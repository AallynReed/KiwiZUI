package ui
{
   import flash.events.MouseEvent;

   /** A flag, as a box and a caption. The caption is to the right of the box rather
    *  than in the row's name column, because the box is the thing being read and a
    *  name that far from its own tick reads as a name for the next row down. */
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

      /** The tick's name sits beside the box and not in the name column, so it has the
       *  whole row to the right of the box rather than a lane stopping short of a
       *  control that is not there. */
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
