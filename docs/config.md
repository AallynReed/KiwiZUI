# Config files

Trove keeps a mod's settings in:

```
%APPDATA%\Trove\ModCfgs\<Mod Title>.cfg
```

An INI file with one `[<swf name>]` section per SWF the mod patches.

```ini
[claims.swf]
autoclaim=1
delay=250
panel=#0B0C0E
```

## The protocol

**Reading.** Register a callback and Trove relays your section back, one key per call:

```actionscript
ExternalInterface.addCallback("loadModConfiguration", this.onConfig);
```

**Writing.**

```actionscript
ExternalInterface.call("UIComponent.OnSaveConfig", "claims.swf", key, value);
```

That is the whole surface. Everything below is what it does that you would not expect.

## The rules

**Keys arrive lowercased.** Compare against lowercase literals.

**A dot in a key makes a section.** Writing `probe.texture` produced both
`probe.texture` under the real section *and* a stray `[probe]` section containing
`texture`. Keep keys flat.

**Never write from inside the read handler.** The write is relayed straight back in as
another config key, which calls the handler, which writes. The mod spins on itself until
it dies.

**Every write is echoed back.** `OnSaveConfig` is relayed in as though the player had set
it. A screen that repaints on each arriving key repaints for news it made up itself —
once for every key it seeded and once for every probe. On a heavy screen that is a
visible hitch a few seconds after opening.

**A write is a record, never a trace.** One write per key, once. Anything that writes
continuously — a slider that saves as it drags, a probe inside a repaint — takes the
screen down on load with nothing in any log.

**The mod cannot create the file.** `OnSaveConfig` only populates keys in a `.cfg` that
already exists in `ModCfgs\`. With no file there, nothing the mod does brings one into
being. It is put there by a mod manager that extracts the packed copy, or by the player.

**Trove rewrites `ModCfgs\` as it exits**, over whatever is there. A file dropped in
while the game is running is overwritten by the copy the running client is holding.

## Seeding defaults

You can fill in keys missing from a file that *is* there. Do it per key:

**Record which keys came back, then write only the ones that did not.** Gating the whole
write behind a single sentinel key means every option you add after a player's first run
is never written, so it stays absent from their file and undiscoverable. Per-key seeding
self-heals as the key list grows.

## `Config.as`

The class does all of the above.

```actionscript
private var cfg:Config = new Config("claims.swf");

public function MyScreen()
{
   super();
   if(IggyFunctions.inIggy)
   {
      ExternalInterface.addCallback("loadModConfiguration", this.onConfig);
   }
   this.cfg.watch(this, KEYS, this.defaultOf, this.onConfigMissing);
}

private function onConfig(key:String, value:String) : void
{
   var k:String = this.cfg.note(key, value);
   if(k == Config.PROBE)
   {
      return;
   }
   this.apply(k, value);
   this.repaint();
}
```

`watch()` is armed once from the constructor and does three things on `ENTER_FRAME` —
not a `Timer`, because callbacks can arrive before the first frame tick and a timer
started that early may never fire at all:

1. Waits a beat past the first key that arrives, then seeds whatever did not.
2. Writes a probe key and waits for it to come back, which is the only way to find out
   whether there is a `.cfg` at all. Up to three times across four seconds — the outbound
   bridge comes up silently, so one unanswered probe means nothing.
3. Calls your `missing` handler once if it never comes back.

### The surface

| | |
|---|---|
| `new Config(section)` | `section` is the SWF name, e.g. `"claims.swf"`. |
| `mirror(section)` | Another section to keep in step. Trove gives each SWF its own section and lets neither read the other's, so a setting two screens share is written to both. |
| `note(key, value)` | Record a key as present. Returns the lowercase key to compare on, or `Config.PROBE` if this was the echo of your own write — return on that. |
| `save(key, value)` | One write. No-op outside Iggy. |
| `seedMissing(keys, defaultFor)` | Writes only what never came back. Returns how many. |
| `watch(screen, keys, defaultFor, missing)` | All of the above, paced. |
| `saw(key)` | Did this key arrive. |
| `confirmed` | The probe came back, so there is a file and a write to it is kept. |

`note()` swallowing the echo is what keeps a screen from repainting for its own writes.
Only the first echo of each value — a value that matches by coincidence later is the
player's.

### Reading and writing literals

The same literals go in the file, in the settings window and over the hub, so a value set
one way and a value set another cannot come to mean different things.

| | |
|---|---|
| `Config.hex(color)` | `0x0B0C0E` to `#0B0C0E`. |
| `Config.hexa(color, alpha)` | `#RRGGBBAA`, or `#RRGGBB` when fully opaque. |
| `Config.color(raw, fallback)` | Back to a `uint`, taking either form. |
| `Config.alpha(raw, fallback)` | The alpha out of an eight-digit value. |
| `Config.flag(raw)` | `1` / `0`. |
| `Config.number(raw, low, high, fallback)` | Parsed and clamped. |
| `Config.clamp(value, low, high, fallback)` | Clamped. |
| `Config.pair(value)` | Two-digit. |

A plain colour setting writes `#RRGGBB`, so a file that never touches transparency reads
exactly as it always did, and a control handed an eight-digit value takes the colour and
ignores the rest.

## Shipping a default `.cfg`

Pack `<Mod Title>.cfg` into the `.tmod` at `ui/<mod title>.cfg`, lowercased, and name it
in the `configPath` header property. That property is what says which packed file is the
config.

**Trove does not install it.** Packed files are game-file overrides, and a config belongs
in `ModCfgs\`, so this copy is inert in game. A mod manager extracts it and puts it
there; anyone else copies it across by hand. Nothing in the mod does this for them.

It is still worth packing, because it is the only copy a player can get hold of at all.

**Do not put a `seeded` sentinel in the shipped file.** With it, the mod skips seeding, so
any option added in a later version never reaches that user.
