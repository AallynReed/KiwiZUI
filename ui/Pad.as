package ui
{
   public class Pad extends Art
   {

      public static const SOUTH:String = "south";

      public static const EAST:String = "east";

      public static const WEST:String = "west";

      public static const NORTH:String = "north";

      public static const LB:String = "lb";

      public static const RB:String = "rb";

      public static const LT:String = "lt";

      public static const RT:String = "rt";

      public static const DPAD:String = "dpad";

      public static const DPAD_NORTH:String = "dpad_north";

      public static const DPAD_SOUTH:String = "dpad_south";

      public static const DPAD_WEST:String = "dpad_west";

      public static const DPAD_EAST:String = "dpad_east";

      public static const DPAD_UPDOWN:String = "dpad_updown";

      public static const DPAD_UPDOWNEAST:String = "dpad_updowneast";

      public static const LEFT_STICK:String = "analog_top_left";

      public static const RIGHT_STICK:String = "analog_top_right";

      public static const LEFT_STICK_PRESS:String = "analog_side_left";

      public static const RIGHT_STICK_PRESS:String = "analog_side_right";

      public static const MENU:String = "menu";

      public static const VIEW:String = "view";

      public static const GUIDE:String = "XB";

      public static const KEYBOARD:String = "keyboard";

      public static const ALL:Array = [SOUTH,EAST,WEST,NORTH,LB,RB,LT,RT,DPAD,DPAD_NORTH,
                                       DPAD_SOUTH,DPAD_WEST,DPAD_EAST,DPAD_UPDOWN,
                                       DPAD_UPDOWNEAST,LEFT_STICK,RIGHT_STICK,
                                       LEFT_STICK_PRESS,RIGHT_STICK_PRESS,MENU,VIEW,GUIDE,
                                       KEYBOARD];

      public function Pad(box:int = 16)
      {
         super(box);
      }

      public function button(name:String, box:int) : Boolean
      {
         return this.show(PadArt,name,box);
      }
   }
}
