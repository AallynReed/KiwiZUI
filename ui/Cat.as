package ui
{
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextFieldAutoSize;

   /** A category in a settings list: a name, a rule, and a chevron that folds the rows
    *  under it away.
    *
    *  A mod is one entry in the hub however many screens it has, so its options arrive
    *  in more than one batch and each batch wants saying apart from the next. Open to
    *  begin with, because a setting nobody can see is a setting nobody will find, and
    *  folding is for getting a long mod out of the way rather than for hiding it.
    *
    *  Not a setting: an empty key keeps it out of every value, every write and every
    *  sync, exactly as Heading is kept out of them. It reports SELECT rather than
    *  CHANGE for the same reason - what changed is the list, not a value. */
   public class Cat extends Option
   {

      private static const RULE:int = 3;

      private static const ARROW:int = 9;

      private static const SPACED:Number = 1.6;

      public var open:Boolean = true;

      private var hot:Boolean = false;

      public function Cat(text:String, w:int)
      {
         super("","",w);
         this.tall = 30;
         this.caption = renderer.label(ARROW + 8,0,10,TextFieldAutoSize.LEFT,"",w,20,false,
                                       false,SPACED);
         this.caption.text = text.toUpperCase();
         addChild(this.caption);
         mouseChildren = false;
         buttonMode = true;
         addEventListener(MouseEvent.ROLL_OVER,this.onHover);
         addEventListener(MouseEvent.ROLL_OUT,this.onHover);
         addEventListener(MouseEvent.CLICK,this.onClick);
      }

      override public function get nameRoom() : int
      {
         return this.w - ARROW - 8;
      }

      override public function paint() : void
      {
         var color:uint = this.hot ? renderer.VALUE : renderer.CYAN;
         this.box.graphics.clear();
         renderer.fill(this.box,0,0,this.w,this.tall,renderer.PANEL,0);
         this.chevron(color);
         this.caption.x = ARROW + 8;
         this.caption.textColor = color;
         renderer.centre(this.caption,0,this.tall - RULE * 2);
         renderer.fill(this.box,0,this.tall - RULE,this.w,1,renderer.BORDER);
      }

      /** Down when the rows below are showing, right when they are folded away - the
       *  direction the eye reads as "there is more that way". */
      private function chevron(color:uint) : void
      {
         var mid:int = (this.tall - RULE * 2) / 2;
         this.box.graphics.beginFill(color,1);
         if(this.open)
         {
            this.box.graphics.moveTo(0,mid - 2);
            this.box.graphics.lineTo(ARROW,mid - 2);
            this.box.graphics.lineTo(ARROW / 2,mid + 3);
         }
         else
         {
            this.box.graphics.moveTo(1,mid - 4);
            this.box.graphics.lineTo(1 + ARROW - 3,mid + 1);
            this.box.graphics.lineTo(1,mid + 6);
         }
         this.box.graphics.endFill();
      }

      private function onHover(e:MouseEvent) : void
      {
         this.hot = e.type == MouseEvent.ROLL_OVER;
         this.paint();
      }

      private function onClick(e:MouseEvent) : void
      {
         this.open = !this.open;
         Option.click();
         this.paint();
         dispatchEvent(new Event(Event.SELECT));
      }
   }
}
