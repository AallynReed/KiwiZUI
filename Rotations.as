package
{
   public class Rotations
   {

      public static const WEEK_BUFFS:Array = ["$Event_DoubleStarBar_name",
                                              "$Event_DoubleAdventureXP_name",
                                              "$Event_second_stat_reroll_name",
                                              "$Event_InvasionFaster_name"];

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

      public static const D15_ONE:Array = ["$Objective_Giantlands",
                                           "$Objective_CeriseSandsea",
                                           "$Objective_DeepForest",
                                           "Alkali Flats",
                                           "$Objective_DeadofWinter",
                                           "$Objective_Giantlands",
                                           "Firefly Party",
                                           "$Objective_DesertofSecrets",
                                           "Weathered Wastelands",
                                           "$Objective_FrozenWastes",
                                           "$Objective_FriggasFjord",
                                           "$Objective_AbandonedBoneyard"];

      public static const D15_TWO:Array = ["$Objective_CursedVale",
                                           "$Objective_HollowDunes",
                                           "$Objective_BewitchingWood",
                                           "$Objective_PrimalPreserve",
                                           "$Objective_HollowDunes",
                                           "$Objective_ForbiddenSpires",
                                           "Viking Burial Grounds",
                                           "$Objective_SpellboundThicket",
                                           "$Objective_SaurianSwamp",
                                           "$Objective_ForbiddenMountains",
                                           "$Objective_UncannyValley"];

      public static const D15_THREE:Array = ["Sugar Steppes",
                                             "$Objective_VolcanicFields",
                                             "$Objective_TheLostIsles",
                                             "$Objective_NeonCity_Luminopolis",
                                             "$Objective_TheLostIsles",
                                             "$Objective_BlazingEmberlands",
                                             "Cocoa Craters",
                                             "Data Spires",
                                             "$Objective_TheLostIsles",
                                             "Cupcake Canyon",
                                             "$Objective_DragonsTeeth",
                                             "$Objective_NeonCity_Luminopolis",
                                             "$Objective_TheLostIsles",
                                             "Data Spires"];

      public function Rotations()
      {
         super();
      }

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

      public static function weeklyBuff(utc:Number) : Object
      {
         var week:Number = 604800000;
         var first:Number = 1584921600000;
         var t:Number = utc - 39600000;
         return state(true,Clock.untilWeeklyReset(utc),
                      [WEEK_BUFFS[wrap(floorDiv(t - first,week),WEEK_BUFFS.length)]]);
      }

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

      public static function chaosChest(utc:Number) : Object
      {
         return state(true,Clock.untilReset(utc,1),[]);
      }

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

      public static function luxion(utc:Number, anchor:Number) : Object
      {
         var cycle:Number = 97200000;
         var window:Number = 10800000;
         var start:Number = anchor * 1000;
         var end:Number = runEnd(anchor);
         var windows:Array = [];
         var open:Number = runStart(anchor);
         var day:int = 1;
         var answer:Object = null;
         var i:int = 0;
         while(open < end)
         {
            windows.push({"at":open,"ends":open + window,"day":day});
            open += cycle;
            day++;
         }
         answer = state(false,end - utc,[]);
         answer.active = start <= utc && utc < end;
         answer.windows = windows;
         answer.at = start;
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

      public static function biomes(utc:Number) : Object
      {
         var span:Number = 10800000;
         var first:Number = 1718708400000;
         var into:Number = (utc - first) % span;
         var k:Number = floorDiv(utc - first,span);
         if(into < 0)
         {
            into += span;
         }
         return state(true,span - into,
                      [D15_ONE[wrap(k,D15_ONE.length)],
                       D15_TWO[wrap(k,D15_TWO.length)],
                       D15_THREE[wrap(k,D15_THREE.length)]]);
      }

      public static function gardening(utc:Number, days:int) : Object
      {
         var day:Number = 86400000;
         var first:Number = 1747998000000;
         var span:Number = days * day;
         var start:Number = first + floorDiv(utc - first,span) * span + (days - 1) * day;
         var on:Boolean = start <= utc;
         return state(on,on ? start + day - utc : start - utc,[]);
      }

      public static function fastTrial(utc:Number) : Object
      {
         var cycle:Number = 97200000;
         var window:Number = 10800000;
         var epoch:Number = 1760094000000;
         var k:Number = floorDiv(utc - epoch,cycle);
         var start:Number = epoch + k * cycle;
         var answer:Object = null;
         if(start + window <= utc)
         {
            start += cycle;
         }
         answer = state(start <= utc,start <= utc ? start + window - utc : start - utc,[]);
         answer.at = start;
         return answer;
      }

      public static function runStart(anchor:Number) : Number
      {
         var cycle:Number = 97200000;
         var epoch:Number = 1760094000000;
         return epoch + Math.ceil((anchor * 1000 - epoch) / cycle) * cycle;
      }

      public static function runEnd(anchor:Number) : Number
      {
         var day:Number = 86400000;
         return Clock.dayStart(anchor * 1000) * 1000 + 7 * day;
      }
   }
}
