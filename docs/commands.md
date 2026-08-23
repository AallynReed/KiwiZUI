# Commands between mods

The settings hub carries a setting from one mod to another. The same channel carries an
instruction, and that is all a mod API is:

```actionscript
ExternalInterface.call("UIComponent.OnSaveConfig", "navigationmenu.swf",
                       "open", "inventory");
```

`OnSaveConfig` is addressed by SWF and not by caller, so that write lands in the `.cfg`
of whichever mod packs `navigationmenu.swf` and Trove relays it back to that mod through
its own `loadModConfiguration`. The mod reads `open` as an instruction and opens the
inventory. Nothing else in Iggy connects two mods — see
[settings-hub.md](settings-hub.md#how-two-mods-can-talk-at-all).

[`Api`](../Api.as) is the receiving half: commands, listeners, and the timing that keeps
the load from being read as a caller.

## Answering commands

```actionscript
this.api = new Api("navigationmenu.swf").command("open", this.onOpen)
                                        .command("press", this.onPress);
this.api.watch(this);
```

A handler takes `(value, key)`. The key is there so a family of keys meaning the same
thing is one handler rather than twenty two.

Route your config through it, most specific first:

```actionscript
public function loadModConfiguration(key:String, value:String) : void
{
   var name:String = this.cfg.note(key,value);
   if(name == Config.PROBE)
   {
      return;
   }
   if(!this.api.run(name,value) && !this.take(name,value))
   {
      this.api.stray(name,value);
   }
}
```

`run` returns true when the key was the bus's. `take` is your own settings, returning
true when the key was one. What is neither is nobody's, and goes to `stray`.

## The load looks exactly like a caller

Trove relays your whole section a key at a time when the screen loads, and it writes a
command key into the file like any other key — so an instruction from last session
arrives on this one looking precisely like a mod asking for it now. There is no marker
in the format that separates them.

So the burst is read as a burst: `Api` acts on nothing until the config has been quiet
for 600 ms, or four seconds have passed with no config at all. Anything that arrives
before that is recognised and dropped.

A command that is safe to honour during the load says so:

```actionscript
this.api.command("listen", this.onListen, true);
```

Saying who you are changes nothing, so it is honoured immediately — a listener made to
wait out the burst would miss whatever news arrived during it.

**A caller cannot clear its own key.** Trove has no delete, so `open = inventory` stays
in the file until something writes over it. That is the whole reason the load is ignored
rather than replayed — and the reason for the next section.

## An instruction has to be consumed

**Trove relays a write when the value changes.** Writing `open = collections` over
`open = collections` is not a message; it is the same message still lying there. So the
second time a mod asks for the same thing, nothing arrives — and nothing looks wrong
either: the file reads exactly as it did after the first time.

`Api` therefore writes an instruction off once it has been carried out. Having run the
handler, it sets the key to `Api.SPENT` in its own section on the next frame — not in the
handler, which is the one place on this channel a write must never go. The echo of that
write is swallowed, so it does not read as a caller.

Three things fall out of it, and all three were failures first:

- the same instruction can be sent twice
- nothing stale is left in the file to be misread at the next login
- a key that says `done` is a record that it was done

**Say it, do not merely write it.** `Api.post` writes; `api.say(swf, key, value)` writes
the key off and repeats it on the next beat, so an instruction that is already sitting in
the file unconsumed can be sent again. Two frames rather than two calls in one frame,
which Trove is at liberty to fold into the last of them.

**A message that has not been delivered must not be taken back.** The sender clearing its
own key after a moment looks like tidiness and is not: a shut screen is fed nothing until
its window opens, so the message is waiting in the file, and unwriting it destroys it.
Whoever acts on it writes it off. Nobody else.

## One shot, never a flag

An instruction is acted on as it arrives and nothing is kept. A caller that wants a
thing twice writes twice.

The older navigation API kept flags instead, and fired every one that was set on every
`ENTER_FRAME` — so a mod that asked for the store and did not clear the key asked again
thirty times a second for the rest of the session, and the only thing that stopped it
was the same mod writing `false`.

## Listeners

A mod names its own section and is told what the screen knows:

```actionscript
ExternalInterface.call("UIComponent.OnSaveConfig", "navigationmenu.swf",
                       "listen", "myscreen.swf");
```

From the answering side:

```actionscript
this.api.tell("nav_claims", "1");
```

`tell` writes to every listener and is silent when the value has not changed — a report
that says what the last one said is a config write for no news, and Trove rewrites the
whole file for each one.

Every report is kept, and a listener that subscribes later is caught up from them at
once. So a listener never needs anything repeated, and the answering screen never needs
to know who is new.

Listeners are capped at eight, `.swf` is required, and a screen will not subscribe
itself.

## Finding the other half of a feature

Subscribing is an announcement as much as a request: a mod that asks to be told what your
screen knows has said its own section out loud. So a feature that needs two mods can ask
for its other half by name.

```actionscript
if(this.api.hears("map.swf"))
{
   ...
}
```

That is what keeps a suite modular rather than all-or-nothing. A feature that spans two
screens — one that can see something and one that can act on it — offers itself only when
both mods are installed, and with one of them missing the option is simply not live.
Nothing is broken and nothing is half-working.

Ask it every frame rather than once. The other mod boots when it boots.

**The other direction.** `hears` tells a screen who subscribed to it. A mod that needs to
know whether a *screen* is there — because it wants that screen to do something, not
merely to be told something — subscribes and waits to be answered:

```actionscript
Api.post("navigationmenu.swf", Api.LISTEN, "starbar.swf");
this.api = new Api("starbar.swf").command(Api.HERE, this.onWho, true);
```

Every screen answers a new listener with its own section under `Api.HERE`, before
replaying its reports. Nothing answers if nobody owns the file, which is the answer.

A screen with nothing of its own to answer needs no bus at all, only the channel:

```actionscript
Api.post("navigationmenu.swf", "open", "inventory");
```

## A shut window hears nothing

Measured in game, and it is the thing most likely to catch you: **Trove does not relay
config to a screen whose window is closed.** Not the load burst, not a live write — the
message is written into the file and delivered when the window next opens.

So a screen that is usually shut cannot be asked to do something at the moment it
matters. It cannot even ask for its own window, because it will not hear the request. The
mod that is always on screen has to do the asking, and the shut screen reads the message
as it comes up.

## Strays

A key that is neither an instruction nor a setting of yours goes to the listeners
untouched.

That is how a feature can move out of a screen without taking its mods with it. Anything
written for the older navigation API addresses `navigationmenu.swf`, so a feature that
now lives in a mod of its own would never see a word of it — the mod that owns the
section passes on what is not its own instead of dropping it.

Forwarding is deduplicated per key, which is also what stops two mods bouncing the same
key between each other.

## What it costs

Every command, report and stray is a config write, and Trove rewrites the whole file for
one key. `OnSaveConfig` spam is what kills a screen on load
([pitfalls.md](pitfalls.md)). Keep to: an instruction when something happened, a report
when the answer changed.
