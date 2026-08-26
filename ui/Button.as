package ui
{
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;

   public class Button extends Sprite
   {

      public static const PUSH:int = 0;

      public static const LATCH:int = 1;

      private static const REST:Number = 0.9;

      private static const RIM:Number = 0.08;

      private static const MARGIN:int = 8;

      public var caption:TextField;

      public var art:DisplayObject;

      public var mark:Function = null;

      public var markSize:int = 0;

      public var face:Shape = new Shape();

      public var tooltip:String = "";

      public var tint:uint = 0;

      public var flagged:Boolean = false;

      public var frame:Shape = new Shape();

      public var box:Shape = new Shape();

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
         this.caption = renderer.pin(renderer.label(0,0,size,TextFieldAutoSize.CENTER,text,w,h),w,size);
         this.caption.x = 0;
         this.caption.setTextFormat(this.caption.defaultTextFormat);
         renderer.centre(this.caption,0,h);
         addChild(this.caption);
         this.paint();
         this.alpha = REST;
         this.listen(true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onPress);
      }

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

      public function setText(text:String) : void
      {
         renderer.say(this.caption,text);
         this.caption.setTextFormat(this.caption.defaultTextFormat);
         this.place();
      }
   }
}
