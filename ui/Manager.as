package ui
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;

   public class Manager extends Sprite
   {

      private static const PAD:int = 14;

      private static const HEAD:int = 36;

      private static const LEFT:int = 196;

      private static const ROW:int = 30;

      private static const LINES:int = 2;

      private static const GAP:int = 7;

      private static const BAND:int = 12;

      private static const BTN:int = 22;

      private static const BTN_GAP:int = 6;

      public static const SWITCH:String = "switch";

      private static const FIND:int = 36;

      public var aside:Function;

      public var swf:String = "";

      public var key:String = "";

      public var literal:String = "";

      public var id:String = "";

      public var line:String;

      private var mods:Object = {};

      private var order:Array = [];

      private var index:int = -1;

      private var rows:Array = [];

      private var panel:Sprite = new Sprite();

      private var panelBox:Shape = new Shape();

      private var picks:Sprite = new Sprite();

      private var pickClip:Sprite = new Sprite();

      private var pickRail:Scrollbar = new Scrollbar();

      private var search:Input = new Input("","",LEFT - PAD * 2,
                                          IggyFunctions.translate("$Marketplace_SearchButton"));

      private var missField:TextField;

      private var picksDeep:int = 0;

      private var pickScroll:Number = 0;

      private var clip:Sprite = new Sprite();

      private var body:Sprite = new Sprite();

      private var rail:Scrollbar = new Scrollbar();

      private var titleField:TextField;

      private var emptyField:TextField;

      private var closeBtn:Plate = new Plate(BTN,BTN,13);

      private var readBtn:Plate = new Plate(BTN,BTN,13);

      private var asideBtn:Plate = new Plate(BTN,BTN,13);

      public var asideTitle:String = "";

      public var asideTip:String = "";

      private var readField:TextField;

      private var reading:Boolean = false;

      private var reported:Boolean = false;

      private var covered:Array = [];

      private var span:int;

      private var high:int;

      private var scroll:Number = 0;

      public function Manager(span:int, high:int)
      {
         super();
         this.span = span;
         this.high = high;
         addChild(this.panel);
         this.panel.addChild(this.panelBox);
         this.titleField = renderer.label(PAD,0,14,TextFieldAutoSize.LEFT,"MOD SETTINGS",
                                          240,24,false,true);
         this.panel.addChild(this.titleField);
         this.emptyField = renderer.label(0,0,12,TextFieldAutoSize.CENTER,"",300,40);
         this.panel.addChild(this.emptyField);
         this.closeBtn.text = "×";
         this.closeBtn.driven = true;
         this.closeBtn.tipTitle = "Close";
         this.closeBtn.tip = "Closes the window.";
         this.closeBtn.anchor = this.headTip;
         this.panel.addChild(this.closeBtn);
         this.readBtn.text = "?";
         this.readBtn.driven = true;
         this.readBtn.tipTitle = "About this mod";
         this.readBtn.tip = "What the mod says about itself, in its author's words. Press it again for the settings.";
         this.readBtn.anchor = this.headTip;
         this.panel.addChild(this.readBtn);
         this.asideBtn.driven = true;
         this.asideBtn.anchor = this.headTip;
         this.panel.addChild(this.asideBtn);
         this.panel.addEventListener(MouseEvent.CLICK,this.onHeadClick);
         this.panel.addEventListener(MouseEvent.MOUSE_MOVE,this.onHeadHover);
         this.readField = renderer.label(0,0,12,TextFieldAutoSize.LEFT,"",200,20);
         this.readField.wordWrap = true;
         this.readField.multiline = true;
         this.body.addChild(this.readField);
         this.search.driven = true;
         this.search.x = PAD;
         this.search.y = HEAD + PAD;
         this.search.addEventListener(Event.CHANGE,this.onFind);
         this.panel.addChild(this.search);
         this.missField = renderer.label(PAD,HEAD + PAD + FIND,11,TextFieldAutoSize.LEFT,
                                         IggyFunctions.translate("$Marketplace_NoResults"),
                                         LEFT - PAD * 2,32,true);
         this.panel.addChild(this.missField);
         this.pickClip.addChild(this.picks);
         this.pickClip.y = HEAD + PAD + FIND;
         this.panel.addChild(this.pickClip);
         this.clip.addChild(this.body);
         this.clip.x = LEFT + PAD;
         this.clip.y = HEAD + PAD;
         this.panel.addChild(this.clip);
         this.pickRail.attach(this.panel);
         this.pickRail.moved = this.slidePicks;
         this.rail.attach(this.panel);
         this.rail.moved = this.slide;
         this.panel.addEventListener(MouseEvent.MOUSE_WHEEL,this.onWheel);
         this.panel.addEventListener(MouseEvent.MOUSE_DOWN,this.onRailDown);
         addEventListener(MouseEvent.CLICK,this.onSwallow);
         addEventListener(MouseEvent.MOUSE_WHEEL,this.onSwallow);
         addEventListener(FocusEvent.FOCUS_OUT,this.onShut);
      }

      private function onSwallow(e:MouseEvent) : void
      {
         e.stopPropagation();
      }

      public function get shown() : Boolean
      {
         return this.parent != null;
      }

      public function get count() : int
      {
         return this.order.length;
      }

      private var stale:Boolean = false;

      public function offer(name:String, value:String) : Boolean
      {
         var at:int = 0;
         var parts:Array = null;
         var title:String = null;
         var record:Object = Hub.parse(name,value);
         if(record == null)
         {
            return false;
         }
         record.id = name;
         record.raw = value;
         title = String(record.title);
         if(this.mods[title] == null)
         {
            this.mods[title] = [];
            this.order.push(title);
            this.order.sort(byName);
         }
         parts = this.mods[title] as Array;
         at = this.partAt(parts,name);
         if(at < 0)
         {
            parts.push(record);
            parts.sort(byGroup);
         }
         else
         {
            if(String((parts[at] as Object).raw) == value)
            {
               return true;
            }
            parts[at] = record;
         }
         if(this.shown)
         {
            this.restate();
         }
         return true;
      }

      private function restate() : void
      {
         if(Layer.open || this.typing)
         {
            this.stale = true;
            return;
         }
         this.rebuild();
      }

      private function get typing() : Boolean
      {
         return this.stage != null && this.stage.focus is TextField;
      }

      private function onShut(e:Event) : void
      {
         if(this.stale && !Layer.open && !this.typing)
         {
            this.rebuild();
         }
      }

      private function partAt(parts:Array, name:String) : int
      {
         var i:int = 0;
         while(i < parts.length)
         {
            if((parts[i] as Object).id == name)
            {
               return i;
            }
            i++;
         }
         return -1;
      }

      private static function byName(a:String, b:String) : int
      {
         var one:String = a.toLowerCase();
         var two:String = b.toLowerCase();
         return one < two ? -1 : (one > two ? 1 : 0);
      }

      private static function byGroup(a:Object, b:Object) : int
      {
         var one:String = String(a.group).toLowerCase();
         var two:String = String(b.group).toLowerCase();
         return one < two ? -1 : (one > two ? 1 : 0);
      }

      private function get story() : String
      {
         var parts:Array = this.chosen;
         var i:int = 0;
         while(parts != null && i < parts.length)
         {
            if(String((parts[i] as Object).readme).length > 0)
            {
               return String((parts[i] as Object).readme);
            }
            i++;
         }
         return "";
      }

      private function get chosen() : Array
      {
         return this.index < 0 || this.index >= this.order.length
              ? null : this.mods[this.order[this.index]] as Array;
      }

      public function resize(span:int, high:int) : void
      {
         this.span = span;
         this.high = high;
      }

      public function show(host:DisplayObjectContainer) : void
      {
         var kid:DisplayObject = null;
         var i:int = 0;
         this.search.value = "";
         this.pickScroll = 0;
         this.covered = [];
         while(i < host.numChildren)
         {
            kid = host.getChildAt(i);
            if(kid.visible)
            {
               kid.visible = false;
               this.covered.push(kid);
            }
            i++;
         }
         Layer.frame(this.span,this.high);
         host.addChild(this);
         this.rebuild();
         Option.watch(this.stage,true);
      }

      public function hide() : void
      {
         var i:int = 0;
         this.flush();
         this.rail.release();
         this.pickRail.release();
         Layer.hide();
         Option.hideTip();
         Option.watch(this.stage,false);
         while(i < this.covered.length)
         {
            (this.covered[i] as DisplayObject).visible = true;
            i++;
         }
         this.covered = [];
         if(this.parent != null)
         {
            this.parent.removeChild(this);
         }
      }

      private function rebuild() : void
      {
         var cat:Cat = null;
         var option:Option = null;
         var specs:Array = null;
         var record:Object = null;
         var parts:Array = null;
         var open:Object = null;
         var i:int = 0;
         var j:int = 0;
         if(this.index < 0 && this.order.length > 0)
         {
            this.index = 0;
         }
         parts = this.chosen;
         open = this.folds();
         this.stale = false;
         this.strip();
         if(this.reading && this.story.length > 0)
         {
            this.paint();
            return;
         }
         while(parts != null && i < parts.length)
         {
            record = parts[i];
            cat = new Cat(String(record.group),this.inner);
            cat.open = open[record.id] == null ? true : Boolean(open[record.id]);
            cat.name = String(record.id);
            cat.addEventListener(Event.SELECT,this.onFold);
            this.body.addChild(cat);
            this.rows.push(cat);
            specs = record.options as Array;
            j = 0;
            while(cat.open && j < specs.length)
            {
               option = this.control(specs[j]);
               if(option != null)
               {
                  option.tip = String((specs[j] as Object).note);
                  option.anchor = this.tipAt;
                  option.reflow();
                  option.from = String((specs[j] as Object).value);
                  option.addEventListener(Event.CHANGE,this.onChange);
                  option.addEventListener(Event.CLOSE,this.onShut);
                  this.body.addChild(option);
                  this.rows.push(option);
               }
               j++;
            }
            i++;
         }
         this.paint();
      }

      private function tipAt(option:Option) : Point
      {
         return Tip.beside(this,this.span,
                           this.clip.y + option.y - this.scroll + option.tall * 0.5);
      }

      private function folds() : Object
      {
         var cat:Cat = null;
         var out:Object = {};
         var i:int = 0;
         while(i < this.rows.length)
         {
            cat = this.rows[i] as Cat;
            if(cat != null)
            {
               out[cat.name] = cat.open;
            }
            i++;
         }
         return out;
      }

      private function flush() : void
      {
         var i:int = 0;
         while(i < this.rows.length)
         {
            (this.rows[i] as Option).settle();
            i++;
         }
      }

      private function strip() : void
      {
         var option:Option = null;
         var i:int = 0;
         this.flush();
         while(i < this.rows.length)
         {
            option = this.rows[i] as Option;
            option.removeEventListener(Event.CHANGE,this.onChange);
            option.removeEventListener(Event.CLOSE,this.onShut);
            option.removeEventListener(Event.SELECT,this.onFold);
            this.body.removeChild(option);
            i++;
         }
         this.rows = [];
      }

      private function get inner() : int
      {
         return this.span - LEFT - PAD * 2 - 8;
      }

      private function get view() : int
      {
         return this.high - HEAD - PAD * 2;
      }

      private function get picksView() : int
      {
         return this.view - FIND;
      }

      private function get matched() : Array
      {
         var needle:String = this.search.value.toLowerCase();
         var out:Array = [];
         var i:int = 0;
         while(i < this.order.length)
         {
            if(needle.length == 0
            || String(this.order[i]).toLowerCase().indexOf(needle) >= 0)
            {
               out.push(i);
            }
            i++;
         }
         return out;
      }

      private function control(spec:Object) : Option
      {
         var w:int = this.inner;
         var values:Array = [];
         var labels:Array = [];
         var choices:Array = spec.choices as Array;
         var i:int = 0;
         switch(String(spec.type))
         {
            case Hub.CHECK:
               return new Check(String(spec.key),String(spec.label),w);
            case Hub.SLIDER:
               return new Slider(String(spec.key),String(spec.label),w,
                                 Number(spec.min),Number(spec.max),Number(spec.step),
                                 int(spec.places),String(spec.zero),String(spec.suffix));
            case Hub.SPIN:
               return new Spin(String(spec.key),String(spec.label),w,
                               Number(spec.max),Number(spec.min),Number(spec.step),
                               int(spec.places),String(spec.suffix));
            case Hub.STEPPER:
               return new Stepper(String(spec.key),String(spec.label),w,
                                  Number(spec.min),Number(spec.max),Number(spec.step),
                                  int(spec.places),String(spec.zero),String(spec.suffix));
            case Hub.COMBO:
               while(i < choices.length)
               {
                  values.push((choices[i] as Array)[0]);
                  labels.push((choices[i] as Array)[1]);
                  i++;
               }
               return new Combo(String(spec.key),String(spec.label),w,values,labels);
            case Hub.COLOR:
               return new Picker(String(spec.key),String(spec.label),w);
            case Hub.ALPHA:
               return new AlphaPicker(String(spec.key),String(spec.label),w);
            case Hub.INPUT:
               return new Input(String(spec.key),String(spec.label),w);
            case Hub.LIST:
               return new List(String(spec.key),String(spec.label),w,
                               String(spec.prompt).length > 0 ? String(spec.prompt) : List.PROMPT);
            case Hub.HEADING:
               return new Heading(String(spec.label),w);
         }
         return null;
      }

      private function gapAfter(at:int) : int
      {
         var next:Option = at + 1 < this.rows.length ? this.rows[at + 1] as Option : null;
         return this.rows[at] is Cat || next is Cat ? BAND : GAP;
      }

      private function get told() : Boolean
      {
         return this.reading && this.story.length > 0;
      }

      private function get content() : int
      {
         var total:int = 0;
         var i:int = 0;
         if(this.told)
         {
            return int(this.readField.height);
         }
         while(i < this.rows.length)
         {
            total += (this.rows[i] as Option).tall + this.gapAfter(i);
            i++;
         }
         return total;
      }

      public function paint() : void
      {
         this.panelBox.graphics.clear();
         renderer.fill(this.panelBox,0,0,this.span,this.high,renderer.PANEL,1);
         renderer.fill(this.panelBox,0,0,this.span,HEAD,renderer.HEADER,1);
         renderer.fill(this.panelBox,0,HEAD,this.span,1,renderer.CYAN,0.85);
         renderer.fill(this.panelBox,LEFT,HEAD + 1,1,this.high - HEAD - 1,renderer.BORDER,1);
         renderer.border(this.panelBox,0,0,this.span,this.high,renderer.ROW);

         this.titleField.textColor = renderer.VALUE;
         renderer.centre(this.titleField,0,HEAD);
         this.closeBtn.x = this.span - PAD - BTN;
         this.closeBtn.y = (HEAD - BTN) / 2;
         this.closeBtn.paint();
         this.readBtn.visible = this.story.length > 0;
         this.readBtn.x = this.leftOf(this.closeBtn);
         this.readBtn.y = this.closeBtn.y;
         this.readBtn.on = this.reading;
         this.readBtn.paint();
         this.asideBtn.visible = this.aside != null;
         this.asideBtn.mark = this.aside;
         this.asideBtn.tipTitle = this.asideTitle;
         this.asideBtn.tip = this.asideTip;
         this.asideBtn.x = this.leftOf(this.readBtn);
         this.asideBtn.y = this.closeBtn.y;
         this.asideBtn.paint();

         this.guard(this.paintPicks,"picks");
         this.guard(this.paintRows,"rows");
      }

      private function leftOf(plate:Plate) : int
      {
         return plate.visible ? plate.x - BTN - BTN_GAP : plate.x;
      }

      private function headTip(plate:Plate) : Point
      {
         return Tip.beside(this,this.span,plate.y + BTN * 0.5,plate.x + BTN * 0.5);
      }

      private function guard(step:Function, tag:String) : void
      {
         try
         {
            step();
         }
         catch(err:Error)
         {
            if(!this.reported)
            {
               this.reported = true;
               Hub.write(Hub.ADDRESS,"lasterror",
                         tag + " " + err.errorID + " " + err.name + ": " + err.message);
            }
         }
      }

      private function paintPicks() : void
      {
         var pick:Sprite = null;
         var skin:Shape = null;
         var face:TextField = null;
         var tall:int = 0;
         var at:int = 0;
         var shown:Array = this.matched;
         var of:int = 0;
         var i:int = 0;
         while(this.picks.numChildren > 0)
         {
            this.picks.removeChildAt(0);
         }
         this.search.visible = this.order.length > 0;
         this.search.paint();
         this.missField.visible = this.order.length > 0 && shown.length == 0;
         this.missField.textColor = renderer.LABEL;
         while(i < shown.length)
         {
            of = int(shown[i]);
            face = renderer.label(PAD,0,11,TextFieldAutoSize.LEFT,"",LEFT - PAD * 2,20);
            this.wrapName(face,String(this.order[of]));
            face.textColor = of == this.index ? renderer.VALUE : renderer.LABEL;
            tall = Math.max(ROW,int(face.textHeight) + 12);
            pick = new Sprite();
            pick.y = at;
            pick.name = String(of);
            pick.buttonMode = true;
            pick.mouseChildren = false;
            skin = new Shape();
            renderer.fill(skin,0,0,LEFT,tall - 1,
                          of == this.index ? renderer.HEADER : renderer.PANEL,1);
            if(of == this.index)
            {
               renderer.fill(skin,0,0,2,tall - 1,renderer.CYAN,1);
            }
            pick.addChild(skin);
            renderer.centre(face,0,tall - 1);
            pick.addChild(face);
            pick.addEventListener(MouseEvent.CLICK,this.onPick);
            this.picks.addChild(pick);
            at += tall;
            i++;
         }
         this.picksDeep = at;
         this.clipPicks();
      }

      private function clipPicks() : void
      {
         var view:int = this.picksView;
         this.pickScroll = Config.clamp(this.pickScroll,0,
                                        Math.max(0,this.picksDeep - view),0);
         this.pickClip.scrollRect = new Rectangle(0,this.pickScroll,LEFT,view);
         this.pickRail.x = LEFT - Scrollbar.W;
         this.pickRail.y = HEAD + PAD + FIND;
         this.pickRail.fit(view,this.picksDeep,this.pickScroll);
      }

      private function slidePicks(where:Number) : void
      {
         this.pickScroll = where;
         this.clipPicks();
      }

      private function wrapName(face:TextField, name:String) : void
      {
         var body:String = name;
         face.autoSize = TextFieldAutoSize.NONE;
         face.wordWrap = true;
         face.multiline = true;
         face.width = LEFT - PAD * 2;
         renderer.say(face,body);
         while(face.numLines > LINES && body.length > 1)
         {
            body = body.substring(0,body.length - 2);
            renderer.say(face,body + "…");
         }
         face.height = face.textHeight + 6;
      }

      private function paintRows() : void
      {
         var option:Option = null;
         var at:int = 0;
         var i:int = 0;
         this.readField.visible = this.told;
         if(this.told)
         {
            this.emptyField.visible = false;
            this.readField.autoSize = TextFieldAutoSize.NONE;
            this.readField.width = this.inner;
            renderer.say(this.readField,this.story);
            this.readField.height = this.readField.textHeight + 8;
            this.readField.textColor = renderer.VALUE;
            this.slide(this.scroll);
            return;
         }
         this.emptyField.visible = this.rows.length == 0;
         if(this.rows.length == 0)
         {
            this.emptyField.x = LEFT + (this.span - LEFT - 300) / 2;
            this.emptyField.textColor = renderer.LABEL;
            this.emptyField.text = this.order.length == 0
                                 ? "No mod has published settings yet."
                                 : "This mod declared no options.";
            renderer.centre(this.emptyField,0,this.high);
         }
         while(i < this.rows.length)
         {
            option = this.rows[i] as Option;
            option.y = at;
            at += option.tall + this.gapAfter(i);
            i++;
         }
         i = 0;
         while(i < this.rows.length)
         {
            (this.rows[i] as Option).paint();
            i++;
         }
         this.slide(this.scroll);
      }

      private function slide(where:Number) : void
      {
         var view:int = this.view;
         this.scroll = Config.clamp(where,0,Math.max(0,this.content - view),0);
         this.clip.scrollRect = new Rectangle(0,this.scroll,this.inner,view);
         this.rail.x = this.span - Scrollbar.W;
         this.rail.y = HEAD + PAD;
         this.rail.fit(view,this.content,this.scroll);
      }

      private function onRead(e:MouseEvent) : void
      {
         Option.click();
         Option.hideTip();
         this.reading = !this.reading;
         this.scroll = 0;
         this.rebuild();
      }

      private function onFind(e:Event) : void
      {
         this.pickScroll = 0;
         this.guard(this.paintPicks,"picks");
      }

      private function onFold(e:Event) : void
      {
         Option.hideTip();
         this.rebuild();
      }

      private function onPick(e:MouseEvent) : void
      {
         var at:int = int((e.currentTarget as Sprite).name);
         if(at == this.index)
         {
            return;
         }
         Option.click();
         Option.hideTip();
         this.index = at;
         this.scroll = 0;
         this.reading = false;
         this.rebuild();
      }

      private function onWheel(e:MouseEvent) : void
      {
         if(this.panel.mouseX < LEFT)
         {
            this.slidePicks(this.pickScroll + renderer.wheel(e));
            return;
         }
         this.slide(this.scroll + renderer.wheel(e));
      }

      private function onRailDown(e:MouseEvent) : void
      {
         var at:Point = new Point(this.panel.mouseX,this.panel.mouseY);
         this.pickRail.press(at);
         this.rail.press(at);
      }

      private function onChange(e:Event) : void
      {
         var record:Object = null;
         var spec:Object = null;
         var option:Option = e.currentTarget as Option;
         var found:Array = this.specFor(option.key);
         if(found == null)
         {
            return;
         }
         record = found[0];
         spec = found[1];
         this.literal = spec.emit == "bool"
                      ? (Config.flag(option.literal) ? "true" : "false")
                      : option.literal;
         spec.value = this.literal;
         this.swf = String(record.swf);
         this.key = option.key;
         this.id = String(record.id);
         this.line = Hub.restate(String(record.raw),this.key,this.literal);
         if(this.line != null)
         {
            record.raw = this.line;
         }
         dispatchEvent(new Event(Event.CHANGE));
         this.paintRows();
      }

      private function specFor(name:String) : Array
      {
         var specs:Array = null;
         var parts:Array = this.chosen;
         var i:int = 0;
         var j:int = 0;
         while(parts != null && i < parts.length)
         {
            specs = (parts[i] as Object).options as Array;
            j = 0;
            while(j < specs.length)
            {
               if((specs[j] as Object).key == name)
               {
                  return [parts[i],specs[j]];
               }
               j++;
            }
            i++;
         }
         return null;
      }

      private function holds(plate:Plate) : Boolean
      {
         var x:Number = this.panel.mouseX;
         var y:Number = this.panel.mouseY;
         return x >= plate.x && x < plate.x + BTN && y >= plate.y && y < plate.y + BTN;
      }

      private function onHeadClick(e:MouseEvent) : void
      {
         if(this.panel.mouseY >= HEAD)
         {
            this.search.press(new Point(this.panel.mouseX,this.panel.mouseY));
            return;
         }
         if(this.holds(this.closeBtn))
         {
            this.onDismiss(e);
         }
         else if(this.readBtn.visible && this.holds(this.readBtn))
         {
            this.onRead(e);
         }
         else if(this.asideBtn.visible && this.holds(this.asideBtn))
         {
            Option.click();
            dispatchEvent(new Event(SWITCH));
         }
      }

      private function onHeadHover(e:MouseEvent) : void
      {
         var at:Point = new Point(this.panel.mouseX,this.panel.mouseY);
         var live:Boolean = at.y < HEAD;
         this.search.lit(at);
         this.pickRail.hover(at);
         this.rail.hover(at);
         var closeHot:Boolean = live && this.holds(this.closeBtn);
         var readHot:Boolean = live && this.readBtn.visible && this.holds(this.readBtn);
         var asideHot:Boolean = live && this.asideBtn.visible && this.holds(this.asideBtn);
         if(closeHot != this.closeBtn.hovered)
         {
            this.closeBtn.hovered = closeHot;
         }
         if(readHot != this.readBtn.hovered)
         {
            this.readBtn.hovered = readHot;
         }
         if(asideHot != this.asideBtn.hovered)
         {
            this.asideBtn.hovered = asideHot;
         }
      }

      private function onDismiss(e:MouseEvent) : void
      {
         Option.click();
         this.hide();
         dispatchEvent(new Event(Event.CLOSE));
      }
   }
}
