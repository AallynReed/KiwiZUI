package ui
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Point;

   /** A dropdown has to draw over everything, and a control sits far too deep in the
    *  tree to manage that from where it is: siblings added after it cover it, and the
    *  panel it lives in clips it. So the list is lifted to the screen root, placed at
    *  the control's own position on screen, and closed wherever else the next press
    *  lands.
    *
    *  **The press is watched, not blocked.** A sheet over the screen closes the popup
    *  and eats the click that closed it, so opening a second dropdown cost two clicks:
    *  one to dismiss the first, one the second could actually see. Listening for the
    *  press on the stage instead leaves the click to reach whatever it was aimed at,
    *  which is what makes moving from one dropdown to the next a single click.
    *
    *  A press inside the popup is left alone, being a choice made rather than a
    *  dismissal. Every other press closes it, including one on the control it opened
    *  off - which would then reopen it from its own click, so `shut` hands that
    *  control the one thing it cannot see for itself: that the press it is answering
    *  is the press that just took its popup away.
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

      private static var frameX:int = 0;

      private static var frameY:int = 0;

      /** How far the scrim reaches. Drawn from well outside the window in every
       *  direction so it catches the next click wherever it lands, whatever transform
       *  the engine has the root under. */
      private static const REACH:int = 8192;

      /** How far the scrim knocks the screen back, for a screen that asks for one. */
      private static const DIM:Number = 0.5;

      /** Whether the popup is a modal: a sheet over the screen that dims it and takes
       *  the click that dismisses it.
       *
       *  **The screen itself is never touched.** A filter or an alpha set on the screen
       *  is set on the popup with it - in game the screen is the root and the popup is
       *  its child - and blurring live text turns the whole window to mush for the sake
       *  of a panel sitting in one corner of it. The sheet is already between the two,
       *  so the knock-back is painted there and the popup, added over it, stays clean.
       *
       *  Off by default: a dropdown opening off a control is not a modal, has no
       *  business darkening the screen behind it, and must not swallow the click that
       *  moves the player on to the next control. */
      public static var dim:Boolean = false;

      private static var sheet:Sprite;

      private static var showing:Sprite;

      /** What the popup opened off, so the press that closes it can be told apart from
       *  a press anywhere else. */
      private static var owner:DisplayObject;

      private static var tossed:DisplayObject;

      private static var watching:IEventDispatcher;

      public function Layer()
      {
         super();
      }

      public static function frame(w:int, h:int, x:int = 0, y:int = 0) : void
      {
         frameW = w;
         frameH = h;
         frameX = x;
         frameY = y;
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
         if(dim)
         {
            scrim(top);
         }
         else
         {
            watch(top.stage);
         }

         var at:Point = top.globalToLocal(anchor.localToGlobal(new Point(x,y)));
         popup.x = at.x;
         popup.y = at.y;
         top.addChild(popup);
         showing = popup;
         owner = anchor;
         clamp(popup);
      }

      private static function scrim(top:Sprite) : void
      {
         if(sheet == null)
         {
            sheet = new Sprite();
            sheet.addEventListener(MouseEvent.CLICK,onDismiss);
         }
         sheet.graphics.clear();
         renderer.fill(sheet,-REACH,-REACH,REACH * 2,REACH * 2,renderer.BLACK,0);
         if(frameW > 0 && frameH > 0)
         {
            renderer.fill(sheet,frameX,frameY,frameW,frameH,renderer.BLACK,DIM);
         }
         top.addChild(sheet);
      }

      /** The stage rather than the root, because bubbling ends there and a press on
       *  nothing at all is the stage's own. The wheel counts as a press: the popup is
       *  a child of the root and the list it came from is not, so a scroll that moved
       *  one and not the other would leave the popup standing over the wrong row. */
      private static function watch(host:IEventDispatcher) : void
      {
         if(host == null)
         {
            return;
         }
         watching = host;
         watching.addEventListener(MouseEvent.MOUSE_DOWN,onOutside);
         watching.addEventListener(MouseEvent.MOUSE_WHEEL,onOutside);
      }

      private static function onOutside(e:MouseEvent) : void
      {
         var hit:DisplayObject = e.target as DisplayObject;
         tossed = null;
         if(within(showing,hit))
         {
            return;
         }
         tossed = within(owner,hit) ? owner : null;
         hide();
      }

      /** True once, for whatever the popup opened off, when the press still being
       *  delivered is the one that closed it. A control asks this from its click and
       *  reads the answer as its own toggle: it opens the popup, so a click that
       *  followed the press that dismissed it would open it straight back. */
      public static function shut(who:DisplayObject) : Boolean
      {
         var was:Boolean = who != null && who == tossed;
         tossed = null;
         return was;
      }

      private static function within(of:DisplayObject, hit:DisplayObject) : Boolean
      {
         var box:DisplayObjectContainer = of as DisplayObjectContainer;
         return of == hit || box != null && hit != null && box.contains(hit);
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
         popup.x = Config.clamp(popup.x,frameX,frameX + Math.max(0,frameW - popup.width),
                                popup.x);
         popup.y = Config.clamp(popup.y,frameY,frameY + Math.max(0,frameH - popup.height),
                                popup.y);
      }

      public static function hide() : void
      {
         if(showing != null && showing.parent != null)
         {
            showing.parent.removeChild(showing);
         }
         showing = null;
         owner = null;
         if(sheet != null && sheet.parent != null)
         {
            sheet.parent.removeChild(sheet);
         }
         if(watching != null)
         {
            watching.removeEventListener(MouseEvent.MOUSE_DOWN,onOutside);
            watching.removeEventListener(MouseEvent.MOUSE_WHEEL,onOutside);
            watching = null;
         }
      }

      private static function onDismiss(e:MouseEvent) : void
      {
         hide();
      }
   }
}
