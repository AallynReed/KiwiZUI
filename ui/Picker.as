package ui
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;

   /** A colour, off a square and a hue strip - the picker everyone already knows how
    *  to work. This one is opaque; AlphaPicker is the same control with an opacity
    *  strip beside the hue, and a screen picks whichever of the two its setting means.
    *  Most colours are not transparency settings, and a strip offered where it has no
    *  meaning is a strip somebody will move.
    *
    *  A drag would once have been out of the question here: a config write is a
    *  record, never a trace, and one write per pixel of travel takes the screen down.
    *  Slider settled that - follow the pointer the whole way, say nothing until it is
    *  released - so the square drags freely and the whole gesture is one write.
    *
    *  The square is the HSV plane itself, not a picture of one. Every component of
    *  hsv() is linear in value, so hsv(h,s,v) is v times hsv(h,s,1), and the column at
    *  saturation s is exactly a gradient from hsv(h,s,1) down to black. One such
    *  gradient per pixel of width is the whole square, correct to the pixel, and built
    *  from the plain two-stop fills the rest of the screen is already drawn with - no
    *  transparent overlay, and nothing Iggy has not already been shown to take.
    *
    *  Redrawn only when the hue moves, so dragging inside the square moves a crosshair
    *  and not 188 gradients a frame.
    *
    *  Picking does not close it. A colour is arrived at rather than chosen - hue, then
    *  saturation, then a nudge of value - and a picker that shut after each of those
    *  would make one decision into three trips. It closes where every other popup
    *  does: the next click somewhere else. */
   public class Picker extends Option
   {

      public static const SIDE:int = 22;

      public static const SQUARE_W:int = 188;

      public static const SQUARE_H:int = 150;

      public static const STRIP:int = 18;

      protected static const PAD:int = 8;

      protected static const HUE_X:int = PAD + SQUARE_W + PAD;

      protected static const ALPHA_X:int = HUE_X + STRIP + PAD;

      protected static const HEX_Y:int = PAD + SQUARE_H + PAD;

      protected static const SQUARE:int = 0;

      protected static const HUE:int = 1;

      protected static const ALPHA:int = 2;

      public var color:uint = 0xFFFFFF;

      public var opacity:Number = 1;

      /** Set by AlphaPicker and by nothing else. The two controls are one
       *  implementation because they differ by a strip and a pair of hex digits, and
       *  two copies of a colour square would be two things to keep in step. */
      protected var translucent:Boolean = false;

      /** Where the crosshair and the hue knob are. The colour is the truth and these
       *  are only a position, but they hold more than the colour does: every grey is
       *  hue nothing, and every black is saturation nothing, so a position cannot be
       *  rebuilt from a colour without losing the corner of the square the pointer was
       *  actually in. */
      public var hue:Number = 0;

      public var sat:Number = 0;

      public var val:Number = 1;

      private var hexText:TextField;

      private var popup:Sprite;

      private var field:Sprite;

      private var plane:Sprite;

      private var bar:Sprite;

      private var marks:Sprite;

      private var hex:Input;

      private var axis:int = SQUARE;

      private var held:Boolean = false;

      private var painted:Number = -1;

      private var barred:Number = -1;

      private var hot:Boolean = false;

      public function Picker(key:String, text:String, w:int)
      {
         super(key,text,w);
         this.hexText = renderer.pin(renderer.label(0,0,12,TextFieldAutoSize.LEFT,"",90,20),90,12);
         addChild(this.hexText);
         mouseChildren = false;
         buttonMode = true;
         addEventListener(MouseEvent.ROLL_OVER,this.onHover);
         addEventListener(MouseEvent.ROLL_OUT,this.onHover);
         addEventListener(MouseEvent.CLICK,this.onFace);
      }

      /** The opacity strip is the only thing between the two controls, so every
       *  measurement that depends on it is taken from here. */
      public function get content() : int
      {
         return SQUARE_W + PAD + STRIP + (this.translucent ? PAD + STRIP : 0);
      }

      public function get wide() : int
      {
         return this.content + PAD * 2;
      }

      public function get deep() : int
      {
         return HEX_Y + 28 + PAD;
      }

      override public function get literal() : String
      {
         return this.translucent ? Config.hexa(this.color,this.opacity)
                                 : "#" + Config.hex(this.color);
      }

      /** An open picker is the authority on its own value, and the screen is only
       *  echoing what the picker told it.
       *
       *  The screen repaints for its own reasons - a stat arriving, a row sorting, a
       *  config key coming back - and every repaint pushes the committed value into
       *  every control. For most of them that is exactly right. For this one it is
       *  not: a colour cannot say which corner of the square the pointer was in, so
       *  rebuilding the position from it drops the hue the moment the square is
       *  touched, which is the reset you see. While the popup is up, nothing outside
       *  gets to move the marks; a value it already holds is not news either. */
      override public function set from(raw:String) : void
      {
         var shade:uint = Config.color(raw,this.color);
         var a:Number = this.translucent ? Config.alpha(raw,this.opacity) : 1;
         if(this.popup != null || (shade == this.color && a == this.opacity))
         {
            return;
         }
         this.opacity = a;
         this.take(shade);
      }

      /** The colour is what is stored and what is written; hue, saturation and value
       *  are only where the square has to put its crosshair. A grey reports no hue, so
       *  the hue it was already showing is kept - otherwise dragging a colour down to
       *  black would lose it and come back up red. */
      private function take(shade:uint) : void
      {
         var hsv:Array = renderer.hsvOf(shade);
         this.color = shade;
         this.sat = Number(hsv[1]);
         this.val = Number(hsv[2]);
         if(this.sat > 0)
         {
            this.hue = Number(hsv[0]);
         }
      }

      override public function paint() : void
      {
         var mid:int = (this.tall - SIDE) / 2;
         var edge:uint = this.hot || this.popup != null ? renderer.CYAN : renderer.BORDER;
         this.box.graphics.clear();
         renderer.fill(this.box,0,0,this.w,this.tall,renderer.PANEL,0);
         if(this.translucent)
         {
            renderer.checker(this.box,this.lane + 1,mid + 1,SIDE - 2,SIDE - 2,5);
         }
         renderer.fill(this.box,this.lane + 1,mid + 1,SIDE - 2,SIDE - 2,this.color,this.opacity);
         renderer.border(this.box,this.lane,mid,SIDE,SIDE,edge,1,1);
         this.captionAt(0,renderer.LABEL);
         this.hexText.x = this.lane + SIDE + 10;
         renderer.centre(this.hexText,0,this.tall);
         this.hexText.text = this.literal;
         this.hexText.textColor = this.hot ? renderer.VALUE : renderer.LABEL;
      }

      private function onHover(e:MouseEvent) : void
      {
         this.hot = e.type == MouseEvent.ROLL_OVER;
         this.paint();
      }

      private function onFace(e:MouseEvent) : void
      {
         if(this.popup != null)
         {
            Layer.hide();
            return;
         }
         Option.click();
         this.build();
         Layer.show(this.popup,this,this.lane,(this.tall - SIDE) / 2 + SIDE + 1);
         this.paint();
      }

      /** Layers, because they redraw at different rates: the plane is the hue's, the
       *  bar is the colour's, the marks are the pointer's, and the hex box has to keep
       *  its own children live to be typed into. */
      private function build() : void
      {
         this.popup = new Sprite();
         this.field = new Sprite();
         this.field.mouseChildren = false;
         this.plane = new Sprite();
         this.bar = new Sprite();
         this.field.addChild(this.plane);
         this.field.addChild(this.bar);
         this.marks = new Sprite();
         this.marks.mouseEnabled = false;
         this.marks.mouseChildren = false;
         this.hex = new Input("hex","",this.content,this.literal);
         this.hex.value = this.literal;
         this.hex.x = PAD;
         this.hex.y = HEX_Y;
         this.hex.addEventListener(Event.CHANGE,this.onHex);
         this.popup.addChild(this.field);
         this.popup.addChild(this.marks);
         this.popup.addChild(this.hex);
         this.field.addEventListener(MouseEvent.MOUSE_DOWN,this.onPress);
         this.popup.addEventListener(Event.REMOVED_FROM_STAGE,this.onClosed);
         this.painted = -1;
         this.barred = -1;
         this.refresh();
      }

      /** One gradient per column of the square, each exactly the value axis at that
       *  saturation. Skipped unless the hue has actually moved, which is why the
       *  opacity strip - which follows the colour rather than the hue - is a second
       *  sprite and not another few lines in here. */
      private function paintPlane() : void
      {
         var i:int = 0;
         if(this.painted == this.hue)
         {
            return;
         }
         this.painted = this.hue;
         this.popup.graphics.clear();
         renderer.framed(this.popup,0,0,this.wide,this.deep,renderer.PANEL,renderer.CYAN,1);
         this.field.graphics.clear();
         renderer.fill(this.field,0,0,this.wide,this.deep,renderer.PANEL,0);
         this.plane.graphics.clear();
         while(i < SQUARE_W)
         {
            renderer.vertical(this.plane,PAD + i,PAD,1,SQUARE_H,
                              renderer.hsv(this.hue,i / (SQUARE_W - 1),1),renderer.BLACK);
            i++;
         }
         renderer.hueStrip(this.plane,HUE_X,PAD,STRIP,SQUARE_H);
      }

      /** The colour at every opacity, over the lattice, as one solid band per pixel.
       *  A gradient that fades its own alpha would be one call instead of a hundred
       *  and fifty, and would be the first thing on this screen to ask Iggy for a
       *  gradient it has never been shown to take. Bands are the same primitive every
       *  other panel is drawn with. */
      private function paintBar() : void
      {
         var i:int = 0;
         if(!this.translucent || this.barred == this.color)
         {
            return;
         }
         this.barred = this.color;
         this.bar.graphics.clear();
         renderer.checker(this.bar,ALPHA_X,PAD,STRIP,SQUARE_H,5);
         while(i < SQUARE_H)
         {
            renderer.fill(this.bar,ALPHA_X,PAD + i,STRIP,1,this.color,1 - i / (SQUARE_H - 1));
            i++;
         }
      }

      private function paintMarks() : void
      {
         var x:int = PAD + this.sat * (SQUARE_W - 1);
         var y:int = PAD + (1 - this.val) * (SQUARE_H - 1);
         this.marks.graphics.clear();
         renderer.border(this.marks,x - 4,y - 4,9,9,renderer.BLACK,0.75,1);
         renderer.border(this.marks,x - 3,y - 3,7,7,0xFFFFFF,1,1);
         this.knob(HUE_X,PAD + this.hue * (SQUARE_H - 1));
         if(this.translucent)
         {
            this.knob(ALPHA_X,PAD + (1 - this.opacity) * (SQUARE_H - 1));
         }
      }

      private function knob(x:int, y:int) : void
      {
         renderer.border(this.marks,x - 2,y - 3,STRIP + 4,7,renderer.BLACK,0.75,1);
         renderer.border(this.marks,x - 1,y - 2,STRIP + 2,5,0xFFFFFF,1,1);
      }

      /** The popup and the row, showing the same colour. Cheap during a drag: the
       *  square is skipped unless the hue is what moved, and the strip unless the
       *  colour is. */
      private function refresh() : void
      {
         if(this.popup == null)
         {
            return;
         }
         this.paintPlane();
         this.paintBar();
         this.paintMarks();
         this.hex.value = this.literal;
         this.hex.paint();
         this.paint();
      }

      private function inSquare() : Boolean
      {
         return this.field.mouseX >= PAD && this.field.mouseX < PAD + SQUARE_W
             && this.field.mouseY >= PAD && this.field.mouseY < PAD + SQUARE_H;
      }

      private function inColumn(at:int) : Boolean
      {
         return this.field.mouseX >= at && this.field.mouseX < at + STRIP
             && this.field.mouseY >= PAD && this.field.mouseY < PAD + SQUARE_H;
      }

      /** The one way in, and where the press landed is the whole gesture. Nothing here
       *  answers CLICK: a drag that ended somewhere unfortunate used to fire a second
       *  handler and write a second, wrong colour. */
      private function onPress(e:MouseEvent) : void
      {
         if(this.inColumn(HUE_X))
         {
            this.axis = HUE;
         }
         else if(this.translucent && this.inColumn(ALPHA_X))
         {
            this.axis = ALPHA;
         }
         else if(this.inSquare())
         {
            this.axis = SQUARE;
         }
         else
         {
            return;
         }
         Option.click();
         this.held = true;
         this.follow();
         this.field.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onDrag);
         this.field.stage.addEventListener(MouseEvent.MOUSE_UP,this.onRelease);
      }

      /** The stage is everyone's, so a listener left on it outlives the popup that
       *  registered it and goes on answering for a control that is no longer there.
       *  held says this picker is the one dragging; release() is the only way off the
       *  stage, and closing the popup goes through it too. */
      private function onDrag(e:MouseEvent) : void
      {
         if(!this.held || this.field == null)
         {
            this.release();
            return;
         }
         this.follow();
         e.updateAfterEvent();
      }

      private function onRelease(e:MouseEvent) : void
      {
         var was:Boolean = this.held;
         this.release();
         if(was)
         {
            this.commit();
         }
      }

      private function release() : void
      {
         this.held = false;
         if(this.field != null && this.field.stage != null)
         {
            this.field.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onDrag);
            this.field.stage.removeEventListener(MouseEvent.MOUSE_UP,this.onRelease);
         }
      }

      /** Which axis is moving is fixed at the press rather than re-read each move: a
       *  pointer that wanders off a strip mid-drag should go on moving that strip, the
       *  way every other picker behaves. */
      private function follow() : void
      {
         var along:Number = Config.clamp((this.field.mouseY - PAD) / (SQUARE_H - 1),0,1,0);
         if(this.axis == HUE)
         {
            this.hue = along;
         }
         else if(this.axis == ALPHA)
         {
            this.opacity = 1 - along;
         }
         else
         {
            this.sat = Config.clamp((this.field.mouseX - PAD) / (SQUARE_W - 1),0,1,this.sat);
            this.val = 1 - along;
         }
         this.color = renderer.hsv(this.hue,this.sat,this.val);
         this.refresh();
      }

      /** The hex box commits on its tick, never on a keystroke, so a colour typed a
       *  character at a time is still one write. */
      private function onHex(e:Event) : void
      {
         if(this.translucent)
         {
            this.opacity = Config.alpha(this.hex.value,this.opacity);
         }
         this.take(Config.color(this.hex.value,this.color));
         this.commit();
      }

      /** One write, and the popup stays. The popup's own border is drawn out of the
       *  palette the write may have just changed, so both layers are marked stale and
       *  redrawn after the screen has taken the new value - not before, or they would
       *  repaint with the colour that is on its way out. */
      private function commit() : void
      {
         this.paint();
         this.announce();
         this.painted = -1;
         this.barred = -1;
         this.refresh();
      }

      private function onClosed(e:Event) : void
      {
         this.release();
         this.popup = null;
         this.field = null;
         this.plane = null;
         this.bar = null;
         this.marks = null;
         this.hex = null;
         this.paint();
      }
   }
}
