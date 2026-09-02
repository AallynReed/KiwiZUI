package
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import flash.utils.getTimer;

   public class Config
   {

      private static const SETTLE:int = 600;

      private static const LATEST:int = 4000;

      private static const GRACE:int = 1200;

      private static const TRIES:int = 3;

      private static const BATCH:int = 4;

      public static const PROBE:String = "is_config";

      private static const LOOSE:Object = {};

      public static const PRESENT:String = "true";

      private var name:String;

      private var arrived:Object;

      private var mirrors:Array = [];

      private var held:Object = {};

      private var loaded:Boolean = false;

      private var due:int = 0;

      private var screen:DisplayObject;

      private var mine:Object = {};

      private var pending:Array;

      private var defaults:Function;

      private var absent:Function;

      private var tries:int = 0;

      private var seedAt:int = 0;

      private var echoed:String;

      public function Config(section:String)
      {
         super();
         this.name = section;
         this.arrived = {};
      }

      public function mirror(section:String) : void
      {
         this.mirrors.push(section);
      }

      public function note(key:String, value:String = null) : String
      {
         var soon:int = 0;
         var lower:String = key == null ? "" : key.toLowerCase();
         var text:String = value == null ? "" : String(value);
         var news:Boolean = this.arrived[lower] == null || this.held[lower] != text;
         this.arrived[lower] = true;
         this.held[lower] = text;
         if(lower == PROBE)
         {
            this.echoed = value;
         }
         soon = getTimer() + SETTLE;
         if(this.pending != null && soon < this.due)
         {
            this.due = soon;
         }
         if(this.mine[lower] != null && this.mine[lower] == text)
         {
            delete this.mine[lower];
            return PROBE;
         }
         if(!news && LOOSE[lower] == null)
         {
            return PROBE;
         }
         if(news)
         {
            this.relay(lower,text);
         }
         return lower;
      }

      public static function always(key:String) : void
      {
         LOOSE[key.toLowerCase()] = true;
      }

      private function relay(key:String, value:String) : void
      {
         var i:int = 0;
         if(!this.loaded || key == PROBE || this.mirrors.length == 0 || !IggyFunctions.inIggy)
         {
            return;
         }
         while(i < this.mirrors.length)
         {
            ExternalInterface.call("UIComponent.OnSaveConfig",String(this.mirrors[i]),key,value);
            i++;
         }
      }

      private function reconcile(keys:Array, defaultFor:Function) : void
      {
         var key:String = null;
         var i:int = 0;
         if(this.mirrors.length == 0)
         {
            return;
         }
         while(i < keys.length)
         {
            key = String(keys[i]).toLowerCase();
            if(this.held[key] != null && this.held[key] != String(defaultFor(key)))
            {
               this.relay(key,String(this.held[key]));
            }
            i++;
         }
      }

      public function get confirmed() : Boolean
      {
         return this.echoed == PRESENT;
      }

      public function saw(key:String) : Boolean
      {
         return this.arrived[key.toLowerCase()] != null;
      }

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

      public function seedMissing(keys:Array, defaultFor:Function) : int
      {
         var key:String = null;
         var written:int = 0;
         while(this.seedAt < keys.length && written < BATCH)
         {
            key = String(keys[this.seedAt]);
            if(!this.saw(key))
            {
               this.save(key,String(defaultFor(key)));
               written++;
            }
            this.seedAt++;
         }
         return keys.length - this.seedAt;
      }

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
            if(this.seedMissing(this.pending,this.defaults) > 0)
            {
               return;
            }
            this.loaded = true;
            this.reconcile(this.pending,this.defaults);
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

      public static function hexa(color:uint, alpha:Number) : String
      {
         var byte:int = Math.round(clamp(alpha,0,1,1) * 255);
         return "#" + hex(color) + (byte >= 255 ? "" : pair(byte));
      }

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

      public static function blank(raw:String) : Boolean
      {
         return digits(raw).length == 0;
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

      public static function number(raw:String, low:Number, high:Number, fallback:Number) : Number
      {
         var text:String = raw == null ? "" : raw.split(" ").join("");
         return text.length == 0 ? fallback : clamp(Number(text),low,high,fallback);
      }
   }
}
