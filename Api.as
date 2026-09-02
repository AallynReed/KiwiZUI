package
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import flash.utils.getTimer;

   public class Api
   {

      public static const LISTEN:String = "listen";

      public static const HERE:String = "api";

      public static const SPENT:String = "done";

      public static const GONE:String = "false";

      private static const QUIET:int = 600;

      private static const LATEST:int = 4000;

      private static const EARS:int = 8;

      private static const HOLD:int = 250;

      private var section:String;

      private var runs:Object = {};

      private var ears:Array = [];

      private var reports:Object = {};

      private var passed:Object = {};

      private var screen:DisplayObject;

      private var due:int = 0;

      private var live:Boolean = false;

      private var used:Array = [];

      private var hushed:Object = {};

      private var saying:Array = [];

      private var later:Array = [];

      public function Api(section:String)
      {
         super();
         this.section = section;
         this.command(LISTEN,this.onListen,true);
      }

      public function command(key:String, run:Function, atOnce:Boolean = false) : Api
      {
         this.runs[key.toLowerCase()] = {"run":run,"now":atOnce,"held":false};
         Config.always(key);
         return this;
      }

      public function holds(key:String) : Api
      {
         var command:Object = this.runs[key.toLowerCase()];
         if(command != null)
         {
            command.held = true;
         }
         return this;
      }

      public function spent(key:String) : void
      {
         var at:String = key.toLowerCase();
         if(this.runs[at] == null || this.used.indexOf(at) >= 0)
         {
            return;
         }
         this.used.push(at);
         this.wake();
      }

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
            if(value != SPENT && command.held != true)
            {
               this.used.push(key);
               this.wake();
            }
         }
         return true;
      }

      public function stray(key:String, value:String) : void
      {
         if(!this.live || this.ears.length == 0 || this.passed[key] == value)
         {
            return;
         }
         this.passed[key] = value;
         this.spread(key,value);
      }

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

      public function hears(section:String) : Boolean
      {
         return this.ears.indexOf(section == null ? "" : section.toLowerCase()) >= 0;
      }

      public function send(swf:String, key:String, value:String) : void
      {
         post(swf,key,value);
      }

      public static function post(swf:String, key:String, value:String) : void
      {
         write(swf,key,value);
      }

      public function say(swf:String, key:String, value:String) : void
      {
         write(swf,key,SPENT);
         this.saying.push([swf,key,value]);
         this.wake();
      }

      public function ask(swf:String, key:String) : void
      {
         write(swf,key,GONE);
         this.saying.push([swf,key,Config.PRESENT]);
         this.later.push([swf,key,GONE,getTimer() + HOLD]);
         this.wake();
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
         this.used.length = 0;
         i = 0;
         while(i < this.saying.length)
         {
            said = this.saying[i] as Array;
            write(String(said[0]),String(said[1]),String(said[2]));
            i++;
         }
         this.saying.length = 0;
         i = 0;
         while(i < this.later.length)
         {
            said = this.later[i] as Array;
            if(getTimer() < int(said[3]))
            {
               i++;
            }
            else
            {
               write(String(said[0]),String(said[1]),String(said[2]));
               this.later.splice(i,1);
            }
         }
         if(this.live && this.screen != null && this.later.length == 0)
         {
            this.screen.removeEventListener(Event.ENTER_FRAME,this.onFrame);
         }
      }

      private function wake() : void
      {
         if(this.screen != null)
         {
            this.screen.addEventListener(Event.ENTER_FRAME,this.onFrame);
         }
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
