package ui
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;

   public class Keys extends Sprite
   {

      private static const ROWS:Array = ["1234567890","QWERTYUIOP","ASDFGHJKL","ZXCVBNM_"];

      private static const COLS:int = 10;

      private static const CELL:int = 26;

      private static const GAP:int = 3;

      private static const EDGE:int = 6;

      private static const BACK:String = "\b";

      private static const SPACE:String = " ";

      private static const BACK_ROW:int = 2;

      private static const SPACE_ROW:int = 3;

      private static const SPACE_COL:int = 8;

      public static const W:int = EDGE * 2 + COLS * CELL + (COLS - 1) * GAP;

      public static const H:int = EDGE * 2 + ROWS.length * CELL + (ROWS.length - 1) * GAP;

      private static var one:Keys;

      private static var box:Input;

      private var art:Shape = new Shape();

      private var caps:Array = [];

      private var hot:int = -1;

      public function Keys()
      {
         super();
         var field:TextField = null;
         var i:int = 0;
         addChild(this.art);
         while(i < ROWS.length * COLS)
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

      private static function keyAt(row:int, col:int) : String
      {
         var body:String = String(ROWS[row]);
         if(col < body.length)
         {
            return body.charAt(col);
         }
         if(row == BACK_ROW && col == COLS - 1)
         {
            return BACK;
         }
         return row == SPACE_ROW && col >= SPACE_COL ? SPACE : "";
      }

      private static function cellX(col:int) : int
      {
         return EDGE + col * (CELL + GAP);
      }

      private static function cellY(row:int) : int
      {
         return EDGE + row * (CELL + GAP);
      }

      private static function cellW(what:String) : int
      {
         return what == SPACE ? CELL * 2 + GAP : CELL;
      }

      private function spotAt(x:Number, y:Number) : int
      {
         var row:int = int((y - EDGE) / (CELL + GAP));
         var col:int = int((x - EDGE) / (CELL + GAP));
         var what:String = null;
         if(x < EDGE || y < EDGE || row < 0 || row >= ROWS.length || col < 0 || col >= COLS)
         {
            return -1;
         }
         what = keyAt(row,col);
         if(what == SPACE)
         {
            col = SPACE_COL;
         }
         if(what.length == 0 || y >= cellY(row) + CELL || x >= cellX(col) + cellW(what))
         {
            return -1;
         }
         return row * COLS + col;
      }

      public function paint() : void
      {
         var what:String = null;
         var spot:int = 0;
         var wide:int = 0;
         var on:Boolean = false;
         var field:TextField = null;
         var row:int = 0;
         var col:int = 0;
         this.art.graphics.clear();
         renderer.fill(this.art,0,0,W,H,renderer.RAISED,1);
         renderer.border(this.art,0,0,W,H,renderer.BORDER,1);
         while(row < ROWS.length)
         {
            col = 0;
            while(col < COLS)
            {
               spot = row * COLS + col;
               what = keyAt(row,col);
               field = this.caps[spot] as TextField;
               field.visible = what.length == 1 && what != BACK && what != SPACE;
               if(what.length == 0 || what == SPACE && col > SPACE_COL)
               {
                  col++;
                  continue;
               }
               on = spot == this.hot;
               wide = cellW(what);
               renderer.framed(this.art,cellX(col),cellY(row),wide,CELL,
                               on ? renderer.RAISED5 : renderer.HEADER,
                               on ? renderer.CYAN : renderer.BORDER,1);
               if(what == BACK)
               {
                  this.rub(cellX(col),cellY(row),on);
               }
               else if(what == SPACE)
               {
                  this.bar(cellX(col),cellY(row),wide,on);
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
         this.tap(keyAt(int(spot / COLS),spot % COLS));
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
