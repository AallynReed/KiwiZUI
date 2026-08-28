package ui
{
   import flash.display.Shape;
   import flash.display.Sprite;

   public class Reach extends Sprite
   {

      private static const OUT:int = 1200;

      private var pad:Shape = new Shape();

      public function Reach()
      {
         super();
         addChild(this.pad);
      }

      public function hold(host:Sprite, w:Number, h:Number) : void
      {
         if(this.parent == host)
         {
            return;
         }
         this.pad.graphics.clear();
         renderer.fill(this.pad,-OUT,-OUT,w + OUT * 2,h + OUT * 2,renderer.BLACK,0);
         host.addChild(this);
      }

      public function drop() : void
      {
         if(this.parent != null)
         {
            this.parent.removeChild(this);
         }
      }
   }
}
