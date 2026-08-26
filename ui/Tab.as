package ui
{
   import flash.display.Shape;
   import flash.display.Sprite;

   public class Tab extends Sprite
   {

      public static const W:int = 24;

      public static const H:int = 50;

      private static const LIT:Number = 0.06;

      private var box:Shape = new Shape();

      private var face:Shape = new Shape();

      private var mark:int = -1;

      private var current:Boolean = false;

      public function Tab(mark:int = -1)
      {
         super();
         mouseChildren = false;
         addChild(this.box);
         addChild(this.face);
         this.mark = mark;
         this.face.x = (W - MARK) >> 1;
         this.face.y = (H - MARK) >> 1;
         this.paint();
      }

      private static const MARK:int = 16;

      public function get selected() : Boolean
      {
         return this.current;
      }

      public function set selected(on:Boolean) : void
      {
         if(this.current != on)
         {
            this.current = on;
            this.paint();
         }
      }

      public function paint() : void
      {
         this.box.graphics.clear();
         renderer.framed(this.box,0,0,W,H,this.current ? renderer.CYAN : renderer.RAISED6,
                         renderer.ROW);
         renderer.fill(this.box,2,2,W - 4,H - 4,
                       this.current ? renderer.lift(renderer.RAISED6,LIT) : renderer.RAISED6);
         this.face.graphics.clear();
         if(this.mark >= 0)
         {
            Glyph.draw(this.face,this.mark,MARK,
                       this.current ? renderer.CYAN : renderer.LABEL);
         }
      }
   }
}
