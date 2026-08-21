package ui
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;

   /** There is no .cfg in ModCfgs\ for this mod, so nothing it is told is kept.
    *
    *  The mod cannot answer this itself: OnSaveConfig only fills in keys in a file that
    *  is already there, and no call in the bridge brings one into being. So the panel
    *  is an instruction rather than an offer, and it comes back every session until the
    *  file is put in place - there is nowhere to record that it was read.
    *
    *  It leads with closing the game, because that is the step that goes wrong. Trove
    *  writes ModCfgs\ back out as it exits, over whatever is there, so a file dropped
    *  in while it is running is overwritten by the copy the running client is holding -
    *  which is the file that does not exist. The name is set apart from the sentences
    *  for the same reason: it has to be copied exactly, and prose is not something
    *  anyone copies exactly.
    *
    *  Not part of the screen until it is asked for: show() attaches it and hide() takes
    *  it away, so an open one is by construction the last child and over everything. */
   public class Notice extends Sprite
   {

      private static const MAXW:int = 420;

      private static const PAD:int = 20;

      private static const HEAD:int = 42;

      private static const BTN:int = 30;

      /** Padding inside the box the file name sits in. */
      private static const BOX:int = 8;

      private var scrim:Shape = new Shape();

      private var panel:Shape = new Shape();

      private var titleText:TextField;

      private var bodyText:TextField;

      private var fileText:TextField;

      private var fileBox:Shape = new Shape();

      private var okBtn:Plate = new Plate(120,BTN,11);

      private var span:int;

      private var high:int;

      private var wide:int = MAXW;

      /** Sized at show() rather than in the constructor: a screen that takes its
       *  dimensions from the stage does not have them yet while it is building, and
       *  MAXW is wider than the narrower panels this ships on. */
      public function Notice(title:String)
      {
         super();
         addChild(this.scrim);
         addChild(this.panel);
         this.titleText = renderer.label(0,0,14,TextFieldAutoSize.LEFT,"NO SETTINGS FILE",
                                         MAXW - PAD * 2,24,false,false,1.6);
         this.bodyText = renderer.label(0,0,12,TextFieldAutoSize.LEFT,
                                        "Close Trove first. Adding the file while the "
                                        + "game is running breaks it. Put it in the "
                                        + "ModCfgs folder inside your Trove AppData "
                                        + "directory, then start the game again. "
                                        + "BetterTroveTools does this for you.",
                                        MAXW - PAD * 2,90,true);
         this.fileText = renderer.label(0,0,12,TextFieldAutoSize.LEFT,title + ".cfg",
                                        MAXW - PAD * 2 - BOX * 2,20);
         addChild(this.titleText);
         addChild(this.fileBox);
         addChild(this.fileText);
         addChild(this.bodyText);
         this.okBtn.text = "GOT IT";
         this.okBtn.addEventListener(MouseEvent.CLICK,this.onDone);
         addChild(this.okBtn);
         addEventListener(MouseEvent.CLICK,this.onOutside);
      }

      public function get shown() : Boolean
      {
         return this.parent != null;
      }

      public function show(host:Sprite, span:int, high:int) : void
      {
         this.span = span;
         this.high = high;
         this.wide = Math.min(MAXW,span - PAD * 2);
         host.addChild(this);
         this.paint();
      }

      public function hide() : void
      {
         if(this.parent != null)
         {
            this.parent.removeChild(this);
         }
      }

      public function paint() : void
      {
         var tall:int = 0;
         var left:int = 0;
         var top:int = 0;
         this.titleText.width = this.bodyText.width = this.wide - PAD * 2;
         this.fileText.width = this.wide - PAD * 2 - BOX * 2;
         tall = HEAD + 14 + this.fileText.height + BOX * 2 + 12 + this.bodyText.height
              + 16 + BTN + PAD;
         left = (this.span - this.wide) / 2;
         top = (this.high - tall) / 2;
         this.x = left;
         this.y = top;

         this.scrim.graphics.clear();
         renderer.fill(this.scrim,-left,-top,this.span,this.high,renderer.PANEL,0.7);
         this.panel.graphics.clear();
         renderer.framed(this.panel,0,0,this.wide,tall,renderer.RAISED2,renderer.CYAN,1);
         renderer.fill(this.panel,1,1,this.wide - 2,HEAD - 1,renderer.HEADER,1);

         this.titleText.x = PAD;
         this.titleText.y = (HEAD - this.titleText.height) / 2;
         this.titleText.textColor = renderer.CYAN;
         this.fileBox.graphics.clear();
         renderer.framed(this.fileBox,PAD,HEAD + 14,this.wide - PAD * 2,
                         this.fileText.height + BOX * 2,renderer.HEADER,renderer.RAISED2,1);
         this.fileText.x = PAD + BOX;
         this.fileText.y = HEAD + 14 + BOX;
         this.fileText.textColor = renderer.CYAN;
         this.bodyText.x = PAD;
         this.bodyText.y = HEAD + 14 + this.fileText.height + BOX * 2 + 12;
         this.bodyText.textColor = renderer.VALUE;
         this.okBtn.x = (this.wide - 120) / 2;
         this.okBtn.y = tall - PAD - BTN;
         this.okBtn.paint();
      }

      private function onDone(e:MouseEvent) : void
      {
         this.hide();
         dispatchEvent(new Event(Event.CLOSE));
      }

      private function onOutside(e:MouseEvent) : void
      {
         var at:Rectangle = new Rectangle(0,0,this.wide,this.panel.height);
         if(!at.contains(this.mouseX,this.mouseY))
         {
            this.onDone(e);
         }
      }
   }
}
