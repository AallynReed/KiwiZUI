package
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import flash.utils.getTimer;

   /** The declaring half of the settings hub: what a mod says about itself so that one
    *  screen can offer every mod's options in one place.
    *
    *  It works because OnSaveConfig is addressed by SWF and not by caller. A write
    *  naming a section lands in the .cfg of whichever mod packs that SWF, so writing
    *  to ADDRESS puts a value in the hub's file, where the hub reads it back through
    *  its own loadModConfiguration. That is the only channel between two mods there
    *  is - nothing can ask for a section that is not its own.
    *
    *  One key per mod, never one per setting. Every option a mod has goes in a single
    *  value, so adding a settings page costs one config write rather than twenty:
    *  OnSaveConfig is a record and a screen that traces through it dies on load.
    *
    *      1|<swf>|<Mod Title>|key~type~label~value~params|key~type~...
    *
    *  Values are the same literals the config file carries, so a value set in the hub
    *  and a value set by hand in the file cannot come to mean different things, and
    *  the hub can hand one straight back with no conversion in between.
    *
    *  Publishing waits a beat for the same reason seeding does: ExternalInterface.call
    *  goes nowhere until Iggy has wired the bridge, silently, and a declaration made
    *  from a constructor is simply lost. Paced on ENTER_FRAME rather than a Timer,
    *  because callbacks can arrive before the first frame tick.
    *
    *  It waits again afterwards. A setting the player changes is one write; recording
    *  it here is a second, and Trove rewrites the whole file for either - so the record
    *  trails the changing rather than following each step of it. */
   public class Hub
   {

      public static const ADDRESS:String = "likedworlds.swf";

      public static const VERSION:String = "3";

      /** Prefix on the key a declaration is written under, so the hub can tell one from
       *  its own settings sharing the section, and so a stale mod can be recognised. */
      public static const MARK:String = "zm_";

      public static const CHECK:String = "check";

      public static const SLIDER:String = "slider";

      public static const SPIN:String = "spin";

      public static const COMBO:String = "combo";

      public static const COLOR:String = "color";

      public static const ALPHA:String = "alpha";

      public static const INPUT:String = "input";

      public static const STEPPER:String = "stepper";

      public static const HEADING:String = "heading";

      private static const SETTLE:int = 2000;

      /** How long the record waits after the last change before it is written.
       *
       *  Trove rewrites the whole .cfg for one key, and the hub's file is every mod's
       *  declarations - so the write that records a change costs more than the write
       *  that makes it, and doing both on the click is what makes a setting take the
       *  game away for a moment. One is all the player asked for; the record follows
       *  once the changing has stopped. */
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

      /** A change is waiting to be recorded. */
      private var dirty:Boolean = false;

      /** Until the first declaration has gone out, nothing is written. Config arrives
       *  one key at a time and a screen that republished on each of them would spend
       *  the whole of its load writing - the same spam that kills a screen when it is
       *  aimed at its own section, aimed at someone else's. */
      private var armed:Boolean = false;

      /** group names the screen these settings belong to. A mod with more than one
       *  screen declares once per screen, and the hub shows one entry for the mod with
       *  a foldable category per screen - so the name has to be the screen's, in words,
       *  and not the SWF's filename. Left out, the filename is what is left to use. */
      public function Hub(section:String, title:String, valueOf:Function, group:String = "")
      {
         super();
         this.section = section;
         this.title = title;
         this.reader = valueOf;
         this.band = group;
      }

      /** What this mod is and how it is meant to be used, in the author's own words.
       *  Shown in place of the controls when the reader asks for it, so a mod with
       *  something to explain has somewhere to explain it that is not a settings row
       *  and not a page on a website nobody opens.
       *
       *  Line breaks survive the config file: a real newline would end the value and
       *  take the rest of the readme with it, so they travel escaped. */
      public function readme(text:String) : Hub
      {
         this.about = text;
         return this;
      }

      /** One row in the hub, in the order they are added. params is the type's own
       *  extra: min,max,step,places,zero,suffix for anything numeric, a value=Label
       *  list for a dropdown, nothing at all for a flag. Neither a zero-word nor a
       *  suffix may carry a comma, which is the one thing the range list cannot spell.
       *
       *  note is what the setting is for and what it wants to be set to, in the mod
       *  author's own words. A label has to fit a lane and so says what a setting is
       *  called; this is the room to say what it does, and it is the only place a
       *  player reading someone else's option can find that out. */
      public function option(key:String, type:String, label:String, params:String = "",
                             note:String = "") : Hub
      {
         this.options.push([key,type,label,params,note]);
         return this;
      }

      /** The key a declaration is written under. It carries the SWF as well as the
       *  mod, because a mod with two screens declares twice and a key naming only the
       *  mod would have the second statement land on top of the first - one screen's
       *  settings silently replacing the other's. */
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

      /** Arms the beat that publishes, once, from the screen that owns the settings. */
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

      /** The beat stays on the screen rather than coming off at the first write: it is
       *  what carries a change to the file once the player has stopped making them. */
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
      }

      /** Called whenever a setting changes, so the hub shows what the screen is
       *  actually running with. It marks rather than writes, and the beat writes QUIET
       *  after the last change - so a click is one config write, the setting itself,
       *  and a run of them is still one record at the end of it.
       *
       *  The wait is only ever pushed back once the first declaration has gone out.
       *  Config arrives one key at a time and each arrival publishes, so before that
       *  it would walk the arming beat forward key by key and declare early - into a
       *  bridge Iggy has not wired yet, where the call goes nowhere. */
      public function publish() : void
      {
         this.dirty = true;
         if(this.armed)
         {
            this.due = getTimer() + QUIET;
         }
      }

      /** Silent when nothing moved: a record that says what the last one said is a
       *  config write for no news. */
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

      /** A value set in the hub, addressed to the mod that declared it. The same call
       *  every mod makes for its own settings, aimed at someone else's section - which
       *  is the whole of what makes one screen able to set another mod's options. */
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

      /** The separators have to survive a label that contains one. Backslash first, or
       *  unescaping would turn an escaped backslash back into an escape. */
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

      /** The reading half. A hub sees every key in its own section, its own settings
       *  among them, so a declaration has to be recognised rather than assumed: ours
       *  by its prefix and its version, a legacy one by the shape of its value.
       *
       *  Returns {swf, title, options:[{key,type,label,value,params}]}, or null for a
       *  key that is not a declaration at all. A mod that has been uninstalled leaves
       *  its key behind - there is nothing to clear it - so the hub is told what the
       *  declaration says and decides for itself what to do with a stale one. */
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

      /** Version 1 had no group, so its options start one field earlier. Both are read
       *  rather than only the current one: a declaration is written by another mod and
       *  goes stale in this file until that mod next runs, so a hub that understood
       *  only the newest format would drop every mod that had not been rebuilt. */
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

      /** A group left unnamed falls back to the SWF it came from, which is a filename
       *  and reads like one. Title casing it is the least that makes it a word. */
      private static function named(text:String) : String
      {
         return text.length == 0 ? "" : text.charAt(0).toUpperCase() + text.substring(1);
      }

      /** One record shape whichever format it arrived in, so the hub builds a row from
       *  a declaration without asking where it came from. The type's extra is parsed
       *  here and never again. */
      private static function shaped(field:Array) : Object
      {
         var range:Array = null;
         var type:String = String(field[1]);
         var params:String = field.length > 4 ? String(field[4]) : "";
         var out:Object = {"key":field[0],"type":type,"label":field[2],"value":field[3],
                           "note":field.length > 5 ? field[5] : "","emit":"","choices":[],
                           "min":0,"max":100,"step":1,"places":0,"zero":"","suffix":"",
                           "len":0};
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
         return out;
      }

      /** value=Label, comma separated. A label is free text, so only the first equals
       *  splits a pair and a choice with no equals stands for itself. */
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

      /** Splitting on a separator that may have been escaped. String.split cannot do
       *  it, so the scan is by hand and each field is unescaped once it is whole. */
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
