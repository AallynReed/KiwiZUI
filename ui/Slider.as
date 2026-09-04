package ui
{
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   import flash.text.TextFieldAutoSize;

   public class Slider extends Option
   {

      private static const READ:int = 44;

      private static const GAP:int = 6;

      private static const THICK:int = 7;

      private var read:int = READ;

      public var live:Boolean = false;

      private var held:Number = 0;

      private var _value:Number = 0;

      protected var low:Number;

      protected var top:Number;

      protected var step:Number;

      protected var places:int;

      protected var zero:String;

      protected var suffix:String;

      private var readout:TextField;

      private var dragging:Boolean = false;

      private var hot:Boolean = false;

      public function Slider(key:String, text:String, w:int, low:Number, top:Number,
                             step:Number, places:int = 0, zero:String = "", suffix:String = "")
      {
         super(key,text,w);
         this.low = low;
         this.top = top;
         this.step = step;
         this.places = places;
         this.zero = zero;
         this.suffix = suffix;
         this.value = low;
         this.held = low;
         this.read = this.widest();
         this.readout = renderer.pin(renderer.label(0,0,12,TextFieldAutoSize.RIGHT,"",
                                                    this.read,20,false,true),this.read,12);
         addChild(this.readout);
         mouseChildren = false;
         addEventListener(MouseEvent.ROLL_OVER,this.onHover);
         addEventListener(MouseEvent.ROLL_OUT,this.onHover);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onPress);
      }

      private function widest() : int
      {
         var probe:TextField = renderer.label(0,0,12,TextFieldAutoSize.LEFT,"",-1,-1,false,true);
         var most:Number = 0;
         var i:int = 0;
         var words:Array = [this.zero,this.wording(this.low),this.wording(this.top)];
         while(i < words.length)
         {
            renderer.say(probe,String(words[i]));
            most = Math.max(most,probe.textWidth);
            i++;
         }
         return Math.max(READ,Math.ceil(most) + 8);
      }

      private function wording(at:Number) : String
      {
         var scale:Number = Math.pow(10,this.places);
         var rounded:Number = Math.round(at * scale) / scale;
         return (this.places == 0 ? String(int(rounded)) : String(rounded)) + this.suffix;
      }

      public function get value() : Number
      {
         return this._value;
      }

      public function set value(at:Number) : void
      {
         if(at == this._value)
         {
            return;
         }
         this._value = at;
         if(this.readout != null)
         {
            this.paint();
         }
      }

      override public function get literal() : String
      {
         var scale:Number = Math.pow(10,this.places);
         var rounded:Number = Math.round(this.value * scale) / scale;
         return this.places == 0 ? String(int(rounded)) : String(rounded);
      }

      override public function set from(raw:String) : void
      {
         this.value = Config.number(raw,this.low - this.stop,this.top,this.value);
         this.value = this.value < this.low ? 0 : this.value;
         this.held = this.value;
      }

      override public function stroke(code:uint, scale:Number) : Boolean
      {
         var at:Number = 0;
         var by:Number = code == Keyboard.LEFT || code == Keyboard.DOWN ? -1
                       : code == Keyboard.RIGHT || code == Keyboard.UP ? 1 : 0;
         if(by == 0)
         {
            return false;
         }
         at = (this.value <= 0 ? this.low - this.stop : this.value) + by * this.step * scale;
         this.value = at < this.low ? (this.stop > 0 ? 0 : this.low)
                    : Config.clamp(at,this.low,this.top,this.value);
         this.paint();
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

      protected function get reading() : String
      {
         return this.zero.length > 0 && this.value == 0 ? this.zero
              : this.literal + this.suffix;
      }

      public function range(low:Number, top:Number, step:Number) : void
      {
         this.low = low;
         this.top = top;
         this.step = step > 0 ? step : this.step;
         this.value = Config.clamp(this.value,low,top,low);
         this.held = this.value;
      }

      private function get bar() : int
      {
         return CTRL - this.read - GAP;
      }

      private function get slide() : int
      {
         return this.bar - 2;
      }

      private function get stop() : Number
      {
         return this.zero.length > 0 && this.low > 0 ? this.step : 0;
      }

      private function get run() : Number
      {
         return this.top - this.low + this.stop;
      }

      private function get fraction() : Number
      {
         if(this.run <= 0)
         {
            return 0;
         }
         return (this.value <= 0 ? 0 : this.value - this.low + this.stop) / this.run;
      }

      override public function paint() : void
      {
         var mid:int = (this.tall - THICK) / 2;
         var run:int = this.fraction * this.slide;
         var live:Boolean = this.hot || this.dragging || this.keyed;
         this.box.graphics.clear();
         renderer.fill(this.box,0,0,this.w,this.tall,renderer.PANEL,0);
         renderer.framed(this.box,this.lane,mid,this.bar,THICK,renderer.HEADER,
                         live ? renderer.CYAN : renderer.BORDER,1);
         if(run > 0)
         {
            renderer.accent(this.box,this.lane + 1,mid + 1,run,THICK - 2);
         }
         this.captionAt(0,renderer.LABEL);
         this.readout.x = this.w - this.read;
         renderer.centre(this.readout,0,this.tall);
         this.readout.text = this.reading;
         this.readout.textColor = live ? renderer.CYAN : renderer.VALUE;
      }

      private function onHover(e:MouseEvent) : void
      {
         this.hot = e.type == MouseEvent.ROLL_OVER;
         this.paint();
      }

      private function onPress(e:MouseEvent) : void
      {
         if(this.mouseX < this.lane)
         {
            return;
         }
         Option.click();
         this.held = this.value;
         this.dragging = true;
         this.follow();
         stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onDrag);
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onRelease);
      }

      private function onDrag(e:MouseEvent) : void
      {
         this.follow();
         e.updateAfterEvent();
      }

      private function onRelease(e:MouseEvent) : void
      {
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onDrag);
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.onRelease);
         this.dragging = false;
         this.paint();
         if(this.value != this.held)
         {
            this.announce();
         }
      }

      private function follow() : void
      {
         var along:Number = Config.clamp((this.mouseX - this.lane - 1) / this.slide,0,1,0);
         var steps:Number = Math.round(along * this.run / this.step);
         var at:Number = this.low - this.stop + steps * this.step;
         this.value = at < this.low ? 0 : Config.clamp(at,this.low,this.top,this.value);
         this.paint();
         if(this.live)
         {
            this.settle();
            return;
         }
         this.stir();
      }
   }
}
