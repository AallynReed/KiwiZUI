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

   public class Settings extends Sprite
   {

      public static const W:int = 380;

      private static const PAD:int = 18;

      public static const INNER:int = W - PAD * 2;

      private static const GAP:int = 8;

      private static const HEAD:int = 38;

      private static const MARGIN:int = 48;

      private static const SCRIM:Number = 0;

      public var anchored:Boolean = false;

      public var bare:Boolean = false;

      public var sticky:Boolean = false;

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

      private var left:int = 0;

      private var top:int = 0;

      private var scroll:Number = 0;

      private var drives:Boolean = false;

      private var pointer:Point = new Point();

      private var here:Point = new Point();

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

      public function set title(text:String) : void
      {
         renderer.say(this.titleText,text);
      }

      private function accented(options:Array) : Array
      {
         var out:Array = options.concat();
         if(this.bare)
         {
            return out;
         }
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

      public function resize(span:int, high:int, left:int = 0, top:int = 0) : void
      {
         this.span = span;
         this.high = high;
         this.left = left;
         this.top = top;
      }

      public function show(host:DisplayObjectContainer, values:Object) : void
      {
         Layer.frame(this.span,this.high);
         this.sync(values);
         host.addChild(this);
         this.paint();
         Option.watch(this.stage,true);
         if(this.drives)
         {
            addEventListener(Event.ENTER_FRAME,this.onTick);
         }
      }

      public function hide() : void
      {
         removeEventListener(Event.ENTER_FRAME,this.onTick);
         Layer.hide();
         Option.watch(this.stage,false);
         if(this.parent != null)
         {
            this.parent.removeChild(this);
         }
         dispatchEvent(new Event(Event.CLOSE));
      }

      public function relist(options:Array, values:Object) : void
      {
         while(this.body.numChildren > 0)
         {
            this.body.removeChildAt(0);
         }
         this.options = this.accented(options);
         this.listen();
         this.scroll = 0;
         this.sync(values);
         if(this.parent != null)
         {
            this.paint();
         }
      }

      private function listen() : void
      {
         var option:Option = null;
         var i:int = 0;
         this.drives = false;
         while(i < this.options.length)
         {
            option = this.options[i] as Option;
            this.drives = this.drives || option.hovers;
            option.addEventListener(Event.CHANGE,this.onChange);
            option.addEventListener(Event.SELECT,this.onFold);
            option.reflow();
            this.body.addChild(option);
            i++;
         }
      }

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

      private function onFold(e:Event) : void
      {
         this.paint();
      }

      private function listed(at:int) : Boolean
      {
         var i:int = at;
         if(this.options[at] is Cat)
         {
            return true;
         }
         while(i > 0)
         {
            i--;
            if(this.options[i] is Cat)
            {
               return (this.options[i] as Cat).open;
            }
         }
         return true;
      }

      private function get content() : int
      {
         var deep:int = 0;
         var i:int = 0;
         while(i < this.options.length)
         {
            if(this.listed(i))
            {
               deep += (this.options[i] as Option).tall + GAP;
            }
            i++;
         }
         return Math.max(0,deep - GAP);
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
         this.panel.y = this.anchored ? this.top : this.top + (this.high - deep) / 2;
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
            option.visible = this.listed(i);
            if(option.visible)
            {
               option.y = at;
               option.paint();
               at += option.tall + GAP;
            }
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
                       3,run,renderer.LABEL,1);
      }

      private function onWheel(e:MouseEvent) : void
      {
         var was:Number = this.scroll;
         this.scroll = Config.clamp(this.scroll + renderer.wheel(e),0,this.content - this.view,0);
         if(this.scroll != was)
         {
            this.paint();
         }
      }

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

      /** The pointer in one row's own coordinates. `clip` carries the scroll in its
       *  `scrollRect`, and a scrollRect is not a transform: a point taken through anything
       *  under it comes back short by the whole scroll, so the row is hit correctly and
       *  every control on it is dead. The panel is the last thing above it, which makes it
       *  the last honest reading. */
      private function into(row:Option, at:Point) : Point
      {
         this.pointer.x = at.x - this.clip.x;
         this.pointer.y = at.y - this.clip.y - row.y + this.scroll;
         return this.pointer;
      }

      private function reach(row:Option) : Boolean
      {
         return row.hovers && row.visible;
      }

      private function claimed(e:MouseEvent) : Boolean
      {
         var option:Option = null;
         var at:Point = this.panel.globalToLocal(new Point(e.stageX,e.stageY));
         var i:int = 0;
         while(i < this.options.length)
         {
            option = this.options[i] as Option;
            if(this.reach(option) && option.press(this.into(option,at)))
            {
               return true;
            }
            i++;
         }
         return false;
      }

      private function onTick(e:Event) : void
      {
         var option:Option = null;
         var i:int = 0;
         this.here.x = this.panel.mouseX;
         this.here.y = this.panel.mouseY;
         while(i < this.options.length)
         {
            option = this.options[i] as Option;
            if(this.reach(option))
            {
               option.lit(this.into(option,this.here));
            }
            i++;
         }
      }

      private function onOutside(e:MouseEvent) : void
      {
         var hit:DisplayObject = e.target as DisplayObject;
         if(this.claimed(e))
         {
            return;
         }
         if(this.sticky || hit == null || hit.stage == null || this.panel.contains(hit))
         {
            return;
         }
         this.onDismiss(e);
      }
   }
}
