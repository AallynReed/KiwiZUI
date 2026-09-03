package ui
{
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFieldType;
   import flash.ui.Keyboard;

   public class Spin extends Option
   {

      private static const SIDE:int = 24;

      private static const BOX:int = 20;

      private static const READ:int = CTRL - SIDE * 2;

      public var value:Number = 0;

      private var low:Number;

      private var top:Number;

      private var step:Number;

      private var places:int;

      private var suffix:String;

      private var readout:TextField;

      private var minus:Plate = new Plate(SIDE,BOX,13);

      private var plus:Plate = new Plate(SIDE,BOX,13);

      private var editing:Boolean = false;

      private var held:Number = 0;

      public function Spin(key:String, text:String, w:int, top:Number,
                           low:Number = 1, step:Number = 1,
                           places:int = 0, suffix:String = "")
      {
         super(key,text,w);
         this.top = top;
         this.low = low;
         this.step = step;
         this.places = places;
         this.suffix = suffix;
         this.value = low;
         this.held = low;
         this.readout = renderer.pin(renderer.label(0,0,12,TextFieldAutoSize.CENTER,"",READ,20,false,true),READ,12);
         this.readout.mouseEnabled = false;
         this.readout.addEventListener(Event.CHANGE,this.onEdit);
         this.readout.addEventListener(KeyboardEvent.KEY_DOWN,this.onTyping);
         this.readout.addEventListener(FocusEvent.FOCUS_OUT,this.onBlur);
         addChild(this.readout);
         addChild(this.minus);
         addChild(this.plus);
         this.minus.text = "-";
         this.plus.text = "+";
         this.minus.repeats = true;
         this.plus.repeats = true;
         this.minus.addEventListener(MouseEvent.CLICK,this.onDown);
         this.plus.addEventListener(MouseEvent.CLICK,this.onUp);
         addEventListener(MouseEvent.CLICK,this.onClick);
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
         if(by == 0 || this.editing)
         {
            return false;
         }
         this.shift(by * this.step * scale);
         return true;
      }

      override public function settle() : void
      {
         if(this.editing)
         {
            this.grab();
         }
         if(this.value != this.held)
         {
            this.held = this.value;
            this.announce();
         }
      }

      override public function paint() : void
      {
         var mid:int = (this.tall - BOX) / 2;
         this.box.graphics.clear();
         renderer.fill(this.box,0,0,this.w,this.tall,renderer.PANEL,0);
         this.captionAt(0,renderer.LABEL);
         if(this.editing)
         {
            renderer.framed(this.box,this.lane + SIDE,mid,READ,BOX,renderer.HEADER,renderer.CYAN,1);
         }
         this.minus.x = this.lane;
         this.minus.y = mid;
         this.plus.x = this.w - SIDE;
         this.plus.y = mid;
         this.readout.x = this.lane + SIDE;
         renderer.centre(this.readout,mid,BOX);
         if(!this.editing)
         {
            renderer.say(this.readout,this.literal + this.suffix);
         }
         this.readout.textColor = this.editing || this.keyed ? renderer.CYAN : renderer.VALUE;
         this.minus.live = this.value > this.low;
         this.plus.live = this.value < this.top;
         this.minus.paint();
         this.plus.paint();
      }

      private function onClick(e:MouseEvent) : void
      {
         if(this.editing || this.mouseX < this.lane + SIDE || this.mouseX > this.w - SIDE)
         {
            return;
         }
         Option.click();
         this.edit(true);
      }

      private function edit(on:Boolean) : void
      {
         this.editing = on;
         this.readout.type = on ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
         this.readout.selectable = on;
         this.readout.mouseEnabled = on;
         if(!on)
         {
            this.paint();
            if(this.stage != null && this.stage.focus == this.readout)
            {
               this.stage.focus = null;
            }
            return;
         }
         renderer.say(this.readout,this.literal);
         this.paint();
         if(this.stage != null)
         {
            this.stage.focus = this.readout;
         }
         this.readout.setSelection(0,this.readout.length);
      }

      private function onEdit(e:Event) : void
      {
         this.stir();
      }

      private function onTyping(e:KeyboardEvent) : void
      {
         if(e.keyCode == Keyboard.ENTER || e.keyCode == Keyboard.ESCAPE)
         {
            this.commit(e.keyCode == Keyboard.ENTER);
         }
      }

      private function onBlur(e:FocusEvent) : void
      {
         this.commit(true);
      }

      private function commit(take:Boolean) : void
      {
         if(!this.editing)
         {
            return;
         }
         if(take)
         {
            this.grab();
         }
         this.edit(false);
         this.settle();
      }

      private function grab() : void
      {
         this.value = Config.number(this.readout.text,this.low,this.top,this.value);
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
