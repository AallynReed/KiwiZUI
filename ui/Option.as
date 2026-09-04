package ui
{
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.external.ExternalInterface;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.utils.getTimer;

   public class Option extends Sprite
   {

      public static const H:int = 26;

      public static var focused:Option;

      private static var listening:Stage;

      private static const HOLD_CTRL:Number = 5;

      private static const HOLD_SHIFT:Number = 10;

      private static const QUIET:int = 500;

      public static function watch(host:Stage, on:Boolean) : void
      {
         blur();
         if(host == null)
         {
            return;
         }
         if(on)
         {
            host.addEventListener(KeyboardEvent.KEY_DOWN,onStroke);
            host.addEventListener(KeyboardEvent.KEY_UP,onSettle);
            return;
         }
         host.removeEventListener(KeyboardEvent.KEY_DOWN,onStroke);
         host.removeEventListener(KeyboardEvent.KEY_UP,onSettle);
      }

      private static function onStroke(e:KeyboardEvent) : void
      {
         var host:Stage = e.currentTarget as Stage;
         var scale:Number = e.shiftKey ? HOLD_SHIFT : e.ctrlKey ? HOLD_CTRL : 1;
         if(focused == null || host.focus is TextField)
         {
            return;
         }
         if(focused.stroke(e.keyCode,scale))
         {
            e.preventDefault();
         }
      }

      private static function onSettle(e:KeyboardEvent) : void
      {
         var host:Stage = e.currentTarget as Stage;
         if(focused != null && !(host.focus is TextField))
         {
            focused.settle();
         }
      }

      public static const CTRL:int = 150;

      public var key:String;

      public var w:int;

      public var tall:int = H;

      public var box:Shape = new Shape();

      public var caption:TextField;

      public var tip:String = "";

      public var anchor:Function;

      /** A row that holds more than one control resolves them itself, from a point the
       *  panel hands it. Iggy decides which object a press landed on by what it drew, and
       *  a strip of small controls is exactly where that answer is wrong - the press goes
       *  through to the neighbour and the row fires the wrong thing. */
      public var hovers:Boolean = false;

      private var due:int = 0;

      public function Option(key:String, text:String = "", w:int = 0)
      {
         super();
         this.key = key;
         this.w = w;
         addChild(this.box);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onTouch);
         addEventListener(MouseEvent.ROLL_OVER,this.onTipIn);
         addEventListener(MouseEvent.ROLL_OUT,this.onTipOut);
         if(text != null && text.length > 0)
         {
            this.caption = renderer.label(0,0,12,TextFieldAutoSize.LEFT,text,w,20);
            addChild(this.caption);
         }
      }

      public function captionAt(x:int, color:uint) : void
      {
         if(this.caption == null)
         {
            return;
         }
         this.caption.x = x;
         renderer.centre(this.caption,0,this.tall);
         this.caption.textColor = color;
      }

      private function onTipIn(e:MouseEvent) : void
      {
         var top:Point = null;
         if(this.tip.length == 0 || !IggyFunctions.inIggy)
         {
            return;
         }
         top = this.anchor != null ? Point(this.anchor(this))
                                   : localToGlobal(new Point(this.w / 2,0));
         ExternalInterface.call("TOOLTIP.SHOW",top.x,top.y,
                                this.caption == null ? "" : this.caption.text,this.tip);
      }

      private function onTipOut(e:MouseEvent) : void
      {
         if(this.tip.length > 0)
         {
            hideTip();
         }
      }

      public static function hideTip() : void
      {
         if(IggyFunctions.inIggy)
         {
            ExternalInterface.call("TOOLTIP.HIDE");
         }
      }

      public function get nameRoom() : int
      {
         return this.lane - 8;
      }

      public function reflow() : void
      {
         if(this.caption == null || this.nameRoom < 40)
         {
            return;
         }
         this.caption.autoSize = TextFieldAutoSize.NONE;
         this.caption.wordWrap = true;
         this.caption.multiline = true;
         this.caption.width = this.nameRoom;
         this.caption.height = this.caption.textHeight + 6;
         this.tall = Math.max(this.tall,int(this.caption.height) + 6);
      }

      public function get lane() : int
      {
         return this.w - CTRL;
      }

      public function announce() : void
      {
         dispatchEvent(new Event(Event.CHANGE));
      }

      public static function click(live:Boolean = true) : void
      {
         if(IggyFunctions.inIggy)
         {
            ExternalInterface.call("POST_SOUND_EVENT",live ? "Play_ui_button_select" : "Play_ui_low_energy");
         }
      }

      public function get keyed() : Boolean
      {
         return focused == this;
      }

      public function stroke(code:uint, scale:Number) : Boolean
      {
         return false;
      }

      public function settle() : void
      {
      }

      public function stir() : void
      {
         this.due = getTimer() + QUIET;
         addEventListener(Event.ENTER_FRAME,this.onQuiet);
      }

      private function onQuiet(e:Event) : void
      {
         if(getTimer() < this.due)
         {
            return;
         }
         removeEventListener(Event.ENTER_FRAME,this.onQuiet);
         this.settle();
      }

      private function onTouch(e:MouseEvent) : void
      {
         var was:Option = focused;
         focused = this;
         if(listening != stage)
         {
            release();
            listening = stage;
            if(listening != null)
            {
               listening.addEventListener(MouseEvent.MOUSE_DOWN,onElsewhere);
            }
         }
         if(was != null && was != this)
         {
            was.paint();
         }
         this.paint();
      }

      private static function onElsewhere(e:MouseEvent) : void
      {
         var at:DisplayObject = e.target as DisplayObject;
         while(at != null)
         {
            if(at is Option)
            {
               return;
            }
            at = at.parent;
         }
         blur();
      }

      public static function blur() : void
      {
         var was:Option = focused;
         focused = null;
         release();
         if(was != null)
         {
            was.paint();
         }
      }

      private static function release() : void
      {
         if(listening != null)
         {
            listening.removeEventListener(MouseEvent.MOUSE_DOWN,onElsewhere);
            listening = null;
         }
      }

      public function get literal() : String
      {
         return "";
      }

      public function set from(raw:String) : void
      {
      }

      public function press(at:Point) : Boolean
      {
         return false;
      }

      public function lit(at:Point) : void
      {
      }

      public function paint() : void
      {
      }
   }
}
