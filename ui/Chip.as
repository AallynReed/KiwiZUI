package ui
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;

   /** A flat control: one hairline rectangle, a tracked word inside it, and a colour
    *  change on hover. Nothing is raised and nothing moves when it is pressed.
    *
    *  Button is the other half of this pair and stays as it is - a gradient plate that
    *  presses by flipping over. The two are not variants of one control: a plate says
    *  "push me" through depth, a chip says it through weight, and a screen that mixes
    *  the two reads as two screens. Pick one per screen.
    *
    *  Colours come out of the palette rather than being written down here, so a chip
    *  follows whatever the player set the accent and the border to. */
   public class Chip extends Sprite
   {

      /** Quiet by default, accent for the one action a panel is for, danger for the
       *  one that takes something away. */
      public static const QUIET:int = 0;

      public static const ACCENT:int = 1;

      public static const DANGER:int = 2;

      /** The one action that takes you out of the screen and into the thing the screen
       *  is about. Accent is for the action a panel is for; this is for leaving. */
      public static const GO:int = 3;

      /** How far the edge lifts under the pointer, and how far a danger edge moves
       *  toward the danger colour. */
      private static const EDGE_LIFT:Number = 0.4;

      /** Between the word and the count that follows it. */
      private static const GAP:int = 7;

      public var caption:TextField;

      /** A number after the word - how many of a thing the chip stands for. Empty on a
       *  chip that is only an action. */
      public var count:TextField;

      public var w:int = 0;

      public var h:int = 0;

      public var tone:int = QUIET;

      private var box:Shape = new Shape();

      private var live:Boolean = true;

      private var over:Boolean = false;

      /** A latched chip paints as though hovered and stays that way, which is what a
       *  filter wants: the one that is on is the one that looks touched. */
      private var latched:Boolean = false;

      public function Chip(w:int, h:int, size:int, text:String, tone:int = QUIET)
      {
         super();
         this.w = w;
         this.h = h;
         this.tone = tone;
         addChild(this.box);
         this.caption = renderer.pin(
            renderer.label(0,0,size,TextFieldAutoSize.CENTER,"",w,h,false,false,tracking(size)),w,size);
         addChild(this.caption);
         this.count = renderer.pin(
            renderer.label(0,0,size,TextFieldAutoSize.CENTER,"",w,h),w,size);
         addChild(this.count);
         this.setText(text);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onPress);
         addEventListener(MouseEvent.MOUSE_OVER,this.onOver);
         addEventListener(MouseEvent.MOUSE_OUT,this.onOut);
         addEventListener(Event.MOUSE_LEAVE,this.onOut);
      }

      /** Uppercase words are what the tracking is for; it does nothing legible to a
       *  number and pushes it out of the column it belongs in. */
      private static function tracking(size:int) : Number
      {
         return size * 0.16;
      }

      public function resize(w:int, h:int) : void
      {
         this.w = w;
         this.h = h;
         this.caption.height = this.h;
         this.count.height = this.h;
         this.paint();
      }

      /** How wide this chip has to be for its own words, so a strip of them can be laid
       *  out to fit rather than to a number somebody guessed. */
      public function get natural() : int
      {
         return int(this.caption.textWidth
                  + (this.count.text.length == 0 ? 0 : this.count.textWidth + GAP)
                  + GAP * 4);
      }

      public function setText(text:String, count:String = "") : void
      {
         this.caption.text = text;
         this.caption.setTextFormat(this.caption.defaultTextFormat);
         this.count.text = count;
         this.count.setTextFormat(this.count.defaultTextFormat);
         this.paint();
      }

      public function get selected() : Boolean
      {
         return this.latched;
      }

      public function set selected(on:Boolean) : void
      {
         this.latched = on;
         this.paint();
      }

      public function get enabled() : Boolean
      {
         return this.live;
      }

      public function set enabled(on:Boolean) : void
      {
         this.live = on;
         this.mouseEnabled = on;
         this.mouseChildren = on;
         this.paint();
      }

      /** The word and the number are centred as one pair, so a chip carrying a count
       *  reads as a single label rather than as a word with a figure pushed off it. */
      private function place() : void
      {
         var word:Number = 0;
         var tail:Number = 0;
         var left:Number = 0;
         this.caption.width = this.w;
         this.count.width = this.w;
         this.caption.setTextFormat(this.caption.defaultTextFormat);
         this.count.setTextFormat(this.count.defaultTextFormat);
         word = this.caption.textWidth;
         tail = this.count.text.length == 0 ? 0 : this.count.textWidth + GAP;
         left = (this.w - (word + tail)) / 2;
         this.caption.x = left - (this.w - word) / 2;
         this.count.x = left + word + GAP - (this.w - this.count.textWidth) / 2;
         renderer.centre(this.caption,0,this.h);
         renderer.centre(this.count,0,this.h);
      }

      public function paint() : void
      {
         var hot:Boolean = this.live && (this.over || this.latched);
         var edge:uint = renderer.BORDER;
         var inner:uint = 0;
         var word:uint = renderer.LABEL;
         var accent:uint = 0;
         if(this.tone == ACCENT || this.tone == GO)
         {
            accent = this.tone == GO ? renderer.GREEN : renderer.CYAN;
            edge = hot ? renderer.sink(accent,32) : renderer.sink(accent,24);
            inner = hot ? renderer.sink(accent,14) : renderer.sink(accent,9);
            word = accent;
         }
         else if(this.tone == DANGER && hot)
         {
            edge = renderer.sink(renderer.RED,30);
            word = renderer.RED;
         }
         else if(hot)
         {
            edge = renderer.lift(renderer.BORDER,EDGE_LIFT);
            word = renderer.VALUE;
         }
         this.box.graphics.clear();
         if(this.tone == ACCENT || this.tone == GO)
         {
            renderer.fill(this.box,1,1,this.w - 2,this.h - 2,inner,1);
         }
         renderer.border(this.box,0,0,this.w,this.h,edge,1);
         this.caption.textColor = word;
         this.count.textColor = renderer.sink(word,70);
         this.alpha = this.live ? 1 : 0.45;
         this.place();
      }

      private function onPress(e:MouseEvent) : void
      {
         Option.click(this.live);
      }

      private function onOver(e:MouseEvent) : void
      {
         this.over = true;
         this.paint();
      }

      private function onOut(e:*) : void
      {
         this.over = false;
         this.paint();
      }
   }
}
