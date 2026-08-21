package ui
{
   /** Picker with an opacity strip beside the hue, for the colours where transparency
    *  is part of the setting.
    *
    *  It is a separate control rather than a flag on the other one so a screen states
    *  which it means at the point it declares the option. A strip offered where
    *  transparency has no meaning is a strip somebody will move, and then a colour
    *  that was never supposed to fade is half gone with nothing to say why.
    *
    *  Fully opaque writes #RRGGBB and anything less writes #RRGGBBAA, so a config file
    *  that never touches transparency reads exactly as it always did, and a plain
    *  Picker handed an eight digit value takes the colour and ignores the rest. */
   public class AlphaPicker extends Picker
   {

      public function AlphaPicker(key:String, text:String, w:int)
      {
         super(key,text,w);
         this.translucent = true;
      }
   }
}
