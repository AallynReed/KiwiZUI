package ui
{
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.ui.Keyboard;
   import flash.text.TextFormat;

   /** A typed-into box with a hint behind it and a cross to empty it. The hint is a
    *  second field rather than placeholder text in the first, so what the caller reads
    *  back is always what was typed and never the prompt.
    *
    *  Typing and committing are two different events on purpose. A box that filters a
    *  list wants every keystroke, and a box that sets a config key must not have one:
    *  a write per keystroke is the failure that kills the screen. So typing dispatches
    *  TYPING, and CHANGE - the event the settings panel writes on - only comes from
    *  the tick beside the field or from leaving it.
    *
    *  A box with no config key has nothing to write, so for that one every keystroke
    *  is settled and CHANGE follows TYPING. That is what makes a filter box a filter
    *  box without the caller having to know which event it is meant to want.
    *
    *  Iggy has to be told a text field took focus or the keys keep going to the game.
    *  That is the screen's job, not this widget's: the root reports FOCUS_IN and
    *  FOCUS_OUT for whatever field they came from, and this one bubbles like any
    *  other. A screen with no such handler has a box that cannot be typed into. */
   public class Input extends Option
   {

      public static const TYPING:String = "typing";

      private static const BOX:int = 24;

      private static const SET:int = 26;

      public var field:TextField;

      private var hint:TextField;

      private var apply:Plate = new Plate(SET,BOX,13);

      private var size:int;

      private var committed:String = "";

      private var hot:Boolean = false;

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

      /** Drawn rather than typed: a tick is a glyph the shipped font may or may not
       *  carry, and a missing one is a blank button with nothing to say why. */
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

      /** The box takes the control lane when the row has a name and the whole width
       *  when it has not, which is the difference between a setting and a search. */
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

      /** Drawn into this sprite rather than kept as a child: it is two strokes and a
       *  hit box, and the click is caught by position instead of by a listener on one
       *  more display object. */
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

      private function onHover(e:MouseEvent) : void
      {
         this.hot = e.type == MouseEvent.ROLL_OVER;
         this.paint();
      }

      private function onClick(e:MouseEvent) : void
      {
         var edge:int = this.boxAt + this.boxWide;
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

      /** Enter settles the box, the same as its button does.
       *
       *  Registered rather than relied on: Iggy feeds a field through
       *  `UIComponent.textCompositionReplace` and not through Flash key events, so whether
       *  this ever fires in game is the engine's business. A listener nothing calls costs
       *  nothing, and the button is the path that is known to work. */
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
