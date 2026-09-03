package
{
   public class Countdown
   {

      public static const SLACK:Number = 1500;

      private var ends:Number = 0;

      private var span:Number = 0;

      public function Countdown()
      {
         super();
      }

      public function get deadline() : Number
      {
         return this.ends;
      }

      public function get total() : Number
      {
         return this.span;
      }

      public function report(remaining:Number, duration:Number, now:Number,
                             fresh:Boolean = false) : void
      {
         var seconds:Number = isNaN(remaining) || remaining < 0 ? 0 : remaining;
         var whole:Number = isNaN(duration) || duration < 0 ? 0 : duration;
         var at:Number = now + seconds * 1000;
         if(fresh || whole != this.span || Math.abs(at - this.ends) > SLACK)
         {
            this.ends = at;
         }
         this.span = whole;
      }

      public function left(now:Number) : Number
      {
         var out:Number = (this.ends - now) / 1000;
         return out > 0 ? out : 0;
      }
   }
}
