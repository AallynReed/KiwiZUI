package ui
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;

   /** The options, in the window rather than only in a file. Every control commits in
    *  steps and one step is one config write - a config write is a record, never a
    *  trace, and a control that wrote continuously would take the screen down. That is
    *  why a slider says nothing until it is released and a text box says nothing until
    *  it is ticked.
    *
    *  Nothing is applied from in here. A control reports its key and the literal that
    *  would go in the file, and the screen puts both through the same reader the
    *  config file goes through, so a value set in the window and a value set in the
    *  file cannot come to mean two different things.
    *
    *  The options come from the screen. Every screen has a different set of them and
    *  there is only one panel, so the list is the caller's and the panel is the part
    *  that is shared. The accent colour is not: it is on every screen, so the panel
    *  adds a picker for it unless the caller already brought one - beside the panel
    *  colour rather than after everything else. Two colour pickers with a screen's own
    *  options between them read as two unrelated settings.
    *
    *  Rows ask for their own height and the list scrolls, so a screen can put as many
    *  options in as it has without the panel running off the top of the window.
    *
    *  The panel is not part of the screen until it is asked for: show() attaches it to
    *  the screen and hide() takes it away again, so a closed panel is not a hidden
    *  sprite the screen has to keep stepping over, and an open one is by construction
    *  the last child and so over everything. CLOSE says it went away, whichever of the
    *  two ways it was dismissed. */
   public class Settings extends Sprite
   {

      public static const W:int = 380;

      private static const PAD:int = 18;

      /** Statics initialise in declaration order, so this one has to follow PAD or it
       *  would be measured against a zero. */
      public static const INNER:int = W - PAD * 2;

      private static const GAP:int = 8;

      private static const HEAD:int = 38;

      /** Clearance kept between the panel and the edge of the screen. */
      private static const MARGIN:int = 48;

      /** The scrim is there to swallow clicks meant for the screen underneath, not to
       *  dim it. Darkening the window made the window opacity being set through this
       *  very panel impossible to judge, which is the one thing a settings panel must
       *  not get in the way of. Invisible and still a filled shape: Flash hit tests
       *  geometry rather than alpha, so nothing gets past it either way. */
      private static const SCRIM:Number = 0;

      public var key:String = "";

      public var literal:String = "";

      private var scrim:Shape = new Shape();

      private var panel:Sprite = new Sprite();

      private var clip:Sprite = new Sprite();

      private var body:Sprite = new Sprite();

      private var rail:Shape = new Shape();

      private var titleText:TextField;

      private var closeBtn:Plate = new Plate(24,24,14);

      private var options:Array;

      private var span:int;

      private var high:int;

      /** Where the host's own content starts. A screen that nudges everything clear of
       *  its window frame leaves the panel behind, because the panel is not a child yet
       *  when that nudge runs - so it is told, and centres on the interface rather than
       *  on the box the interface sits in. */
      private var left:int = 0;

      private var top:int = 0;

      private var scroll:Number = 0;

      public function Settings(span:int, high:int, options:Array)
      {
         super();
         this.span = span;
         this.high = high;
         addChild(this.scrim);
         addChild(this.panel);
         addEventListener(MouseEvent.CLICK,this.onOutside);

         this.titleText = renderer.label(PAD,0,14,TextFieldAutoSize.LEFT,"SETTINGS",200,24,false,true);
         this.panel.addChild(this.titleText);
         this.closeBtn.text = "\u00D7";
         this.closeBtn.addEventListener(MouseEvent.CLICK,this.onDismiss);
         this.panel.addChild(this.closeBtn);
         this.clip.addChild(this.body);
         this.panel.addChild(this.clip);
         this.panel.addChild(this.rail);
         this.panel.addEventListener(MouseEvent.MOUSE_WHEEL,this.onWheel);

         this.options = this.accented(options);
         this.listen();
      }

      private function accented(options:Array) : Array
      {
         var out:Array = options.concat();
         var at:int = out.length;
         var i:int = 0;
         while(i < out.length)
         {
            if((out[i] as Option).key == "accent")
            {
               return out;
            }
            if((out[i] as Option).key == "panel")
            {
               at = i + 1;
            }
            i++;
         }
         out.splice(at,0,new Picker("accent","Accent",INNER));
         return out;
      }

      /** The keys in the order the rows are laid out, so where a control ended up is
       *  something the gallery can assert rather than something to go and look at. */
      public function get order() : String
      {
         var out:Array = [];
         var i:int = 0;
         while(i < this.options.length)
         {
            out.push((this.options[i] as Option).key);
            i++;
         }
         return out.join(",");
      }

      public function get shown() : Boolean
      {
         return this.parent != null;
      }

      /** A window that can be resized has to be able to say so: the panel centres itself
       *  in this frame and hands the same one to Layer, so a stale size puts both in the
       *  wrong place. */
      public function resize(span:int, high:int, left:int = 0, top:int = 0) : void
      {
         this.span = span;
         this.high = high;
         this.left = left;
         this.top = top;
      }

      /** The panel is the only thing here that knows how big the screen is, so it is
       *  what tells Layer where a popup may sit. */
      public function show(host:DisplayObjectContainer, values:Object) : void
      {
         Layer.frame(this.span,this.high);
         this.sync(values);
         host.addChild(this);
         this.paint();
         Option.watch(this.stage,true);
      }

      public function hide() : void
      {
         Layer.hide();
         Option.watch(this.stage,false);
         if(this.parent != null)
         {
            this.parent.removeChild(this);
         }
         dispatchEvent(new Event(Event.CLOSE));
      }

      private function listen() : void
      {
         var option:Option = null;
         var i:int = 0;
         while(i < this.options.length)
         {
            option = this.options[i] as Option;
            option.addEventListener(Event.CHANGE,this.onChange);
            this.body.addChild(option);
            i++;
         }
      }

      /** Pushed in from the screen on every repaint, so the panel shows the values the
       *  screen is actually running with and never a copy that can drift out of step
       *  with the config file. A key the screen does not report is a palette colour,
       *  which the renderer already holds. */
      public function sync(values:Object) : void
      {
         var option:Option = null;
         var i:int = 0;
         while(i < this.options.length)
         {
            option = this.options[i] as Option;
            if(option.key.length > 0)
            {
               option.from = values[option.key] == null
                           ? renderer.defaultOf(option.key)
                           : String(values[option.key]);
            }
            i++;
         }
      }

      private function get content() : int
      {
         var deep:int = 0;
         var i:int = 0;
         while(i < this.options.length)
         {
            deep += (this.options[i] as Option).tall + GAP;
            i++;
         }
         return deep - GAP;
      }

      private function get view() : int
      {
         return Math.min(this.content,this.high - MARGIN - HEAD - PAD * 2);
      }

      public function paint() : void
      {
         var view:int = this.view;
         var deep:int = HEAD + PAD + view + PAD;
         var option:Option = null;
         var at:int = 0;
         var i:int = 0;
         this.scrim.graphics.clear();
         renderer.fill(this.scrim,this.left,this.top,this.span,this.high,renderer.BLACK,SCRIM);
         this.panel.x = this.left + (this.span - W) / 2;
         this.panel.y = this.top + (this.high - deep) / 2;
         this.panel.graphics.clear();
         renderer.framed(this.panel,0,0,W,deep,renderer.PANEL,renderer.BORDER,1);
         renderer.fill(this.panel,1,1,W - 2,HEAD - 1,renderer.HEADER,1);
         renderer.fill(this.panel,1,HEAD,W - 2,1,renderer.CYAN,0.85);

         this.titleText.textColor = renderer.VALUE;
         renderer.centre(this.titleText,0,HEAD);
         this.closeBtn.x = W - PAD - 24;
         this.closeBtn.y = (HEAD - 24) / 2;
         this.closeBtn.paint();

         while(i < this.options.length)
         {
            option = this.options[i] as Option;
            option.y = at;
            option.paint();
            at += option.tall + GAP;
            i++;
         }
         this.scroll = Config.clamp(this.scroll,0,this.content - view,0);
         this.clip.x = PAD;
         this.clip.y = HEAD + PAD;
         this.clip.scrollRect = new Rectangle(0,this.scroll,INNER,view);
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
         this.rail.x = W - 7;
         this.rail.y = HEAD + PAD;
         renderer.fill(this.rail,0,0,3,view,renderer.HEADER,1);
         renderer.fill(this.rail,0,this.scroll * (view - run) / (this.content - view),
                       3,run,renderer.BORDER,1);
      }

      private function onWheel(e:MouseEvent) : void
      {
         var was:Number = this.scroll;
         this.scroll = Config.clamp(this.scroll - e.delta * 6,0,this.content - this.view,0);
         if(this.scroll != was)
         {
            this.paint();
         }
      }

      /** Repainted after the screen has had the change, not before: CHANGE is dispatched
       *  straight through, so by the time that call returns the new colour is already in
       *  the palette and the panel can draw itself with it. Without this the one window
       *  that cannot show what a colour does is the one being used to pick it. */
      private function onChange(e:Event) : void
      {
         var option:Option = e.currentTarget as Option;
         this.key = option.key;
         this.literal = option.literal;
         dispatchEvent(new Event(Event.CHANGE));
         this.paint();
      }

      private function onDismiss(e:MouseEvent) : void
      {
         Option.click();
         this.hide();
      }

      /** A click that missed the panel closes it. The scrim is what stops that click
       *  reaching the screen underneath, and it has to be listened for here rather than
       *  on the scrim itself: a Shape is not an InteractiveObject, so a mouse listener
       *  put on one is never called and the click went nowhere at all - the panel stayed
       *  open and swallowed everything aimed past it. */
      private function onOutside(e:MouseEvent) : void
      {
         var hit:DisplayObject = e.target as DisplayObject;
         if(hit != null && this.panel.contains(hit))
         {
            return;
         }
         this.onDismiss(e);
      }
   }
}
