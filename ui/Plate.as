package ui
{
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;

   public class Plate extends Sprite
   {

      private static const ICON_GAP:int = 6;

      public var caption:TextField;

      private var box:Shape = new Shape();

      public var live:Boolean = true;

      public var mark:Function = null;

      public var face:Shape = new Shape();

      public var mark2:DisplayObject;

      public var icon:Icon;

      public var markSize:int = 0;

      public var driven:Boolean = false;

      public var on:Boolean = false;

      public var tipTitle:String = "";

      public var tip:String = "";

      public var anchor:Function;

      public var bare:Boolean = false;

      private var w:int;

      private var h:int;

      private var hot:Boolean = false;

      public function Plate(w:int, h:int, size:int)
      {
         super();
         this.w = w;
         this.h = h;
         addChild(this.box);
         addChild(this.face);
         this.caption = renderer.pin(renderer.label(0,0,size,TextFieldAutoSize.CENTER,"",w,h,false,true),w,size);
         this.caption.x = 0;
         addChild(this.caption);
         mouseChildren = false;
         addEventListener(MouseEvent.ROLL_OVER,this.onHover);
         addEventListener(MouseEvent.ROLL_OUT,this.onHover);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onPress);
      }

      public function resize(w:int, h:int) : void
      {
         this.w = w;
         this.h = h;
         this.caption.width = w;
         this.place();
      }

      public function set text(body:String) : void
      {
         if(this.caption.text == body)
         {
            return;
         }
         this.caption.text = body;
         this.caption.setTextFormat(this.caption.defaultTextFormat);
         this.place();
      }

      public function setIcon(texture:String, size:int) : Boolean
      {
         if(this.icon == null)
         {
            this.icon = new Icon(size);
         }
         this.icon.show(texture,size);
         this.markSize = 0;
         this.setMark(this.icon);
         return this.icon.visible;
      }

      public function setIconArt(art:DisplayObject, size:int) : void
      {
         this.markSize = size;
         this.setMark(art);
      }

      public function setMark(art:DisplayObject) : void
      {
         if(this.mark2 != art)
         {
            if(this.mark2 != null && this.mark2.parent == this)
            {
               removeChild(this.mark2);
            }
            this.mark2 = art;
            if(art != null)
            {
               addChild(art);
            }
         }
         this.place();
      }

      private function place() : void
      {
         var span:Number = 0;
         var left:Number = 0;
         var wide:Number = 0;
         var deep:Number = 0;
         if(this.mark2 == null || !this.mark2.visible)
         {
            this.caption.autoSize = TextFieldAutoSize.NONE;
            this.caption.width = this.w;
            this.caption.x = 0;
            return;
         }
         wide = this.markSize > 0 ? this.markSize : this.mark2.width;
         deep = this.markSize > 0 ? this.markSize : this.mark2.height;
         this.caption.autoSize = TextFieldAutoSize.LEFT;
         span = wide + ICON_GAP + this.caption.textWidth;
         left = (this.w - span) / 2;
         this.mark2.x = left;
         this.mark2.y = (this.h - deep) / 2;
         this.caption.x = left + wide + ICON_GAP;
      }

      public function paint() : void
      {
         var edge:uint = this.on || this.hot && this.live ? renderer.CYAN : renderer.BORDER;
         graphics.clear();
         this.box.graphics.clear();
         if(this.bare)
         {
            renderer.fill(this.box,0,0,this.w,this.h,
                          this.on ? renderer.RAISED5 : renderer.HEADER,
                          this.on ? 1 : this.hot && this.live ? 0.55 : 0);
         }
         else
         {
            renderer.framed(this.box,0,0,this.w,this.h,renderer.HEADER,edge,1);
         }
         this.caption.textColor = !this.live ? renderer.LABEL
                                : this.on ? renderer.VALUE
                                : this.hot ? renderer.VALUE : renderer.LABEL;
         if(!this.bare)
         {
            this.caption.textColor = !this.live ? renderer.LABEL
                                   : this.on ? renderer.CYAN : renderer.VALUE;
         }
         renderer.centre(this.caption,0,this.h);
         this.alpha = this.live ? 1 : 0.55;
         this.buttonMode = this.live;
         this.face.graphics.clear();
         if(this.mark != null)
         {
            this.mark(this);
         }
      }

      public function get hovered() : Boolean
      {
         return this.hot;
      }

      public function set hovered(on:Boolean) : void
      {
         if(this.hot != on)
         {
            this.hot = on;
            this.paint();
            this.tell();
         }
      }

      private function tell() : void
      {
         var top:Point = null;
         if(this.tip.length == 0 || !IggyFunctions.inIggy)
         {
            return;
         }
         if(!this.hot || !this.live)
         {
            Tip.hide();
            return;
         }
         top = this.anchor != null ? Point(this.anchor(this))
                                   : localToGlobal(new Point(this.w * 0.5,0));
         ExternalInterface.call("TOOLTIP.SHOW",top.x,top.y,this.tipTitle,this.tip);
      }

      private function onHover(e:MouseEvent) : void
      {
         if(!this.driven)
         {
            this.hovered = e.type == MouseEvent.ROLL_OVER;
         }
      }

      private function onPress(e:MouseEvent) : void
      {
         if(!this.driven)
         {
            Option.click(this.live);
         }
      }
   }
}
