# Toolchain

Everything below runs on Windows, which is where Trove is.

## FFDec

[JPEXS Free Flash Decompiler](https://github.com/jindrapetrik/jpexs-decompiler). The
CLI is the useful half:

```bash
java -jar "C:\Program Files (x86)\FFDec\ffdec.jar" -export script <outdir> <in.swf>
```

That gives you the stock decompile of a screen: its class, its timeline children, its
callback list. Read it before you write anything.

Other invocations worth knowing:

```bash
ffdec.jar -dumpSWF <in.swf>
```

The real display list, including the art and the components Flash never gave an
instance name. **The decompiled source is not the display list** — a class only
declares the timeline children that were named, so unnamed art is placed on the
timeline and appears in no `.as` file at all. Restyling a screen by hiding the declared
variables leaves all of that still on screen.

```bash
ffdec.jar -format sprite:png -export sprite <outdir> <in.swf>
```

Writes `DefineSprite_<id>[_<name>]/<frame>.png`, one file per frame. This is how you
find out what art a SWF is carrying.

```bash
ffdec.jar -replace <in.swf> <out.swf> <scriptpath> <file.as>
```

Replaces one script. **It cannot add a script**, only replace one that is already
there, which is why helper classes have to go in file-scoped classes after the
`package` block rather than in files of their own.

Two more things about `-replace`:

- It refuses to compile a reference to a `protected` member. Use the public alias where
  there is one — `drawNow()` for `draw()`.
- A call to a method that does not exist compiles silently and fails at runtime. Check
  them yourself; the compiler will not.

Replace one script per invocation, chaining each output into the next.

## The compiler

You need `mxmlc` and a Flash Player 11.2 `playerglobal.swc`. **Adobe Animate 2024
bundles a full Flex 4.6 compiler**, which is the easiest one to get hold of if you
already have Animate:

```
<Animate>\Common\Configuration\ActionScript 3.0\bin\mxmlc.jar
<Animate>\Common\Configuration\ActionScript 3.0\FP11.2\playerglobal.swc
```

The bundled SDK is stripped of `flex-config.xml`, the Spark theme and the font
snapshot, so every default that reaches for one of them has to be blanked or the
compiler dies looking:

```bash
java -jar mxmlc.jar \
  -load-config= \
  -theme= \
  -compiler.fonts.local-fonts-snapshot= \
  -external-library-path=<...>/FP11.2/playerglobal.swc \
  -target-player=11.2 \
  -swf-version=15 \
  -default-size 601 502 \
  -default-frame-rate 24 \
  -default-background-color=0 \
  -static-link-runtime-shared-libraries=true \
  -source-path <your src> <path to KiwiZUI> \
  -output build/claims.swf \
  src/Claims.as
```

`-default-size` is the stage size the game's window expects for that screen. Take it
from the vanilla SWF. The SWF version is not load-bearing — Iggy has accepted v43 from
other mods — but the stage size is.

A standalone Flex SDK with the same `playerglobal` should work equally well; the flags
above are the ones verified against Animate's copy.

## Testing outside the game

The library gates every engine call on `IggyFunctions.inIggy`, which is false outside
Iggy, so a screen built on it runs under the standalone Flash debug player with the
engine parts skipped. That is the cheap half of testing: what a control reports and
what it makes of a config literal can be asserted without launching Trove at all.

Tracing needs `mm.cfg` in the user profile:

```
ErrorReportingEnable=1
TraceOutputFileEnable=1
```

Output then lands in `%APPDATA%\Macromedia\Flash Player\Logs\flashlog.txt`.

What this cannot check is drawing, and it cannot check anything Iggy does differently.
Compile `test/Gallery.as` and look at it.

## Packing a `.tmod`

A `.tmod` is a container of game-file overrides plus a header of properties. The
properties that matter:

| property | |
|---|---|
| `title` | The mod's name. The `.tmod` filename must match it, case included. |
| `author` | |
| `modVersion` | |
| `notes` | |
| `tags` | |
| `previewPath` | A packed image shown in the mod list. |
| `configPath` | The packed `.cfg`, which says which packed file is the config. |

Packed paths are lowercased, and only files under Trove's own top-level folders (`ui`,
`textures`, `models`, and the rest) are treated as overrides. So a screen ships as
`ui/<name>.swf`.

## Installing and testing

```
<Trove>\Live\mods\
<Trove>\PTS\mods\
```

Drop the `.tmod` in and restart Trove **in full**. Iggy caches UI SWFs for the session,
so a hot swap shows you the build you already had.

**Two mods that pack the same game file will conflict**, and which one wins is
arbitrary. There is no merge and no load order. If you are shipping a build tool, have
it read every other installed `.tmod` first and move any mod that packs a file you also
pack out of the folder — `<Trove>\mods_disabled\` beside it, never deleted. Trove only
scans `mods`, so moving is a complete removal as far as the game is concerned, and the
player keeps a mod they may have chosen deliberately.

## Verifying a build

Three things are worth proving before a build ships, and all three are automatable:

1. **Every class you did not target is byte-identical to the stock decompile.** A patch
   that quietly rewrote a class you were not editing is a patch that will break on the
   next game update in a way you cannot diagnose.
2. **Your own symbols are present in the build.** Decompile your own output and grep it
   for every callback name, every outbound call and every class the engine binds onto.
   The compiler proves the source is valid AS3; it cannot prove the SWF still speaks
   Iggy's protocol.
3. **The compile is a fixed point.** Recompiling the build's own decompiled source
   reproduces the build. Where it does not, something in your source compiles to
   bytecode that does not round-trip, and the difference is where a future port will go
   wrong.

Point 2 is the one that catches real failures. A callback you forgot to register is a
feature that stops working with no symptom at all, and a grep over your own decompile
is the only thing that finds it before a player does.
