package
{
   public class GemReader
   {

      public static const DAMAGE:int = 0;

      public static const CRIT:int = 1;

      public static const LIGHT:int = 5;

      private static const GAIN:Array = [3,5,7,9];

      private static const CAP_LEVEL:Array = [23,25,30,35];

      private static const PR_BANDS:Array = [[[85,113],[113,150]],[[150,200],[200,266]],
                                             [[175,250],[220,280]],[[200,260],[240,300]]];

      private static const MODEL_SLACK_MIN:Number = 15;

      private static const MODEL_SLACK_REL:Number = 0.006;

      private static const EDGE:Number = 1e-9;

      private static const BANDS:Array = [
         [[[14,85,113],[0.2,85,113],[0.02,85,113],[0.5,85,113],[50,85,113],[1,85,113]],
          [[14,113,150],[0.2,113,150],[0.02,113,150],[0.5,113,150],[50,113,150],[1,113,150]]],
         [[[14,150,200],[0.2,150,200],[0.02,150,200],[0.5,150,200],[50,150,200],[1,150,200]],
          [[14,200,266],[0.2,200,266],[0.02,200,266],[0.5,200,266],[50,200,266],[1,200,266]]],
         [[[16,210,280],[3 / 14,560 / 3,770 / 3],[0.3 / 14,560 / 3,770 / 3],[0.5,245,315],[50,245,315],[5 / 7,280,385]],
          [[16,245,350],[3 / 14,700 / 3,910 / 3],[0.3 / 14,700 / 3,910 / 3],[0.5,315,385],[50,315,385],[5 / 7,350,420]]],
         [[[168 / 9,270,360],[2.5 / 9,187.2,297],[0.25 / 9,187.2,297],[5.25 / 9,315,405],[525 / 9,315,405],[5 / 9,495,585]],
          [[28,210,300],[2.5 / 9,252,342],[0.25 / 9,252,342],[5.25 / 9,405,495],[525 / 9,405,495],[5 / 9,495,630]]]
      ];

      private static var labels:Array = null;

      private static var tierNames:Array = null;

      private static var levelHead:String = null;

      private static var gradeHead:String = null;

      private static var chargedWord:String = null;

      private var _tier:int = -1;

      private var _level:int = 0;

      private var _socket:int = 0;

      private var hint:int = 0;

      private var rank:int = 0;

      private var columns:Array = [];

      private var printed:Array = [];

      private var places:Array = [];

      private var marks:Array = [];

      private var boosts:Array = [];

      private var rolls:Array = [];

      private var fitErr:Number = 0;

      private var prLow:Number = 0;

      private var prSpan:Number = 0;

      private var raise:Number = 0;

      private var base:Number = 0;

      private var slack:Number = 0;

      private var low:Array = [];

      private var wide:Array = [];

      private var giveNum:Array = [];

      private var lead:Array = [];

      private var fitRolls:Array = [];

      private var _solved:Boolean = false;

      private var _starved:Boolean = false;

      private var _quality:Number = 0;

      public function GemReader()
      {
         super();
      }

      public function reset() : void
      {
         _tier = -1;
         _level = 0;
         _socket = 0;
         hint = 0;
         rank = 0;
         columns = [];
         printed = [];
         places = [];
         marks = [];
         boosts = [];
         rolls = [];
         _solved = false;
         _starved = false;
         _quality = 0;
      }

      public function get tier() : int
      {
         return _tier;
      }

      public function get level() : int
      {
         return _level;
      }

      public function get solved() : Boolean
      {
         return _solved;
      }

      public function get starved() : Boolean
      {
         return _starved;
      }

      public function get quality() : Number
      {
         return _quality;
      }

      public function get isGem() : Boolean
      {
         return _level > 0 || _tier >= 0;
      }

      public function get statCount() : int
      {
         return columns.length;
      }

      public function get settled() : Boolean
      {
         return _level >= 15;
      }

      public function get maxLevel() : int
      {
         return _tier < 0 ? 0 : int(CAP_LEVEL[_tier]);
      }

      public function get attainable() : int
      {
         return total(boosts) + Math.max(0,columns.length - Math.min(3,int(_level / 5)));
      }

      public function boostsAt(i:int) : int
      {
         return int(boosts[i]);
      }

      public function columnAt(i:int) : int
      {
         return int(columns[i]);
      }

      public function percentAt(i:int) : String
      {
         return Math.round(Number(rolls[i]) * 100) + "%";
      }

      public function projectAt(i:int) : String
      {
         var band:Array = BANDS[_tier][_socket][int(columns[i])] as Array;
         var scaled:Number = Number(band[1]) + (Number(band[2]) - Number(band[1])) * Number(rolls[i]);
         var value:Number = Number(band[0]) * (scaled * (int(boosts[i]) + 1) + lift(maxLevel));
         var digits:int = int(places[i]);
         var body:String = digits > 0 ? value.toFixed(digits) : grouped(Math.round(value));
         return marks[i] == true ? body + "%" : body;
      }

      public function observe(level:int, powerRank:int, rarity:int) : void
      {
         _level = level;
         rank = powerRank;
         _tier = tierOf(rarity);
      }

      public function readRow(line:String) : Boolean
      {
         var i:int = 0;
         warmHeads();
         if(starts(line,levelHead))
         {
            _level = firstInt(line.substring(levelHead.length));
         }
         while(i < tierNames.length)
         {
            if(String(tierNames[i]).length > 0 && line == tierNames[i])
            {
               _tier = i;
            }
            i++;
         }
         if(isGem && chargedWord.length > 0 && line.indexOf(chargedWord) != -1)
         {
            hint = 1;
         }
         if(!starts(line,gradeHead))
         {
            return false;
         }
         rank = firstInt(line.substring(gradeHead.length));
         return true;
      }

      private static function starts(line:String, head:String) : Boolean
      {
         return head.length > 0 && line.lastIndexOf(head,0) == 0;
      }

      public function take(name:String, value:String) : Boolean
      {
         var column:int = 0;
         var body:String = null;
         var n:Number = 0;
         if(columns.length >= 3)
         {
            return false;
         }
         column = columnOf(name,value);
         if(column < 0)
         {
            return false;
         }
         body = bare(value);
         n = Number(body);
         if(isNaN(n) || n <= 0)
         {
            return false;
         }
         columns.push(column);
         printed.push(n);
         places.push(decimals(body));
         marks.push(value.indexOf("%") != -1);
         return true;
      }

      public function solve() : Boolean
      {
         var socket:int = 0;
         var want:Array = [0,0,0];
         var err:Number = 0;
         var bad:Boolean = false;
         var s:int = 0;
         var n:int = columns.length;
         var cap:int = 0;
         var short:int = 0;
         var top:int = 0;
         var a:int = 0;
         var b:int = 0;
         var c:int = 0;
         var found:Boolean = false;
         var bestErr:Number = 0;
         var bestBad:Boolean = false;
         _solved = false;
         if(n < 2 || _level <= 0 || _tier < 0 || rank <= 0)
         {
            return false;
         }
         cap = Math.min(3,int(_level / 5));
         short = Math.max(0,n - cap);
         top = n >= 3 ? cap : 0;
         while(s < 2)
         {
            socket = s == 0 ? hint : 1 - hint;
            this.prepare(socket);
            c = 0;
            while(c <= top)
            {
               b = 0;
               while(b + c <= cap)
               {
                  a = 0;
                  while(a + b + c <= cap)
                  {
                     want[0] = a;
                     want[1] = b;
                     want[2] = c;
                     if(measure(want))
                     {
                        err = fitErr;
                        bad = a + b + c + short < 3;
                        if(!found || (bad ? 1 : 0) < (bestBad ? 1 : 0) || (bad == bestBad && err < bestErr))
                        {
                           found = true;
                           bestErr = err;
                           bestBad = bad;
                           keep(socket,want);
                        }
                     }
                     a++;
                  }
                  b++;
               }
               c++;
            }
            s++;
         }
         if(!found)
         {
            return false;
         }
         refineRolls();
         _starved = attainable < 3;
         _quality = ranked();
         if(_quality < 0)
         {
            _quality = weighted();
         }
         _solved = true;
         return true;
      }

      private function prepare(socket:int) : void
      {
         var i:int = 0;
         var band:Array = null;
         var table:Array = BANDS[_tier][socket] as Array;
         var pr:Array = PR_BANDS[_tier][socket] as Array;
         prLow = Number(pr[0]);
         prSpan = Number(pr[1]) - prLow;
         raise = lift(_level);
         base = (socket == 1 ? 100 : 0) + columns.length * raise;
         slack = 0.5 + Math.max(MODEL_SLACK_MIN,MODEL_SLACK_REL * rank);
         low.length = 0;
         wide.length = 0;
         giveNum.length = 0;
         lead.length = 0;
         while(i < columns.length)
         {
            band = table[int(columns[i])] as Array;
            low.push(Number(band[1]));
            wide.push(Number(band[2]) - Number(band[1]));
            giveNum.push(step(int(places[i])) / 2 / Number(band[0]));
            lead.push(Number(printed[i]) / Number(band[0]) - raise);
            i++;
         }
      }

      private function measure(want:Array) : Boolean
      {
         var i:int = 0;
         var give:Number = 0;
         var roll:Number = 0;
         var bound:Number = slack;
         var guess:Number = base;
         var containers:int = 0;
         var n:int = columns.length;
         fitRolls.length = 0;
         while(i < n)
         {
            containers = int(want[i]) + 1;
            give = Number(giveNum[i]) / (Number(wide[i]) * containers);
            roll = (Number(lead[i]) / containers - Number(low[i])) / Number(wide[i]);
            if(roll < -2 * give - EDGE || roll > 1 + give + EDGE)
            {
               return false;
            }
            roll = roll < 0 ? 0 : (roll > 1 ? 1 : roll);
            fitRolls.push(roll);
            bound += prSpan * containers * give;
            guess += (prLow + prSpan * (roll + give)) * containers;
            i++;
         }
         fitErr = Math.abs(guess - rank);
         return fitErr <= bound;
      }

      private function keep(socket:int, want:Array) : void
      {
         var i:int = 0;
         _socket = socket;
         boosts = [];
         rolls = [];
         while(i < columns.length)
         {
            boosts.push(int(want[i]));
            rolls.push(Number(fitRolls[i]));
            i++;
         }
      }

      private function refineRolls() : void
      {
         var i:int = 0;
         var containers:int = 0;
         var count:int = total(boosts) + columns.length;
         var room:Array = [];
         var head:Number = 0;
         var want:Number = 0;
         var share:Number = 0;
         var lowRank:Number = 0;
         var highRank:Number = 0;
         prepare(_socket);
         lowRank = Math.round(prLow * count + base);
         highRank = Math.round((prLow + prSpan) * count + base);
         while(i < columns.length)
         {
            containers = int(boosts[i]) + 1;
            room.push(Math.min(1,Number(rolls[i])
               + 2 * Number(giveNum[i]) / (Number(wide[i]) * containers)) - Number(rolls[i]));
            head += Number(room[i]) * containers;
            want -= Number(rolls[i]) * containers;
            i++;
         }
         if(highRank <= lowRank || head <= 0)
         {
            return;
         }
         want += (rank - lowRank) / (highRank - lowRank) * count;
         share = want / head;
         share = share < 0 ? 0 : (share > 1 ? 1 : share);
         i = 0;
         while(i < columns.length)
         {
            rolls[i] = Number(rolls[i]) + share * Number(room[i]);
            i++;
         }
      }

      private function ranked() : Number
      {
         var band:Array = PR_BANDS[_tier][_socket] as Array;
         var containers:int = total(boosts) + columns.length;
         var base:Number = columns.length * lift(_level) + (_socket == 1 ? 100 : 0);
         var low:Number = Math.round(Number(band[0]) * containers + base);
         var high:Number = Math.round(Number(band[1]) * containers + base);
         if(high <= low || rank < low || rank > high)
         {
            return -1;
         }
         return (rank - low) / (high - low);
      }

      private function weighted() : Number
      {
         var i:int = 0;
         var sum:Number = 0;
         var weight:Number = 0;
         var containers:Number = 0;
         while(i < rolls.length)
         {
            containers = int(boosts[i]) + 1;
            sum += Number(rolls[i]) * containers;
            weight += containers;
            i++;
         }
         return weight > 0 ? sum / weight : 0;
      }

      private function lift(lvl:int) : Number
      {
         var gain:Number = Number(GAIN[_tier]);
         var milestones:int = 0;
         var late:int = 0;
         if(lvl <= 1)
         {
            return 0;
         }
         milestones = Math.min(int(lvl / 5),3);
         late = Math.max(int(lvl / 5) - milestones,0);
         return gain * (Math.min(lvl,15) - milestones - 1)
              + gain * 5 * late
              + gain * 2 * (Math.max(lvl - 15,0) - late);
      }

      public static function tierOf(rarity:int) : int
      {
         if(rarity >= 27 && rarity <= 31)
         {
            return 3;
         }
         if(rarity >= 22 && rarity <= 26)
         {
            return 2;
         }
         if(rarity >= 12 && rarity <= 21)
         {
            return rarity % 2 == 0 ? 0 : 1;
         }
         return -1;
      }

      private static function warmHeads() : void
      {
         if(levelHead != null)
         {
            return;
         }
         levelHead = head("$GemLevel");
         gradeHead = head("$NoRarityPowerRank");
         chargedWord = trim(text("$GemTooltip_ChargedTitle"));
         tierNames = [text("$Rarity_Radiant"),text("$Rarity_Stellar"),
                      text("$Rarity_Crystal"),text("$Rarity_Mystic")];
      }

      private static function bare(raw:String) : String
      {
         return raw.split(",").join("").split("%").join("").split("+").join("").split(" ").join("");
      }

      private static function decimals(body:String) : int
      {
         var dot:int = body.indexOf(".");
         return dot < 0 ? 0 : body.length - dot - 1;
      }

      private static function step(digits:int) : Number
      {
         var s:Number = 1;
         var n:int = digits;
         while(n > 0)
         {
            s = s / 10;
            n--;
         }
         return s;
      }

      private static function total(list:Array) : int
      {
         var i:int = 0;
         var sum:int = 0;
         while(i < list.length)
         {
            sum += int(list[i]);
            i++;
         }
         return sum;
      }

      private static function grouped(value:int) : String
      {
         var s:String = String(value);
         var out:String = "";
         var i:int = s.length;
         while(i > 3)
         {
            out = "," + s.substring(i - 3,i) + out;
            i -= 3;
         }
         return s.substring(0,i) + out;
      }

      private static function columnOf(name:String, value:String) : int
      {
         var i:int = 0;
         if(labels == null)
         {
            labels = [text("$Stat_PhysicalDamage"),text("$Stat_SpellDamage"),
                      text("$Stat_CriticalHitDamage"),text("$Stat_CriticalHitChance"),
                      text("$Stat_MaxHealth"),text("$Stat_Light")];
         }
         while(i < labels.length)
         {
            if(String(labels[i]).length > 0 && name.indexOf(labels[i]) != -1)
            {
               if(i <= 1)
               {
                  return 0;
               }
               if(i == 2)
               {
                  return 1;
               }
               if(i == 3)
               {
                  return 2;
               }
               if(i == 4)
               {
                  return value.indexOf("%") != -1 ? 3 : 4;
               }
               return 5;
            }
            i++;
         }
         return -1;
      }

      private static function text(key:String) : String
      {
         var s:* = IggyFunctions.translate(key);
         return s == null ? "" : String(s);
      }

      private static function head(key:String) : String
      {
         var s:String = text(key);
         var brace:int = s.indexOf("{");
         return brace > 0 ? s.substring(0,brace) : "";
      }

      private static function trim(s:String) : String
      {
         var a:int = 0;
         var b:int = s.length;
         while(a < b && s.charAt(a) == " ")
         {
            a++;
         }
         while(b > a && s.charAt(b - 1) == " ")
         {
            b--;
         }
         return s.substring(a,b);
      }

      private static function firstInt(s:String) : int
      {
         var i:int = 0;
         var digits:String = "";
         var c:String = null;
         while(i < s.length)
         {
            c = s.charAt(i);
            if(c >= "0" && c <= "9")
            {
               digits += c;
            }
            else if(digits.length > 0)
            {
               break;
            }
            i++;
         }
         return digits.length > 0 ? int(digits) : 0;
      }

   }
}
