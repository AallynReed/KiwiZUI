package
{
   public class Legacy
   {

      public function Legacy()
      {
         super();
      }

      public static function parse(text:String) : Object
      {
         var at:Array = [0];
         var root:Object = obj(text,at);
         var settings:Object = root == null ? null : root.settings;
         var options:Array = [];
         var key:String = null;
         if(root == null || root.modname == null || root.file == null || settings == null)
         {
            return null;
         }
         var order:Array = ordered(settings,text);
         var i:int = 0;
         while(i < order.length)
         {
            key = String(order[i]);
            push(options,key,settings[key]);
            i++;
         }
         var swf:String = String(root.file);
         var band:String = Hub.stem(swf);
         return {"swf":swf,"title":String(root.modname),"options":options,"readme":"",
                 "group":band.length == 0 ? "" : band.charAt(0).toUpperCase() + band.substring(1)};
      }

      private static function ordered(settings:Object, text:String) : Array
      {
         var key:String = null;
         var found:Array = [];
         var out:Array = [];
         var i:int = 0;
         for(key in settings)
         {
            if(settings[key] is Object)
            {
               found.push({"key":key,"at":text.indexOf("'" + key + "':")});
            }
         }
         found.sortOn("at",Array.NUMERIC);
         while(i < found.length)
         {
            out.push((found[i] as Object).key);
            i++;
         }
         return out;
      }

      private static function push(options:Array, key:String, spec:Object) : void
      {
         var kind:String = spec.type == null ? "" : String(spec.type);
         var label:String = spec.title == null ? key : String(spec.title);
         var value:String = spec.value == null ? "" : String(spec.value);
         var option:Object = {"key":key,"label":label,"value":value,"note":
                              spec.description == null ? "" : String(spec.description),
                              "emit":"","choices":[],"min":0,"max":100,"step":1,
                              "places":0,"zero":"","suffix":"","len":0};
         switch(kind)
         {
            case "checkbox":
               option.type = Hub.CHECK;
               option.emit = "bool";
               break;
            case "dropdown":
               option.type = Hub.COMBO;
               option.choices = pairs(spec.options == null ? "" : String(spec.options));
               break;
            case "slider":
               option.type = Hub.SLIDER;
               option.min = Number(spec.min);
               option.max = Number(spec.max);
               option.step = Number(spec.stepsize);
               break;
            case "colorpicker":
               option.type = Hub.COLOR;
               break;
            case "input":
            case "checkboxedit":
               option.type = Hub.INPUT;
               break;
            default:
               return;
         }
         options.push(option);
      }

      private static function pairs(raw:String) : Array
      {
         var out:Array = [];
         var parts:Array = raw.split("|");
         var i:int = 0;
         while(i < parts.length)
         {
            if(String(parts[i]).length > 0)
            {
               out.push([parts[i],parts[i]]);
            }
            i++;
         }
         return out;
      }

      private static function obj(text:String, at:Array) : Object
      {
         var key:String = null;
         var out:Object = {};
         if(skip(text,at) != "{")
         {
            return null;
         }
         at[0]++;
         if(skip(text,at) == "}")
         {
            at[0]++;
            return out;
         }
         while(at[0] < text.length)
         {
            key = quoted(text,at);
            if(key == null || skip(text,at) != ":")
            {
               return null;
            }
            at[0]++;
            if(skip(text,at) == "{")
            {
               out[key] = obj(text,at);
               if(out[key] == null)
               {
                  return null;
               }
            }
            else
            {
               out[key] = quoted(text,at);
               if(out[key] == null)
               {
                  return null;
               }
            }
            if(skip(text,at) == ",")
            {
               at[0]++;
            }
            else
            {
               if(skip(text,at) != "}")
               {
                  return null;
               }
               at[0]++;
               return out;
            }
         }
         return null;
      }

      private static function quoted(text:String, at:Array) : String
      {
         var shut:int = 0;
         if(skip(text,at) != "'")
         {
            return null;
         }
         shut = text.indexOf("'",at[0] + 1);
         if(shut < 0)
         {
            return null;
         }
         var out:String = text.substring(at[0] + 1,shut);
         at[0] = shut + 1;
         return out;
      }

      private static function skip(text:String, at:Array) : String
      {
         while(at[0] < text.length && text.charAt(at[0]) <= " ")
         {
            at[0]++;
         }
         return at[0] < text.length ? text.charAt(at[0]) : "";
      }
   }
}
