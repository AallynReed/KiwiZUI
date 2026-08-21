package ui
{
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;

   /** A row of differently coloured words and numbers, ending against a fixed right edge.
    *
    *  One field per piece rather than one field of markup, for two reasons that both cost
    *  a build to find. `htmlText` puts its content in a paragraph box whose height is not
    *  the height of a line, so `textHeight` comes back describing something other than the
    *  words - and every rule in these screens for putting text in the middle of a box is
    *  written in terms of that measurement, so a reading written as markup sits wherever
    *  the mismeasurement lands. The obvious alternative, colouring stretches of one plain
    *  field, needs `setTextFormat`'s ranged form, and nothing in any of these mods has ever
    *  asked Iggy for that arity - a rejected call takes the screen down with nothing in any
    *  log.
    *
    *  Separate fields need neither. Each is placed and centred by the same rules as every
    *  other caption, so the row is level by construction. */
   public class Run extends Sprite
   {

      private var bits:Array = [];

      private var gaps:Array = [];

      public function Run(size:int, most:int, bold:Boolean = false, spacing:Number = 0)
      {
         super();
         var i:int = 0;
         while(i < most)
         {
            this.bits.push(addChild(renderer.pin(
               renderer.label(0,0,size,TextFieldAutoSize.LEFT,"",240,size * 2,false,bold,
                              spacing),240,size)));
            this.gaps.push(0);
            i++;
         }
         mouseEnabled = false;
         mouseChildren = false;
      }

      /** What the row says, as `{text, lit, gap}` in reading order. `gap` is the room the
       *  piece keeps in front of itself, which is a property of what it says rather than
       *  of where it lands. Pieces past what this run was built to hold are dropped. */
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
            field.text = piece == null ? "" : String(piece.text);
            this.gaps[i] = piece == null ? 0 : Number(piece.gap);
            if(piece != null)
            {
               field.textColor = uint(piece.lit);
            }
            i++;
         }
         this.place();
      }

      /** Laid out so the last piece ends at this sprite's own origin, which is what makes
       *  the caller's job one number: put the run where the row has to end.
       *
       *  A leading gap on the first piece is harmless - the whole run is measured before
       *  the start is worked back from the end, so what comes first only shifts empty
       *  space. */
      private function place() : void
      {
         var field:TextField = null;
         var run:Number = 0;
         var at:Number = 0;
         var i:int = 0;
         while(i < this.bits.length)
         {
            field = this.bits[i] as TextField;
            if(field.visible)
            {
               run += Number(this.gaps[i]) + field.textWidth;
            }
            i++;
         }
         at = -run;
         i = 0;
         while(i < this.bits.length)
         {
            field = this.bits[i] as TextField;
            if(field.visible)
            {
               at += Number(this.gaps[i]);
               /* A field draws its text a gutter in from its own left edge, so the field
                  goes back by one to put the words where the measurement says they are. */
               field.x = at - 2;
               at += field.textWidth;
            }
            i++;
         }
      }

      /** Puts the words in the middle of a box `high` tall, in this run's own space, so a
       *  caller that has placed the run has placed the words. */
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
