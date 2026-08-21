# Controls

Everything in the `ui` package. All of it draws itself — no timeline symbols, no embedded
art, no fonts.

## The shape every setting has

[`ui.Option`](../ui/Option.as) is the base. One setting is a name on the left and a
control on the right:

```
|<---------- nameRoom ---------->|<----- CTRL = 150 ----->|
  Claim delay                      [ 250 ▲▼ ]
```

Three members are the whole contract:

| | |
|---|---|
| `key` | The config key this control writes. |
| `literal` | The current value, as the literal that goes in the config file. |
| `from` | Set it from a literal that came out of one. |

That is what lets a screen hold one list and run both directions through the same reader
the config file goes through — a value set in the window and a value set in the file
cannot come to mean two different things.

**Nothing is applied from inside a control.** A control reports its key and its literal;
the screen decides what that means.

`Event.CHANGE` is dispatched when a value commits. **A control commits in steps, and one
step is one config write.** A slider says nothing until it is released; a text box says
nothing until it is ticked. A control that wrote continuously would take the screen down.

**A control with an empty key is a control and not a setting** — a search box, a filter
flag. It stays out of `sync()`, out of the config file and out of every write, and works
the same everywhere else.

### Keyboard

```actionscript
Option.watch(stage, true);
```

Turns on arrow-key handling for whichever control the pointer last pressed. Turn it off
when the controls come down. A held key repeats, so `stroke()` moves and repaints but does
not report — `settle()` reports once, when the run of keys ends.

## Settings

| | |
|---|---|
| [`Check`](../ui/Check.as) | A flag, as a box and a caption. |
| [`Slider`](../ui/Slider.as) | A number, dragged. No knob; the run of colour is the reading. One write per gesture. |
| [`Stepper`](../ui/Stepper.as) | A number, stepped rather than dragged, for values worth setting exactly. Reads a zero as a word — `Auto`, `Off`. |
| [`Spin`](../ui/Spin.as) | A number, stepped, nudged by the arrows, or typed straight in. A plain reading until it is clicked. |
| [`Input`](../ui/Input.as) | A typed-into box with a hint behind it and a cross to empty it. |
| [`Combo`](../ui/Combo.as) | One choice out of a list. |
| [`Multi`](../ui/Multi.as) | Any number of choices out of a list. The literal is the values joined by commas, so the file stays editable by hand. |
| [`Picker`](../ui/Picker.as) | A colour, off a square and a hue strip. Opaque. |
| [`AlphaPicker`](../ui/AlphaPicker.as) | The same with an opacity strip. Writes `#RRGGBBAA`, or `#RRGGBB` when fully opaque. |
| [`Heading`](../ui/Heading.as) | A section title. Not a setting. |
| [`Cat`](../ui/Cat.as) | A foldable category. Not a setting. |

`Stepper` and `Spin` stay separate on purpose: `Stepper` reads a zero as a word, and a box
that can be typed into cannot also mean that — the digit and the word would be two answers
to the same question.

`Input` dispatches `TYPING` on every keystroke and `CHANGE` only on the tick or on leaving
the field. A box that filters a list wants every keystroke; a box that sets a config key
must not have one.

## Buttons

| | |
|---|---|
| [`Button`](../ui/Button.as) | A plate with a vertical gradient, pressed by flipping the gradient over. Latching is the same class with a mode. |
| [`Chip`](../ui/Chip.as) | One hairline rectangle and a tracked word. Nothing raised, nothing moves. |
| [`Plate`](../ui/Plate.as) | The flat plate underneath both. Repaints out of the palette, so a colour arriving from config reaches every button already on screen. |

`Button` and `Chip` are not variants: a plate says *push me* through depth, a chip says it
through weight, and a screen that mixes the two reads as two screens. Pick one per screen.

## Items and art

| | |
|---|---|
| [`Slot`](../ui/Slot.as) | One item square: rarity-coloured frame, the item's icon, quality pips. |
| [`ObjectPreview`](../ui/ObjectPreview.as) | The `CheckTextureExists` → `objectPreviewReady` handshake. |
| [`Icon`](../ui/Icon.as) | A bitmap that knows which game texture it is showing, and reports whether the art actually arrived. |
| [`Art`](../ui/Art.as) | A symbol grafted into the SWF's own tag stream. See [art.md](art.md). |
| [`SlotDragDropHelper`](../ui/SlotDragDropHelper.as) | Drag between slots. |

**Most of what is public on `Slot` has no caller in this repository, and that is the
point.** The engine drives a slot by writing its properties from the outside, the same way
it calls a screen by callback name. The set comes from the stock decompile, so a property
missing there is an item that silently never appears. Nothing in it may be deleted for
looking unused.

## Structure

| | |
|---|---|
| [`Settings`](../ui/Settings.as) | The options panel: a list of `Option`s, scrolled, with the commit rules already in it. |
| [`Manager`](../ui/Manager.as) | The settings hub screen. Mods on the left, that mod's options on the right. See [settings-hub.md](settings-hub.md). |
| [`Tab`](../ui/Tab.as) | The narrow strip down the side of a screen that switches between them. |
| [`Notice`](../ui/Notice.as) | The panel that says there is no `.cfg` in `ModCfgs\`, so nothing is being kept. |
| [`Bar`](../ui/Bar.as) | A track with a filled run and a reading beside it. |
| [`Run`](../ui/Run.as) | A row of differently coloured words and numbers against a fixed right edge. One field per piece, never markup. |
| [`Layer`](../ui/Layer.as) | Lifts a popup to the screen root, over an invisible sheet that closes it wherever else the next click lands. |
| [`Find`](../ui/Find.as) | Walks up from a click target to the slot, card or button it belongs to. |
| [`Tip`](../ui/Tip.as) | Where a tooltip anchor goes so the engine does not open it across the window that asked for it. |

`Layer` exists because a control sits too deep in the tree to manage drawing over
everything from where it is: siblings added after it cover it, and the panel it lives in
clips it. One popup at a time, and the control learns it was closed from
`REMOVED_FROM_STAGE` rather than from a callback.

`Tip` reserves 450 pixels to the left, which is `tooltip.swf`'s own `minWidth`. Only a
tooltip's *name* line can widen it past that, so all but a very long name comes out at
exactly the floor. Reserving the widest it can get — 658 — opened tooltips two hundred
pixels clear of the window with nothing in between. The trade is deliberate.

## Drawing your own

Draw into a **child `Shape`**, never into a control's own `graphics`. Iggy measures a
sprite by its children, and a control that measures zero captures the clicks around it.
A mark goes **above** the box, because a sprite's own graphics render below its children.

[pitfalls.md](pitfalls.md) has the full account. It is the single most expensive thing in
this repository.

## Seeing them

`test/Gallery.as` puts every control on one screen. Compile it against the library and
open it in the standalone debug player — no Trove involved:

```bash
java -jar mxmlc.jar -load-config= -theme= -compiler.fonts.local-fonts-snapshot= \
  -external-library-path=<...>/playerglobal.swc \
  -target-player=11.2 -swf-version=15 -default-size 760 700 -debug=true \
  -source-path test . -output gallery.swf test/Gallery.as
```

The `test` path has to come first: `Gallery.as` is in the unnamed package, so the
directory holding it has to be a source root in its own right.
