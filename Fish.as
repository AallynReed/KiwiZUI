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
         "Outside of Pools","Group 3","Group 2","Group 1","All groups","Group Unknown",
         "Group 4 - Rare"];
      private static const POLE:Array = [
         "Any non-special rod","Elysian Rod / Alpha Angler","Lady of the Lake / Royal Reeler",
         "Lady of the Lake","Murkwater Mark's Mucker","Turtle Trawler",
         "Any non-special rod / Pole of the Deep","Pole of the Deep"];
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
         "$prefabs_item_fish_water_rare_ancient_item_name|2|1|3|0|0|1|Ideal for farming Ancient Scale - Spot must lack other rare water fish|Ideal for farming Ancient Scale",
         "$prefabs_item_fish_water_rare_newbie_item_name|2|0|4|0|0|1|Cornerstone / Palashien|",
         "$prefabs_item_fish_water_rare_radiantday_item_name|2|0|5|0|0|1|Day lasts roughly 340 seconds|",
         "$prefabs_item_fish_water_rare_radiantnight_item_name|2|0|6|0|0|1|Night lasts roughly 135 seconds|",
         "$prefabs_item_fish_water_rare_undead_item_name|2|0|7|0|0|1||",
         "$prefabs_item_fish_water_rare_shadowarena_item_name|2|1|8|0|0|1||",
         "$prefabs_item_fish_water_rare_hub_item_name|2|1|9|0|0|1||",
         "$prefabs_item_fish_water_rare_desert_item_name|2|0|10|0|0|1|Cornerstone / Palashien|",
         "$prefabs_item_fish_water_rare_shark_item_name|2|2|1|4|0|0||Ideal for farming Ancient Scale",
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
         "$prefabs_item_fish_lava_rare_ancient_item_name|2|2|15|0|0|1|Spot must lack other rare lava fish|",
         "$prefabs_item_fish_lava_rare_newbie_item_name|2|0|16|0|0|1|Mine-type dungeons can spawn with lava pools on the surface|",
         "$prefabs_item_fish_lava_rare_hub_item_name|2|1|17|0|0|1|Lava can be found in the Trials of Luxion area|",
         "$prefabs_item_fish_lava_rare_sky_item_name|2|0|18|0|0|1|Dungeons can spawn with Lava instead of Water, not too rare|",
         "$prefabs_item_fish_lava_rare_treasureisle_item_name|2|1|19|0|0|1|Lava can be found in 3-Star volcano Dungeons and Lighthouse Dungeons - Biome found in any 'Prime' world|",
         "$prefabs_item_fish_lava_rare_ice_item_name|2|0|20|0|0|1|Lava can be found in the center of some 3-Star Dungeons and at the bottom of the mine-like 3-Star Dungeon|",
         "$prefabs_item_fish_lava_rare_shark_item_name|2|2|13|4|0|0||",
         "$prefabs_item_fish_lava_rare_zebrafish_item_name|2|0|21|0|0|1|Lava can be found at the bottom of some 3-Star Dungeons|",
         "$prefabs_item_fish_enchanted_rare_lava_darkwater_item_name|2|1|22|4|1|0||",
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
         "$prefabs_item_fish_chocolate_uncommon_cupcake_item_name|1|0|23|0|0|1||",
         "$prefabs_item_fish_chocolate_uncommon_enchwood_item_name|1|0|23|0|0|1||",
         "$prefabs_item_fish_chocolate_uncommon_mushroom_item_name|1|0|23|0|0|1||",
         "$prefabs_item_fish_chocolate_uncommon_swordfish_item_name|1|3|23|0|0|1||",
         "$prefabs_item_fish_chocolate_uncommon_glim_item_name|1|1|23|0|0|1||",
         "$prefabs_item_fish_chocolate_uncommon_anglerfish_item_name|1|2|23|3|0|0||",
         "$prefabs_item_fish_chocolate_uncommon_elemental_item_name|1|1|23|1|0|0||",
         "$prefabs_item_fish_chocolate_uncommon_squid_item_name|1|1|23|2|0|0||",
         "$prefabs_item_fish_chocolate_uncommon_ore_cinnabar_item_name|1|3|25|0|0|0|Chocolate fountain in Cornerstone|",
         "$prefabs_item_fish_chocolate_rare_ancient_item_name|2|2|26|0|0|1|Spot must lack other rare chocolate fish|",
         "$prefabs_item_fish_chocolate_rare_cottoncandy_blue_item_name|2|1|23|0|0|1|Chocolate fountain in Cornerstone must be height 200 or above|",
         "$prefabs_item_fish_chocolate_rare_cottoncandy_pink_item_name|2|1|23|0|0|1|Chocolate fountain in Cornerstone must be height 200 or above|",
         "$prefabs_item_fish_chocolate_rare_gobstopper_item_name|2|0|23|0|0|1|Chocolate fountain below water underground in Treasure Isle seems easiest - Must be height 20 or below, anywhere but Candoria|",
         "$prefabs_item_fish_chocolate_rare_octopus_item_name|2|2|27|0|0|1|Chocolate fountain in Cornerstone|",
         "$prefabs_item_fish_chocolate_rare_chocodile_item_name|2|3|28|0|0|1||",
         "$prefabs_item_fish_chocolate_rare_shark_item_name|2|2|24|4|0|0||",
         "$prefabs_item_fish_chocolate_rare_zebrafish_item_name|2|0|25|0|0|0|Chocolate fountain in Cornerstone|",
         "$prefabs_item_fish_enchanted_rare_chocolate_darkwater_item_name|2|3|29|4|1|0||",
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
         "$prefabs_item_fish_plasma_uncommon_01_name|1|0|30|0|0|1||",
         "$prefabs_item_fish_plasma_uncommon_02_name|1|1|30|0|0|1||",
         "$prefabs_item_fish_plasma_uncommon_04_name|1|2|30|0|0|1||",
         "$prefabs_item_fish_plasma_uncommon_05_name|1|3|30|0|0|1||",
         "$prefabs_item_fish_plasma_uncommon_anglerfish_item_name|1|1|31|3|0|0||",
         "$prefabs_item_fish_plasma_uncommon_elemental_item_name|1|0|31|1|0|0||",
         "$prefabs_item_fish_plasma_uncommon_squid_item_name|1|1|31|2|0|0||",
         "$prefabs_item_fish_plasma_uncommon_ore_nitro_glitterine_item_name|1|3|32|0|0|1||",
         "$prefabs_item_fish_plasma_rare_01_name|2|0|33|0|0|0||",
         "$prefabs_item_fish_plasma_rare_02_name|2|0|30|0|0|1|Must be height 55 or below - Geode topside with non-special rod seems to be easiest - Anvil 5-Star Dungeons spawn with Plasma|",
         "$prefabs_item_fish_plasma_rare_03_name|2|1|30|0|0|1|Must be height 111 or above - Must lack other rare fish - Try to find a good spot in a 3-Star Neon City dungeon|",
         "$prefabs_item_fish_plasma_rare_04_name|2|2|34|0|0|1|Must be height 56-110|",
         "$prefabs_item_fish_plasma_rare_05_name|2|3|35|0|0|1||",
         "$prefabs_item_fish_plasma_plasma_swordfish_item_name|2|3|36|0|0|1|Spot must lack other rare plasma fish - Example: Plasma in Medieval Highlands / Geode topside|",
         "$prefabs_item_fish_plasma_rare_shark_item_name|2|2|31|4|0|0||",
         "$prefabs_item_fish_plasma_rare_zebrafish_item_name|2|0|37|0|0|1|Some 3-Star dungeons spawn with plasma in the center. Alternatively find an adjacent Neon City biome (preferred)|",
         "$prefabs_item_fish_enchanted_rare_plasma_darkwater_item_name|2|2|31|4|1|0||",
         "$prefabs_item_fish_enchanted_rare_frogprince_item_name|2|0|38|0|2|1||",
         "$prefabs_item_fish_enchanted_rare_phoenix_item_name|2|2|39|0|3|1|Cornerstone water fountain - Palashien can create Water to fish in|",
         "$prefabs_item_fish_enchanted_rare_witch_item_name|2|1|7|0|2|1|Cornerstone water fountain - Must be height 20-200|Great for farming Enchanted Scale",
         "$prefabs_item_fish_enchanted_rare_gryphon_item_name|2|2|0|0|2|1|Cornerstone water fountain - Must be height 200 or above -- Can use Ganda and Palashien to create a sky water pool|",
         "$prefabs_item_fish_enchanted_rare_merqubesly_item_name|2|1|0|0|2|1|Must be height 20 or lower - Water underground in Treasure Isle seems easiest|",
         "$prefabs_item_fish_enchanted_rare_tardigrade_item_name|2|0|40|5|4|0|Sea of Eternity can be found in Shores of the Everdark|",
         "$prefabs_item_fish_enchanted_rare_sea_urchin_item_name|2|0|24|3|4|0|Test pool group by catching one common/uncommon and comparing their group to find the right pool|",
         "$prefabs_item_fish_enchanted_rare_ocean_sunfish_item_name|2|3|13|5|4|0||",
         "$prefabs_item_fish_enchanted_rare_goblinfish_item_name|2|1|1|1|4|0|Test pool group by catching one common/uncommon and comparing their group to find the right pool - Works in D15|",
         "$prefabs_item_fish_enchanted_rare_eel_item_name|2|1|31|2|4|0|Test pool group by catching one common/uncommon and comparing their group to find the right pool|",
         "$prefabs_item_fish_enchanted_rare_lobster_item_name|2|1|13|6|4|0|Rare lava pools only - Seems easiest in Igneous Island World|",
         "$prefabs_item_fish_enchanted_rare_water_turtle_item_name|2|2|41|0|5|0|Found in any water in Open Seas Biome located in Drowned World (Icon-less biome on map, not spawn chunk)|Great for farming Turtle Shell",
         "$prefabs_item_fish_enchanted_rare_lava_turtle_item_name|2|2|14|0|5|0|Caught in Lava in the lower layer of Sundered Uplands. Find adjacent Dragonfire Peaks for ease of access|",
         "$prefabs_item_fish_enchanted_rare_plasma_turtle_item_name|2|2|32|0|5|0|Plasma can be found in the Anvil 5-Star dungeon and some 1-Star dungeons. Anvil preferred for spot rotation|",
         "$prefabs_item_fish_enchanted_rare_chocolate_turtle_item_name|2|2|42|0|5|0|Chocolate fountain at height 100 or lower - Cornerstone potential|",
         "$prefabs_item_fish_water_common_maxuber_abyssalangler_name|0|1|43|1|6|0||",
         "$prefabs_item_fish_water_common_maxuber_abyssalcrustacean_name|0|0|43|1|6|0||",
         "$prefabs_item_fish_water_common_maxuber_pyricflyfish_name|0|0|43|3|6|0||",
         "$prefabs_item_fish_water_common_maxuber_pyrickraken_name|0|3|43|3|6|0||",
         "$prefabs_item_fish_water_common_maxuber_zephyrangler_name|0|1|43|2|6|0||",
         "$prefabs_item_fish_water_common_maxuber_zephyrnautiloid_name|0|2|43|2|6|0||",
         "$prefabs_item_fish_water_uncommon_maxuber_abyssalhippocampus_name|1|0|43|1|6|0||Low-%-split, making it rarer",
         "$prefabs_item_fish_water_uncommon_maxuber_deepstone_name|1|1|43|1|6|0||",
         "$prefabs_item_fish_water_uncommon_maxuber_lichenstone_name|1|1|43|3|6|0||",
         "$prefabs_item_fish_water_uncommon_maxuber_pyricpuffer_name|1|2|43|3|6|0||",
         "$prefabs_item_fish_water_uncommon_maxuber_runeslate_name|1|1|43|2|6|0||",
         "$prefabs_item_fish_water_uncommon_maxuber_zephyrclam_name|1|3|43|2|6|0||",
         "$prefabs_item_fish_water_rare_maxuber_abyssalsquid_name|2|1|43|6|7|0|Rare water pools only|Great for farming Scale of the Depths",
         "$prefabs_item_fish_water_rare_maxuber_kraken_name|2|3|43|2|7|0||",
         "$prefabs_item_fish_water_rare_maxuber_pyricjellyfish_name|2|0|43|3|7|0||",
         "$prefabs_item_fish_water_rare_maxuber_zephyrmanta_name|2|2|43|1|7|0||"];
      private static const MOUNTED:Array = [
         "bonefish|27","choc_ancient|79","choc_browniemone|74","choc_common_coral|67",
         "choc_common_frog|68","choc_common_slug|69","choc_cotcandyblue|80",
         "choc_cotcandypink|81","choc_crocodile|84","choc_cupcake|70","choc_epic|62",
         "choc_frozenfudge|71","choc_gobstopper|82","choc_legendary|63","choc_mushroom|72",
         "choc_poptopus|83","choc_rare_shark|85","choc_rare_zebrafish|86","choc_rare|61",
         "choc_relic|64","choc_resplendent|65","choc_shadow|66","choc_swordfish|73",
         "choc_uncommon_anglerfish|75","choc_uncommon_elemental|76",
         "choc_uncommon_ore_cinnabar|78","choc_uncommon_squid|77","choc_uncommon|60",
         "enchanted_rare_chocolate_darkwater|87","enchanted_rare_chocolate_turtle|129",
         "enchanted_rare_eel|124","enchanted_rare_goblinfish|123",
         "enchanted_rare_lava_darkwater|59","enchanted_rare_lava_turtle|127",
         "enchanted_rare_lobster|125","enchanted_rare_ocean_sunfish|122",
         "enchanted_rare_plasma_darkwater|114","enchanted_rare_plasma_turtle|128",
         "enchanted_rare_sea_urchin|121","enchanted_rare_tardigrade|120",
         "enchanted_rare_water_turtle|126","eyefish|25","fatcat|10","hubhugger|26",
         "lava_ancient|51","lava_common_coral|37","lava_common_frog|38","lava_common_slug|39",
         "lava_diamond|45","lava_epic|32","lava_fireore|43","lava_glass|46","lava_hubhugger|53",
         "lava_icefireore|56","lava_islefireore|55","lava_legendary|33","lava_noobfish|52",
         "lava_rare_shark|57","lava_rare_zebrafish|58","lava_rare|31","lava_relic|34",
         "lava_resplendent|35","lava_shadow|36","lava_shardine|54","lava_swordfish|44",
         "lava_uncommon_anglerfish|47","lava_uncommon_elemental|48",
         "lava_uncommon_ore_gl_lower|50","lava_uncommon_squid|49","lava_uncommon|30",
         "magic_frogprince|115","magic_gryphon|118","magic_merqubesly|119","magic_phoenix|116",
         "magic_witchfunnel|117","moonfish|23","noobfish|21","orefish_formicite|41",
         "orefish_infinium|42","orefish_shapestone|40","plasma_common_01|88",
         "plasma_common_02|89","plasma_common_03|90","plasma_common_04|91",
         "plasma_common_05|92","plasma_common_06|93","plasma_common_07|94",
         "plasma_common_coral|95","plasma_common_frog|96","plasma_common_slug|97",
         "plasma_rare_01|106","plasma_rare_02|107","plasma_rare_03|108","plasma_rare_04|109",
         "plasma_rare_05|110","plasma_rare_shark|112","plasma_rare_zebrafish|113",
         "plasma_swordfish|111","plasma_uncommon_01|98","plasma_uncommon_02|99",
         "plasma_uncommon_04|100","plasma_uncommon_05|101","plasma_uncommon_anglerfish|102",
         "plasma_uncommon_elemental|103","plasma_uncommon_ore_nitro_glitterine|105",
         "plasma_uncommon_squid|104","shardine_radiant|12","sunfish|22","swordfish|11",
         "undead_ghostfish|24","water_ancient|20","water_common_coral|7","water_common_frog|8",
         "water_common_maxuber_abyssalangler|130","water_common_maxuber_abyssalcrustacean|131",
         "water_common_maxuber_pyricflyfish|132","water_common_maxuber_pyrickraken|133",
         "water_common_maxuber_zephyrangler|134","water_common_maxuber_zephyrnautiloid|135",
         "water_common_slug|9","water_epic|2","water_fae|13","water_iceore|14",
         "water_legendary|3","water_rare_maxuber_abyssalsquid|142",
         "water_rare_maxuber_kraken|143","water_rare_maxuber_pyricjellyfish|144",
         "water_rare_maxuber_zephyrmanta|145","water_rare_shark|28","water_rare_zebrafish|29",
         "water_rare|1","water_relic|4","water_resplendent|5","water_school|15",
         "water_shadow|6","water_uncommon_anglerfish|16","water_uncommon_elemental|17",
         "water_uncommon_maxuber_abyssalhippocampus|136","water_uncommon_maxuber_deepstone|137",
         "water_uncommon_maxuber_lichenstone|138","water_uncommon_maxuber_pyricpuffer|139",
         "water_uncommon_maxuber_runeslate|140","water_uncommon_maxuber_zephyrclam|141",
         "water_uncommon_ore_gl_upper|19","water_uncommon_squid|18","water_uncommon|0"];

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
            for each(tier in TIERS)
            {
               put(out,TROPHY + parts[0] + "_" + tier + "_item_name",fish);
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
