package ui
{
   import flash.display.DisplayObject;
   import flash.geom.Point;

   /** Which control in a strip a point is on.
    *
    *  Never from `width` and `height`. Iggy measures a sprite by its children, so a
    *  control whose caption is empty measures zero however much of itself it drew - and
    *  one it measures as zero does not merely miss its own presses, it takes the presses
    *  of everything beside it. That is what puts a whole strip of buttons behind the last
    *  one added to it. Where a control was put and the size it was built at are both
    *  ours, so the rectangle is ours.
    *
    *  The container asks: one CLICK listener of its own for the press, and the frame tick
    *  for the hover, so the lit button and the pressed button cannot disagree. A control
    *  never answers for itself - `driven` is how it is told to ignore its own roll events
    *  - and it keeps its mouse either way, because taking the mouse off a control stops
    *  clicks reaching anything at all. */
   public class Hit
   {

      public function Hit()
      {
         super();
      }

      public static function holds(kid:DisplayObject, w:Number, h:Number, at:Point) : Boolean
      {
         return kid != null && kid.visible && at != null
             && at.x >= kid.x && at.x < kid.x + w
             && at.y >= kid.y && at.y < kid.y + h;
      }

      /** The chip under the point, or null. Every chip carries the size it was built at,
       *  so a strip needs nothing from its container but the point. */
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

      /** The same rectangles, lighting whichever one the pointer is on and clearing the
       *  rest, and answering which that was. A null point is the pointer somewhere else
       *  entirely. */
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
