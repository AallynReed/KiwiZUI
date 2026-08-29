package ui
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;

   public class Scrollbar extends Sprite
   {

      public static const W:int = 12;

      private static const MARK:int = 4;

      private static const LEAST:int = 24;

      public var moved:Function;

      private var box:Shape = new Shape();

      private var zone:Reach = new Reach();

      private var home:Sprite;

      private var watch:Stage;

      private var view:Number = 0;

      private var content:Number = 0;

      private var at:Number = 0;

      private var run:Number = 0;

      private var top:Number = 0;

      private var grab:Number = -1;

      private var lit:Boolean = false;

      public function Scrollbar()
      {
         super();
         addChild(this.box);
      }

      public function attach(home:Sprite) : void
      {
         this.home = home;
      }

      public function get live() : Boolean
      {
         return this.content > this.view && this.view > 0;
      }

      public function get held() : Boolean
      {
         return this.grab >= 0;
      }

      public function get span() : Number
      {
         return Math.max(0,this.content - this.view);
      }

      public function fit(view:Number, content:Number, at:Number) : void
      {
         this.view = view;
         this.content = content;
         this.at = at;
         if(!this.live)
         {
            this.release();
            this.shed();
            return;
         }
         this.run = Math.max(LEAST,view * view / content);
         this.top = (view - this.run) * at / this.span;
         this.box.graphics.clear();
         renderer.fill(this.box,0,0,W,view,renderer.PANEL,0);
         renderer.fill(this.box,(W - MARK) / 2,0,MARK,view,renderer.HEADER);
         renderer.fill(this.box,(W - MARK) / 2,this.top,MARK,this.run,
                       this.lit || this.held ? renderer.CYAN : renderer.BORDER);
         if(this.parent == null && this.home != null)
         {
            this.home.addChild(this);
         }
      }

      public function holds(at:Point) : Boolean
      {
         return this.live && at.x >= this.x && at.x < this.x + W
             && at.y >= this.y && at.y < this.y + this.view;
      }

      public function hover(at:Point) : void
      {
         var on:Boolean = this.holds(at);
         if(on == this.lit)
         {
            return;
         }
         this.lit = on;
         this.repaint();
      }

      public function press(at:Point) : void
      {
         var y:Number = at.y - this.y;
         if(!this.holds(at) || this.held)
         {
            return;
         }
         this.grab = y >= this.top && y < this.top + this.run ? y - this.top : this.run / 2;
         this.zone.hold(this.home,W,this.view);
         this.zone.addEventListener(MouseEvent.MOUSE_MOVE,this.onDrag);
         this.zone.addEventListener(MouseEvent.MOUSE_UP,this.onDrop);
         if(this.home != null)
         {
            this.home.addEventListener(MouseEvent.MOUSE_UP,this.onDrop);
         }
         this.watch = stage;
         if(this.watch != null)
         {
            this.watch.addEventListener(MouseEvent.MOUSE_MOVE,this.onDrag);
            this.watch.addEventListener(MouseEvent.MOUSE_UP,this.onDrop);
            this.watch.addEventListener(Event.MOUSE_LEAVE,this.onDrop);
         }
         this.seek(y);
         this.repaint();
      }

      public function release() : void
      {
         if(!this.held)
         {
            return;
         }
         this.grab = -1;
         this.zone.removeEventListener(MouseEvent.MOUSE_MOVE,this.onDrag);
         this.zone.removeEventListener(MouseEvent.MOUSE_UP,this.onDrop);
         this.zone.drop();
         if(this.home != null)
         {
            this.home.removeEventListener(MouseEvent.MOUSE_UP,this.onDrop);
         }
         if(this.watch != null)
         {
            this.watch.removeEventListener(MouseEvent.MOUSE_MOVE,this.onDrag);
            this.watch.removeEventListener(MouseEvent.MOUSE_UP,this.onDrop);
            this.watch.removeEventListener(Event.MOUSE_LEAVE,this.onDrop);
            this.watch = null;
         }
         this.repaint();
      }

      private function shed() : void
      {
         this.box.graphics.clear();
         if(this.parent != null)
         {
            this.parent.removeChild(this);
         }
      }

      private function repaint() : void
      {
         this.fit(this.view,this.content,this.at);
      }

      private function seek(y:Number) : void
      {
         var travel:Number = this.view - this.run;
         if(travel <= 0 || this.moved == null)
         {
            return;
         }
         this.moved(Config.clamp((y - this.grab) / travel * this.span,0,this.span,0));
      }

      private function onDrag(e:MouseEvent) : void
      {
         if(!this.held || this.home == null)
         {
            return;
         }
         this.seek(this.home.globalToLocal(new Point(e.stageX,e.stageY)).y - this.y);
      }

      private function onDrop(e:Event) : void
      {
         this.release();
      }
   }
}
