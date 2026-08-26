package ui
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Rectangle;

   public class Art extends Sprite
   {

      public var kind:Class;

      public var frame:*;

      public var box:int = 16;

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
