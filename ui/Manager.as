package ui
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;

   /** Every mod's settings in one place: what has declared itself on the left, that
    *  mod's own options on the right.
    *
    *  Nothing here knows any mod but the one whose declaration it is reading. A mod
    *  states its options into this screen's config section and this screen builds the
    *  controls out of that statement, so a mod written after this one still appears in
    *  it and a mod uninstalled tomorrow costs nothing to take out.
    *
    *  A mod is one entry however many screens it has. Each screen declares separately -
    *  they are separate config sections and neither can read the other - so the parts
    *  are gathered back under the mod's name here, one foldable category each.
    *
    *  The controls are the ones a screen's own settings panel is built from. That is
    *  the point of the shared widgets: a foreign mod's slider is our slider, and
    *  behaves the way every other control in every Zakros screen behaves, rather than
    *  being a second and worse settings system living beside the first.
    *
    *  A change reports the SWF as well as the key, because the write does not go where
    *  this screen's own writes go - it is addressed to the declaring mod's section,
    *  and the host is what makes that call. */
   public class Manager extends Sprite
   {

      private static const PAD:int = 14;

      private static const HEAD:int = 36;

      private static const LEFT:int = 196;

      /** The shortest a mod entry can be. A mod name is long and not ours to shorten,
       *  so an entry takes a second line when it needs one and is cut only when two
       *  were not enough either. */
      private static const ROW:int = 30;

      private static const LINES:int = 2;

      private static const GAP:int = 7;

      /** Between a category and the rows under it, and between the last of those rows
       *  and the next category. A fold reads as a group only if the space around it is
       *  bigger than the space inside it. */
      private static const BAND:int = 12;

      /** The header buttons are square and this is that square. Their hit tests are
       *  measured off it and never off width and height, which Iggy reports as zero for
       *  a plate whose caption is one glyph. */
      private static const BTN:int = 22;

      public var swf:String = "";

      public var key:String = "";

      public var literal:String = "";

      private var mods:Object = {};

      private var order:Array = [];

      private var index:int = -1;

      private var rows:Array = [];

      private var panel:Sprite = new Sprite();

      private var picks:Sprite = new Sprite();

      private var pickClip:Sprite = new Sprite();

      private var pickRail:Shape = new Shape();

      private var picksDeep:int = 0;

      private var pickScroll:Number = 0;

      private var clip:Sprite = new Sprite();

      private var body:Sprite = new Sprite();

      private var rail:Shape = new Shape();

      private var titleField:TextField;

      private var emptyField:TextField;

      private var closeBtn:Plate = new Plate(BTN,BTN,13);

      /** Only there when the mod being read brought a readme. A button that is present
       *  and does nothing is worse than no button, and most mods will not write one. */
      private var readBtn:Plate = new Plate(BTN,BTN,13);

      private var readField:TextField;

      private var reading:Boolean = false;

      private var reported:Boolean = false;

      /** What was on screen before this opened, put back when it closes. This fills the
       *  window, so the host's own content underneath costs legibility and buys
       *  nothing - none of it shows and none of it can be reached. */
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
         this.titleField = renderer.label(PAD,0,14,TextFieldAutoSize.LEFT,"MOD SETTINGS",
                                          240,24,false,true);
         this.panel.addChild(this.titleField);
         this.emptyField = renderer.label(0,0,12,TextFieldAutoSize.CENTER,"",300,40);
         this.panel.addChild(this.emptyField);
         this.closeBtn.text = "×";
         this.closeBtn.driven = true;
         this.panel.addChild(this.closeBtn);
         this.readBtn.text = "?";
         this.readBtn.driven = true;
         this.panel.addChild(this.readBtn);
         this.panel.addEventListener(MouseEvent.CLICK,this.onHeadClick);
         this.panel.addEventListener(MouseEvent.MOUSE_MOVE,this.onHeadHover);
         this.readField = renderer.label(0,0,12,TextFieldAutoSize.LEFT,"",200,20);
         this.readField.wordWrap = true;
         this.readField.multiline = true;
         this.body.addChild(this.readField);
         this.pickClip.addChild(this.picks);
         this.pickClip.y = HEAD + PAD;
         this.panel.addChild(this.pickClip);
         this.panel.addChild(this.pickRail);
         this.clip.addChild(this.body);
         this.clip.x = LEFT + PAD;
         this.clip.y = HEAD + PAD;
         this.panel.addChild(this.clip);
         this.panel.addChild(this.rail);
         this.panel.addEventListener(MouseEvent.MOUSE_WHEEL,this.onWheel);
         addEventListener(MouseEvent.CLICK,this.onSwallow);
         addEventListener(MouseEvent.MOUSE_WHEEL,this.onSwallow);
      }

      /** Nothing behind a modal gets the event that landed on it.
       *
       *  Every host screen keeps one click handler on its own root for its header
       *  buttons, resolved by where the press landed rather than by what Iggy said it
       *  hit - and this panel covers that header. The readme button sits on top of the
       *  settings button that opened the panel, and the close button on top of the
       *  host's own. Without this, one press on the readme both turns the readme on and
       *  toggles the panel shut, and one press on close asks the game to close the whole
       *  window.
       *
       *  On this rather than on the panel, so it catches everything the modal contains,
       *  and it runs after the panel's own handlers because bubbling reaches a parent
       *  last. */
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

      /** Handed every config key this screen receives. A declaration is taken and
       *  answered for; anything else is the host's own setting and is left alone.
       *
       *  A screen that declares twice replaces its earlier statement rather than
       *  appearing twice - the key it arrived under is that screen, so that is what
       *  identifies it.
       *
       *  A statement that says what the one before it said is taken and dropped. A mod
       *  restates itself whenever it is running while its settings are being changed
       *  from here, and rebuilding the whole panel to redraw the value the player has
       *  just set is work for nothing - with the controls thrown away and made again
       *  under the pointer that set them. */
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
            this.rebuild();
         }
         return true;
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

      /** The first thing the mod had to say. A mod with several screens writes its
       *  readme on whichever one it likes and the hub shows one per mod, because the
       *  reader picked a mod and not a screen of one. */
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

      /** The host's own content is taken off screen rather than dimmed under a scrim.
       *  A settings list is read, and reading it through a list of worlds is harder
       *  than it needs to be for nothing gained - there is nothing behind this worth
       *  seeing while it is open. */
      public function show(host:DisplayObjectContainer) : void
      {
         var kid:DisplayObject = null;
         var i:int = 0;
         if(this.index < 0 && this.order.length > 0)
         {
            this.index = 0;
         }
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

      /** The rows are thrown away and made again whenever the selection changes. A
       *  declaration can name any control of any type, so there is no stable set to
       *  keep and reuse - and a mod that republishes with an option added has to be
       *  able to grow a row.
       *
       *  A fold lives on the category, which is thrown away with everything else, so it
       *  is carried across a rebuild by hand and forgotten when the panel closes.
       *  Anything longer would have to be written down, and the state of a disclosure
       *  triangle is not worth a line in a config file. */
      private function rebuild() : void
      {
         var cat:Cat = null;
         var option:Option = null;
         var specs:Array = null;
         var record:Object = null;
         var parts:Array = this.chosen;
         var open:Object = this.folds();
         var i:int = 0;
         var j:int = 0;
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
                  this.body.addChild(option);
                  this.rows.push(option);
               }
               j++;
            }
            i++;
         }
         this.paint();
      }

      /** Beside the window and at the row's own height, rather than on top of the
       *  controls the row is explaining. Where the row is on screen is the list's own
       *  offset less the scroll, which the panel knows and the row does not. */
      private function tipAt(option:Option) : Point
      {
         return Tip.beside(this,this.span,
                           this.clip.y + option.y - this.scroll + option.tall * 0.5);
      }

      /** Which categories were folded, so a rebuild does not spring them all open again
       *  the moment a value inside one of them changes. */
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

      private function strip() : void
      {
         var option:Option = null;
         var i:int = 0;
         while(i < this.rows.length)
         {
            option = this.rows[i] as Option;
            option.removeEventListener(Event.CHANGE,this.onChange);
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
         this.panel.graphics.clear();
         renderer.fill(this.panel,0,0,this.span,this.high,renderer.PANEL,1);
         renderer.fill(this.panel,0,0,this.span,HEAD,renderer.HEADER,1);
         renderer.fill(this.panel,0,HEAD,this.span,1,renderer.CYAN,0.85);
         renderer.fill(this.panel,LEFT,HEAD + 1,1,this.high - HEAD - 1,renderer.BORDER,1);
         renderer.border(this.panel,0,0,this.span,this.high,renderer.ROW);

         this.titleField.textColor = renderer.VALUE;
         renderer.centre(this.titleField,0,HEAD);
         this.closeBtn.x = this.span - PAD - BTN;
         this.closeBtn.y = (HEAD - BTN) / 2;
         this.closeBtn.paint();
         this.readBtn.visible = this.story.length > 0;
         this.readBtn.x = this.closeBtn.x - BTN - 8;
         this.readBtn.y = this.closeBtn.y;
         this.readBtn.on = this.reading;
         this.readBtn.paint();

         this.guard(this.paintPicks,"picks");
         this.guard(this.paintRows,"rows");
      }

      /** A screen inside Iggy cannot be attached to and a throw in a repaint leaves no
       *  trace in any log, so the half of paint() that failed says so through the config
       *  file - the one channel out that survives.
       *
       *  Once, and never again. A write per repaint is the spam that kills a screen, and
       *  the second failure is the same failure as the first. */
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
         var i:int = 0;
         while(this.picks.numChildren > 0)
         {
            this.picks.removeChildAt(0);
         }
         while(i < this.order.length)
         {
            face = renderer.label(PAD,0,11,TextFieldAutoSize.LEFT,"",LEFT - PAD * 2,20);
            this.wrapName(face,String(this.order[i]));
            face.textColor = i == this.index ? renderer.VALUE : renderer.LABEL;
            tall = Math.max(ROW,int(face.textHeight) + 12);
            pick = new Sprite();
            pick.y = at;
            pick.name = String(i);
            pick.buttonMode = true;
            pick.mouseChildren = false;
            skin = new Shape();
            renderer.fill(skin,0,0,LEFT,tall - 1,
                          i == this.index ? renderer.HEADER : renderer.PANEL,1);
            if(i == this.index)
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

      /** The mod list scrolls on its own. Seventeen mods is taller than the window and
       *  a list that simply ran off the bottom would put the mods nobody can see at the
       *  end of the alphabet. */
      private function clipPicks() : void
      {
         var view:int = this.view;
         var run:int = 0;
         this.pickScroll = Config.clamp(this.pickScroll,0,
                                        Math.max(0,this.picksDeep - view),0);
         this.pickClip.scrollRect = new Rectangle(0,this.pickScroll,LEFT,view);
         this.pickRail.graphics.clear();
         if(this.picksDeep <= view)
         {
            return;
         }
         run = Math.max(20,view * view / this.picksDeep);
         this.pickRail.x = LEFT - 5;
         this.pickRail.y = HEAD + PAD;
         renderer.fill(this.pickRail,0,0,3,view,renderer.HEADER,1);
         renderer.fill(this.pickRail,0,
                       this.pickScroll * (view - run) / (this.picksDeep - view),
                       3,run,renderer.BORDER,1);
      }

      /** A mod name gets two lines and then gets cut. Wrapping first is what makes the
       *  cut rare: most titles are long because they are two or three words, not
       *  because they are one unreadable one, and a name cut at the width of the rail
       *  loses the part that says which mod it is. */
      private function wrapName(face:TextField, name:String) : void
      {
         var body:String = name;
         face.autoSize = TextFieldAutoSize.NONE;
         face.wordWrap = true;
         face.multiline = true;
         face.width = LEFT - PAD * 2;
         face.text = body;
         while(face.numLines > LINES && body.length > 1)
         {
            body = body.substring(0,body.length - 2);
            face.text = body + "…";
         }
         face.height = face.textHeight + 6;
      }

      /** Where every row goes is settled before any of them draws. A control places
       *  what it draws against `tall`, which reflow() has already fixed, so the two are
       *  separable - and separated they are, because a row that fails to draw then costs
       *  its own appearance rather than the position of every row after it. */
      private function paintRows() : void
      {
         var option:Option = null;
         var at:int = 0;
         var i:int = 0;
         var view:int = this.view;
         this.readField.visible = this.told;
         if(this.told)
         {
            this.emptyField.visible = false;
            this.readField.autoSize = TextFieldAutoSize.NONE;
            this.readField.width = this.inner;
            this.readField.text = this.story;
            this.readField.height = this.readField.textHeight + 8;
            this.readField.textColor = renderer.VALUE;
            this.scroll = Config.clamp(this.scroll,0,
                                       Math.max(0,this.readField.height - view),0);
            this.clip.scrollRect = new Rectangle(0,this.scroll,this.inner,view);
            this.paintRail(view);
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
         this.scroll = Config.clamp(this.scroll,0,Math.max(0,this.content - view),0);
         this.clip.scrollRect = new Rectangle(0,this.scroll,this.inner,view);
         this.paintRail(view);
      }

      private function paintRail(view:int) : void
      {
         var run:int = Math.max(20,view * view / this.content);
         this.rail.graphics.clear();
         if(this.content <= view)
         {
            return;
         }
         this.rail.x = this.span - 8;
         this.rail.y = HEAD + PAD;
         renderer.fill(this.rail,0,0,3,view,renderer.HEADER,1);
         renderer.fill(this.rail,0,this.scroll * (view - run) / (this.content - view),
                       3,run,renderer.BORDER,1);
      }

      private function onRead(e:MouseEvent) : void
      {
         Option.click();
         Option.hideTip();
         this.reading = !this.reading;
         this.scroll = 0;
         this.rebuild();
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

      /** Whichever side the pointer is over. Two lists that scroll and one wheel, so the
       *  only sane rule is that the wheel talks to what is under it. */
      private function onWheel(e:MouseEvent) : void
      {
         var was:Number = 0;
         if(this.panel.mouseX < LEFT)
         {
            was = this.pickScroll;
            this.pickScroll = Config.clamp(this.pickScroll + renderer.wheel(e),0,
                                           Math.max(0,this.picksDeep - this.view),0);
            if(this.pickScroll != was)
            {
               this.clipPicks();
            }
            return;
         }
         was = this.scroll;
         this.scroll = Config.clamp(this.scroll + renderer.wheel(e),0,
                                    Math.max(0,this.content - this.view),0);
         if(this.scroll != was)
         {
            this.paintRows();
         }
      }

      /** Reported in the declaring mod's dialect, not ours. A legacy flag is written
       *  true and false where every control here states itself as 1 and 0, and handing
       *  that mod our literal would read to it as off - turning the setting off rather
       *  than on. */
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
         dispatchEvent(new Event(Event.CHANGE));
         this.paintRows();
      }

      /** Which screen of the mod a key belongs to, as well as what it says. Two screens
       *  of one mod can name the same setting - they are separate sections, and a value
       *  they share is deliberately written to both - so the record comes back with the
       *  spec rather than the write going to whichever was looked at first. */
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

      /** Which header button was hit, worked out from where the pointer was rather than
       *  from which object Iggy decided owned the click. Iggy measures a plate by its
       *  children and gets a one-glyph caption wrong, and a control it measures wrong
       *  takes the clicks around it as well as its own - the close button was eating
       *  every press aimed at the readme beside it.
       *
       *  The rectangles are the ones paint() put the buttons on, so the hit test and the
       *  drawing cannot disagree. */
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
      }

      /** Driven from here for the same reason the clicks are: a plate left to its own
       *  roll-over lights up for a pointer that is over the button next to it. */
      private function onHeadHover(e:MouseEvent) : void
      {
         var live:Boolean = this.panel.mouseY < HEAD;
         var closeHot:Boolean = live && this.holds(this.closeBtn);
         var readHot:Boolean = live && this.readBtn.visible && this.holds(this.readBtn);
         if(closeHot != this.closeBtn.hovered)
         {
            this.closeBtn.hovered = closeHot;
         }
         if(readHot != this.readBtn.hovered)
         {
            this.readBtn.hovered = readHot;
         }
      }

      /** Only the panel's own close says CLOSE. A host that puts the panel away
       *  itself is going back to its screen, and closing that screen from under it
       *  would be a dismissal nobody asked for. */
      private function onDismiss(e:MouseEvent) : void
      {
         Option.click();
         this.hide();
         dispatchEvent(new Event(Event.CLOSE));
      }
   }
}
