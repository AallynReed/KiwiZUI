package
{
   import flash.display.Sprite;
   import flash.display.StageAlign;
   import flash.display.StageScaleMode;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import ui.*;

   /** Every control in the shared lib, laid out to be looked at rather than asserted
    *  against. Gallery is the harness; this is the picture.
    *
    *  Live, not a mockup: the dropdowns open, the sliders drag, the pickers pick. What
    *  is on screen is the same code the screens compile against, so a shot of this
    *  cannot show something the mods do not have. */
   public class Demo extends Sprite
   {

      private static const W:int = 900;

      private static const H:int = 480;

      private static const COL:int = 344;

      private static const LEFT:int = 40;

      private static const RIGHT:int = 500;

      private static const HEAD:int = 44;

      private var titleText:TextField;

      private var heads:Array = [];

      private var search:Input = new Input("","",COL,"Search, as a screen would use it");

      private var title:Input = new Input("title","Window title",COL,"Effects");

      private var descriptions:Check = new Check("descriptions","Show descriptions",COL);

      private var locked:Check = new Check("hidelocked","Hide locked subclasses",COL);

      private var sort:Combo = new Combo("sort","Sort by",COL,
                                         ["game","level","power","name"],
                                         ["Game order","Level","Power rank","Name"]);

      private var show:Multi = new Multi("show","Show",COL,["locked","current","maxed"],
                                         ["Locked","Current class","Maxed out"]);

      private var columns:Stepper = new Stepper("columns","Columns",COL,0,8,1,0,"Auto");

      private var gap:Spin = new Spin("gap","Row gap",COL,40,4,2,0,"px");

      private var warn:Slider = new Slider("warnred","Red under",COL,0,900,15,0,"Off","s");

      private var accent:Picker = new Picker("accent","Accent",COL);

      private var panelColor:AlphaPicker = new AlphaPicker("panel","Panel color",COL);

      private var push:Button = new Button(120,30,13,"PUSH");

      private var latch:Button = new Button(120,30,13,"LATCH",Button.LATCH);

      private var plates:Array = [];

      private var bar:Bar = new Bar(250);

      private var tabs:Array = [];

      public function Demo()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.onStage);
      }

      private function onStage(e:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onStage);
         stage.scaleMode = StageScaleMode.NO_SCALE;
         stage.align = StageAlign.TOP_LEFT;
         Layer.frame(W,H);
         this.build();
         Option.watch(stage,true);
         this.paint();
      }

      /** Set to something other than every default, because a row of untouched
       *  controls shows what they look like and not what they do. */
      private function build() : void
      {
         var plate:Plate = null;
         var tab:Tab = null;
         var i:int = 0;
         this.titleText = renderer.label(LEFT,0,15,TextFieldAutoSize.LEFT,
                                         "ZAKROS UI - SHARED CONTROLS",400,24,false,true);
         addChild(this.titleText);

         this.search.value = "gem";
         this.title.value = "Effects";
         this.descriptions.value = true;
         this.sort.from = "power";
         this.show.from = "locked,maxed";
         this.columns.from = "3";
         this.gap.from = "12";
         this.warn.from = "120";
         this.accent.from = "#5FD3E8";
         this.panelColor.from = "#3A7AB8B3";

         while(i < 3)
         {
            plate = new Plate(58,24,11);
            plate.text = ["GAME","LEVEL","NAME"][i];
            plate.on = i == 1;
            this.plates.push(plate);
            addChild(plate);
            tab = new Tab();
            tab.selected = i == 0;
            this.tabs.push(tab);
            addChild(tab);
            i++;
         }
         this.bar.setBar(7,12);

         addChild(this.search);
         addChild(this.title);
         addChild(this.descriptions);
         addChild(this.locked);
         addChild(this.sort);
         addChild(this.show);
         addChild(this.columns);
         addChild(this.gap);
         addChild(this.warn);
         addChild(this.accent);
         addChild(this.panelColor);
         addChild(this.push);
         addChild(this.latch);
         addChild(this.bar);
         this.latch.selected = true;
      }

      private function head(body:String, x:int, y:int) : void
      {
         var field:TextField = renderer.label(x,y,10,TextFieldAutoSize.LEFT,body,200,16,false,true);
         field.textColor = renderer.CYAN;
         this.heads.push(field);
         addChild(field);
      }

      private function place(control:Option, x:int, y:int) : void
      {
         control.x = x;
         control.y = y;
         control.paint();
      }

      private function paint() : void
      {
         var i:int = 0;
         graphics.clear();
         renderer.fill(this,0,0,W,H,renderer.PANEL,1);
         renderer.fill(this,0,0,W,HEAD,renderer.HEADER,1);
         renderer.fill(this,0,HEAD,W,1,renderer.CYAN,0.85);
         renderer.fill(this,RIGHT - 58,HEAD + 20,1,H - HEAD - 44,renderer.BORDER,1);
         this.titleText.y = (HEAD - this.titleText.height) / 2;

         this.head("TEXT",LEFT,HEAD + 22);
         this.place(this.search,LEFT,HEAD + 44);
         this.place(this.title,LEFT,HEAD + 78);

         this.head("CHOICE",LEFT,HEAD + 124);
         this.place(this.descriptions,LEFT,HEAD + 146);
         this.place(this.locked,LEFT,HEAD + 178);
         this.place(this.sort,LEFT,HEAD + 210);
         this.place(this.show,LEFT,HEAD + 242);

         this.head("NUMBER",LEFT,HEAD + 288);
         this.place(this.columns,LEFT,HEAD + 310);
         this.place(this.gap,LEFT,HEAD + 342);
         this.place(this.warn,LEFT,HEAD + 374);

         this.head("COLOR",RIGHT,HEAD + 22);
         this.place(this.accent,RIGHT,HEAD + 44);
         this.place(this.panelColor,RIGHT,HEAD + 76);

         this.head("BUTTONS",RIGHT,HEAD + 122);
         this.push.x = RIGHT;
         this.push.y = HEAD + 144;
         this.latch.x = RIGHT + 130;
         this.latch.y = HEAD + 144;
         while(i < this.plates.length)
         {
            (this.plates[i] as Plate).x = RIGHT + i * 64;
            (this.plates[i] as Plate).y = HEAD + 186;
            (this.plates[i] as Plate).paint();
            (this.tabs[i] as Tab).x = RIGHT + i * 30;
            (this.tabs[i] as Tab).y = HEAD + 320;
            i++;
         }

         this.head("PROGRESS",RIGHT,HEAD + 232);
         this.bar.x = RIGHT;
         this.bar.y = HEAD + 258;

         this.head("TABS",RIGHT,HEAD + 296);
      }
   }
}
