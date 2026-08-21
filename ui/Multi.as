package ui
{
   /** Any number of choices out of a list, as the same dropdown with a tick beside
    *  every row. A click toggles one and leaves the list open, because picking three
    *  things should not be three trips through the menu - and each toggle is still
    *  exactly one config write, which is the rule a control has to keep.
    *
    *  The literal is the chosen values joined by commas, so a config file states the
    *  set in the words the code already uses for it and stays editable by hand. */
   public class Multi extends Combo
   {

      public var chosen:Array = [];

      private var noneText:String;

      private var allText:String;

      public function Multi(key:String, text:String, w:int, values:Array, labels:Array = null,
                            noneText:String = "None", allText:String = "All")
      {
         super(key,text,w,values,labels);
         this.noneText = noneText;
         this.allText = allText;
         this.boxes = true;
         var i:int = 0;
         while(i < values.length)
         {
            this.chosen.push(false);
            i++;
         }
      }

      override public function get literal() : String
      {
         var out:Array = [];
         var i:int = 0;
         while(i < this.values.length)
         {
            if(this.chosen[i])
            {
               out.push(this.values[i]);
            }
            i++;
         }
         return out.join(",");
      }

      override public function set from(raw:String) : void
      {
         var want:Array = (raw == null ? "" : raw).split(" ").join("").split(",");
         var i:int = 0;
         while(i < this.values.length)
         {
            this.chosen[i] = want.indexOf(String(this.values[i])) >= 0;
            i++;
         }
      }

      override public function marked(i:int) : Boolean
      {
         return Boolean(this.chosen[i]);
      }

      /** The chosen labels, written out. A count says how many were picked and never
       *  which, so the closed box names them and the field it goes in cuts the line
       *  off where it runs out of room. */
      override public function get summary() : String
      {
         var out:Array = [];
         var i:int = 0;
         if(this.count == 0)
         {
            return this.noneText;
         }
         if(this.count == this.values.length)
         {
            return this.allText;
         }
         while(i < this.values.length)
         {
            if(this.chosen[i])
            {
               out.push(String(this.labels[i]));
            }
            i++;
         }
         return out.join(", ");
      }

      public function get count() : int
      {
         var n:int = 0;
         var i:int = 0;
         while(i < this.chosen.length)
         {
            if(this.chosen[i])
            {
               n++;
            }
            i++;
         }
         return n;
      }

      /** A set has no next item, so there is nothing for the arrows to walk. */
      override public function stroke(code:uint, scale:Number) : Boolean
      {
         return false;
      }

      /** Left open on purpose: the menu is where a set is assembled, and closing it
       *  after every tick would make choosing three things three round trips. */
      override public function pick(i:int) : void
      {
         this.chosen[i] = !this.chosen[i];
         this.repaintMenu();
         this.paint();
         this.announce();
      }
   }
}
