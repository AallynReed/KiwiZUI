# KiwiZUI

A shared ActionScript 3 library for Trove UI mods, and the documentation for how
Trove's Flash UI actually works.

Trove renders its interface with Iggy, a Flash runtime that is not the Flash player.
Most of what you know about AS3 holds; the parts that do not will take a screen down
on load with nothing in any log to say why. This repository is the two halves of
working around that: a set of controls and helpers that already handle it, and a
written account of what was found the hard way.

Everything here is used in production by the Zakros UI mods. Take any of it.

## What is in it

| | |
|---|---|
| `IggyFunctions.as` | The declaration Iggy binds its natives onto. Every from-scratch SWF needs it. |
| `renderer.as` | Palette, text and drawing primitives. The whole visual system. |
| `Config.as` | Reading, seeding and writing `ModCfgs\<Mod Title>.cfg`. |
| `Hub.as` | Declaring your mod's settings so another screen can offer them. |
| `Api.as` | Answering instructions from other mods, on the same channel. |
| `Legacy.as` | Reading declarations written for Criteox's Mod Setting Manager. |
| `InsigniaArt.as` | The name a graft binds Trove's club insignia to, for `ui/Sigil`. |
| `GemReader.as` | Gem tier, level, quality and boost maths. |
| `Clock.as` | The wall clock, Trove's day and week resets, and durations in the game's own words. |
| `Rotations.as` | Which cycle of a weekly rotation is running, and when the next one starts. |
| `ui/` | 36 classes: controls, popups, item slots, tooltips and the helpers behind them. |
| `test/` | A gallery SWF that puts every control on one screen. |

## Documentation

Read [docs/iggy.md](docs/iggy.md) before writing any of it. It is the difference
between a screen that loads and a screen that does not.

- [The Iggy contract](docs/iggy.md) — how the engine talks to a SWF, and where it is not Flash
- [Toolchain](docs/toolchain.md) — FFDec, the compiler, the debug player, deploying a build
- [Building a screen](docs/screens.md) — from scratch, or by replacing a class in the vanilla SWF
- [Config files](docs/config.md) — the `ModCfgs` protocol, and how to seed defaults safely
- [The settings hub](docs/settings-hub.md) — make your mod's options appear in one shared screen
- [Commands between mods](docs/commands.md) — let another mod ask your screen to do something
- [Controls](docs/controls.md) — the `ui` package, control by control
- [Drawing](docs/renderer.md) — palette, text measurement, shapes
- [Art](docs/art.md) — getting Trove's own pictures into a from-scratch screen
- [Pitfalls](docs/pitfalls.md) — symptoms, and what each one turned out to be

## Using it

The library is plain source on a second source path. There is no SWC and nothing to
link, because a mod that patches a vanilla SWF cannot add scripts to it — the classes
have to compile into the same tree the screen's own code lives in.

```
-source-path <your src> <path to KiwiZUI>
```

Your own sources come first on that path, so **a class of yours with a library
class's name silently replaces it** — no warning, and the library keeps compiling
against its own copy while your screen gets yours. Two mods had done it before anyone
noticed. Check the names in the table above before you take one.

The root classes are in the unnamed package and the controls are in `ui`, matching
where Trove's own scripts sit. Nothing is namespaced, deliberately: `-replace` puts
your code where the SWF already has a script, and a package the SWF does not have is
a script you cannot add.

A screen then looks like this, in full:

```actionscript
package
{
   import flash.display.Sprite;
   import flash.external.ExternalInterface;
   import ui.*;

   public class MyScreen extends Sprite
   {
      private var cfg:Config = new Config("myscreen.swf");

      public function MyScreen()
      {
         super();
         if(IggyFunctions.inIggy)
         {
            ExternalInterface.addCallback("loadModConfiguration",this.onConfig);
         }
         this.cfg.watch(this,KEYS,defaultOf);
      }
   }
}
```

`IggyFunctions.inIggy` is `false` everywhere except in game, so the same build runs
under the standalone debug player with the engine calls skipped. That is what makes
the control gallery possible.

## Compatibility

Written against Trove's live client, Flash Player 11.2 target, SWF version 15. The
controls draw everything themselves and embed no fonts — Iggy provides Open Sans out
of the client's own `ui\fonts\`, so a screen built on this is a few kilobytes rather
than a few hundred.

## Contributing

Take it, change it, ship it. No credit needed and none wanted — the point of writing it
down was to stop the next person losing six restarts to the same bug.

If you find something Iggy does that is not written down here, a pull request against
`docs/` is worth more than anything else you could send back.

## Licence

[MIT-0](LICENSE). MIT with the attribution clause removed, so there is nothing to
carry into your own build.
