package ui
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFieldType;
   import flash.ui.Keyboard;

   public class Combo extends Option
   {

      public static const BOX:int = 22;

      public static const ROW:int = 22;

      private static const PAGE:int = 10;

      private static const ARROW_W:int = 8;

      private static const ARROW_H:int = 5;

      private static const HUNT:int = 24;

      public var index:int = 0;

      public var values:Array;

      public var labels:Array;

      public var boxes:Boolean = false;

      /** Asked for, never assumed. A field that takes the keyboard is a field that takes
       *  it from the game, so a list only gets one where the screen says it is long enough
       *  to be worth that. */
      public var hunts:Boolean = false;

      private var face:TextField;

      private var menu:Sprite;

      private var slots:Array = [];

      private var rows:Array = [];

      private var find:TextField;

      private var hint:TextField;

      private var query:String = "";

      private var hover:int = -1;

      private var first:int = 0;

      private var hot:Boolean = false;

      private var held:int = 0;

      private var menuW:int = CTRL;

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
         return this.index < 0 || this.index >= this.labels.length ? ""
              : String(this.labels[this.index]);
      }

      public function choose(i:int) : void
      {
         this.index = Config.clamp(i,0,Math.max(0,this.values.length - 1),0);
         this.held = this.index;
         this.paint();
      }

      public function reset(values:Array, labels:Array = null) : void
      {
         this.values = values;
         this.labels = labels == null ? values : labels;
         this.choose(0);
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
         renderer.say(this.face,this.summary);
         renderer.elide(this.face,this.face.width);
         this.face.textColor = renderer.VALUE;
      }

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

      public function get searchable() : Boolean
      {
         return this.hunts && this.values.length > PAGE;
      }

      private function get lid() : int
      {
         return this.searchable ? HUNT : 0;
      }

      private function get open() : int
      {
         return Math.min(this.slots.length,this.rows.length);
      }

      private function onHover(e:MouseEvent) : void
      {
         this.hot = e.type == MouseEvent.ROLL_OVER;
         this.paint();
      }

      private function onFace(e:MouseEvent) : void
      {
         if(this.menu != null || Layer.shut(this))
         {
            Layer.hide();
            return;
         }
         Option.click();
         this.build();
         Layer.show(this.menu,this,this.lane,(this.tall - BOX) / 2 + BOX + 1);
         if(this.find != null && stage != null)
         {
            stage.focus = this.find;
         }
         this.paint();
      }

      private function build() : void
      {
         var field:TextField = null;
         var i:int = 0;
         this.menu = new Sprite();
         this.menu.mouseChildren = this.searchable;
         this.menuW = this.menuWide;
         this.slots = [];
         this.query = "";
         while(i < this.page)
         {
            field = renderer.pin(renderer.label(0,0,12,TextFieldAutoSize.LEFT,"",
                                                this.menuW - 34,20),this.menuW - 34,12);
            this.slots.push(field);
            this.menu.addChild(field);
            i++;
         }
         if(this.searchable)
         {
            this.hunt();
         }
         this.sift();
         this.first = Config.clamp(this.index - (this.page >> 1),0,
                                   Math.max(0,this.rows.length - this.page),0);
         this.menu.addEventListener(MouseEvent.MOUSE_MOVE,this.onTrack);
         this.menu.addEventListener(MouseEvent.ROLL_OUT,this.onLeave);
         this.menu.addEventListener(MouseEvent.MOUSE_WHEEL,this.onWheel);
         this.menu.addEventListener(MouseEvent.CLICK,this.onPick);
         this.menu.addEventListener(Event.REMOVED_FROM_STAGE,this.onClosed);
         this.hover = -1;
         this.repaintMenu();
      }

      /** A list longer than a page gets a field to narrow it with. The field is the
       *  search: Iggy routes the keyboard at a focused TextField and nowhere else, so a
       *  box the player clicks into is the only kind that can be typed in at all. */
      private function hunt() : void
      {
         this.hint = this.line(this.menuW - 18);
         renderer.say(this.hint,"Type to search");
         this.menu.addChild(this.hint);
         this.find = this.line(this.menuW - 18);
         this.find.type = TextFieldType.INPUT;
         this.find.selectable = true;
         this.find.mouseEnabled = true;
         this.find.addEventListener(Event.CHANGE,this.onHunt);
         this.menu.addChild(this.find);
      }

      private function line(wide:int) : TextField
      {
         return renderer.pin(renderer.label(0,0,12,TextFieldAutoSize.LEFT,"",wide,20),wide,12);
      }

      private function onHunt(e:Event) : void
      {
         this.query = this.find.text;
         this.first = 0;
         this.hover = -1;
         this.sift();
         this.repaintMenu();
      }

      private function sift() : void
      {
         var want:String = this.query.toLowerCase();
         var i:int = 0;
         this.rows = [];
         while(i < this.values.length)
         {
            if(want.length == 0 || String(this.labels[i]).toLowerCase().indexOf(want) >= 0)
            {
               this.rows.push(i);
            }
            i++;
         }
         this.first = Config.clamp(this.first,0,Math.max(0,this.rows.length - this.page),0);
      }

      public function repaintMenu() : void
      {
         var field:TextField = null;
         var row:int = 0;
         var top:int = 0;
         var i:int = 0;
         var live:int = this.open;
         var deep:int = this.lid + live * ROW + 2;
         if(this.menu == null)
         {
            return;
         }
         this.menu.graphics.clear();
         renderer.framed(this.menu,0,0,this.menuW,deep,renderer.PANEL,renderer.CYAN,1);
         if(this.searchable)
         {
            this.paintHunt();
         }
         while(i < this.slots.length)
         {
            field = this.slots[i] as TextField;
            field.visible = i < live;
            if(field.visible)
            {
               row = int(this.rows[this.first + i]);
               top = this.lid + 1 + i * ROW;
               if(row == this.hover)
               {
                  renderer.fill(this.menu,1,top,this.menuW - 2,ROW,renderer.HEADER,1);
               }
               if(this.boxes)
               {
                  renderer.framed(this.menu,9,top + 5,11,11,renderer.HEADER,
                                  this.marked(row) ? renderer.CYAN : renderer.BORDER,1);
                  if(this.marked(row))
                  {
                     renderer.accent(this.menu,11,top + 7,7,7);
                  }
               }
               field.x = this.boxes ? 26 : 9;
               renderer.centre(field,top,ROW);
               renderer.say(field,String(this.labels[row]));
               renderer.elide(field,field.width);
               field.textColor = this.marked(row) ? renderer.CYAN
                               : row == this.hover ? renderer.VALUE : renderer.LABEL;
            }
            i++;
         }
         this.rail(deep);
      }

      private function paintHunt() : void
      {
         renderer.fill(this.menu,1,1,this.menuW - 2,HUNT - 1,renderer.HEADER,1);
         renderer.fill(this.menu,1,HUNT,this.menuW - 2,1,renderer.BORDER,1);
         this.find.x = 9;
         this.hint.x = 9;
         renderer.centre(this.find,1,HUNT);
         renderer.centre(this.hint,1,HUNT);
         this.find.textColor = renderer.VALUE;
         this.hint.textColor = renderer.LABEL;
         this.hint.visible = this.find.text.length == 0;
      }

      private function rail(deep:int) : void
      {
         var live:int = this.open;
         var span:int = deep - 2 - this.lid;
         if(live == 0 || this.rows.length <= live)
         {
            return;
         }
         renderer.fill(this.menu,this.menuW - 4,1 + this.lid,3,span,renderer.HEADER,1);
         renderer.fill(this.menu,this.menuW - 4,
                       1 + this.lid + span * this.first / this.rows.length,
                       3,Math.max(8,span * live / this.rows.length),renderer.LABEL,1);
      }

      public function get menuWide() : int
      {
         var field:TextField = null;
         var most:Number = 0;
         var room:int = Layer.roomWide;
         var i:int = 0;
         if(room <= CTRL)
         {
            return CTRL;
         }
         field = renderer.label(0,0,12,TextFieldAutoSize.LEFT,"",0,20);
         while(i < this.labels.length)
         {
            renderer.say(field,String(this.labels[i]));
            if(field.textWidth > most)
            {
               most = field.textWidth;
            }
            i++;
         }
         return Config.clamp(Math.ceil(most) + 38,CTRL,room - 8,CTRL);
      }

      private function onTrack(e:MouseEvent) : void
      {
         var was:int = this.hover;
         var slot:int = int((this.menu.mouseY - 1 - this.lid) / ROW);
         this.hover = this.menu.mouseY < this.lid || slot < 0 || slot >= this.open
                    ? -1 : int(this.rows[this.first + slot]);
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
                                   Math.max(0,this.rows.length - this.open),this.first);
         if(this.first != was)
         {
            this.onTrack(e);
            this.repaintMenu();
         }
      }

      private function onPick(e:MouseEvent) : void
      {
         if(this.menu.mouseY < this.lid)
         {
            return;
         }
         if(this.hover >= 0 && this.hover < this.values.length)
         {
            Option.click();
            this.pick(this.hover);
         }
      }

      /** The field is taken off the display list with the menu, and a field that had the
       *  keyboard has to hand it back or the engine keeps sending keys at a box nobody
       *  can see. */
      private function onClosed(e:Event) : void
      {
         if(this.find != null && stage != null && stage.focus == this.find)
         {
            stage.focus = null;
            if(IggyFunctions.inIggy)
            {
               ExternalInterface.call("UIComponent.OnTextfieldFocusOut");
            }
         }
         this.menu = null;
         this.find = null;
         this.hint = null;
         this.slots = [];
         this.rows = [];
         this.paint();
      }
   }
}
