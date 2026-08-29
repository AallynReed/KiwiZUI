package ui
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;

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

      protected var translucent:Boolean = false;

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

      private var sent:String = "";

      private var zone:Reach = new Reach();

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

      override public function set from(raw:String) : void
      {
         var shade:uint = Config.color(raw,this.color);
         var a:Number = this.translucent ? Config.alpha(raw,this.opacity) : 1;
         if(this.popup != null)
         {
            return;
         }
         if(shade != this.color || a != this.opacity)
         {
            this.opacity = a;
            this.take(shade);
         }
         this.sent = this.literal;
      }

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
         renderer.say(this.hexText,this.literal);
         this.hexText.textColor = this.hot ? renderer.VALUE : renderer.LABEL;
      }

      private function onHover(e:MouseEvent) : void
      {
         this.hot = e.type == MouseEvent.ROLL_OVER;
         this.paint();
      }

      private function onFace(e:MouseEvent) : void
      {
         if(this.popup != null || Layer.shut(this))
         {
            Layer.hide();
            return;
         }
         Option.click();
         this.build();
         Layer.show(this.popup,this,this.lane,(this.tall - SIDE) / 2 + SIDE + 1);
         this.paint();
      }

      public function openOn(host:DisplayObject, x:Number, y:Number) : void
      {
         if(this.popup != null)
         {
            Layer.hide();
            return;
         }
         this.build();
         Layer.show(this.popup,host,x,y);
      }

      public function get open() : Boolean
      {
         return this.popup != null;
      }

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
         this.zone.hold(this.field,this.wide,this.deep);
         this.follow();
         this.field.addEventListener(MouseEvent.MOUSE_MOVE,this.onDrag);
         this.field.addEventListener(MouseEvent.MOUSE_UP,this.onRelease);
         this.field.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onDrag);
         this.field.stage.addEventListener(MouseEvent.MOUSE_UP,this.onRelease);
      }

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
            this.settle();
         }
      }

      private function release() : void
      {
         this.held = false;
         this.zone.drop();
         if(this.field == null)
         {
            return;
         }
         this.field.removeEventListener(MouseEvent.MOUSE_MOVE,this.onDrag);
         this.field.removeEventListener(MouseEvent.MOUSE_UP,this.onRelease);
         if(this.field.stage != null)
         {
            this.field.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onDrag);
            this.field.stage.removeEventListener(MouseEvent.MOUSE_UP,this.onRelease);
         }
      }

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
         this.stir();
      }

      private function onHex(e:Event) : void
      {
         if(this.translucent)
         {
            this.opacity = Config.alpha(this.hex.value,this.opacity);
         }
         this.take(Config.color(this.hex.value,this.color));
         this.settle();
      }

      override public function settle() : void
      {
         if(this.literal != this.sent)
         {
            this.commit();
         }
      }

      private function commit() : void
      {
         this.sent = this.literal;
         this.paint();
         this.announce();
         this.painted = -1;
         this.barred = -1;
         this.refresh();
      }

      private function onClosed(e:Event) : void
      {
         this.hex.settle();
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
