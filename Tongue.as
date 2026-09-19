package
{
   import flash.external.ExternalInterface;

   public class Tongue
   {

      public static const LOCALES:Array = ["en","zh"];

      public static const NAMES:Array = ["English","Zhongwen"];

      private static var known:int = -1;

      public function Tongue()
      {
         super();
      }

      public static function get at() : int
      {
         return known >= 0 ? known : resolve();
      }

      private static function resolve() : int
      {
         var told:* = null;
         if(!IggyFunctions.inIggy)
         {
            return known = 0;
         }
         told = ExternalInterface.call("GetLocale");
         if(told != null && String(told).length > 0)
         {
            return known = Math.max(0,LOCALES.indexOf(String(told).toLowerCase().substr(0,2)));
         }
         told = IggyFunctions.translate("$LanguageName");
         if(told != null && String(told).length > 0 && String(told).charAt(0) != "$")
         {
            return known = Math.max(0,NAMES.indexOf(String(told)));
         }
         return 0;
      }
   }
}
