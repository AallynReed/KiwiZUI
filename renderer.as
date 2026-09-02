package
{
   import flash.display.Bitmap;
   import ui.Icon;
   import flash.events.MouseEvent;
   import flash.display.GradientType;
   import flash.filters.BitmapFilterQuality;
   import flash.filters.ColorMatrixFilter;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.utils.Dictionary;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.text.TextLineMetrics;

   public class renderer
   {

      public static function wheel(e:MouseEvent, by:Number = 48) : Number
      {
         return e.delta > 0 ? -by : by;
      }

      public static var PANEL:uint = 0x0F0B0C0E;

      public static var PANEL2:uint = 0x0F0B0C0E;

      public static var ROW:uint = 0x0F3A3F46;

      public static var HEADER:uint = 0x0F15171A;

      public static var RAISED:uint = 0x0F0E1013;

      public static var RAISED2:uint = 0x0F101216;

      public static var SLOT:uint = 0x0F101216;

      public static var RAISED3:uint = 0x0F101216;

      public static var RAISED4:uint = 0x0F101216;

      public static var RAISED5:uint = 0x0F15171A;

      public static var RAISED6:uint = 0x0F0B0C0E;

      public static var BORDER:uint = 0x0F3A3F46;

      public static var VALUE:uint = 0xE8ECF1;

      public static var LABEL:uint = 0x8A929C;

      public static var RED:uint = 0xE5484D;

      public static var DANGER:uint = 0xE5484D;

      public static var ORANGE:uint = 0xF2870D;

      public static var YELLOW:uint = 0xEBC13B;

      public static var GREEN:uint = 0x4CC38A;

      public static var CYAN:uint = 0x5FD3E8;

      public static var PURPLE:uint = 0xB05CE0;

      public static var WATER:uint = 0x73B8FF;

      public static var AIR:uint = 0xFFCC66;

      public static var FIRE:uint = 0xE65050;

      public static var COSMIC:uint = 0x7FD962;

      public static var LIGHT:uint = 0x5FD3E8;

      public static const BLACK:uint = 0;

      public static const SHADOW:DropShadowFilter = new DropShadowFilter(0,45,0,0,0,0,0,1);

      public static const SHADOW2:DropShadowFilter = new DropShadowFilter(0,210,0,0,0,0,0,1);

      public static const SHADE:DropShadowFilter = new DropShadowFilter(1,90,0,0.6,0,0,1,
                                                                        BitmapFilterQuality.LOW);

      public static const GHOST:ColorMatrixFilter = new ColorMatrixFilter([0.4,0.4,0.4,0,0,0.4,0.4,0.4,0,0,0.4,0.4,0.4,0,0,0,0,0,1,0]);

      public static const MAXRING:int = 4;

      private static const PUSH:Number = 12;

      public static var MARK:Array = null;

      private static const STAMPED:Dictionary = new Dictionary(true);

      public static var RING:int = 0;

      public static var INK:uint = 0;

      public static var FONT:String = "Open Sans";

      private static const FMT:TextFormat = new TextFormat(FONT,null,VALUE,false,false,false,null,null);

      private static const GUTTER:int = 2;

      private static const CAP:Number = 0.6;

      private static const LINES:Object = {};

      private static const ASCENTS:Object = {};

      private static const WIDTHS:Object = {};

      private static const LIFT:Number = 0.1;

      private static const SINK:Number = 60;

      private static const FILL:Number = 75;

      private static const CHAOS:Array = [0xFF0000,0xFF8C00,0xFFFF00,0x008000,0x00FFFF,0x0000FF,0x8B00FF];

      private static const CHAOS_ALPHA:Array = [1,1,1,1,1,1,1];

      private static const CHAOS_STOP:Array = [0,42,84,126,168,210,255];

      private static const HUES:Array = [0xFF0000,0xFFFF00,0x00FF00,0x00FFFF,0x0000FF,0xFF00FF,0xFF0000];

      private static const HUE_ALPHA:Array = [1,1,1,1,1,1,1];

      private static const HUE_STOP:Array = [0,43,85,128,170,213,255];

      private static const QUARTER:Number = Math.PI * 0.5;

      private static const FIELD:Object = {
         "panel":"PANEL", "label":"LABEL", "value":"VALUE",
         "accent":"CYAN", "red":"RED", "danger":"DANGER", "orange":"ORANGE",
         "yellow":"YELLOW", "green":"GREEN", "purple":"PURPLE",
         "water":"WATER", "air":"AIR", "fire":"FIRE", "cosmic":"COSMIC",
         "statlight":"LIGHT", "slot":"SLOT"
      };

      private static const STEPS:Object = {
         "PANEL2":0, "RAISED6":0, "RAISED":0.018,
         "RAISED2":0.028, "RAISED3":0.028, "RAISED4":0.028, "SLOT":0.028,
         "RAISED5":0.049, "HEADER":0.049,
         "ROW":0.229, "BORDER":0.229
      };

      public static const KEYS:Array = ["panel","label","value","accent","red","danger","orange",
                                        "yellow","green","purple","water","air","fire","cosmic",
                                        "statlight","outline","outlinecolor"];

      private static const STOCK:Object = {};

      private static var slotOwn:Boolean = false;

      public function renderer()
      {
         super();
      }

      public static function solidity(color:uint) : Number
      {
         return 1 - (color >>> 24) / 255;
      }

      public static function apply(key:String, raw:String) : Boolean
      {
         var name:String = key.toLowerCase();
         keep(name);
         if(name == "outline")
         {
            RING = Config.number(raw,0,MAXRING,0);
            remark();
            return true;
         }
         if(name == "outlinecolor")
         {
            INK = Config.color(raw,0);
            remark();
            return true;
         }
         var field:String = FIELD[name];
         if(field == null)
         {
            return false;
         }
         if(field == "SLOT" && Config.blank(raw))
         {
            slotOwn = false;
            derive();
            return true;
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
            case "DANGER":  DANGER = c;  break;
            case "ORANGE":  ORANGE = c;  break;
            case "YELLOW":  YELLOW = c;  break;
            case "GREEN":   GREEN = c;   break;
            case "PURPLE":  PURPLE = c;  break;
            case "WATER":   WATER = c;   break;
            case "AIR":     AIR = c;     break;
            case "FIRE":    FIRE = c;    break;
            case "COSMIC":  COSMIC = c;  break;
            case "LIGHT":   LIGHT = c;   break;
            case "SLOT":    SLOT = c; slotOwn = true; break;
            default: return false;
         }
         return true;
      }

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
            case "SLOT":    if(!slotOwn) { SLOT = c; } break;
            case "RAISED3": RAISED3 = c; break;
            case "RAISED4": RAISED4 = c; break;
            case "RAISED5": RAISED5 = c; break;
            case "RAISED6": RAISED6 = c; break;
            case "BORDER":  BORDER = c;  break;
         }
      }

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
            case "SLOT":    return SLOT;
            case "RAISED3": return RAISED3;
            case "RAISED4": return RAISED4;
            case "RAISED5": return RAISED5;
            case "RAISED6": return RAISED6;
            case "BORDER":  return BORDER;
            case "LABEL":   return LABEL;
            case "CYAN":    return CYAN;
            case "RED":     return RED;
            case "DANGER":  return DANGER;
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
         var name:String = key.toLowerCase();
         if(name == "outline")
         {
            return String(RING);
         }
         if(name == "outlinecolor")
         {
            return Config.hex(INK);
         }
         return Config.hexa(colorOf(key),alphaOf(key));
      }

      private static function owns(name:String) : Boolean
      {
         return FIELD[name] != null || name == "outline" || name == "outlinecolor";
      }

      private static function keep(name:String) : void
      {
         if(STOCK[name] == null && owns(name))
         {
            STOCK[name] = defaultOf(name);
         }
      }

      public static function stockOf(key:String) : String
      {
         var name:String = key.toLowerCase();
         if(STOCK[name] != null)
         {
            return String(STOCK[name]);
         }
         return owns(name) ? defaultOf(name) : "";
      }

      public static function stamp(field:TextField, own:Array = null) : TextField
      {
         var base:Array = own == null ? [SHADOW] : own;
         STAMPED[field] = base;
         field.filters = MARK == null ? base : MARK;
         return field;
      }

      public static function say(field:TextField, body:String) : TextField
      {
         var want:String = body == null ? "" : body;
         if(field != null && field.text != want)
         {
            field.text = want;
         }
         return field;
      }

      private static function remark() : void
      {
         var field:Object = null;
         MARK = RING <= 0
              ? null
              : [new GlowFilter(INK,1,RING * 2,RING * 2,PUSH,BitmapFilterQuality.MEDIUM)];
         for(field in STAMPED)
         {
            TextField(field).filters = MARK == null ? STAMPED[field] : MARK;
         }
      }

      public static function bindIcon(image:Bitmap, texture:String, size:int) : Boolean
      {
         return Icon.paint(image,texture,size);
      }

      public static function spacedOut(size:int, spacing:Number) : TextFormat
      {
         var out:TextFormat = new TextFormat(FONT,size,VALUE);
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
         stamp(field);
         field.defaultTextFormat = shaped(size,align,bold,spacing);
         field.x = x;
         field.y = y;
         field.htmlText = body;
         return boxed(field,w,h,wrap,align);
      }

      private static function shaped(size:int, align:String, bold:Boolean,
                                     spacing:Number = 0) : TextFormat
      {
         FMT.size = size;
         FMT.align = align;
         FMT.bold = bold;
         FMT.letterSpacing = spacing;
         return FMT;
      }

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

      public static function pin(field:TextField, w:int, size:int) : TextField
      {
         field.x = 0;
         field.autoSize = TextFieldAutoSize.NONE;
         field.width = w;
         field.height = size * 2;
         return field;
      }

      private static function lineOf(size:Number, bold:Boolean = false) : Number
      {
         var key:String = FONT + "|" + size + (bold ? "b" : "");
         var probe:TextField = null;
         var m:TextLineMetrics = null;
         var tall:Number = 0;
         if(LINES[key] == null)
         {
            probe = new TextField();
            probe.defaultTextFormat = new TextFormat(FONT,size,0,bold);
            renderer.say(probe,"Hg");
            m = probe.getLineMetrics(0);
            tall = m.ascent + m.descent;
            LINES[key] = (tall > 0 ? tall : probe.textHeight) + GUTTER * 2;
         }
         return Number(LINES[key]);
      }

      public static function wideOf(body:String, size:Number, bold:Boolean = false,
                                    spacing:Number = 0) : int
      {
         var key:String = FONT + "|" + body + "|" + size + (bold ? "b" : "") + "|" + spacing;
         var probe:TextField = null;
         var fmt:TextFormat = null;
         if(WIDTHS[key] == null)
         {
            fmt = new TextFormat(FONT,size,0,bold);
            fmt.letterSpacing = spacing;
            probe = new TextField();
            probe.defaultTextFormat = fmt;
            renderer.say(probe,body);
            WIDTHS[key] = Math.ceil(probe.textWidth) + GUTTER * 2;
         }
         return int(WIDTHS[key]);
      }

      private static function ascentOf(size:Number, bold:Boolean = false) : Number
      {
         var key:String = FONT + "|" + size + (bold ? "b" : "");
         var probe:TextField = null;
         if(ASCENTS[key] == null)
         {
            probe = new TextField();
            probe.defaultTextFormat = new TextFormat(FONT,size,0,bold);
            renderer.say(probe,"Hg");
            ASCENTS[key] = probe.getLineMetrics(0).ascent + GUTTER;
         }
         return Number(ASCENTS[key]);
      }

      public static function baseline(field:TextField, y:Number) : void
      {
         var fmt:TextFormat = field.defaultTextFormat;
         field.y = y - ascentOf(Number(fmt.size),fmt.bold == true);
      }

      public static function markBy(field:TextField, h:Number) : Number
      {
         var fmt:TextFormat = field.defaultTextFormat;
         var size:Number = Number(fmt.size);
         var bold:Boolean = fmt.bold == true;
         var body:Number = (ascentOf(size,bold) - GUTTER) * CAP;
         return field.y + ascentOf(size,bold) - (body + h) / 2;
      }

      public static function baselineIn(size:Number, top:Number, h:Number,
                                        bold:Boolean = false) : Number
      {
         return top + (h - lineOf(size,bold)) / 2 + ascentOf(size,bold);
      }

      public static function deep(size:Number, lines:int = 1, bold:Boolean = false) : int
      {
         return int(lineOf(size,bold) * lines + GUTTER * 2);
      }

      public static function blockOf(field:TextField) : int
      {
         var fmt:TextFormat = field.defaultTextFormat;
         var one:int = deep(int(fmt.size),1,fmt.bold == true);
         return Math.max(one,int(field.textHeight + GUTTER * 2));
      }

      public static function centre(field:TextField, top:Number, h:Number) : void
      {
         var fmt:TextFormat = field.defaultTextFormat;
         var size:Number = Number(fmt.size);
         var bold:Boolean = fmt.bold == true;
         var line:Number = lineOf(size,bold);
         var deep:Number = field.textHeight + GUTTER * 2;
         if(deep <= line)
         {
            baseline(field,baselineIn(size,top,h,bold));
            return;
         }
         field.y = top + (h - deep) / 2;
      }

      public static function firstLine(field:TextField, top:Number, h:Number) : void
      {
         var fmt:TextFormat = field.defaultTextFormat;
         baseline(field,baselineIn(Number(fmt.size),top,h,fmt.bold == true));
      }

      public static function across(field:TextField, left:Number, w:Number) : void
      {
         field.x = left + (w - (field.textWidth + GUTTER * 2)) / 2;
      }

      public static function hug(field:TextField, x:Number) : void
      {
         field.width = field.textWidth + GUTTER * 2;
         field.height = field.textHeight + GUTTER * 2;
         field.x = x - GUTTER;
      }

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

      public static function fitBox(field:TextField, wide:Number, high:Number, size:int,
                                    floor:int) : int
      {
         var at:int = size;
         var fmt:TextFormat = field.defaultTextFormat;
         field.autoSize = TextFieldAutoSize.NONE;
         field.multiline = true;
         field.wordWrap = true;
         field.width = wide;
         while(true)
         {
            fmt.size = at;
            field.defaultTextFormat = fmt;
            field.setTextFormat(fmt);
            if(at <= floor || (field.textWidth <= wide && field.textHeight <= high))
            {
               break;
            }
            at--;
         }
         field.height = deep(at,field.numLines < 1 ? 1 : field.numLines);
         return at;
      }

      public static function elide(field:TextField, wide:Number) : void
      {
         var body:String = field.text;
         while(body.length > 1 && field.textWidth > wide)
         {
            body = body.substr(0,body.length - 1);
            renderer.say(field,body + "…");
         }
      }

      public static function elideLines(field:TextField, lines:int) : void
      {
         var body:String = field.text;
         while(body.length > 1 && field.numLines > lines)
         {
            body = body.substr(0,body.length - 1);
            renderer.say(field,body + "…");
         }
      }

      public static function resize(field:TextField, size:int) : void
      {
         var fmt:TextFormat = field.defaultTextFormat;
         if(int(fmt.size) == size)
         {
            return;
         }
         fmt.size = size;
         field.defaultTextFormat = fmt;
         if(field.length > 0)
         {
            field.setTextFormat(fmt);
         }
      }

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

      public static function heart(target:*, cx:Number, cy:Number, w:int, h:int, color:uint, solid:Boolean = false, opacity:Number = 1) : *
      {
         var up:Number = w / 4;
         var down:Number = h / 2;
         var g:* = target.graphics;
         if(solid)
         {
            g.beginFill(color & 0xFFFFFF,opacity);
         }
         else
         {
            g.lineStyle(1.4,color & 0xFFFFFF,opacity);
         }
         g.moveTo(cx,cy - up);
         g.curveTo(cx + up * 2.1,cy - up * 2.1,cx + up * 2,cy);
         g.curveTo(cx + up,cy + up * 1.5,cx,cy + down);
         g.curveTo(cx - up,cy + up * 1.5,cx - up * 2,cy);
         g.curveTo(cx - up * 2.1,cy - up * 2.1,cx,cy - up);
         if(solid)
         {
            g.endFill();
         }
         g.lineStyle();
         return target;
      }

      public static function lift(color:uint, t:Number) : uint
      {
         return blend(color,VALUE,t) | color & 0xFF000000;
      }

      public static function sink(color:uint, percent:Number) : uint
      {
         return shade(color,percent) | color & 0xFF000000;
      }

      public static function accent(target:*, x:int, y:int, w:int, h:int) : *
      {
         return vertical(target,x,y,w,h,CYAN,sink(CYAN,FILL));
      }

      public static function raised(target:*, x:int, y:int, w:int, h:int,
                                    light:uint, dark:uint) : *
      {
         return vertical(target,x,y,w,h,lift(light,LIFT),sink(dark,SINK));
      }

      public static function tint(body:String = "", color:uint = 0xFFFFFF) : String
      {
         return "<font color=\"#" + Config.hex(color) + "\">" + body + "</font>";
      }

      public static function gradeFor(fraction:Number) : uint
      {
         var pct:Number = fraction * 100;
         if(pct < 30) { return RED; }
         if(pct < 50) { return ORANGE; }
         if(pct < 70) { return YELLOW; }
         if(pct < 100) { return GREEN; }
         return CYAN;
      }

      public static function rampFor(fraction:Number) : uint
      {
         if(fraction < 0.33) { return blend(RED,ORANGE,fraction / 0.33); }
         if(fraction < 0.66) { return blend(ORANGE,YELLOW,(fraction - 0.33) / 0.33); }
         return blend(YELLOW,GREEN,(fraction - 0.66) / 0.34);
      }

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

      public static function chaos(target:*, x:int, y:int, w:int, h:int) : *
      {
         var box:Matrix = new Matrix();
         box.createGradientBox(w,h,Math.PI / 4,x,y);
         target.graphics.beginGradientFill(GradientType.LINEAR,CHAOS,CHAOS_ALPHA,CHAOS_STOP,box);
         target.graphics.drawRect(x,y,w,h);
         target.graphics.endFill();
         return target;
      }

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

      public static function pip(target:*, x:Number = 0, y:Number = 0, radius:Number = 0,
                                 color:uint = 0, alpha:Number = 1) : *
      {
         var start:Number = -Math.PI / 2;
         var inner:Number = radius / 2;
         var step:Number = Math.PI * 2 / 5;
         var point:int = 0;
         var outerAngle:Number = 0;
         var innerAngle:Number = 0;
         target.graphics.beginFill(color & 0xFFFFFF,alpha * solidity(color));
         target.graphics.lineStyle(Math.max(0.75,radius * 0.16),BLACK,0.95);
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

      public static function group(value:Number) : String
      {
         return commas(String(value < 0 ? Math.ceil(value) : Math.floor(value)));
      }

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
