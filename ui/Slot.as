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

   public class Slot extends Sprite
   {

      public static const CHAOS:int = 6;

      public static const RADIANT:int = 26;

      public static const STELLAR:int = 27;

      private static const PLAIN:Array = [0,0x34CF6A,0x00C5F0,0xC831FB,0xFA8D3E,0xE65050];

      private static const SHADE:uint = 0xD2A6FF;

      private static const RADIANT_EDGE:uint = 0x5CCFE6;

      private static const STELLAR_EDGE:uint = 0xFEC13D;

      private static const STYLEABLE:Object = {1:true, 2:true, 3:true, 4:true};

      private static const ALWAYS_FILLED:Object = {0:true};

      public var image:ObjectPreview;

      public var tipAnchor:Function = null;

      public var size:int = 0;

      private var edging:Shape = new Shape();

      private var frame:Shape = new Shape();

      private var pips:Shape = new Shape();

      private var strike:Shape = new Shape();

      private var tally:TextField;

      private var icon:String = "";

      private static const UNSET:int = -1;

      private static const PRESS:Number = 0.85;

      private static const PIP_PITCH:Number = 1.75;

      private var rank:int = UNSET;

      private var slotId:Object = null;

      private var picked:Boolean = false;

      private var counted:Boolean = false;

      private var held:int = 0;

      private var dimmed:Boolean = false;

      public var tooltipName:String = "";

      public var tooltipDescription:String = "";

      public var hasRollOver:Boolean = false;

      public var activates:Boolean = true;

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

      private var body:Sprite = new Sprite();

      public static const MARK_WASH:Number = 0.3;

      private static const MARK_DOT:Number = 3;

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
         this.tally = renderer.label(0,TALLY_PAD,size >= 56 ? 15 : (size >= 40 ? 12 : 10),
                                     TextFieldAutoSize.RIGHT," ",size,30,false,true);
         renderer.stamp(this.tally,[renderer.SHADE]);
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
         if(IggyFunctions.inIggy)
         {
            ExternalInterface.call("POST_SOUND_EVENT","Play_ui_window_click_item");
            ExternalInterface.call("SLOT.ACTIVATE",this.slotId);
         }
      }

      public function hideTooltip() : void
      {
         if(IggyFunctions.inIggy)
         {
            ExternalInterface.call("TOOLTIP.HIDE");
         }
      }

      public function get iconImage() : String
      {
         return this.icon;
      }

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

      private static const TALLY_PAD:int = -2;

      private function retally() : void
      {
         renderer.say(this.tally,this.held <= 1 ? " " : (this.withX ? "x" : "") + String(this.held));
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
         if(this.pipCount != count)
         {
            this.setQuality(count);
         }
      }

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

      public function shown() : Boolean
      {
         return this.rank != UNSET && this.image.loaded;
      }

      private function onPreviewLoaded(preview:ObjectPreview) : void
      {
         this.paint();
      }

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
         if(this.activates)
         {
            this.activate();
         }
      }

      private function onEnter(e:MouseEvent) : void
      {
         var beside:Point = this.tipAnchor != null ? this.tipAnchor(this) as Point : null;
         this.light(true);
         this.newItem = false;
         var corner:Point = beside != null ? beside : localToGlobal(new Point(width,height));
         var top:Point = null;
         if(!IggyFunctions.inIggy)
         {
            return;
         }
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
         this.selected = false;
         if(IggyFunctions.inIggy)
         {
            ExternalInterface.call("TOOLTIP.HIDE");
            ExternalInterface.call("SLOT.POINTER_LEAVE",this.slotId);
         }
      }
   }
}
