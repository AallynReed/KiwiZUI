package
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import flash.utils.getTimer;

   /** Instructions one mod sends another, on the channel the settings hub already uses.
    *
    *  OnSaveConfig is addressed by SWF and not by caller, so a write naming a section
    *  lands in the .cfg of whichever mod packs that SWF and Trove relays it back to that
    *  mod through its own loadModConfiguration. The hub carries a setting that way. The
    *  same relay carries an instruction just as well:
    *
    *      ExternalInterface.call("UIComponent.OnSaveConfig","navigationmenu.swf",
    *                             "open","inventory");
    *
    *  and the mod that owns the navigation menu opens the inventory. It is the only way
    *  two mods can speak at all - nothing can ask for a section that is not its own.
    *
    *  Three things this has to get right, and all three are about the channel rather
    *  than the protocol.
    *
    *  **The load looks exactly like a caller.** Trove relays the whole section a key at
    *  a time when the screen loads, and Trove writes a command key into the file like
    *  any other, so an instruction from last session arrives on this one indistinguishable
    *  from a mod asking for it now. Nothing in the format can separate them, so the burst
    *  is read as a burst: instructions count once the file has stopped arriving.
    *
    *  **An instruction is one shot.** It is acted on as it arrives and no flag is kept,
    *  because a flag has to be cleared by whoever set it and the mod that set it may
    *  already be gone. A caller that wants a thing twice writes twice.
    *
    *  **A report costs a config write.** Trove rewrites the whole file for one key, so
    *  news goes out only when it has changed, and a listener that arrives late is caught
    *  up from what has already been said rather than by anyone repeating themselves. */
   public class Api
   {

      /** A mod naming its own section, to be told what this screen knows. */
      public static const LISTEN:String = "listen";

      /** What a screen answers a new listener with, carrying its own section.
       *
       *  It is the only way round this handshake goes: `hears` tells a screen which mods
       *  have subscribed to it, and this tells a mod which screens it reached. A feature
       *  that needs another mod to do something - rather than merely to be told
       *  something - has to know that mod is there before it asks. */
      public static const HERE:String = "api";

      /** What a key is set to once its instruction has been carried out.
       *
       *  Trove relays a write when the value *changes*, so a caller asking twice for the
       *  same thing is heard once and then never again - `open = collections` written
       *  over `open = collections` is not a message, it is the same message still lying
       *  there. Measured the hard way: the second and third time a mod asked for a
       *  window, nothing arrived and the config file looked exactly as it had after the
       *  first, which is a failure with no symptom.
       *
       *  So an instruction is consumed. Having acted, the screen writes the key back to
       *  this in its own section, which clears the way for the next one and leaves
       *  nothing behind to be misread on the next login. */
      public static const SPENT:String = "done";

      /** Config silence before an instruction is acted on. */
      private static const QUIET:int = 600;

      /** From arming, if no config ever arrives - the case where there is no file in
       *  ModCfgs\ at all, and the one where waiting for quiet would wait forever. */
      private static const LATEST:int = 4000;

      /** A listener costs a config write per piece of news. The cap is not for the
       *  honest case, which is one or two, but for the mod that subscribes in a loop. */
      private static const EARS:int = 8;

      private var section:String;

      private var runs:Object = {};

      private var ears:Array = [];

      /** Every report made so far, which is the state a late listener is given. Also
       *  what makes a report silent when it says what the last one said. */
      private var reports:Object = {};

      private var passed:Object = {};

      private var screen:DisplayObject;

      private var due:int = 0;

      private var live:Boolean = false;

      /** Instructions carried out this frame, to be written off on the next one. Not
       *  written off where they were acted on: that is inside the read handler, and a
       *  write from there is the one thing this channel cannot take. */
      private var used:Array = [];

      /** Keys whose next arrival is this screen's own writing-off coming back, and not a
       *  caller saying anything. */
      private var hushed:Object = {};

      /** Instructions waiting for their second beat. See say(). */
      private var saying:Array = [];

      public function Api(section:String)
      {
         super();
         this.section = section;
         this.command(LISTEN,this.onListen,true);
      }

      /** One instruction this screen answers to.
       *
       *  run is handed the value and the key, so a family of keys that mean the same
       *  thing - one per screen, in the older protocol - is a single handler rather
       *  than twenty two.
       *
       *  atOnce is for the ones that are safe before the file has settled. Saying who
       *  you are changes nothing, and a listener made to wait out the load burst would
       *  miss whatever news arrives during it. */
      public function command(key:String, run:Function, atOnce:Boolean = false) : Api
      {
         this.runs[key.toLowerCase()] = {"run":run,"now":atOnce};
         return this;
      }

      /** Arms the beat that decides the load burst is over. */
      public function watch(screen:DisplayObject) : void
      {
         if(this.screen != null)
         {
            return;
         }
         this.screen = screen;
         this.due = getTimer() + LATEST;
         this.screen.addEventListener(Event.ENTER_FRAME,this.onFrame);
      }

      /** Every key the screen is given, whether or not it is an instruction: the wait
       *  is for the file to go quiet, and a setting arriving says the file is still
       *  coming as clearly as an instruction does.
       *
       *  True means the key was this protocol's and the screen has nothing else to do
       *  with it - including the case where it was recognised and deliberately not
       *  acted on, which is what the load burst is. */
      public function run(key:String, value:String) : Boolean
      {
         var command:Object = this.runs[key];
         if(!this.live)
         {
            this.due = getTimer() + QUIET;
         }
         if(command == null)
         {
            return false;
         }
         if(this.hushed[key] != null && value == SPENT)
         {
            delete this.hushed[key];
            return true;
         }
         if(this.live || command.now == true)
         {
            (command.run as Function)(value,key);
            if(value != SPENT)
            {
               this.used.push(key);
            }
         }
         return true;
      }

      /** A key that is neither an instruction nor a setting of this screen's, handed to
       *  whoever is listening.
       *
       *  It is how a feature can move out of a screen without taking its mods with it.
       *  Anything already written to answer the older navigation menu addresses
       *  navigationmenu.swf, and a minimap that now lives in a mod of its own would
       *  never see a word of it - so the screen that owns the section passes on what is
       *  not its own rather than dropping it. */
      public function stray(key:String, value:String) : void
      {
         if(!this.live || this.ears.length == 0 || this.passed[key] == value)
         {
            return;
         }
         this.passed[key] = value;
         this.spread(key,value);
      }

      /** News, to every mod that asked for it. */
      public function tell(key:String, value:String) : void
      {
         if(this.reports[key] == value)
         {
            return;
         }
         this.reports[key] = value;
         this.spread(key,value);
      }

      public function get armed() : Boolean
      {
         return this.live;
      }

      /** Whether the mod that owns a screen is here and speaking.
       *
       *  Subscribing is an announcement as much as a request - a mod that asks to be
       *  told what this screen knows has said its own section out loud - so a feature
       *  that needs two mods can ask for its other half by name and stay off until it
       *  answers. That is what keeps a suite modular rather than all-or-nothing: the
       *  minimap is drawn by the navigation menu and refreshed by whoever owns map.swf,
       *  and with only one of the two installed the option is simply not live.
       *
       *  It cannot be asked before the other mod has booted, so ask it every frame
       *  rather than once. */
      public function hears(section:String) : Boolean
      {
         return this.ears.indexOf(section == null ? "" : section.toLowerCase()) >= 0;
      }

      /** A word to a section that is not ours: an instruction to another mod, where
       *  tell() is news to whoever asked for it. No two writes are folded together
       *  here - an instruction that says what the last one said is a second instruction,
       *  and the caller is the only thing that knows whether it meant it twice. */
      public function send(swf:String, key:String, value:String) : void
      {
         post(swf,key,value);
      }

      /** The same thing for a screen with nothing else to say. A mod that only feeds
       *  another one has no instructions of its own to answer and no listeners to keep,
       *  so it needs a channel rather than a bus. */
      public static function post(swf:String, key:String, value:String) : void
      {
         write(swf,key,value);
      }

      /** Say something whether or not it is what the file already says.
       *
       *  Trove relays a write when the value changes, so an instruction that was sent
       *  and never carried out is an instruction that can never be sent again - the
       *  second one is the same words already lying there and nothing is relayed. Which
       *  is exactly the state a mod is left in when the screen it was talking to had its
       *  window shut.
       *
       *  So the key is written off first and the instruction goes out on the next beat.
       *  Two frames rather than two calls in one, because a pair of writes in the same
       *  frame is a pair Trove is at liberty to fold into the last one, which would be
       *  no change at all. */
      public function say(swf:String, key:String, value:String) : void
      {
         write(swf,key,SPENT);
         this.saying.push([swf,key,value]);
      }

      private function onListen(value:String, key:String) : void
      {
         var swf:String = value == null ? "" : value.toLowerCase();
         var said:String = null;
         if(swf.length < 5 || swf.substring(swf.length - 4) != ".swf" || swf == this.section)
         {
            return;
         }
         if(this.ears.indexOf(swf) >= 0 || this.ears.length >= EARS)
         {
            return;
         }
         this.ears.push(swf);
         write(swf,HERE,this.section);
         for(said in this.reports)
         {
            write(swf,said,String(this.reports[said]));
         }
      }

      private function spread(key:String, value:String) : void
      {
         var i:int = 0;
         while(i < this.ears.length)
         {
            write(String(this.ears[i]),key,value);
            i++;
         }
      }

      /** The beat stays on the screen for the life of it. Arming happens once, but
       *  writing off a spent instruction happens whenever one is carried out. */
      private function onFrame(e:Event) : void
      {
         var key:String = null;
         var said:Array = null;
         var i:int = 0;
         if(!this.live && getTimer() >= this.due)
         {
            this.live = true;
         }
         while(i < this.used.length)
         {
            key = String(this.used[i]);
            this.hushed[key] = true;
            write(this.section,key,SPENT);
            i++;
         }
         this.used = [];
         i = 0;
         while(i < this.saying.length)
         {
            said = this.saying[i] as Array;
            write(String(said[0]),String(said[1]),String(said[2]));
            i++;
         }
         this.saying = [];
      }

      private static function write(swf:String, key:String, value:String) : void
      {
         if(!IggyFunctions.inIggy)
         {
            return;
         }
         ExternalInterface.call("UIComponent.OnSaveConfig",swf,key,value);
      }
   }
}
