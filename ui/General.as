package ui
{
   public class General
   {

      public static const TITLE:String = "Zakros UI";

      public static const ID:String = "zg";

      public static const GROUP:String = "Shared appearance";

      public static const APPLY:String = "zg_apply";

      public static const REVERT:String = "zg_revert";

      public static const MARK:String = "zg_was_";

      public static const HOLD:String = "zg_set_";

      public static const READ:String =
         "Colours every Zakros UI mod shares. Set them here, press Apply, and the value "
       + "is written into every installed mod that offers it.\n\n"
       + "Nothing changes until Apply is pressed. Revert puts back what each mod held "
       + "before the last Apply, and a mod's own page still overrides anything set here.\n\n"
       + "A screen already open keeps the values it loaded. Changes show the next time "
       + "that screen is opened.";

      public static const LABELS:Object = {
         "panel":"Panel color",
         "accent":"Accent color",
         "label":"Label color",
         "value":"Text color",
         "outline":"Text outline",
         "outlinecolor":"Outline color",
         "red":"Red",
         "orange":"Orange",
         "yellow":"Yellow",
         "green":"Green",
         "danger":"Danger",
         "purple":"Purple",
         "water":"Water",
         "air":"Air",
         "fire":"Fire",
         "cosmic":"Cosmic",
         "statlight":"Light"};

      public static const ORDER:Array = ["panel","accent","label","value","outline",
                                         "outlinecolor"];

      public function General()
      {
         super();
      }

      public static function record(mods:Object, order:Array, held:Object,
                                    saved:Object, busy:Boolean = false) : Object
      {
         var slot:Object = null;
         var key:String = null;
         var specs:Array = [];
         var wanted:Array = keys();
         var seen:Object = tally(mods,order);
         var i:int = 0;
         while(i < wanted.length)
         {
            key = String(wanted[i]);
            slot = seen[key];
            if(slot != null && int(slot.mods) >= 2)
            {
               specs.push(Hub.spec(key,shape(slot),
                                   named(key) + "  (" + slot.mods + ")",
                                   held[key] != null ? String(held[key]) : String(slot.best),
                                   params(slot),
                                   "Written into " + slot.mods
                                 + " mods when you press Apply."));
            }
            i++;
         }
         if(specs.length == 0)
         {
            return null;
         }
         specs.push(Hub.spec(APPLY,Hub.ACT,busy ? "Applying…" : "Apply to every mod",
                             busy ? "off" : "on","",
                             "Writes each value above into every mod that offers it."));
         specs.push(Hub.spec(REVERT,Hub.ACT,"Revert last apply",
                             busy || bare(saved) ? "off" : "on","",
                             "Puts every mod back to what it held before the last Apply."));
         return {"swf":"","title":TITLE,"group":GROUP,"readme":READ,
                 "options":specs,"id":ID,"raw":""};
      }

      public static function keys() : Array
      {
         var key:String = null;
         var out:Array = ORDER.slice();
         var i:int = 0;
         while(i < renderer.KEYS.length)
         {
            key = String(renderer.KEYS[i]);
            if(out.indexOf(key) < 0)
            {
               out.push(key);
            }
            i++;
         }
         return out;
      }

      private static function named(key:String) : String
      {
         return LABELS[key] != null ? String(LABELS[key])
                                    : key.charAt(0).toUpperCase() + key.substring(1);
      }

      private static function ours(key:String) : Boolean
      {
         return renderer.KEYS.indexOf(key) >= 0;
      }

      private static function bare(saved:Object) : Boolean
      {
         var key:String = null;
         for(key in saved)
         {
            return false;
         }
         return true;
      }

      private static function shape(slot:Object) : String
      {
         var type:String = String((slot.sample as Object).type);
         if(type == Hub.COLOR || type == Hub.ALPHA)
         {
            return Boolean(slot.alpha) ? Hub.ALPHA : Hub.COLOR;
         }
         return type;
      }

      private static function params(slot:Object) : String
      {
         var one:Object = slot.sample;
         var type:String = String(one.type);
         if(type != Hub.STEPPER && type != Hub.SLIDER && type != Hub.SPIN)
         {
            return "";
         }
         return one.min + "," + one.max + "," + one.step + "," + one.places + ","
              + one.zero + "," + one.suffix;
      }

      private static function tally(mods:Object, order:Array) : Object
      {
         var parts:Array = null;
         var specs:Array = null;
         var one:Object = null;
         var slot:Object = null;
         var votes:int = 0;
         var out:Object = {};
         var i:int = 0;
         var j:int = 0;
         var k:int = 0;
         while(i < order.length)
         {
            parts = String(order[i]) == TITLE ? null : mods[order[i]] as Array;
            j = 0;
            while(parts != null && j < parts.length)
            {
               specs = (parts[j] as Object).options as Array;
               k = 0;
               while(k < specs.length)
               {
                  one = specs[k];
                  if(ours(String(one.key)))
                  {
                     slot = out[one.key];
                     if(slot == null)
                     {
                        slot = {"mods":0,"alpha":false,"sample":one,"seen":{},
                                "best":String(one.value),"top":0};
                        out[one.key] = slot;
                     }
                     slot.mods++;
                     if(String(one.type) == Hub.ALPHA)
                     {
                        slot.alpha = true;
                     }
                     votes = int(slot.seen[one.value]) + 1;
                     slot.seen[one.value] = votes;
                     if(votes > int(slot.top))
                     {
                        slot.top = votes;
                        slot.best = String(one.value);
                     }
                  }
                  k++;
               }
               j++;
            }
            i++;
         }
         return out;
      }

      public static function queue(mods:Object, order:Array, key:String,
                                   value:String) : Array
      {
         var parts:Array = null;
         var specs:Array = null;
         var one:Object = null;
         var out:Array = [];
         var i:int = 0;
         var j:int = 0;
         var k:int = 0;
         while(i < order.length)
         {
            parts = String(order[i]) == TITLE ? null : mods[order[i]] as Array;
            j = 0;
            while(parts != null && j < parts.length)
            {
               specs = (parts[j] as Object).options as Array;
               k = 0;
               while(k < specs.length)
               {
                  one = specs[k];
                  if(one.key == key && String(one.value) != value)
                  {
                     out.push([String((parts[j] as Object).swf),key,value,
                               String(one.value),parts[j],one]);
                  }
                  k++;
               }
               j++;
            }
            i++;
         }
         return out;
      }

      public static function find(mods:Object, order:Array, swf:String,
                                  key:String) : Array
      {
         var parts:Array = null;
         var specs:Array = null;
         var i:int = 0;
         var j:int = 0;
         var k:int = 0;
         while(i < order.length)
         {
            parts = String(order[i]) == TITLE ? null : mods[order[i]] as Array;
            j = 0;
            while(parts != null && j < parts.length)
            {
               if(String((parts[j] as Object).swf) == swf)
               {
                  specs = (parts[j] as Object).options as Array;
                  k = 0;
                  while(k < specs.length)
                  {
                     if((specs[k] as Object).key == key)
                     {
                        return [parts[j],specs[k]];
                     }
                     k++;
                  }
               }
               j++;
            }
            i++;
         }
         return null;
      }

      public static function pack(jobs:Array) : String
      {
         var job:Array = null;
         var out:String = "";
         var i:int = 0;
         while(i < jobs.length)
         {
            job = jobs[i] as Array;
            out += (i > 0 ? "|" : "") + Hub.esc(String(job[0])) + "~"
                 + Hub.esc(String(job[3]));
            i++;
         }
         return out;
      }

      public static function unpack(line:String) : Array
      {
         var field:Array = null;
         var out:Array = [];
         var parts:Array = Hub.cut(line,"|");
         var i:int = 0;
         while(i < parts.length)
         {
            field = Hub.cut(String(parts[i]),"~");
            if(field.length >= 2)
            {
               out.push([String(field[0]),String(field[1])]);
            }
            i++;
         }
         return out;
      }
   }
}
