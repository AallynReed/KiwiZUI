package ui
{
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
