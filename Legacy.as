package
{
   /** Criteox's Mod Setting Manager got there first, and mods already declare themselves
    *  to likedworlds.swf in its format. Reading it costs one parser and means every mod
    *  already wired for that hub appears in this one with nothing asked of its author.
    *
    *      {'modname':'X','file':'y.swf','settings':{'k':{'type':'checkbox','title':'T',
    *       'description':'D','value':'true'}}}
    *
    *  Quoted keys, quoted scalars, nested objects, and no escaping anywhere - a quote
    *  inside a label breaks the format at the writing end, so nothing here tries to
    *  recover one. What it does do is refuse rather than throw: a malformed declaration
    *  from someone else's mod must not take this screen down with it.
    *
    *  Its value dialect is its own - a flag is 'true' and 'false' where ours is 1 and 0 -
    *  so each option carries how to write it back. A hub that handed a legacy mod our
    *  literal would silently turn every one of its flags off.
    *
    *  What comes back carries every field Hub.ours and Hub.shaped set, down to the ones
    *  a legacy declaration has nothing to say about. The hub reads a record without
    *  asking which parser built it, and Iggy throws on a property that is missing rather
    *  than handing back undefined the way the standalone player does - so a field left
    *  out here is not an empty value in the panel, it is the panel. */
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

      /** The order the author wrote the settings in, which is the order they are meant
       *  to be read in. A for..in over an object hands them back in whatever order the
       *  runtime feels like, so the keys are put back into source order by where each
       *  one appears in the text it was parsed from. */
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

      /** A dropdown's choices are its own labels, so each one stands for itself. */
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
