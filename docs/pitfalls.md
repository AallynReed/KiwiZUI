# Pitfalls

Each of these cost at least one game restart, and several cost six. They are written
symptom first, because the symptom is what you will have.

---

## A button with no caption eats every click around it

**Symptom.** Clicking anywhere along the window header opens the settings panel. The
sort buttons and the close button do nothing at all. Hovering anywhere along the header
lights the settings button up. The screen renders correctly the whole time — only input
is wrong.

**Cause.** Iggy measures a sprite by its children and does not count the sprite's own
`graphics`.

A control that draws its face straight into `this.graphics` and has no children measures
zero wide. Every button that carries a word also has a caption `TextField` child, so it
measures correctly by accident. The one button whose face is a drawn mark rather than a
word has an empty caption and no child with any size.

In game it measured `w0 h26` — zero wide, the 26 of height coming from the empty caption
alone. Its captioned neighbour, built from the same class with the same arguments on the
adjacent line, measured 26x26. Under the standalone debug player, the same source and
the same data gave 26x26 for both. That is what proved the difference was Iggy's.

**And a control Iggy measures as zero does not merely fail to receive its own clicks —
it captures the clicks around it.** One silent button ate a header.

**Fix.** Three parts.

1. **Draw into a child `Shape`, never into `this.graphics`.** `ui.Plate`, `ui.Button`
   and `ui.Tab` all do this now. `ui.Button` was believed safe for a while because it
   drew its gradient into a child — but its *frame* went into `this.graphics`, so a
   caption-less Button measured by the gradient alone and repeated the entire bug on two
   more screens. `ui.Tab` had no children at all and measured zero outright. **Do not
   trust a claim that a class is already safe. Grep for `renderer.framed(this,` and
   `renderer.fill(this,` and look.**

2. **Resolve header clicks by coordinate.** One `CLICK` listener on the screen reads
   `globalToLocal(stageX, stageY)` and decides which control was hit from the rectangles
   the layout used. Build those rectangles from each button's `x`/`y` and the size it
   was **constructed** at — never from `width`/`height`, which is the number Iggy gets
   wrong.

3. **Resolve hover the same way.** Read it on `ENTER_FRAME` from `this.mouseX` /
   `this.mouseY`, through the same mapping the clicks use, so the lit button and the
   clickable button cannot disagree.

**A mark goes above the box.** A sprite's own `graphics` render below its children, so a
mark left in `graphics` is buried by the box you just added. That regression cost the
settings button its icon for a build.

**Two things that broke input completely**, both attempted while fixing this:

- **Do not add a mouse listener at the root.** A `MOUSE_MOVE` handler on the screen
  stopped Iggy delivering clicks anywhere on that screen.
- **Do not take the mouse off a control.** `mouseEnabled = false` on the header plates
  did the same.

Either alone kills every click in the window. Reading the pointer on the frame tick needs
no listener and no event delivery, and its worst case is a highlight that does not light.

---

## A control loses its next press after the list is rebuilt

**Symptom.** A button or a checkbox on a list row does nothing the first time it is
pressed. Press it again and it works. Reopen the window and the first press is dead
again, on every row. Reads exactly like a hit test that is off by a few pixels, and no
amount of fixing the geometry changes it.

**Cause.** Iggy has to find a display object again after it is added to the display list,
and until it has, it will not aim the pointer at it. A layout pass that empties its
container and re-adds every row therefore costs every control on screen its next press.
Where the list rebuilds in response to engine updates, that is most presses.

**Fix.** Move rows, do not re-add them. Remove only what has left the list, add only what
is new, and set `x`/`y` on the rest. Depth usually does not need restoring - list rows do
not overlap, so nothing reads it.

**It is not the click, and it is not the hit test.** Both were tried first here. Moving
the handler to `MOUSE_DOWN` does nothing, because no event is dispatched at all; and the
coordinates were right the whole time. Check whether the container is being emptied before
looking anywhere else.

---

## A control on a list takes two presses

**Symptom.** A button or a checkbox on a list row does nothing on the first press and
works on the second. Reads exactly like a hit test that is off by a few pixels, and every
attempt to fix the geometry changes nothing.

