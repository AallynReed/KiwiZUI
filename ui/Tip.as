package ui
{
   import flash.display.DisplayObject;
   import flash.external.ExternalInterface;
   import flash.geom.Point;

   public class Tip
   {

      private static const GAP:int = 5;

      private static const WIDEST:int = 450;

      public function Tip()
      {
         super();
      }

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
