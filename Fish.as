package
{
   public class Fish
   {

      public static const COMMON:int = 0;

      public static const UNCOMMON:int = 1;

      public static const RARE:int = 2;

      public static const MASTERY:Array = [5,15,25];

      private static const TROPHY:String = "$prefabs_placeable_deco_trophy_fish_";

      private static const TIERS:Array = ["basic","silver","gold"];

      private static const TAILS:Array = ["_item_name","_name"];

      private static var words:Array = null;

      private static var prefix:String = null;

      public static function rarityWord(rarity:int) : String
      {
         if(words == null || String(words[0]).charAt(0) == "$")
         {
            words = [IggyFunctions.translate("$Rarity_Common"),
                     IggyFunctions.translate("$Rarity_Uncommon"),
                     IggyFunctions.translate("$Rarity_Rare")];
         }
         return String(words[rarity < 0 ? 0 : (rarity > 2 ? 2 : rarity)]);
      }

      public static function get weighed() : String
      {
         var form:String = null;
         var at:int = 0;
         if(prefix != null)
         {
            return prefix;
         }
         form = String(IggyFunctions.translate("$FishWeightFormat"));
         at = form.indexOf("{");
         if(at <= 0)
         {
            return "";
         }
         prefix = form.substring(0,at);
         return prefix;
      }

      public static function weightIn(body:String) : Number
      {
         var text:String = stripped(body);
         var mark:String = weighed;
         var digits:String = "";
         var at:int = 0;
         var ch:String = null;
         if(mark.length == 0)
         {
            return NaN;
         }
         at = text.indexOf(mark);
         if(at < 0)
         {
            return NaN;
         }
         at += mark.length;
         while(at < text.length)
         {
            ch = text.charAt(at);
            if(ch >= "0" && ch <= "9")
            {
               digits += ch;
            }
            else if((ch == "." || ch == ",") && digits.length > 0
                    && digits.indexOf(".") == -1)
            {
               digits += ".";
            }
            else if(digits.length > 0)
            {
               break;
            }
            at++;
         }
         return digits.length == 0 ? NaN : Number(digits);
      }

      private static function stripped(body:String) : String
      {
         var out:String = "";
         var depth:int = 0;
         var at:int = 0;
         var ch:String = null;
         if(body == null)
         {
            return "";
         }
         while(at < body.length)
         {
            ch = body.charAt(at);
            if(ch == "<")
            {
               depth++;
            }
            else if(ch == ">")
            {
               if(depth > 0)
               {
                  depth--;
               }
            }
            else if(depth == 0)
            {
               out += ch;
            }
            at++;
         }
         return out;
      }

      public static const LOW:Array = [19.05,38.25,67.25,115.25];

      public static const HIGH:Array = [20,40,70,120];

      public static const WASLOW:Array = [7.5,21,35,75];

      public static const WASHIGH:Array = [10,30,50,100];

      private static const LIQUID:Array = [
         "Water (Anywhere)","Water (Pool)","Water (Sundered Uplands)","Water (Anywhere*)",
         "Water (Tutorial World)","Water (Radiant Ruins) during Day",
         "Water (Radiant Ruins) during Night","Water (Cursed Vale)","Water (Shadow Tower)",
         "Water (Hub)","Water (Desert Frontier)","Water (Magical Atoll)","Lava (Anywhere)",
         "Lava (Pool)","Lava (Sundered Uplands)","Lava (Anywhere*)","Lava (Tutorial World)",
         "Lava (Hub)","Lava (Radiant Ruins)","Lava (The Lost Isles)","Lava (Permafrost)",
         "Lava (Jurrasic Jungle)","Lava (Shores of the Everdark - Pool)","Chocolate (Anywhere)",
         "Chocolate (Pool)","Chocolate (Forbidden Spires)","Chocolate (Anywhere*)",
         "Chocolate (Jurassic Jungle)","Chocolate (Candoria)",
         "Chocolate (Shores of the Everdark - Pool)","Plasma (Anywhere)","Plasma (Pool)",
         "Plasma (Geode Topside)","Plasma (Forbidden Spires)","Plasma (Neon City)",
         "Plasma (Shadow Tower)","Plasma (Anywhere*)","Plasma (Permafrost)",
         "Water (Fae Forest)","Water (Dragonfire Peaks)","Water (Sea of Eternity - Pool)",
         "Water (Open Seas)","Chocolate (Permafrost)","Water (Long Shade / Drowned 15)"];
      private static const POOL:Array = [
         "Outside of Pools","Group 3","Group 2","Group 1","Event Pool","All groups",
         "Group Unknown","Group 4 - Rare"];
      private static const POLE:Array = [
         "Any non-special rod","Any","Elysian Rod / Alpha Angler",
         "Lady of the Lake / Royal Reeler","Lady of the Lake","Murkwater Mark's Mucker",
         "Turtle Trawler","Any non-special rod / Pole of the Deep","Pole of the Deep"];
      private static const TABLE:Array = [
         "$prefabs_item_fish_water_common_01_item_name|0|0|0|0|0|1||",
         "$prefabs_item_fish_water_common_02_item_name|0|0|0|0|0|1||",
         "$prefabs_item_fish_water_common_03_item_name|0|1|0|0|0|1||",
         "$prefabs_item_fish_water_common_04_item_name|0|1|0|0|0|1||",
         "$prefabs_item_fish_water_common_05_item_name|0|2|0|0|0|1||",
         "$prefabs_item_fish_water_common_06_item_name|0|2|0|0|0|1||",
         "$prefabs_item_fish_water_common_07_item_name|0|2|0|0|0|1||Low-%-split, making it rarer",
         "$prefabs_item_fish_water_common_coral_item_name|0|0|1|1|0|0||",
         "$prefabs_item_fish_water_common_frog_item_name|0|0|1|2|0|0||",
         "$prefabs_item_fish_water_common_slug_item_name|0|0|1|3|0|0||",
         "$prefabs_item_fish_water_common_school_eel_name|0|1|1|4|1|0|Untradable - Can be caught during the \"Books and Hooks\" event. Event replaces ALL pools with special event ones.|",
         "$prefabs_item_fish_water_uncommon_fatcat_item_name|1|3|0|0|0|1||",
         "$prefabs_item_fish_water_uncommon_swordfish_item_name|1|3|0|0|0|1||",
         "$prefabs_item_fish_water_uncommon_radiantshardine_item_name|1|0|0|0|0|1||",
         "$prefabs_item_fish_water_uncommon_fae_item_name|1|1|0|0|0|1||",
         "$prefabs_item_fish_water_uncommon_oreice_item_name|1|0|0|0|0|1||",
         "$prefabs_item_fish_water_uncommon_recipe_item_name|1|1|0|0|0|1||",
         "$prefabs_item_fish_water_uncommon_anglerfish_item_name|1|1|1|2|0|0||",
         "$prefabs_item_fish_water_uncommon_elemental_item_name|1|1|1|1|0|0||",
         "$prefabs_item_fish_water_uncommon_squid_item_name|1|3|1|3|0|0||",
         "$prefabs_item_fish_water_uncommon_ore_gl_upper_item_name|1|3|2|0|0|0|Palashien can create Water to fish in|",
         "$prefabs_item_fish_water_uncommon_school_deepwater_name|1|2|1|4|1|0|Untradable - Can be caught during the \"Books and Hooks\" event. Event replaces ALL pools with special event ones.|",
         "$prefabs_item_fish_water_rare_ancient_item_name|2|1|3|0|0|1|Ideal for farming Ancient Scale - Spot must lack other rare water fish|Ideal for farming Ancient Scale",
         "$prefabs_item_fish_water_rare_newbie_item_name|2|0|4|0|0|1|Cornerstone / Palashien|",
         "$prefabs_item_fish_water_rare_radiantday_item_name|2|0|5|0|0|1|Day lasts roughly 340 seconds|",
         "$prefabs_item_fish_water_rare_radiantnight_item_name|2|0|6|0|0|1|Night lasts roughly 135 seconds|",
         "$prefabs_item_fish_water_rare_undead_item_name|2|0|7|0|0|1||",
         "$prefabs_item_fish_water_rare_shadowarena_item_name|2|1|8|0|0|1||",
         "$prefabs_item_fish_water_rare_hub_item_name|2|1|9|0|0|1||",
         "$prefabs_item_fish_water_rare_desert_item_name|2|0|10|0|0|1|Cornerstone / Palashien|",
         "$prefabs_item_fish_water_rare_shark_item_name|2|2|1|5|0|0||Ideal for farming Ancient Scale",
         "$prefabs_item_fish_water_rare_zebrafish_item_name|2|1|11|0|0|1|Biome found in Drowned Worlds|",
         "$prefabs_item_fish_lava_common_01_item_name|0|0|12|0|0|1||",
         "$prefabs_item_fish_lava_common_02_item_name|0|0|12|0|0|1||",
         "$prefabs_item_fish_lava_common_03_item_name|0|1|12|0|0|1||",
         "$prefabs_item_fish_lava_common_04_item_name|0|0|12|0|0|1||",
         "$prefabs_item_fish_lava_common_05_item_name|0|2|12|0|0|1||",
         "$prefabs_item_fish_lava_common_06_item_name|0|1|12|0|0|1||",
         "$prefabs_item_fish_lava_common_07_item_name|0|2|12|0|0|1||Low-%-split, making it rarer",
         "$prefabs_item_fish_lava_common_coral_item_name|0|1|13|1|0|0||",
         "$prefabs_item_fish_lava_common_frog_item_name|0|0|13|3|0|0||",
         "$prefabs_item_fish_lava_common_slug_item_name|0|0|13|2|0|0||",
         "$prefabs_item_fish_lava_common_school_tuna_name|0|1|13|4|1|0|Untradable - Can be caught during the \"Books and Hooks\" event. Event replaces ALL pools with special event ones.|",
         "$prefabs_item_fish_lava_uncommon_orecommon_item_name|1|3|12|0|0|1||",
         "$prefabs_item_fish_lava_uncommon_oreuncommon_item_name|1|3|12|0|0|1||",
         "$prefabs_item_fish_lava_uncommon_orerare_item_name|1|3|12|0|0|1||",
         "$prefabs_item_fish_lava_uncommon_orefire_item_name|1|1|12|0|0|1||",
         "$prefabs_item_fish_lava_uncommon_swordfish_item_name|1|3|12|0|0|1||",
         "$prefabs_item_fish_lava_uncommon_diamond_item_name|1|1|12|0|0|1||",
         "$prefabs_item_fish_lava_uncommon_bottle_item_name|1|0|12|0|0|1||",
         "$prefabs_item_fish_lava_uncommon_anglerfish_item_name|1|1|13|3|0|0||",
         "$prefabs_item_fish_lava_uncommon_elemental_item_name|1|2|13|1|0|0||",
         "$prefabs_item_fish_lava_uncommon_squid_item_name|1|1|13|2|0|0||",
         "$prefabs_item_fish_lava_uncommon_ore_gl_lower_item_name|1|3|14|0|0|0|Lava leaking into lower layer of Sundered Uplands (Find adjacent Dragonfire Peaks for easy access)|",
         "$prefabs_item_fish_lava_uncommon_school_carp_name|1|0|13|4|1|0|Untradable - Can be caught during the \"Books and Hooks\" event. Event replaces ALL pools with special event ones.|",
         "$prefabs_item_fish_lava_rare_ancient_item_name|2|2|15|0|0|1|Spot must lack other rare lava fish|",
         "$prefabs_item_fish_lava_rare_newbie_item_name|2|0|16|0|0|1|Mine-type dungeons can spawn with lava pools on the surface|",
         "$prefabs_item_fish_lava_rare_hub_item_name|2|1|17|0|0|1|Lava can be found in the Trials of Luxion area|",
         "$prefabs_item_fish_lava_rare_sky_item_name|2|0|18|0|0|1|Dungeons can spawn with Lava instead of Water, not too rare|",
         "$prefabs_item_fish_lava_rare_treasureisle_item_name|2|1|19|0|0|1|Lava can be found in 3-Star volcano Dungeons and Lighthouse Dungeons - Biome found in any 'Prime' world|",
         "$prefabs_item_fish_lava_rare_ice_item_name|2|0|20|0|0|1|Lava can be found in the center of some 3-Star Dungeons and at the bottom of the mine-like 3-Star Dungeon|",
         "$prefabs_item_fish_lava_rare_shark_item_name|2|2|13|5|0|0||",
         "$prefabs_item_fish_lava_rare_zebrafish_item_name|2|0|21|0|0|1|Lava can be found at the bottom of some 3-Star Dungeons|",
         "$prefabs_item_fish_enchanted_rare_lava_darkwater_item_name|2|1|22|5|2|0||",
         "$prefabs_item_fish_chocolate_common_01_item_name|0|0|23|0|0|1||",
         "$prefabs_item_fish_chocolate_common_02_item_name|0|0|23|0|0|1||",
         "$prefabs_item_fish_chocolate_common_03_item_name|0|1|23|0|0|1||",
         "$prefabs_item_fish_chocolate_common_04_item_name|0|3|23|0|0|1||",
         "$prefabs_item_fish_chocolate_common_05_item_name|0|2|23|0|0|1||",
         "$prefabs_item_fish_chocolate_common_06_item_name|0|2|23|0|0|1||",
         "$prefabs_item_fish_chocolate_common_07_item_name|0|2|23|0|0|1||Low-%-split, making it rarer",
         "$prefabs_item_fish_chocolate_common_coral_item_name|0|0|24|1|0|0||",
         "$prefabs_item_fish_chocolate_common_frog_item_name|0|0|24|3|0|0||",
         "$prefabs_item_fish_chocolate_common_slug_item_name|0|1|24|2|0|0||",
         "$prefabs_item_fish_chocolate_common_school_surgeon_name|0|2|24|4|1|0|Untradable - Can be caught during the \"Books and Hooks\" event. Event replaces ALL pools with special event ones.|",
         "$prefabs_item_fish_chocolate_uncommon_cupcake_item_name|1|0|23|0|0|1||",
         "$prefabs_item_fish_chocolate_uncommon_enchwood_item_name|1|0|23|0|0|1||",
         "$prefabs_item_fish_chocolate_uncommon_mushroom_item_name|1|0|23|0|0|1||",
         "$prefabs_item_fish_chocolate_uncommon_swordfish_item_name|1|3|23|0|0|1||",
         "$prefabs_item_fish_chocolate_uncommon_glim_item_name|1|1|23|0|0|1||",
         "$prefabs_item_fish_chocolate_uncommon_anglerfish_item_name|1|2|23|3|0|0||",
         "$prefabs_item_fish_chocolate_uncommon_elemental_item_name|1|1|23|1|0|0||",
         "$prefabs_item_fish_chocolate_uncommon_squid_item_name|1|1|23|2|0|0||",
         "$prefabs_item_fish_chocolate_uncommon_ore_cinnabar_item_name|1|3|25|0|0|0|Chocolate fountain in Cornerstone|",
         "$prefabs_item_fish_chocolate_uncommon_school_mackerel_name|1|0|24|4|1|0|Untradable - Can be caught during the \"Books and Hooks\" event. Event replaces ALL pools with special event ones.|",
         "$prefabs_item_fish_chocolate_rare_ancient_item_name|2|2|26|0|0|1|Spot must lack other rare chocolate fish|",
         "$prefabs_item_fish_chocolate_rare_cottoncandy_blue_item_name|2|1|23|0|0|1|Chocolate fountain in Cornerstone must be height 200 or above|",
         "$prefabs_item_fish_chocolate_rare_cottoncandy_pink_item_name|2|1|23|0|0|1|Chocolate fountain in Cornerstone must be height 200 or above|",
         "$prefabs_item_fish_chocolate_rare_gobstopper_item_name|2|0|23|0|0|1|Chocolate fountain below water underground in Treasure Isle seems easiest - Must be height 20 or below, anywhere but Candoria|",
         "$prefabs_item_fish_chocolate_rare_octopus_item_name|2|2|27|0|0|1|Chocolate fountain in Cornerstone|",
         "$prefabs_item_fish_chocolate_rare_chocodile_item_name|2|3|28|0|0|1||",
         "$prefabs_item_fish_chocolate_rare_shark_item_name|2|2|24|5|0|0||",
         "$prefabs_item_fish_chocolate_rare_zebrafish_item_name|2|0|25|0|0|0|Chocolate fountain in Cornerstone|",
         "$prefabs_item_fish_enchanted_rare_chocolate_darkwater_item_name|2|3|29|5|2|0||",
         "$prefabs_item_fish_plasma_common_01_name|0|0|30|0|0|1||",
         "$prefabs_item_fish_plasma_common_02_name|0|0|30|0|0|1||",
         "$prefabs_item_fish_plasma_common_03_name|0|1|30|0|0|1||",
         "$prefabs_item_fish_plasma_common_04_name|0|1|30|0|0|1||",
         "$prefabs_item_fish_plasma_common_05_name|0|2|30|0|0|1||",
         "$prefabs_item_fish_plasma_common_06_name|0|2|30|0|0|1||",
         "$prefabs_item_fish_plasma_common_07_name|0|3|30|0|0|1||Low-%-split, making it rarer",
         "$prefabs_item_fish_plasma_common_coral_item_name|0|3|31|1|0|0||",
         "$prefabs_item_fish_plasma_common_frog_item_name|0|1|31|3|0|0||",
         "$prefabs_item_fish_plasma_common_slug_item_name|0|0|31|2|0|0||",
         "$prefabs_item_fish_plasma_common_school_marlin_name|0|2|31|4|1|0|Untradable - Can be caught during the \"Books and Hooks\" event. Event replaces ALL pools with special event ones.|",
         "$prefabs_item_fish_plasma_uncommon_01_name|1|0|30|0|0|1||",
         "$prefabs_item_fish_plasma_uncommon_02_name|1|1|30|0|0|1||",
         "$prefabs_item_fish_plasma_uncommon_04_name|1|2|30|0|0|1||",
         "$prefabs_item_fish_plasma_uncommon_05_name|1|3|30|0|0|1||",
         "$prefabs_item_fish_plasma_uncommon_anglerfish_item_name|1|1|31|3|0|0||",
         "$prefabs_item_fish_plasma_uncommon_elemental_item_name|1|0|31|1|0|0||",
         "$prefabs_item_fish_plasma_uncommon_squid_item_name|1|1|31|2|0|0||",
         "$prefabs_item_fish_plasma_uncommon_ore_nitro_glitterine_item_name|1|3|32|0|0|1||",
         "$prefabs_fish_plasma_uncommon_school_trout_name|1|0|31|4|1|0|Untradable - Can be caught during the \"Books and Hooks\" event. Event replaces ALL pools with special event ones.|",
         "$prefabs_item_fish_plasma_rare_01_name|2|0|33|0|0|0||",
         "$prefabs_item_fish_plasma_rare_02_name|2|0|30|0|0|1|Must be height 55 or below - Geode topside with non-special rod seems to be easiest - Anvil 5-Star Dungeons spawn with Plasma|",
         "$prefabs_item_fish_plasma_rare_03_name|2|1|30|0|0|1|Must be height 111 or above - Must lack other rare fish - Try to find a good spot in a 3-Star Neon City dungeon|",
         "$prefabs_item_fish_plasma_rare_04_name|2|2|34|0|0|1|Must be height 56-110|",
         "$prefabs_item_fish_plasma_rare_05_name|2|3|35|0|0|1||",
         "$prefabs_item_fish_plasma_plasma_swordfish_item_name|2|3|36|0|0|1|Spot must lack other rare plasma fish - Example: Plasma in Medieval Highlands / Geode topside|",
         "$prefabs_item_fish_plasma_rare_shark_item_name|2|2|31|5|0|0||",
         "$prefabs_item_fish_plasma_rare_zebrafish_item_name|2|0|37|0|0|1|Some 3-Star dungeons spawn with plasma in the center. Alternatively find an adjacent Neon City biome (preferred)|",
         "$prefabs_item_fish_enchanted_rare_plasma_darkwater_item_name|2|2|31|5|2|0||",
         "$prefabs_item_fish_enchanted_rare_frogprince_item_name|2|0|38|0|3|1||",
         "$prefabs_item_fish_enchanted_rare_phoenix_item_name|2|2|39|0|4|1|Cornerstone water fountain - Palashien can create Water to fish in|",
         "$prefabs_item_fish_enchanted_rare_witch_item_name|2|1|7|0|3|1|Cornerstone water fountain - Must be height 20-200|Great for farming Enchanted Scale",
         "$prefabs_item_fish_enchanted_rare_gryphon_item_name|2|2|0|0|3|1|Cornerstone water fountain - Must be height 200 or above -- Can use Ganda and Palashien to create a sky water pool|",
         "$prefabs_item_fish_enchanted_rare_merqubesly_item_name|2|1|0|0|3|1|Must be height 20 or lower - Water underground in Treasure Isle seems easiest|",
         "$prefabs_item_fish_enchanted_rare_tardigrade_item_name|2|0|40|6|5|0|Sea of Eternity can be found in Shores of the Everdark|",
         "$prefabs_item_fish_enchanted_rare_sea_urchin_item_name|2|0|24|3|5|0|Test pool group by catching one common/uncommon and comparing their group to find the right pool|",
         "$prefabs_item_fish_enchanted_rare_ocean_sunfish_item_name|2|3|13|6|5|0||",
         "$prefabs_item_fish_enchanted_rare_goblinfish_item_name|2|1|1|1|5|0|Test pool group by catching one common/uncommon and comparing their group to find the right pool - Works in D15|",
         "$prefabs_item_fish_enchanted_rare_eel_item_name|2|1|31|2|5|0|Test pool group by catching one common/uncommon and comparing their group to find the right pool|",
         "$prefabs_item_fish_enchanted_rare_lobster_item_name|2|1|13|7|5|0|Rare lava pools only - Seems easiest in Igneous Island World|",
         "$prefabs_item_fish_enchanted_rare_water_turtle_item_name|2|2|41|0|6|0|Found in any water in Open Seas Biome located in Drowned World (Icon-less biome on map, not spawn chunk)|Great for farming Turtle Shell",
         "$prefabs_item_fish_enchanted_rare_lava_turtle_item_name|2|2|14|0|6|0|Caught in Lava in the lower layer of Sundered Uplands. Find adjacent Dragonfire Peaks for ease of access|",
         "$prefabs_item_fish_enchanted_rare_plasma_turtle_item_name|2|2|32|0|6|0|Plasma can be found in the Anvil 5-Star dungeon and some 1-Star dungeons. Anvil preferred for spot rotation|",
         "$prefabs_item_fish_enchanted_rare_chocolate_turtle_item_name|2|2|42|0|6|0|Chocolate fountain at height 100 or lower - Cornerstone potential|",
         "$prefabs_item_fish_water_common_maxuber_abyssalangler_name|0|1|43|1|7|0||",
         "$prefabs_item_fish_water_common_maxuber_abyssalcrustacean_name|0|0|43|1|7|0||",
         "$prefabs_item_fish_water_common_maxuber_pyricflyfish_name|0|0|43|3|7|0||",
         "$prefabs_item_fish_water_common_maxuber_pyrickraken_name|0|3|43|3|7|0||",
         "$prefabs_item_fish_water_common_maxuber_zephyrangler_name|0|1|43|2|7|0||",
         "$prefabs_item_fish_water_common_maxuber_zephyrnautiloid_name|0|2|43|2|7|0||",
         "$prefabs_item_fish_water_uncommon_maxuber_abyssalhippocampus_name|1|0|43|1|7|0||Low-%-split, making it rarer",
         "$prefabs_item_fish_water_uncommon_maxuber_deepstone_name|1|1|43|1|7|0||",
         "$prefabs_item_fish_water_uncommon_maxuber_lichenstone_name|1|1|43|3|7|0||",
         "$prefabs_item_fish_water_uncommon_maxuber_pyricpuffer_name|1|2|43|3|7|0||",
         "$prefabs_item_fish_water_uncommon_maxuber_runeslate_name|1|1|43|2|7|0||",
         "$prefabs_item_fish_water_uncommon_maxuber_zephyrclam_name|1|3|43|2|7|0||",
         "$prefabs_item_fish_water_rare_maxuber_abyssalsquid_name|2|1|43|7|8|0|Rare water pools only|Great for farming Scale of the Depths",
         "$prefabs_item_fish_water_rare_maxuber_kraken_name|2|3|43|2|8|0||",
         "$prefabs_item_fish_water_rare_maxuber_pyricjellyfish_name|2|0|43|3|8|0||",
         "$prefabs_item_fish_water_rare_maxuber_zephyrmanta_name|2|2|43|1|8|0||"];
      private static const MOUNTED:Array = [
         "bonefish|29|0","choc_ancient|85|0","choc_browniemone|79|0","choc_common_coral|71|0",
         "choc_common_frog|72|0","choc_common_slug|73|0","choc_cotcandyblue|86|0",
         "choc_cotcandypink|87|0","choc_crocodile|90|0","choc_cupcake|75|0","choc_epic|66|0",
         "choc_frozenfudge|76|0","choc_gobstopper|88|0","choc_legendary|67|0",
         "choc_mushroom|77|0","choc_poptopus|89|0","choc_rare_shark|91|0",
         "choc_rare_zebrafish|92|0","choc_rare|65|0","choc_relic|68|0","choc_resplendent|69|0",
         "choc_shadow|70|0","choc_swordfish|78|0","choc_uncommon_anglerfish|80|0",
         "choc_uncommon_elemental|81|0","choc_uncommon_ore_cinnabar|83|0",
         "choc_uncommon_squid|82|0","choc_uncommon|64|0","chocolate_common_school_surgeon|74|1",
         "chocolate_uncommon_school_mackerel|84|1","enchanted_rare_chocolate_darkwater|93|0",
         "enchanted_rare_chocolate_turtle|137|0","enchanted_rare_eel|132|0",
         "enchanted_rare_goblinfish|131|0","enchanted_rare_lava_darkwater|63|0",
         "enchanted_rare_lava_turtle|135|0","enchanted_rare_lobster|133|0",
         "enchanted_rare_ocean_sunfish|130|0","enchanted_rare_plasma_darkwater|122|0",
         "enchanted_rare_plasma_turtle|136|0","enchanted_rare_sea_urchin|129|0",
         "enchanted_rare_tardigrade|128|0","enchanted_rare_water_turtle|134|0","eyefish|27|0",
         "fatcat|11|0","hubhugger|28|0","lava_ancient|55|0","lava_common_coral|39|0",
         "lava_common_frog|40|0","lava_common_school_tuna|42|1","lava_common_slug|41|0",
         "lava_diamond|48|0","lava_epic|34|0","lava_fireore|46|0","lava_glass|49|0",
         "lava_hubhugger|57|0","lava_icefireore|60|0","lava_islefireore|59|0",
         "lava_legendary|35|0","lava_noobfish|56|0","lava_rare_shark|61|0",
         "lava_rare_zebrafish|62|0","lava_rare|33|0","lava_relic|36|0","lava_resplendent|37|0",
         "lava_shadow|38|0","lava_shardine|58|0","lava_swordfish|47|0",
         "lava_uncommon_anglerfish|50|0","lava_uncommon_elemental|51|0",
         "lava_uncommon_ore_gl_lower|53|0","lava_uncommon_school_carp|54|1",
         "lava_uncommon_squid|52|0","lava_uncommon|32|0","magic_frogprince|123|0",
         "magic_gryphon|126|0","magic_merqubesly|127|0","magic_phoenix|124|0",
         "magic_witchfunnel|125|0","moonfish|25|0","noobfish|23|0","orefish_formicite|44|0",
         "orefish_infinium|45|0","orefish_shapestone|43|0","plasma_common_01|94|0",
         "plasma_common_02|95|0","plasma_common_03|96|0","plasma_common_04|97|0",
         "plasma_common_05|98|0","plasma_common_06|99|0","plasma_common_07|100|0",
         "plasma_common_coral|101|0","plasma_common_frog|102|0",
         "plasma_common_school_marlin|104|1","plasma_common_slug|103|0","plasma_rare_01|114|0",
         "plasma_rare_02|115|0","plasma_rare_03|116|0","plasma_rare_04|117|0",
         "plasma_rare_05|118|0","plasma_rare_shark|120|0","plasma_rare_zebrafish|121|0",
         "plasma_swordfish|119|0","plasma_uncommon_01|105|0","plasma_uncommon_02|106|0",
         "plasma_uncommon_04|107|0","plasma_uncommon_05|108|0",
         "plasma_uncommon_anglerfish|109|0","plasma_uncommon_elemental|110|0",
         "plasma_uncommon_ore_nitro_glitterine|112|0","plasma_uncommon_school_trout|113|1",
         "plasma_uncommon_squid|111|0","shardine_radiant|13|0","sunfish|24|0","swordfish|12|0",
         "undead_ghostfish|26|0","water_ancient|22|0","water_common_coral|7|0",
         "water_common_frog|8|0","water_common_maxuber_abyssalangler|138|0",
         "water_common_maxuber_abyssalcrustacean|139|0",
         "water_common_maxuber_pyricflyfish|140|0","water_common_maxuber_pyrickraken|141|0",
         "water_common_maxuber_zephyrangler|142|0","water_common_maxuber_zephyrnautiloid|143|0",
         "water_common_school_eel|10|1","water_common_slug|9|0","water_epic|2|0",
         "water_fae|14|0","water_iceore|15|0","water_legendary|3|0",
         "water_rare_maxuber_abyssalsquid|150|0","water_rare_maxuber_kraken|151|0",
         "water_rare_maxuber_pyricjellyfish|152|0","water_rare_maxuber_zephyrmanta|153|0",
         "water_rare_shark|30|0","water_rare_zebrafish|31|0","water_rare|1|0","water_relic|4|0",
         "water_resplendent|5|0","water_school|16|0","water_shadow|6|0",
         "water_uncommon_anglerfish|17|0","water_uncommon_elemental|18|0",
         "water_uncommon_maxuber_abyssalhippocampus|144|0",
         "water_uncommon_maxuber_deepstone|145|0","water_uncommon_maxuber_lichenstone|146|0",
         "water_uncommon_maxuber_pyricpuffer|147|0","water_uncommon_maxuber_runeslate|148|0",
         "water_uncommon_maxuber_zephyrclam|149|0","water_uncommon_ore_gl_upper|20|0",
         "water_uncommon_school_deepwater|21|1","water_uncommon_squid|19|0","water_uncommon|0|0"];

      private static var index:Object = null;

      public var key:String = "";

      public var rarity:int = 0;

      public var weight:int = 0;

      public var liquid:String = "";

      public var pool:String = "";

      public var pole:String = "";

      public var aged:Boolean = false;

      public var hint:String = "";

      public var note:String = "";

      public function Fish()
      {
         super();
      }

      public function get low() : Number
      {
         return Number(LOW[this.weight]);
      }

      public function get high() : Number
      {
         return Number(HIGH[this.weight]);
      }

      public function get worth() : int
      {
         return int(MASTERY[this.rarity]);
      }

      public function fraction(caught:Number) : Number
      {
         var least:Number = this.old(caught) ? Number(WASLOW[this.weight]) : this.low;
         var most:Number = this.old(caught) ? Number(WASHIGH[this.weight]) : this.high;
         var part:Number = most <= least ? 0 : (caught - least) / (most - least);
         return part < 0 ? 0 : (part > 1 ? 1 : part);
      }

      public function fits(caught:Number) : Boolean
      {
         if(this.old(caught))
         {
            return true;
         }
         return !isNaN(caught) && caught >= this.low && caught <= this.high;
      }

      public function old(caught:Number) : Boolean
      {
         return this.aged && caught >= Number(WASLOW[this.weight])
             && caught <= Number(WASHIGH[this.weight]);
      }

      public static const PLAIN:int = 0;

      public static const LEAST:int = 1;

      public static const RECORD:int = 2;

      public static const HAIR:int = 3;

      public static const WHOLE:int = 4;

      public static const NOTHING:int = 5;

      public function standing(caught:Number) : int
      {
         var least:Number = this.old(caught) ? Number(WASLOW[this.weight]) : this.low;
         var most:Number = this.old(caught) ? Number(WASHIGH[this.weight]) : this.high;
         if(isNaN(caught))
         {
            return PLAIN;
         }
         if(near(caught,0))
         {
            return NOTHING;
         }
         if(near(caught,least))
         {
            return LEAST;
         }
         if(near(caught,most))
         {
            return RECORD;
         }
         if(near(caught,least + 0.01) || near(caught,most - 0.01))
         {
            return HAIR;
         }
         if(near(caught,Math.round(caught)) && caught > least && caught < most)
         {
            return WHOLE;
         }
         return PLAIN;
      }

      private static function near(a:Number, b:Number) : Boolean
      {
         return Math.abs(a - b) < 0.001;
      }

      public static function named(displayName:String) : Fish
      {
         var name:String = displayName == null ? "" : trimmed(displayName.toLowerCase());
         var map:Object = null;
         if(name.length == 0)
         {
            return null;
         }
         if(index == null)
         {
            map = built();
            if(map == null)
            {
               return null;
            }
            index = map;
         }
         return index[name] as Fish;
      }

      private static function built() : Object
      {
         var out:Object = {};
         var made:Array = [];
         var row:String = null;
         var parts:Array = null;
         var fish:Fish = null;
         var tier:String = null;
         var tail:String = null;
         var found:int = 0;
         for each(row in TABLE)
         {
            parts = row.split("|");
            fish = new Fish();
            fish.key = parts[0];
            fish.rarity = int(parts[1]);
            fish.weight = int(parts[2]);
            fish.liquid = LIQUID[int(parts[3])];
            fish.pool = POOL[int(parts[4])];
            fish.pole = POLE[int(parts[5])];
            fish.aged = parts[6] == "1";
            fish.hint = parts[7];
            fish.note = parts[8];
            made.push(fish);
            found += put(out,fish.key,fish);
         }
         for each(row in MOUNTED)
         {
            parts = row.split("|");
            fish = made[int(parts[1])] as Fish;
            tail = String(TAILS[int(parts[2])]);
            for each(tier in TIERS)
            {
               put(out,TROPHY + parts[0] + "_" + tier + tail,fish);
            }
         }
         return found == 0 ? null : out;
      }

      private static function put(into:Object, key:String, fish:Fish) : int
      {
         var name:String = trimmed(String(IggyFunctions.translate(key)).toLowerCase());
         if(name.length == 0 || name.charAt(0) == "$")
         {
            return 0;
         }
         into[name] = fish;
         return 1;
      }


      private static function trimmed(body:String) : String
      {
         var from:int = 0;
         var to:int = body.length;
         while(from < to && body.charAt(from) <= " ")
         {
            from++;
         }
         while(to > from && body.charAt(to - 1) <= " ")
         {
            to--;
         }
         return body.substring(from,to);
      }
   }
}
