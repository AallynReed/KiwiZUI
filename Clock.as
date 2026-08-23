package
{
   /** The wall clock, and spans written in the game's own words.
    *
    *  Trove's day rolls over at **11:00 UTC**, so the game's internal clock is real UTC
    *  minus eleven hours - the "trove-time" frame. Everything scheduled in game is
    *  anchored in that frame; everything here takes and returns real UTC milliseconds
    *  and does the shift itself, so no caller has to remember which frame it is in.
    *
    *  **No constant in this class is a static.** A class static is set once, in
    *  declaration order, and a class whose initialiser calls out to Iggy can be left
    *  half-initialised - which showed up as a countdown of `0m` with a good clock going
    *  in, and cost a long hunt. Every number here is a local, and every translation is
    *  looked up when it is written rather than when the class loads. */
   public class Clock
   {

      public function Clock()
      {
         super();
      }

      /** The present, in UTC milliseconds, or NaN when the runtime will not give one.
       *
       *  Iggy is not Flash and has answered `new Date().time` with **NaN** rather than
       *  throwing. NaN carried through the arithmetic comes out of `shortSpan` as `0m`,
       *  a number that looks like an answer, so the reading is checked for being a time
       *  at all rather than merely for having thrown. A caller that gets NaN draws no
       *  countdowns; there is nothing else it can honestly do. */
      public static function now() : Number
      {
         var ms:Number = Number.NaN;
         try
         {
            ms = new Date().time;
         }
         catch(e:Error)
         {
            ms = Number.NaN;
         }
         return real(ms) ? ms : Number.NaN;
      }

      /** Anything before 2001 is not the present either. */
      public static function real(ms:Number) : Boolean
      {
         return !isNaN(ms) && ms > 1000000000000;
      }

      /** Real UTC to the frame the game schedules in. */
      public static function trove(utc:Number) : Number
      {
         return utc - 11 * 3600000;
      }

      /** Which weekday it is in game, Monday zero - the numbering `populateDailyBonus`
       *  sends. 1 January 1970 was a Thursday, so adding three makes this zero on a
       *  Monday. */
      public static function weekday(utc:Number) : int
      {
         var day:Number = 86400000;
         return (Math.floor(trove(utc) / day) + 3) % 7;
      }

      /** How long until the game's day rolls over. */
      public static function untilDailyReset(utc:Number) : Number
      {
         var day:Number = 86400000;
         var shifted:Number = trove(utc);
         return (Math.floor(shifted / day) + 1) * day - shifted;
      }

      /** The start of the trove-day `utc` falls in, as real UTC seconds - which is how
       *  a run of anything is recorded against a day. Seconds because that is the unit
       *  the schedules are anchored in; everything else here is milliseconds. */
      public static function dayStart(utc:Number) : Number
      {
         var day:Number = 86400000;
         return (Math.floor(trove(utc) / day) * day + 11 * 3600000) / 1000;
      }

      /** How long until the game's day rolls over on a given weekday, Monday zero. A
       *  reset that has already happened today is the one just gone, so landing on the
       *  day itself counts a full seven forward rather than to zero.
       *
       *  More than one thing in Trove turns over weekly and they do not all turn over on
       *  the same day, so the day is an argument rather than a second copy of this. */
      public static function untilReset(utc:Number, day:int) : Number
      {
         var span:Number = 86400000;
         var shifted:Number = trove(utc);
         var at:Number = Math.floor(shifted / span);
         var ahead:Number = (day + 7 - (at + 3) % 7) % 7;
         return (at + (ahead == 0 ? 7 : ahead)) * span - shifted;
      }

      /** The weekly reset, which is the Monday. */
      public static function untilWeeklyReset(utc:Number) : Number
      {
         return untilReset(utc,0);
      }

      /** A span in the game's own short units - "2d 04h" - down to whichever two are
       *  worth reading. The smaller of the pair is padded so a countdown does not change
       *  width as it runs down.
       *
       *  `seconds` opens the bottom of the scale, for a countdown a player watches run
       *  out rather than one they glance at. Off, anything under a minute reads "0m",
       *  which is what a screen with its own word for "now" wants under it. */
      public static function shortSpan(ms:Number, seconds:Boolean = false) : String
      {
         var day:Number = 86400000;
         var hour:Number = 3600000;
         var minute:Number = 60000;
         var left:Number = ms < 0 || isNaN(ms) ? 0 : ms;
         var days:int = Math.floor(left / day);
         var hours:int = Math.floor(left % day / hour);
         var mins:int = Math.floor(left % hour / minute);
         var secs:int = Math.floor(left % minute / 1000);
         if(days > 0)
         {
            return pairOf(days,"$TimeUnit_Days_short",hours,"$TimeUnit_Hours_short");
         }
         if(hours > 0)
         {
            return pairOf(hours,"$TimeUnit_Hours_short",mins,"$TimeUnit_Minutes_short");
         }
         if(!seconds)
         {
            return oneOf(mins,"$TimeUnit_Minutes_short");
         }
         if(mins > 0)
         {
            return pairOf(mins,"$TimeUnit_Minutes_short",secs,"$TimeUnit_Seconds_short");
         }
         return oneOf(secs,"$TimeUnit_Seconds_short");
      }

      /** The two largest units the duration reaches, joined the way the language file
       *  says to join them - vanilla's own `_kiwi.Util.TimeUtil.localizeTime`. The game
       *  ships `$Time_Localized1` and `$Time_Localized2` and nothing wider, which is why
       *  two units is the ceiling. `short` picks the abbreviated unit names.
       *
       *  Where shortSpan pads the smaller half so a countdown holds its width, this
       *  reads as a sentence does. A screen wants one or the other, never both. */
      public static function span(ms:Number, units:int = 2, short:Boolean = true) : String
      {
         var i:int = 0;
         var parts:Array = partsOf(ms,units,short);
         if(parts.length == 0)
         {
            parts.push({"value":"0","units":IggyFunctions.translate("$TimeUnit_Seconds_short")});
         }
         var joiner:String = IggyFunctions.translate(
            joinerKey(Math.min(units,parts.length),short));
         if(joiner == null || joiner.length == 0)
         {
            return plain(parts);
         }
         while(i < units && i < parts.length)
         {
            joiner = joiner.replace("{" + 2 * i + "}",parts[i].value);
            joiner = joiner.replace("{" + (2 * i + 1) + "}",parts[i].units);
            i++;
         }
         return joiner;
      }

      /** The game ships exactly these four joiners and nothing wider, so they are
       *  written out rather than built up: a key assembled from pieces is a key no
       *  verifier can find in the language files. */
      private static function joinerKey(count:int, short:Boolean) : String
      {
         if(count <= 1)
         {
            return short ? "$Time_Localized1_short" : "$Time_Localized1";
         }
         return short ? "$Time_Localized2_short" : "$Time_Localized2";
      }

      /** The hour of the day a schedule names, as the game writes one. */
      public static function hour(h:int, m:int) : String
      {
         var whole:int = h > 12 ? h - 12 : h;
         return whole + ":" + (m < 10 ? "0" + m : String(m));
      }

      /** The game's own units, largest first, in milliseconds. Built when it is asked
       *  for rather than kept as a static, the same as every other constant here. */
      private static function units() : Array
      {
         return [{"key":"$TimeUnit_Years",   "ms":31536000000},
                 {"key":"$TimeUnit_Months",  "ms":2628000000},
                 {"key":"$TimeUnit_Days",    "ms":86400000},
                 {"key":"$TimeUnit_Hours",   "ms":3600000},
                 {"key":"$TimeUnit_Minutes", "ms":60000},
                 {"key":"$TimeUnit_Seconds", "ms":1000}];
      }

      private static function plain(parts:Array) : String
      {
         var out:String = "";
         var i:int = 0;
         while(i < parts.length)
         {
            out += (i > 0 ? " " : "") + parts[i].value + parts[i].units;
            i++;
         }
         return out;
      }

      /** The largest units a duration reaches, as {value, units} pairs already in the
       *  game's own words - for a screen that has a sentence of its own to put them in
       *  rather than the language file's joiner.
       *
       *  Empty when the duration does not reach even a second, so a caller can say
       *  nothing rather than say zero.
       *
       *  Vanilla rounds when it is asked for one unit and floors when it is asked for
       *  two, which is the difference between "about an hour" and "an hour and a bit". */
      public static function partsOf(ms:Number, count:int = 2, short:Boolean = true) : Array
      {
         var size:Number = NaN;
         var key:String = null;
         var value:Number = NaN;
         var table:Array = units();
         var left:Number = Math.abs(ms);
         var out:Array = [];
         var i:int = 0;
         while(i < table.length && out.length < count)
         {
            size = Number(table[i].ms);
            if(left > size)
            {
               value = count == 1 ? Math.round(left / size) : Math.floor(left / size);
               key = String(table[i].key) + (short ? "_short" : value == 1 ? "_single" : "");
               out.push({"value":String(value),"units":IggyFunctions.translate(key)});
            }
            if(left != size)
            {
               left %= size;
            }
            i++;
         }
         return out;
      }

      /** The game's own template where it resolves, and the same shape written out
       *  where it does not. A template is a nicety; the number is the point. */
      private static function pairOf(big:int, bigKey:String, small:int, smallKey:String) : String
      {
         var pad:String = (small < 10 ? "0" : "") + small;
         var one:String = IggyFunctions.translate(bigKey);
         var two:String = IggyFunctions.translate(smallKey);
         var shape:String = IggyFunctions.translate("$Time_Localized2_short");
         if(shape == null || shape.indexOf("{0}") == -1)
         {
            return big + one + " " + pad + two;
         }
         return shape.replace("{0}",String(big)).replace("{1}",one)
                     .replace("{2}",pad).replace("{3}",two);
      }

      private static function oneOf(value:int, key:String) : String
      {
         var unit:String = IggyFunctions.translate(key);
         var shape:String = IggyFunctions.translate("$Time_Localized1_short");
         if(shape == null || shape.indexOf("{0}") == -1)
         {
            return value + unit;
         }
         return shape.replace("{0}",String(value)).replace("{1}",unit);
      }
   }
}
