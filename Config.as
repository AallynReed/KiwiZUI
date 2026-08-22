package
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import flash.utils.getTimer;

   /** Trove keeps a mod's settings in %APPDATA%\Trove\ModCfgs\<Mod Title>.cfg and
    *  relays the section back one key per call. The mod cannot create that file;
    *  it can only fill in keys missing from one that is already there.
    *
    *  So seeding is per key, never behind a single sentinel: record which keys came
    *  back, then write only the ones that did not. Gating the whole write on "did
    *  the sentinel arrive" means every option added after a player's first run stays
    *  absent from their file and is undiscoverable. Recording each key self-heals as
    *  the key list grows.
    *
    *  Writes must not happen from inside the read handler - the write is relayed
    *  straight back and the mod spins on itself until it dies. Call seedMissing()
    *  from a later beat instead. Keys arrive lowercased, and a dot in a key makes
    *  Trove split it into its own section, so keys stay flat. */
   public class Config
   {

      /** How long past the first key that arrives before seeding, and how long from
       *  arming before giving up on one arriving at all. */
      private static const SETTLE:int = 600;

      private static const LATEST:int = 4000;

      /** How long a written probe is given to come back, and how many go out before
       *  silence is read as there being no file. */
      private static const GRACE:int = 1200;

      private static const TRIES:int = 3;

      /** What note() answers with when the key it was given is not a setting the screen
       *  has anything to do with: the probe, and the echo of a value this mod itself just
       *  wrote. Screens return on it rather than adopting.
       *
       *  The key itself is the probe's - not a setting and not in any mod's key list, it
       *  exists only to be written and waited for. */
      public static const PROBE:String = "is_config";

      public static const PRESENT:String = "true";

      private var name:String;

      private var arrived:Object;

      private var mirrors:Array = [];

      private var due:int = 0;

      private var screen:DisplayObject;

      /** Keys this mod has written and is still waiting to see come back.
       *
       *  Every `OnSaveConfig` is relayed straight back in as though the player had set it,
       *  and a screen that repaints on each arriving key then repaints for news it made up
       *  itself - once for the sentinel, once for every key it seeded and once for each
       *  probe. On a heavy screen that is a visible hitch a few seconds after opening, and
       *  it happens in every mod because they all write and all repaint.
       *
       *  An echo carries nothing the screen does not already hold, so it is swallowed. Only
       *  the first one: a value that matches by coincidence later is the player's. */
      private var mine:Object = {};

      private var pending:Array;

      private var defaults:Function;

      private var absent:Function;

      private var tries:int = 0;

      private var echoed:String;

      public function Config(section:String)
      {
         super();
         this.name = section;
         this.arrived = {};
      }

      /** Another section to keep in step with this one. Trove gives each SWF of a mod
       *  its own section and lets neither read the other's, so a setting two screens
       *  share is written to both: the screen that changed it reads its own copy back,
       *  and the other finds an identical one already waiting the next time it loads.
       *
       *  Mirroring the write rather than the read is what makes that work at all - there
       *  is no way to ask for a section that is not yours. */
      public function mirror(section:String) : void
      {
         this.mirrors.push(section);
      }

      /** Record a key as present and hand back the lowercase form to compare on. The
       *  probe is the one key whose value matters as well as its arrival, so it is the
       *  one key kept. */
      public function note(key:String, value:String = null) : String
      {
         var soon:int = 0;
         var lower:String = key == null ? "" : key.toLowerCase();
         this.arrived[lower] = true;
         if(lower == PROBE)
         {
            this.echoed = value;
         }
         soon = getTimer() + SETTLE;
         if(this.pending != null && soon < this.due)
         {
            this.due = soon;
         }
         if(this.mine[lower] != null && this.mine[lower] == (value == null ? "" : String(value)))
         {
            delete this.mine[lower];
            return PROBE;
         }
         return lower;
      }

      /** The probe went out and came back with the value that went out, so there is a
       *  file in ModCfgs\ and a write to it is kept. Anything that only means something
       *  once it can be remembered waits on this. */
      public function get confirmed() : Boolean
      {
         return this.echoed == PRESENT;
      }

      public function saw(key:String) : Boolean
      {
         return this.arrived[key.toLowerCase()] != null;
      }

      /** Guarded on inIggy for the same reason Option.click is: outside the game there
       *  is no bridge and the call throws, which would make the widgets untestable in
       *  a plain player. */
      public function save(key:String, value:String) : void
      {
         var i:int = 0;
         if(!IggyFunctions.inIggy)
         {
            return;
         }
         this.mine[key.toLowerCase()] = value == null ? "" : String(value);
         ExternalInterface.call("UIComponent.OnSaveConfig",this.name,key,value);
         while(i < this.mirrors.length)
         {
            ExternalInterface.call("UIComponent.OnSaveConfig",String(this.mirrors[i]),key,value);
            i++;
         }
      }

      /** Writes only what never came back. defaultFor(key) returns the literal to
       *  write, so each caller keeps its own typed key table.
       *
       *  **There is no sentinel.** This used to write a `seeded` key and there was never
       *  anything that read it: seeding is per key, so the file itself says what is
       *  missing and a mark saying "this file has been seeded" answers a question nobody
       *  asks. All it did was put a line in every player's config that they could edit
       *  and watch do nothing, and spend a write saying so. Gating on one is the older
       *  mistake it is a leftover of - with it, every option added after a player's first
       *  run never reaches them. */
      public function seedMissing(keys:Array, defaultFor:Function) : int
      {
         var key:String = null;
         var written:int = 0;
         var i:int = 0;
         while(i < keys.length)
         {
            key = String(keys[i]);
            if(!this.saw(key))
            {
               this.save(key,String(defaultFor(key)));
               written++;
            }
            i++;
         }
         return written;
      }

      /** Everything the config needs from a screen, armed once from its constructor.
       *
       *  Seeding waits a beat because it cannot run from the read handler - the write
       *  is relayed straight back and the mod spins on itself until it dies. It waits
       *  SETTLE past the first key that arrives, or LATEST from here if none ever does,
       *  which is the case where there is no file to read and so the one worth saying
       *  something about.
       *
       *  Then the probe: whether ModCfgs\<Mod Title>.cfg is there at all, answered the
       *  only way it can be. OnSaveConfig lands in a file that already exists and
       *  nowhere else, and a write Trove accepts is relayed straight back through
       *  loadModConfiguration - so a key is written and waited for. It returns carrying
       *  the value that went out if the file is there, and nothing happens if it is not.
       *
       *  Written up to TRIES times before that is believed. The outbound bridge comes up
       *  silently and a call made before it does goes nowhere, so one unanswered probe
       *  means nothing on its own; three across four seconds is a file that is not there.
       *  missing() then runs once, and never again that session - there is nowhere to
       *  record that it was read. A screen with no window to say it in passes nothing
       *  and the probe still runs, so every one of these files carries the same mark
       *  and every screen answers the question the same way.
       *
       *  Paced on ENTER_FRAME rather than a Timer: callbacks can arrive before the first
       *  frame tick, and a timer started that early may never fire. */
      public function watch(screen:DisplayObject, keys:Array, defaultFor:Function, missing:Function = null) : void
      {
         if(this.screen != null)
         {
            return;
         }
         this.screen = screen;
         this.pending = keys;
         this.defaults = defaultFor;
         this.absent = missing;
         this.due = getTimer() + LATEST;
         this.screen.addEventListener(Event.ENTER_FRAME,this.onFrame);
      }

      private function onFrame(e:Event) : void
      {
         if(this.tries > 0 && this.confirmed)
         {
            this.stop();
            return;
         }
         if(getTimer() < this.due)
         {
            return;
         }
         if(this.pending != null)
         {
            this.seedMissing(this.pending,this.defaults);
            this.pending = null;
         }
         if(this.tries < TRIES)
         {
            this.tries++;
            this.save(PROBE,PRESENT);
            this.due = getTimer() + GRACE;
            return;
         }
         this.stop();
         if(this.absent != null)
         {
            this.absent();
         }
      }

      private function stop() : void
      {
         this.screen.removeEventListener(Event.ENTER_FRAME,this.onFrame);
      }

      public static function hex(color:uint) : String
      {
         var digits:String = (color & 0xFFFFFF).toString(16).toUpperCase();
         while(digits.length < 6)
         {
            digits = "0" + digits;
         }
         return digits;
      }

      public static function pair(value:int) : String
      {
         var digits:String = (value & 0xFF).toString(16).toUpperCase();
         return digits.length < 2 ? "0" + digits : digits;
      }

      /** The one place the literal is spelled. Fully opaque is written #RRGGBB, so a
       *  config file that never touches transparency reads exactly as it always did
       *  and an FF nobody asked for is not appended to every colour in it. */
      public static function hexa(color:uint, alpha:Number) : String
      {
         var byte:int = Math.round(clamp(alpha,0,1,1) * 255);
         return "#" + hex(color) + (byte >= 255 ? "" : pair(byte));
      }

      /** #RRGGBB, 0xRRGGBB or bare hex, with an optional AA on the end. Falls back
       *  rather than throwing: a typo in a config file must not take the screen down. */
      private static function digits(raw:String) : String
      {
         var text:String = raw == null ? "" : raw.split(" ").join("");
         if(text.charAt(0) == "#")
         {
            return text.substring(1);
         }
         if(text.substring(0,2).toLowerCase() == "0x")
         {
            return text.substring(2);
         }
         return text;
      }

      public static function color(raw:String, fallback:uint) : uint
      {
         var text:String = digits(raw);
         if(text.length == 0)
         {
            return fallback;
         }
         if(text.length == 8)
         {
            text = text.substring(0,6);
         }
         var value:Number = Number("0x" + text);
         return isNaN(value) ? fallback : uint(value) & 0xFFFFFF;
      }

      /** Only an eight digit value carries one. Anything else is opaque, which is what
       *  every colour written before transparency existed has to keep meaning. */
      public static function alpha(raw:String, fallback:Number) : Number
      {
         var text:String = digits(raw);
         if(text.length != 8)
         {
            return text.length == 0 ? fallback : 1;
         }
         var value:Number = Number("0x" + text.substring(6));
         return isNaN(value) ? fallback : value / 255;
      }

      public static function flag(raw:String) : Boolean
      {
         var text:String = raw == null ? "" : raw.toLowerCase();
         return text == "1" || text == "true" || text == "yes" || text == "on";
      }

      public static function clamp(value:Number, low:Number, high:Number, fallback:Number) : Number
      {
         if(isNaN(value))
         {
            return fallback;
         }
         return value < low ? low : (value > high ? high : value);
      }

      /** An empty value falls back rather than clamping. Number("") is 0, not NaN, so
       *  a key present in the file with nothing after the equals used to come out as
       *  the bottom of the range - a window at its minimum opacity, and nothing to say
       *  why. */
      public static function number(raw:String, low:Number, high:Number, fallback:Number) : Number
      {
         var text:String = raw == null ? "" : raw.split(" ").join("");
         return text.length == 0 ? fallback : clamp(Number(text),low,high,fallback);
      }
   }
}
