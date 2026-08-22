package
{
   /** Trove's deterministic cycles: the ones that can be worked out from a clock alone,
    *  with no server behind them.
    *
    *  Ported from `TroveAPI/app/trove/server_time.py`, `rotations.py` and `luxion.py`,
    *  which are themselves BetterTroveTools' arithmetic. The anchors and the lists are
    *  copied verbatim so the indices line up; `verify_rotations.py` fuzzes this class
    *  against the Python at several thousand moments spread over years, because a cycle
    *  that is a phase out is wrong in a way that reads entirely plausible.
    *
    *  Two frames are in play and mixing them is the whole failure mode. The merchant and
    *  buff anchors are in **trove time** (real UTC minus eleven hours), which is the
    *  frame the game schedules in; the biome and Luxion anchors are in **real UTC**
    *  because that is how they were captured. Each function says which it uses.
    *  Everything in and out of this class is real UTC milliseconds.
    *
    *  Every answer has the same shape, so a caller draws one row per cycle rather than a
    *  case per cycle:
    *
    *      on    is it happening right now
    *      ms    to the boundary - the end when it is on, the start when it is not
    *      keys  translation keys for whatever the cycle is currently carrying
    *
    *  **No number in this class is a class constant.** A class static is set once, in
    *  declaration order, and a derived one - `WEEK = 7 * DAY` - reads whatever the static
    *  it was built from held at that moment. Leaderboards lost a long hunt to exactly
    *  this: every test passed, and in game the countdowns read `0m`, which is what
    *  `Clock.shortSpan` returns for a NaN that looks for all the world like an answer.
    *  Moving its constants into locals fixed it. So every span here is written out where
    *  it is used, and the only statics are the tables, which are literal and depend on
    *  nothing.
    *
    *  What is *not* here: the d15 three-hour biome rotation, because eight of its thirty
    *  sub-biomes ship no translation key and a screen does not invent names; gardening,
    *  for the same reason - the windows are exact and the words for them are not the
    *  game's; and invasions, which are out of scope across this project. */
   public class Rotations
   {

      /** The four-week buff rotation, in its own order. */
      public static const WEEK_BUFFS:Array = ["$Event_DoubleStarBar_name",
                                              "$Event_DoubleAdventureXP_name",
                                              "$Event_second_stat_reroll_name",
                                              "$Event_InvasionFaster_name"];

      /** Every biome either biome cycle can land on, named by the key the client ships
       *  for it rather than by the English the tables carry. */
      private static const MANA_BIOMES:Array = ["$CollectionName_NeonCity",
                                                "$CollectionName_JurassicJungle",
                                                "$CollectionName_DragonfirePeaks",
                                                "$CollectionName_ForbiddenSpires",
                                                "$CollectionName_Giantlands",
                                                "$CollectionName_MedievalHighlands",
                                                "$CollectionName_Permafrost",
                                                "$CollectionName_CursedVale",
                                                "$CollectionName_DesertFrontier",
                                                "$Objective_FaeForest",
                                                "$CollectionName_Candoria"];

      private static const STAMPY_BIOMES:Array = ["$CollectionName_DesertFrontier",
                                                  "$Objective_TheLostIsles",
                                                  "$Geode_Surface",
                                                  "$CollectionName_NeonCity",
                                                  "$CollectionName_DragonfirePeaks",
                                                  "$CollectionName_Permafrost",
                                                  "$CollectionName_Candoria",
                                                  "$CollectionName_CursedVale",
                                                  "$CollectionName_ForbiddenSpires",
                                                  "$Objective_FaeForest",
                                                  "$CollectionName_MedievalHighlands",
                                                  "$CollectionName_JurassicJungle",
                                                  "$CollectionName_Giantlands"];

      public function Rotations()
      {
         super();
      }

      /** Floor division, spelled out. ActionScript's `%` truncates towards zero where
       *  the Python this is ported from floors, so the two disagree before an anchor -
       *  and an anchor is only in the past until somebody tests a date that is not. */
      private static function floorDiv(value:Number, by:Number) : Number
      {
         return Math.floor(value / by);
      }

      private static function wrap(index:Number, length:int) : int
      {
         return int(index - Math.floor(index / length) * length);
      }

      private static function state(on:Boolean, ms:Number, keys:Array) : Object
      {
         return {"on":on,"ms":ms < 0 ? 0 : ms,"keys":keys};
      }

      /** This week's bonus, and how long is left of it. Trove frame, anchored on trove
       *  2020-03-23. */
      public static function weeklyBuff(utc:Number) : Object
      {
         var week:Number = 604800000;
         var first:Number = 1584921600000;
         var t:Number = utc - 39600000;
         return state(true,Clock.untilWeeklyReset(utc),
                      [WEEK_BUFFS[wrap(floorDiv(t - first,week),WEEK_BUFFS.length)]]);
      }

      /** How long until the week whose bonus is `k` begins, and zero when that is this
       *  week's. Trove frame, the same anchor `weeklyBuff` reads. */
      public static function untilWeekBuff(utc:Number, k:int) : Number
      {
         var week:Number = 604800000;
         var first:Number = 1584921600000;
         var t:Number = utc - 39600000;
         var n:int = WEEK_BUFFS.length;
         var at:int = wrap(floorDiv(t - first,week),n);
         var ahead:int = (k - at + n) % n;
         return ahead == 0 ? 0 : Clock.untilWeeklyReset(utc) + (ahead - 1) * week;
      }

      /** Corruxion: three days in the hub, every fourteen. Trove frame, anchored on
       *  trove 2024-03-08. */
      public static function corruxion(utc:Number) : Object
      {
         var day:Number = 86400000;
         var interval:Number = 14 * day;
         var duration:Number = 3 * day;
         var first:Number = 1709856000000;
         var t:Number = utc - 39600000;
         var completed:Number = floorDiv(t - first,interval);
         var current:Number = t - first - completed * interval;
         var next:Number = first + (completed + 1) * interval;
         var on:Boolean = current < duration;
         var start:Number = on ? next - interval : next;
         return state(on,on ? start + duration - t : start - t,[]);
      }

      /** Fluxion: the same three-day window, but every seven days and alternating between
       *  taking votes and selling what was voted for. Trove frame, anchored on trove
       *  2023-07-18, which is a voting week.
       *
       *  The phase is carried whether or not the window is open, because which of the two
       *  is coming is the question - going to the hub for a vote and finding a shop is
       *  the mistake this answers. Away, `start` is already the next window, so the same
       *  read gives the next phase rather than the one just finished. */
      public static function fluxion(utc:Number) : Object
      {
         var day:Number = 86400000;
         var interval:Number = 7 * day;
         var fortnight:Number = 14 * day;
         var duration:Number = 3 * day;
         var first:Number = 1689638400000;
         var t:Number = utc - 39600000;
         var delta:Number = t - first;
         var completed:Number = floorDiv(delta,fortnight);
         var rest:Number = delta - completed * fortnight;
         var phase:Number = floorDiv(rest,interval);
         var current:Number = rest - phase * interval;
         var next:Number = first + (completed * 2 + phase + 1) * interval;
         var on:Boolean = current < duration;
         var start:Number = on ? next - interval : next;
         var votes:Boolean = wrap(Math.round((start - first) / interval),2) == 0;
         return state(on,on ? start + duration - t : start - t,
                      [votes ? "$CommunityLeaderboard_Voting" : "$store"]);
      }

      /** The chaos chest's featured item changes on the **trove Tuesday**. What is in it
       *  comes from a server; when it turns over does not.
       *
       *  BetterTroveTools expresses this as a seven-day window off the fluxion anchor,
       *  which lands on the same instants because that anchor happens to be a Tuesday.
       *  Written as the weekday it actually is, it no longer depends on an epoch that has
       *  nothing to do with it - and `verify_rotations.py` checks the two still agree at
       *  every moment it tests. */
      public static function chaosChest(utc:Number) : Object
      {
         return state(true,Clock.untilReset(utc,1),[]);
      }

      /** Wild mana grows in three biomes at a time: this week's and the two before it.
       *  Real UTC, anchored on 2023-11-20 11:00. */
      public static function wildMana(utc:Number) : Object
      {
         var week:Number = 604800000;
         var base:Number = 1700478000000;
         var weeks:Number = floorDiv(utc - base,week);
         var n:int = MANA_BIOMES.length;
         return state(true,base + (weeks + 1) * week - utc,
                      [MANA_BIOMES[wrap(weeks,n)],
                       MANA_BIOMES[wrap(weeks - 1,n)],
                       MANA_BIOMES[wrap(weeks - 2,n)]]);
      }

      /** Stampy visits one biome for forty-eight hours, once a fortnight. The window is
       *  short and the gap is long, so this answers with the run that has not finished
       *  yet rather than the one the grid is nearest. Real UTC, anchored on 2023-09-25
       *  11:00. */
      public static function stampy(utc:Number) : Object
      {
         var period:Number = 1209600000;
         var duration:Number = 172800000;
         var base:Number = 1695639600000;
         var k:Number = floorDiv(utc - base,period);
         var start:Number = base + k * period;
         var end:Number = start + duration;
         var on:Boolean = false;
         if(end <= utc)
         {
            k += 1;
            start += period;
            end = start + duration;
         }
         on = start <= utc;
         return state(on,on ? end - utc : start - utc,
                      [STAMPY_BIOMES[wrap(k,STAMPY_BIOMES.length)]]);
      }

      /** Luxion, given the trove-day his run was first seen on.
       *
       *  His *cadence* is as fixed as anything here - the merchant is open three hours,
       *  away twenty-four, and that twenty-seven hour grid has been ticking since trove
       *  2025-10-10 whether or not a run is live. What cannot be computed is which run is
       *  live: that is set by the developers and moves around events. So the caller
       *  supplies the day it saw him, and everything else comes off the grid.
       *
       *  A run is seven days long and its first opening is the first grid slot at or
       *  after that day's reset - **not** the reset itself. The grid drifts three hours a
       *  day, so a run quite normally opens fifteen hours after the day it was reported
       *  on, and every ninth trove-day holds no opening at all.
       *
       *  `ms` counts to the most useful boundary: the current window's close while he is
       *  open, the next window's open while he is not, and the run's end once the last
       *  window has gone. `active` says whether the run is still running at all - a
       *  caller draws nothing when it is false. Real UTC, `anchor` in seconds because
       *  that is the unit a run is recorded in. */
      public static function luxion(utc:Number, anchor:Number) : Object
      {
         var cycle:Number = 97200000;
         var window:Number = 10800000;
         var runs:int = 7;
         var start:Number = runStart(anchor);
         var end:Number = start + runs * 86400000;
         var windows:Array = [];
         var open:Number = 0;
         var i:int = 0;
         var answer:Object = null;
         while(i < runs)
         {
            open = start + i * cycle;
            windows.push({"at":open,"ends":open + window,"day":i + 1});
            i++;
         }
         answer = state(false,end - utc,[]);
         answer.active = start <= utc && utc < end;
         answer.windows = windows;
         answer.at = start;
         i = 0;
         while(i < windows.length)
         {
            if(utc < windows[i].ends)
            {
               answer.on = utc >= windows[i].at;
               answer.ms = answer.on ? windows[i].ends - utc : windows[i].at - utc;
               return answer;
            }
            i++;
         }
         return answer;
      }

      /** The first twenty-seven hour grid slot at or after a run's start day. */
      public static function runStart(anchor:Number) : Number
      {
         var cycle:Number = 97200000;
         var epoch:Number = 1760094000000;
         return epoch + Math.ceil((anchor * 1000 - epoch) / cycle) * cycle;
      }

      /** When the run recorded against that day is over, so a caller knows whether a
       *  sighting belongs to it or opens a new one. */
      public static function runEnd(anchor:Number) : Number
      {
         return runStart(anchor) + 7 * 86400000;
      }
   }
}
