package ui
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.ui.Keyboard;

   public class List extends Option
   {

      public static const BOX:int = 22;

      public static const ROW:int = 22;

      private static const BROAD:int = 460;

      private static const NARROW:int = 300;

      private static const MARGIN:int = 40;

      public static const PROMPT:String = "Add a value";

      public static const NONE:String = "None";

      private static const HEAD:int = 28;

      private static const PAGE:int = 18;

      private static const LEAST:int = 8;

      private static const CHROME:int = 104;

      private static const PAD:int = 8;

      private static const GUTTER:int = 22;

      private static const NUM:int = 16;

      private static const TEXT_X:int = GUTTER + NUM + 6;

      private static const ADD:int = 26;

      private static const RING:Number = 5.5;

      private static const DOT:Number = 1.5;

      public var values:Array = [];

      private var noneText:String;

      private var prompt:String;

      private var face:TextField;

      private var popup:Sprite;

      private var frame:Shape;

      private var rows:Sprite;

      private var paper:Shape;

      private var nums:Array = [];

      private var texts:Array = [];

      private var entry:Input;

      private var adder:Plate;

      private var title:TextField;

      private var closer:Sprite;

      private var page:int = LEAST;

      private var wide:int = NARROW;

      private var first:int = 0;

      private var hover:int = -1;

      private var armed:Boolean = false;

      private var carried:int = -1;

      private var began:String = "";

      private var hot:Boolean = false;

      private var hotClose:Boolean = false;

      public function List(key:String, text:String, w:int, prompt:String = PROMPT,
                           noneText:String = NONE)
      {
         super(key,text,w);
         this.prompt = prompt;
         this.noneText = noneText;
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
         return this.values.join(",");
      }

      override public function set from(raw:String) : void
      {
         if(this.popup != null)
         {
            return;
         }
         this.values = [];
         this.take(raw);
         this.settleView();
         this.refresh();
      }

      public static function split(raw:String) : Array
      {
         var one:String = null;
         var out:Array = [];
         var parts:Array = (raw == null ? "" : raw).split(",");
         var i:int = 0;
         while(i < parts.length)
         {
            one = trim(String(parts[i]));
            if(one.length > 0 && out.indexOf(one) < 0)
            {
               out.push(one);
            }
            i++;
         }
         return out;
      }

      private function take(raw:String) : int
      {
         var parts:Array = split(raw);
         var got:int = 0;
         var i:int = 0;
         while(i < parts.length)
         {
            if(this.values.indexOf(parts[i]) < 0)
            {
               this.values.push(parts[i]);
               got++;
            }
            i++;
         }
         return got;
      }

      private static function trim(body:String) : String
      {
         var from:int = 0;
         var to:int = body.length;
         while(from < to && body.charCodeAt(from) <= 32)
         {
            from++;
         }
         while(to > from && body.charCodeAt(to - 1) <= 32)
         {
            to--;
         }
         return body.substring(from,to);
      }

      public function get summary() : String
      {
         return this.values.length == 0 ? this.noneText : this.values.join(", ");
      }

      public function get count() : int
      {
         return this.values.length;
      }

      public function move(from:int, to:int) : void
      {
         if(from < 0 || to < 0 || from >= this.values.length || to >= this.values.length
         || from == to)
         {
            return;
         }
         this.values.splice(to,0,this.values.splice(from,1)[0]);
      }

      override public function paint() : void
      {
         var mid:int = (this.tall - BOX) / 2;
         var edge:uint = this.hot || this.popup != null || this.keyed ? renderer.CYAN : renderer.BORDER;
         var empty:Boolean = this.values.length == 0;
         this.box.graphics.clear();
         renderer.fill(this.box,0,0,this.w,this.tall,renderer.PANEL,0);
         renderer.framed(this.box,this.lane,mid,CTRL,BOX,renderer.HEADER,edge,1);
         this.dots(this.w - 11,mid + (BOX >> 1),this.hot ? renderer.CYAN : renderer.LABEL);
         this.captionAt(0,renderer.LABEL);
         this.face.x = this.lane + 8;
         renderer.centre(this.face,mid,BOX);
         this.face.text = this.summary;
         renderer.elide(this.face,this.face.width);
         this.face.textColor = empty ? renderer.LABEL : renderer.VALUE;
      }

      private function dots(right:int, mid:int, color:uint) : void
      {
         var i:int = 0;
         while(i < 3)
         {
            renderer.disc(this.box,right - i * 5,mid,DOT,color,1);
            i++;
         }
      }

      private function onHover(e:MouseEvent) : void
      {
         this.hot = e.type == MouseEvent.ROLL_OVER;
         this.paint();
      }

      private function onFace(e:MouseEvent) : void
      {
         if(this.popup != null || Layer.shut(this))
         {
            Layer.hide();
            return;
         }
         Option.click();
         this.build();
         Layer.middle(this.popup,this,this.wide,this.deep);
         this.entry.focus();
         this.paint();
      }

      private function build() : void
      {
         var i:int = 0;
         this.wide = this.widest;
         this.page = Config.clamp(this.values.length + 1,LEAST,this.ceiling,LEAST);
         this.popup = new Sprite();
         this.frame = new Shape();
         this.rows = new Sprite();
         this.paper = new Shape();
         this.rows.x = PAD;
         this.rows.y = HEAD + PAD;
         this.rows.mouseChildren = false;
         this.rows.addChild(this.paper);
         this.nums = [];
         this.texts = [];
         while(i < this.page)
         {
            this.nums.push(this.line(NUM,TextFieldAutoSize.RIGHT));
            this.texts.push(this.line(this.inner - TEXT_X - PAD,TextFieldAutoSize.LEFT));
            i++;
         }
         this.entry = new Input("","",this.inner - ADD - 4,this.prompt);
         this.entry.x = PAD;
         this.entry.y = this.entryY;
         this.entry.addEventListener(Input.TYPING,this.onTyping);
         this.entry.field.addEventListener(KeyboardEvent.KEY_DOWN,this.onKey);
         this.adder = new Plate(ADD,Input.BOX,13);
         this.adder.mark = tick;
         this.adder.x = PAD + this.inner - ADD;
         this.adder.y = this.entryY + this.entry.boxTop;
         this.adder.addEventListener(MouseEvent.CLICK,this.onAdd);
         this.title = renderer.pin(renderer.label(0,0,13,TextFieldAutoSize.LEFT,"",
                                                  this.wide - HEAD - PAD,20,false,true),
                                   this.wide - HEAD - PAD,13);
         this.title.x = PAD;
         this.title.text = this.caption == null ? "" : this.caption.text;
         this.title.textColor = renderer.VALUE;
         renderer.centre(this.title,0,HEAD);
         this.closer = this.closeButton();
         this.popup.addChild(this.frame);
         this.popup.addChild(this.title);
         this.popup.addChild(this.closer);
         this.popup.addChild(this.rows);
         this.popup.addChild(this.entry);
         this.popup.addChild(this.adder);
         this.popup.addEventListener(MouseEvent.MOUSE_WHEEL,this.onWheel);
         this.rows.addEventListener(MouseEvent.MOUSE_MOVE,this.onTrack);
         this.rows.addEventListener(MouseEvent.ROLL_OUT,this.onLeave);
         this.rows.addEventListener(MouseEvent.MOUSE_DOWN,this.onPress);
         this.rows.addEventListener(MouseEvent.CLICK,this.onStrike);
         this.popup.addEventListener(Event.REMOVED_FROM_STAGE,this.onClosed);
         this.hover = -1;
         this.armed = false;
         this.settleView();
         this.refresh();
      }


      private function closeButton() : Sprite
      {
         var box:Sprite = new Sprite();
         box.mouseChildren = false;
         box.buttonMode = true;
         box.x = this.wide - HEAD;
         box.addChild(new Shape());
         box.addEventListener(MouseEvent.ROLL_OVER,this.onCloseHover);
         box.addEventListener(MouseEvent.ROLL_OUT,this.onCloseHover);
         box.addEventListener(MouseEvent.CLICK,this.onClose);
         return box;
      }

      private function paintCloser() : void
      {
         var art:Shape = this.closer.getChildAt(0) as Shape;
         var mid:int = HEAD >> 1;
         var color:uint = this.hotClose ? renderer.DANGER : renderer.LABEL;
         art.graphics.clear();
         renderer.fill(art,0,0,HEAD,HEAD,renderer.PANEL,0);
         art.graphics.lineStyle(2,color & 0xFFFFFF,renderer.solidity(color));
         art.graphics.moveTo(mid - 5,mid - 5);
         art.graphics.lineTo(mid + 5,mid + 5);
         art.graphics.moveTo(mid + 5,mid - 5);
         art.graphics.lineTo(mid - 5,mid + 5);
         art.graphics.lineStyle();
      }

      private function onCloseHover(e:MouseEvent) : void
      {
         if(this.popup != null)
         {
            this.hotClose = e.type == MouseEvent.ROLL_OVER;
            this.paintCloser();
         }
      }

      private function onClose(e:MouseEvent) : void
      {
         Option.click();
         Layer.hide();
      }

      private function line(w:int, align:String) : TextField
      {
         var field:TextField = renderer.pin(renderer.label(0,0,12,align,"",w,20),w,12);
         this.rows.addChild(field);
         return field;
      }

      private function get ceiling() : int
      {
         return Layer.roomHigh <= 0 ? PAGE
              : Config.clamp((Layer.roomHigh - CHROME) / ROW,LEAST,PAGE,PAGE);
      }

      private function get widest() : int
      {
         return Layer.roomWide <= 0 ? BROAD
              : Config.clamp(Layer.roomWide - MARGIN,NARROW,BROAD,BROAD);
      }

      private function get inner() : int
      {
         return this.wide - PAD * 2;
      }

      public function get entryY() : int
      {
         return HEAD + PAD + this.page * ROW + PAD;
      }

      public function get deep() : int
      {
         return this.entryY + 28 + PAD;
      }

      private function settleView() : void
      {
         this.first = Config.clamp(this.first,0,Math.max(0,this.values.length - this.page),0);
      }

      private function refresh() : void
      {
         if(this.popup != null)
         {
            this.frame.graphics.clear();
            renderer.framed(this.frame,0,0,this.wide,this.deep,renderer.PANEL,renderer.CYAN,1);
            renderer.fill(this.frame,1,1,this.wide - 2,HEAD - 1,renderer.HEADER,1);
            renderer.fill(this.frame,1,HEAD,this.wide - 2,1,renderer.CYAN,0.85);
            this.paintCloser();
            this.repaintRows();
            this.entry.paint();
            this.lightAdder();
         }
         this.paint();
      }

      private function repaintRows() : void
      {
         var num:TextField = null;
         var text:TextField = null;
         var row:int = 0;
         var lit:Boolean = false;
         var held:Boolean = false;
         var i:int = 0;
         this.paper.graphics.clear();
         renderer.fill(this.paper,0,0,this.inner,this.page * ROW,renderer.PANEL,0);
         while(i < this.page)
         {
            row = this.first + i;
            num = this.nums[i] as TextField;
            text = this.texts[i] as TextField;
            lit = row == this.hover || row == this.carried;
            held = row == this.carried;
            num.visible = text.visible = row < this.values.length;
            if(num.visible)
            {
               if(lit)
               {
                  renderer.fill(this.paper,0,i * ROW,this.inner,ROW,renderer.HEADER,1);
               }
               if(held)
               {
                  renderer.fill(this.paper,0,i * ROW,2,ROW,renderer.CYAN,1);
               }
               this.ring(GUTTER >> 1,i * ROW + (ROW >> 1),
                         this.armed && lit ? renderer.DANGER
                                           : lit ? renderer.VALUE : renderer.LABEL);
               num.x = GUTTER;
               renderer.centre(num,i * ROW,ROW);
               num.text = String(row + 1);
               num.textColor = held ? renderer.CYAN : renderer.LABEL;
               text.x = TEXT_X;
               renderer.centre(text,i * ROW,ROW);
               text.text = String(this.values[row]);
               renderer.elide(text,text.width);
               text.textColor = renderer.VALUE;
            }
            i++;
         }
         this.blank();
         this.rail();
      }

      private function blank() : void
      {
         var text:TextField = this.texts[0] as TextField;
         if(this.values.length > 0)
         {
            return;
         }
         text.visible = true;
         text.x = GUTTER;
         renderer.centre(text,0,ROW);
         text.text = this.noneText;
         text.textColor = renderer.LABEL;
      }

      private function ring(x:int, y:int, color:uint) : void
      {
         this.paper.graphics.lineStyle(1.5,color & 0xFFFFFF,renderer.solidity(color));
         this.paper.graphics.drawCircle(x,y,RING);
         this.paper.graphics.moveTo(x - 3,y);
         this.paper.graphics.lineTo(x + 3,y);
         this.paper.graphics.lineStyle();
      }

      private function rail() : void
      {
         var span:int = this.page * ROW;
         if(this.values.length <= this.page)
         {
            return;
         }
         renderer.fill(this.paper,this.inner - 3,0,3,span,renderer.HEADER,1);
         renderer.fill(this.paper,this.inner - 3,span * this.first / this.values.length,3,
                       Math.max(8,span * this.page / this.values.length),renderer.BORDER,1);
      }

      private function under() : int
      {
         var slot:int = this.rows.mouseY < 0 ? -1 : int(this.rows.mouseY / ROW);
         return slot < 0 || slot >= this.page || this.first + slot >= this.values.length
              ? -1 : this.first + slot;
      }

      private function onTrack(e:MouseEvent) : void
      {
         var was:int = this.hover;
         var wasArmed:Boolean = this.armed;
         if(this.popup == null || this.carried >= 0)
         {
            return;
         }
         this.hover = this.under();
         this.armed = this.hover >= 0 && this.rows.mouseX < GUTTER;
         if(this.hover != was || this.armed != wasArmed)
         {
            this.repaintRows();
         }
      }

      private function onLeave(e:MouseEvent) : void
      {
         if(this.popup != null && this.carried < 0)
         {
            this.hover = -1;
            this.armed = false;
            this.repaintRows();
         }
      }

      private function onWheel(e:MouseEvent) : void
      {
         var was:int = this.first;
         if(this.popup == null || this.carried >= 0)
         {
            return;
         }
         this.first = Config.clamp(this.first + renderer.wheel(e,3),0,
                                   Math.max(0,this.values.length - this.page),this.first);
         if(this.first != was)
         {
            this.onTrack(e);
            this.repaintRows();
         }
      }

      private function onPress(e:MouseEvent) : void
      {
         if(this.popup == null || this.armed || this.under() < 0)
         {
            return;
         }
         this.carried = this.under();
         this.hover = this.carried;
         this.began = this.literal;
         this.rows.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onCarry);
         this.rows.stage.addEventListener(MouseEvent.MOUSE_UP,this.onDrop);
         this.repaintRows();
      }

      private function onCarry(e:MouseEvent) : void
      {
         var to:int = 0;
         if(this.carried < 0 || this.rows == null)
         {
            this.drop();
            return;
         }
         to = this.under();
         if(to >= 0 && to != this.carried)
         {
            this.move(this.carried,to);
            this.carried = this.hover = to;
            this.repaintRows();
            e.updateAfterEvent();
         }
      }

      private function onDrop(e:MouseEvent) : void
      {
         var moved:Boolean = this.carried >= 0 && this.literal != this.began;
         this.drop();
         if(moved)
         {
            Option.click();
            this.announce();
         }
         this.refresh();
      }

      private function drop() : void
      {
         this.carried = -1;
         if(this.rows != null && this.rows.stage != null)
         {
            this.rows.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onCarry);
            this.rows.stage.removeEventListener(MouseEvent.MOUSE_UP,this.onDrop);
         }
      }

      private function onStrike(e:MouseEvent) : void
      {
         if(this.popup == null || this.hover < 0 || !this.armed)
         {
            return;
         }
         Option.click();
         this.values.splice(this.hover,1);
         this.hover = -1;
         this.armed = false;
         this.settleView();
         this.announce();
         this.refresh();
      }

      private static function tick(plate:Plate) : void
      {
         var mid:int = Input.BOX >> 1;
         plate.face.graphics.lineStyle(2,plate.caption.textColor,1);
         plate.face.graphics.moveTo(8,mid);
         plate.face.graphics.lineTo(11,mid + 4);
         plate.face.graphics.lineTo(18,mid - 4);
         plate.face.graphics.lineStyle();
      }

      private function lightAdder() : void
      {
         this.adder.live = this.entry.value.length > 0;
         this.adder.paint();
      }

      private function onTyping(e:Event) : void
      {
         if(this.popup != null)
         {
            this.lightAdder();
         }
      }

      private function onKey(e:KeyboardEvent) : void
      {
         if(e.keyCode == Keyboard.ENTER)
         {
            this.onAdd(null);
         }
      }

      private function onAdd(e:Event = null) : void
      {
         var got:int = 0;
         if(this.popup == null || this.entry.value.length == 0)
         {
            return;
         }
         got = this.take(this.entry.value);
         this.entry.value = "";
         if(got == 0)
         {
            Option.click(false);
            this.refresh();
            return;
         }
         Option.click();
         this.first = Math.max(0,this.values.length - this.page);
         this.announce();
         this.refresh();
      }

      private function onClosed(e:Event) : void
      {
         this.drop();
         dispatchEvent(new Event(Event.CLOSE));
         this.popup = null;
         this.frame = null;
         this.rows = null;
         this.paper = null;
         this.entry = null;
         this.adder = null;
         this.title = null;
         this.closer = null;
         this.nums = [];
         this.texts = [];
         this.paint();
      }
   }
}
