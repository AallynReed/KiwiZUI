package
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import flash.utils.getTimer;

   public class Hub
   {

      public static const ADDRESS:String = "likedworlds.swf";

      public static const VERSION:String = "3";

      public static const MARK:String = "zm_";

      public static const CHECK:String = "check";

      public static const SLIDER:String = "slider";

      public static const SPIN:String = "spin";

      public static const COMBO:String = "combo";

      public static const COLOR:String = "color";

      public static const ALPHA:String = "alpha";

      public static const INPUT:String = "input";

      public static const LIST:String = "list";

      public static const STEPPER:String = "stepper";

      public static const HEADING:String = "heading";

      private static const SETTLE:int = 2000;

      private static const QUIET:int = 1500;

      private var section:String;

      private var title:String;

      private var band:String;

      private var about:String = "";

      private var reader:Function;

      private var options:Array = [];

      private var screen:DisplayObject;

      private var due:int;

      private var last:String;

      private var dirty:Boolean = false;

      private var armed:Boolean = false;

      public function Hub(section:String, title:String, valueOf:Function, group:String = "")
      {
         super();
         this.section = section;
         this.title = title;
         this.reader = valueOf;
         this.band = group;
      }

      public function readme(text:String) : Hub
      {
         this.about = text;
         return this;
      }

      public function option(key:String, type:String, label:String, params:String = "",
                             note:String = "") : Hub
      {
         this.options.push([key,type,label,params,note]);
         return this;
      }

      public function slug() : String
      {
         return flatten(this.title) + "__" + flatten(stem(this.section));
      }

      public static function flatten(text:String) : String
      {
         var out:String = "";
         var c:String = null;
         var i:int = 0;
         var low:String = text.toLowerCase();
         while(i < low.length)
         {
            c = low.charAt(i);
            out += c >= "a" && c <= "z" || c >= "0" && c <= "9" ? c : "_";
            i++;
         }
         return out;
      }

      public static function stem(swf:String) : String
      {
         var at:int = swf.lastIndexOf(".");
         return at < 0 ? swf : swf.substring(0,at);
      }

      public function watch(screen:DisplayObject) : void
      {
         if(this.screen != null)
         {
            return;
         }
         this.screen = screen;
         this.due = getTimer() + SETTLE;
         this.screen.addEventListener(Event.ENTER_FRAME,this.onFrame);
      }

      private function onFrame(e:Event) : void
      {
         if(getTimer() < this.due)
         {
            return;
         }
         if(!this.armed)
         {
            this.armed = true;
            this.dirty = true;
         }
         if(this.dirty)
         {
            this.dirty = false;
            this.record();
         }
         this.screen.removeEventListener(Event.ENTER_FRAME,this.onFrame);
      }

      public function publish() : void
      {
         this.dirty = true;
         if(this.armed)
         {
            this.due = getTimer() + QUIET;
         }
         if(this.screen != null)
         {
            this.screen.addEventListener(Event.ENTER_FRAME,this.onFrame);
         }
      }

      private function record() : void
      {
         var line:String = this.declaration();
         if(!IggyFunctions.inIggy || line == this.last)
         {
            return;
         }
         this.last = line;
         ExternalInterface.call("UIComponent.OnSaveConfig",ADDRESS,MARK + this.slug(),line);
      }

      public static function write(swf:String, key:String, value:String) : void
      {
         if(!IggyFunctions.inIggy)
         {
            return;
         }
         ExternalInterface.call("UIComponent.OnSaveConfig",swf,key,value);
      }

      public function declaration() : String
      {
         var row:Array = null;
         var out:String = VERSION + "|" + esc(this.section) + "|" + esc(this.title)
                        + "|" + esc(this.band) + "|" + esc(this.about);
         var i:int = 0;
         while(i < this.options.length)
         {
            row = this.options[i] as Array;
            out += "|" + esc(String(row[0])) + "~" + esc(String(row[1])) + "~"
                       + esc(String(row[2])) + "~" + esc(this.valueOf(String(row[0])))
                       + "~" + esc(String(row[3])) + "~" + esc(String(row[4]));
            i++;
         }
         return out;
      }

      private function valueOf(key:String) : String
      {
         var raw:* = this.reader == null ? null : this.reader(key);
         return raw == null ? "" : String(raw);
      }

      public static function esc(text:String) : String
      {
         if(text == null)
         {
            return "";
         }
         return text.split("\\").join("\\\\").split("\r\n").join("\n")
                    .split("|").join("\\p").split("~").join("\\s")
                    .split("\n").join("\\n");
      }

      public static function unesc(text:String) : String
      {
         var out:String = "";
         var c:String = null;
         var i:int = 0;
         while(i < text.length)
         {
            c = text.charAt(i);
            if(c != "\\" || i == text.length - 1)
            {
               out += c;
               i++;
            }
            else
            {
               c = text.charAt(i + 1);
               out += c == "p" ? "|" : c == "s" ? "~" : c == "n" ? "\n" : c;
               i += 2;
            }
         }
         return out;
      }

      public static function parse(key:String, value:String) : Object
      {
         if(key == null || value == null)
         {
            return null;
         }
         if(key.substr(0,MARK.length) == MARK
         && (value.substr(0,2) == "3|" || value.substr(0,2) == "2|"
          || value.substr(0,2) == "1|"))
         {
            return ours(value);
         }
         if(value.charAt(0) == "{" && value.charAt(value.length - 1) == "}")
         {
            return Legacy.parse(value);
         }
         return null;
      }

      private static function ours(value:String) : Object
      {
         var field:Array = null;
         var parts:Array = cut(value,"|");
         var options:Array = [];
         var era:int = int(parts[0]);
         var old:Boolean = era < 2;
         var i:int = era < 2 ? 3 : (era < 3 ? 4 : 5);
         if(parts.length < i)
         {
            return null;
         }
         while(i < parts.length)
         {
            field = cut(String(parts[i]),"~");
            if(field.length >= 4)
            {
               options.push(shaped(field));
            }
            i++;
         }
         return {"swf":parts[1],"title":parts[2],"options":options,
                 "readme":era < 3 ? "" : String(parts[4]),
                 "group":named(old || String(parts[3]).length == 0
                             ? stem(String(parts[1])) : String(parts[3]))};
      }

      private static function named(text:String) : String
      {
         return text.length == 0 ? "" : text.charAt(0).toUpperCase() + text.substring(1);
      }

      private static function shaped(field:Array) : Object
      {
         var range:Array = null;
         var type:String = String(field[1]);
         var params:String = field.length > 4 ? String(field[4]) : "";
         var out:Object = {"key":field[0],"type":type,"label":field[2],"value":field[3],
                           "note":field.length > 5 ? field[5] : "","emit":"","choices":[],
                           "min":0,"max":100,"step":1,"places":0,"zero":"","suffix":"",
                           "len":0,"prompt":""};
         if(type == SLIDER || type == SPIN || type == STEPPER)
         {
            range = params.split(",");
            out.min = Number(range[0]);
            out.max = range.length > 1 ? Number(range[1]) : 100;
            out.step = range.length > 2 ? Number(range[2]) : 1;
            out.places = range.length > 3 ? int(range[3]) : 0;
            out.zero = range.length > 4 ? String(range[4]) : "";
            out.suffix = range.length > 5 ? String(range[5]) : "";
         }
         else if(type == COMBO)
         {
            out.choices = choices(params);
         }
         else if(type == INPUT)
         {
            out.len = int(params);
         }
         else if(type == LIST)
         {
            out.prompt = params;
         }
         return out;
      }

      private static function choices(params:String) : Array
      {
         var at:int = 0;
         var one:String = null;
         var out:Array = [];
         var parts:Array = params.split(",");
         var i:int = 0;
         while(i < parts.length)
         {
            one = String(parts[i]);
            if(one.length > 0)
            {
               at = one.indexOf("=");
               out.push(at < 0 ? [one,one] : [one.substring(0,at),one.substring(at + 1)]);
            }
            i++;
         }
         return out;
      }

      public static function cut(text:String, sep:String) : Array
      {
         var out:Array = [];
         var field:String = "";
         var c:String = null;
         var i:int = 0;
         while(i < text.length)
         {
            c = text.charAt(i);
            if(c == "\\" && i < text.length - 1)
            {
               field += c + text.charAt(i + 1);
               i += 2;
            }
            else if(c == sep)
            {
               out.push(unesc(field));
               field = "";
               i++;
            }
            else
            {
               field += c;
               i++;
            }
         }
         out.push(unesc(field));
         return out;
      }
   }
}
