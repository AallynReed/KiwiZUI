package ui
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;

   public class ObjectPreview extends Sprite
   {

      private static const WAITING:Dictionary = new Dictionary();

      private static var armed:Boolean = false;

      private var _textureName:String;

      private var image:Bitmap = new Bitmap(new BitmapData(1,1));

      private var _imageWidth:Number;

      private var _imageHeight:Number;

      private var _loaded:Boolean = false;

      private var filed:String = null;

      public var loadedCallback:Function = null;

      public function ObjectPreview(w:int = -1, h:int = -1)
      {
         super();
         addChild(this.image);
         this._imageWidth = w;
         this._imageHeight = h;
         this.addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
         arm();
      }

      private static function arm() : void
      {
         if(armed || !IggyFunctions.inIggy)
         {
            return;
         }
         armed = true;
         ExternalInterface.addCallback("objectPreviewReady",objectPreviewReady);
      }

      public static function objectPreviewReady(texture:String) : void
      {
         var preview:ObjectPreview = null;
         var key:String = texture == null ? "" : texture;
         var queue:Array = WAITING[key] as Array;
         var i:int = 0;
         if(queue == null)
         {
            return;
         }
         delete WAITING[key];
         while(i < queue.length)
         {
            preview = queue[i] as ObjectPreview;
            i++;
            if(preview == null || preview.filed != key)
            {
               continue;
            }
            preview.filed = null;
            preview.replaceTexture();
         }
      }

      public function get loaded() : Boolean
      {
         return this._loaded;
      }

      public function get imageWidth() : int
      {
         return this.image.width;
      }

      public function get imageHeight() : int
      {
         return this.image.height;
      }

      public function get textureName() : String
      {
         if(this._textureName)
         {
            return this._textureName;
         }
         return "";
      }

      public function set textureName(name:String) : void
      {
         if(this._textureName == name)
         {
            return;
         }
         this._textureName = name;
         if(!name || name.length == 0)
         {
            this.removeListener();
            if(IggyFunctions.inIggy)
            {
               IggyFunctions.setTextureForBitmap(this.image,null);
               this._loaded = false;
            }
            return;
         }
         this.addListener();
      }

      public function getBitmapBounds() : Rectangle
      {
         return this.image.getBounds(this.image);
      }

      private function addListener() : void
      {
         var queue:Array = null;
         this.removeListener();
         this.filed = this._textureName;
         queue = WAITING[this.filed] as Array;
         if(queue == null)
         {
            queue = [];
            WAITING[this.filed] = queue;
         }
         if(queue.indexOf(this) < 0)
         {
            queue.push(this);
         }
         if(IggyFunctions.inIggy)
         {
            ExternalInterface.call("UIComponent.CheckTextureExists",this._textureName);
         }
      }

      private function onRemovedFromStage(e:Event) : void
      {
         this.removeListener();
      }

      private function removeListener() : void
      {
         var at:int = 0;
         var queue:Array = this.filed == null ? null : WAITING[this.filed] as Array;
         if(queue != null)
         {
            at = queue.indexOf(this);
            if(at >= 0)
            {
               queue.splice(at,1);
            }
            if(queue.length == 0)
            {
               delete WAITING[this.filed];
            }
         }
         this.filed = null;
      }

      private function replaceTexture() : void
      {
         var bounds:Rectangle = null;
         try
         {
            IggyFunctions.setTextureForBitmap(this.image,null);
            this.image.scaleX = this.image.scaleY = 1;
            IggyFunctions.setTextureForBitmap(this.image,this._textureName,this._imageWidth,this._imageHeight);
            bounds = this.image.getBounds(this.image);
            if(this._imageWidth < 0)
            {
               this._imageWidth = bounds.width;
            }
            else
            {
               this.image.width = this._imageWidth;
            }
            if(this._imageHeight < 0)
            {
               this._imageHeight = bounds.height;
            }
            else
            {
               this.image.height = this._imageHeight;
            }
            this._loaded = true;
            if(this.loadedCallback != null)
            {
               this.loadedCallback(this);
            }
         }
         catch(e:ArgumentError)
         {
         }
      }

      public function resize(w:Number, h:Number) : void
      {
         if(this._imageWidth == w && this._imageHeight == h)
         {
            return;
         }
         this._imageWidth = w;
         this._imageHeight = h;
         if(!this._loaded || !this._textureName || this._textureName.length == 0)
         {
            return;
         }
         this.image.width = Math.abs(w);
         this.image.height = Math.abs(h);
         if(IggyFunctions.inIggy)
         {
            ExternalInterface.call("UIComponent.CheckTextureExists",this._textureName);
         }
      }
   }
}
