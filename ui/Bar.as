package ui
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;

   public class Bar extends Sprite
   {

      public static const PAD:int = 30;

      public static const H:int = 11;

      public var w:int = 0;

      public var showValue:Boolean = true;

      public var valueText:TextField;

      private var track:Shape = new Shape();

      private var run:Shape = new Shape();

      public function Bar(w:int)
      {
         super();
         this.w = w;
         addChild(this.track);
         addChild(this.run);
         this.valueText = renderer.label(w + 4,0,11.5,TextFieldAutoSize.LEFT,"~ / ~",w,30);
         renderer.centre(this.valueText,0,H);
         addChild(this.valueText);
         this.paint();
      }

      public function paint() : void
      {
         this.track.graphics.clear();
         renderer.framed(this.track,-1,-1,this.w + 2,H + 2,renderer.RAISED6,renderer.PANEL2);
         renderer.fill(this.track,1,1,this.w - 2,H - 2,renderer.HEADER);
      }

      public function setRatio(fraction:Number, color:uint) : void
      {
         this.valueText.visible = false;
         this.fillRun(fraction,color,renderer.shade(color,75));
      }

      public function setBar(have:int, need:int) : void
      {
         var fraction:Number = need <= 0 ? 0 : have / need;
         this.valueText.visible = this.showValue;
         renderer.say(this.valueText,have + " / " + need);
         this.valueText.textColor = renderer.rampFor(fraction);
         this.fillRun(fraction,renderer.blend(renderer.YELLOW,renderer.VALUE,0.4),renderer.YELLOW);
      }

      private function fillRun(fraction:Number, top:uint, bottom:uint) : void
      {
         var span:int = this.w * (isNaN(fraction) || fraction < 0 ? 0 : (fraction > 1 ? 1 : fraction));
         this.run.graphics.clear();
         renderer.vertical(this.run,0,0,span,H,top,bottom);
         if(span >= 1)
         {
            renderer.fill(this.run,span,0,1,H,renderer.ROW);
         }
      }
   }
}
