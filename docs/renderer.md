# Drawing

[`renderer`](../renderer.as) is the palette, the text helpers and the shape primitives.
Every control in `ui/` draws through it, so a colour arriving from a config file reaches
everything already on screen.

## The palette

Fifteen colours, and nothing else is settable:

```
panel  label  value  accent
red  danger  orange  yellow  green  purple
water  air  fire  cosmic
statlight
```

`renderer.KEYS` carries two more that are not colours - `outline` and `outlinecolor`,
under Text below - because they are the same thing to a config file and every mod seeds
the one list.

```actionscript
renderer.apply("accent", "#5FD3E8");   // from a config literal
renderer.colorOf("accent");            // back out
renderer.defaultOf("accent");          // what it holds now
renderer.stockOf("accent");            // what it was shipped as
renderer.KEYS;                         // all of them, for seeding
```

**One name per colour, never two.** There used to be aliases — `accent` and `cyan` naming
one colour, `yellow` and `gold` another — and each alias seeded into the file as its own
key. Trove relays a section one key per call, so on every load the second of a pair
arrived after the first and overwrote it: a chosen accent was saved correctly, then undone
by the untouched `cyan` line further down the same file. It looked exactly like the write
had failed.

**The greys are derived, not settable.** `PANEL2`, `RAISED`…`RAISED6`, `HEADER`, `ROW` and
`BORDER` are one colour at set lightnesses, measured off the stock palette rather than
invented. So a panel colour set by the player carries the whole screen with it instead of
leaving a header behind at the old shade. A key nothing reads is a key a player can set
and watch do nothing.

### Transparency lives in the top byte

A palette colour carries its own transparency, and the byte counts **down** from opaque —
zero is solid.

```
0x0F0B0C0E   →  #0B0C0E at 15/255 of transparency
0xFFFFFF     →  opaque white
```

That way every plain RGB literal already written into a screen is opaque by construction,
and no drawing call had to be rewritten to honour a translucent palette. The primitives
mask the byte off before it reaches the graphics call and fold it into the alpha.

### Quality bands

```actionscript
renderer.gradeFor(fraction);   // banded
renderer.rampFor(fraction);    // continuous
```

| range | |
|---|---|
| 0–30% | red |
| 30–50% | orange |
| 50–70% | yellow |
| 70–99% | green |
| 100% | cyan |

### Colour maths

```actionscript
renderer.hsv(hue, sat, val);        // → uint
renderer.hsvOf(color);              // → [h, s, v]
renderer.blend(from, to, t);
renderer.shade(color, percent);
renderer.lift(color, t);            // toward light
renderer.sink(color, percent);      // toward dark
```

## Text

```actionscript
var f:TextField = renderer.label(x, y, size, align, body, w, h, wrap, bold, spacing);
```

It sizes the field for its **line box**, which is the part that goes wrong by hand:
`height = size + 5` clips the text away entirely at 15pt and above, and it reads as a
font-size ceiling in the engine rather than as a clipped field.

No font is embedded. Iggy provides Open Sans out of the client's own `ui\fonts\`.

### The outline

`label()` puts `SHADOW` on every field it builds, which is a no-op - the panel behind the
text is what makes it readable. A screen whose text stands on the world needs a real one,
and says so:

```actionscript
renderer.stamp(field, [renderer.SHADE]);   // a hard copy one pixel under the glyph
renderer.stamp(field, zakros.INK);         // or whatever that screen tuned
```

`outline` (0-4, 0 is off) and `outlinecolor` then replace **whichever** baseline a field
was stamped with, and putting the outline away restores it. That is why the baseline is
kept per field rather than one for the suite: the three in use disagree, and a single
default would flatten two of them.

Fields stamped before the player turns it on are reached as well - `stamp()` records them
in a weak-keyed `Dictionary`, so a row built for a list that has since been discarded goes
with it. Anything built afterwards is stamped as it is made.

**A field with a deliberate filter of its own stays out of it.** World Tooltip's purple
glow on a biome name and Marketplace's two-directional stamp are not readability halos and
are not registered, so nothing here touches them.

| | |
|---|---|
| `deep(size, lines)` | The height a field of that many lines needs. |
| `pin(field, w, size)` | Fix a field to a width. |
| `centre(field, top, h)` | Centre vertically in a box. |
| `across(field, left, w)` | Centre horizontally. |
| `fit(field, wide, size, floor)` | Shrink the size until it fits, down to a floor. Returns what it settled on. |
| `elide(field, wide)` | Cut with an ellipsis. |
| `spacedOut(size, spacing)` | A centred, letter-spaced format. |
| `group(value)` / `groupText(body)` | Thousands separators. |
| `numbersIn(body)` | Separators applied to every number in a string. |
| `titleCase(body)` | |
| `tint(body, color)` | Wrap in `<font>`. |

**Avoid `htmlText`.** It discards the field's paragraph alignment, and it puts its content
in a paragraph box whose height is not the height of a line — so `textHeight` describes
something other than the words, and every rule for centring text is written in terms of
that measurement. Use one field per coloured piece; that is what [`ui.Run`](../ui/Run.as)
is.

## Shapes

Every one of these takes a target to draw into. **Pass a child `Shape`, not the control
itself** — see [pitfalls.md](pitfalls.md).

| | |
|---|---|
| `fill(target, x, y, w, h, color, alpha)` | |
| `framed(target, x, y, w, h, fill, border, weight)` | Fill and hairline in one. |
| `border(target, x, y, w, h, …)` | Hairline only. |
| `dashed(target, x, y, w, h, …)` | |
| `raised(target, x, y, w, h, …)` | The lifted plate face. |
| `accent(target, x, y, w, h)` | The single accent rule. |
| `vertical(target, x, y, w, h, …)` | Vertical gradient. |
| `triband(target, x, y, w, h, …)` | |
| `checker(target, x, y, w, h, …)` | The transparency checkerboard. |
| `disc(target, x, y, radius, …)` | |
| `pip(target, x, y, radius, …)` | Quality pips. |
| `noEntry(target, x, y, radius, …)` | |
| `flame(target, x, y, size, …)` | |
| `gear(target, x, y, color)` | The settings mark. |
| `hueStrip(target, x, y, w, h)` | The hue ramp for a colour picker. |
| `chaos(target, x, y, w, h)` | The full spectrum. |

## Icons

```actionscript
renderer.bindIcon(image, texture, size);
```

Binds a game texture path and reports whether art actually arrived — which is what lets a
caller put a word back rather than leave a button carrying a bare number. A path the game
does not have throws, and outside Iggy nothing binds at all.

This is for **texture paths only**. An item icon is an asynchronous render target and
needs the handshake in [`ui.ObjectPreview`](../ui/ObjectPreview.as). See
[iggy.md](iggy.md#textures-and-item-icons).

## The look

Dark, minimal, flat. A near-black panel, a slightly lighter header band, a hairline
border, and one accent rule. Muted grey for labels, bright for values. No gradients
except the one on a button face, no glows, no rounded-everything.

Nothing is hardcoded that a user might want to change.
