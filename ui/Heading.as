package ui
{
   import flash.text.TextFieldAutoSize;

   public class Heading extends Option
   {

      private static const SPACED:Number = 1.6;

      private static const RULE:int = 3;

      public function Heading(text:String, w:int)
      {
         super("","",w);
         this.tall = 28;
         this.caption = renderer.label(0,0,10,TextFieldAutoSize.LEFT,"",w,20,false,false,
                                       SPACED);
         this.caption.text = text.toUpperCase();
         addChild(this.caption);
         mouseEnabled = false;
         mouseChildren = false;
      }

      override public function get nameRoom() : int
      {
         return this.w;
      }

      override public function paint() : void
      {
         this.box.graphics.clear();
         this.caption.x = 0;
         this.caption.textColor = renderer.CYAN;
         renderer.centre(this.caption,0,this.tall - RULE * 2);
         renderer.fill(this.box,0,this.tall - RULE,this.w,1,renderer.BORDER);
      }
   }
}
