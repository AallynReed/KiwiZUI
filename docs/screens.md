# Building a screen

There are two ways to change a Trove UI screen, and they are not equally good.

## Write the screen, do not patch it

The vanilla SWF is an **asset container** — art, fonts, symbol classes, timeline children
— and nothing more. Replace the screen's own class outright rather than threading hooks
through Trove's.

Hooks look cheaper and are not. They inherit Trove's layout, they run inside its call
order, and every game update re-opens all of them. Re-porting a hook-based mod is a hunt
for numbered edits through someone else's method bodies. Re-porting a replaced class is:
decompile the new SWF, diff two lists, fix whatever the container renamed.

## What the container forces on you

Three things, and this is the whole of it.

**Declare every timeline child you touch.** Flash binds instance names to typed fields on
the symbol class. An undeclared name is a runtime failure, not a compile one. Copy the
`public var` block out of the stock decompile verbatim.

**Register every engine callback, even as a no-op.** The engine calls into the SWF by
name. One missing name is a feature that silently stops working with nothing in any log.
Take the list from the stock decompile and match it exactly.

**Keep the outbound calls the screen is expected to make.** Dropping `OnDropOntoSlot` or
`CheckUpgradeAvailability` breaks the game's own state, not just your window's.

Everything else — layout, drawing, event wiring, what is shown at all — is yours.

## From scratch

The stronger option, where the screen does not depend on art in the vanilla SWF. `mxmlc`
builds `ui/<screen>.swf` out of your own sources, and Iggy binds its natives onto the
classes you declare. Nothing of Trove's has to be present.

```actionscript
package
{
   import flash.display.Sprite;
   import flash.display.StageAlign;
   import flash.display.StageScaleMode;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import ui.*;

   public class Claims extends Sprite
   {
      private var cfg:Config = new Config("claims.swf");
      private var hub:Hub;

      public function Claims()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE, this.onStage, false, 0, true);
         this.bind();
      }

      private function onStage(e:Event) : void
      {
         if(stage)
         {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.addEventListener(Event.RESIZE, this.onResize, false, 0, true);
         }
         this.layout();
      }

      private function bind() : void
      {
         if(IggyFunctions.inIggy)
         {
            ExternalInterface.addCallback("addClaim", this.addClaim);
            ExternalInterface.addCallback("setClaimed", this.setClaimed);
            ExternalInterface.addCallback("objectPreviewReady", this.onTextureReady);
            ExternalInterface.addCallback("loadModConfiguration", this.onConfig);
         }
         this.cfg.watch(this, Skin.KEYS, this.skin.defaultOf, this.onConfigMissing);
      }
   }
}
```

Four things in that worth stating plainly:

- **Every engine call is gated on `IggyFunctions.inIggy`.** The same build then runs under
  the standalone debug player with the engine parts skipped, which is where you should be
  testing.
- **`objectPreviewReady` is registered explicitly.** It is in no individual screen's
  callback list — every screen inherits it — so a from-scratch build that does not
  register it never receives an item icon.
- **Nothing is announced from the constructor.** `ExternalInterface.call` goes nowhere
  until Iggy has wired the bridge, silently. `Config.watch` handles the waiting.
- **The stage size is the vanilla screen's.** Take it from the SWF you are replacing;
  `-default-size 601 502` for `claims.swf`. The SWF *version* is not load-bearing — Iggy
  has accepted v43 from other mods — but the stage size is what the game's window expects.

A from-scratch screen is small. Vanilla `claims.swf` is 367 KB, mostly a copy of Arial;
the replacement is under 7 KB for the same screen, because Iggy provides the fonts.

## By replacing a class

Where the screen needs art out of the vanilla SWF and grafting it is not worth it:

```bash
ffdec.jar -replace vanilla.swf out.swf scripts/Screen.as Screen.as
```

**`-replace` only replaces scripts that already exist.** It cannot add one. So helper
classes have to go in file-scoped classes *after* the `package` block, in a file that is
already there.

That has a hard limit: **FFDec's compiler cannot resolve a file-scoped class as a base
class.** `Check`, `Picker` and `Input` all extend `Option`, and `AlphaPicker` extends
`Picker`, so a `-replace` build using this control set dies on `Option is not an existing
type`. A mod that bundles only standalone classes gets away with it.

Where you need both the vanilla art and the control set, build from scratch and graft the
art in. See [art.md](art.md).

Replace one script per invocation, chaining each output into the next.

## Re-porting after a game update

1. Decompile the new SWF.
2. Diff the `public var` block against yours.
3. Diff the callback list against yours.
4. Fix whatever the container renamed.

That is the whole procedure, and it is why replacing the class is worth it.

## Verify before shipping

Three things, all automatable, in order of how much they catch:

1. **Grep your own decompiled build** for every callback name, every outbound call and
   every class the engine binds onto. The compiler proves the source is valid AS3; it
   cannot prove the SWF still speaks Iggy's protocol. A callback you forgot to register
   has no symptom until a player finds it.
2. **Every class you did not target is byte-identical to the stock decompile.** A patch
   that quietly rewrote something you were not editing breaks on the next update in a way
   you cannot diagnose.
3. **The compile is a fixed point** — recompiling the build's own decompiled source
   reproduces it. Where it is not, something compiles to bytecode that does not
   round-trip, and that is where a future port goes wrong.

Where there is maths, mirror it outside ActionScript and fuzz it against the real tables.

## The rules that are not obvious

- **No guessing.** Game constants come from the game. Strings come from
  `IggyFunctions.translate("$Key")`, with keys read out of `<Trove>\languages\en\*.binfab`
  — never matched against English text. If a value cannot be known authoritatively, do not
  render it.
- **Draw into a child `Shape`, never a control's own `graphics`.**
- **One config write per key, once.**
- **Restart Trove in full to test.** Iggy caches UI SWFs for the session.
