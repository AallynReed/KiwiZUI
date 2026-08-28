package ui
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Point;

   public class Layer
   {

      private static var frameW:int = 0;

      private static var frameH:int = 0;

      private static var frameX:int = 0;

      private static var frameY:int = 0;

      private static const REACH:int = 8192;

      private static const DIM:Number = 0.5;

      public static var dim:Boolean = false;

      private static var sheet:Sprite;

      private static var showing:Sprite;

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

      public static function get roomWide() : int
      {
         return frameW;
      }

      public static function get roomHigh() : int
      {
         return frameH;
      }

      public static function get open() : Boolean
      {
         return showing != null;
      }

      public static function shows(popup:Sprite) : Boolean
      {
         return showing == popup;
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

      public static function middle(popup:Sprite, anchor:DisplayObject, w:int, h:int) : void
      {
         var was:Boolean = dim;
         dim = true;
         show(popup,anchor,0,0);
         dim = was;
         if(showing != popup || frameW <= 0 || frameH <= 0)
         {
            return;
         }
         popup.x = frameX + Math.max(0,(frameW - w) / 2);
         popup.y = frameY + Math.max(0,(frameH - h) / 2);
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
