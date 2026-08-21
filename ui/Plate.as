package ui
{
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;

   /** A flat plate that repaints out of the palette rather than baking it in, so a
    *  colour arriving from the config reaches every button already on screen.
    *
    *  The plate is drawn into a child rather than into its own graphics, because Iggy
    *  measures a sprite by its children: a plate with no caption and nothing but its
    *  own graphics came back zero wide, and a control that measures zero does not
    *  merely miss its own clicks - it takes the ones around it too. */
   public class Plate extends Sprite
   {

      /** Between a mark and the word beside it. */
      private static const ICON_GAP:int = 6;

      public var caption:TextField;

      private var box:Shape = new Shape();

      public var live:Boolean = true;

      /** Drawn over the plate after it is framed, for a button whose face is a mark
       *  rather than a word. It draws into `face`, never into the plate's own
       *  graphics: a sprite's own drawing sits under its children, so a mark put there
       *  would be buried by the box. Reads the caption colour, so it lights with the
       *  rest. */
      public var mark:Function = null;

      public var face:Shape = new Shape();

      /** A mark beside the caption, for a plate whose subject is a thing rather than a
       *  word - a currency, an item. Null until one is set, so a plate that never asks
       *  for one is exactly the plate it always was. */
      public var mark2:DisplayObject;

      /** Kept separately from mark2 so a plate that binds a texture path does not
       *  rebuild the bitmap it is binding onto each time. */
      public var icon:Icon;

      /** Set when the owner works out the hover itself. The plate then ignores its own
       *  roll events rather than being taken off the mouse: turning the mouse off a
       *  header button stopped clicks reaching anything at all in Iggy. */
      public var driven:Boolean = false;

      public var on:Boolean = false;

      /** One of a run of buttons that share a single frame drawn around the lot of them.
       *  A bare plate draws no edge of its own and says it is current by lifting its
       *  face, because a border on every segment of a group reads as a row of buttons
       *  rather than as one control with a choice in it. */
      public var bare:Boolean = false;

      private var w:int;

      private var h:int;

      private var hot:Boolean = false;

      public function Plate(w:int, h:int, size:int)
      {
         super();
         this.w = w;
         this.h = h;
         addChild(this.box);
         addChild(this.face);
         /* Pinned for the same reason ui.Button is: a mark-only plate has no caption
            text, and a caption that measures zero wide is what put an invisible button
            across a header once already. */
         this.caption = renderer.pin(renderer.label(0,0,size,TextFieldAutoSize.CENTER,"",w,h,false,true),w,size);
         this.caption.x = 0;
         addChild(this.caption);
         mouseChildren = false;
         addEventListener(MouseEvent.ROLL_OVER,this.onHover);
         addEventListener(MouseEvent.ROLL_OUT,this.onHover);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onPress);
      }

      /** A plate whose size is decided by a layout rather than at construction. The
       *  caption is pinned to a width, so it has to be told the new one or the text
       *  keeps centring on the old box. */
      public function resize(w:int, h:int) : void
      {
         this.w = w;
         this.h = h;
         this.caption.width = w;
         this.place();
      }

      public function set text(body:String) : void
      {
         this.caption.text = body;
         this.caption.setTextFormat(this.caption.defaultTextFormat);
         this.place();
      }

      /** Binds a game texture to the mark and says whether one arrived, so a caller can
       *  put the word back rather than leave a plate carrying a bare number. */
      public function setIcon(texture:String, size:int) : Boolean
      {
         if(this.icon == null)
         {
            this.icon = new Icon(size);
         }
         this.icon.show(texture,size);
         this.setMark(this.icon);
         return this.icon.visible;
      }

      /** Any picture at all as the mark - a grafted symbol, most of the time, because a
       *  texture path only resolves for art the game already has resident. */
      public function setMark(art:DisplayObject) : void
      {
         if(this.mark2 != art)
         {
            if(this.mark2 != null && this.mark2.parent == this)
            {
               removeChild(this.mark2);
            }
            this.mark2 = art;
            if(art != null)
            {
               addChild(art);
            }
         }
         this.place();
      }

      /** The mark and the word are centred as one, so the plate reads as a single label
       *  rather than as a picture with a number pushed off to the side. The caption keeps
       *  its full width and its centre alignment; shifting it is what puts the text
       *  where the pair wants it, and the shift is zero when there is no mark. */
      private function place() : void
      {
         var span:Number = 0;
         var left:Number = 0;
         if(this.mark2 == null || !this.mark2.visible)
         {
            this.caption.x = 0;
            return;
         }
         span = this.mark2.width + ICON_GAP + this.caption.textWidth;
         left = (this.w - span) / 2;
         this.mark2.x = left;
         this.mark2.y = (this.h - this.mark2.height) / 2;
         this.caption.x = left + this.mark2.width + ICON_GAP
                        - (this.w - this.caption.textWidth) / 2;
      }

      public function paint() : void
      {
         var edge:uint = this.on || this.hot && this.live ? renderer.CYAN : renderer.BORDER;
         graphics.clear();
         this.box.graphics.clear();
         if(this.bare)
         {
            renderer.fill(this.box,0,0,this.w,this.h,
                          this.on ? renderer.RAISED5 : renderer.HEADER,
                          this.on ? 1 : this.hot && this.live ? 0.55 : 0);
         }
         else
         {
            renderer.framed(this.box,0,0,this.w,this.h,renderer.HEADER,edge,1);
         }
         this.caption.textColor = !this.live ? renderer.LABEL
                                : this.on ? renderer.VALUE
                                : this.hot ? renderer.VALUE : renderer.LABEL;
         if(!this.bare)
         {
            this.caption.textColor = !this.live ? renderer.LABEL
                                   : this.on ? renderer.CYAN : renderer.VALUE;
         }
         renderer.centre(this.caption,0,this.h);
         this.alpha = this.live ? 1 : 0.55;
         this.buttonMode = this.live;
         this.face.graphics.clear();
         if(this.mark != null)
         {
            this.mark(this);
         }
      }

      public function get hovered() : Boolean
      {
         return this.hot;
      }

      public function set hovered(on:Boolean) : void
      {
         if(this.hot != on)
         {
            this.hot = on;
            this.paint();
         }
      }

      private function onHover(e:MouseEvent) : void
      {
         if(!this.driven)
         {
            this.hovered = e.type == MouseEvent.ROLL_OVER;
         }
      }

      private function onPress(e:MouseEvent) : void
      {
         Option.click(this.live);
      }
   }
}
