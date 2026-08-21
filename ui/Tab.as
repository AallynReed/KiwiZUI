package ui
{
   import flash.display.Shape;
   import flash.display.Sprite;

   /** The narrow strip down the side of a screen that switches between them. Its only
    *  state is whether it is the current one, so it repaints whole rather than keeping
    *  a second set of children for the selected look. */
   public class Tab extends Sprite
   {

      public static const W:int = 24;

      public static const H:int = 50;

      /** The current tab is the lit one, so its face is the lighter of the two. Drawn
       *  the other way round it reads as the one that has been pressed out of the way. */
      private static const LIT:Number = 0.06;

      /** Drawn into a child, never into this sprite's own graphics: Iggy measures a
       *  sprite by its children and ignores its graphics, so a tab that drew itself
       *  measured zero - and a control Iggy measures as zero takes the clicks of
       *  everything around it. */
      private var box:Shape = new Shape();

      private var current:Boolean = false;

      public function Tab()
      {
         super();
         addChild(this.box);
         this.paint();
      }

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
      }
   }
}
