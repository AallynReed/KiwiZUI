package ui
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.geom.Point;

   public class Hit
   {

      public function Hit()
      {
         super();
      }

      public static function show(host:DisplayObjectContainer, kid:DisplayObject,
                                  on:Boolean) : void
      {
         kid.visible = on;
         if(!on)
         {
            if(kid.parent != null)
            {
               kid.parent.removeChild(kid);
            }
         }
         else if(kid.parent != host)
         {
            host.addChild(kid);
         }
      }

      public static function blind(kid:InteractiveObject) : InteractiveObject
      {
         IggyFunctions.setHittestProperties(kid,IggyFunctions.HITTEST_NO_MOUSE
                                          | IggyFunctions.HITTEST_NO_GET_OBJECTS_UNDER_POINT
                                          | IggyFunctions.HITTEST_NO_IGGY_GET_OBJECTS_UNDER_POINT);
         return kid;
      }

      public static function holds(kid:DisplayObject, w:Number, h:Number, at:Point) : Boolean
      {
         return kid != null && kid.visible && at != null
             && at.x >= kid.x && at.x < kid.x + w
             && at.y >= kid.y && at.y < kid.y + h;
      }

      public static function chip(strip:Array, at:Point) : Chip
      {
         var i:int = 0;
         var one:Chip = null;
         while(i < strip.length)
         {
            one = strip[i] as Chip;
            if(one != null && holds(one,one.w,one.h,at))
            {
               return one;
            }
            i++;
         }
         return null;
      }

      public static function light(strip:Array, at:Point) : Chip
      {
         var i:int = 0;
         var one:Chip = null;
         var over:Chip = chip(strip,at);
         while(i < strip.length)
         {
            one = strip[i] as Chip;
            if(one != null)
            {
               one.hovered = one == over;
            }
            i++;
         }
         return over;
      }
   }
}
