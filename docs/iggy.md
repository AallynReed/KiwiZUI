# The Iggy contract

Trove's interface is rendered by Iggy, a commercial Flash runtime embedded in the
game. It runs AS3 bytecode and it is not the Flash player. Where it differs, it does
not warn you: **a rejected call takes the whole screen down, with nothing in any log,
anywhere.** A screen that fails this way draws nothing and reports nothing, and every
symptom points at the last thing you changed rather than at the thing that broke.

Read this page before writing a screen. Everything in it cost at least one build to
find.

## How the engine reaches your SWF

Two directions, both through `ExternalInterface`.

**Inbound.** The engine calls into the SWF by name.

```actionscript
ExternalInterface.addCallback("addClaim", this.addClaim);
```

The name is the contract. Trove decides what it calls and when, and your handler's
signature has to match what it passes. Get the list out of the stock decompile of the
screen you are replacing, and **register every one of them, even as a no-op.** A
missing name is a feature that silently stops working — no error, no log line, just a
part of the screen that never updates.

**Outbound.** You call the engine by name.

```actionscript
ExternalInterface.call("UIComponent.OnSaveConfig", swf, key, value);
ExternalInterface.call("OnRequestClose");
```

Keep the calls the screen you replaced was making. Dropping `OnDropOntoSlot` or
`CheckUpgradeAvailability` breaks the game's own state, not just your window's.

**Outbound calls are dead during construction.** A SWF can receive `addCallback`
immediately, but `ExternalInterface.call` goes nowhere until Iggy has finished wiring
the bridge, and it fails silently. Anything you want to announce — a config seed, a
settings declaration — has to wait for the first *inbound* callback, or for a few
frames to pass. Never send it from a constructor.

## Iggy binds onto your own classes

None of Trove's code has to be present for the bindings to attach. Declare the class
with the right name and the right signatures and the engine finds it:

```actionscript
package
{
   import flash.display.*;
   import flash.geom.*;

   public class IggyFunctions
   {
      public static var inIggy:* = false;

      public static function translate(param1:String) : *
      {
         return param1;
      }

      public static function setTextureForBitmap(param1:Bitmap, param2:Object,
                                                 param3:int = -1, param4:int = -1) : *
      {
      }
   }
}
```

Measured in game: `inIggy` comes back `true`, `translate("$Claims")` returns `CLAIMS`,
and `setTextureForBitmap` loads a real `.dds`. The copy in this repository
([IggyFunctions.as](../IggyFunctions.as)) is the full set, with bodies that behave
sensibly outside the game so the same build also runs under the debug player.

`inIggy` is the switch to gate every engine call on. It is false everywhere but in
game.

## Text

