package ui
{
   import flash.events.MouseEvent;

   public class Check extends Option
   {

      private static const BOX:int = 15;

      public var value:Boolean = false;

      private var hot:Boolean = false;

      public function Check(key:String, text:String, w:int)
      {
         super(key,text,w);
         mouseChildren = false;
         buttonMode = true;
         addEventListener(MouseEvent.ROLL_OVER,this.onHover);
         addEventListener(MouseEvent.ROLL_OUT,this.onHover);
         addEventListener(MouseEvent.CLICK,this.onClick);
      }

      override public function get nameRoom() : int
      {
         return this.w - (BOX + 10);
      }

      override public function get literal() : String
      {
         return this.value ? "1" : "0";
      }

      override public function set from(raw:String) : void
      {
         this.value = Config.flag(raw);
      }

      override public function paint() : void
      {
         var top:int = (this.tall - BOX) / 2;
         var edge:uint = this.value || this.hot ? renderer.CYAN : renderer.BORDER;
         this.box.graphics.clear();
         renderer.fill(this.box,0,0,this.w,this.tall,renderer.PANEL,0);
         renderer.framed(this.box,0,top,BOX,BOX,renderer.HEADER,edge,1);
         if(this.value)
         {
            renderer.accent(this.box,4,top + 4,BOX - 8,BOX - 8);
         }
         this.captionAt(BOX + 10,this.value ? renderer.VALUE : renderer.LABEL);
      }

      private function onHover(e:MouseEvent) : void
      {
         this.hot = e.type == MouseEvent.ROLL_OVER;
         this.paint();
      }

      private function onClick(e:MouseEvent) : void
      {
         this.value = !this.value;
         Option.click();
         this.paint();
         this.announce();
      }
   }
}
