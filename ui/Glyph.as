package ui
{
   import flash.display.Shape;

   /** The tab marks, drawn rather than fetched.
    *
    *  Vanilla's own tabs are icons and the art is in the SWF - five shapes, one per mode,
    *  each a complete tab face with the plate baked into the same shape as the glyph. It
    *  cannot be lifted out of them without rewriting the shape records, it would arrive
    *  wearing vanilla's plate rather than ours, and there is nothing in it for the gems
    *  tab, which is ours and not the game's. So these are drawn.
    *
    *  Drawn, and not embedded or fetched: Iggy renders the geometry a SWF carries and
    *  very little else a mod can bring - see ART.md, where four other routes were put in
    *  front of it and all four came back blank. A path is a path in any client.
    *
    *  They say what vanilla's say, because that is what a player already reads: a sword
    *  for the adventure bag, a block for the build bag, a leaf for crafting, a crystal
    *  for Geode, a badge for modules, a bust for the character sheet, a winged shield for
    *  mastery and crossed swords for PvP. The gem is ours.
    *
    *  The character sheet's own tabs are the same story one screen along: four 40x54
    *  bitmaps, each the whole tab face - gold frame, coloured background and the icon on
    *  top of it, in one character. Nothing in there can be grafted but the frame with it,
    *  and keying the background out means re-encoding a bitmap off a gradient. So these,
    *  which take the palette and are the same drawing at any size. */
   public class Glyph
   {

      public static const ADVENTURE:int = 0;

      public static const BUILD:int = 1;

      public static const CRAFTING:int = 2;

      public static const GEODE:int = 3;

      public static const MODULE:int = 4;

      public static const GEM:int = 5;

      public static const CHARACTER:int = 6;

      public static const MASTERY:int = 7;

      public static const PVP:int = 8;

      public function Glyph()
      {
         super();
      }

      /** One mark, drawn into the box the button reserved for it. Everything below is in
       *  twentieths of that box, so a mark is the same drawing at any size. */
      public static function draw(face:Shape, kind:int, box:Number, color:uint) : void
      {
         var u:Number = box / 20;
         switch(kind)
         {
            case ADVENTURE:
               sword(face,u,color);
               return;
            case BUILD:
               block(face,u,color);
               return;
            case CRAFTING:
               leaf(face,u,color);
               return;
            case GEODE:
               crystal(face,u,color);
               return;
            case MODULE:
               badge(face,u,color);
               return;
            case GEM:
               gem(face,u,color);
               return;
            case CHARACTER:
               bust(face,u,color);
               return;
            case MASTERY:
               shield(face,u,color);
               return;
            case PVP:
               crossed(face,u,color);
         }
      }

      private static function poly(face:Shape, u:Number, color:uint, alpha:Number,
                                   points:Array) : void
      {
         var i:int = 2;
         face.graphics.beginFill(color & 0xFFFFFF,alpha * renderer.solidity(color));
         face.graphics.moveTo(Number(points[0]) * u,Number(points[1]) * u);
         while(i < points.length)
         {
            face.graphics.lineTo(Number(points[i]) * u,Number(points[i + 1]) * u);
            i += 2;
         }
         face.graphics.endFill();
      }

      /** A shape taken back out of a mark, in the panel's own colour rather than by
       *  erasing: one Shape holds the whole glyph and Flash has no hole to punch. */
      private static function cut(face:Shape, u:Number, points:Array) : void
      {
         var i:int = 2;
         face.graphics.beginFill(renderer.PANEL & 0xFFFFFF,0.85);
         face.graphics.moveTo(Number(points[0]) * u,Number(points[1]) * u);
         while(i < points.length)
         {
            face.graphics.lineTo(Number(points[i]) * u,Number(points[i + 1]) * u);
            i += 2;
         }
         face.graphics.endFill();
      }

      private static function bar(face:Shape, u:Number, color:uint, alpha:Number,
                                  x:Number, y:Number, w:Number, h:Number) : void
      {
         face.graphics.beginFill(color & 0xFFFFFF,alpha * renderer.solidity(color));
         face.graphics.drawRect(x * u,y * u,w * u,h * u);
         face.graphics.endFill();
      }

      /** Point up, because that is how vanilla's sits and how a sword is drawn. */
      private static function sword(face:Shape, u:Number, color:uint) : void
      {
         poly(face,u,color,1,[10,1, 12.2,4.5, 12.2,12, 7.8,12, 7.8,4.5]);
         bar(face,u,color,0.75,4.5,12,11,1.9);
         bar(face,u,color,1,8.8,13.9,2.4,4.2);
         face.graphics.beginFill(color & 0xFFFFFF,renderer.solidity(color));
         face.graphics.drawCircle(10 * u,18.6 * u,1.5 * u);
         face.graphics.endFill();
      }

      /** A cube, which is what a build bag is full of. Three faces at three weights of
       *  the one colour, so it reads as a solid without a second colour to configure. */
      private static function block(face:Shape, u:Number, color:uint) : void
      {
         poly(face,u,color,1,[10,1.5, 17.5,5.8, 10,10.1, 2.5,5.8]);
         poly(face,u,color,0.72,[2.5,5.8, 10,10.1, 10,18.5, 2.5,14.2]);
         poly(face,u,color,0.45,[10,10.1, 17.5,5.8, 17.5,14.2, 10,18.5]);
      }

      private static function leaf(face:Shape, u:Number, color:uint) : void
      {
         face.graphics.beginFill(color & 0xFFFFFF,renderer.solidity(color));
         face.graphics.moveTo(4 * u,16.5 * u);
         face.graphics.curveTo(3 * u,4 * u,16.5 * u,3.5 * u);
         face.graphics.curveTo(17 * u,16 * u,4 * u,16.5 * u);
         face.graphics.endFill();
         face.graphics.lineStyle(1.4 * u,renderer.PANEL & 0xFFFFFF,0.85);
         face.graphics.moveTo(5 * u,16 * u);
         face.graphics.lineTo(14.5 * u,5.5 * u);
         face.graphics.lineStyle();
      }

      /** The cut Geode's own tab shows: a long hexagon with a facet down it. */
      private static function crystal(face:Shape, u:Number, color:uint) : void
      {
         poly(face,u,color,1,[10,1.2, 16,5.6, 16,14.4, 10,18.8, 4,14.4, 4,5.6]);
         face.graphics.lineStyle(1.3 * u,renderer.PANEL & 0xFFFFFF,0.8);
         face.graphics.moveTo(4 * u,5.6 * u);
         face.graphics.lineTo(10 * u,8 * u);
         face.graphics.lineTo(16 * u,5.6 * u);
         face.graphics.moveTo(10 * u,8 * u);
         face.graphics.lineTo(10 * u,18.8 * u);
         face.graphics.lineStyle();
      }

      /** A module is a fitting rather than a thing, so it is drawn as one: a plate with
       *  a socket in the middle of it. */
      private static function badge(face:Shape, u:Number, color:uint) : void
      {
         face.graphics.lineStyle(1.9 * u,color & 0xFFFFFF,renderer.solidity(color));
         face.graphics.drawRoundRect(2.6 * u,2.6 * u,14.8 * u,14.8 * u,5 * u,5 * u);
         face.graphics.lineStyle();
         face.graphics.beginFill(color & 0xFFFFFF,renderer.solidity(color));
         face.graphics.drawCircle(10 * u,10 * u,3.1 * u);
         face.graphics.endFill();
      }

      /** Head and shoulders, which is what vanilla's character tab carries. Square,
       *  because everything in this game is. */
      private static function bust(face:Shape, u:Number, color:uint) : void
      {
         bar(face,u,color,1,6.4,2.4,7.2,7.6);
         poly(face,u,color,0.72,[2.8,18.6, 2.8,14.4, 6.4,11.6, 13.6,11.6, 17.2,14.4, 17.2,18.6]);
         face.graphics.lineStyle(1.3 * u,renderer.PANEL & 0xFFFFFF,0.85);
         face.graphics.moveTo(8.1 * u,5.6 * u);
         face.graphics.lineTo(8.1 * u,6.8 * u);
         face.graphics.moveTo(11.9 * u,5.6 * u);
         face.graphics.lineTo(11.9 * u,6.8 * u);
         face.graphics.lineStyle();
      }

      /** Mastery is a rank, so it is drawn as one: the shield vanilla's tab carries with
       *  a rank's chevrons cut out of it. The wings on vanilla's badge are three shapes
       *  fighting over the same twenty pixels and come out as flaps at this size. */
      private static function shield(face:Shape, u:Number, color:uint) : void
      {
         poly(face,u,color,1,[10,2, 16,4.6, 16,11.4, 10,18.2, 4,11.4, 4,4.6]);
         cut(face,u,[10,6, 13.2,8, 13.2,9.6, 10,7.6, 6.8,9.6, 6.8,8]);
         cut(face,u,[10,10, 13.2,12, 13.2,13.6, 10,11.6, 6.8,13.6, 6.8,12]);
      }

      /** Two swords crossed, which is the mark every game uses for this and the one
       *  vanilla's PvP tab carries. Longer than the single sword above and drawn with a
       *  grip: a blade that stops at its guard reads as a chevron once it is leaning. */
      private static function crossed(face:Shape, u:Number, color:uint) : void
      {
         blade(face,u,color,-40);
         blade(face,u,color,40);
      }

      private static function blade(face:Shape, u:Number, color:uint, deg:Number) : void
      {
         poly(face,u,color,1,turn(deg,[10,0.8, 11.3,3.2, 11.3,13.2, 8.7,13.2, 8.7,3.2]));
         poly(face,u,color,0.72,turn(deg,[5.6,13.2, 14.4,13.2, 14.4,15, 5.6,15]));
         poly(face,u,color,0.9,turn(deg,[9,15, 11,15, 11,18.4, 9,18.4]));
         poly(face,u,color,0.72,turn(deg,[8.2,18.4, 11.8,18.4, 11.8,19.6, 8.2,19.6]));
      }

      /** The same points about the middle of the box, so a sword is written down once
       *  and leant either way rather than twice with the second set worked out by hand. */
      private static function turn(deg:Number, points:Array) : Array
      {
         var a:Number = deg * Math.PI / 180;
         var cos:Number = Math.cos(a);
         var sin:Number = Math.sin(a);
         var out:Array = [];
         var x:Number = 0;
         var y:Number = 0;
         var i:int = 0;
         while(i < points.length)
         {
            x = Number(points[i]) - 10;
            y = Number(points[i + 1]) - 10;
            out.push(10 + x * cos - y * sin,10 + x * sin + y * cos);
            i += 2;
         }
         return out;
      }

      /** A brilliant cut: a table, a girdle and a point. */
      private static function gem(face:Shape, u:Number, color:uint) : void
      {
         poly(face,u,color,1,[6.6,2.6, 13.4,2.6, 17.6,7.6, 10,18.4, 2.4,7.6]);
         face.graphics.lineStyle(1.3 * u,renderer.PANEL & 0xFFFFFF,0.8);
         face.graphics.moveTo(2.4 * u,7.6 * u);
         face.graphics.lineTo(17.6 * u,7.6 * u);
         face.graphics.moveTo(6.6 * u,2.6 * u);
         face.graphics.lineTo(7.6 * u,7.6 * u);
         face.graphics.moveTo(13.4 * u,2.6 * u);
         face.graphics.lineTo(12.4 * u,7.6 * u);
         face.graphics.moveTo(7.6 * u,7.6 * u);
         face.graphics.lineTo(10 * u,18.4 * u);
         face.graphics.moveTo(12.4 * u,7.6 * u);
         face.graphics.lineTo(10 * u,18.4 * u);
         face.graphics.lineStyle();
      }
   }
}
