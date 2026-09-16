package ui
{

   public class Widget
   {

      public function Widget()
      {
         super();
      }

      public static function controls(specs:Array, w:int) : Array
      {
         var one:Option = null;
         var out:Array = [];
         var i:int = 0;
         while(i < specs.length)
         {
            one = control(specs[i],w);
            if(one != null)
            {
               out.push(one);
            }
            i++;
         }
         return out;
      }

      public static function control(spec:Object, w:int) : Option
      {
         var values:Array = [];
         var labels:Array = [];
         var choices:Array = spec.choices as Array;
         var i:int = 0;
         switch(String(spec.type))
         {
            case Hub.CHECK:
               return new Check(String(spec.key),String(spec.label),w);
            case Hub.SLIDER:
               return new Slider(String(spec.key),String(spec.label),w,
                                 Number(spec.min),Number(spec.max),Number(spec.step),
                                 int(spec.places),String(spec.zero),String(spec.suffix));
            case Hub.SPIN:
               return new Spin(String(spec.key),String(spec.label),w,
                               Number(spec.max),Number(spec.min),Number(spec.step),
                               int(spec.places),String(spec.suffix));
            case Hub.STEPPER:
               return new Stepper(String(spec.key),String(spec.label),w,
                                  Number(spec.min),Number(spec.max),Number(spec.step),
                                  int(spec.places),String(spec.zero),String(spec.suffix));
            case Hub.COMBO:
               while(i < choices.length)
               {
                  values.push((choices[i] as Array)[0]);
                  labels.push((choices[i] as Array)[1]);
                  i++;
               }
               return new Combo(String(spec.key),String(spec.label),w,values,labels);
            case Hub.MULTI:
               while(i < choices.length)
               {
                  values.push((choices[i] as Array)[0]);
                  labels.push((choices[i] as Array)[1]);
                  i++;
               }
               return new Multi(String(spec.key),String(spec.label),w,values,labels);
            case Hub.COLOR:
               return new Picker(String(spec.key),String(spec.label),w);
            case Hub.ALPHA:
               return new AlphaPicker(String(spec.key),String(spec.label),w);
            case Hub.INPUT:
               return new Input(String(spec.key),String(spec.label),w);
            case Hub.LIST:
               return new List(String(spec.key),String(spec.label),w,
                               String(spec.prompt).length > 0 ? String(spec.prompt) : List.PROMPT);
            case Hub.HEADING:
               return new Heading(String(spec.label),w);
            case Hub.NOTE:
               return new Note(String(spec.label),w);
            case Hub.ACT:
               return new Act(String(spec.key),String(spec.label),w);
         }
         return null;
      }
   }
}
