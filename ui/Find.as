package ui
{
   /** A click lands on whatever child happened to be drawn under the pointer, which is
    *  rarely the thing that wants to know about it. Walking up from the target is what
    *  turns that into "which slot / card / button was this", without a listener on
    *  every part of every one of them. */
   public class Find
   {

      public function Find()
      {
         super();
      }

      public static function ancestorOf(node:*, kind:Class) : *
      {
         while(node != null && !(node is kind))
         {
            node = node.parent;
         }
         return node;
      }
   }
}
