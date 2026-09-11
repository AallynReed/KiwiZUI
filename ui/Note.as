package ui
{
   import flash.text.TextFieldAutoSize;

   public class Note extends Option
   {

      private static const SIZE:int = 11;

      private static const RULE:int = 2;

      private static const PAD:int = 8;

      public function Note(text:String, w:int)
      {
         super("","",w);
         this.tall = 0;
         this.caption = renderer.label(RULE + PAD,0,SIZE,TextFieldAutoSize.LEFT,text,
                                       this.nameRoom,20,true);
         addChild(this.caption);
         mouseEnabled = false;
         mouseChildren = false;
         this.reflow();
      }

      override public function get nameRoom() : int
      {
         return this.w - RULE - PAD;
      }

      override public function paint() : void
      {
         this.box.graphics.clear();
         this.caption.x = RULE + PAD;
         this.caption.y = 0;
         this.caption.textColor = renderer.LABEL;
         renderer.fill(this.box,0,0,RULE,this.tall,renderer.CYAN,0.85);
      }
   }
}
