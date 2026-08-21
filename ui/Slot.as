package ui
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;

   /** One item square: a rarity-coloured frame, the item's own icon, and the quality
    *  pips under it. The icon is an asynchronous render target rather than a texture,
    *  so ObjectPreview owns the handshake and this only ever hands it a name.
    *
    *  Most of what is public here has no caller in this repo, and that is the point: the
    *  engine drives a slot by writing its properties from the outside, the same way it
    *  calls a screen by callback name. The set comes from the stock decompile, so a
    *  property missing here is an item that silently never appears - nothing in here may
    *  be deleted for looking unused.
    *
    *  Every child is a Shape or a disabled field, which makes the slot itself the mouse
    *  target for everything, so the drag watcher has to listen in the target phase or it
    *  never hears a thing. */
   public class Slot extends Sprite
   {

      public static const CHAOS:int = 6;

      public static const RADIANT:int = 26;

      public static const STELLAR:int = 27;

      /** The five plain rarities. Above them the game bands rarity in runs, so the
       *  frame is worked out from the run rather than kept as an entry per id. */
      private static const PLAIN:Array = [0,0x34CF6A,0x00C5F0,0xC831FB,0xFA8D3E,0xE65050];

      private static const SHADE:uint = 0xD2A6FF;

      private static const RADIANT_EDGE:uint = 0x5CCFE6;

      private static const STELLAR_EDGE:uint = 0xFEC13D;

      /** Weapon, face, hat and banner are the four a player can deliberately leave
       *  unstyled - the last three have a "Hide" style of their own. The engine still
       *  reports a rarity for those, so an empty one has to read as "taken off" rather
       *  than "nothing here". */
      private static const STYLEABLE:Object = {1:true, 2:true, 3:true, 4:true};

      /** The costume, which is slot 0 in the charsheet's own gear table. A character is
       *  never without one, so a costume slot with nothing in it is one still waiting
       *  for its texture rather than an empty one, and it is never drawn as empty. */
      private static const ALWAYS_FILLED:Object = {0:true};

      public var image:ObjectPreview;

      public var size:int = 0;

      /** The element ring the slot was built with, kept apart from `frame` because that
       *  one is cleared and redrawn on every repaint. In a child either way: Iggy
       *  measures a sprite by its children and ignores its own graphics. */
      private var edging:Shape = new Shape();

      private var frame:Shape = new Shape();

      private var pips:Shape = new Shape();

      private var strike:Shape = new Shape();

      private var tally:TextField;

      private var icon:String = "";

      private static const UNSET:int = -1;

      private var rank:int = UNSET;

      private var slotId:Object = null;

      private var picked:Boolean = false;

      private var counted:Boolean = false;

      private var held:int = 0;

      private var dimmed:Boolean = false;

      public var tooltipName:String = "";

      public var tooltipDescription:String = "";

      public var hasRollOver:Boolean = false;

      public var useLargeBitmaps:Boolean = false;

      private var itemName:String = "";

      private var worn:Boolean = false;

      private var canDrag:Boolean = true;

      private var feedback:Boolean = true;

      private var withX:Boolean = false;

      private var hidden:Boolean = false;

      private var fill:Number = 0;

      private var key:String = "";

      private var pipCount:int = 0;

      /** STYLEABLE and ALWAYS_FILLED read the slot id as a gear position, which is what
       *  it is on the character sheet and is not what it is anywhere else. A screen whose
       *  ids are inventory indexes says so here, or its first four squares come out as a
       *  costume and three unstyled gear pieces. */
      private var positional:Boolean = true;

      public function Slot(size:int = 52, edge:int = -1, positional:Boolean = true)
      {
         super();
         this.size = size;
         this.positional = positional;
         addChild(this.edging);
         renderer.framed(this.edging,0,0,size,size,renderer.RAISED2,
                         edge != -1 ? uint(edge) : renderer.PANEL);
         addChild(this.frame);
         addChild(this.strike);
         renderer.fill(this.strike,-1.5,-(size >> 1) + 2,3,size - 4,renderer.RED,0.8);
         this.strike.rotation = 35;
         this.strike.x = size >> 1;
         this.strike.y = size >> 1;
         this.strike.visible = false;
         this.image = new ObjectPreview(size - 8,size - 8);
         this.image.x = 4;
         this.image.y = 4;
         this.image.mouseEnabled = false;
         this.image.loadedCallback = this.onPreviewLoaded;
         addChild(this.image);
         /* The stack count is sized off the square rather than fixed, because the square
            is not: an inventory lets the player choose it, and fifteen point on a forty
            pixel cell overhangs into the one beside it. */
         this.tally = renderer.label(0,size - 16,size >= 56 ? 15 : (size >= 40 ? 12 : 10),
                                     TextFieldAutoSize.RIGHT," ",size,30,false,true);
         this.tally.filters = [renderer.SHADOW,renderer.SHADOW2];
         addChild(this.tally);
         addChild(this.pips);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onPress);
         addEventListener(MouseEvent.CLICK,this.onClick);
         addEventListener(MouseEvent.MOUSE_OVER,this.onEnter);
         addEventListener(MouseEvent.MOUSE_OUT,this.onLeave);
         addEventListener(Event.MOUSE_LEAVE,this.onLeave);
      }


      public function get objectName() : String
      {
         return this.itemName;
      }

      public function set objectName(name:String) : void
      {
         this.itemName = name == null ? "" : name;
      }

      public function get equipped() : Boolean
      {
         return this.worn;
      }

      public function set equipped(on:Boolean) : void
      {
         this.worn = on;
      }

      public function getEquippedStatus() : Boolean
      {
         return this.worn;
      }

      public function get dragEnabled() : Boolean
      {
         return this.canDrag;
      }

      public function set dragEnabled(on:Boolean) : void
      {
         this.canDrag = on;
      }

      public function get clickFeedback() : Boolean
      {
         return this.feedback;
      }

      public function set clickFeedback(on:Boolean) : void
      {
         this.feedback = on;
      }

      public function get showQuantityWithX() : Boolean
      {
         return this.withX;
      }

      public function set showQuantityWithX(on:Boolean) : void
      {
         this.withX = on;
         this.retally();
      }

      public function get styleHidden() : Boolean
      {
         return this.hidden;
      }

      public function set styleHidden(on:Boolean) : void
      {
         this.hidden = on;
      }

      public function get percent() : Number
      {
         return this.fill;
      }

      public function set percent(value:Number) : void
      {
         this.fill = value;
      }

      public function get hotkey() : String
      {
         return this.key;
      }

      public function set hotkey(value:String) : void
      {
         this.key = value == null ? "" : value;
      }

      public function get quality() : int
      {
         return this.pipCount;
      }

      public function set empty(on:Boolean) : void
      {
         if(on)
         {
            this.clear();
         }
      }

      public function setSlotSize(span:Number) : void
      {
         this.image.resize(span - 8,span - 8);
      }

      public function setRarityScale(scale:Number) : void
      {
      }

      public function copyFrom(other:Slot) : void
      {
         if(other == null)
         {
            return;
         }
         this.data = other.data;
         this.rarity = other.rarity;
         this.quantity = other.quantity;
         this.showQuantity = other.showQuantity;
         this.objectName = other.objectName;
         this.iconImage = other.iconImage;
         this.setQuality(other.quality);
      }

      public function activate() : void
      {
         this.selected = false;
         if(this.feedback)
         {
            ExternalInterface.call("POST_SOUND_EVENT","Play_ui_window_click_item");
         }
         ExternalInterface.call("SLOT.ACTIVATE",this.slotId);
      }

      public function hideTooltip() : void
      {
         ExternalInterface.call("TOOLTIP.HIDE");
      }

      public function get iconImage() : String
      {
         return this.icon;
      }

      /** The engine sets this to a render target name rather than a texture path, and
       *  paints the item into it on its own schedule. */
      public function set iconImage(name:String) : void
      {
         var next:String = name == null ? "" : name;
         if(this.icon != next)
         {
            this.icon = next;
            this.image.textureName = next;
            this.paint();
         }
      }

      /** Rebinds even when the name has not changed, which is how a slot re-renders an
       *  item it is already showing.
       *
       *  The name has to be dropped and set again to mean anything: a render target is
       *  bound once and the preview takes itself off the ready list afterwards, so
       *  writing the same name over the top is the no-op the setter says it is. That is
       *  the whole difference between this and iconImage, and it is what an inventory
       *  needs - every square keeps its target name for the life of the screen while the
       *  item standing in it changes all day. */
      public function set forceIconImage(name:String) : void
      {
         var next:String = name == null ? "" : name;
         this.icon = next;
         this.image.textureName = "";
         this.image.textureName = next;
         this.paint();
      }

      public function get rarity() : int
      {
         return this.rank;
      }

      public function set rarity(value:int) : void
      {
         if(this.rank != value)
         {
            this.rank = value;
            this.paint();
         }
      }

      public function setRarity(value:int) : void
      {
         this.rarity = value;
      }

      /** Object, not int, because that is the stock signature: the engine writes null
       *  into it to say the slot stands for nothing, and an int would read that back
       *  as slot zero. */
      public function get data() : Object
      {
         return this.slotId;
      }

      public function set data(id:Object) : void
      {
         if(this.slotId != id)
         {
            this.slotId = id;
            this.paint();
         }
      }

      public function get quantity() : int
      {
         return this.held;
      }

      public function set quantity(count:int) : void
      {
         if(this.held != count)
         {
            this.held = count;
            this.retally();
         }
      }

      private function retally() : void
      {
         this.tally.text = this.held <= 1 ? " " : (this.withX ? "x" : "") + String(this.held);
      }

      public function get showQuantity() : Boolean
      {
         return this.counted;
      }

      public function set showQuantity(on:Boolean) : void
      {
         if(this.counted != on)
         {
            this.counted = on;
            this.tally.visible = on;
         }
      }

      public function get ghosted() : Boolean
      {
         return this.dimmed;
      }

      public function set ghosted(on:Boolean) : void
      {
         if(this.dimmed != on)
         {
            this.dimmed = on;
            this.image.filters = on ? [renderer.GHOST] : [];
         }
      }

      public function get locked() : Boolean
      {
         return this.strike.visible;
      }

      public function set locked(on:Boolean) : void
      {
         this.strike.visible = on;
      }

      public function set quality(count:int) : void
      {
         this.setQuality(count);
      }

      /** Selection nudges the whole square inwards rather than drawing a second state,
       *  so it costs nothing to repaint and never fights the rarity frame. */
      public function get selected() : Boolean
      {
         return this.picked;
      }

      public function set selected(on:Boolean) : void
      {
         if(this.picked == on)
         {
            return;
         }
         this.picked = on;
         var nudge:Number = this.size * 0.075;
         this.x += on ? nudge : -nudge;
         this.y += on ? nudge : -nudge;
         this.scaleX = this.scaleY = on ? 0.85 : 1;
      }

      public function clear() : void
      {
         this.data = -1;
         this.rarity = 0;
         this.quantity = 0;
         this.showQuantity = false;
         this.icon = "";
         this.image.textureName = "";
         this.setQuality(0);
      }

      /** A gem's quality, as that many stars centred along the bottom edge.
       *
       *  Sized to fit rather than fixed. Five stars at a fixed radius are wider than the
       *  square they sit on at any cell size this screen offers, and the row that
       *  overflows is the five-star one - which is the row a player most wants to see. */
      public function setQuality(count:int) : void
      {
         var span:Number = this.size - 4;
         var radius:Number = 0;
         var step:Number = 0;
         var left:Number = 0;
         var i:int = 0;
         this.pipCount = count;
         this.pips.graphics.clear();
         if(count <= 0)
         {
            return;
         }
         radius = Math.min(this.size * 0.13,span / count * 0.62);
         step = count > 1 ? (span - radius * 2) / (count - 1) : 0;
         left = (this.size - (step * (count - 1) + radius * 2)) / 2 + radius;
         while(i < count)
         {
            renderer.pip(this.pips,left + i * step,this.size - radius - 1,radius,renderer.YELLOW);
            i++;
         }
      }

      /** Chaos has no colour of its own - it is drawn as the whole sweep. */
      private static function frameFor(rarity:int) : int
      {
         if(rarity <= 0) { return 0; }
         if(rarity <= 5) { return int(PLAIN[rarity]); }
         if(rarity == CHAOS) { return -1; }
         if(rarity <= 11) { return SHADE; }
         if(rarity <= 21) { return rarity % 2 == 0 ? 0xD3E1F5 : 0xFFB454; }
         if(rarity <= 26) { return RADIANT_EDGE; }
         return STELLAR_EDGE;
      }

      /** Public so a screen can put the palette through every slot it owns: the engine
       *  fills a slot once and a colour arriving from the config has to reach it. */
      public function paint() : void
      {
         var edge:int = frameFor(this.rank);
         var span:int = this.size;
         this.frame.graphics.clear();
         if(this.rank > 0)
         {
            if(edge == -1)
            {
               renderer.chaos(this.frame,0,0,span,span);
            }
            else
            {
               renderer.fill(this.frame,0,0,span,span,uint(edge));
            }
            renderer.fill(this.frame,2,2,span - 4,span - 4,renderer.RAISED2);
            if(this.rank >= STELLAR)
            {
               renderer.triband(this.frame,3,3,span - 6,span - 6,0x8913B9,0xB622D9,0x1C97C3);
               renderer.fill(this.frame,5,5,span - 10,span - 10,renderer.RAISED2);
            }
            else if(this.rank == RADIANT)
            {
               renderer.fill(this.frame,3,3,span - 6,span - 6,0x95E6CB);
               renderer.fill(this.frame,5,5,span - 10,span - 10,renderer.RAISED2);
            }
         }
         // Which of the three states a slot is in cannot be read from any one signal.
         // The engine writes rarity, quantity, iconImage, showQuantity and locked and
         // nothing else, and it does not write a rarity for every slot:
         //
         //   emblem  rarity -1, no quantity, preview loaded  - equipped, rarity never set
         //   gem     rarity -1, no quantity, preview loaded  - the same
         //   flask   rarity  0, quantity 14, preview loaded  - a real icon
         //   mount   rarity  0, no quantity, nothing loaded  - empty
         //   face    rarity 23, no quantity, nothing loaded  - equipped, no style set
         //   hat     rarity 24, no quantity, preview loaded  - a real icon
         //
         // Rarity is not the signal for empty and never was: emblems and gems sit at
         // UNSET with something in them, which an earlier reading of that first line
         // took for an untouched slot. A loaded preview is the one thing that says a
         // slot has an item in it, so it is asked first and nothing overrides it.
         if(this.image.loaded)
         {
            return;
         }
         if(this.positional && this.slotId != null && ALWAYS_FILLED[Number(this.slotId)] != null)
         {
            return;
         }
         if(this.rank == UNSET)
         {
            renderer.dashed(this.frame,0,0,span,span,renderer.BORDER,0.7);
            return;
         }
         // Equipped but with no style chosen: the barred circle alone.
         if(this.positional && this.rank > 0 && STYLEABLE[Number(this.slotId)] != null)
         {
            renderer.noEntry(this.frame,span >> 1,span >> 1,span * 0.27,
                             renderer.LABEL,renderer.RAISED2,0.85);
            return;
         }
         renderer.dashed(this.frame,0,0,span,span,renderer.BORDER,0.7);
      }

      /** Whether this slot is showing an item. */
      public function shown() : Boolean
      {
         return this.rank != UNSET && this.image.loaded;
      }

      /** The texture arrives on the engine's own schedule, so a slot is drawn empty
       *  first and redrawn when something actually lands in it. */
      private function onPreviewLoaded(preview:ObjectPreview) : void
      {
         this.paint();
      }

      /** Announced the way the stock class announces it. The gem screen acts on this;
       *  the character sheet does not, and neither does Trove's own - dragging an item
       *  out of a gear slot is not something that screen has ever done. The call is what
       *  the stock slot sends either way, so it stays. */
      private function onPress(e:MouseEvent) : void
      {
         this.selected = true;
         if(this.slotId != null && this.canDrag)
         {
            SlotDragDropHelper.startDrag(this,e.stageX,e.stageY,Number(this.slotId),this.image.textureName);
         }
      }

      private function onClick(e:MouseEvent) : void
      {
         this.activate();
      }

      private function onEnter(e:MouseEvent) : void
      {
         var corner:Point = localToGlobal(new Point(width,height));
         var top:Point = null;
         ExternalInterface.call("SLOT.POINTER_ENTER",this.slotId,corner.x,corner.y);
         if(this.tooltipName.length > 0 || this.tooltipDescription.length > 0)
         {
            top = localToGlobal(new Point(this.width / 2,0));
            ExternalInterface.call("TOOLTIP.SHOW",top.x,top.y,this.tooltipName,this.tooltipDescription);
         }
      }

      private function onLeave(e:Event) : void
      {
         ExternalInterface.call("TOOLTIP.HIDE");
         ExternalInterface.call("SLOT.POINTER_LEAVE",this.slotId);
         this.selected = false;
      }
   }
}
