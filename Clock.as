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
       *  width as it runs down. */
      public static function shortSpan(ms:Number) : String
      {
         var day:Number = 86400000;
         var hour:Number = 3600000;
         var minute:Number = 60000;
         var left:Number = ms < 0 || isNaN(ms) ? 0 : ms;
         var days:int = Math.floor(left / day);
         var hours:int = Math.floor(left % day / hour);
         var mins:int = Math.floor(left % hour / minute);
         if(days > 0)
         {
            return pairOf(days,"$TimeUnit_Days_short",hours,"$TimeUnit_Hours_short");
         }
         if(hours > 0)
         {
            return pairOf(hours,"$TimeUnit_Hours_short",mins,"$TimeUnit_Minutes_short");
         }
         return oneOf(mins,"$TimeUnit_Minutes_short");
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
