package ui
{
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.ui.Keyboard;
   import flash.text.TextFormat;

   public class Input extends Option
   {

      public static const TYPING:String = "typing";

      public static const BOX:int = 24;

      private static const SET:int = 26;

      public var field:TextField;

      private var hint:TextField;

      private var apply:Plate = new Plate(SET,BOX,13);

      private var size:int;

      private var committed:String = "";

      private var hot:Boolean = false;

      public var driven:Boolean = false;

      public function Input(key:String, text:String, w:int, prompt:String = "", size:int = 12)
      {
         super(key,text,w);
         this.tall = 28;
         this.size = size;
         this.field = this.build(renderer.VALUE);
         this.field.type = TextFieldType.INPUT;
         this.field.selectable = true;
         this.field.mouseEnabled = true;
         this.field.addEventListener(Event.CHANGE,this.onEdit);
         this.field.addEventListener(FocusEvent.FOCUS_OUT,this.onLeave);
         this.field.addEventListener(KeyboardEvent.KEY_DOWN,this.onKey);
         addChild(this.field);
         this.hint = this.build(renderer.LABEL);
         this.hint.text = prompt;
         addChild(this.hint);
         if(key.length > 0)
         {
            this.apply.mark = this.tick;
            this.apply.addEventListener(MouseEvent.CLICK,this.onApply);
            addChild(this.apply);
         }
         addEventListener(MouseEvent.ROLL_OVER,this.onHover);
         addEventListener(MouseEvent.ROLL_OUT,this.onHover);
         addEventListener(MouseEvent.CLICK,this.onClick);
      }

      private function tick(plate:Plate) : void
      {
         var mid:int = BOX >> 1;
         plate.face.graphics.lineStyle(2,plate.caption.textColor,1);
         plate.face.graphics.moveTo(8,mid);
         plate.face.graphics.lineTo(11,mid + 4);
         plate.face.graphics.lineTo(18,mid - 4);
         plate.face.graphics.lineStyle();
      }

      private function build(color:uint) : TextField
      {
         var f:TextField = new TextField();
         f.defaultTextFormat = new TextFormat("Open Sans",this.size,color);
         f.mouseEnabled = false;
         f.height = this.size * 2;
         return f;
      }

      public function get boxTop() : int
      {
         return (this.tall - BOX) / 2;
      }

      public function get value() : String
      {
         return this.field.text;
      }

      public function set value(body:String) : void
      {
         this.field.text = body == null ? "" : body;
         this.committed = this.field.text;
      }

      override public function get literal() : String
      {
         return this.field.text;
      }

      override public function set from(raw:String) : void
      {
         this.value = raw;
      }

      public function clear() : void
      {
         this.field.text = "";
         this.paint();
         this.report();
      }

      public function compose(start:int, length:int, body:String) : void
      {
         this.field.replaceText(start,start + length,body);
         this.paint();
         this.report();
      }

      private function get boxAt() : int
      {
         return this.caption == null ? 0 : this.lane;
      }

      private function get boxWide() : int
      {
         var span:int = this.caption == null ? this.w : CTRL;
         return this.key.length > 0 ? span - SET - 4 : span;
      }

      override public function paint() : void
      {
         var at:int = this.boxAt;
         var wide:int = this.boxWide;
         var mid:int = (this.tall - BOX) / 2;
         var empty:Boolean = this.field.text.length == 0;
         this.box.graphics.clear();
         renderer.fill(this.box,0,0,this.w,this.tall,renderer.PANEL,0);
         renderer.framed(this.box,at,mid,wide,BOX,renderer.HEADER,this.hot ? renderer.CYAN : renderer.BORDER,1);
         this.captionAt(0,renderer.LABEL);
         this.place(this.field,at,wide,mid,renderer.VALUE);
         this.place(this.hint,at,wide,mid,renderer.LABEL);
         this.hint.visible = empty;
         this.cross(at + wide - 10,mid + (BOX >> 1),!empty);
         if(this.key.length > 0)
         {
            this.apply.x = at + wide + 4;
            this.apply.y = mid;
            this.apply.live = this.field.text != this.committed;
            this.apply.paint();
         }
      }

      private function place(f:TextField, at:int, wide:int, mid:int, color:uint) : void
      {
         var fmt:TextFormat = new TextFormat("Open Sans",this.size,color);
         f.x = at + 8;
         f.width = wide - 26;
         f.defaultTextFormat = fmt;
         if(f.length > 0)
         {
            f.setTextFormat(fmt);
         }
         renderer.centre(f,mid,BOX);
      }

      private function cross(x:int, y:int, on:Boolean) : void
      {
         if(!on)
         {
            return;
         }
         this.box.graphics.lineStyle(2,this.hot ? renderer.VALUE : renderer.LABEL,1);
         this.box.graphics.moveTo(x - 4,y - 4);
         this.box.graphics.lineTo(x + 4,y + 4);
         this.box.graphics.moveTo(x + 4,y - 4);
         this.box.graphics.lineTo(x - 4,y + 4);
         this.box.graphics.lineStyle();
      }

      public function press(at:Point) : Boolean
      {
         var edge:Number = this.x + this.boxAt + this.boxWide;
         if(!Hit.holds(this,this.boxAt + this.boxWide,this.tall,at))
         {
            return false;
         }
         Option.click();
         if(this.field.text.length > 0 && at.x > edge - 20)
         {
            this.clear();
            return true;
         }
         this.focus();
         return true;
      }

      public function focus() : void
      {
         if(stage != null)
         {
            stage.focus = this.field;
         }
         this.field.setSelection(this.field.text.length,this.field.text.length);
      }

      public function lit(at:Point) : void
      {
         this.hovered = Hit.holds(this,this.boxAt + this.boxWide,this.tall,at);
      }

      public function set hovered(on:Boolean) : void
      {
         if(this.hot != on)
         {
            this.hot = on;
            this.paint();
         }
      }

      private function onHover(e:MouseEvent) : void
      {
         if(!this.driven)
         {
            this.hovered = e.type == MouseEvent.ROLL_OVER;
         }
      }

      private function onClick(e:MouseEvent) : void
      {
         var edge:int = this.boxAt + this.boxWide;
         if(this.driven)
         {
            return;
         }
         if(this.field.text.length > 0 && this.mouseX > edge - 20 && this.mouseX < edge)
         {
            Option.click();
            this.clear();
         }
      }

      private function onEdit(e:Event) : void
      {
         this.paint();
         this.report();
      }

      private function report() : void
      {
         dispatchEvent(new Event(TYPING));
         if(this.key.length == 0)
         {
            this.announce();
         }
      }

      private function onApply(e:MouseEvent) : void
      {
         this.commit();
      }

      private function onLeave(e:FocusEvent) : void
      {
         this.commit();
      }

      private function onKey(e:KeyboardEvent) : void
      {
         if(e.keyCode == Keyboard.ENTER)
         {
            this.commit();
         }
      }

      private function commit() : void
      {
         if(this.field.text == this.committed)
         {
            return;
         }
         this.committed = this.field.text;
         this.paint();
         this.announce();
      }
   }
}
