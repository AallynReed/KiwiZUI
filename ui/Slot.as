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

      /** Where this square's tooltip should open, if the screen holding it has an opinion.
       *
       *  The engine grows a tooltip right and down from the point it is handed and only
       *  turns it round at the edge of the screen - so anchored on the square, it opens
       *  straight across the rest of the grid. Ours is the only thing that knows where
       *  the window ends, and Tip.beside is what answers it.
       *
       *  **It is SLOT.POINTER_ENTER the item tooltip comes from**, not TOOLTIP.SHOW. The
       *  engine looks the item up by the id it is handed and draws the card itself;
       *  TOOLTIP.SHOW is the plain-text one a control asks for by hand, and a square in a
       *  bag has no text of its own to ask with. Moving only that one moved nothing.
       *
       *  A function on the square rather than a window registered on Tip: two of these
       *  screens can be open at once, and a static would have the second one's window
       *  answering for the first one's squares. A screen that sets nothing keeps both of
       *  the points a slot always had. */
      public var tipAnchor:Function = null;

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

      /** How far a pressed square shrinks. */
      private static const PRESS:Number = 0.85;

      /** The pitch of a row of quality stars, as a multiple of one star's radius.
       *
       *  Two would put them edge to edge, and under two they overlap - which is wanted.
       *  A row that may not overlap at all has to shrink the star to fit five of them in
       *  a square, and five tiny stars read worse than five overlapping ones; a star is a
       *  spiky outline and the points interleave. What was wrong before was not the
       *  overlap, it was that the pitch was worked out from the square instead of from
       *  the star, so one star sat alone in the middle and five piled up. */
      private static const PIP_PITCH:Number = 1.75;

      private var rank:int = UNSET;

      private var slotId:Object = null;

      private var picked:Boolean = false;

      private var counted:Boolean = false;

      private var held:int = 0;

      private var dimmed:Boolean = false;

      public var tooltipName:String = "";

      public var tooltipDescription:String = "";

      /** Whether the square lights under the pointer. The stock slot walks its frame to
       *  a highlight state on roll over and back on roll out, and only when nothing is
       *  worn in it - a gear square that is filled says so already. */
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

      private var mark:uint = 0;

      private var lit:Boolean = false;

      private var fresh:Boolean = false;

      /** Everything drawn lives in here and never in the slot itself.
       *
       *  A press shrinks the square, and a shrink has to be offset by half of what it
       *  took away or it collapses towards the top left corner. Done on the slot, that
       *  offset is written into the same x and y the grid lays the slot out with - so
       *  any reflow between the press and the release wipes it, the square scales about
       *  its corner, and the release then takes the offset off a position that never had
       *  it and leaves the whole cell adrift.
       *
       *  Scaling a child instead keeps the press out of the layout entirely. It is deaf
       *  to the mouse so the slot stays the target of everything, which is what the drag
       *  watcher listens on. */
      private var body:Sprite = new Sprite();

      /** How much of the highlight colour a marked square carries. Behind the icon
       *  rather than around it: the frame is already the rarity's and a second ring
       *  beside it reads as a thicker frame rather than as a different thing. */
      private static const MARK_WASH:Number = 0.3;

      /** The radius of the dot a square carries while what is in it is new. */
      private static const MARK_DOT:Number = 3;

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
         this.body.mouseEnabled = false;
         this.body.mouseChildren = false;
         addChild(this.body);
         this.body.addChild(this.edging);
         renderer.framed(this.edging,0,0,size,size,renderer.RAISED2,
                         edge != -1 ? uint(edge) : renderer.PANEL);
         this.body.addChild(this.frame);
         this.body.addChild(this.strike);
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
         this.body.addChild(this.image);
         /* The stack count is sized off the square rather than fixed, because the square
            is not: an inventory lets the player choose it, and fifteen point on a forty
            pixel cell overhangs into the one beside it.
            Along the top edge, which is the part of an icon that is most often empty -
            against the bottom it sat over the heaviest part of the art and shared the
            edge with the quality stars, and a small square left it unreadable. */
         this.tally = renderer.label(0,TALLY_PAD,size >= 56 ? 15 : (size >= 40 ? 12 : 10),
                                     TextFieldAutoSize.RIGHT," ",size,30,false,true);
         this.tally.filters = [renderer.SHADE];
         this.body.addChild(this.tally);
         this.body.addChild(this.pips);
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

      /** Carried because the engine writes it, and acted on by nothing.
       *
       *  The stock slot registers its press and click listeners behind this flag, and
       *  reproducing that killed clicking outright - so whatever the engine is setting it
       *  to here, a square that stops answering the mouse is never the right reading of
       *  it. A slot activates when it is clicked. */
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

      /** The colour this square is picked out in, or zero for one that is not. */
      public function get highlight() : uint
      {
         return this.mark;
      }

      public function set highlight(color:uint) : void
      {
         if(this.mark != color)
         {
            this.mark = color;
            this.paint();
         }
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
         this.highlight = other.highlight;
         this.setQuality(other.quality);
      }

      public function activate() : void
      {
         this.selected = false;
         ExternalInterface.call("POST_SOUND_EVENT","Play_ui_window_click_item");
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

      /** Where the number sits against the top edge of the square. Negative because a
       *  TextField carries a two pixel gutter above its first line, so a pad of zero is
       *  already two pixels of nothing - this puts the digits on the edge itself. */
      private static const TALLY_PAD:int = -2;

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

      /** Guarded, because setQuality redraws the row and the property is written on
       *  every refill - a screen that re-asks the engine on a clock would otherwise
       *  redraw every star it owns for nothing. setQuality itself stays unconditional:
       *  it is also how a caller redraws the row at a new size. */
      public function set quality(count:int) : void
      {
         if(this.pipCount != count)
         {
            this.setQuality(count);
         }
      }

      /** Selection shrinks the square inwards rather than drawing a second state, so it
       *  costs nothing to repaint and never fights the rarity frame. Centred: the offset
       *  is half of what the shrink took off each axis, and it is applied to `body` so
       *  the slot's own x and y stay the grid's. */
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
         this.body.scaleX = this.body.scaleY = on ? PRESS : 1;
         this.body.x = this.body.y = on ? this.size * (1 - PRESS) / 2 : 0;
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

      /** A gem's quality, as that many stars closed up against each other and centred
       *  along the bottom edge.
       *
       *  Sized to fit rather than fixed. Five stars at a fixed radius are wider than the
       *  square they sit on at any cell size this screen offers, and the row that
       *  overflows is the five-star one - which is the row a player most wants to see.
       *
       *  Spread edge to edge the gap grew with the square and shrank with the count, so
       *  one star sat alone in the middle and five piled up on each other. The pitch is
       *  the star's own size now, and the radius is what falls out of it - one expression
       *  rather than a spread followed by a correction. */
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
         radius = Math.min(this.size * 0.13,span / (PIP_PITCH * count - (PIP_PITCH - 2)));
         step = radius * PIP_PITCH;
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
         var inset:int = this.rank >= RADIANT ? 3 : 1;
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
            /* A hairline, the way every other edge on these screens is. Two pixels of
               rarity around a forty pixel square is a frame the item is inside; one is a
               rule the item carries. The second band keeps its pixel of daylight from the
               first, so a Stellar still reads as two rings and not as one thick one. */
            renderer.fill(this.frame,1,1,span - 2,span - 2,renderer.RAISED2);
            if(this.rank >= STELLAR)
            {
               renderer.triband(this.frame,2,2,span - 4,span - 4,0x8913B9,0xB622D9,0x1C97C3);
               renderer.fill(this.frame,3,3,span - 6,span - 6,renderer.RAISED2);
            }
            else if(this.rank == RADIANT)
            {
               renderer.fill(this.frame,2,2,span - 4,span - 4,0x95E6CB);
               renderer.fill(this.frame,3,3,span - 6,span - 6,renderer.RAISED2);
            }
         }
         if(this.mark != 0)
         {
            renderer.fill(this.frame,inset,inset,span - inset * 2,span - inset * 2,
                          this.mark,MARK_WASH);
         }
         if(this.lit && !this.worn)
         {
            renderer.border(this.frame,0,0,span,span,renderer.VALUE,0.5);
         }
         if(this.fresh)
         {
            renderer.disc(this.frame,MARK_DOT + 1,MARK_DOT + 1,MARK_DOT,renderer.CYAN);
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

      private function light(on:Boolean) : void
      {
         if(this.lit == on || !this.hasRollOver)
         {
            return;
         }
         this.lit = on;
         this.paint();
      }

      /** A square the engine has just put something new into. Cleared by looking at it. */
      public function get newItem() : Boolean
      {
         return this.fresh;
      }

      public function set newItem(on:Boolean) : void
      {
         if(this.fresh != on)
         {
            this.fresh = on;
            this.paint();
         }
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
         var beside:Point = this.tipAnchor != null ? this.tipAnchor(this) as Point : null;
         this.light(true);
         /* Looking at it is what makes it no longer new, which is what the stock slot
            does with its glow. */
         this.newItem = false;
         var corner:Point = beside != null ? beside : localToGlobal(new Point(width,height));
         var top:Point = null;
         ExternalInterface.call("SLOT.POINTER_ENTER",this.slotId,corner.x,corner.y);
         if(this.tooltipName.length > 0 || this.tooltipDescription.length > 0)
         {
            top = beside != null ? beside : localToGlobal(new Point(this.width / 2,0));
            ExternalInterface.call("TOOLTIP.SHOW",top.x,top.y,this.tooltipName,this.tooltipDescription);
         }
      }

      private function onLeave(e:Event) : void
      {
         this.light(false);
         ExternalInterface.call("TOOLTIP.HIDE");
         ExternalInterface.call("SLOT.POINTER_LEAVE",this.slotId);
         this.selected = false;
      }
   }
}
