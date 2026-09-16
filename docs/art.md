# Art

**Iggy draws the art a SWF carries in its own tag stream, and nothing a mod hands it at
runtime.** If a from-scratch screen needs a picture, graft the characters out of a
vanilla SWF into the build. Do not embed it, decode it, fetch it by path, or pack it as
a game file — all four were tried in game and all four are dead ends.

## What was proven

Six routes were put on screen side by side in one build, each in its own `try`, and
exactly one drew:

| | route | drew |
|---|---|---|
| A | `ui/meta_icons/meta_cubit.dds` by texture path | **yes** |
| B | `ui/meta_icons/meta_credit.dds` by texture path | no |
| C | `ui/<mine>.dds` packed into our own `.tmod` | no |
| D | `ui/<mine>.png` packed into our own `.tmod` | no |
| E | `BitmapData` built in ActionScript | no |
| F | `Loader.loadBytes` on an embedded PNG | no |

Read across it:

- **A texture path only resolves for art the game has already loaded.** `meta_credit.dds`
  is in the client — `ui/meta_icons/index.tfi` lists it beside `meta_cubit.dds`, and the
  two files are byte-identical in header — it is simply never resident. Retrying the bind
  for five seconds and sending `UIComponent.CheckTextureExists` changed nothing. A only
  worked because the screen under test loads that particular cube.
- **A file packed into your own `.tmod` is not addressable as a texture**, in either
  format. D is the proof rather than C: that PNG is the game's own file, unmodified, so
  the failure cannot be blamed on the encoding.
- **`[Embed]` is worse than useless.** It generates an `mx.core` asset, and Iggy will not
  construct one — a compile-time success and a runtime failure that takes its caller down
  with it.
- **The art is usually already in the SWF you are replacing.** Look there first.

## Finding the art

A class only declares the timeline children Flash gave an instance name, so art with no
name appears in no decompiled `.as` at all. Read the tags, not the source:

```bash
ffdec.jar -dumpSWF ui/<screen>.swf > dump.txt
```

Then look at what the character ids actually are, rather than guessing from names:

```bash
ffdec.jar -format image:png -export image ./img ui/<screen>.swf
ffdec.jar -format shape:png -export shape ./shp ui/<screen>.swf
```

On `cornerstone.swf` that gave: **68** and **69** are `DefineBitsLossless2` 24x24, the
gold cubit cube and the prismatic credit cube; **70** is a `DefineShape2` whose two fills
are those bitmaps — one unnamed shape holding both cubes, credit hard left and cubit hard
right, placed at depth 70 in frame 1 of `cornerstone_entry_3`.

## The graft

Binary surgery on your own compiled SWF, run after the compiler and before anything
reads the build:

1. Pull the character tags out of the vanilla SWF — the bitmaps, and the shape whose
   fills reference them.
2. Check the ids do not collide with your compiled SWF's own. A from-scratch mxmlc build
   defines **no characters at all**, so in practice the vanilla ids copy across untouched
   and nothing needs remapping. Fail the build if that ever stops being true.
3. Add a `DefineSprite` that places the shape. A bare bitmap character cannot be bound to
   a class; only a sprite can.
4. Append an entry to the existing `SymbolClass` tag binding that sprite to a class name.
   Keep the compiler's own entry (character 0 to the document class).
5. Recompress, and rewrite the header length.

The ActionScript side is an empty class with the bound name:

```actionscript
public class CurrencyArt extends MovieClip
{
   public function CurrencyArt() { super(); }
}
```

Constructing it hands back the art. Where one character holds several pictures, crop with
`scrollRect` — it clips and shifts in one go, so the wanted part lands on the container's
own origin. Measure the crop off `getBounds()` rather than writing coordinates down, so a
re-port that moves the art is followed without an edit.

Export the sprite back out of your own build afterwards and fail unless it is there and
bound. The graft is binary surgery; read the result back rather than trusting it.

[`ui.Art`](../ui/Art.as) is the display side: it holds the symbol class as a field and
constructs it inside a `try`, because a class the graft did not bind is a compile-time
success and a runtime throw — and a throw there would take down whichever repaint it
happened in.

## Why not just use `-replace`

The obvious answer to "use the vanilla assets" is to stop building from scratch and
replace the class inside the vanilla SWF instead.

That does not work for a screen using this control set. **FFDec's compiler cannot resolve
a file-scoped class as a base class**, and `-replace` can only ever add file-scoped
classes. `Check`, `Picker` and `Input` all extend `Option`, and `AlphaPicker` extends
`Picker`, so the compile dies on `Option is not an existing type`. A mod that bundles only
standalone classes gets away with `-replace`; one with a class hierarchy does not.

Grafting the characters keeps the from-scratch build and the control tree intact, and is
a much smaller change than flattening a hierarchy.

## Testing it without the game

The standalone player constructs a grafted symbol perfectly well — it is a real SWF
symbol, and Iggy is not involved. Graft the same characters into your preview harness and
the icons appear there, which is the whole check short of a restart.

Two things the harness will not tell you, both of which cost a cycle:

- `trace()` is stripped unless the compiler is given **`-debug=true`**. Without it
  `flashlog.txt` stays empty while the player still logs uncaught errors, which reads
  exactly like the code never ran.
- `Loader.loadBytes` fails locally with `Error #2148`, a local-file sandbox rule that does
  not exist in Iggy. Add the directory to
  `%APPDATA%\Macromedia\Flash Player\#Security\FlashPlayerTrust\`.

## The rule

Never redraw art the game already has. It was drawn to mean something, and a substitute
is a guess wearing the same shape. If it cannot be grafted, use words.
