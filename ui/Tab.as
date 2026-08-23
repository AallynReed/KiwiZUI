package ui
{
   import flash.display.Shape;
   import flash.display.Sprite;

   /** The narrow strip down the side of a screen that switches between them. Its only
    *  state is whether it is the current one, so it repaints whole rather than keeping
    *  a second set of children for the selected look.
    *
    *  A mark is optional. A tab given one says what it is without a caption, which is the
    *  only thing 24 pixels of width has room for; a tab given none is the plain face it
    *  always was. */
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

      /** The mark is its own child rather than more of the box: the face is redrawn on
       *  every state change and the mark is not, and one shape for both would mean
       *  clearing the drawing that does not change to repaint the one that does. */
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

      /** Big enough to read at 24 wide and still clear of the tab's own border. */
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
