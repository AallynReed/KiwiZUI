package ui
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.geom.Rectangle;

   public class Icon extends Bitmap
   {

      public var texture:String = "";

      public var box:int = 16;

      private var canvas:Bitmap;

      private static const TRIES:int = 10;

      private var asked:String = null;

      private var sized:int = -1;

      private var got:Boolean = false;

      private var tries:int = 0;

      public function Icon(box:int = 16)
      {
         super(new BitmapData(1,1,true,0));
         this.box = box;
         this.visible = false;
      }

      public function show(texture:String, box:int) : Boolean
      {
         var want:String = texture == null ? "" : texture;
         var cap:int = want.length == 0 ? 1 : TRIES;
         if(want != this.asked || box != this.sized)
         {
            this.asked = want;
            this.sized = box;
            this.tries = 0;
            this.got = false;
         }
         if(this.got || this.tries >= cap)
         {
            return this.got;
         }
         this.tries++;
         this.texture = want;
         this.box = box;
         this.got = this.bind();
         return this.got;
      }

      public static function paint(image:Bitmap, texture:String, box:int) : Boolean
      {
         var mask:Icon = new Icon(box);
         mask.texture = texture == null ? "" : texture;
         mask.canvas = image;
         return mask.dress();
      }

      public function bind() : Boolean
      {
         this.canvas = this;
         return this.dress();
      }

      private function dress() : Boolean
      {
         var bounds:Rectangle = null;
         var scale:Number = 0;
         this.canvas.visible = false;
         try
         {
            IggyFunctions.setTextureForBitmap(this.canvas,null);
            this.canvas.scaleX = this.canvas.scaleY = 1;
            IggyFunctions.setTextureForBitmap(this.canvas,this.texture);
            bounds = this.canvas.getBounds(this.canvas);
            if(bounds.width > 1 && bounds.height > 1)
            {
               scale = this.box / Math.max(bounds.width,bounds.height);
               this.canvas.width = bounds.width * scale;
               this.canvas.height = bounds.height * scale;
               this.canvas.visible = true;
            }
         }
         catch(e:Error)
         {
         }
         return this.canvas.visible;
      }
   }
}
