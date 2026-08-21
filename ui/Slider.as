package ui
{
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   import flash.text.TextFieldAutoSize;

   /** A number, dragged. The fill is the whole of it - there is no knob, because a
    *  knob says the same thing twice and the run of colour says it flatter.
    *
    *  The fill follows the pointer the whole way but the value is only announced on
    *  release, so a drag across the track is one config write and not one per pixel of
    *  travel - a write is a record, never a trace, and a control that wrote
    *  continuously would take the screen down with it.
    *
    *  A click anywhere on the track jumps there, which is the same one write. */
   public class Slider extends Option
   {

      private static const READ:int = 44;

      private static const GAP:int = 6;

      private static const TRACK:int = CTRL - READ - GAP;

      private static const THICK:int = 7;

      private static const RUN:int = TRACK - 2;

      public var value:Number = 0;

      private var low:Number;

      private var top:Number;

      private var step:Number;

      private var places:int;

      private var zero:String;

      private var suffix:String;

      private var readout:TextField;

      private var held:Number = 0;

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
         this.readout = renderer.pin(renderer.label(0,0,12,TextFieldAutoSize.RIGHT,"",READ,20,false,true),READ,12);
         addChild(this.readout);
         mouseChildren = false;
         addEventListener(MouseEvent.ROLL_OVER,this.onHover);
         addEventListener(MouseEvent.ROLL_OUT,this.onHover);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onPress);
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

      /** By the step, which is the smallest move the slider has: an arrow key is the
       *  precise way to set one, so it moves by the least the control can express. */
      override public function stroke(code:uint, scale:Number) : Boolean
      {
         var by:Number = code == Keyboard.LEFT || code == Keyboard.DOWN ? -1
                       : code == Keyboard.RIGHT || code == Keyboard.UP ? 1 : 0;
         if(by == 0)
         {
            return false;
         }
         this.value = Config.clamp(this.value + by * this.step * scale,this.low,this.top,this.value);
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

      private function get fraction() : Number
      {
         return this.top == this.low ? 0 : (this.value - this.low) / (this.top - this.low);
      }

      override public function paint() : void
      {
         var mid:int = (this.tall - THICK) / 2;
         var run:int = this.fraction * RUN;
         var live:Boolean = this.hot || this.dragging || this.keyed;
         this.box.graphics.clear();
         renderer.fill(this.box,0,0,this.w,this.tall,renderer.PANEL,0);
         renderer.framed(this.box,this.lane,mid,TRACK,THICK,renderer.HEADER,
                         live ? renderer.CYAN : renderer.BORDER,1);
         if(run > 0)
         {
            renderer.accent(this.box,this.lane + 1,mid + 1,run,THICK - 2);
         }
         this.captionAt(0,renderer.LABEL);
         this.readout.x = this.w - READ;
         renderer.centre(this.readout,0,this.tall);
         this.readout.text = this.zero.length > 0 && this.value == 0
                           ? this.zero
                           : this.literal + this.suffix;
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

      /** Snapped to the step on the way in, so the value the knob shows and the value
       *  that would be written are the same number at every point of the drag. */
      private function follow() : void
      {
         var along:Number = Config.clamp((this.mouseX - this.lane - 1) / RUN,0,1,0);
         var steps:Number = Math.round(along * (this.top - this.low) / this.step);
         this.value = Config.clamp(this.low + steps * this.step,this.low,this.top,this.value);
         this.paint();
      }
   }
}
