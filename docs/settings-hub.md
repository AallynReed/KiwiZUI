# The settings hub

One screen that offers every mod's options, so a player does not have to find and edit
a `.cfg` per mod. Your mod declares what it has; the hub builds the controls out of that
declaration and writes changes back to you.

Nothing in the hub knows any mod but the one whose declaration it is reading. A mod
written after it still appears in it, and a mod uninstalled tomorrow costs nothing to
take out.

## How two mods can talk at all

`OnSaveConfig` is addressed **by SWF, not by caller**. A write naming a section lands in
the `.cfg` of whichever mod packs that SWF, and Trove relays it back to that mod through
its own `loadModConfiguration`.

```actionscript
ExternalInterface.call("UIComponent.OnSaveConfig", "likedworlds.swf", key, value);
```

That is the only channel between two mods there is. Nothing can *ask* for a section that
is not its own — it can only write into one.

The hub's address is `likedworlds.swf`.

## Declaring, the short way

If you are compiling against this library, use [`Hub`](../Hub.as):

```actionscript
this.hub = new Hub("claims.swf", "Zakros UI - Claims Manager", this.hubValue, "Claims")
   .readme("Everything waiting to be claimed, in one list you can work down.")
   .option("autoclaim", Hub.CHECK, "Claim automatically", "",
           "Takes each claim as it arrives instead of waiting for you.")
   .option("delay", Hub.SPIN, "Claim delay", "50,10000,50,0,,ms",
           "How long to wait between automatic claims.")
   .option("panel", Hub.ALPHA, "Panel color", "",
           "Background of the window, with its opacity.");

this.hub.watch(this);
```

`hubValue(key)` returns the current literal for a key — the same literal that goes in
your config file. `watch()` arms it and republishes whenever a value changes.

Publishing waits a beat, on `ENTER_FRAME`: `ExternalInterface.call` goes nowhere until
Iggy has wired the bridge, silently, so a declaration made from a constructor is lost.

It waits again after that. `publish()` marks the declaration rather than writing it,
and the beat writes 1.5s after the last change - so changing a setting is one config
write, the setting itself, and a run of changes is one record at the end of it. Trove
rewrites the whole `.cfg` for a single key and the hub's file holds every mod's
declaration, so the record costs more than the setting does.

## Declaring, without the library

One write, under a key prefixed `zm_`, with the whole declaration as the value:

```
key:    zm_<flattened mod title>__<flattened swf stem>
value:  3|<swf>|<Mod Title>|<group>|<readme>|<option>|<option>|…
```

Each option is six fields separated by `~`:

```
key~type~label~value~params~note
```

**One key per mod, never one per setting.** Every option goes in a single value, so
adding a settings page costs one config write rather than twenty. `OnSaveConfig` is a
record, and a screen that traces through it dies on load.

The key carries the SWF as well as the mod because a mod with two screens declares twice,
and a key naming only the mod would have the second statement land on top of the first.

### Fields

| | |
|---|---|
| `swf` | Your section — the SWF this set of options belongs to. Changes are addressed back here. |
| `Mod Title` | Shown as one entry however many screens you declare. |
| `group` | The screen these options belong to, in words. Left empty, the SWF filename is used. |
| `readme` | What the mod is and how it is meant to be used, in your own words. Shown instead of the controls when the reader asks for it. |

### Types

| type | params |
|---|---|
| `check` | — |
| `slider` | `min,max,step,places,zero,suffix` |
| `spin` | `min,max,step,places,zero,suffix` |
| `stepper` | `min,max,step,places,zero,suffix` |
| `combo` | `value=Label,value=Label,…` |
| `color` | — |
| `alpha` | — |
| `input` | maximum length |
| `heading` | — (not a setting; a title and a rule) |

`zero` is the word shown in place of a zero — `Auto`, `Off`. `suffix` is the unit. Neither
may contain a comma, which is the one thing the range list cannot spell.

A `combo` label is free text, so only the first `=` splits a pair, and a choice with no
`=` stands for itself.

### Escaping

The separators have to survive a label that contains one. Backslash first, or unescaping
turns an escaped backslash back into an escape.

| | |
|---|---|
| `\` | `\\` |
| `\|` | `\p` |
| `~` | `\s` |
| newline | `\n` |

Line breaks in a readme travel escaped because a real newline would end the value and take
the rest of the readme with it.

### Values

The value in a declaration is the same literal your config file carries. That way a value
set in the hub and a value set by hand in the file cannot come to mean different things,
and the hub can hand one straight back with no conversion in between. See
[config.md](config.md#reading-and-writing-literals).

## Receiving a change

The hub writes to your section, exactly as if the player had edited the file:

```actionscript
ExternalInterface.call("UIComponent.OnSaveConfig", yourSwf, key, value);
```

It arrives through your own `loadModConfiguration`. There is nothing extra to implement —
if your mod already reads its config, it already accepts changes from the hub.

## Older formats

`Hub.parse` reads versions 1 and 2 as well as 3. A declaration is written by another mod
and sits stale in the file until that mod next runs, so a hub that understood only the
newest format would drop every mod that had not been rebuilt.

It also reads [Criteox's Mod Setting Manager](../Legacy.as) format, so a mod already
wired for that hub appears in this one with nothing asked of its author:

```
{'modname':'X','file':'y.swf','settings':{'k':{'type':'checkbox','title':'T',
 'description':'D','value':'true'}}}
```

Its value dialect is its own — a flag is `'true'`/`'false'` where ours is `1`/`0` — so
each parsed option carries how to write it back. A hub that handed a legacy mod our
literal would silently turn every one of its flags off.

That format has no escaping anywhere, so a quote inside a label breaks it at the writing
end. `Legacy.parse` refuses rather than throws: a malformed declaration from someone
else's mod must not take the reading screen down with it.