**Cause.** `CLICK` is a matched `MOUSE_DOWN` and `MOUSE_UP` on the one control. A list
that re-places its rows in response to engine updates moves the row out from under the
pointer between the two, and no click is ever made. The Activity Tracker rebuilds a frame
after any update and its activities carry clocks, so updates never stop arriving.

**Fix.** Act on `MOUSE_DOWN`. It is delivered on its own and cannot be dropped by a
re-layout, and a control that responds on the press feels immediate rather than late.

Rows that never move may stay on `CLICK`. Anything on a list that re-places itself may
not.

---

## The screen dies on load and nothing is logged

**Symptom.** The window opens blank, or does not open. No error, no log line, nowhere.

**Cause.** Some call Iggy rejects. It could be anything, and the last thing you changed
is usually not it.

**Fix.** Build a probe. Walk each suspect call in its own `try/catch` and write the
result through `UIComponent.OnSaveConfig` — the config file is the only channel out of a
SWF that survives a crash. One restart bisects the whole surface. See
[iggy.md](iggy.md#when-a-screen-dies-on-load).

---

## The screen dies on load, and the probe is the reason

**Symptom.** The same blank window, after adding the probe that was supposed to diagnose
the blank window.

**Cause.** `OnSaveConfig` is not free, and spamming it kills the screen. A report left
inside a repaint fires on every stat, every update and every config key that arrives.

**Fix.** One write per key, once. A config write is a record, never a trace.

This cost six test cycles and four wrong diagnoses, because the probe looked like the
one thing that could not be the culprit.

---

## The mod writes its config and then spins until it dies

**Symptom.** The screen loads, then hangs.

**Cause.** A write made from inside the `loadModConfiguration` handler. Trove relays the
write straight back in as another config key, which calls the handler, which writes.

**Fix.** Never write from inside the read handler. Seed from a later beat —
[`Config.watch()`](../Config.as) paces it on `ENTER_FRAME`.

---

## An option added in v2 never appears in anyone's config file

**Symptom.** New settings are invisible and undiscoverable for every player who ran the
previous version. A fresh install is fine.

**Cause.** Seeding gated behind a single sentinel key. The sentinel arrived, so the whole
seed was skipped, so the new key was never written.

**Fix.** Seed per key. Record which keys came back and write only the ones that did not.
That self-heals as the key list grows. See [config.md](config.md).

---

## A config key produces a stray section in the `.cfg`

**Symptom.** Writing `probe.texture` produced both `probe.texture` under the real section
*and* a stray `[probe]` section with `texture` in it.

**Cause.** Trove splits a dotted key into a section.

**Fix.** Keep keys flat.

---

## A key comparison never matches

**Cause.** Keys arrive lowercased.

**Fix.** Compare against lowercase literals. `Config.note()` hands back the lowercase
form for exactly this.

---

## Text renders nothing at 15pt and above

**Symptom.** Looks like a font-size ceiling in the engine. It is not.

**Cause.** `height = size + 5` on the `TextField`. The line box is taller than that, so
the text is clipped away entirely.

**Fix.** `height = size * 2`, or set `autoSize`. `renderer.label()` handles it.

---

## A right-aligned field renders left

**Cause.** `htmlText` discards the field's paragraph alignment.

**Fix.** Put the alignment in the markup (`<p align="right">`), or use `.text` with
`setTextFormat`.

---

## Centred text sits in the wrong place

**Cause.** `htmlText` puts its content in a paragraph box whose height is not the height
of a line, so `textHeight` describes something other than the words.

**Fix.** One field per coloured piece — [`ui.Run`](../ui/Run.as) — rather than one field
of markup.

---

## An item slot stays blank forever

**Cause.** `setTextureForBitmap` called directly on an item icon. An icon is an
asynchronous render target, not a texture; the call throws `ArgumentError` and the slot
never recovers.

**Fix.** The `CheckTextureExists` → `objectPreviewReady` handshake, and register
`objectPreviewReady` explicitly — it is in no individual screen's callback list. See
[iggy.md](iggy.md#textures-and-item-icons).

---

## An icon loads at the wrong size

**Cause.** `setTextureForBitmap(bmp, name, 48, 48)` does not scale anything; the size
comes from the file. It produced a 24x24 bitmap.

**Fix.** Set `bmp.width` and `bmp.height` after the load.

---

## A `Timer` started at construction never fires

**Cause.** Callbacks can arrive before the first frame tick.

**Fix.** `ENTER_FRAME` with a `getTimer()` throttle, for anything paced.

---

## An overlay on a button disappears when the button changes state

**Cause.** `UIComponent.setState` only sets `_newFrame` and calls `invalidate`; the
`gotoAndStop` lands later in `draw()`. A frame change re-adds the timeline children above
your overlay.

**Fix.** Drive the overlay from `ENTER_FRAME` gated on `currentFrame` changing, read the
state from `currentFrameLabel`, and re-assert with `setChildIndex` each time.

---

## Restyling a screen leaves half of it on screen

**Cause.** The decompiled source is not the display list. A class only declares the
timeline children Flash gave an instance name; unnamed art and unnamed components appear
in no `.as` at all.

**Fix.** Read the real list with `-dumpSWF`, and sweep by *type* (`kid is Shape`,
`kid is WindowCloseButton`), never by depth number — depths renumber across updates.

---

## The new build behaves exactly like the old one

**Cause.** Iggy caches UI SWFs for the session.

**Fix.** Restart Trove in full. A hot swap shows nothing.

---

## The compile succeeds and the method does not exist

**Cause.** FFDec compiles a call to a method that is not there, silently. It fails at
runtime, which for Iggy means the screen dies with nothing logged.

**Fix.** Check them yourself. Also: FFDec will not compile a reference to a `protected`
member, so use the public alias where there is one — `drawNow()` for `draw()`.

---

## `trace()` produces nothing under the debug player

**Cause.** Traces are stripped from release builds, and the player only writes the log
when told to by a file.

**Fix.** Compile with `-debug=true` (and `-compiler.omit-trace-statements=false`), and
put `mm.cfg` in the user profile with `TraceOutputFileEnable=1`. Output goes to
`%APPDATA%\Macromedia\Flash Player\Logs\flashlog.txt`.

Run the player in the foreground. Backgrounding the launcher kills it with the shell
before it writes anything.

---

## `Loader.loadBytes` fails locally with Error #2148

**Cause.** A local-file sandbox rule in the standalone player. It does not exist in Iggy.

**Fix.** Add the directory to `%APPDATA%\Macromedia\Flash Player\#Security\FlashPlayerTrust\`.

---

## Two mods patch the same file and the wrong one wins

**Cause.** Trove loads both and which one wins is arbitrary. There is no merge and no
load order.

**Fix.** There is no fix at runtime. Detect it at install time: read every installed
`.tmod`, and move any mod that packs a file you also pack into `<Trove>\mods_disabled\`
before installing. Trove only scans `mods`, so that is a complete removal as far as the
game is concerned, and the player keeps the mod.

---

## Half a screen lays out and the rest piles up in one corner

Iggy throws on reading a property an object does not have. The standalone player hands
back `undefined`, so the harness is silent and the game is not.

That makes an object literal a contract. `Legacy.parse` built its record without
`readme`, which `Hub.ours` always sets; `Manager.paint` read `record.readme` between
placing the close button and placing the readme button, and everything from that line on
- the second button, the mod list, the whole row layout - simply did not run. What you
see is the half that got done, and no error anywhere.

Two things follow. Every builder of a shared record sets **every** field, including the
ones its format has nothing to say about. And a paint routine settles positions before it
draws, so a throw costs one row's appearance rather than the position of every row after
it - which is what makes the difference visible enough to locate.

---

## The lesson under most of these

Build the out-of-game harness first. Animate ships a debug player that runs the SWF with
no Trove involved:

```
<Animate>\Players\Debug\FlashPlayerDebugger.exe
```

It builds the real screen, feeds it real data, dispatches `MouseEvent.CLICK` at real
coordinates, and traces what changed. That answers a question in seconds. The config
channel is minutes and a restart, and is only worth reaching for when something does not
reproduce in the harness — which, so far, is Iggy's hit testing and nothing else.

The header bug above was found across six game restarts. With the harness first it would
have been one.
