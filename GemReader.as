package
{
   /** Reads a gem back out of what is on screen: how many boosts sit on each stat,
    *  how far each roll got through its band, and one overall grade.
    *
    *  Two ways in, because the two screens know different things. The gem screen is
    *  handed the numbers outright and calls observe(); the tooltip only has its own
    *  rows and calls readRow() for each, which picks the same three facts out of the
    *  translated text. Stats arrive through take() either way.
    *
    *  Power Rank is required. It is an integer the game prints outright and it is
    *  linear in the rolls, so it both settles which boost layout is real and gives
    *  the exact quality - the printed stats are rounded and can do neither. */
   public class GemReader
   {

      private static const GAIN:Array = [3,5,7,9];

      private static const CAP_LEVEL:Array = [23,25,30,35];

      private static const PR_BANDS:Array = [[[85,113],[113,150]],[[150,200],[200,266]],
                                             [[175,250],[220,280]],[[200,260],[240,300]]];

      private static const STEPS:int = 40;

      private static const MODEL_SLACK_MIN:Number = 15;

      private static const MODEL_SLACK_REL:Number = 0.006;

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

      /** The ceiling: what the gem will have at level 15, not what it has now. A
       *  milestone either adds a missing stat or boosts one, so a gem short a stat
       *  has to spend one gaining it. Anything under 3 can never be maxed. */
      public function get attainable() : int
      {
         return total(boosts) + Math.max(0,columns.length - Math.min(3,int(_level / 5)));
      }

      public function boostsAt(i:int) : int
      {
         return int(boosts[i]);
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

      /** The tooltip has no numbers to hand, only its own rows. Level, Power Rank,
       *  rarity and the game's word for Empowered all arrive as translated text. */
      public function readRow(line:String) : void
      {
         var i:int = 0;
         warmHeads();
         if(levelHead.length > 0 && line.indexOf(levelHead) == 0)
         {
            _level = firstInt(line.substring(levelHead.length));
         }
         if(isGradeRow(line))
         {
            rank = firstInt(line.substring(gradeHead.length));
         }
         while(i < tierNames.length)
         {
            if(String(tierNames[i]).length > 0 && line == tierNames[i])
            {
               _tier = i;
            }
            i++;
         }
         if(chargedWord.length > 0 && line.indexOf(chargedWord) != -1)
         {
            hint = 1;
         }
      }

      public function isGradeRow(line:String) : Boolean
      {
         warmHeads();
         return gradeHead.length > 0 && line.indexOf(gradeHead) == 0;
      }

      public function take(name:String, value:String) : Boolean
      {
         var column:int = columnOf(name,value);
         var n:Number = number(value);
         if(column < 0 || isNaN(n) || n <= 0 || columns.length >= 3)
         {
            return false;
         }
         columns.push(column);
         printed.push(n);
         places.push(decimals(value));
         marks.push(value.indexOf("%") != -1);
         return true;
      }

      /** Every legal boost layout, on both sockets, checked against the Power Rank.
       *  A layout whose rolls fall outside their band is impossible; of the rest the
       *  one whose predicted rank lands nearest wins. A full reading beats a short
       *  one on a tie - a wrong "Bad Gem" could make someone scrap a good gem, so
       *  the guess never goes that way. The socket read off the tooltip is tried
       *  first, so it takes ties too. */
      public function solve() : Boolean
      {
         var socket:int = 0;
         var code:int = 0;
         var want:Array = null;
         var err:Number = 0;
         var bad:Boolean = false;
         var s:int = 0;
         var n:int = columns.length;
         var cap:int = 0;
         var span:int = 0;
         var reach:int = 0;
         var found:Boolean = false;
         var bestErr:Number = 0;
         var bestBad:Boolean = false;
         _solved = false;
         if(n < 2 || _level <= 0 || _tier < 0 || rank <= 0)
         {
            return false;
         }
         cap = Math.min(3,int(_level / 5));
         span = cap + 1;
         reach = span * span * span;
         while(s < 2)
         {
            socket = s == 0 ? hint : 1 - hint;
            code = 0;
            while(code < reach)
            {
               want = [code % span,int(code / span) % span,int(code / (span * span))];
               if(legal(want,cap,n) && measure(socket,want))
               {
                  err = fitErr;
                  bad = total(want) + Math.max(0,n - cap) < 3;
                  if(!found || (bad ? 1 : 0) < (bestBad ? 1 : 0) || (bad == bestBad && err < bestErr))
                  {
                     found = true;
                     bestErr = err;
                     bestBad = bad;
                     keep(socket,want);
                  }
               }
               code++;
            }
            s++;
         }
         if(!found)
         {
            return false;
         }
         snapRolls();
         _starved = attainable < 3;
         _quality = ranked();
         if(_quality < 0)
         {
            _quality = weighted();
         }
         _solved = true;
         return true;
      }

      private function legal(want:Array, cap:int, n:int) : Boolean
      {
         var i:int = n;
         if(total(want) > cap)
         {
            return false;
         }
         while(i < 3)
         {
            if(int(want[i]) != 0)
            {
               return false;
            }
            i++;
         }
         return true;
      }

      private function measure(socket:int, want:Array) : Boolean
      {
         var i:int = 0;
         var band:Array = null;
         var give:Number = 0;
         var roll:Number = 0;
         var bound:Number = 0.5 + Math.max(MODEL_SLACK_MIN,MODEL_SLACK_REL * rank);
         var guess:Number = 0;
         var table:Array = BANDS[_tier][socket] as Array;
         var pr:Array = PR_BANDS[_tier][socket] as Array;
         var prSpan:Number = Number(pr[1]) - Number(pr[0]);
         var raise:Number = lift(_level);
         var containers:int = 0;
         fitRolls = [];
         while(i < columns.length)
         {
            band = table[int(columns[i])] as Array;
            containers = int(want[i]) + 1;
            give = step(int(places[i])) / 2 / Number(band[0])
                 / ((Number(band[2]) - Number(band[1])) * containers);
            roll = ((Number(printed[i]) / Number(band[0]) - raise) / containers - Number(band[1]))
                 / (Number(band[2]) - Number(band[1]));
            if(roll < -give || roll > 1 + give)
            {
               return false;
            }
            roll = roll < 0 ? 0 : (roll > 1 ? 1 : roll);
            fitRolls.push(roll);
            bound += prSpan * containers * give;
            i++;
         }
         guess = (socket == 1 ? 100 : 0) + columns.length * raise;
         i = 0;
         while(i < columns.length)
         {
            guess += (Number(pr[0]) + prSpan * Number(fitRolls[i])) * (int(want[i]) + 1);
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

      /** A roll only ever moves one focus at a time, 2.5% of a container, so a stat
       *  with C containers sits on the 1/(40C) grid and nowhere else. The printed
       *  number is truncated, which throws away up to a whole print unit; snapping
       *  puts it back. Only where the printed value names exactly one grid point
       *  though - where two adjacent points truncate the same way, taking the nearer
       *  one is a guess, and it is wrong often enough to matter. */
      private function snapRolls() : void
      {
         var i:int = 0;
         var containers:int = 0;
         var steps:int = 0;
         var near:int = 0;
         var fits:int = 0;
         var pick:int = 0;
         var s:int = 0;
         while(i < columns.length)
         {
            containers = int(boosts[i]) + 1;
            steps = STEPS * containers;
            near = Math.round(Number(rolls[i]) * steps);
            near = near < 0 ? 0 : (near > steps ? steps : near);
            fits = 0;
            pick = -1;
            s = near - 1;
            while(s <= near + 1)
            {
               if(s >= 0 && s <= steps && agrees(i,containers,s / steps))
               {
                  fits++;
                  pick = s;
               }
               s++;
            }
            if(fits == 1 && pick == near)
            {
               rolls[i] = near / steps;
            }
            i++;
         }
      }

      private function agrees(i:int, containers:int, roll:Number) : Boolean
      {
         var band:Array = BANDS[_tier][_socket][int(columns[i])] as Array;
         var span:Number = Number(band[2]) - Number(band[1]);
         var value:Number = (Number(band[1]) * containers + lift(_level) + roll * span * containers) * Number(band[0]);
         var unit:Number = step(int(places[i]));
         return Math.abs(Math.floor(value / unit + 1e-9) * unit - Number(printed[i])) < unit * 0.5;
      }

      /** Where the rank sits between the least and the most a gem of this tier,
       *  socket, level and container count can reach is the weighted quality
       *  exactly. -1 when the rank falls outside that band, which means the layout
       *  is wrong and the stats are the better answer.
       *
       *  The level gain accrues once per stat the gem actually has, not three
       *  times - the two only look the same on a gem with all three. */
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

      private static function decimals(raw:String) : int
      {
         var body:String = raw.split(",").join("").split("%").join("").split("+").join("").split(" ").join("");
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

      private static function number(raw:String) : Number
      {
         return Number(raw.split(",").join("").split("%").join("").split("+").join("").split(" ").join(""));
      }
   }
}
