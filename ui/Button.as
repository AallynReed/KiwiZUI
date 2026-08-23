package ui
{
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;

   /** A flat plate with a vertical gradient, pressed by flipping that gradient over.
    *  A latching button is the same plate that stays flipped, so both are this one
    *  class with a mode rather than two that drift apart. */
   public class Button extends Sprite
   {

      public static const PUSH:int = 0;

      public static const LATCH:int = 1;

      private static const REST:Number = 0.9;

      /** The rim is the palette's border colour, but the plate rests under REST and
       *  a tab does not, so drawn flat it reads a shade darker than the tabs beside
       *  it and the gradient creeps up to meet it. Lifted just past the border, it
       *  lands back where the eye expects it. */
      private static const RIM:Number = 0.08;

      /** Between a mark and the word beside it. */
      private static const MARGIN:int = 8;

      public var caption:TextField;

      /** Drawn beside the caption, for a button whose subject is a thing rather than a
       *  word and whose art cannot be a bitmap. Iggy renders vector geometry and very
       *  little else a mod can bring, so this is the only mark that always arrives.
       *
       *  It draws into `face`, never into the button's own graphics: a sprite's own
       *  drawing sits under its children, so a mark put there would be buried by the
       *  plate. */
      /** Art the caller already holds, shown beside the caption. Where `mark` draws,
       *  this is a display object placed as-is - which is how a button carries the
       *  game's own art rather than an approximation of it. */
      public var art:DisplayObject;

      public var mark:Function = null;

      public var markSize:int = 0;

      public var face:Shape = new Shape();

      public var tooltip:String = "";

      /** The colour a latched button lights in, for one that stands for a subject with a
       *  colour of its own rather than for an action. Zero keeps the accent, which is
       *  what every other button on every screen wants. */
      public var tint:uint = 0;

      /** A dot in the corner saying there is something new behind this button. The stock
       *  screens carry it as a timeline clip on the control itself; here it is one more
       *  thing the button draws, so it survives a repaint the way the rest of it does. */
      public var flagged:Boolean = false;

      /** Iggy measures a sprite by its children and does not count the sprite's own
       *  graphics, so the frame goes in a child and not in `graphics`. Drawn into the
       *  sprite, a button with no caption measures short - and a control Iggy measures
       *  wrong does not merely miss its own clicks, it takes the ones around it. That is
       *  what put an invisible button across a whole header once already.
       *
       *  Separate from `box` because `box` is flipped to draw the pressed state and the
       *  frame must not move with it. */
      public var frame:Shape = new Shape();

      public var box:Shape = new Shape();

      /** The radius of the corner dot. */
      private static const FLAG:Number = 3;

      public var w:int = 0;

      public var h:int = 0;

      private var mode:int = PUSH;

      private var live:Boolean = true;

      private var latched:Boolean = false;

      public function Button(w:int, h:int, size:int, text:String,
                             mode:int = PUSH, tooltip:String = "")
      {
         super();
         this.w = w;
         this.h = h;
         this.mode = mode;
         this.tooltip = tooltip;
         mouseChildren = false;
         addChild(this.frame);
         addChild(this.box);
         addChild(this.face);
         /* Pinned to the button's width rather than sized to its text. An autoSized
            caption with nothing in it measures zero wide, and a control Iggy measures as
            zero does not merely miss its own clicks - it takes the ones around it. Every
            button carrying a drawn mark instead of a word has an empty caption, so this
            is the difference between a 30 wide button and an invisible one across the
            whole strip. Centre alignment inside a fixed width puts the text where the
            autoSize did. */
         this.caption = renderer.pin(renderer.label(0,0,size,TextFieldAutoSize.CENTER,text,w,h),w,size);
         this.caption.x = 0;
         /* label() sets htmlText, and htmlText discards the field's paragraph
            alignment. autoSize was doing the centring before; a pinned field has to be
            told again, or the caption sits against the left edge of the button. */
         this.caption.setTextFormat(this.caption.defaultTextFormat);
         renderer.centre(this.caption,0,h);
         addChild(this.caption);
         this.paint();
         this.alpha = REST;
         this.listen(true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onPress);
      }

      /** Drawing is its own step because the palette arrives after the screen is
       *  built: a button made with the stock colours has to be able to take the
       *  player's without being rebuilt. Only the graphics are cleared, so a latched
       *  button stays pressed across a repaint. */
      public function paint() : void
      {
         this.frame.graphics.clear();
         renderer.framed(this.frame,0,0,this.w,this.h,renderer.lift(renderer.BORDER,RIM),renderer.PANEL2);
         this.box.graphics.clear();
         renderer.raised(this.box,2,2,this.w - 4,this.h - 4,renderer.RAISED2,renderer.RAISED6);
         this.caption.textColor = !this.latched ? renderer.VALUE
                                : (this.tint != 0 ? this.tint : renderer.CYAN);
         this.face.graphics.clear();
         if(this.mark != null)
         {
            this.mark(this.face);
         }
         if(this.flagged)
         {
            renderer.disc(this.frame,this.w - FLAG - 2,FLAG + 2,FLAG,renderer.CYAN);
         }
         this.place();
      }

      /** The mark and the word are centred as one, so the button reads as a single
       *  label rather than as a picture with a number pushed off to the side.
       *
       *  The caption keeps its full width and its centre alignment; shifting the box is
       *  what puts the text where the pair wants it, and it comes out at zero when there
       *  is no mark, so a plain button is untouched by any of this. */
      /** Hands the button a piece of art to carry, and says whether there was any.
       *  A caller left with none puts its word back rather than showing a bare
       *  number. */
      public function setIconArt(source:DisplayObject, size:int) : Boolean
      {
         if(this.art != null && contains(this.art))
         {
            removeChild(this.art);
         }
         this.art = source;
         this.markSize = size;
         if(source != null)
         {
            addChild(source);
         }
         this.place();
         return source != null;
      }

      /** How much room the mark takes, whichever kind of mark it is, and zero when
       *  there is none - which is what leaves a plain button untouched by any of this. */
      private function get markWidth() : Number
      {
         return this.art != null || this.mark != null ? this.markSize : 0;
      }

      private function place() : void
      {
         var wide:Number = this.markWidth;
         var span:Number = 0;
         var left:Number = 0;
         if(wide == 0)
         {
            this.caption.x = 0;
            return;
         }
         /* A button carrying only a mark is the mark centred, with no gap held for a
            word that is not there - which is what a strip of icon tabs is. */
         span = this.caption.text.length == 0 ? wide
                                              : wide + MARGIN + this.caption.textWidth;
         left = (this.w - span) / 2;
         if(this.art != null)
         {
            this.art.x = left;
            this.art.y = (this.h - wide) / 2;
         }
         else if(this.mark != null)
         {
            this.face.x = left;
            this.face.y = (this.h - wide) / 2;
         }
         this.caption.x = left + wide + MARGIN - (this.w - this.caption.textWidth) / 2;
      }

      private function listen(on:Boolean) : void
      {
         if(on)
         {
            addEventListener(MouseEvent.MOUSE_OVER,this.onOver);
            addEventListener(MouseEvent.MOUSE_OUT,this.onOut);
            addEventListener(Event.MOUSE_LEAVE,this.onOut);
            return;
         }
         removeEventListener(MouseEvent.MOUSE_OVER,this.onOver);
         removeEventListener(MouseEvent.MOUSE_OUT,this.onOut);
         removeEventListener(Event.MOUSE_LEAVE,this.onOut);
      }

      private function onOver(e:MouseEvent) : void
      {
         if(this.live)
         {
            this.alpha = 1;
         }
      }

      private function onOut(e:*) : void
      {
         if(this.live)
         {
            this.alpha = REST;
         }
      }

      private function onPress(e:MouseEvent) : void
      {
         Option.click(this.live);
         if(!this.live)
         {
            return;
         }
         this.sink(this.mode == LATCH ? !this.latched : true);
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onRelease);
      }

      private function onRelease(e:MouseEvent) : void
      {
         this.sink(this.mode == LATCH ? this.latched : false);
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.onRelease);
      }

      /** Pressed is the same gradient upside down - one plate, no second drawing. */
      private function sink(down:Boolean) : void
      {
         this.box.scaleY = down ? -1 : 1;
         this.box.y = down ? this.h : 0;
      }

      public function get selected() : Boolean
      {
         return this.latched;
      }

      public function set selected(on:Boolean) : void
      {
         this.latched = on;
         this.sink(on);
         this.caption.textColor = on ? renderer.CYAN : renderer.VALUE;
      }

      public function get enabled() : Boolean
      {
         return this.live;
      }

      public function set enabled(on:Boolean) : void
      {
         this.live = on;
         this.alpha = on ? REST : 0.5;
         if(this.mode == LATCH)
         {
            this.listen(on);
         }
         else
         {
            this.mouseEnabled = on;
         }
      }

      /** .text rather than htmlText, so the field keeps the centre alignment its own
       *  format carries. */
      public function setText(text:String) : void
      {
         this.caption.text = text;
         this.caption.setTextFormat(this.caption.defaultTextFormat);
         this.place();
      }
   }
}
