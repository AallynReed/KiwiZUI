package ui
{
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

   /** One setting, in the window. Every control is this shape - it knows its config
    *  key, it can state its value as the literal that goes in the file, and it can be
    *  told a literal back - so the panel holds one list and the screen runs both
    *  directions through the same reader the config file goes through.
    *
    *  The caption lives here rather than in each control: every row is a name on the
    *  left and a control on the right, and CTRL is where that control starts, so the
    *  right edge of a slider lines up with the right edge of a dropdown without each
    *  one being measured by hand.
    *
    *  A control with an empty key is a control and not a setting - a search box, a
    *  filter flag - and works the same everywhere else. */
   public class Option extends Sprite
   {

      public static const H:int = 26;

      /** The control the arrow keys are talking to: whatever the pointer last pressed.
       *  A screen keeps the game running underneath it, so nothing is nudged until a
       *  control has actually been used, and the panel lets go of it when it closes. */
      public static var focused:Option;

      private static const HOLD_CTRL:Number = 5;

      private static const MARK:Number = 2.5;

      private static const MARK_DROP:int = 9;

      private static const HOLD_SHIFT:Number = 10;

      /** The arrows go to whatever control the pointer last pressed, for the settings
       *  that want a number rather than a gesture. Held on the stage rather than on a
       *  control, because a control does not hold the focus Flash means by that word:
       *  the screen does not take the keyboard off the game, and a text box that does
       *  have focus keeps its own keys.
       *
       *  A host turns this on when its controls go up and off when they come down, so
       *  nothing is left listening to a keyboard it has no controls for. */
      public static function watch(host:Stage, on:Boolean) : void
      {
         focused = null;
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

      /** One report per run of keys, however many repeats the key made on the way. */
      private static function onSettle(e:KeyboardEvent) : void
      {
         if(focused != null)
         {
            focused.settle();
         }
      }

      /** Width of the control side of a row. */
      public static const CTRL:int = 150;

      public var key:String;

      public var w:int;

      /** Row height, per instance: a text field needs more room than a checkbox and
       *  the panel lays rows out by what each one asks for. */
      public var tall:int = H;

      /** Everything a control draws goes in here and never into its own graphics. Iggy
       *  measures a sprite by its children and ignores its graphics, so a control that
       *  drew itself measured by its caption alone - and a control Iggy measures wrong
       *  does not merely miss its own clicks, it takes the ones around it.
       *
       *  Added before the caption, so it stays underneath it and under whatever else a
       *  control puts on top. */
      public var box:Shape = new Shape();

      public var caption:TextField;

      /** What the setting is for and what it wants to be set to, in the words of
       *  whoever wrote the mod. Shown through the game's own tooltip, because a screen
       *  listing settings it did not choose has no room to print an explanation beside
       *  every one of them and no business guessing which ones need one. */
      public var tip:String = "";

      /** Drawn where the name ends, so a row carrying an explanation says so without
       *  being hovered. Its own shape rather than part of the row: every control
       *  clears `box` when it paints, and a mark that vanished on the first repaint
       *  would be worse than no mark. */
      private var tipMark:Shape = new Shape();

      /** Where the tooltip is to open, worked out by whatever built the row.
       *
       *  A row cannot answer this for itself, twice over. The tooltip has to go beside
       *  the window rather than over the controls it is describing, so the window's own
       *  edges are what it is measured from; and a row sits in a scrolled clip, which
       *  Iggy does not fold into the transform, so the row's own localToGlobal is where
       *  it would have been with the list scrolled to the top. Both are the panel's to
       *  know. Unset, the tip opens at the row, which is where it used to open. */
      public var anchor:Function;

      public function Option(key:String, text:String = "", w:int = 0)
      {
         super();
         this.key = key;
         this.w = w;
         addChild(this.box);
         addChild(this.tipMark);
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
         this.tipMark.graphics.clear();
         if(this.caption == null)
         {
            return;
         }
         this.caption.x = x;
         renderer.centre(this.caption,0,this.tall);
         this.caption.textColor = color;
         if(this.tip.length > 0)
         {
            renderer.pip(this.tipMark,x + this.caption.textWidth + 8,
                         this.caption.y + MARK_DROP,MARK,renderer.LABEL,0.8);
         }
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

      /** Also called when the panel goes away. A row taken off the stage gets no roll
       *  out, so a tooltip opened on the way to the close button would be left on
       *  screen with nothing under it to dismiss it. */
      public static function hideTip() : void
      {
         if(IggyFunctions.inIggy)
         {
            ExternalInterface.call("TOOLTIP.HIDE");
         }
      }

      /** How wide the name may be before it reaches the control beside it. A caption is
       *  built as wide as the whole row, so a name longer than its lane runs underneath
       *  the control rather than stopping at it. No screen notices while it is showing
       *  names it chose itself; a screen showing names it was handed notices at once. */
      public function get nameRoom() : int
      {
         return this.lane - 8;
      }

      /** Wraps the name into its lane and grows the row to whatever that came to, so a
       *  long name costs height rather than legibility.
       *
       *  Called before the row is laid out and never during a paint: every control
       *  places what it draws against `tall`, so a height that changed mid-paint would
       *  put the box in one place and the tick in another. */
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

      /** Where the control side starts. */
      public function get lane() : int
      {
         return this.w - CTRL;
      }

      public function announce() : void
      {
         dispatchEvent(new Event(Event.CHANGE));
      }

      /** The one place a control makes a noise. Guarded on inIggy so the widgets can
       *  be put on a stage outside the game and clicked at: outside Iggy there is no
       *  bridge and the call throws, which would make every control untestable. */
      public static function click(live:Boolean = true) : void
      {
         if(IggyFunctions.inIggy)
         {
            ExternalInterface.call("POST_SOUND_EVENT",live ? "Play_ui_button_select" : "Play_ui_low_energy");
         }
      }

      /** True while the arrow keys would reach this one. Controls that answer to them
       *  draw it the way they draw a hover, because a control the keyboard is on is a
       *  control being used, and arrows that nudge something the eye cannot pick out
       *  are a trap rather than a shortcut. */
      public function get keyed() : Boolean
      {
         return focused == this;
      }

      /** Answers a key, and says whether it took it. A control that takes one moves and
       *  repaints but does not report: a held key repeats, and a config write per repeat
       *  is the failure that takes a screen down. */
      public function stroke(code:uint, scale:Number) : Boolean
      {
         return false;
      }

      /** Reports what the keys came to, once they are done - the same bargain a dragged
       *  control makes with the mouse. */
      public function settle() : void
      {
      }

      private function onTouch(e:MouseEvent) : void
      {
         var was:Option = focused;
         focused = this;
         if(was != null && was != this)
         {
            was.paint();
         }
         this.paint();
      }

      public function get literal() : String
      {
         return "";
      }

      public function set from(raw:String) : void
      {
      }

      public function paint() : void
      {
      }
   }
}
