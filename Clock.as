package
{
   public class Clock
   {

      public function Clock()
      {
         super();
      }

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

      public static function real(ms:Number) : Boolean
      {
         return !isNaN(ms) && ms > 1000000000000;
      }

      public static function trove(utc:Number) : Number
      {
         return utc - 11 * 3600000;
      }

      public static function weekday(utc:Number) : int
      {
         var day:Number = 86400000;
         return (Math.floor(trove(utc) / day) + 3) % 7;
      }

      public static function untilDailyReset(utc:Number) : Number
      {
         var day:Number = 86400000;
         var shifted:Number = trove(utc);
         return (Math.floor(shifted / day) + 1) * day - shifted;
      }

      public static function dayStart(utc:Number) : Number
      {
         var day:Number = 86400000;
         return (Math.floor(trove(utc) / day) * day + 11 * 3600000) / 1000;
      }

      public static function untilReset(utc:Number, day:int) : Number
      {
         var span:Number = 86400000;
         var shifted:Number = trove(utc);
         var at:Number = Math.floor(shifted / span);
         var ahead:Number = (day + 7 - (at + 3) % 7) % 7;
         return (at + (ahead == 0 ? 7 : ahead)) * span - shifted;
      }

      public static function untilWeeklyReset(utc:Number) : Number
      {
         return untilReset(utc,0);
      }

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

      private static function joinerKey(count:int, short:Boolean) : String
      {
         if(count <= 1)
         {
            return short ? "$Time_Localized1_short" : "$Time_Localized1";
         }
         return short ? "$Time_Localized2_short" : "$Time_Localized2";
      }

      public static function wall(twelve:Boolean = false, shift:Number = 0) : String
      {
         var when:Date = null;
         var ms:Number = NaN;
         try
         {
            when = new Date();
         }
         catch(e:Error)
         {
            return "";
         }
         if(when == null || !real(when.time))
         {
            return "";
         }
         ms = when.time + (shift == 0 ? localOffset(when) : shift * 3600000);
         return face(ms,twelve);
      }

      public static function serverWall(twelve:Boolean = false) : String
      {
         var ms:Number = now();
         return real(ms) ? face(trove(ms),twelve) : "";
      }

      private static function face(ms:Number, twelve:Boolean) : String
      {
         var mins:int = Math.floor(ms / 60000) % 1440;
         var h:int = 0;
         if(mins < 0)
         {
            mins += 1440;
         }
         h = mins / 60;
         if(!twelve)
         {
            return pad(h) + ":" + pad(mins % 60);
         }
         return String(h % 12 == 0 ? 12 : h % 12) + ":" + pad(mins % 60)
              + (h < 12 ? " AM" : " PM");
      }

      public static function localOffset(when:Date) : Number
      {
         var made:Date = null;
         var offset:Number = Number.NaN;
         try
         {
            made = new Date(when.fullYearUTC,when.monthUTC,when.dateUTC,12,0,0);
            offset = Date.UTC(when.fullYearUTC,when.monthUTC,when.dateUTC,12,0,0)
                   - made.time;
         }
         catch(e:Error)
         {
            offset = Number.NaN;
         }
         if(!isNaN(offset) && offset != 0)
         {
            return offset;
         }
         offset = -Number(when.timezoneOffset) * 60000;
         return isNaN(offset) ? 0 : offset;
      }

      private static function pad(value:int) : String
      {
         return value < 10 ? "0" + value : String(value);
      }

      public static function hour(h:int, m:int) : String
      {
         var whole:int = h > 12 ? h - 12 : h;
         return whole + ":" + (m < 10 ? "0" + m : String(m));
      }

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
