package ui
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.geom.Rectangle;

   /** A bitmap that knows which game texture it is meant to be showing.
    *
    *  A path the game does not have throws, and outside Iggy nothing binds at all, so
    *  the bind is wrapped and reports whether art actually arrived - which is what lets
    *  a caller put a word back rather than leave a button carrying a bare number.
    *
    *  The texture and the size are fields rather than arguments to the call that binds
    *  them, because bind() is the part with the try in it: a function with parameters
    *  and a try has those parameters hoisted into locals by the compiler, and the
    *  decompile then shows an alias the source never had - which costs the build its
    *  fixed point over its own decompile for nothing. */
   public class Icon extends Bitmap
   {

      public var texture:String = "";

      public var box:int = 16;

      /** What bind() is painting. Normally this icon itself; paint() points it at
       *  someone else's bitmap. A field rather than an argument because the call that
       *  reads it is the one with the try in it, and a parameter used across a try is
       *  hoisted into a local by the compiler - which shows up in the decompile as an
       *  alias the source never had. */
      private var canvas:Bitmap;

      public function Icon(box:int = 16)
      {
         super(new BitmapData(1,1,true,0));
         this.box = box;
         this.visible = false;
      }

      public function show(texture:String, box:int) : Boolean
      {
         this.texture = texture == null ? "" : texture;
         this.box = box;
         return this.bind();
      }

      /** The same bind for a caller that is holding a plain Bitmap. */
      public static function paint(image:Bitmap, texture:String, box:int) : Boolean
      {
         var mask:Icon = new Icon(box);
         mask.texture = texture == null ? "" : texture;
         mask.canvas = image;
         return mask.dress();
      }

      /** The sequence is ObjectPreview's, because it is the one Iggy accepts: clear the
       *  bitmap, reset the scale, bind, and only then resize - the size comes from the
       *  file and not from the call's arguments. Measured before the resize, since after
       *  it every bitmap is the size that was asked for whether or not anything came. */
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
               /* Fitted into the square rather than stretched to it: the art is the
                  game's and nothing here knows it is square. */
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
