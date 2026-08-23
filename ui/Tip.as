package ui
{
   import flash.display.DisplayObject;
   import flash.external.ExternalInterface;
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

      /** `at` is where in the window the thing being described sits, and a caller that
       *  knows it should say: the side it is nearest is the side the tooltip should open
       *  on, so a hover on the right edge does not send a tooltip across to the left of
       *  the window to be read. The near side only wins if it has room for one; the wider
       *  gap is still better than a tooltip half off the surface. */
      /** Opens the game's tooltip beside the window, and answers whether it opened - so a
       *  caller knows whether it has one to close and never hides a tooltip it did not
       *  put up.
       *
       *  `spot` is where the thing being described sits in the host's own coordinates,
       *  and the caller is what works that out. A row cannot answer it for itself: under
       *  a `scrollRect` Iggy does not fold the scroll into the transform, so the row's own
       *  `localToGlobal` is where it would have been with the list at the top. Add the
       *  offsets up instead - they are all ours. */
      public static function open(host:DisplayObject, w:Number, spot:Point,
                                  title:String, body:String) : Boolean
      {
         var top:Point = null;
         if(host == null || spot == null || body == null || body.length == 0
            || !IggyFunctions.inIggy)
         {
            return false;
         }
         top = beside(host,w,spot.y,spot.x);
         ExternalInterface.call("TOOLTIP.SHOW",top.x,top.y,title,body);
         return true;
      }

      public static function hide() : void
      {
         if(IggyFunctions.inIggy)
         {
            ExternalInterface.call("TOOLTIP.HIDE");
         }
      }

      public static function beside(host:DisplayObject, w:Number, y:Number, at:Number = -1) : Point
      {
         var near:Point = host.localToGlobal(new Point(0,y));
         var far:Point = host.localToGlobal(new Point(w,y));
         var scale:Number = (far.x - near.x) / w;
         var right:Number = host.stage == null ? near.x : host.stage.stageWidth - far.x;
         var room:Number = (GAP + WIDEST) * scale;
         var toRight:Boolean = right >= near.x;
         if(at >= 0 && (at * 2 >= w ? right : near.x) >= room)
         {
            toRight = at * 2 >= w;
         }
         if(toRight)
         {
            return new Point(far.x + GAP * scale,near.y);
         }
         return new Point(Math.max(GAP * scale,near.x - (GAP + WIDEST) * scale),near.y);
      }
   }
}
