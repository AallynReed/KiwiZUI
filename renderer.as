package
{
   import flash.display.Bitmap;
   import ui.Icon;
   import flash.display.GradientType;
   import flash.filters.ColorMatrixFilter;
   import flash.filters.DropShadowFilter;
   import flash.geom.Matrix;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;

   /** Every colour the screens draw with, and the primitives they draw. Nothing here
    *  keeps state beyond the palette, so a screen can repaint from scratch at any
    *  point without asking what was drawn before. */
   public class renderer
   {

      /** The greys carry the default translucency in their top byte rather than a
       *  separate opacity setting multiplied over every draw. A fixed multiplier meant
       *  the panel colour's own alpha picker could never reach solid: whatever it was
       *  set to, the window came out at 94% of it. One control, and the picker is it. */
      public static var PANEL:uint = 0x0F0B0C0E;

      public static var PANEL2:uint = 0x0F0B0C0E;

      public static var ROW:uint = 0x0F3A3F46;

      public static var HEADER:uint = 0x0F15171A;

      public static var RAISED:uint = 0x0F0E1013;

      public static var RAISED2:uint = 0x0F101216;

      public static var RAISED3:uint = 0x0F101216;

      public static var RAISED4:uint = 0x0F101216;

      public static var RAISED5:uint = 0x0F15171A;

      public static var RAISED6:uint = 0x0F0B0C0E;

      public static var BORDER:uint = 0x0F3A3F46;

      public static var VALUE:uint = 0xE8ECF1;

      public static var LABEL:uint = 0x8A929C;

      public static var RED:uint = 0xE5484D;

      public static var ORANGE:uint = 0xF2870D;

      public static var YELLOW:uint = 0xEBC13B;

      public static var GREEN:uint = 0x4CC38A;

      public static var CYAN:uint = 0x5FD3E8;

      public static var PURPLE:uint = 0xB05CE0;

      public static var WATER:uint = 0x73B8FF;

      public static var AIR:uint = 0xFFCC66;

      public static var FIRE:uint = 0xE65050;

      public static var COSMIC:uint = 0x7FD962;

      /** The Light stat's own colour, and not the accent it used to borrow. They start
       *  at the same cyan, which is why the borrowing went unnoticed: an accent set to
       *  anything else took the stat with it, and a stat that changes colour with the
       *  theme is no longer saying which stat it is. */
      public static var LIGHT:uint = 0x5FD3E8;

      public static const BLACK:uint = 0;

      public static const SHADOW:DropShadowFilter = new DropShadowFilter(0,45,0,0,0,0,0,1);

      public static const SHADOW2:DropShadowFilter = new DropShadowFilter(0,210,0,0,0,0,0,1);

      public static const GHOST:ColorMatrixFilter = new ColorMatrixFilter([0.4,0.4,0.4,0,0,0.4,0.4,0.4,0,0,0.4,0.4,0.4,0,0,0,0,0,1,0]);

      private static const FMT:TextFormat = new TextFormat("Open Sans",null,VALUE,false,false,false,null,null);

      /** The two pixels Flash reserves above and below the lines of every field. */
      private static const GUTTER:int = 2;

      private static const LINES:Object = {};

      private static const LIFT:Number = 0.1;

      private static const SINK:Number = 60;

      private static const FILL:Number = 75;

      private static const CHAOS:Array = [0xFF0000,0xFF8C00,0xFFFF00,0x008000,0x00FFFF,0x0000FF,0x8B00FF];

      private static const CHAOS_ALPHA:Array = [1,1,1,1,1,1,1];

      private static const CHAOS_STOP:Array = [0,42,84,126,168,210,255];

      /** The hue wheel the way hsv() reads it: red at nothing, round through the
       *  spectrum, red again at one. Drawn the other way up, the strip and the colour a
       *  click on it produced were mirror images of each other. */
      private static const HUES:Array = [0xFF0000,0xFFFF00,0x00FF00,0x00FFFF,0x0000FF,0xFF00FF,0xFF0000];

      private static const HUE_ALPHA:Array = [1,1,1,1,1,1,1];

      private static const HUE_STOP:Array = [0,43,85,128,170,213,255];

      private static const QUARTER:Number = Math.PI * 0.5;

      /** Config key to palette field, one key per colour and never two.
       *
       *  There used to be aliases here - accent and cyan naming one colour, yellow and
       *  gold another - and each alias was seeded into the file as its own key. Trove
       *  relays a section one key per call, so on every load the second of a pair
       *  arrived after the first and overwrote it: a chosen accent was saved correctly,
       *  then undone by the untouched `cyan` line sitting further down the same file.
       *  It looked for all the world like the write had failed.
       *
       *  A colour with two names is a colour that can disagree with itself. One name. */
      private static const FIELD:Object = {
         "panel":"PANEL", "label":"LABEL", "value":"VALUE",
         "accent":"CYAN", "red":"RED", "orange":"ORANGE",
         "yellow":"YELLOW", "green":"GREEN", "purple":"PURPLE",
         "water":"WATER", "air":"AIR", "fire":"FIRE", "cosmic":"COSMIC",
         "statlight":"LIGHT"
      };

      /** The greys are one colour at five lightnesses, not eleven keys that can
       *  disagree with each other. The steps are the ones the stock palette already
       *  stood at - measured off it rather than invented - so a default config draws
       *  exactly what it always drew, and a panel colour set after that carries the
       *  whole screen with it instead of leaving a header behind at the old shade.
       *
       *  Only the greys are in here. The accent, the two text colours and the rarity
       *  colours each mean something of their own and stay settable. */
      private static const STEPS:Object = {
         "PANEL2":0, "RAISED6":0, "RAISED":0.018,
         "RAISED2":0.028, "RAISED3":0.028, "RAISED4":0.028,
         "RAISED5":0.049, "HEADER":0.049,
         "ROW":0.229, "BORDER":0.229
      };

      /** What a config file carries. The greys that STEPS derives are deliberately not
       *  in here: a key nothing reads is a key a player can set and watch do nothing. */
      public static const KEYS:Array = ["panel","label","value","accent","red","orange",
                                        "yellow","green","purple","water","air","fire","cosmic",
                                        "statlight"];

      public function renderer()
      {
         super();
      }

      /** Assignment is spelled out rather than looked up: a colour is a plain static so
       *  every draw reads it straight, and Iggy is not asked to write a class property
       *  by name. FIELD folds the aliases in, so this switch has one case per colour
       *  and not one per key. */
      /** A palette colour carries its own transparency in the top byte, and the byte
       *  counts *down* from opaque: zero is solid. That way every plain RGB literal
       *  already written into these screens - 0xFFFFFF for a crosshair, 0 for black -
       *  is opaque by construction, and no drawing call anywhere had to be rewritten
       *  to honour a translucent palette. The primitives mask the byte off before it
       *  reaches the graphics call and fold it into the alpha instead. */
      /** How opaque a palette colour is. The top byte carries the transparency a player
       *  set, so anything drawing raw geometry in a palette colour has to apply it the
       *  way fill() and border() already do - public for those callers. */
      public static function solidity(color:uint) : Number
      {
         return 1 - (color >>> 24) / 255;
      }

      public static function apply(key:String, raw:String) : Boolean
      {
         var name:String = key.toLowerCase();
         var field:String = FIELD[name];
         if(field == null)
         {
            return false;
         }
         var c:uint = uint(Math.round((1 - Config.alpha(raw,1)) * 255)) << 24
                    | Config.color(raw,VALUE);
         switch(field)
         {
            case "PANEL":   PANEL = c; derive(); break;
            case "LABEL":   LABEL = c;   break;
            case "VALUE":   VALUE = c; derive(); break;
            case "CYAN":    CYAN = c;    break;
            case "RED":     RED = c;     break;
            case "ORANGE":  ORANGE = c;  break;
            case "YELLOW":  YELLOW = c;  break;
            case "GREEN":   GREEN = c;   break;
            case "PURPLE":  PURPLE = c;  break;
            case "WATER":   WATER = c;   break;
            case "AIR":     AIR = c;     break;
            case "FIRE":    FIRE = c;    break;
            case "COSMIC":  COSMIC = c;  break;
            case "LIGHT":   LIGHT = c;   break;
            default: return false;
         }
         return true;
      }

      /** The ramp, off whatever PANEL now is. The transparency travels with it, because
       *  a translucent panel that left an opaque header and border behind is not a
       *  translucent window - it is a window with two holes in it. */
      private static function derive() : void
      {
         var name:String = null;
         for(name in STEPS)
         {
            put(name,lift(PANEL,Number(STEPS[name])));
         }
      }

      private static function put(field:String, c:uint) : void
      {
         switch(field)
         {
            case "PANEL2":  PANEL2 = c;  break;
            case "ROW":     ROW = c;     break;
            case "HEADER":  HEADER = c;  break;
            case "RAISED":  RAISED = c;  break;
            case "RAISED2": RAISED2 = c; break;
            case "RAISED3": RAISED3 = c; break;
            case "RAISED4": RAISED4 = c; break;
            case "RAISED5": RAISED5 = c; break;
            case "RAISED6": RAISED6 = c; break;
            case "BORDER":  BORDER = c;  break;
         }
      }

      /** Not valueOf: that is Object's own coercion hook, and a static of that name
       *  on a class is called by the player with no argument whenever the class object
       *  is coerced - a warning per coercion and a hook that cannot do its job. */
      public static function colorOf(key:String) : uint
      {
         switch(FIELD[key.toLowerCase()])
         {
            case "PANEL":   return PANEL;
            case "PANEL2":  return PANEL2;
            case "ROW":     return ROW;
            case "HEADER":  return HEADER;
            case "RAISED":  return RAISED;
            case "RAISED2": return RAISED2;
            case "RAISED3": return RAISED3;
            case "RAISED4": return RAISED4;
            case "RAISED5": return RAISED5;
            case "RAISED6": return RAISED6;
            case "BORDER":  return BORDER;
            case "LABEL":   return LABEL;
            case "CYAN":    return CYAN;
            case "RED":     return RED;
            case "ORANGE":  return ORANGE;
            case "YELLOW":  return YELLOW;
            case "GREEN":   return GREEN;
            case "PURPLE":  return PURPLE;
            case "WATER":   return WATER;
            case "AIR":     return AIR;
            case "FIRE":    return FIRE;
            case "COSMIC":  return COSMIC;
            case "LIGHT":   return LIGHT;
         }
         return VALUE;
      }

      public static function alphaOf(key:String) : Number
      {
         return solidity(colorOf(key));
      }

      public static function defaultOf(key:String) : String
      {
         return Config.hexa(colorOf(key),alphaOf(key));
      }

      /** Binds a game texture onto a bitmap and says whether one actually arrived, for
       *  a caller holding a plain Bitmap rather than a ui.Icon. The sequence itself is
       *  Icon's, so there is one of it. */
      public static function bindIcon(image:Bitmap, texture:String, size:int) : Boolean
      {
         return Icon.paint(image,texture,size);
      }

      /** A format a caller can put on a field it did not build here - a control's own
       *  caption, most of the time. A copy rather than the shared one, because the shared
       *  one is rewritten by the next label built after it. */
      public static function spacedOut(size:int, spacing:Number) : TextFormat
      {
         var out:TextFormat = new TextFormat("Open Sans",size,VALUE);
         out.align = TextFormatAlign.CENTER;
         out.letterSpacing = spacing;
         return out;
      }

      public static function label(x:int = 0, y:int = 0, size:int = 8, align:String = "",
                                   body:String = "", w:int = -1, h:int = -1,
                                   wrap:Boolean = false, bold:Boolean = false,
                                   spacing:Number = 0) : TextField
      {
         var field:TextField = new TextField();
         field.mouseEnabled = false;
         field.filters = [SHADOW];
         field.defaultTextFormat = shaped(size,align,bold,spacing);
         field.x = x;
         field.y = y;
         field.htmlText = body;
         return boxed(field,w,h,wrap,align);
      }

      /** Spacing is set on every call and not only when it is asked for: the format is
       *  one shared object, so a caption that wanted letter spacing would otherwise leave
       *  it on the next label built after it. */
      private static function shaped(size:int, align:String, bold:Boolean,
                                     spacing:Number = 0) : TextFormat
      {
         FMT.size = size;
         FMT.align = align;
         FMT.bold = bold;
         FMT.letterSpacing = spacing;
         return FMT;
      }

      /** A field sized for its line box, not for its font size: height from the size
       *  alone clips the text away entirely above 14pt, and a field that renders
       *  nothing looks for all the world like a font ceiling. autoSize goes on last so
       *  it settles against the width the caller asked for. */
      private static function boxed(field:TextField, w:int, h:int, wrap:Boolean, align:String) : TextField
      {
         if(w != -1)
         {
            field.width = w;
         }
         if(h != -1)
         {
            field.height = h;
         }
         field.wordWrap = wrap;
         field.autoSize = align;
         return field;
      }

      /** A field that stays exactly where it is put. label() sizes to its content,
       *  which is what a caption wants and the opposite of what a readout in a fixed
       *  column wants: an autoSized CENTER field slides sideways as its text changes,
       *  so a value that grows a digit no longer lines up with the one above it.
       *  Height is the line box rather than the font size - below that the field
       *  renders nothing at all. */
      public static function pin(field:TextField, w:int, size:int) : TextField
      {
         /* autoSize CENTER moves a field sideways to keep its centre where it was, so a
            field arriving here has already drifted and freezing it at that x puts the
            text off the control. Callers that place the field themselves overwrite this
            anyway; the ones that do not need it back at nothing. */
         field.x = 0;
         field.autoSize = TextFieldAutoSize.NONE;
         field.width = w;
         field.height = size * 2;
         return field;
      }

      /** How tall one line stands at this size, measured once per size and kept. The
       *  numbers are Flash's own and not the font file's - it rounds both the ascent
       *  and the descent to whole pixels, so 12pt and 13pt come out the same height -
       *  and a field with nothing in it reports no height at all, which is the state
       *  every control paints in before it has anything to say. */
      private static function lineOf(size:Number) : Number
      {
         var key:String = String(size);
         var probe:TextField = null;
         if(LINES[key] == null)
         {
            probe = new TextField();
            probe.defaultTextFormat = new TextFormat("Open Sans",size);
            probe.text = "Hg";
            LINES[key] = probe.textHeight + GUTTER * 2;
         }
         return Number(LINES[key]);
      }

      /** How tall a box has to be for that many lines at that size, gutters included.
       *  A pinned field keeps whatever height it was made with, so a wrapping one has to
       *  be given the room its lines need or it shows the first of them and stops. */
      public static function deep(size:Number, lines:int = 1) : int
      {
         return int(lineOf(size) * lines + GUTTER * 2);
      }

      /** Puts text in the middle of a box. The field's own height is the wrong thing
       *  to centre on: pin() gives a field more of it than the lines need so nothing
       *  is ever clipped, and a control that halves that room puts its words a couple
       *  of pixels above the box drawn around them - which is why a readout used to
       *  sit higher than the caption beside it. What is centred is what is written,
       *  which for a field that wraps is however many lines it came to and for one
       *  with nothing in it yet is the one line it is going to have.
       *
       *  Every control places its text through here, so one rule decides where text
       *  sits and a box cannot drift away from the words in it. */
      public static function centre(field:TextField, top:Number, h:Number) : void
      {
         var line:Number = lineOf(Number(field.defaultTextFormat.size));
         field.y = top + (h - Math.max(line,field.textHeight + GUTTER * 2)) / 2;
      }

      /** The same rule across a box. A field draws its text a gutter in from its own
       *  left edge, so a caption placed at the padding sits a gutter to the right of
       *  where it looks like it was put - which on a control only as wide as its word is
       *  the difference between centred and visibly not. */
      public static function across(field:TextField, left:Number, w:Number) : void
      {
         field.x = left + (w - (field.textWidth + GUTTER * 2)) / 2;
      }

      /** Makes a line fit the width it has by getting smaller, and answers the size it
       *  settled on.
       *
       *  The other way to make text fit is `elide`, and for a name it is the wrong one:
       *  a club called something is not a club called something else with a dot after
       *  it, and a player looking for their own club wants to read it. A point or two
       *  down is a name that is still the name.
       *
       *  Stops at `floor` and leaves whatever is left over the edge, because a field
       *  that keeps shrinking to fit an absurd string ends up unreadable rather than
       *  merely tight. */
      public static function fit(field:TextField, wide:Number, size:int, floor:int) : int
      {
         var at:int = size;
         var fmt:TextFormat = field.defaultTextFormat;
         while(at > floor)
         {
            fmt.size = at;
            field.defaultTextFormat = fmt;
            field.setTextFormat(fmt);
            if(field.textWidth <= wide)
            {
               return at;
            }
            at--;
         }
         fmt.size = at;
         field.defaultTextFormat = fmt;
         field.setTextFormat(fmt);
         return at;
      }

      /** Cuts a line down to the width it has and ends it in an ellipsis. A set of
       *  choices is written out in full where it fits, because the words are what a
       *  player picked and a count is not, and it has to stop somewhere when it does
       *  not. */
      public static function elide(field:TextField, wide:Number) : void
      {
         var body:String = field.text;
         while(body.length > 1 && field.textWidth > wide)
         {
            body = body.substr(0,body.length - 1);
            field.text = body + "…";
         }
      }

      /** Three bars: the settings glyph on every screen that has one. Drawn from a
       *  corner rather than a centre because it goes into a button's face at a fixed
       *  inset. */
      public static function gear(target:*, x:int = 7, y:int = 8, color:uint = 0) : *
      {
         var i:int = 0;
         while(i < 3)
         {
            fill(target,x,y + i * 5,12,2,color,1);
            i++;
         }
         return target;
      }

      /** A colour taken a little way toward the text colour, keeping whatever
       *  transparency it had - blend() and shade() both drop it. */
      public static function lift(color:uint, t:Number) : uint
      {
         return blend(color,VALUE,t) | color & 0xFF000000;
      }

      public static function sink(color:uint, percent:Number) : uint
      {
         return shade(color,percent) | color & 0xFF000000;
      }

      /** The accent, filled. Every solid run of it - a slider's travel, a ticked box -
       *  is drawn through here, so one gradient covers the lot and a run of colour
       *  reads the same whatever control it is in. */
      public static function accent(target:*, x:int, y:int, w:int, h:int) : *
      {
         return vertical(target,x,y,w,h,CYAN,sink(CYAN,FILL));
      }

      /** A vertical gradient with its ends pushed apart. The raised greys sit within a
       *  few values of each other, so a plate drawn straight from the pair reads flat;
       *  lifting one end and sinking the other keeps the colours the player set and
       *  makes the shape of the button visible.
       *
       *  Light on top, dark underneath - a face catching the light from above is what
       *  says raised at all. Drawn the other way up it reads as a dent. Pressing flips
       *  the whole thing, which is the same rule read upside down. */
      public static function raised(target:*, x:int, y:int, w:int, h:int,
                                    light:uint, dark:uint) : *
      {
         return vertical(target,x,y,w,h,lift(light,LIFT),sink(dark,SINK));
      }

      /** htmlText discards the field's own alignment, so colour goes in the markup
       *  and the alignment stays with it. */
      public static function tint(body:String = "", color:uint = 0xFFFFFF) : String
      {
         return "<font color=\"#" + Config.hex(color) + "\">" + body + "</font>";
      }

      /** 0-30 red, 30-50 orange, 50-70 yellow, 70-99 green, 100 cyan. */
      public static function gradeFor(fraction:Number) : uint
      {
         var pct:Number = fraction * 100;
         if(pct < 30) { return RED; }
         if(pct < 50) { return ORANGE; }
         if(pct < 70) { return YELLOW; }
         if(pct < 100) { return GREEN; }
         return CYAN;
      }

      /** The same bands as a continuous ramp, for bars that fill rather than grade. */
      public static function rampFor(fraction:Number) : uint
      {
         if(fraction < 0.33) { return blend(RED,ORANGE,fraction / 0.33); }
         if(fraction < 0.66) { return blend(ORANGE,YELLOW,(fraction - 0.33) / 0.33); }
         return blend(YELLOW,GREEN,(fraction - 0.66) / 0.34);
      }

      /** Hue in turns, saturation and value 0-1. The colour picker walks a grid of
       *  these rather than of stored swatches, so every hue at every shade is on the
       *  panel without a table of them being written down. */
      public static function hsv(hue:Number, sat:Number, val:Number) : uint
      {
         var h:Number = (hue - Math.floor(hue)) * 6;
         var sector:int = int(h);
         var f:Number = h - sector;
         var p:Number = val * (1 - sat);
         var q:Number = val * (1 - sat * f);
         var t2:Number = val * (1 - sat * (1 - f));
         switch(sector)
         {
            case 0: return pack(val,t2,p);
            case 1: return pack(q,val,p);
            case 2: return pack(p,val,t2);
            case 3: return pack(p,q,val);
            case 4: return pack(t2,p,val);
         }
         return pack(val,p,q);
      }

      /** The way back: hue in turns, saturation and value 0-1, as a three-element
       *  array. A grey has no hue to report, so it reports zero and the caller keeps
       *  whichever hue it was already showing - otherwise dragging a colour down to
       *  black would lose the hue and come back up red. */
      public static function hsvOf(color:uint) : Array
      {
         var r:Number = (color >> 16 & 0xFF) / 255;
         var g:Number = (color >> 8 & 0xFF) / 255;
         var b:Number = (color & 0xFF) / 255;
         var top:Number = Math.max(r,Math.max(g,b));
         var span:Number = top - Math.min(r,Math.min(g,b));
         var h:Number = 0;
         if(span > 0)
         {
            if(top == r)      { h = ((g - b) / span + 6) % 6; }
            else if(top == g) { h = (b - r) / span + 2; }
            else              { h = (r - g) / span + 4; }
            h /= 6;
         }
         return [h,top == 0 ? 0 : span / top,top];
      }

      private static function pack(r:Number, g:Number, b:Number) : uint
      {
         return uint(r * 255 + 0.5) << 16 | uint(g * 255 + 0.5) << 8 | uint(b * 255 + 0.5);
      }

      public static function blend(from:uint, to:uint, t:Number) : uint
      {
         from &= 0xFFFFFF;
         to &= 0xFFFFFF;
         var r:Number = (from >> 16 & 0xFF) + ((to >> 16 & 0xFF) - (from >> 16 & 0xFF)) * t;
         var g:Number = (from >> 8 & 0xFF) + ((to >> 8 & 0xFF) - (from >> 8 & 0xFF)) * t;
         var b:Number = (from & 0xFF) + ((to & 0xFF) - (from & 0xFF)) * t;
         return uint(r) << 16 | uint(g) << 8 | uint(b);
      }

      public static function shade(color:uint, percent:Number) : uint
      {
         var k:Number = percent * 0.01;
         color &= 0xFFFFFF;
         return uint((color >> 16 & 0xFF) * k) << 16
              | uint((color >> 8 & 0xFF) * k) << 8
              | uint((color & 0xFF) * k);
      }

      /** The grey lattice a translucent colour is shown against, so "half transparent"
       *  reads as that rather than as a slightly different grey. */
      public static function checker(target:*, x:int = 0, y:int = 0, w:int = 0, h:int = 0,
                                     size:int = 6) : *
      {
         var down:int = 0;
         var across:int = 0;
         fill(target,x,y,w,h,0x2A2E33,1);
         while(down * size < h)
         {
            across = down % 2;
            while(across * size < w)
            {
               fill(target,x + across * size,y + down * size,
                    Math.min(size,w - across * size),Math.min(size,h - down * size),0x15171A,1);
               across += 2;
            }
            down++;
         }
         return target;
      }

      public static function fill(target:*, x:int = 0, y:int = 0, w:int = 0, h:int = 0,
                                  color:uint = 0, alpha:Number = 1) : *
      {
         target.graphics.beginFill(color & 0xFFFFFF,alpha * solidity(color));
         target.graphics.drawRect(x,y,w,h);
         target.graphics.endFill();
         return target;
      }

      /** A one-pixel border with its own fill inside. Every border in here is a
       *  filled rect rather than a stroke, so nothing straddles a half pixel. */
      public static function framed(target:*, x:int = 0, y:int = 0, w:int = 0, h:int = 0,
                                    inner:uint = 0, edge:uint = 0, alpha:Number = 1) : *
      {
         fill(target,x,y,w,h,edge,alpha);
         fill(target,x + 1,y + 1,w - 2,h - 2,inner,alpha);
         return target;
      }

      public static function border(target:*, x:int = 0, y:int = 0, w:int = 0, h:int = 0,
                                    color:uint = 0, alpha:Number = 1, weight:int = 1) : *
      {
         target.graphics.beginFill(color & 0xFFFFFF,alpha * solidity(color));
         target.graphics.drawRect(x,y,w - weight,weight);
         target.graphics.drawRect(x + w - weight,y,weight,h);
         target.graphics.drawRect(x,y + h - weight,w - weight,weight);
         target.graphics.drawRect(x,y + weight,weight,h - weight);
         target.graphics.endFill();
         return target;
      }

      public static function dashed(target:*, x:int, y:int, w:int, h:int,
                                    color:uint, alpha:Number = 1) : *
      {
         var run:int = 4;
         var at:int = 0;
         target.graphics.beginFill(color & 0xFFFFFF,alpha * solidity(color));
         while(at < w)
         {
            target.graphics.drawRect(x + at,y,Math.min(run,w - at),1);
            target.graphics.drawRect(x + at,y + h - 1,Math.min(run,w - at),1);
            at += run * 2;
         }
         at = 0;
         while(at < h)
         {
            target.graphics.drawRect(x,y + at,1,Math.min(run,h - at));
            target.graphics.drawRect(x + w - 1,y + at,1,Math.min(run,h - at));
            at += run * 2;
         }
         target.graphics.endFill();
         return target;
      }

      public static function disc(target:*, x:int = 0, y:int = 0, radius:Number = 0,
                                  color:uint = 0, alpha:Number = 1) : *
      {
         target.graphics.beginFill(color & 0xFFFFFF,alpha * solidity(color));
         target.graphics.drawCircle(x,y,radius);
         target.graphics.endFill();
         return target;
      }

      public static function vertical(target:*, x:int, y:int, w:int, h:int,
                                      top:uint, bottom:uint) : *
      {
         return ramp(target,x,y,w,h,[top & 0xFFFFFF,bottom & 0xFFFFFF],
                     [solidity(top),solidity(bottom)],[0,255]);
      }

      public static function triband(target:*, x:int, y:int, w:int, h:int,
                                     top:uint, middle:uint, bottom:uint) : *
      {
         return ramp(target,x,y,w,h,[top & 0xFFFFFF,middle & 0xFFFFFF,bottom & 0xFFFFFF],
                     [solidity(top),solidity(middle),solidity(bottom)],[0,128,255]);
      }

      /** The seven-colour sweep chaos rarity is drawn with. */
      public static function chaos(target:*, x:int, y:int, w:int, h:int) : *
      {
         var box:Matrix = new Matrix();
         box.createGradientBox(w,h,Math.PI / 4,x,y);
         target.graphics.beginGradientFill(GradientType.LINEAR,CHAOS,CHAOS_ALPHA,CHAOS_STOP,box);
         target.graphics.drawRect(x,y,w,h);
         target.graphics.endFill();
         return target;
      }

      /** The full hue circle, bottom to top, for the strip beside a colour square.
       *  Ends where it starts so the wrap is not a seam. */
      public static function hueStrip(target:*, x:int, y:int, w:int, h:int) : *
      {
         return ramp(target,x,y,w,h,HUES,HUE_ALPHA,HUE_STOP);
      }

      private static function ramp(target:*, x:int, y:int, w:int, h:int,
                                   colors:Array, alphas:Array, stops:Array) : *
      {
         var box:Matrix = new Matrix();
         box.createGradientBox(w,h,QUARTER,x,y);
         target.graphics.beginGradientFill(GradientType.LINEAR,colors,alphas,stops,box);
         target.graphics.drawRect(x,y,w,h);
         target.graphics.endFill();
         return target;
      }

      /** The barred circle drawn on a slot that is empty because the player took the
       *  item off deliberately - hat, face and weapon can be left unstyled. */
      public static function noEntry(target:*, x:int = 0, y:int = 0, radius:Number = 0,
                                     color:uint = 0, hole:uint = 0, alpha:Number = 1) : *
      {
         var arm:Number = radius * 0.7071;
         var weight:Number = radius * 0.11 + 0.6;
         disc(target,x,y,radius,color,alpha);
         disc(target,x,y,radius - weight * 1.6,hole,1);
         target.graphics.beginFill(color & 0xFFFFFF,alpha * solidity(color));
         target.graphics.moveTo(x - arm - weight,y - arm + weight);
         target.graphics.lineTo(x - arm + weight,y - arm - weight);
         target.graphics.lineTo(x + arm + weight,y + arm - weight);
         target.graphics.lineTo(x + arm - weight,y + arm + weight);
         target.graphics.endFill();
         return target;
      }

      public static function flame(target:*, x:Number, y:Number, size:Number,
                                   color:uint, alpha:Number = 1) : *
      {
         target.graphics.beginFill(color & 0xFFFFFF,alpha * solidity(color));
         target.graphics.moveTo(x,y - size);
         target.graphics.curveTo(x + size * 0.95,y - size * 0.1,x + size * 0.42,y + size * 0.62);
         target.graphics.curveTo(x,y + size,x - size * 0.42,y + size * 0.62);
         target.graphics.curveTo(x - size * 0.95,y - size * 0.1,x,y - size);
         target.graphics.endFill();
         target.graphics.beginFill(shade(color,55),alpha * solidity(color));
         target.graphics.moveTo(x,y - size * 0.1);
         target.graphics.curveTo(x + size * 0.5,y + size * 0.28,x,y + size * 0.66);
         target.graphics.curveTo(x - size * 0.5,y + size * 0.28,x,y - size * 0.1);
         target.graphics.endFill();
         return target;
      }

      /** One five-pointed pip of a gem's quality, outlined so it reads against the
       *  item icon behind it.
       *
       *  The centre is a Number and not an int: a row of pips is placed at a fractional
       *  pitch, and rounding each one to a whole pixel is what made the gaps in a row of
       *  five come out uneven. */
      public static function pip(target:*, x:Number = 0, y:Number = 0, radius:Number = 0,
                                 color:uint = 0, alpha:Number = 1) : *
      {
         var start:Number = Math.PI / 4 - Math.PI / 20;
         var inner:Number = radius / 2;
         var step:Number = Math.PI * 2 / 5;
         var point:int = 0;
         var outerAngle:Number = 0;
         var innerAngle:Number = 0;
         target.graphics.beginFill(color & 0xFFFFFF,alpha * solidity(color));
         target.graphics.lineStyle(2.5,BLACK,0.95);
         target.graphics.moveTo(Math.cos(start) * radius + x,Math.sin(start) * radius + y);
         while(point <= 5)
         {
            outerAngle = step * point + start;
            innerAngle = outerAngle + Math.PI / 5;
            target.graphics.lineTo(Math.cos(outerAngle) * radius + x,Math.sin(outerAngle) * radius + y);
            target.graphics.lineTo(Math.cos(innerAngle) * inner + x,Math.sin(innerAngle) * inner + y);
            point++;
         }
         target.graphics.endFill();
         return target;
      }

      public static function group(value:int) : String
      {
         return commas(String(value));
      }

      /** Same grouping, on a string that may carry a decimal tail or a percent sign. */
      public static function groupText(body:String) : String
      {
         var text:String = body;
         var suffix:String = "";
         var tail:String = "";
         if(text.indexOf("%") != -1)
         {
            suffix = "%";
            text = text.split("%").join("");
         }
         var dot:int = text.indexOf(".");
         if(dot != -1)
         {
            tail = text.substring(dot);
            text = text.substring(0,dot);
         }
         return commas(text) + tail + suffix;
      }

      /** Thousands separators, counting back from the end so a leading sign is left
       *  alone. Character by character rather than by pattern, for the same reason
       *  titleCase is. */
      private static function commas(digits:String) : String
      {
         var out:String = "";
         var seen:int = 0;
         var i:int = digits.length - 1;
         var ch:String = null;
         while(i >= 0)
         {
            ch = digits.charAt(i);
            if(seen > 0 && seen % 3 == 0 && ch >= "0" && ch <= "9")
            {
               out = "," + out;
            }
            out = ch + out;
            if(ch >= "0" && ch <= "9")
            {
               seen++;
            }
            i--;
         }
         return out;
      }

      public static function numbersIn(body:String = "") : String
      {
         var found:Array = [];
         var word:String = null;
         for each(word in body.split(" "))
         {
            if(!isNaN(Number(word)))
            {
               found.push(word);
            }
         }
         return found.join(" - ");
      }

      /** Capitalised word by word. Written against the string directly - Iggy takes a
       *  RegExp but not a replace with a function behind it, and a rejected call takes
       *  the whole screen down with nothing in any log. */
      public static function titleCase(body:String) : String
      {
         if(body == null || body == "")
         {
            return "";
         }
         var lower:String = body.toLowerCase();
         var out:String = "";
         var afterGap:Boolean = true;
         var i:int = 0;
         var ch:String = null;
         while(i < lower.length)
         {
            ch = lower.charAt(i);
            out += afterGap ? ch.toUpperCase() : ch;
            afterGap = ch == " ";
            i++;
         }
         return out;
      }
   }
}
