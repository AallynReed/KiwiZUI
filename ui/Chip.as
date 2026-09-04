package ui
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;

   public class Chip extends Sprite
   {

      public static const QUIET:int = 0;

      public static const ACCENT:int = 1;

      public static const DANGER:int = 2;

      public static const GO:int = 3;

      private static const EDGE_LIFT:Number = 0.4;

      private static const GAP:int = 7;

      public var caption:TextField;

      public var count:TextField;

      public var w:int = 0;

      public var h:int = 0;

      public var tone:int = QUIET;

      public var driven:Boolean = false;

      /** A quiet chip draws its body at alpha 0, which is a fill that was never drawn, so
       *  the press goes through it to whatever is behind. A chip that is a button on its
       *  own - rather than one row of a strip the container resolves - has to have a
       *  middle to be pressed in. */
      public var solid:Boolean = false;

      public var mark:Function = null;

      public var face:Shape = new Shape();

      private var box:Shape = new Shape();

      private var live:Boolean = true;

      private var over:Boolean = false;

      private var latched:Boolean = false;

      public function Chip(w:int, h:int, size:int, text:String, tone:int = QUIET)
      {
         super();
         this.w = w;
         this.h = h;
         this.tone = tone;
         mouseChildren = false;
         addChild(this.box);
         addChild(this.face);
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

      private static function tracking(size:int) : Number
      {
         return size * 0.16;
      }

      public function resize(w:int, h:int) : void
      {
         this.w = w;
         this.h = h;
         this.paint();
      }

      public function get natural() : int
      {
         return int(this.caption.textWidth
                  + (this.count.text.length == 0 ? 0 : this.count.textWidth + GAP)
                  + GAP * 4);
      }

      public function setText(text:String, count:String = "") : void
      {
         renderer.say(this.caption,text);
         this.caption.setTextFormat(this.caption.defaultTextFormat);
         renderer.say(this.count,count);
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
         this.paint();
      }

      private function place() : void
      {
         var word:Number = 0;
         var tail:Number = 0;
         var left:Number = 0;
         this.caption.setTextFormat(this.caption.defaultTextFormat);
         this.count.setTextFormat(this.count.defaultTextFormat);
         word = this.caption.textWidth;
         tail = this.count.text.length == 0 ? 0 : this.count.textWidth + GAP;
         left = (this.w - (word + tail)) / 2;
         renderer.hug(this.caption,left);
         renderer.hug(this.count,left + word + GAP);
         renderer.centre(this.caption,0,this.h);
         renderer.centre(this.count,0,this.h);
      }

      public function paint() : void
      {
         var on:Boolean = this.live && this.latched;
         var hot:Boolean = this.live && this.over;
         var lit:Boolean = on || hot;
         var edge:uint = hot ? renderer.lift(renderer.BORDER,EDGE_LIFT) : renderer.BORDER;
         var body:uint = renderer.RAISED5;
         var fill:Number = on || this.solid ? 1 : 0;
         var word:uint = lit ? renderer.VALUE : renderer.LABEL;
         var accent:uint = 0;
         if(this.tone == ACCENT || this.tone == GO)
         {
            accent = this.tone == GO ? renderer.GREEN : renderer.CYAN;
            edge = renderer.sink(accent,hot ? 42 : 24);
            body = renderer.sink(accent,on ? 17 : 9);
            fill = 1;
            word = accent;
         }
         else if(this.tone == DANGER && lit)
         {
            edge = renderer.sink(renderer.DANGER,hot ? 30 : 45);
            word = renderer.DANGER;
         }
         this.box.graphics.clear();
         renderer.fill(this.box,0,0,this.w,this.h,body,fill);
         renderer.border(this.box,0,0,this.w,this.h,edge,1);
         this.caption.textColor = word;
         this.count.textColor = renderer.sink(word,70);
         this.face.graphics.clear();
         if(this.mark != null)
         {
            this.mark(this);
         }
         this.alpha = this.live ? 1 : 0.45;
         this.place();
      }

      private function onPress(e:MouseEvent) : void
      {
         if(!this.driven)
         {
            Option.click(this.live);
         }
      }

      public function get hovered() : Boolean
      {
         return this.over;
      }

      public function set hovered(on:Boolean) : void
      {
         if(this.over != on)
         {
            this.over = on;
            this.paint();
         }
      }

      private function onOver(e:MouseEvent) : void
      {
         if(!this.driven)
         {
            this.hovered = true;
         }
      }

      private function onOut(e:*) : void
      {
         if(!this.driven)
         {
            this.hovered = false;
         }
      }
   }
}
