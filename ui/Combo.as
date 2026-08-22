package ui
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.ui.Keyboard;

   /** One choice out of a list. Closed it is a box with the current choice in it;
    *  open it is that list, lifted to the screen root by Layer so it draws over the
    *  panel it came from instead of under the next row down.
    *
    *  The list is one sprite with a band under the pointer rather than a row of
    *  sprites with a listener each: which row the pointer is over is a division, and
    *  a menu that is thrown away on close cannot leak the listeners it never had.
    *
    *  Multi is this class with the click toggling instead of choosing, so anything
    *  changed here has to keep working for both. */
   public class Combo extends Option
   {

      public static const BOX:int = 22;

      public static const ROW:int = 22;

      private static const PAGE:int = 10;

      private static const ARROW_W:int = 8;

      private static const ARROW_H:int = 5;

      public var index:int = 0;

      public var values:Array;

      public var labels:Array;

      /** Multi ticks every row; a single choice marks one and needs no column of
       *  empty boxes to say the others are not it. */
      public var boxes:Boolean = false;

      private var face:TextField;

      private var menu:Sprite;

      private var slots:Array = [];

      private var hover:int = -1;

      private var first:int = 0;

      private var hot:Boolean = false;

      private var held:int = 0;

      public function Combo(key:String, text:String, w:int, values:Array, labels:Array = null)
      {
         super(key,text,w);
         this.values = values;
         this.labels = labels == null ? values : labels;
         this.face = renderer.pin(renderer.label(0,0,12,TextFieldAutoSize.LEFT,"",CTRL - 34,20),CTRL - 34,12);
         addChild(this.face);
         mouseChildren = false;
         buttonMode = true;
         addEventListener(MouseEvent.ROLL_OVER,this.onHover);
         addEventListener(MouseEvent.ROLL_OUT,this.onHover);
         addEventListener(MouseEvent.CLICK,this.onFace);
      }

      override public function get literal() : String
      {
         return String(this.values[this.index]);
      }

      override public function set from(raw:String) : void
      {
         var at:int = this.values.indexOf(raw);
         this.index = at < 0 ? this.index : at;
         this.held = this.index;
      }

      /** Up and down walk the list whether it is open or shut, so a choice can be
       *  changed without the menu ever being drawn. */
      override public function stroke(code:uint, scale:Number) : Boolean
      {
         var by:int = code == Keyboard.UP ? -1 : code == Keyboard.DOWN ? 1 : 0;
         if(by == 0 || this.values.length == 0)
         {
            return false;
         }
         this.index = Config.clamp(this.index + by,0,this.values.length - 1,this.index);
         this.repaintMenu();
         this.paint();
         return true;
      }

      override public function settle() : void
      {
         if(this.index != this.held)
         {
            this.held = this.index;
            this.announce();
         }
      }

      public function get summary() : String
      {
         return String(this.labels[this.index]);
      }

      public function marked(i:int) : Boolean
      {
         return i == this.index;
      }

      public function pick(i:int) : void
      {
         this.index = i;
         this.held = i;
         Layer.hide();
         this.paint();
         this.announce();
      }

      override public function paint() : void
      {
         var mid:int = (this.tall - BOX) / 2;
         var edge:uint = this.hot || this.menu != null || this.keyed ? renderer.CYAN : renderer.BORDER;
         this.box.graphics.clear();
         renderer.fill(this.box,0,0,this.w,this.tall,renderer.PANEL,0);
         renderer.framed(this.box,this.lane,mid,CTRL,BOX,renderer.HEADER,edge,1);
         this.caret(this.w - 1,mid,this.hot ? renderer.CYAN : renderer.LABEL);
         this.captionAt(0,renderer.LABEL);
         this.face.x = this.lane + 8;
         renderer.centre(this.face,mid,BOX);
         this.face.text = this.summary;
         renderer.elide(this.face,this.face.width);
         this.face.textColor = renderer.VALUE;
      }

      /** Set in from the box's inner corner rather than from its middle, so the space
       *  to the right of the arrow is the space above and below it. */
      private function caret(right:int, top:int, color:uint) : void
      {
         var pad:int = (BOX - 2 - ARROW_H) / 2;
         var x:int = right - pad - ARROW_W;
         var y:int = top + 1 + pad;
         this.box.graphics.beginFill(color,1);
         this.box.graphics.moveTo(x,y);
         this.box.graphics.lineTo(x + ARROW_W,y);
         this.box.graphics.lineTo(x + (ARROW_W >> 1),y + ARROW_H);
         this.box.graphics.endFill();
      }

      public function get page() : int
      {
         return Math.min(PAGE,this.values.length);
      }

      private function onHover(e:MouseEvent) : void
      {
         this.hot = e.type == MouseEvent.ROLL_OVER;
         this.paint();
      }

      private function onFace(e:MouseEvent) : void
      {
         if(this.menu != null)
         {
            Layer.hide();
            return;
         }
         Option.click();
         this.build();
         Layer.show(this.menu,this,this.lane,(this.tall - BOX) / 2 + BOX + 1);
         this.paint();
      }

      /** Built on every open rather than kept: the palette can have moved since the
       *  last one, and a menu that is discarded on close cannot hold a stale colour. */
      private function build() : void
      {
         var field:TextField = null;
         var i:int = 0;
         this.menu = new Sprite();
         this.menu.mouseChildren = false;
         this.slots = [];
         this.first = Config.clamp(this.index - (this.page >> 1),0,this.values.length - this.page,0);
         while(i < this.page)
         {
            field = renderer.pin(renderer.label(0,0,12,TextFieldAutoSize.LEFT,"",CTRL - 34,20),CTRL - 34,12);
            this.slots.push(field);
            this.menu.addChild(field);
            i++;
         }
         this.menu.addEventListener(MouseEvent.MOUSE_MOVE,this.onTrack);
         this.menu.addEventListener(MouseEvent.ROLL_OUT,this.onLeave);
         this.menu.addEventListener(MouseEvent.MOUSE_WHEEL,this.onWheel);
         this.menu.addEventListener(MouseEvent.CLICK,this.onPick);
         this.menu.addEventListener(Event.REMOVED_FROM_STAGE,this.onClosed);
         this.hover = -1;
         this.repaintMenu();
      }

      public function repaintMenu() : void
      {
         var field:TextField = null;
         var row:int = 0;
         var i:int = 0;
         var deep:int = this.page * ROW + 2;
         if(this.menu == null)
         {
            return;
         }
         this.menu.graphics.clear();
         renderer.framed(this.menu,0,0,CTRL,deep,renderer.PANEL,renderer.CYAN,1);
         while(i < this.page)
         {
            row = this.first + i;
            field = this.slots[i] as TextField;
            if(row == this.hover)
            {
               renderer.fill(this.menu,1,1 + i * ROW,CTRL - 2,ROW,renderer.HEADER,1);
            }
            if(this.boxes)
            {
               renderer.framed(this.menu,9,6 + i * ROW,11,11,renderer.HEADER,
                               this.marked(row) ? renderer.CYAN : renderer.BORDER,1);
               if(this.marked(row))
               {
                  renderer.accent(this.menu,11,8 + i * ROW,7,7);
               }
            }
            field.x = this.boxes ? 26 : 9;
            renderer.centre(field,1 + i * ROW,ROW);
            field.text = String(this.labels[row]);
            renderer.elide(field,field.width);
            field.textColor = this.marked(row) ? renderer.CYAN
                            : row == this.hover ? renderer.VALUE : renderer.LABEL;
            i++;
         }
         this.rail(deep);
      }

      /** Only when there is more list than page. Drawn rather than scrollable by
       *  hand: the wheel is what moves it, this only says how far along it is. */
      private function rail(deep:int) : void
      {
         var span:int = deep - 2;
         if(this.values.length <= this.page)
         {
            return;
         }
         renderer.fill(this.menu,CTRL - 4,1,3,span,renderer.HEADER,1);
         renderer.fill(this.menu,CTRL - 4,1 + span * this.first / this.values.length,
                       3,Math.max(8,span * this.page / this.values.length),renderer.BORDER,1);
      }

      private function onTrack(e:MouseEvent) : void
      {
         var was:int = this.hover;
         var slot:int = int((this.menu.mouseY - 1) / ROW);
         this.hover = slot < 0 || slot >= this.page ? -1 : this.first + slot;
         if(this.hover != was)
         {
            this.repaintMenu();
         }
      }

      private function onLeave(e:MouseEvent) : void
      {
         this.hover = -1;
         this.repaintMenu();
      }

      private function onWheel(e:MouseEvent) : void
      {
         var was:int = this.first;
         this.first = Config.clamp(this.first + renderer.wheel(e,3),0,
                                   this.values.length - this.page,this.first);
         if(this.first != was)
         {
            this.onTrack(e);
            this.repaintMenu();
         }
      }

      private function onPick(e:MouseEvent) : void
      {
         if(this.hover >= 0 && this.hover < this.values.length)
         {
            Option.click();
            this.pick(this.hover);
         }
      }

      private function onClosed(e:Event) : void
      {
         this.menu = null;
         this.slots = [];
         this.paint();
      }
   }
}
