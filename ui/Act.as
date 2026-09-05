package ui
{
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;

   public class Act extends Option
   {

      private static const TALL:int = 26;

      private static const SIZE:int = 12;

      public var live:Boolean = true;

      private var hot:Boolean = false;

      private var face:TextField;

      public function Act(key:String, text:String, w:int)
      {
         super(key,"",w);
         this.tall = TALL;
         this.face = renderer.pin(renderer.label(0,0,SIZE,TextFieldAutoSize.CENTER,"",w,TALL,
                                                 false,true),w,SIZE);
         this.face.text = text;
         addChild(this.face);
         mouseChildren = false;
         buttonMode = true;
         addEventListener(MouseEvent.ROLL_OVER,this.onHover);
         addEventListener(MouseEvent.ROLL_OUT,this.onHover);
         addEventListener(MouseEvent.CLICK,this.onClick);
      }

      public function say(body:String) : void
      {
         if(this.face.text == body)
         {
            return;
         }
         this.face.text = body;
         this.paint();
      }

      override public function get literal() : String
      {
         return "";
      }

      override public function set from(raw:String) : void
      {
         this.live = Config.flag(raw);
      }

      override public function reflow() : void
      {
      }

      override public function paint() : void
      {
         var edge:uint = !this.live ? renderer.BORDER
                                    : (this.hot ? renderer.CYAN : renderer.BORDER);
         this.box.graphics.clear();
         renderer.framed(this.box,0,0,this.w,this.tall,renderer.HEADER,edge,1);
         renderer.pin(this.face,this.w,SIZE);
         renderer.centre(this.face,0,this.tall);
         this.face.textColor = !this.live ? renderer.LABEL
                                          : (this.hot ? renderer.VALUE : renderer.LABEL);
      }

      private function onHover(e:MouseEvent) : void
      {
         this.hot = e.type == MouseEvent.ROLL_OVER;
         this.paint();
      }

      private function onClick(e:MouseEvent) : void
      {
         Option.click(this.live);
         if(this.live)
         {
            this.announce();
         }
      }
   }
}
