package ui
{
   import flash.display.DisplayObject;
   import flash.geom.Point;

   /** Where a tooltip goes when the window that asked for it has to stay readable.
    *
    *  The engine grows a tooltip right and down from the anchor it is handed and only
    *  turns it around at the edge of the surface. It knows the surface and knows nothing
    *  about our window, so an anchor taken anywhere on one - on the item, or on the
    *  window's own left edge the way vanilla's console path does it - opens the tooltip
    *  straight across the list and the controls beside it.
    *
    *  So the anchor goes outside the window entirely, into whichever gap beside it is
    *  wider, at the height of the thing being described.
    *
    *  To the right that is exact: the tooltip grows away from the window from the point
    *  it is given. To the left it cannot be, because how wide the tooltip will be is
    *  settled by the engine after it has the text. So a width is reserved, and which
    *  one to reserve is the whole of this class.
    *
    *  `tooltip.swf` sizes its panel to `max(nameTextField.x + nameTextField.width +
    *  padding, minWidth)` and ships `minWidth` at 450. Only the *name* can widen it -
    *  the body lines are laid out inside a panel already sized - so all but a very long
    *  name comes out at exactly the floor, and the floor is what is reserved.
    *
    *  Reserving the widest it can get instead - 658, the same formula with the name at
    *  its `DEFAULT_MAX_WIDTH` cap - is what opened tooltips two hundred pixels clear of
    *  the window with nothing in between. That is the trade, and it is deliberate: every
    *  ordinary tooltip now sits against the edge, and a name long enough to beat 450
    *  covers a strip of the window by however much it beat it by.
    *
    *  Everything is measured through the host's own transform, so the reserve is in the
    *  same scaled pixels the engine will draw the tooltip in. */
   public class Tip
   {

      private static const GAP:int = 5;

      /** tooltip.swf's own `_minWidth`, which is what its panel comes out at unless a
       *  long name pushes it wider. */
      private static const WIDEST:int = 450;

      public function Tip()
      {
         super();
      }

      public static function beside(host:DisplayObject, w:Number, y:Number) : Point
      {
         var near:Point = host.localToGlobal(new Point(0,y));
         var far:Point = host.localToGlobal(new Point(w,y));
         var scale:Number = (far.x - near.x) / w;
         var right:Number = host.stage == null ? near.x : host.stage.stageWidth - far.x;
         if(right >= near.x)
         {
            return new Point(far.x + GAP * scale,near.y);
         }
         return new Point(Math.max(GAP * scale,near.x - (GAP + WIDEST) * scale),near.y);
      }
   }
}
