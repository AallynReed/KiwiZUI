package ui
{
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   import flash.text.TextFieldAutoSize;

   public class Stepper extends Option
   {

      private static const SIDE:int = 24;

      private static const READ:int = CTRL - SIDE * 2;

      public var value:Number = 0;

      private var low:Number;

      private var top:Number;

      private var step:Number;

      private var places:int;

      private var zero:String;

      private var suffix:String;

      private var readout:TextField;

      private var held:Number = 0;

      private var minus:Plate = new Plate(SIDE,20,13);

      private var plus:Plate = new Plate(SIDE,20,13);

      public function Stepper(key:String, text:String, w:int, low:Number, top:Number,
                              step:Number, places:int = 0, zero:String = "", suffix:String = "")
      {
         super(key,text,w);
         this.suffix = suffix;
         this.low = low;
         this.top = top;
         this.step = step;
         this.places = places;
         this.zero = zero;
         this.value = low;
         this.held = low;
         this.readout = renderer.pin(renderer.label(0,0,12,TextFieldAutoSize.CENTER,"",READ,20,false,true),READ,12);
         addChild(this.readout);
         addChild(this.minus);
         addChild(this.plus);
         this.minus.text = "-";
         this.plus.text = "+";
         this.minus.repeats = true;
         this.plus.repeats = true;
         this.minus.addEventListener(MouseEvent.CLICK,this.onDown);
         this.plus.addEventListener(MouseEvent.CLICK,this.onUp);
      }

      override public function get literal() : String
      {
         var scale:Number = Math.pow(10,this.places);
         var rounded:Number = Math.round(this.value * scale) / scale;
         return this.places == 0 ? String(int(rounded)) : String(rounded);
      }

      override public function set from(raw:String) : void
      {
         this.value = Config.number(raw,this.low,this.top,this.value);
         this.held = this.value;
      }

      override public function stroke(code:uint, scale:Number) : Boolean
      {
         var by:Number = code == Keyboard.LEFT ? -1 : code == Keyboard.RIGHT ? 1 : 0;
         if(by == 0)
         {
            return false;
         }
         this.shift(by * this.step * scale);
         return true;
      }

      override public function settle() : void
      {
         if(this.value != this.held)
         {
            this.held = this.value;
            this.announce();
         }
      }

      override public function paint() : void
      {
         var mid:int = (this.tall - 20) / 2;
         this.box.graphics.clear();
         renderer.fill(this.box,0,0,this.w,this.tall,renderer.PANEL,0);
         this.captionAt(0,renderer.LABEL);
         this.minus.x = this.lane;
         this.minus.y = mid;
         this.plus.x = this.w - SIDE;
         this.plus.y = mid;
         this.readout.x = this.lane + SIDE;
         renderer.centre(this.readout,0,this.tall);
         this.readout.text = this.zero.length > 0 && this.value == 0
                           ? this.zero
                           : this.literal + this.suffix;
         this.readout.textColor = this.keyed ? renderer.CYAN : renderer.VALUE;
         this.minus.live = this.value > this.low;
         this.plus.live = this.value < this.top;
         this.minus.paint();
         this.plus.paint();
      }

      private function onDown(e:MouseEvent) : void
      {
         this.move(-this.step);
      }

      private function onUp(e:MouseEvent) : void
      {
         this.move(this.step);
      }

      private function move(by:Number) : void
      {
         this.shift(by);
         this.settle();
      }

      private function shift(by:Number) : void
      {
         this.value = Config.clamp(this.value + by,this.low,this.top,this.value);
         this.paint();
      }
   }
}
