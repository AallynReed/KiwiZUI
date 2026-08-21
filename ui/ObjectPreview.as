package ui
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import flash.geom.Rectangle;
   
   public class ObjectPreview extends Sprite
   {
      
      private static var listeners:Array = null;
      
      private var _textureName:String;
      
      private var image:Bitmap = new Bitmap(new BitmapData(1,1));
      
      private var _imageWidth:Number;
      
      private var _imageHeight:Number;
      
      private var _loaded:Boolean = false;
      
      public var loadedCallback:Function = null;
      
      public function ObjectPreview(param1:int = -1, param2:int = -1)
      {
         super();
         addChild(this.image);
         this._imageWidth = param1;
         this._imageHeight = param2;
         this.addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
         if(IggyFunctions.inIggy)
         {
            ExternalInterface.addCallback("objectPreviewReady",objectPreviewReady);
         }
      }
      
      private static function findListener(param1:ObjectPreview) : int
      {
         var _loc2_:int = 0;
         if(listeners)
         {
            _loc2_ = 0;
            while(_loc2_ < listeners.length)
            {
               if(listeners[_loc2_] == param1)
               {
                  return _loc2_;
               }
               _loc2_++;
            }
         }
         return -1;
      }
      
      public static function objectPreviewReady(param1:String) : void
      {
         var _loc2_:ObjectPreview = null;
         var _loc3_:* = 0;
         if(listeners != null)
         {
            _loc2_ = null;
            _loc3_ = int(listeners.length - 1);
            while(_loc3_ >= 0)
            {
               _loc2_ = listeners[_loc3_] as ObjectPreview;
               if(_loc2_)
               {
                  if(param1 == _loc2_.textureName)
                  {
                     _loc2_.removeListener();
                     _loc2_.replaceTexture();
                  }
               }
               _loc3_--;
            }
         }
      }
      
      /** True only once a texture has actually rendered into the bitmap. A slot is
       *  handed a target name whether or not anything is in it, so this is the only
       *  honest answer to "is something shown here". */
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
      
      public function set textureName(param1:String) : void
      {
         if(this._textureName != param1)
         {
            this._textureName = param1;
            if(!param1 || param1.length == 0)
            {
               if(IggyFunctions.inIggy)
               {
                  this.removeListener();
                  IggyFunctions.setTextureForBitmap(this.image,null);
                  this._loaded = false;
               }
            }
            else
            {
               this.addListener();
            }
         }
      }
      
      public function getBitmapBounds() : Rectangle
      {
         return this.image.getBounds(this.image);
      }
      
      private function addListener() : void
      {
         if(!listeners)
         {
            listeners = [];
         }
         if(findListener(this) == -1)
         {
            listeners.push(this);
         }
         if(IggyFunctions.inIggy)
         {
            ExternalInterface.call("UIComponent.CheckTextureExists",this._textureName);
         }
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         this.removeListener();
      }
      
      private function removeListener() : void
      {
         var _loc1_:int = findListener(this);
         if(_loc1_ >= 0)
         {
            listeners.splice(_loc1_,1);
         }
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
         /* Iggy throws this when the name is not a texture it has finished with, and
            it takes down whatever called us if it gets out. The screen has nothing to
            do about it either way: the engine calls objectPreviewReady again when the
            target is actually ready. */
         catch(e:ArgumentError)
         {
         }
      }
      
      public function resize(param1:Number, param2:Number) : void
      {
         this._imageWidth = param1;
         this._imageHeight = param2;
         if(Boolean(this._loaded) && Boolean(this._textureName) && this._textureName.length > 0)
         {
            this.image.width = Math.abs(param1);
            this.image.height = Math.abs(param2);
            if(IggyFunctions.inIggy)
            {
               ExternalInterface.call("UIComponent.CheckTextureExists",this._textureName);
            }
         }
      }
   }
}

