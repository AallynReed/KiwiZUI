package ui
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;

   public class Keys extends Sprite
   {

      /** Backspace and space are characters in a row like any other, so a layout is its
       *  four strings and nothing else. Forty-four keys in eleven columns is the grid
       *  exactly filled, and each of the six that is neither a letter nor a digit sits
       *  where a keyboard puts it: the hyphen after the nought, the colon after the L, the
       *  comma after the M. The apostrophe is the one that cannot - the corner it belongs
       *  in is the backspace's - so it ends the top letter row instead.
       *
       *  The punctuation earns its keys on names alone. The wildcard is ours, every name
       *  pattern in this library being a leading `*`, and the underscore is Trove account
       *  names; the rest are the game's own item names, which are full of all four. */
      private static const TEXT:Array = ["1234567890-","QWERTYUIOP'","ASDFGHJKL:\b",
                                         "ZXCVBNM,_* "];

      private static const NUMS:Array = ["123","456","789","0.\b"];

      private static const COLS:int = 11;

      private static const CELL:int = 26;

      private static const GAP:int = 3;

      private static const EDGE:int = 6;

      private static const BACK:String = "\b";

      private static const SPACE:String = " ";

      public static const W:int = EDGE * 2 + COLS * CELL + (COLS - 1) * GAP;

      public static const H:int = EDGE * 2 + TEXT.length * CELL + (TEXT.length - 1) * GAP;

      private static var one:Keys;

      private static var box:Input;

      private var art:Shape = new Shape();

      private var caps:Array = [];

      private var rows:Array = TEXT;

      private var hot:int = -1;

      public function Keys()
      {
         super();
         var field:TextField = null;
         var i:int = 0;
         addChild(this.art);
         while(i < TEXT.length * COLS)
         {
            field = renderer.pin(renderer.label(0,0,11,TextFieldAutoSize.CENTER,"",CELL,CELL),
                                 CELL,11);
            addChild(Hit.blind(field));
            this.caps.push(field);
            i++;
         }
         addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
         addEventListener(MouseEvent.CLICK,this.onClick);
      }

      public static function beside(field:Input) : void
      {
         if(one == null)
         {
            one = new Keys();
         }
         box = field;
         one.hot = -1;
         one.rows = field.digits ? NUMS : TEXT;
         one.paint();
         Layer.show(one,field,0,field.tall + 2);
      }

      public static function shows(field:Input) : Boolean
      {
         return one != null && box == field && Layer.shows(one);
      }

      public static function get up() : Boolean
      {
         return one != null && Layer.shows(one);
      }

      public static function lit() : void
      {
         if(up)
         {
            one.hover();
         }
      }

      private function keyAt(row:int, col:int) : String
      {
         var body:String = row < this.rows.length ? String(this.rows[row]) : "";
         return col < body.length ? body.charAt(col) : "";
      }

      private function get cols() : int
      {
         var most:int = 0;
         var i:int = 0;
         while(i < this.rows.length)
         {
            most = Math.max(most,String(this.rows[i]).length);
            i++;
         }
         return most;
      }

      private function get wide() : int
      {
         return EDGE * 2 + this.cols * CELL + (this.cols - 1) * GAP;
      }

      private function get high() : int
      {
         return EDGE * 2 + this.rows.length * CELL + (this.rows.length - 1) * GAP;
      }

      private static function cellX(col:int) : int
      {
         return EDGE + col * (CELL + GAP);
      }

      private static function cellY(row:int) : int
      {
         return EDGE + row * (CELL + GAP);
      }

      private function spotAt(x:Number, y:Number) : int
      {
         var row:int = int((y - EDGE) / (CELL + GAP));
         var col:int = int((x - EDGE) / (CELL + GAP));
         if(x < EDGE || y < EDGE || row < 0 || row >= this.rows.length
            || col < 0 || col >= this.cols)
         {
            return -1;
         }
         if(this.keyAt(row,col).length == 0 || y >= cellY(row) + CELL
            || x >= cellX(col) + CELL)
         {
            return -1;
         }
         return row * COLS + col;
      }

      public function paint() : void
      {
         var what:String = null;
         var spot:int = 0;
         var on:Boolean = false;
         var field:TextField = null;
         var row:int = 0;
         var col:int = 0;
         this.art.graphics.clear();
         renderer.fill(this.art,0,0,this.wide,this.high,renderer.RAISED,1);
         renderer.border(this.art,0,0,this.wide,this.high,renderer.BORDER,1);
         while(row < TEXT.length)
         {
            col = 0;
            while(col < COLS)
            {
               spot = row * COLS + col;
               what = this.keyAt(row,col);
               field = this.caps[spot] as TextField;
               field.visible = what.length == 1 && what != BACK && what != SPACE;
               if(what.length == 0)
               {
                  col++;
                  continue;
               }
               on = spot == this.hot;
               renderer.framed(this.art,cellX(col),cellY(row),CELL,CELL,
                               on ? renderer.RAISED5 : renderer.HEADER,
                               on ? renderer.CYAN : renderer.BORDER,1);
               if(what == BACK)
               {
                  this.rub(cellX(col),cellY(row),on);
               }
               else if(what == SPACE)
               {
                  this.bar(cellX(col),cellY(row),CELL,on);
               }
               else
               {
                  field.x = cellX(col);
                  renderer.say(field,what);
                  field.setTextFormat(field.defaultTextFormat);
                  field.textColor = on ? renderer.VALUE : renderer.LABEL;
                  renderer.centre(field,cellY(row),CELL);
               }
               col++;
            }
            row++;
         }
      }

      private function rub(x:int, y:int, on:Boolean) : void
      {
         var mid:int = y + (CELL >> 1);
         var left:int = x + 8;
         var right:int = x + CELL - 7;
         this.art.graphics.lineStyle(2,on ? renderer.VALUE : renderer.LABEL,1);
         this.art.graphics.moveTo(left,mid);
         this.art.graphics.lineTo(right,mid);
         this.art.graphics.moveTo(left + 4,mid - 4);
         this.art.graphics.lineTo(left,mid);
         this.art.graphics.lineTo(left + 4,mid + 4);
         this.art.graphics.lineStyle();
      }

      private function bar(x:int, y:int, wide:int, on:Boolean) : void
      {
         renderer.fill(this.art,x + 10,y + CELL - 9,wide - 20,2,
                       on ? renderer.VALUE : renderer.LABEL,1);
      }

      public function hover() : void
      {
         var over:int = this.spotAt(this.mouseX,this.mouseY);
         if(over != this.hot)
         {
            this.hot = over;
            this.paint();
         }
      }

      private function onDown(e:MouseEvent) : void
      {
         e.stopPropagation();
      }

      private function onClick(e:MouseEvent) : void
      {
         var spot:int = this.spotAt(this.mouseX,this.mouseY);
         e.stopPropagation();
         if(spot < 0 || box == null)
         {
            return;
         }
         this.tap(this.keyAt(int(spot / COLS),spot % COLS));
      }

      private function tap(what:String) : void
      {
         var held:int = box.value.length;
         Option.click(what != BACK || held > 0);
         if(what != BACK)
         {
            box.compose(held,0,what.toLowerCase());
            return;
         }
         if(held > 0)
         {
            box.compose(held - 1,1,"");
         }
      }
   }
}
