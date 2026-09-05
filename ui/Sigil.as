package ui
{
   import flash.display.MovieClip;
   import flash.display.Sprite;

   public class Sigil extends Sprite
   {

      private var clip:InsigniaArt;

      public function Sigil()
      {
         super();
         this.visible = false;
         mouseChildren = false;
         this.build();
      }

      private function build() : void
      {
         try
         {
            this.clip = new InsigniaArt();
            addChild(this.clip);
         }
         catch(e:Error)
         {
         }
      }

      public function show(shieldFrame:int, wingsFrame:int) : Boolean
      {
         if(this.clip == null)
         {
            return false;
         }
         this.stopAt(this.clip.shield,shieldFrame);
         this.stopAt(this.clip.wings,wingsFrame);
         this.visible = true;
         return true;
      }

      private function stopAt(clip:MovieClip, frame:int) : void
      {
         if(clip != null)
         {
            clip.gotoAndStop(frame < 1 || frame > clip.totalFrames ? 1 : frame);
         }
      }

      public function get span() : Number
      {
         return this.clip == null ? 0 : this.clip.width;
      }

      public function get rise() : Number
      {
         return this.clip == null ? 0 : this.clip.height;
      }
   }
}
