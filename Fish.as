package
{
   public class Fish
   {

      public static const COMMON:int = 0;

      public static const UNCOMMON:int = 1;

      public static const RARE:int = 2;

      public static const MASTERY:Array = [5,15,25];

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

      private static const TABLE:Array = tableParts();

      private static function tableParts() : Array
      {
         var t:Array = [];
         tableParts0(t);
         return t;
      }

      private static function tableParts0(t:Array) : void
      {
         t[0] = ["$prefabs_item_fish_water_common_01_item_name",0,0,0,0,0,true,"",""];
         t[1] = ["$prefabs_item_fish_water_common_02_item_name",0,0,0,0,0,true,"",""];
         t[2] = ["$prefabs_item_fish_water_common_03_item_name",0,1,0,0,0,true,"",""];
         t[3] = ["$prefabs_item_fish_water_common_04_item_name",0,1,0,0,0,true,"",""];
         t[4] = ["$prefabs_item_fish_water_common_05_item_name",0,2,0,0,0,true,"",""];
         t[5] = ["$prefabs_item_fish_water_common_06_item_name",0,2,0,0,0,true,"",""];
         t[6] = ["$prefabs_item_fish_water_common_07_item_name",0,2,0,0,0,true,"","Low-%-split, making it rarer"];
         t[7] = ["$prefabs_item_fish_water_common_coral_item_name",0,0,1,1,0,false,"",""];
         t[8] = ["$prefabs_item_fish_water_common_frog_item_name",0,0,1,2,0,false,"",""];
         t[9] = ["$prefabs_item_fish_water_common_slug_item_name",0,0,1,3,0,false,"",""];
         t[10] = ["$prefabs_item_fish_water_common_school_eel_name",0,1,1,4,1,false,"Untradable - Can be caught during the \"Books and Hooks\" event. Event replaces ALL pools with special event ones.",""];
         t[11] = ["$prefabs_item_fish_water_uncommon_fatcat_item_name",1,3,0,0,0,true,"",""];
         t[12] = ["$prefabs_item_fish_water_uncommon_swordfish_item_name",1,3,0,0,0,true,"",""];
         t[13] = ["$prefabs_item_fish_water_uncommon_radiantshardine_item_name",1,0,0,0,0,true,"",""];
         t[14] = ["$prefabs_item_fish_water_uncommon_fae_item_name",1,1,0,0,0,true,"",""];
         t[15] = ["$prefabs_item_fish_water_uncommon_oreice_item_name",1,0,0,0,0,true,"",""];
         t[16] = ["$prefabs_item_fish_water_uncommon_recipe_item_name",1,1,0,0,0,true,"",""];
         t[17] = ["$prefabs_item_fish_water_uncommon_anglerfish_item_name",1,1,1,2,0,false,"",""];
         t[18] = ["$prefabs_item_fish_water_uncommon_elemental_item_name",1,1,1,1,0,false,"",""];
         t[19] = ["$prefabs_item_fish_water_uncommon_squid_item_name",1,3,1,3,0,false,"",""];
         t[20] = ["$prefabs_item_fish_water_uncommon_ore_gl_upper_item_name",1,3,2,0,0,false,"Palashien can create Water to fish in",""];
         t[21] = ["$prefabs_item_fish_water_uncommon_school_deepwater_name",1,2,1,4,1,false,"Untradable - Can be caught during the \"Books and Hooks\" event. Event replaces ALL pools with special event ones.",""];
         t[22] = ["$prefabs_item_fish_water_rare_ancient_item_name",2,1,3,0,0,true,"Ideal for farming Ancient Scale - Spot must lack other rare water fish","Ideal for farming Ancient Scale"];
         t[23] = ["$prefabs_item_fish_water_rare_newbie_item_name",2,0,4,0,0,true,"Cornerstone / Palashien",""];
         t[24] = ["$prefabs_item_fish_water_rare_radiantday_item_name",2,0,5,0,0,true,"Day lasts roughly 340 seconds",""];
         t[25] = ["$prefabs_item_fish_water_rare_radiantnight_item_name",2,0,6,0,0,true,"Night lasts roughly 135 seconds",""];
         t[26] = ["$prefabs_item_fish_water_rare_undead_item_name",2,0,7,0,0,true,"",""];
         t[27] = ["$prefabs_item_fish_water_rare_shadowarena_item_name",2,1,8,0,0,true,"",""];
         t[28] = ["$prefabs_item_fish_water_rare_hub_item_name",2,1,9,0,0,true,"",""];
         t[29] = ["$prefabs_item_fish_water_rare_desert_item_name",2,0,10,0,0,true,"Cornerstone / Palashien",""];
         t[30] = ["$prefabs_item_fish_water_rare_shark_item_name",2,2,1,5,0,false,"","Ideal for farming Ancient Scale"];
         t[31] = ["$prefabs_item_fish_water_rare_zebrafish_item_name",2,1,11,0,0,true,"Biome found in Drowned Worlds",""];
         t[32] = ["$prefabs_item_fish_lava_common_01_item_name",0,0,12,0,0,true,"",""];
         t[33] = ["$prefabs_item_fish_lava_common_02_item_name",0,0,12,0,0,true,"",""];
         t[34] = ["$prefabs_item_fish_lava_common_03_item_name",0,1,12,0,0,true,"",""];
         t[35] = ["$prefabs_item_fish_lava_common_04_item_name",0,0,12,0,0,true,"",""];
         t[36] = ["$prefabs_item_fish_lava_common_05_item_name",0,2,12,0,0,true,"",""];
         t[37] = ["$prefabs_item_fish_lava_common_06_item_name",0,1,12,0,0,true,"",""];
         t[38] = ["$prefabs_item_fish_lava_common_07_item_name",0,2,12,0,0,true,"","Low-%-split, making it rarer"];
         t[39] = ["$prefabs_item_fish_lava_common_coral_item_name",0,1,13,1,0,false,"",""];
         t[40] = ["$prefabs_item_fish_lava_common_frog_item_name",0,0,13,3,0,false,"",""];
         t[41] = ["$prefabs_item_fish_lava_common_slug_item_name",0,0,13,2,0,false,"",""];
         t[42] = ["$prefabs_item_fish_lava_common_school_tuna_name",0,1,13,4,1,false,"Untradable - Can be caught during the \"Books and Hooks\" event. Event replaces ALL pools with special event ones.",""];
         t[43] = ["$prefabs_item_fish_lava_uncommon_orecommon_item_name",1,3,12,0,0,true,"",""];
         t[44] = ["$prefabs_item_fish_lava_uncommon_oreuncommon_item_name",1,3,12,0,0,true,"",""];
         t[45] = ["$prefabs_item_fish_lava_uncommon_orerare_item_name",1,3,12,0,0,true,"",""];
         t[46] = ["$prefabs_item_fish_lava_uncommon_orefire_item_name",1,1,12,0,0,true,"",""];
         t[47] = ["$prefabs_item_fish_lava_uncommon_swordfish_item_name",1,3,12,0,0,true,"",""];
         t[48] = ["$prefabs_item_fish_lava_uncommon_diamond_item_name",1,1,12,0,0,true,"",""];
         t[49] = ["$prefabs_item_fish_lava_uncommon_bottle_item_name",1,0,12,0,0,true,"",""];
         t[50] = ["$prefabs_item_fish_lava_uncommon_anglerfish_item_name",1,1,13,3,0,false,"",""];
         t[51] = ["$prefabs_item_fish_lava_uncommon_elemental_item_name",1,2,13,1,0,false,"",""];
         t[52] = ["$prefabs_item_fish_lava_uncommon_squid_item_name",1,1,13,2,0,false,"",""];
         t[53] = ["$prefabs_item_fish_lava_uncommon_ore_gl_lower_item_name",1,3,14,0,0,false,"Lava leaking into lower layer of Sundered Uplands (Find adjacent Dragonfire Peaks for easy access)",""];
         t[54] = ["$prefabs_item_fish_lava_uncommon_school_carp_name",1,0,13,4,1,false,"Untradable - Can be caught during the \"Books and Hooks\" event. Event replaces ALL pools with special event ones.",""];
         t[55] = ["$prefabs_item_fish_lava_rare_ancient_item_name",2,2,15,0,0,true,"Spot must lack other rare lava fish",""];
         t[56] = ["$prefabs_item_fish_lava_rare_newbie_item_name",2,0,16,0,0,true,"Mine-type dungeons can spawn with lava pools on the surface",""];
         t[57] = ["$prefabs_item_fish_lava_rare_hub_item_name",2,1,17,0,0,true,"Lava can be found in the Trials of Luxion area",""];
         t[58] = ["$prefabs_item_fish_lava_rare_sky_item_name",2,0,18,0,0,true,"Dungeons can spawn with Lava instead of Water, not too rare",""];
         t[59] = ["$prefabs_item_fish_lava_rare_treasureisle_item_name",2,1,19,0,0,true,"Lava can be found in 3-Star volcano Dungeons and Lighthouse Dungeons - Biome found in any 'Prime' world",""];
         t[60] = ["$prefabs_item_fish_lava_rare_ice_item_name",2,0,20,0,0,true,"Lava can be found in the center of some 3-Star Dungeons and at the bottom of the mine-like 3-Star Dungeon",""];
         t[61] = ["$prefabs_item_fish_lava_rare_shark_item_name",2,2,13,5,0,false,"",""];
         t[62] = ["$prefabs_item_fish_lava_rare_zebrafish_item_name",2,0,21,0,0,true,"Lava can be found at the bottom of some 3-Star Dungeons",""];
         t[63] = ["$prefabs_item_fish_enchanted_rare_lava_darkwater_item_name",2,1,22,5,2,false,"",""];
         t[64] = ["$prefabs_item_fish_chocolate_common_01_item_name",0,0,23,0,0,true,"",""];
         t[65] = ["$prefabs_item_fish_chocolate_common_02_item_name",0,0,23,0,0,true,"",""];
         t[66] = ["$prefabs_item_fish_chocolate_common_03_item_name",0,1,23,0,0,true,"",""];
         t[67] = ["$prefabs_item_fish_chocolate_common_04_item_name",0,3,23,0,0,true,"",""];
         t[68] = ["$prefabs_item_fish_chocolate_common_05_item_name",0,2,23,0,0,true,"",""];
         t[69] = ["$prefabs_item_fish_chocolate_common_06_item_name",0,2,23,0,0,true,"",""];
         t[70] = ["$prefabs_item_fish_chocolate_common_07_item_name",0,2,23,0,0,true,"","Low-%-split, making it rarer"];
         t[71] = ["$prefabs_item_fish_chocolate_common_coral_item_name",0,0,24,1,0,false,"",""];
         t[72] = ["$prefabs_item_fish_chocolate_common_frog_item_name",0,0,24,3,0,false,"",""];
         t[73] = ["$prefabs_item_fish_chocolate_common_slug_item_name",0,1,24,2,0,false,"",""];
         t[74] = ["$prefabs_item_fish_chocolate_common_school_surgeon_name",0,2,24,4,1,false,"Untradable - Can be caught during the \"Books and Hooks\" event. Event replaces ALL pools with special event ones.",""];
         t[75] = ["$prefabs_item_fish_chocolate_uncommon_cupcake_item_name",1,0,23,0,0,true,"",""];
         t[76] = ["$prefabs_item_fish_chocolate_uncommon_enchwood_item_name",1,0,23,0,0,true,"",""];
         t[77] = ["$prefabs_item_fish_chocolate_uncommon_mushroom_item_name",1,0,23,0,0,true,"",""];
         t[78] = ["$prefabs_item_fish_chocolate_uncommon_swordfish_item_name",1,3,23,0,0,true,"",""];
         t[79] = ["$prefabs_item_fish_chocolate_uncommon_glim_item_name",1,1,23,0,0,true,"",""];
         t[80] = ["$prefabs_item_fish_chocolate_uncommon_anglerfish_item_name",1,2,23,3,0,false,"",""];
         t[81] = ["$prefabs_item_fish_chocolate_uncommon_elemental_item_name",1,1,23,1,0,false,"",""];
         t[82] = ["$prefabs_item_fish_chocolate_uncommon_squid_item_name",1,1,23,2,0,false,"",""];
         t[83] = ["$prefabs_item_fish_chocolate_uncommon_ore_cinnabar_item_name",1,3,25,0,0,false,"Chocolate fountain in Cornerstone",""];
         t[84] = ["$prefabs_item_fish_chocolate_uncommon_school_mackerel_name",1,0,24,4,1,false,"Untradable - Can be caught during the \"Books and Hooks\" event. Event replaces ALL pools with special event ones.",""];
         t[85] = ["$prefabs_item_fish_chocolate_rare_ancient_item_name",2,2,26,0,0,true,"Spot must lack other rare chocolate fish",""];
         t[86] = ["$prefabs_item_fish_chocolate_rare_cottoncandy_blue_item_name",2,1,23,0,0,true,"Chocolate fountain in Cornerstone must be height 200 or above",""];
         t[87] = ["$prefabs_item_fish_chocolate_rare_cottoncandy_pink_item_name",2,1,23,0,0,true,"Chocolate fountain in Cornerstone must be height 200 or above",""];
         t[88] = ["$prefabs_item_fish_chocolate_rare_gobstopper_item_name",2,0,23,0,0,true,"Chocolate fountain below water underground in Treasure Isle seems easiest - Must be height 20 or below, anywhere but Candoria",""];
         t[89] = ["$prefabs_item_fish_chocolate_rare_octopus_item_name",2,2,27,0,0,true,"Chocolate fountain in Cornerstone",""];
         t[90] = ["$prefabs_item_fish_chocolate_rare_chocodile_item_name",2,3,28,0,0,true,"",""];
         t[91] = ["$prefabs_item_fish_chocolate_rare_shark_item_name",2,2,24,5,0,false,"",""];
         t[92] = ["$prefabs_item_fish_chocolate_rare_zebrafish_item_name",2,0,25,0,0,false,"Chocolate fountain in Cornerstone",""];
         t[93] = ["$prefabs_item_fish_enchanted_rare_chocolate_darkwater_item_name",2,3,29,5,2,false,"",""];
         t[94] = ["$prefabs_item_fish_plasma_common_01_name",0,0,30,0,0,true,"",""];
         t[95] = ["$prefabs_item_fish_plasma_common_02_name",0,0,30,0,0,true,"",""];
         t[96] = ["$prefabs_item_fish_plasma_common_03_name",0,1,30,0,0,true,"",""];
         t[97] = ["$prefabs_item_fish_plasma_common_04_name",0,1,30,0,0,true,"",""];
         t[98] = ["$prefabs_item_fish_plasma_common_05_name",0,2,30,0,0,true,"",""];
         t[99] = ["$prefabs_item_fish_plasma_common_06_name",0,2,30,0,0,true,"",""];
         t[100] = ["$prefabs_item_fish_plasma_common_07_name",0,3,30,0,0,true,"","Low-%-split, making it rarer"];
         t[101] = ["$prefabs_item_fish_plasma_common_coral_item_name",0,3,31,1,0,false,"",""];
         t[102] = ["$prefabs_item_fish_plasma_common_frog_item_name",0,1,31,3,0,false,"",""];
         t[103] = ["$prefabs_item_fish_plasma_common_slug_item_name",0,0,31,2,0,false,"",""];
         t[104] = ["$prefabs_item_fish_plasma_common_school_marlin_name",0,2,31,4,1,false,"Untradable - Can be caught during the \"Books and Hooks\" event. Event replaces ALL pools with special event ones.",""];
         t[105] = ["$prefabs_item_fish_plasma_uncommon_01_name",1,0,30,0,0,true,"",""];
         t[106] = ["$prefabs_item_fish_plasma_uncommon_02_name",1,1,30,0,0,true,"",""];
         t[107] = ["$prefabs_item_fish_plasma_uncommon_04_name",1,2,30,0,0,true,"",""];
         t[108] = ["$prefabs_item_fish_plasma_uncommon_05_name",1,3,30,0,0,true,"",""];
         t[109] = ["$prefabs_item_fish_plasma_uncommon_anglerfish_item_name",1,1,31,3,0,false,"",""];
         t[110] = ["$prefabs_item_fish_plasma_uncommon_elemental_item_name",1,0,31,1,0,false,"",""];
         t[111] = ["$prefabs_item_fish_plasma_uncommon_squid_item_name",1,1,31,2,0,false,"",""];
         t[112] = ["$prefabs_item_fish_plasma_uncommon_ore_nitro_glitterine_item_name",1,3,32,0,0,true,"",""];
         t[113] = ["$prefabs_fish_plasma_uncommon_school_trout_name",1,0,31,4,1,false,"Untradable - Can be caught during the \"Books and Hooks\" event. Event replaces ALL pools with special event ones.",""];
         t[114] = ["$prefabs_item_fish_plasma_rare_01_name",2,0,33,0,0,false,"",""];
         t[115] = ["$prefabs_item_fish_plasma_rare_02_name",2,0,30,0,0,true,"Must be height 55 or below - Geode topside with non-special rod seems to be easiest - Anvil 5-Star Dungeons spawn with Plasma",""];
         t[116] = ["$prefabs_item_fish_plasma_rare_03_name",2,1,30,0,0,true,"Must be height 111 or above - Must lack other rare fish - Try to find a good spot in a 3-Star Neon City dungeon",""];
         t[117] = ["$prefabs_item_fish_plasma_rare_04_name",2,2,34,0,0,true,"Must be height 56-110",""];
         t[118] = ["$prefabs_item_fish_plasma_rare_05_name",2,3,35,0,0,true,"",""];
         t[119] = ["$prefabs_item_fish_plasma_plasma_swordfish_item_name",2,3,36,0,0,true,"Spot must lack other rare plasma fish - Example: Plasma in Medieval Highlands / Geode topside",""];
         t[120] = ["$prefabs_item_fish_plasma_rare_shark_item_name",2,2,31,5,0,false,"",""];
         t[121] = ["$prefabs_item_fish_plasma_rare_zebrafish_item_name",2,0,37,0,0,true,"Some 3-Star dungeons spawn with plasma in the center. Alternatively find an adjacent Neon City biome (preferred)",""];
         t[122] = ["$prefabs_item_fish_enchanted_rare_plasma_darkwater_item_name",2,2,31,5,2,false,"",""];
         t[123] = ["$prefabs_item_fish_enchanted_rare_frogprince_item_name",2,0,38,0,3,true,"",""];
         t[124] = ["$prefabs_item_fish_enchanted_rare_phoenix_item_name",2,2,39,0,4,true,"Cornerstone water fountain - Palashien can create Water to fish in",""];
         t[125] = ["$prefabs_item_fish_enchanted_rare_witch_item_name",2,1,7,0,3,true,"Cornerstone water fountain - Must be height 20-200","Great for farming Enchanted Scale"];
         t[126] = ["$prefabs_item_fish_enchanted_rare_gryphon_item_name",2,2,0,0,3,true,"Cornerstone water fountain - Must be height 200 or above -- Can use Ganda and Palashien to create a sky water pool",""];
         t[127] = ["$prefabs_item_fish_enchanted_rare_merqubesly_item_name",2,1,0,0,3,true,"Must be height 20 or lower - Water underground in Treasure Isle seems easiest",""];
         t[128] = ["$prefabs_item_fish_enchanted_rare_tardigrade_item_name",2,0,40,6,5,false,"Sea of Eternity can be found in Shores of the Everdark",""];
         t[129] = ["$prefabs_item_fish_enchanted_rare_sea_urchin_item_name",2,0,24,3,5,false,"Test pool group by catching one common/uncommon and comparing their group to find the right pool",""];
         t[130] = ["$prefabs_item_fish_enchanted_rare_ocean_sunfish_item_name",2,3,13,6,5,false,"",""];
         t[131] = ["$prefabs_item_fish_enchanted_rare_goblinfish_item_name",2,1,1,1,5,false,"Test pool group by catching one common/uncommon and comparing their group to find the right pool - Works in D15",""];
         t[132] = ["$prefabs_item_fish_enchanted_rare_eel_item_name",2,1,31,2,5,false,"Test pool group by catching one common/uncommon and comparing their group to find the right pool",""];
         t[133] = ["$prefabs_item_fish_enchanted_rare_lobster_item_name",2,1,13,7,5,false,"Rare lava pools only - Seems easiest in Igneous Island World",""];
         t[134] = ["$prefabs_item_fish_enchanted_rare_water_turtle_item_name",2,2,41,0,6,false,"Found in any water in Open Seas Biome located in Drowned World (Icon-less biome on map, not spawn chunk)","Great for farming Turtle Shell"];
         t[135] = ["$prefabs_item_fish_enchanted_rare_lava_turtle_item_name",2,2,14,0,6,false,"Caught in Lava in the lower layer of Sundered Uplands. Find adjacent Dragonfire Peaks for ease of access",""];
         t[136] = ["$prefabs_item_fish_enchanted_rare_plasma_turtle_item_name",2,2,32,0,6,false,"Plasma can be found in the Anvil 5-Star dungeon and some 1-Star dungeons. Anvil preferred for spot rotation",""];
         t[137] = ["$prefabs_item_fish_enchanted_rare_chocolate_turtle_item_name",2,2,42,0,6,false,"Chocolate fountain at height 100 or lower - Cornerstone potential",""];
         t[138] = ["$prefabs_item_fish_water_common_maxuber_abyssalangler_name",0,1,43,1,7,false,"",""];
         t[139] = ["$prefabs_item_fish_water_common_maxuber_abyssalcrustacean_name",0,0,43,1,7,false,"",""];
         t[140] = ["$prefabs_item_fish_water_common_maxuber_pyricflyfish_name",0,0,43,3,7,false,"",""];
         t[141] = ["$prefabs_item_fish_water_common_maxuber_pyrickraken_name",0,3,43,3,7,false,"",""];
         t[142] = ["$prefabs_item_fish_water_common_maxuber_zephyrangler_name",0,1,43,2,7,false,"",""];
         t[143] = ["$prefabs_item_fish_water_common_maxuber_zephyrnautiloid_name",0,2,43,2,7,false,"",""];
         t[144] = ["$prefabs_item_fish_water_uncommon_maxuber_abyssalhippocampus_name",1,0,43,1,7,false,"","Low-%-split, making it rarer"];
         t[145] = ["$prefabs_item_fish_water_uncommon_maxuber_deepstone_name",1,1,43,1,7,false,"",""];
         t[146] = ["$prefabs_item_fish_water_uncommon_maxuber_lichenstone_name",1,1,43,3,7,false,"",""];
         t[147] = ["$prefabs_item_fish_water_uncommon_maxuber_pyricpuffer_name",1,2,43,3,7,false,"",""];
         t[148] = ["$prefabs_item_fish_water_uncommon_maxuber_runeslate_name",1,1,43,2,7,false,"",""];
         t[149] = ["$prefabs_item_fish_water_uncommon_maxuber_zephyrclam_name",1,3,43,2,7,false,"",""];
         t[150] = ["$prefabs_item_fish_water_rare_maxuber_abyssalsquid_name",2,1,43,7,8,false,"Rare water pools only","Great for farming Scale of the Depths"];
         t[151] = ["$prefabs_item_fish_water_rare_maxuber_kraken_name",2,3,43,2,8,false,"",""];
         t[152] = ["$prefabs_item_fish_water_rare_maxuber_pyricjellyfish_name",2,0,43,3,8,false,"",""];
         t[153] = ["$prefabs_item_fish_water_rare_maxuber_zephyrmanta_name",2,2,43,1,8,false,"",""];
      }

      private static const MOUNTED:Array = mountedParts();

      private static function mountedParts() : Array
      {
         var t:Array = [];
         mountedParts0(t);
         return t;
      }

      private static function mountedParts0(t:Array) : void
      {
         t[0] = ["$prefabs_placeable_deco_trophy_fish_bonefish_basic_item_name",29];
         t[1] = ["$prefabs_placeable_deco_trophy_fish_bonefish_silver_item_name",29];
         t[2] = ["$prefabs_placeable_deco_trophy_fish_bonefish_gold_item_name",29];
         t[3] = ["$prefabs_placeable_deco_trophy_fish_choc_ancient_basic_item_name",85];
         t[4] = ["$prefabs_placeable_deco_trophy_fish_choc_ancient_silver_item_name",85];
         t[5] = ["$prefabs_placeable_deco_trophy_fish_choc_ancient_gold_item_name",85];
         t[6] = ["$prefabs_placeable_deco_trophy_fish_choc_browniemone_basic_item_name",79];
         t[7] = ["$prefabs_placeable_deco_trophy_fish_choc_browniemone_silver_item_name",79];
         t[8] = ["$prefabs_placeable_deco_trophy_fish_choc_browniemone_gold_item_name",79];
         t[9] = ["$prefabs_placeable_deco_trophy_fish_choc_common_coral_basic_item_name",71];
         t[10] = ["$prefabs_placeable_deco_trophy_fish_choc_common_coral_silver_item_name",71];
         t[11] = ["$prefabs_placeable_deco_trophy_fish_choc_common_coral_gold_item_name",71];
         t[12] = ["$prefabs_placeable_deco_trophy_fish_choc_common_frog_basic_item_name",72];
         t[13] = ["$prefabs_placeable_deco_trophy_fish_choc_common_frog_silver_item_name",72];
         t[14] = ["$prefabs_placeable_deco_trophy_fish_choc_common_frog_gold_item_name",72];
         t[15] = ["$prefabs_placeable_deco_trophy_fish_choc_common_slug_basic_item_name",73];
         t[16] = ["$prefabs_placeable_deco_trophy_fish_choc_common_slug_silver_item_name",73];
         t[17] = ["$prefabs_placeable_deco_trophy_fish_choc_common_slug_gold_item_name",73];
         t[18] = ["$prefabs_placeable_deco_trophy_fish_choc_cotcandyblue_basic_item_name",86];
         t[19] = ["$prefabs_placeable_deco_trophy_fish_choc_cotcandyblue_silver_item_name",86];
         t[20] = ["$prefabs_placeable_deco_trophy_fish_choc_cotcandyblue_gold_item_name",86];
         t[21] = ["$prefabs_placeable_deco_trophy_fish_choc_cotcandypink_basic_item_name",87];
         t[22] = ["$prefabs_placeable_deco_trophy_fish_choc_cotcandypink_silver_item_name",87];
         t[23] = ["$prefabs_placeable_deco_trophy_fish_choc_cotcandypink_gold_item_name",87];
         t[24] = ["$prefabs_placeable_deco_trophy_fish_choc_crocodile_basic_item_name",90];
         t[25] = ["$prefabs_placeable_deco_trophy_fish_choc_crocodile_silver_item_name",90];
         t[26] = ["$prefabs_placeable_deco_trophy_fish_choc_crocodile_gold_item_name",90];
         t[27] = ["$prefabs_placeable_deco_trophy_fish_choc_cupcake_basic_item_name",75];
         t[28] = ["$prefabs_placeable_deco_trophy_fish_choc_cupcake_silver_item_name",75];
         t[29] = ["$prefabs_placeable_deco_trophy_fish_choc_cupcake_gold_item_name",75];
         t[30] = ["$prefabs_placeable_deco_trophy_fish_choc_epic_basic_item_name",66];
         t[31] = ["$prefabs_placeable_deco_trophy_fish_choc_epic_silver_item_name",66];
         t[32] = ["$prefabs_placeable_deco_trophy_fish_choc_epic_gold_item_name",66];
         t[33] = ["$prefabs_placeable_deco_trophy_fish_choc_frozenfudge_basic_item_name",76];
         t[34] = ["$prefabs_placeable_deco_trophy_fish_choc_frozenfudge_silver_item_name",76];
         t[35] = ["$prefabs_placeable_deco_trophy_fish_choc_frozenfudge_gold_item_name",76];
         t[36] = ["$prefabs_placeable_deco_trophy_fish_choc_gobstopper_basic_item_name",88];
         t[37] = ["$prefabs_placeable_deco_trophy_fish_choc_gobstopper_silver_item_name",88];
         t[38] = ["$prefabs_placeable_deco_trophy_fish_choc_gobstopper_gold_item_name",88];
         t[39] = ["$prefabs_placeable_deco_trophy_fish_choc_legendary_basic_item_name",67];
         t[40] = ["$prefabs_placeable_deco_trophy_fish_choc_legendary_silver_item_name",67];
         t[41] = ["$prefabs_placeable_deco_trophy_fish_choc_legendary_gold_item_name",67];
         t[42] = ["$prefabs_placeable_deco_trophy_fish_choc_mushroom_basic_item_name",77];
         t[43] = ["$prefabs_placeable_deco_trophy_fish_choc_mushroom_silver_item_name",77];
         t[44] = ["$prefabs_placeable_deco_trophy_fish_choc_mushroom_gold_item_name",77];
         t[45] = ["$prefabs_placeable_deco_trophy_fish_choc_poptopus_basic_item_name",89];
         t[46] = ["$prefabs_placeable_deco_trophy_fish_choc_poptopus_silver_item_name",89];
         t[47] = ["$prefabs_placeable_deco_trophy_fish_choc_poptopus_gold_item_name",89];
         t[48] = ["$prefabs_placeable_deco_trophy_fish_choc_rare_basic_item_name",65];
         t[49] = ["$prefabs_placeable_deco_trophy_fish_choc_rare_silver_item_name",65];
         t[50] = ["$prefabs_placeable_deco_trophy_fish_choc_rare_gold_item_name",65];
         t[51] = ["$prefabs_placeable_deco_trophy_fish_choc_rare_shark_basic_item_name",91];
         t[52] = ["$prefabs_placeable_deco_trophy_fish_choc_rare_shark_silver_item_name",91];
         t[53] = ["$prefabs_placeable_deco_trophy_fish_choc_rare_shark_gold_item_name",91];
         t[54] = ["$prefabs_placeable_deco_trophy_fish_choc_rare_zebrafish_basic_item_name",92];
         t[55] = ["$prefabs_placeable_deco_trophy_fish_choc_rare_zebrafish_silver_item_name",92];
         t[56] = ["$prefabs_placeable_deco_trophy_fish_choc_rare_zebrafish_gold_item_name",92];
         t[57] = ["$prefabs_placeable_deco_trophy_fish_choc_relic_basic_item_name",68];
         t[58] = ["$prefabs_placeable_deco_trophy_fish_choc_relic_silver_item_name",68];
         t[59] = ["$prefabs_placeable_deco_trophy_fish_choc_relic_gold_item_name",68];
         t[60] = ["$prefabs_placeable_deco_trophy_fish_choc_resplendent_basic_item_name",69];
         t[61] = ["$prefabs_placeable_deco_trophy_fish_choc_resplendent_silver_item_name",69];
         t[62] = ["$prefabs_placeable_deco_trophy_fish_choc_resplendent_gold_item_name",69];
         t[63] = ["$prefabs_placeable_deco_trophy_fish_choc_shadow_basic_item_name",70];
         t[64] = ["$prefabs_placeable_deco_trophy_fish_choc_shadow_silver_item_name",70];
         t[65] = ["$prefabs_placeable_deco_trophy_fish_choc_shadow_gold_item_name",70];
         t[66] = ["$prefabs_placeable_deco_trophy_fish_choc_swordfish_basic_item_name",78];
         t[67] = ["$prefabs_placeable_deco_trophy_fish_choc_swordfish_silver_item_name",78];
         t[68] = ["$prefabs_placeable_deco_trophy_fish_choc_swordfish_gold_item_name",78];
         t[69] = ["$prefabs_placeable_deco_trophy_fish_choc_uncommon_basic_item_name",64];
         t[70] = ["$prefabs_placeable_deco_trophy_fish_choc_uncommon_silver_item_name",64];
         t[71] = ["$prefabs_placeable_deco_trophy_fish_choc_uncommon_gold_item_name",64];
         t[72] = ["$prefabs_placeable_deco_trophy_fish_choc_uncommon_anglerfish_basic_item_name",80];
         t[73] = ["$prefabs_placeable_deco_trophy_fish_choc_uncommon_anglerfish_silver_item_name",80];
         t[74] = ["$prefabs_placeable_deco_trophy_fish_choc_uncommon_anglerfish_gold_item_name",80];
         t[75] = ["$prefabs_placeable_deco_trophy_fish_choc_uncommon_elemental_basic_item_name",81];
         t[76] = ["$prefabs_placeable_deco_trophy_fish_choc_uncommon_elemental_silver_item_name",81];
         t[77] = ["$prefabs_placeable_deco_trophy_fish_choc_uncommon_elemental_gold_item_name",81];
         t[78] = ["$prefabs_placeable_deco_trophy_fish_choc_uncommon_ore_cinnabar_basic_item_name",83];
         t[79] = ["$prefabs_placeable_deco_trophy_fish_choc_uncommon_ore_cinnabar_silver_item_name",83];
         t[80] = ["$prefabs_placeable_deco_trophy_fish_choc_uncommon_ore_cinnabar_gold_item_name",83];
         t[81] = ["$prefabs_placeable_deco_trophy_fish_choc_uncommon_squid_basic_item_name",82];
         t[82] = ["$prefabs_placeable_deco_trophy_fish_choc_uncommon_squid_silver_item_name",82];
         t[83] = ["$prefabs_placeable_deco_trophy_fish_choc_uncommon_squid_gold_item_name",82];
         t[84] = ["$prefabs_placeable_deco_trophy_fish_chocolate_common_school_surgeon_basic_name",74];
         t[85] = ["$prefabs_placeable_deco_trophy_fish_chocolate_common_school_surgeon_silver_name",74];
         t[86] = ["$prefabs_placeable_deco_trophy_fish_chocolate_common_school_surgeon_gold_name",74];
         t[87] = ["$prefabs_placeable_deco_trophy_fish_chocolate_uncommon_school_mackerel_basic_name",84];
         t[88] = ["$prefabs_placeable_deco_trophy_fish_chocolate_uncommon_school_mackerel_silver_name",84];
         t[89] = ["$prefabs_placeable_deco_trophy_fish_chocolate_uncommon_school_mackerel_gold_name",84];
         t[90] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_chocolate_darkwater_basic_item_name",93];
         t[91] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_chocolate_darkwater_silver_item_name",93];
         t[92] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_chocolate_darkwater_gold_item_name",93];
         t[93] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_chocolate_turtle_basic_item_name",137];
         t[94] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_chocolate_turtle_silver_item_name",137];
         t[95] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_chocolate_turtle_gold_item_name",137];
         t[96] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_eel_basic_item_name",132];
         t[97] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_eel_silver_item_name",132];
         t[98] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_eel_gold_item_name",132];
         t[99] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_goblinfish_basic_item_name",131];
         t[100] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_goblinfish_silver_item_name",131];
         t[101] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_goblinfish_gold_item_name",131];
         t[102] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_lava_darkwater_basic_item_name",63];
         t[103] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_lava_darkwater_silver_item_name",63];
         t[104] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_lava_darkwater_gold_item_name",63];
         t[105] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_lava_turtle_basic_item_name",135];
         t[106] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_lava_turtle_silver_item_name",135];
         t[107] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_lava_turtle_gold_item_name",135];
         t[108] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_lobster_basic_item_name",133];
         t[109] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_lobster_silver_item_name",133];
         t[110] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_lobster_gold_item_name",133];
         t[111] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_ocean_sunfish_basic_item_name",130];
         t[112] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_ocean_sunfish_silver_item_name",130];
         t[113] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_ocean_sunfish_gold_item_name",130];
         t[114] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_plasma_darkwater_basic_item_name",122];
         t[115] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_plasma_darkwater_silver_item_name",122];
         t[116] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_plasma_darkwater_gold_item_name",122];
         t[117] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_plasma_turtle_basic_item_name",136];
         t[118] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_plasma_turtle_silver_item_name",136];
         t[119] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_plasma_turtle_gold_item_name",136];
         t[120] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_sea_urchin_basic_item_name",129];
         t[121] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_sea_urchin_silver_item_name",129];
         t[122] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_sea_urchin_gold_item_name",129];
         t[123] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_tardigrade_basic_item_name",128];
         t[124] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_tardigrade_silver_item_name",128];
         t[125] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_tardigrade_gold_item_name",128];
         t[126] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_water_turtle_basic_item_name",134];
         t[127] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_water_turtle_silver_item_name",134];
         t[128] = ["$prefabs_placeable_deco_trophy_fish_enchanted_rare_water_turtle_gold_item_name",134];
         t[129] = ["$prefabs_placeable_deco_trophy_fish_eyefish_basic_item_name",27];
         t[130] = ["$prefabs_placeable_deco_trophy_fish_eyefish_silver_item_name",27];
         t[131] = ["$prefabs_placeable_deco_trophy_fish_eyefish_gold_item_name",27];
         t[132] = ["$prefabs_placeable_deco_trophy_fish_fatcat_basic_item_name",11];
         t[133] = ["$prefabs_placeable_deco_trophy_fish_fatcat_silver_item_name",11];
         t[134] = ["$prefabs_placeable_deco_trophy_fish_fatcat_gold_item_name",11];
         t[135] = ["$prefabs_placeable_deco_trophy_fish_hubhugger_basic_item_name",28];
         t[136] = ["$prefabs_placeable_deco_trophy_fish_hubhugger_silver_item_name",28];
         t[137] = ["$prefabs_placeable_deco_trophy_fish_hubhugger_gold_item_name",28];
         t[138] = ["$prefabs_placeable_deco_trophy_fish_lava_ancient_basic_item_name",55];
         t[139] = ["$prefabs_placeable_deco_trophy_fish_lava_ancient_silver_item_name",55];
         t[140] = ["$prefabs_placeable_deco_trophy_fish_lava_ancient_gold_item_name",55];
         t[141] = ["$prefabs_placeable_deco_trophy_fish_lava_common_coral_basic_item_name",39];
         t[142] = ["$prefabs_placeable_deco_trophy_fish_lava_common_coral_silver_item_name",39];
         t[143] = ["$prefabs_placeable_deco_trophy_fish_lava_common_coral_gold_item_name",39];
         t[144] = ["$prefabs_placeable_deco_trophy_fish_lava_common_frog_basic_item_name",40];
         t[145] = ["$prefabs_placeable_deco_trophy_fish_lava_common_frog_silver_item_name",40];
         t[146] = ["$prefabs_placeable_deco_trophy_fish_lava_common_frog_gold_item_name",40];
         t[147] = ["$prefabs_placeable_deco_trophy_fish_lava_common_school_tuna_basic_name",42];
         t[148] = ["$prefabs_placeable_deco_trophy_fish_lava_common_school_tuna_silver_name",42];
         t[149] = ["$prefabs_placeable_deco_trophy_fish_lava_common_school_tuna_gold_name",42];
         t[150] = ["$prefabs_placeable_deco_trophy_fish_lava_common_slug_basic_item_name",41];
         t[151] = ["$prefabs_placeable_deco_trophy_fish_lava_common_slug_silver_item_name",41];
         t[152] = ["$prefabs_placeable_deco_trophy_fish_lava_common_slug_gold_item_name",41];
         t[153] = ["$prefabs_placeable_deco_trophy_fish_lava_diamond_basic_item_name",48];
         t[154] = ["$prefabs_placeable_deco_trophy_fish_lava_diamond_silver_item_name",48];
         t[155] = ["$prefabs_placeable_deco_trophy_fish_lava_diamond_gold_item_name",48];
         t[156] = ["$prefabs_placeable_deco_trophy_fish_lava_epic_basic_item_name",34];
         t[157] = ["$prefabs_placeable_deco_trophy_fish_lava_epic_silver_item_name",34];
         t[158] = ["$prefabs_placeable_deco_trophy_fish_lava_epic_gold_item_name",34];
         t[159] = ["$prefabs_placeable_deco_trophy_fish_lava_fireore_basic_item_name",46];
         t[160] = ["$prefabs_placeable_deco_trophy_fish_lava_fireore_silver_item_name",46];
         t[161] = ["$prefabs_placeable_deco_trophy_fish_lava_fireore_gold_item_name",46];
         t[162] = ["$prefabs_placeable_deco_trophy_fish_lava_glass_basic_item_name",49];
         t[163] = ["$prefabs_placeable_deco_trophy_fish_lava_glass_silver_item_name",49];
         t[164] = ["$prefabs_placeable_deco_trophy_fish_lava_glass_gold_item_name",49];
         t[165] = ["$prefabs_placeable_deco_trophy_fish_lava_hubhugger_basic_item_name",57];
         t[166] = ["$prefabs_placeable_deco_trophy_fish_lava_hubhugger_silver_item_name",57];
         t[167] = ["$prefabs_placeable_deco_trophy_fish_lava_hubhugger_gold_item_name",57];
         t[168] = ["$prefabs_placeable_deco_trophy_fish_lava_icefireore_basic_item_name",60];
         t[169] = ["$prefabs_placeable_deco_trophy_fish_lava_icefireore_silver_item_name",60];
         t[170] = ["$prefabs_placeable_deco_trophy_fish_lava_icefireore_gold_item_name",60];
         t[171] = ["$prefabs_placeable_deco_trophy_fish_lava_islefireore_basic_item_name",59];
         t[172] = ["$prefabs_placeable_deco_trophy_fish_lava_islefireore_silver_item_name",59];
         t[173] = ["$prefabs_placeable_deco_trophy_fish_lava_islefireore_gold_item_name",59];
         t[174] = ["$prefabs_placeable_deco_trophy_fish_lava_legendary_basic_item_name",35];
         t[175] = ["$prefabs_placeable_deco_trophy_fish_lava_legendary_silver_item_name",35];
         t[176] = ["$prefabs_placeable_deco_trophy_fish_lava_legendary_gold_item_name",35];
         t[177] = ["$prefabs_placeable_deco_trophy_fish_lava_noobfish_basic_item_name",56];
         t[178] = ["$prefabs_placeable_deco_trophy_fish_lava_noobfish_silver_item_name",56];
         t[179] = ["$prefabs_placeable_deco_trophy_fish_lava_noobfish_gold_item_name",56];
         t[180] = ["$prefabs_placeable_deco_trophy_fish_lava_rare_basic_item_name",33];
         t[181] = ["$prefabs_placeable_deco_trophy_fish_lava_rare_silver_item_name",33];
         t[182] = ["$prefabs_placeable_deco_trophy_fish_lava_rare_gold_item_name",33];
         t[183] = ["$prefabs_placeable_deco_trophy_fish_lava_rare_shark_basic_item_name",61];
         t[184] = ["$prefabs_placeable_deco_trophy_fish_lava_rare_shark_silver_item_name",61];
         t[185] = ["$prefabs_placeable_deco_trophy_fish_lava_rare_shark_gold_item_name",61];
         t[186] = ["$prefabs_placeable_deco_trophy_fish_lava_rare_zebrafish_basic_item_name",62];
         t[187] = ["$prefabs_placeable_deco_trophy_fish_lava_rare_zebrafish_silver_item_name",62];
         t[188] = ["$prefabs_placeable_deco_trophy_fish_lava_rare_zebrafish_gold_item_name",62];
         t[189] = ["$prefabs_placeable_deco_trophy_fish_lava_relic_basic_item_name",36];
         t[190] = ["$prefabs_placeable_deco_trophy_fish_lava_relic_silver_item_name",36];
         t[191] = ["$prefabs_placeable_deco_trophy_fish_lava_relic_gold_item_name",36];
         t[192] = ["$prefabs_placeable_deco_trophy_fish_lava_resplendent_basic_item_name",37];
         t[193] = ["$prefabs_placeable_deco_trophy_fish_lava_resplendent_silver_item_name",37];
         t[194] = ["$prefabs_placeable_deco_trophy_fish_lava_resplendent_gold_item_name",37];
         t[195] = ["$prefabs_placeable_deco_trophy_fish_lava_shadow_basic_item_name",38];
         t[196] = ["$prefabs_placeable_deco_trophy_fish_lava_shadow_silver_item_name",38];
         t[197] = ["$prefabs_placeable_deco_trophy_fish_lava_shadow_gold_item_name",38];
         t[198] = ["$prefabs_placeable_deco_trophy_fish_lava_shardine_basic_item_name",58];
         t[199] = ["$prefabs_placeable_deco_trophy_fish_lava_shardine_silver_item_name",58];
         t[200] = ["$prefabs_placeable_deco_trophy_fish_lava_shardine_gold_item_name",58];
         t[201] = ["$prefabs_placeable_deco_trophy_fish_lava_swordfish_basic_item_name",47];
         t[202] = ["$prefabs_placeable_deco_trophy_fish_lava_swordfish_silver_item_name",47];
         t[203] = ["$prefabs_placeable_deco_trophy_fish_lava_swordfish_gold_item_name",47];
         t[204] = ["$prefabs_placeable_deco_trophy_fish_lava_uncommon_basic_item_name",32];
         t[205] = ["$prefabs_placeable_deco_trophy_fish_lava_uncommon_silver_item_name",32];
         t[206] = ["$prefabs_placeable_deco_trophy_fish_lava_uncommon_gold_item_name",32];
         t[207] = ["$prefabs_placeable_deco_trophy_fish_lava_uncommon_anglerfish_basic_item_name",50];
         t[208] = ["$prefabs_placeable_deco_trophy_fish_lava_uncommon_anglerfish_silver_item_name",50];
         t[209] = ["$prefabs_placeable_deco_trophy_fish_lava_uncommon_anglerfish_gold_item_name",50];
         t[210] = ["$prefabs_placeable_deco_trophy_fish_lava_uncommon_elemental_basic_item_name",51];
         t[211] = ["$prefabs_placeable_deco_trophy_fish_lava_uncommon_elemental_silver_item_name",51];
         t[212] = ["$prefabs_placeable_deco_trophy_fish_lava_uncommon_elemental_gold_item_name",51];
         t[213] = ["$prefabs_placeable_deco_trophy_fish_lava_uncommon_ore_gl_lower_basic_item_name",53];
         t[214] = ["$prefabs_placeable_deco_trophy_fish_lava_uncommon_ore_gl_lower_silver_item_name",53];
         t[215] = ["$prefabs_placeable_deco_trophy_fish_lava_uncommon_ore_gl_lower_gold_item_name",53];
         t[216] = ["$prefabs_placeable_deco_trophy_fish_lava_uncommon_school_carp_basic_name",54];
         t[217] = ["$prefabs_placeable_deco_trophy_fish_lava_uncommon_school_carp_silver_name",54];
         t[218] = ["$prefabs_placeable_deco_trophy_fish_lava_uncommon_school_carp_gold_name",54];
         t[219] = ["$prefabs_placeable_deco_trophy_fish_lava_uncommon_squid_basic_item_name",52];
         t[220] = ["$prefabs_placeable_deco_trophy_fish_lava_uncommon_squid_silver_item_name",52];
         t[221] = ["$prefabs_placeable_deco_trophy_fish_lava_uncommon_squid_gold_item_name",52];
         t[222] = ["$prefabs_placeable_deco_trophy_fish_magic_frogprince_basic_item_name",123];
         t[223] = ["$prefabs_placeable_deco_trophy_fish_magic_frogprince_silver_item_name",123];
         t[224] = ["$prefabs_placeable_deco_trophy_fish_magic_frogprince_gold_item_name",123];
         t[225] = ["$prefabs_placeable_deco_trophy_fish_magic_gryphon_basic_item_name",126];
         t[226] = ["$prefabs_placeable_deco_trophy_fish_magic_gryphon_silver_item_name",126];
         t[227] = ["$prefabs_placeable_deco_trophy_fish_magic_gryphon_gold_item_name",126];
         t[228] = ["$prefabs_placeable_deco_trophy_fish_magic_merqubesly_basic_item_name",127];
         t[229] = ["$prefabs_placeable_deco_trophy_fish_magic_merqubesly_silver_item_name",127];
         t[230] = ["$prefabs_placeable_deco_trophy_fish_magic_merqubesly_gold_item_name",127];
         t[231] = ["$prefabs_placeable_deco_trophy_fish_magic_phoenix_basic_item_name",124];
         t[232] = ["$prefabs_placeable_deco_trophy_fish_magic_phoenix_silver_item_name",124];
         t[233] = ["$prefabs_placeable_deco_trophy_fish_magic_phoenix_gold_item_name",124];
         t[234] = ["$prefabs_placeable_deco_trophy_fish_magic_witchfunnel_basic_item_name",125];
         t[235] = ["$prefabs_placeable_deco_trophy_fish_magic_witchfunnel_silver_item_name",125];
         t[236] = ["$prefabs_placeable_deco_trophy_fish_magic_witchfunnel_gold_item_name",125];
         t[237] = ["$prefabs_placeable_deco_trophy_fish_moonfish_basic_item_name",25];
         t[238] = ["$prefabs_placeable_deco_trophy_fish_moonfish_silver_item_name",25];
         t[239] = ["$prefabs_placeable_deco_trophy_fish_moonfish_gold_item_name",25];
         t[240] = ["$prefabs_placeable_deco_trophy_fish_noobfish_basic_item_name",23];
         t[241] = ["$prefabs_placeable_deco_trophy_fish_noobfish_silver_item_name",23];
         t[242] = ["$prefabs_placeable_deco_trophy_fish_noobfish_gold_item_name",23];
         t[243] = ["$prefabs_placeable_deco_trophy_fish_orefish_formicite_basic_item_name",44];
         t[244] = ["$prefabs_placeable_deco_trophy_fish_orefish_formicite_silver_item_name",44];
         t[245] = ["$prefabs_placeable_deco_trophy_fish_orefish_formicite_gold_item_name",44];
         t[246] = ["$prefabs_placeable_deco_trophy_fish_orefish_infinium_basic_item_name",45];
         t[247] = ["$prefabs_placeable_deco_trophy_fish_orefish_infinium_silver_item_name",45];
         t[248] = ["$prefabs_placeable_deco_trophy_fish_orefish_infinium_gold_item_name",45];
         t[249] = ["$prefabs_placeable_deco_trophy_fish_orefish_shapestone_basic_item_name",43];
         t[250] = ["$prefabs_placeable_deco_trophy_fish_orefish_shapestone_silver_item_name",43];
         t[251] = ["$prefabs_placeable_deco_trophy_fish_orefish_shapestone_gold_item_name",43];
         t[252] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_01_basic_item_name",94];
         t[253] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_01_silver_item_name",94];
         t[254] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_01_gold_item_name",94];
         t[255] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_02_basic_item_name",95];
         t[256] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_02_silver_item_name",95];
         t[257] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_02_gold_item_name",95];
         t[258] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_03_basic_item_name",96];
         t[259] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_03_silver_item_name",96];
         t[260] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_03_gold_item_name",96];
         t[261] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_04_basic_item_name",97];
         t[262] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_04_silver_item_name",97];
         t[263] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_04_gold_item_name",97];
         t[264] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_05_basic_item_name",98];
         t[265] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_05_silver_item_name",98];
         t[266] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_05_gold_item_name",98];
         t[267] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_06_basic_item_name",99];
         t[268] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_06_silver_item_name",99];
         t[269] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_06_gold_item_name",99];
         t[270] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_07_basic_item_name",100];
         t[271] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_07_silver_item_name",100];
         t[272] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_07_gold_item_name",100];
         t[273] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_coral_basic_item_name",101];
         t[274] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_coral_silver_item_name",101];
         t[275] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_coral_gold_item_name",101];
         t[276] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_frog_basic_item_name",102];
         t[277] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_frog_silver_item_name",102];
         t[278] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_frog_gold_item_name",102];
         t[279] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_school_marlin_basic_name",104];
         t[280] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_school_marlin_silver_name",104];
         t[281] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_school_marlin_gold_name",104];
         t[282] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_slug_basic_item_name",103];
         t[283] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_slug_silver_item_name",103];
         t[284] = ["$prefabs_placeable_deco_trophy_fish_plasma_common_slug_gold_item_name",103];
         t[285] = ["$prefabs_placeable_deco_trophy_fish_plasma_rare_01_basic_item_name",114];
         t[286] = ["$prefabs_placeable_deco_trophy_fish_plasma_rare_01_silver_item_name",114];
         t[287] = ["$prefabs_placeable_deco_trophy_fish_plasma_rare_01_gold_item_name",114];
         t[288] = ["$prefabs_placeable_deco_trophy_fish_plasma_rare_02_basic_item_name",115];
         t[289] = ["$prefabs_placeable_deco_trophy_fish_plasma_rare_02_silver_item_name",115];
         t[290] = ["$prefabs_placeable_deco_trophy_fish_plasma_rare_02_gold_item_name",115];
         t[291] = ["$prefabs_placeable_deco_trophy_fish_plasma_rare_03_basic_item_name",116];
         t[292] = ["$prefabs_placeable_deco_trophy_fish_plasma_rare_03_silver_item_name",116];
         t[293] = ["$prefabs_placeable_deco_trophy_fish_plasma_rare_03_gold_item_name",116];
         t[294] = ["$prefabs_placeable_deco_trophy_fish_plasma_rare_04_basic_item_name",117];
         t[295] = ["$prefabs_placeable_deco_trophy_fish_plasma_rare_04_silver_item_name",117];
         t[296] = ["$prefabs_placeable_deco_trophy_fish_plasma_rare_04_gold_item_name",117];
         t[297] = ["$prefabs_placeable_deco_trophy_fish_plasma_rare_05_basic_item_name",118];
         t[298] = ["$prefabs_placeable_deco_trophy_fish_plasma_rare_05_silver_item_name",118];
         t[299] = ["$prefabs_placeable_deco_trophy_fish_plasma_rare_05_gold_item_name",118];
         t[300] = ["$prefabs_placeable_deco_trophy_fish_plasma_rare_shark_basic_item_name",120];
         t[301] = ["$prefabs_placeable_deco_trophy_fish_plasma_rare_shark_silver_item_name",120];
         t[302] = ["$prefabs_placeable_deco_trophy_fish_plasma_rare_shark_gold_item_name",120];
         t[303] = ["$prefabs_placeable_deco_trophy_fish_plasma_rare_zebrafish_basic_item_name",121];
         t[304] = ["$prefabs_placeable_deco_trophy_fish_plasma_rare_zebrafish_silver_item_name",121];
         t[305] = ["$prefabs_placeable_deco_trophy_fish_plasma_rare_zebrafish_gold_item_name",121];
         t[306] = ["$prefabs_placeable_deco_trophy_fish_plasma_swordfish_basic_item_name",119];
         t[307] = ["$prefabs_placeable_deco_trophy_fish_plasma_swordfish_silver_item_name",119];
         t[308] = ["$prefabs_placeable_deco_trophy_fish_plasma_swordfish_gold_item_name",119];
         t[309] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_01_basic_item_name",105];
         t[310] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_01_silver_item_name",105];
         t[311] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_01_gold_item_name",105];
         t[312] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_02_basic_item_name",106];
         t[313] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_02_silver_item_name",106];
         t[314] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_02_gold_item_name",106];
         t[315] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_04_basic_item_name",107];
         t[316] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_04_silver_item_name",107];
         t[317] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_04_gold_item_name",107];
         t[318] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_05_basic_item_name",108];
         t[319] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_05_silver_item_name",108];
         t[320] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_05_gold_item_name",108];
         t[321] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_anglerfish_basic_item_name",109];
         t[322] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_anglerfish_silver_item_name",109];
         t[323] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_anglerfish_gold_item_name",109];
         t[324] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_elemental_basic_item_name",110];
         t[325] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_elemental_silver_item_name",110];
         t[326] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_elemental_gold_item_name",110];
         t[327] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_ore_nitro_glitterine_basic_item_name",112];
         t[328] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_ore_nitro_glitterine_silver_item_name",112];
         t[329] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_ore_nitro_glitterine_gold_item_name",112];
         t[330] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_school_trout_basic_name",113];
         t[331] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_school_trout_silver_name",113];
         t[332] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_school_trout_gold_name",113];
         t[333] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_squid_basic_item_name",111];
         t[334] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_squid_silver_item_name",111];
         t[335] = ["$prefabs_placeable_deco_trophy_fish_plasma_uncommon_squid_gold_item_name",111];
         t[336] = ["$prefabs_placeable_deco_trophy_fish_shardine_radiant_basic_item_name",13];
         t[337] = ["$prefabs_placeable_deco_trophy_fish_shardine_radiant_silver_item_name",13];
         t[338] = ["$prefabs_placeable_deco_trophy_fish_shardine_radiant_gold_item_name",13];
         t[339] = ["$prefabs_placeable_deco_trophy_fish_sunfish_basic_item_name",24];
         t[340] = ["$prefabs_placeable_deco_trophy_fish_sunfish_silver_item_name",24];
         t[341] = ["$prefabs_placeable_deco_trophy_fish_sunfish_gold_item_name",24];
         t[342] = ["$prefabs_placeable_deco_trophy_fish_swordfish_basic_item_name",12];
         t[343] = ["$prefabs_placeable_deco_trophy_fish_swordfish_silver_item_name",12];
         t[344] = ["$prefabs_placeable_deco_trophy_fish_swordfish_gold_item_name",12];
         t[345] = ["$prefabs_placeable_deco_trophy_fish_undead_ghostfish_basic_item_name",26];
         t[346] = ["$prefabs_placeable_deco_trophy_fish_undead_ghostfish_silver_item_name",26];
         t[347] = ["$prefabs_placeable_deco_trophy_fish_undead_ghostfish_gold_item_name",26];
         t[348] = ["$prefabs_placeable_deco_trophy_fish_water_ancient_basic_item_name",22];
         t[349] = ["$prefabs_placeable_deco_trophy_fish_water_ancient_silver_item_name",22];
         t[350] = ["$prefabs_placeable_deco_trophy_fish_water_ancient_gold_item_name",22];
         t[351] = ["$prefabs_placeable_deco_trophy_fish_water_common_coral_basic_item_name",7];
         t[352] = ["$prefabs_placeable_deco_trophy_fish_water_common_coral_silver_item_name",7];
         t[353] = ["$prefabs_placeable_deco_trophy_fish_water_common_coral_gold_item_name",7];
         t[354] = ["$prefabs_placeable_deco_trophy_fish_water_common_frog_basic_item_name",8];
         t[355] = ["$prefabs_placeable_deco_trophy_fish_water_common_frog_silver_item_name",8];
         t[356] = ["$prefabs_placeable_deco_trophy_fish_water_common_frog_gold_item_name",8];
         t[357] = ["$prefabs_placeable_deco_trophy_fish_water_common_maxuber_abyssalangler_basic_item_name",138];
         t[358] = ["$prefabs_placeable_deco_trophy_fish_water_common_maxuber_abyssalangler_silver_item_name",138];
         t[359] = ["$prefabs_placeable_deco_trophy_fish_water_common_maxuber_abyssalangler_gold_item_name",138];
         t[360] = ["$prefabs_placeable_deco_trophy_fish_water_common_maxuber_abyssalcrustacean_basic_item_name",139];
         t[361] = ["$prefabs_placeable_deco_trophy_fish_water_common_maxuber_abyssalcrustacean_silver_item_name",139];
         t[362] = ["$prefabs_placeable_deco_trophy_fish_water_common_maxuber_abyssalcrustacean_gold_item_name",139];
         t[363] = ["$prefabs_placeable_deco_trophy_fish_water_common_maxuber_pyricflyfish_basic_item_name",140];
         t[364] = ["$prefabs_placeable_deco_trophy_fish_water_common_maxuber_pyricflyfish_silver_item_name",140];
         t[365] = ["$prefabs_placeable_deco_trophy_fish_water_common_maxuber_pyricflyfish_gold_item_name",140];
         t[366] = ["$prefabs_placeable_deco_trophy_fish_water_common_maxuber_pyrickraken_basic_item_name",141];
         t[367] = ["$prefabs_placeable_deco_trophy_fish_water_common_maxuber_pyrickraken_silver_item_name",141];
         t[368] = ["$prefabs_placeable_deco_trophy_fish_water_common_maxuber_pyrickraken_gold_item_name",141];
         t[369] = ["$prefabs_placeable_deco_trophy_fish_water_common_maxuber_zephyrangler_basic_item_name",142];
         t[370] = ["$prefabs_placeable_deco_trophy_fish_water_common_maxuber_zephyrangler_silver_item_name",142];
         t[371] = ["$prefabs_placeable_deco_trophy_fish_water_common_maxuber_zephyrangler_gold_item_name",142];
         t[372] = ["$prefabs_placeable_deco_trophy_fish_water_common_maxuber_zephyrnautiloid_basic_item_name",143];
         t[373] = ["$prefabs_placeable_deco_trophy_fish_water_common_maxuber_zephyrnautiloid_silver_item_name",143];
         t[374] = ["$prefabs_placeable_deco_trophy_fish_water_common_maxuber_zephyrnautiloid_gold_item_name",143];
         t[375] = ["$prefabs_placeable_deco_trophy_fish_water_common_school_eel_basic_name",10];
         t[376] = ["$prefabs_placeable_deco_trophy_fish_water_common_school_eel_silver_name",10];
         t[377] = ["$prefabs_placeable_deco_trophy_fish_water_common_school_eel_gold_name",10];
         t[378] = ["$prefabs_placeable_deco_trophy_fish_water_common_slug_basic_item_name",9];
         t[379] = ["$prefabs_placeable_deco_trophy_fish_water_common_slug_silver_item_name",9];
         t[380] = ["$prefabs_placeable_deco_trophy_fish_water_common_slug_gold_item_name",9];
         t[381] = ["$prefabs_placeable_deco_trophy_fish_water_epic_basic_item_name",2];
         t[382] = ["$prefabs_placeable_deco_trophy_fish_water_epic_silver_item_name",2];
         t[383] = ["$prefabs_placeable_deco_trophy_fish_water_epic_gold_item_name",2];
         t[384] = ["$prefabs_placeable_deco_trophy_fish_water_fae_basic_item_name",14];
         t[385] = ["$prefabs_placeable_deco_trophy_fish_water_fae_silver_item_name",14];
         t[386] = ["$prefabs_placeable_deco_trophy_fish_water_fae_gold_item_name",14];
         t[387] = ["$prefabs_placeable_deco_trophy_fish_water_iceore_basic_item_name",15];
         t[388] = ["$prefabs_placeable_deco_trophy_fish_water_iceore_silver_item_name",15];
         t[389] = ["$prefabs_placeable_deco_trophy_fish_water_iceore_gold_item_name",15];
         t[390] = ["$prefabs_placeable_deco_trophy_fish_water_legendary_basic_item_name",3];
         t[391] = ["$prefabs_placeable_deco_trophy_fish_water_legendary_silver_item_name",3];
         t[392] = ["$prefabs_placeable_deco_trophy_fish_water_legendary_gold_item_name",3];
         t[393] = ["$prefabs_placeable_deco_trophy_fish_water_rare_basic_item_name",1];
         t[394] = ["$prefabs_placeable_deco_trophy_fish_water_rare_silver_item_name",1];
         t[395] = ["$prefabs_placeable_deco_trophy_fish_water_rare_gold_item_name",1];
         t[396] = ["$prefabs_placeable_deco_trophy_fish_water_rare_maxuber_abyssalsquid_basic_item_name",150];
         t[397] = ["$prefabs_placeable_deco_trophy_fish_water_rare_maxuber_abyssalsquid_silver_item_name",150];
         t[398] = ["$prefabs_placeable_deco_trophy_fish_water_rare_maxuber_abyssalsquid_gold_item_name",150];
         t[399] = ["$prefabs_placeable_deco_trophy_fish_water_rare_maxuber_kraken_basic_item_name",151];
         t[400] = ["$prefabs_placeable_deco_trophy_fish_water_rare_maxuber_kraken_silver_item_name",151];
         t[401] = ["$prefabs_placeable_deco_trophy_fish_water_rare_maxuber_kraken_gold_item_name",151];
         t[402] = ["$prefabs_placeable_deco_trophy_fish_water_rare_maxuber_pyricjellyfish_basic_item_name",152];
         t[403] = ["$prefabs_placeable_deco_trophy_fish_water_rare_maxuber_pyricjellyfish_silver_item_name",152];
         t[404] = ["$prefabs_placeable_deco_trophy_fish_water_rare_maxuber_pyricjellyfish_gold_item_name",152];
         t[405] = ["$prefabs_placeable_deco_trophy_fish_water_rare_maxuber_zephyrmanta_basic_item_name",153];
         t[406] = ["$prefabs_placeable_deco_trophy_fish_water_rare_maxuber_zephyrmanta_silver_item_name",153];
         t[407] = ["$prefabs_placeable_deco_trophy_fish_water_rare_maxuber_zephyrmanta_gold_item_name",153];
         t[408] = ["$prefabs_placeable_deco_trophy_fish_water_rare_shark_basic_item_name",30];
         t[409] = ["$prefabs_placeable_deco_trophy_fish_water_rare_shark_silver_item_name",30];
         t[410] = ["$prefabs_placeable_deco_trophy_fish_water_rare_shark_gold_item_name",30];
         t[411] = ["$prefabs_placeable_deco_trophy_fish_water_rare_zebrafish_basic_item_name",31];
         t[412] = ["$prefabs_placeable_deco_trophy_fish_water_rare_zebrafish_silver_item_name",31];
         t[413] = ["$prefabs_placeable_deco_trophy_fish_water_rare_zebrafish_gold_item_name",31];
         t[414] = ["$prefabs_placeable_deco_trophy_fish_water_relic_basic_item_name",4];
         t[415] = ["$prefabs_placeable_deco_trophy_fish_water_relic_silver_item_name",4];
         t[416] = ["$prefabs_placeable_deco_trophy_fish_water_relic_gold_item_name",4];
         t[417] = ["$prefabs_placeable_deco_trophy_fish_water_resplendent_basic_item_name",5];
         t[418] = ["$prefabs_placeable_deco_trophy_fish_water_resplendent_silver_item_name",5];
         t[419] = ["$prefabs_placeable_deco_trophy_fish_water_resplendent_gold_item_name",5];
         t[420] = ["$prefabs_placeable_deco_trophy_fish_water_school_basic_item_name",16];
         t[421] = ["$prefabs_placeable_deco_trophy_fish_water_school_silver_item_name",16];
         t[422] = ["$prefabs_placeable_deco_trophy_fish_water_school_gold_item_name",16];
         t[423] = ["$prefabs_placeable_deco_trophy_fish_water_shadow_basic_item_name",6];
         t[424] = ["$prefabs_placeable_deco_trophy_fish_water_shadow_silver_item_name",6];
         t[425] = ["$prefabs_placeable_deco_trophy_fish_water_shadow_gold_item_name",6];
         t[426] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_basic_item_name",0];
         t[427] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_silver_item_name",0];
         t[428] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_gold_item_name",0];
         t[429] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_anglerfish_basic_item_name",17];
         t[430] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_anglerfish_silver_item_name",17];
         t[431] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_anglerfish_gold_item_name",17];
         t[432] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_elemental_basic_item_name",18];
         t[433] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_elemental_silver_item_name",18];
         t[434] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_elemental_gold_item_name",18];
         t[435] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_maxuber_abyssalhippocampus_basic_item_name",144];
         t[436] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_maxuber_abyssalhippocampus_silver_item_name",144];
         t[437] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_maxuber_abyssalhippocampus_gold_item_name",144];
         t[438] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_maxuber_deepstone_basic_item_name",145];
         t[439] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_maxuber_deepstone_silver_item_name",145];
         t[440] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_maxuber_deepstone_gold_item_name",145];
         t[441] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_maxuber_lichenstone_basic_item_name",146];
         t[442] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_maxuber_lichenstone_silver_item_name",146];
         t[443] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_maxuber_lichenstone_gold_item_name",146];
         t[444] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_maxuber_pyricpuffer_basic_item_name",147];
         t[445] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_maxuber_pyricpuffer_silver_item_name",147];
         t[446] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_maxuber_pyricpuffer_gold_item_name",147];
         t[447] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_maxuber_runeslate_basic_item_name",148];
         t[448] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_maxuber_runeslate_silver_item_name",148];
         t[449] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_maxuber_runeslate_gold_item_name",148];
         t[450] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_maxuber_zephyrclam_basic_item_name",149];
         t[451] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_maxuber_zephyrclam_silver_item_name",149];
         t[452] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_maxuber_zephyrclam_gold_item_name",149];
         t[453] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_ore_gl_upper_basic_item_name",20];
         t[454] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_ore_gl_upper_silver_item_name",20];
         t[455] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_ore_gl_upper_gold_item_name",20];
         t[456] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_school_deepwater_basic_name",21];
         t[457] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_school_deepwater_silver_name",21];
         t[458] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_school_deepwater_gold_name",21];
         t[459] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_squid_basic_item_name",19];
         t[460] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_squid_silver_item_name",19];
         t[461] = ["$prefabs_placeable_deco_trophy_fish_water_uncommon_squid_gold_item_name",19];
      }

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
         var row:Array = null;
         var fish:Fish = null;
         var found:int = 0;
         for each(row in TABLE)
         {
            fish = new Fish();
            fish.key = row[0];
            fish.rarity = row[1];
            fish.weight = row[2];
            fish.liquid = LIQUID[row[3]];
            fish.pool = POOL[row[4]];
            fish.pole = POLE[row[5]];
            fish.aged = row[6];
            fish.hint = row[7];
            fish.note = row[8];
            made.push(fish);
            found += put(out,fish.key,fish);
         }
         for each(row in MOUNTED)
         {
            put(out,row[0],made[row[1]] as Fish);
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
