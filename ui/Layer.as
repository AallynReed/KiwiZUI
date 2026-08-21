package ui
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;

   /** A dropdown has to draw over everything, and a control sits far too deep in the
    *  tree to manage that from where it is: siblings added after it cover it, and the
    *  panel it lives in clips it. So the list is lifted to the screen root, placed at
    *  the control's own position on screen, and put over an invisible sheet that
    *  closes it wherever else the next click lands.
    *
    *  One popup at a time, which is what a dropdown means, and the control learns it
    *  was closed from REMOVED_FROM_STAGE rather than from a callback registered here. */
   public class Layer
   {

      /** How big the screen this popup belongs to actually is, in the root's own
       *  coordinates. Nothing here asks the stage for it: inside Iggy the stage is the
       *  whole game surface and not the mod's window, so a popup pulled back inside
       *  *that* rectangle lands somewhere off the window entirely - which is exactly
       *  what a colour picker did, six hundred pixels away and over another screen.
       *
       *  The screen is the only thing that knows its own size, so the screen says. A
       *  frame nobody sets means no clamping, which puts a popup slightly off an edge
       *  at worst and never across the room. */
      private static var frameW:int = 0;

      private static var frameH:int = 0;

      /** How far the dismiss sheet reaches. Drawn from well outside the window in
       *  every direction so it catches the next click wherever it lands, whatever
       *  transform the engine has the root under. */
      private static const REACH:int = 8192;

      private static var sheet:Sprite;

      private static var showing:Sprite;

      public function Layer()
      {
         super();
      }

      public static function frame(w:int, h:int) : void
      {
         frameW = w;
         frameH = h;
      }

      public static function get open() : Boolean
      {
         return showing != null;
      }

      public static function show(popup:Sprite, anchor:DisplayObject, x:Number, y:Number) : void
      {
         var top:Sprite = anchor.root as Sprite;
         if(top == null)
         {
            return;
         }
         hide();
         if(sheet == null)
         {
            sheet = new Sprite();
            sheet.addEventListener(MouseEvent.CLICK,onDismiss);
         }
         sheet.graphics.clear();
         renderer.fill(sheet,-REACH,-REACH,REACH * 2,REACH * 2,renderer.BLACK,0);
         top.addChild(sheet);

         var at:Point = top.globalToLocal(anchor.localToGlobal(new Point(x,y)));
         popup.x = at.x;
         popup.y = at.y;
         top.addChild(popup);
         showing = popup;
         clamp(popup);
      }

      /** Placed under the control, then pulled back inside the screen when there is
       *  not enough room below or to the right - a list that runs off the edge is a
       *  list with choices that cannot be picked.
       *
       *  Both directions, and in the root's own coordinates: the popup is a child of
       *  the root, so nothing outside it has any bearing on where it may sit. A popup
       *  larger than the frame is put in the corner rather than pushed negative. */
      private static function clamp(popup:Sprite) : void
      {
         if(frameW <= 0 || frameH <= 0)
         {
            return;
         }
         popup.x = Config.clamp(popup.x,0,Math.max(0,frameW - popup.width),popup.x);
         popup.y = Config.clamp(popup.y,0,Math.max(0,frameH - popup.height),popup.y);
      }

      public static function hide() : void
      {
         if(showing != null && showing.parent != null)
         {
            showing.parent.removeChild(showing);
         }
         showing = null;
         if(sheet != null && sheet.parent != null)
         {
            sheet.parent.removeChild(sheet);
         }
      }

      private static function onDismiss(e:MouseEvent) : void
      {
         hide();
      }
   }
}
