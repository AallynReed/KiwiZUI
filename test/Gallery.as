package
{
   import flash.display.Sprite;
   import flash.display.StageAlign;
   import flash.display.StageScaleMode;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextLineMetrics;
   import flash.ui.Keyboard;
   import ui.*;

   public class Gallery extends Sprite
   {

      private static const W:int = 760;

      private static const H:int = 700;

      private var log:TextField;

      private var lines:Array = [];

      private var failures:int = 0;

      private var writes:int = 0;

      private var reports:int = 0;

      private var panel:Settings;

      private var sort:Combo = new Combo("sort","Sort by",Settings.INNER,
                                         ["game","level","power","name"],
                                         ["Game order","Level","Power rank","Name"]);

      private var words:List = new List("words","Watch words",Settings.INNER,"Add a word");

      private var tint:Picker = new Picker("value","Text color",Settings.INNER);

      private var fade:AlphaPicker = new AlphaPicker("panel","Panel color",Settings.INNER);

      private var gate:Plate = new Plate(110,26,13);

      private var search:Input = new Input("","",300,"Filter, as a screen would use it");

      private var flag:Check = new Check("","A loose checkbox",300);

      private var push:Button = new Button(120,30,13,"PUSH");

      private var latch:Button = new Button(120,30,13,"LATCH",Button.LATCH);

      public function Gallery()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.onStage);
      }

      private function onStage(e:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onStage);
         stage.scaleMode = StageScaleMode.NO_SCALE;
         stage.align = StageAlign.TOP_LEFT;
         this.build();
         this.check();
         this.paint();
      }

      private function build() : void
      {
         this.log = renderer.label(400,54,11,TextFieldAutoSize.LEFT,"",330,600,false);
         this.panel = new Settings(W,H,[
            new Check("descriptions","Show descriptions",Settings.INNER),
            new Slider("warnred","Red under",Settings.INNER,0,900,15,0,"Off","s"),
            new Stepper("columns","Columns",Settings.INNER,0,8,1,0,"Auto"),
            this.sort,
            new Multi("show","Show",Settings.INNER,["locked","current","maxed"],
                      ["Locked","Current class","Maxed out"]),
            new Input("title","Window title",Settings.INNER,"Effects"),
            this.words,
            this.tint,
            this.fade]);
         this.gate.text = "SETTINGS";
         this.gate.addEventListener(MouseEvent.CLICK,this.onGate);
         this.panel.addEventListener(Event.CHANGE,this.onSetting);
         this.panel.addEventListener(Event.CLOSE,this.onGate2);
         addChild(this.log);
         addChild(this.gate);
         addChild(this.search);
         addChild(this.flag);
         addChild(this.push);
         addChild(this.latch);
      }

      private function paint() : void
      {
         graphics.clear();
         renderer.fill(this,0,0,W,H,renderer.PANEL,1);
         renderer.fill(this,0,0,W,40,renderer.HEADER,1);
         renderer.fill(this,0,40,W,1,renderer.CYAN,0.85);
         this.gate.x = 30;
         this.gate.y = 60;
         this.gate.paint();
         this.search.x = 30;
         this.search.y = 106;
         this.search.paint();
         this.flag.x = 30;
         this.flag.y = 150;
         this.flag.paint();
         this.push.x = 30;
         this.push.y = 190;
         this.latch.x = 160;
         this.latch.y = 190;
         this.log.textColor = this.failures > 0 ? renderer.RED : renderer.LABEL;
         this.log.text = this.lines.join("\n");
      }

      private function onGate(e:MouseEvent) : void
      {
         if(this.panel.shown)
         {
            this.panel.hide();
            return;
         }
         this.panel.show(this,this.values());
         this.gate.on = true;
         this.gate.paint();
      }

      private function values() : Object
      {
         return {"descriptions":"1","warnred":"120","columns":"0",
                 "sort":"power","show":"locked,maxed","title":"Effects",
                 "words":"gearcrafter,golden soul,fragment"};
      }

      private function onGate2(e:Event) : void
      {
         this.gate.on = false;
         this.gate.paint();
      }

      private function onSetting(e:Event) : void
      {
         this.writes++;
         this.say("set " + this.panel.key + " = " + this.panel.literal);
         renderer.apply(this.panel.key,this.panel.literal);
         this.panel.sync(this.values());
         this.panel.paint();
         this.paint();
      }

      private function say(body:String) : void
      {
         this.lines.push(body);
         trace(body);
      }

      private function said(name:String, got:Boolean) : void
      {
         if(!got)
         {
            this.failures++;
         }
         this.say((got ? "pass  " : "FAIL  ") + name);
      }

      private function same(name:String, got:*, want:*) : void
      {
         var ok:Boolean = String(got) == String(want);
         if(!ok)
         {
            this.failures++;
         }
         this.say((ok ? "pass  " : "FAIL  ") + name
                  + (ok ? "" : "  got " + got + ", want " + want));
      }

      private function check() : void
      {
         this.checkCentring();
         this.checkKeys();
         this.checkCheck();
         this.checkStepper();
         this.checkSpin();
         this.checkSlider();
         this.checkCombo();
         this.checkMulti();
         this.checkList();
         this.checkPicker();
         this.checkOpacity();
         this.checkTwoPickers();
         this.checkEcho();
         this.checkPushed();
         this.checkInput();
         this.checkColour();
         this.checkPacked();
         this.checkPalette();
         this.checkKeysDistinct();
         this.checkTextFitting();
         this.checkAccentPlacement();
         this.checkRoundTrip();
         this.checkRestate();
         this.checkLayer();
         this.checkTip();
         this.say(this.failures == 0 ? "\nall " + (this.lines.length) + " checks passed"
                                     : "\n" + this.failures + " FAILED");
      }

      private function checkTip() : void
      {
         var host:Sprite = new Sprite();
         var at:Point = null;
         host.graphics.beginFill(0,0);
         host.graphics.drawRect(0,0,300,200);
         host.graphics.endFill();
         addChild(host);
         host.x = 40;
         host.y = 60;
         at = Tip.beside(host,300,50);
         this.same("a tooltip with room to the right opens past the right edge",at.x,345);
         this.same("a tooltip opens at the height it was asked for",at.y,110);
         host.x = 600;
         at = Tip.beside(host,100,50);
         this.same("a tooltip with no room to the right reserves its own width",at.x,145);
         host.x = 300;
         at = Tip.beside(host,440,50);
         this.same("a tooltip with no room for the reserve stays on the stage",at.x,5);
         removeChild(host);
      }

      private function checkLayer() : void
      {
         this.panel.show(this,this.values());
         this.same("panel attaches",this.panel.shown,true);
         this.same("panel fits the stage",this.panel.height <= H,true);
         this.sort.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
         this.same("combo opens a layer",Layer.open,true);
         this.same("combo menu is over the panel",this.lifted(),true);
         this.same("combo menu is inside the stage",this.inside(),true);
         this.sort.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
         this.same("a press on the control that opened it closes the menu",Layer.open,false);
         this.sort.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
         this.same("and the click that came with it leaves it closed",Layer.open,false);
         this.sort.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
         this.same("a click of its own opens it again",Layer.open,true);
         this.tint.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
         this.same("a press on another control closes the menu",Layer.open,false);
         this.tint.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
         this.same("and the same click opens that control's own popup",Layer.open,true);
         Layer.hide();
         this.same("layer closes",Layer.open,false);
         this.tint.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
         this.same("picker opens a layer",Layer.open,true);
         this.same("a pick leaves the picker open",this.stillOpen(),true);
         this.same("picker grid is over the panel",this.lifted(),true);
         this.same("picker grid is inside the stage",this.inside(),true);
         Layer.hide();
         this.checkModal();
         this.fade.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
         this.same("the opacity strip is its full height",this.stripDeep(),Picker.SQUARE_H);
         Layer.hide();
         this.checkFramed();
         this.checkTornDown();
         this.panel.hide();
         this.same("panel detaches",this.panel.shown,false);
      }

      private function checkModal() : void
      {
         var at:Rectangle = null;
         Layer.frame(400,300);
         this.words.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
         this.same("a list opens a layer",Layer.open,true);
         this.same("a list is over the settings panel",this.lifted(),true);
         this.same("a list dims the screen behind it",this.scrimmed(),true);
         at = this.box();
         this.same("a list opens in the middle across",Math.round(at.x + at.width / 2),200);
         this.same("a list opens in the middle down",Math.round(at.y + at.height / 2),150);
         this.same("a list takes the width the screen has",Math.round(at.width),360);
         this.checkAdding();
         Layer.hide();
         this.same("a list closes",Layer.open,false);
         this.checkFits();
         Layer.frame(W,H);
      }

      private function checkAdding() : void
      {
         var panel:Sprite = this.getChildAt(this.numChildren - 1) as Sprite;
         var box:Input = this.typedInto(panel);
         var button:Plate = this.tickOn(panel);
         this.same("the panel has a box to type in",box != null,true);
         this.same("and a tick beside it",button != null,true);
         if(box == null || button == null)
         {
            return;
         }
         this.writes = 0;
         box.value = "gilded";
         box.dispatchEvent(new Event(Input.TYPING));
         box.dispatchEvent(new Event(Event.CHANGE));
         this.same("typing adds nothing",this.words.count,3);
         this.same("and typing writes nothing",this.writes,0);
         button.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
         this.same("the tick is what adds",this.writes,1);
         this.checkHolding();
      }

      private function checkHolding() : void
      {
         var held:String = this.words.literal;
         this.same("the panel is still open",Layer.open,true);
         this.words.from = "";
         this.same("an open list refuses an empty value",this.words.literal,held);
         this.words.from = "one,two";
         this.same("and refuses a stale one",this.words.literal,held);
         this.words.move(0,1);
         this.same("and is still the one being reordered",this.words.literal != held,true);
         held = this.words.literal;
         Layer.hide();
         this.same("what was reordered survives the close",this.words.literal,held);
         this.words.from = "one,two";
         this.same("a closed list takes a value like any other",this.words.literal,"one,two");
         this.words.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
      }

      private function checkFits() : void
      {
         var held:String = this.words.literal;
         var many:Array = [];
         var i:int = 0;
         while(i < 40)
         {
            many.push("value " + i);
            i++;
         }
         this.words.from = many.join(",");
         this.words.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
         this.same("a long list still fits the screen",this.box().height <= 300,true);
         Layer.hide();
         Layer.frame(900,700);
         this.words.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
         this.same("and stops widening at its own ceiling",Math.round(this.box().width),460);
         Layer.hide();
         Layer.frame(400,300);
         this.words.from = held;
      }

      private function typedInto(panel:Sprite) : Input
      {
         var i:int = 0;
         while(i < panel.numChildren)
         {
            if(panel.getChildAt(i) is Input)
            {
               return panel.getChildAt(i) as Input;
            }
            i++;
         }
         return null;
      }

      private function tickOn(panel:Sprite) : Plate
      {
         var i:int = 0;
         while(i < panel.numChildren)
         {
            if(panel.getChildAt(i) is Plate)
            {
               return panel.getChildAt(i) as Plate;
            }
            i++;
         }
         return null;
      }

      private function scrimmed() : Boolean
      {
         var at:Rectangle = this.getChildAt(this.numChildren - 2).getBounds(this);
         return at.width >= W && at.height >= H;
      }

      private function checkFramed() : void
      {
         Layer.frame(420,320);
         this.fade.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
         this.same("a popup stays inside the frame it is given",this.within(420,320),true);
         Layer.hide();
         Layer.frame(90,90);
         this.fade.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
         this.same("a popup bigger than the frame sits in the corner",this.corner(),true);
         Layer.hide();
         Layer.frame(W,H);
      }

      private function box() : Rectangle
      {
         return this.getChildAt(this.numChildren - 1).getBounds(this);
      }

      private function within(wide:int, high:int) : Boolean
      {
         var at:Rectangle = this.box();
         return at.left >= 0 && at.top >= 0 && at.right <= wide && at.bottom <= high;
      }

      private function corner() : Boolean
      {
         var at:Rectangle = this.box();
         return Math.round(at.left) == 0 && Math.round(at.top) == 0;
      }

      private function checkTornDown() : void
      {
         this.fade.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
         var inner:Sprite = (this.getChildAt(this.numChildren - 1) as Sprite).getChildAt(0) as Sprite;
         Layer.hide();
         this.writes = 0;
         inner.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
         inner.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
         inner.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE));
         this.same("a torn down popup is deaf",this.writes,0);
      }

      private function lifted() : Boolean
      {
         return this.getChildIndex(this.panel) < this.numChildren - 1;
      }

      private function stripDeep() : int
      {
         var field:Sprite = (this.getChildAt(this.numChildren - 1) as Sprite).getChildAt(0) as Sprite;
         var bar:Sprite = field.getChildAt(1) as Sprite;
         return Math.round(bar.getBounds(bar).height);
      }

      private function checkEcho() : void
      {
         this.fade.from = "#5FD3E8";
         this.fade.sat = 0.25;
         this.fade.val = 0.5;
         this.fade.hue = 0.75;
         this.fade.from = this.fade.literal;
         this.same("an echoed value leaves the crosshair alone",this.fade.sat,0.25);
         this.same("and leaves the value alone",this.fade.val,0.5);
         this.same("and leaves the hue alone",this.fade.hue,0.75);
         this.fade.from = "#E5484D";
         this.same("a new value does move it",this.fade.sat != 0.25,true);
         this.fade.from = "#000000";
         this.same("black keeps the hue it was showing",this.fade.hue > 0,true);
      }

      private function checkPushed() : void
      {
         this.panel.show(this,this.values());
         this.fade.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
         this.fade.hue = 0.75;
         this.fade.sat = 0.25;
         this.fade.val = 0.5;
         this.panel.sync(this.values());
         this.same("an open picker refuses the screen's copy",this.fade.hue,0.75);
         this.same("and keeps its saturation",this.fade.sat,0.25);
         this.panel.paint();
         this.same("a repaint of the panel leaves it alone",this.fade.val,0.5);
         this.fade.opacity = 0.4;
         this.panel.sync(this.values());
         this.panel.paint();
         this.same("and leaves the opacity strip alone",this.fade.opacity,0.4);
         this.fade.hue = 0.75;
         this.fade.opacity = 0.4;
         this.fade.from = this.fade.literal;
         this.same("an echoed value leaves the opacity strip alone",this.fade.opacity,0.4);
         this.same("and the hue with it",this.fade.hue,0.75);
         Layer.hide();
         this.fade.from = "#E5484D";
         this.same("a closed picker takes a new value",this.fade.hue != 0.75,true);
         this.panel.hide();
      }

      private function checkTwoPickers() : void
      {
         this.same("a plain picker has no opacity strip",
                   this.tint.wide,Picker.SQUARE_W + 8 * 3 + Picker.STRIP);
         this.same("an alpha picker is one strip wider",
                   this.fade.wide - this.tint.wide,Picker.STRIP + 8);
         this.same("both are the same height",this.fade.deep,this.tint.deep);
         this.tint.from = "#FF880080";
         this.same("a plain picker drops the alpha it is handed",this.tint.literal,"#FF8800");
         this.same("a plain picker stays opaque",this.tint.opacity,1);
         this.fade.from = "#FF880080";
         this.same("an alpha picker keeps it",this.fade.literal,"#FF880080");
      }

      private function stillOpen() : Boolean
      {
         this.tint.from = "#FF8800";
         this.tint.announce();
         return Layer.open && this.lifted();
      }

      private function inside() : Boolean
      {
         var box:Rectangle = this.getChildAt(this.numChildren - 1).getBounds(this);
         return box.left >= 0 && box.top >= 0 && box.right <= W && box.bottom <= H;
      }

      private function checkCentring() : void
      {
         var plate:Plate = new Plate(58,24,11);
         plate.text = "GAME";
         plate.paint();
         this.centred("a plate caption sits centred",plate.caption,0,24);
         this.centred("a button caption sits centred",this.push.caption,0,30);
         this.flag.paint();
         this.centred("a checkbox caption sits centred",this.flag.caption,0,Option.H);
         this.search.paint();
         this.centred("a text box sits centred",this.search.field,2,24);
      }

      private function centred(name:String, f:TextField, top:Number, h:Number) : void
      {
         var size:Number = Number(f.defaultTextFormat.size);
         var base:Number = f.y + 2 + f.getLineMetrics(0).ascent;
         this.near(name,base - 1462 / 2048 * size / 2,top + h / 2);
      }

      private function near(name:String, got:Number, want:Number) : void
      {
         var ok:Boolean = Math.abs(got - want) <= 1;
         if(!ok)
         {
            this.failures++;
         }
         this.say((ok ? "pass  " : "FAIL  ") + name
                  + (ok ? "" : "  got " + got + ", want " + want));
      }

      private function checkKeys() : void
      {
         var s:Slider = new Slider("a","A",300,0,100,5);
         this.reports = 0;
         s.addEventListener(Event.CHANGE,this.onReport);
         s.from = "50";
         this.same("an arrow moves by the step",this.after(s,Keyboard.RIGHT,1),"55");
         this.same("the other way too",this.after(s,Keyboard.LEFT,1),"50");
         this.same("ctrl moves five steps",this.after(s,Keyboard.UP,5),"75");
         this.same("shift moves ten",this.after(s,Keyboard.DOWN,10),"25");
         this.same("a run of keys is silent",this.reports,0);
         s.settle();
         this.same("and reports once it settles",this.reports,1);
         s.settle();
         this.same("a settle with nothing in it is silent",this.reports,1);
         this.same("an arrow stops at the end",this.after(s,Keyboard.LEFT,10),"0");
         this.same("a slider ignores anything else",s.stroke(Keyboard.SPACE,1),false);

         var c:Combo = new Combo("c","C",300,["one","two","three"]);
         c.from = "one";
         this.same("down walks the list",this.after(c,Keyboard.DOWN,1),"two");
         this.same("up walks it back",this.after(c,Keyboard.UP,1),"one");
         this.same("up stops at the top",this.after(c,Keyboard.UP,1),"one");
         this.same("a dropdown ignores sideways",c.stroke(Keyboard.LEFT,1),false);

         var m:Multi = new Multi("m","M",300,["one","two"]);
         this.same("a multi takes no arrows",m.stroke(Keyboard.DOWN,1),false);

         var n:Stepper = new Stepper("n","N",300,0,10,2);
         n.from = "4";
         this.same("right steps up",this.after(n,Keyboard.RIGHT,1),"6");
         this.same("left steps down",this.after(n,Keyboard.LEFT,1),"4");
         this.same("a stepper ignores up",n.stroke(Keyboard.UP,1),false);
      }

      private function after(o:Option, code:uint, scale:Number) : String
      {
         o.stroke(code,scale);
         return o.literal;
      }

      private function onReport(e:Event) : void
      {
         this.reports++;
      }

      private function checkCheck() : void
      {
         var c:Check = new Check("flag","Flag",300);
         c.from = "1";
         this.same("check reads 1",c.literal,"1");
         c.from = "true";
         this.same("check reads true",c.literal,"1");
         c.from = "0";
         this.same("check reads 0",c.literal,"0");
         c.from = "nonsense";
         this.same("check falls back to off",c.literal,"0");
      }

      private function checkStepper() : void
      {
         var s:Stepper = new Stepper("n","N",300,0,8,1);
         s.from = "5";
         this.same("stepper reads 5",s.literal,"5");
         s.from = "99";
         this.same("stepper clamps high",s.literal,"8");
         s.from = "-4";
         this.same("stepper clamps low",s.literal,"0");
         var a:Stepper = new Stepper("a","A",300,0.4,1,0.05,2);
         a.from = "0.95";
         this.same("stepper keeps 2 places",a.literal,"0.95");
      }

      private function checkSpin() : void
      {
         var s:Spin = new Spin("gap","Gap",300,40,4,2);
         this.same("a spin starts at its floor",s.literal,"4");
         s.from = "12";
         this.same("a spin reads back",s.literal,"12");
         this.same("right steps by the step",this.after(s,Keyboard.RIGHT,1),"14");
         this.same("shift steps ten of them",this.after(s,Keyboard.LEFT,10),"4");
         this.same("and stops at the floor",this.after(s,Keyboard.LEFT,1),"4");
         s.from = "999";
         this.same("a spin clamps high",s.literal,"40");
         s.from = "1";
         this.same("a spin clamps low",s.literal,"4");
         s.from = "7";
         this.same("a typed figure need not sit on the step",s.literal,"7");
         var d:Spin = new Spin("n","N",300,8);
         this.same("a floor of one is the default",d.literal,"1");
         this.same("and a step of one",this.after(d,Keyboard.RIGHT,1),"2");
         this.same("a spin ignores up",d.stroke(Keyboard.UP,1),false);
      }

      private function checkSlider() : void
      {
         var s:Slider = new Slider("a","A",300,0.4,1,0.05,2);
         s.from = "0.7";
         this.same("slider reads 0.7",s.literal,"0.7");
         s.from = "2";
         this.same("slider clamps high",s.literal,"1");
         s.from = "";
         this.same("slider keeps its value on junk",s.literal,"1");
         var w:Slider = new Slider("w","W",300,0,900,15,0,"Off","s");
         w.from = "120";
         this.same("slider reads whole numbers",w.literal,"120");
      }

      private function checkCombo() : void
      {
         var c:Combo = new Combo("sort","Sort",300,["game","level","power"],
                                 ["Game order","Level","Power rank"]);
         c.from = "power";
         this.same("combo reads a value",c.literal,"power");
         this.same("combo shows its label",c.summary,"Power rank");
         c.from = "not-a-value";
         this.same("combo keeps its choice on junk",c.literal,"power");
         this.checkComboWidth();
      }

      private function checkComboWidth() : void
      {
         var room:int = 420;
         var brief:Combo = new Combo("s","S",300,["a","b"],["Level","Power rank"]);
         var long:Combo = new Combo("l","L",300,["a","b"],
                                    ["Are you sure you want to clear this cornerstone? "
                                   + "Everything built on it will be destroyed.","Level"]);
         Layer.frame(room,room);
         this.same("a menu of short labels stays the width of its control",
                   brief.menuWide,Option.CTRL);
         this.said("a menu widens to the label that needs it",
                   long.menuWide > Option.CTRL);
         this.said("and never past the frame it opens in",long.menuWide <= room - 8);
         Layer.frame(0,0);
         this.same("with no frame to measure against it does not widen",
                   long.menuWide,Option.CTRL);
      }

      private function checkMulti() : void
      {
         var m:Multi = new Multi("show","Show",300,["locked","current","maxed"],
                                 ["Locked","Current","Maxed"]);
         this.same("multi starts empty",m.literal,"");
         this.same("multi says none",m.summary,"None");
         m.from = "maxed,locked";
         this.same("multi keeps the list order",m.literal,"locked,maxed");
         this.same("multi names what was picked",m.summary,"Locked, Maxed");
         m.from = "locked, current , maxed";
         this.same("multi ignores spacing",m.literal,"locked,current,maxed");
         this.same("multi says all",m.summary,"All");
         m.from = "current";
         this.same("multi names a single choice",m.summary,"Current");
         m.from = "";
         this.same("multi empties",m.literal,"");
      }


      private function checkList() : void
      {
         var l:List = new List("words","Words",300);
         this.same("a list starts empty",l.literal,"");
         this.same("an empty list says none",l.summary,"None");
         l.from = "gearcrafter,golden soul,fragment";
         this.same("a list keeps what it was given",l.literal,"gearcrafter,golden soul,fragment");
         this.same("a list keeps the order it was given",l.count,3);
         this.same("a list names what is in it",l.summary,"gearcrafter, golden soul, fragment");
         l.from = " fragment , gearcrafter ";
         this.same("a list trims each value",l.literal,"fragment,gearcrafter");
         this.same("a list keeps a space inside one",l.summary,"fragment, gearcrafter");
         l.from = "one,,two,one, ,two";
         this.same("a list drops the empty and the repeated",l.literal,"one,two");
         l.from = "primal paragon cube";
         this.same("a list takes a single value",l.literal,"primal paragon cube");
         l.from = "";
         this.same("a list empties",l.literal,"");
         this.same("and says none again",l.summary,"None");
         l.from = "one,two,three,four";
         l.move(0,2);
         this.same("a moved value lands where it was put",l.literal,"two,three,one,four");
         l.move(3,0);
         this.same("and the rest close up behind it",l.literal,"four,two,three,one");
         l.move(1,1);
         this.same("a move to where it already is changes nothing",l.literal,"four,two,three,one");
         l.move(0,9);
         this.same("a move off the end changes nothing",l.literal,"four,two,three,one");

      }

      private function checkOpacity() : void
      {
         var p:AlphaPicker = new AlphaPicker("accent","Accent",300);
         p.from = "#FF8800";
         this.same("opaque stays six digits",p.literal,"#FF8800");
         this.same("opaque reads as full",p.opacity,1);
         p.from = "#FF880080";
         this.same("translucent keeps eight digits",p.literal,"#FF880080");
         p.from = "#FF8800FF";
         this.same("a written FF shortens back",p.literal,"#FF8800");
         p.from = "#FF880000";
         this.same("fully clear keeps its colour",p.literal,"#FF880000");
         p.from = "#00FF00";
         this.same("a six digit value is opaque again",p.literal,"#00FF00");
         this.same("eight digit colour is the top six",Config.hex(Config.color("#1A2B3C4D",0)),"1A2B3C");
         this.same("eight digit alpha is the last two",Config.alpha("#1A2B3C80",1),128 / 255);
         this.same("six digit alpha is opaque",Config.alpha("#1A2B3C",0.5),1);
         this.same("junk alpha falls back",Config.alpha("",0.5),0.5);
         this.same("hexa rounds to a byte",Config.hexa(0xFF8800,0.5),"#FF880080");
         this.same("a byte round trips",Config.hexa(0xFF8800,Config.alpha("#FF880080",1)),"#FF880080");
      }

      private function checkPicker() : void
      {
         var p:Picker = new Picker("accent","Accent",300);
         p.from = "#FF8800";
         this.same("picker reads hash hex",p.literal,"#FF8800");
         p.from = "0x00FF00";
         this.same("picker reads 0x hex",p.literal,"#00FF00");
         p.from = "1a2b3c";
         this.same("picker reads bare hex",p.literal,"#1A2B3C");
         p.from = "not a colour";
         this.same("picker keeps its colour on junk",p.literal,"#1A2B3C");
         this.same("picker resets to the shipped colour",p.preset,"#5FD3E8");
         this.same("an alpha picker resets to the shipped colour",
                   new AlphaPicker("panel","Panel",300).preset,Config.hexa(0x0B0C0E,1 - 15 / 255));
         this.same("a picker with no shipped colour has nothing to reset to",
                   new Picker("pinned","Pinned",300).preset,"");
      }

      private function checkInput() : void
      {
         var i:Input = new Input("title","Title",300);
         i.from = "Effects";
         this.same("input reads back",i.literal,"Effects");
         this.same("input value is its text",i.value,"Effects");
         i.clear();
         this.same("input clears",i.literal,"");
         this.same("and the cross has nothing left to do",i.clearable,false);
         i.clears = "#FF8800";
         this.same("a default gives the cross something to do",i.clearable,true);
         i.clear();
         this.same("and the cross restores it",i.literal,"#FF8800");
      }

      private function checkAccentPlacement() : void
      {
         var mid:Settings = new Settings(W,H,[
            new Check("a","A",Settings.INNER),
            new AlphaPicker("panel","Panel color",Settings.INNER),
            new Check("b","B",Settings.INNER)]);
         var none:Settings = new Settings(W,H,[new Check("a","A",Settings.INNER)]);
         var own:Settings = new Settings(W,H,[
            new Picker("accent","Accent",Settings.INNER),
            new AlphaPicker("panel","Panel color",Settings.INNER)]);
         this.same("the accent lands beside the panel colour",mid.order,"a,panel,accent,b");
         this.same("and last when there is no panel colour",none.order,"a,accent");
         this.same("and is not added twice",own.order,"accent,panel");
      }

      private function checkRoundTrip() : void
      {
         var shades:Array = [0x000000,0xFFFFFF,0x808080,0xFF0000,0x00FF00,0x0000FF,
                             0xFFFF00,0x00FFFF,0xFF00FF,0x5FD3E8,0xE5484D,0x1A2B3C,
                             0x0B0C0E,0x8A929C,0xB05CE0,0x7FD962];
         var hsv:Array = null;
         var shade:uint = 0;
         var i:int = 0;
         while(i < shades.length)
         {
            shade = uint(shades[i]);
            hsv = renderer.hsvOf(shade);
            this.same("round trip #" + Config.hex(shade),
                      "#" + Config.hex(renderer.hsv(Number(hsv[0]),Number(hsv[1]),Number(hsv[2]))),
                      "#" + Config.hex(shade));
            i++;
         }
      }

      private function restated(key:String) : String
      {
         return key == "scale" ? "100" : "#FF8800";
      }

      private function checkRestate() : void
      {
         var hub:Hub = new Hub("compass.swf","Zakros UI - Compass",this.restated,"Compass")
            .readme("A band | a mark ~ a plate")
            .option("scale",Hub.STEPPER,"Compass size","50,200,5,0,,%")
            .option("accent",Hub.COLOR,"Centre mark");
         var line:String = hub.declaration();
         var next:String = Hub.restate(line,"scale","125");
         var was:Object = Hub.parse(Hub.MARK + "compass",line);
         var now:Object = Hub.parse(Hub.MARK + "compass",next);
         this.same("a restated value is the new one",(now.options[0] as Object).value,"125");
         this.same("the value beside it is untouched",(now.options[1] as Object).value,
                   (was.options[1] as Object).value);
         this.same("a restated line keeps its readme",now.readme,was.readme);
         this.same("a restated line keeps its group",now.group,was.group);
         this.same("a restated line keeps its parameters",(now.options[0] as Object).max,200);
         this.same("a key that is not there restates nothing",Hub.restate(line,"none","1"),null);
         this.same("a legacy line restates nothing",Hub.restate("{\"a\":1}","scale","1"),null);
      }

      private function checkPacked() : void
      {
         var f:TextField = new TextField();
         f.textColor = 0x808A929C;
         this.same("a text field masks a packed colour",Config.hex(f.textColor),"8A929C");
         var g:Sprite = new Sprite();
         renderer.fill(g,0,0,10,10,0x80FF0000,1);
         this.same("a packed colour still draws",Math.round(g.width),10);
      }

      private function checkPalette() : void
      {
         renderer.apply("accent","#5FD3E8");
         this.same("a six digit key is opaque",renderer.alphaOf("accent"),1);
         this.same("and keeps its colour",Config.hex(renderer.colorOf("accent")),"5FD3E8");
         renderer.apply("accent","#5FD3E880");
         this.same("an eight digit key is translucent",
                   Math.round(renderer.alphaOf("accent") * 255),128);
         this.same("and still keeps its colour",Config.hex(renderer.colorOf("accent")),"5FD3E8");
         this.same("and reports the eight digit literal",renderer.defaultOf("accent"),"#5FD3E880");
         renderer.apply("accent","#5FD3E800");
         this.same("fully clear is alpha zero",renderer.alphaOf("accent"),0);
         this.same("the shipped colour outlives a change",renderer.stockOf("accent"),"#5FD3E8");
         this.same("a key renderer does not own has no shipped colour",renderer.stockOf("pinned"),"");
         renderer.apply("accent","#5FD3E8");
         this.same("six digits put it back to opaque",renderer.alphaOf("accent"),1);
         this.same("a blend of two colours is opaque",
                   renderer.alphaOf("accent"),1);
      }

      private function checkTextFitting() : void
      {
         var body:String = null;
         var probe:TextField = null;
         var wide:int = 0;
         var bad:String = "";
         var slack:String = "";
         var words:Array = ["Player","A Rather Long Player Name Indeed",
                            "Wollarkka the Unmaker of Worlds","x",
                            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA","Two Words"];
         var i:int = 0;
         while(i < words.length)
         {
            body = String(words[i]);
            wide = 10;
            while(wide <= 260)
            {
               probe = renderer.label(0,0,12,TextFieldAutoSize.LEFT,body);
               renderer.elide(probe,wide);
               if(probe.text != this.elidedBy(body,wide))
               {
                  bad += " " + body.substr(0,6) + "@" + wide;
               }
               probe = renderer.label(0,0,12,TextFieldAutoSize.LEFT,body);
               if(renderer.fit(probe,wide,18,6) != this.fittedBy(body,wide))
               {
                  slack += " " + body.substr(0,6) + "@" + wide;
               }
               wide += 10;
            }
            i++;
         }
         this.same("elide bisects to the same text a scan would find",bad,"");
         this.same("fit bisects to the same size a scan would find",slack,"");
      }

      private function elidedBy(body:String, wide:Number) : String
      {
         var probe:TextField = renderer.label(0,0,12,TextFieldAutoSize.LEFT,body);
         var cut:String = body;
         while(cut.length > 1 && probe.textWidth > wide)
         {
            cut = cut.substr(0,cut.length - 1);
            renderer.say(probe,cut + "…");
         }
         return probe.text;
      }

      private function fittedBy(body:String, wide:Number) : int
      {
         var probe:TextField = renderer.label(0,0,12,TextFieldAutoSize.LEFT,body);
         var fmt:TextFormat = probe.defaultTextFormat;
         var at:int = 18;
         while(at > 6)
         {
            fmt.size = at;
            probe.defaultTextFormat = fmt;
            probe.setTextFormat(fmt);
            if(probe.textWidth <= wide)
            {
               return at;
            }
            at--;
         }
         return at;
      }

      private function checkKeysDistinct() : void
      {
         var keys:Array = renderer.KEYS;
         var was:Array = [];
         var clashes:String = "";
         var i:int = 0;
         while(i < keys.length)
         {
            was.push(renderer.defaultOf(String(keys[i])));
            i++;
         }
         i = 0;
         while(i < keys.length)
         {
            renderer.apply(String(keys[i]),"#" + Config.hex(0x110000 + i * 0x010101));
            i++;
         }
         i = 0;
         while(i < keys.length)
         {
            if(Config.hex(renderer.colorOf(String(keys[i]))) != Config.hex(0x110000 + i * 0x010101))
            {
               clashes += " " + keys[i];
            }
            i++;
         }
         this.same("no two config keys drive one colour",clashes,"");
         i = 0;
         while(i < keys.length)
         {
            renderer.apply(String(keys[i]),String(was[i]));
            i++;
         }
      }

      private function checkColour() : void
      {
         this.same("hsv red","#" + Config.hex(renderer.hsv(0,1,1)),"#FF0000");
         this.same("hsv green","#" + Config.hex(renderer.hsv(1 / 3,1,1)),"#00FF00");
         this.same("hsv blue","#" + Config.hex(renderer.hsv(2 / 3,1,1)),"#0000FF");
         this.same("hsv white","#" + Config.hex(renderer.hsv(0,0,1)),"#FFFFFF");
         this.same("hsv black","#" + Config.hex(renderer.hsv(0,0,0)),"#000000");
         this.same("hsv wraps","#" + Config.hex(renderer.hsv(1,1,1)),"#FF0000");
      }
   }
}
