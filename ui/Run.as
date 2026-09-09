package ui
{
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;

   public class Run extends Sprite
   {

      private static const FLOOR:int = 22;

      private var bits:Array = [];

      private var gaps:Array = [];

      private var spans:Array = [];

      private var wide:Number = 0;

      private var size:int = 0;

      private var bold:Boolean = false;

      private var spacing:Number = 0;

      private var fromLeft:Boolean = false;

      public function Run(size:int, most:int, bold:Boolean = false, spacing:Number = 0,
                          fromLeft:Boolean = false)
      {
         super();
         var i:int = 0;
         this.size = size;
         this.bold = bold;
         this.spacing = spacing;
         this.fromLeft = fromLeft;
         while(i < most)
         {
            this.bits.push(addChild(renderer.pin(
               renderer.label(0,0,size,TextFieldAutoSize.LEFT,"",240,size * 2,false,bold,
                              spacing),240,size)));
            this.gaps.push(0);
            this.spans.push(0);
            i++;
         }
         mouseEnabled = false;
         mouseChildren = false;
      }

      public function resize(size:int) : void
      {
         var field:TextField = null;
         var i:int = 0;
         this.size = size;
         while(i < this.bits.length)
         {
            field = this.bits[i] as TextField;
            renderer.resize(field,size);
            field.height = size * 2;
            i++;
         }
      }

      public function say(said:Array) : void
      {
         var field:TextField = null;
         var piece:Object = null;
         var i:int = 0;
         while(i < this.bits.length)
         {
            field = this.bits[i] as TextField;
            piece = i < said.length ? said[i] : null;
            field.visible = piece != null;
            renderer.say(field,piece == null ? "" : String(piece.text));
            this.gaps[i] = piece == null ? 0 : Number(piece.gap);
            if(piece != null)
            {
               field.textColor = uint(piece.lit);
            }
            i++;
         }
         this.place();
      }

      public function get span() : Number
      {
         return this.wide;
      }

      private function widthOf(field:TextField) : Number
      {
         var seen:Number = field.textWidth;
         if(seen > 0 || field.text.length == 0)
         {
            return seen;
         }
         return renderer.wideOf(field.text,this.size,this.bold,this.spacing);
      }

      private function place() : void
      {
         var field:TextField = null;
         var run:Number = 0;
         var at:Number = 0;
         var i:int = 0;
         while(i < this.bits.length)
         {
            field = this.bits[i] as TextField;
            this.spans[i] = field.visible ? this.widthOf(field) : 0;
            if(field.visible)
            {
               run += Number(this.gaps[i]) + Number(this.spans[i]);
            }
            i++;
         }
         this.wide = run;
         at = this.fromLeft ? 0 : -run;
         i = 0;
         while(i < this.bits.length)
         {
            field = this.bits[i] as TextField;
            if(field.visible)
            {
               at += Number(this.gaps[i]);
               field.x = (this.fromLeft ? at : Math.min(at,-Number(this.spans[i]))) - 2;
               at += Number(this.spans[i]);
            }
            i++;
         }
      }

      public function fit(room:Number) : void
      {
         var field:TextField = null;
         var widest:TextField = null;
         var most:Number = 0;
         var over:Number = this.wide - room;
         var i:int = 0;
         if(over <= 0)
         {
            return;
         }
         while(i < this.bits.length)
         {
            field = this.bits[i] as TextField;
            if(field.visible && (widest == null || Number(this.spans[i]) > most))
            {
               widest = field;
               most = Number(this.spans[i]);
            }
            i++;
         }
         if(widest == null)
         {
            return;
         }
         renderer.elide(widest,Math.max(FLOOR,most - over));
         this.place();
      }

      public function startOf(index:int) : Number
      {
         var field:TextField = index >= 0 && index < this.bits.length
                             ? this.bits[index] as TextField : null;
         return field == null ? 0 : field.x + 2;
      }

      public function centre(high:Number) : void
      {
         var field:TextField = null;
         var i:int = 0;
         while(i < this.bits.length)
         {
            field = this.bits[i] as TextField;
            renderer.centre(field,0,high);
            i++;
         }
      }
   }
}