**Do not embed a font.** The client ships Open Sans in `<Trove>\ui\fonts\`, and a SWF
that embeds nothing still renders `new TextFormat("Open Sans", ...)`. Vanilla
`claims.swf` is 367 KB mostly because it embeds a copy of Arial; the replacement is
under 7 KB for the same screen.

**Size a `TextField` for its line box, not its font size.** `height = size + 5` clips
the text away entirely at 15pt and above: the field renders nothing, and it looks for
all the world like a font-size ceiling in the engine. Use `height = size * 2`, or set
`autoSize` and let the field size itself. `renderer.label()` does this for you.

**`htmlText` discards the field's paragraph alignment.** A right-aligned field
silently renders left the moment you assign `htmlText`. Put the alignment in the
markup (`<p align="right">`) or use `.text` with `setTextFormat`.

**`htmlText` also breaks measurement.** Its content goes in a paragraph box whose
height is not the height of a line, so `textHeight` describes something other than the
words. Every rule for centring text in a box is written in terms of that measurement,
so a reading built as markup sits wherever the mismeasurement lands. Use one field per
coloured piece instead — that is what [`ui.Run`](../ui/Run.as) is.

**Never match English text when a translation key exists.** Use
`IggyFunctions.translate("$Key")`, with keys read out of `<Trove>\languages\en\*.binfab`.

## Measurement and hit testing

**Iggy measures a sprite by its children and does not count the sprite's own
`graphics`.** A sprite that draws its face straight into `this.graphics` and carries no
children measures zero wide. A control that measures zero does not merely miss its own
clicks — it takes the ones around it too, and the whole header of a window starts
responding to a button that is not there.

Draw into a child `Shape`, always. [`ui.Plate`](../ui/Plate.as) exists because of this
bug; [pitfalls.md](pitfalls.md) has the full account.

## Textures and item icons

There are two different things here, and confusing them is a blank slot forever.

**A texture path binds directly**, if the game already has that texture resident:

```actionscript
IggyFunctions.setTextureForBitmap(bmp, "ui/meta_icons/meta_cubit.dds");
```

Resident is the operative word. A path the client has on disk but has not loaded does
not resolve, and retrying does not help. See [art.md](art.md).

**An item icon is an asynchronous render target, not a texture.** Iggy sets a slot's
`iconImage` to a *target name* like `Gems.gemSlot0`, then paints the object into it on
its own schedule. Calling `setTextureForBitmap` straight away throws `ArgumentError`
and the slot stays blank for good. The handshake, taken from `_kiwi.Core.ObjectPreview`:

1. `ExternalInterface.call("UIComponent.CheckTextureExists", name)`
2. wait for the engine to call `objectPreviewReady(name)` back
3. `setTextureForBitmap(bmp, null)`, reset `scaleX = scaleY = 1`, **then** bind the name

`objectPreviewReady` appears in no individual screen's callback list — every screen
inherits it from `ObjectPreview` — so a from-scratch build has to register it
explicitly or nothing ever arrives.

[`ui.ObjectPreview`](../ui/ObjectPreview.as) implements the handshake, and
[`ui.Slot`](../ui/Slot.as) is a whole item square built on it.

**Texture size comes from the file, not from the request.**
`setTextureForBitmap(bmp, name, 48, 48)` produces a 24x24 bitmap; the width and height
arguments do not scale anything. Set `bmp.width` and `bmp.height` afterwards if you
want a fixed size.

## Timing

**Do not build on `Timer`.** Callbacks can arrive before the first frame tick, so a
timer started from a constructor may never fire at all. Use `ENTER_FRAME` with a
`getTimer()` throttle for anything paced. Both [`Config`](../Config.as) and
[`Hub`](../Hub.as) do this.

**Button state changes are deferred.** `UIComponent.setState` only sets `_newFrame` and
calls `invalidate`; the `gotoAndStop` lands later, in `draw()`. So a mouse handler that
measures or repaints a button reads the *old* frame, and the new frame's art then swaps
in over the top of whatever you drew. Drive an overlay from `ENTER_FRAME` gated on
`currentFrame` changing, read the state from `currentFrameLabel`, and re-assert the
overlay with `setChildIndex` each time — a frame change re-adds the timeline children
above it.

**Iggy caches UI SWFs for the session.** Testing a new build means restarting Trove in
full. A hot swap shows you the old one.

## When a screen dies on load

You get nothing. No log, no error dialog, no partial render. The only channel out of a
dying SWF is the config file, because `OnSaveConfig` is handled engine-side and lands
on disk:

```actionscript
function report(key:String, what:String) : void
{
   ExternalInterface.call("UIComponent.OnSaveConfig", "myscreen.swf", key, what);
}

try { suspectCall(); report("probe_a", "ok"); }
catch(e:Error) { report("probe_a", e.message); }
```

Walk each suspect call in its own `try`, write one result per call, restart, and read
`%APPDATA%\Trove\ModCfgs\<Mod Title>.cfg`. One restart bisects the whole surface. It is
the only debugging technique that works in game, and it is worth building the probe
before you think you need it.

**But a config write is a record, never a trace.** One write per key, once. A probe
left inside a repaint fires on every stat, every update and every config key that
arrives, and the screen then dies on load with — again — nothing in any log. That
failure looked like everything except the probe for six test cycles.

## What does not work at all

- **`[Embed]`.** It generates an `mx.core.BitmapAsset`, and Iggy refuses to construct
  one. `new` on the generated class throws `IllegalOperationError` in game: a
  compile-time success and a runtime failure, and it fails *inside whatever called it*.
- **Art packed into your own `.tmod` and addressed as a texture.** Neither `.dds` nor
  `.png`, in any location.
- **`BitmapData` built in ActionScript.** Nothing draws.
- **`Loader.loadBytes` on embedded bytes.** Compiles, runs, draws nothing.
- **The whole of `flash.net`.** No HTTP, no sockets, no `SharedObject`. Measured in game
  with a probe that resolved each class through `getDefinitionByName` inside a `try`:

  ```
  tf=ok  dict=ok  vars=threw  ldr=threw  req=threw
  ```

  `flash.text.TextField` and `flash.utils.Dictionary` resolve, so the lookup itself works
  and the negatives are real: `URLRequest`, `URLLoader` and `URLVariables` are all absent.
  Do not be fooled by `iggy_w64.dll` - it carries the strings `URLLoader`, `URLRequest`
  and `flash.net`, and none of them are registered for ActionScript to reach. No Trove SWF
  and no mod uses them either; the only way out of a screen is `ExternalInterface`.

The one route that works is grafting the art out of a vanilla SWF into your build.
See [art.md](art.md).
