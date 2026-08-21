package ui
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Rectangle;

   /** A picture the SWF carries in its own tag stream, shown at a size a layout asked
    *  for. Iggy draws what is in the tag stream and nothing handed to it at runtime, so
    *  a grafted symbol is the only art a from-scratch screen can put on the glass -
    *  see ART.md.
    *
    *  The symbol class is a field rather than a `new` at the call site because
    *  constructing one is the part that can fail: a class the graft did not bind is a
    *  compile-time success and a runtime throw, and a throw here would take the repaint
    *  it happened in down with it.
    *
    *  The class, the frame and the size are all fields for the same reason ui.Icon's
    *  are: dress() is the method with the try in it, and a parameter used across a try
    *  is hoisted into a local by the compiler, which shows in the decompile as an alias
    *  the source never had. */
   public class Art extends Sprite
   {

      public var kind:Class;

      /** A frame label or a frame number - whichever the symbol was built with. */
      public var frame:*;

      public var box:int = 16;

      /** The part of the symbol's canvas the drawing actually occupies, or null to take
       *  the canvas whole. Vanilla's power-rank shield is a 38 x 45 badge in the middle
       *  of an 88 x 88 frame, so sizing by the canvas draws the margin at the size the
       *  badge was wanted at - the badge comes out at two fifths of it. */
      public var crop:Rectangle;

      private var frame2:Sprite = new Sprite();

      private var clip:MovieClip;

      public function Art(box:int = 16)
      {
         super();
         this.box = box;
         this.visible = false;
         mouseEnabled = false;
         mouseChildren = false;
         addChild(this.frame2);
      }

      public function show(kind:Class, frame:*, box:int) : Boolean
      {
         this.kind = kind;
         this.frame = frame;
         this.box = box;
         return this.dress();
      }

      /** Scaled to fit the box rather than stretched to it, and measured off the frame
       *  it settled on: a clip reports the bounds of whatever frame it is showing, so
       *  the measurement has to follow gotoAndStop rather than precede it.
       *
       *  The crop is a scrollRect on the sprite the clip sits in rather than a shift of
       *  the clip: scrollRect clips and moves in one go, so the wanted part lands on the
       *  container's own origin, and the scale then applies to what is left. */
      private function dress() : Boolean
      {
         var bounds:Rectangle = null;
         var scale:Number = 0;
         this.visible = false;
         try
         {
            if(this.clip == null)
            {
               this.clip = new this.kind();
               this.frame2.addChild(this.clip);
            }
            this.clip.gotoAndStop(this.frame);
            this.frame2.scrollRect = null;
            this.frame2.scaleX = this.frame2.scaleY = 1;
            this.clip.x = this.clip.y = 0;
            bounds = this.crop != null ? this.crop : this.clip.getBounds(this.clip);
            if(bounds.width > 1 && bounds.height > 1)
            {
               if(this.crop != null)
               {
                  this.frame2.scrollRect = this.crop;
               }
               else
               {
                  this.clip.x = -bounds.x;
                  this.clip.y = -bounds.y;
               }
               scale = this.box / Math.max(bounds.width,bounds.height);
               this.frame2.scaleX = this.frame2.scaleY = scale;
               this.visible = true;
            }
         }
         catch(e:Error)
         {
         }
         return this.visible;
      }

      public function get span() : Number
      {
         return this.visible ? this.frame2.width : 0;
      }

      public function get rise() : Number
      {
         return this.visible ? this.frame2.height : 0;
      }
   }
}
