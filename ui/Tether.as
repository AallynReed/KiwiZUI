package ui
{
   import flash.display.Shape;
   import flash.display.Sprite;

   public class Tether extends Sprite
   {

      private static const FADED:Number = 0.45;

      private static const STAR:int = 4;

      public var box:int;

      public var allowed:Boolean = true;

      public var loadedCallback:Function = null;

      private var plate:Shape = new Shape();

      private var mark:Shape = new Shape();

      private var art:ObjectPreview;

      public function Tether(box:int)
      {
         super();
         this.box = box;
         this.visible = false;
         mouseEnabled = false;
         mouseChildren = false;
         this.art = new ObjectPreview(box,box);
         this.art.loadedCallback = this.onArt;
         addChild(this.plate);
         addChild(this.art);
         addChild(this.mark);
      }

      private function onArt(preview:ObjectPreview) : void
      {
         this.paint();
         if(this.loadedCallback != null)
         {
            this.loadedCallback();
         }
      }

      public function show(texture:String, leader:Boolean) : void
      {
         this.art.textureName = texture == null ? "" : texture;
         this.mark.visible = leader;
         this.paint();
      }

      public function set faded(on:Boolean) : void
      {
         this.alpha = on ? FADED : 1;
      }

      public function paint() : void
      {
         this.visible = this.allowed && this.art.loaded;
         this.plate.graphics.clear();
         this.mark.graphics.clear();
         if(this.visible)
         {
            renderer.framed(this.plate,-2,-2,this.box + 4,this.box + 4,renderer.HEADER,
                            renderer.RAISED6);
            renderer.pip(this.mark,this.box - 1,-1,STAR,renderer.CYAN);
         }
      }
   }
}
