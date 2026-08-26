package ui
{
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Point;
   
   public class SlotDragDropHelper
   {
      
      private static var currentDragStart:Point;
      
      private static const DragStartDelta:Number = 15;
      
      private static var dragSource:DisplayObject = null;
      
      private static var sourceSlotId:Object = -1;
      
      private static var textureName:String = "";

      
      public function SlotDragDropHelper()
      {
         super();
      }
      
      public static function startDrag(param1:DisplayObject, param2:Number, param3:Number, param4:Object, param5:String) : void
      {
         stopWatchingMouse();
         currentDragStart = new Point(param2,param3);
         dragSource = param1;
         sourceSlotId = param4;
         textureName = param5;
         param1.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
         param1.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
         param1.addEventListener(MouseEvent.ROLL_OUT,onRollOut);
      }
      
      public static function registerDropCallback(param1:Function) : void
      {
         ExternalInterface.addCallback("DRAGHOST.DROP",param1);
      }
      
      private static function onMouseMove(param1:MouseEvent) : void
      {
         var _loc2_:Number = new Point(param1.stageX - currentDragStart.x,param1.stageY - currentDragStart.y).length;
         if(_loc2_ >= DragStartDelta)
         {
            internalStartDrag(param1.stageX,param1.stageY);
         }
      }
      
      private static function onMouseUp(param1:MouseEvent) : void
      {
         stopWatchingMouse();
      }
      
      private static function onRollOut(param1:MouseEvent) : void
      {
         internalStartDrag(param1.stageX,param1.stageY);
      }
      
      public static var dragStarted:Function = null;

      private static function internalStartDrag(param1:Number, param2:Number) : void
      {
         ExternalInterface.call("SLOT.DRAG_START",sourceSlotId,param1,param2,textureName);
         stopWatchingMouse();
         if(dragStarted != null)
         {
            dragStarted();
         }
      }
      
      private static function stopWatchingMouse() : void
      {
         if(dragSource)
         {
            dragSource.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
            dragSource.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
            dragSource.removeEventListener(MouseEvent.ROLL_OUT,onRollOut);
            dragSource = null;
            sourceSlotId = -1;
         }
      }
   }
}
