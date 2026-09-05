"""Regenerate lib/Fish.as from the game's own fish names and the community weight table.

Two sources, joined on the English name:

  * `E:\\Trove\\languages\\en\\prefabs_item_fish_*.binfab` - every fish the game has, each
    behind a translation key. The key is what the table is keyed by, so a lookup at
    runtime translates it and matches the player's own language rather than English.
  * Embrace's Trove Fishing Guide - the weight class, where each fish is caught, which
    pool group it belongs to and which pole it takes. None of that is in any game file
    we can read.

Min and max weight are not stored: they are a function of the weight class alone, which
this checks before writing anything.

    python lib/fishtable.py
"""

from __future__ import annotations

import csv
import glob
import io
import re
import sys
import urllib.request
from pathlib import Path

sys.path.insert(0, r"S:\Desktop\Projects\TroveAPI")
from app.trove.codexes.binfab import extract_localization_map  # noqa: E402

HERE = Path(__file__).parent
OUT = HERE / "Fish.as"
LANG = r"E:\Trove\languages\en\prefabs_item_fish_*.binfab"
SHEET = ("https://docs.google.com/spreadsheets/d/"
         "1QvhKgFdOzd955b2-rnyhvr3nEoGmepu3hDqSWb1l8a4/export?format=csv&gid=0")

ALIAS = {
    "Wide-Eyed Noobfish": "Wide-eyed Noobfish",
    "Bruce": "Briny Bruce",
    "Rainbow-Shelled Turtleing": "Rainbow-Shelled Turtleling",
    "Fiery Flow": "Fiery Flow Fish",
    "Blue Cotton Candish": "Blue High Flying Cotton Candish",
    "Pink Cotton Candish": "Pink High Flying Cotton Candish",
    "Zephyr Nautoloid": "Zephyr Nautiloid",
}

RARITY = ["Common", "Uncommon", "Rare"]
WEIGHT = ["Light", "Medium", "Heavy", "Very heavy"]
SPECIES = 154

RANGE = {"Light": (19.05, 20.0), "Medium": (38.25, 40.0),
         "Heavy": (67.25, 70.0), "Very heavy": (115.25, 120.0)}
WAS = {"Light": (7.5, 10.0), "Medium": (21.0, 30.0),
       "Heavy": (35.0, 50.0), "Very heavy": (75.0, 100.0)}


TROPHY = "$prefabs_placeable_deco_trophy_fish_"
TIERS = ["basic", "silver", "gold"]
TAILS = ["_item_name", "_name"]
DECO = r"E:\Trove\languages\en\prefabs_placeable_deco*.binfab"

TROPHY_ALIAS = {
    "choc_cotcandyblue": "Blue High Flying Cotton Candish",
    "choc_cotcandypink": "Pink High Flying Cotton Candish",
}


def trophy_names() -> dict[str, tuple[str, int]]:
    """Every fish-trophy stem, with the name its `basic` tier carries and which of the
    two endings the game spells its keys with.

    Both endings are live. Everything up to the Long Shade fish is `_item_name`; the
    eight event fish added with it are `_name`, and looking for one ending alone is why
    their trophies matched no fish at all."""
    out: dict[str, tuple[str, int]] = {}
    for path in glob.glob(DECO):
        for key, value in extract_localization_map(Path(path).read_bytes()).items():
            if not key.startswith(TROPHY):
                continue
            for i, tail in enumerate(TAILS):
                if key.endswith("_basic" + tail):
                    out[key[len(TROPHY):-len("_basic" + tail)]] = (value.strip(), i)
                    break
    if not out:
        raise SystemExit(f"no fish trophies found under {DECO}")
    return out


def plain(text: str) -> str:
    return re.sub(r"[^a-z0-9]", "", text.lower())


def trophy_stems(keys: dict[str, tuple[str, int]],
                 by_name: dict[str, list[str]]) -> dict[str, str]:
    """Each trophy stem mapped to the fish key it belongs to.

    Joined on the key first and on the name second. The key is the better of the two -
    `..._trophy_fish_plasma_common_04_basic` and `$prefabs_item_fish_plasma_common_04_name`
    are plainly the same fish - and it is the only one that works where the two names are
    spelled differently, which several are: the game writes *Abyssal Crusteacean* on the
    trophy and *Abyssal Crustacean* on the fish, and *Lichenstone* against *Lichestone*.
    Where the key does not line up the name usually does, and two need naming outright."""
    stems: dict[str, list[str]] = {}
    for key in by_name_keys(by_name):
        stem = key
        for prefix in ("$prefabs_item_fish_", "$prefabs_fish_"):
            if stem.startswith(prefix):
                stem = stem[len(prefix):]
                break
        for suffix in TAILS:
            if stem.endswith(suffix):
                stem = stem[:-len(suffix)]
                break
        stems.setdefault(stem, []).append(key)

    longest = sorted(by_name, key=len, reverse=True)
    out: dict[str, str] = {}
    for stem, (shown, _) in keys.items():
        if stem in TROPHY_ALIAS:
            out[stem] = by_name[TROPHY_ALIAS[stem]][0]
            continue
        tries = [stem, stem.replace("choc_", "chocolate_", 1),
                 stem.replace("magic_", "enchanted_rare_", 1)]
        found = next((stems[t][0] for t in tries if t in stems), None)
        if found is None:
            hit = next((n for n in longest if plain(n) in plain(shown)), None)
            found = by_name[hit][0] if hit else None
        if found is None:
            raise SystemExit(f"trophy {stem!r} ({shown!r}) matches no fish")
        out[stem] = found
    return out


def by_name_keys(by_name: dict[str, list[str]]) -> list[str]:
    return [k for keys in by_name.values() for k in keys]


def game_names() -> dict[str, str]:
    out: dict[str, str] = {}
    for path in glob.glob(LANG):
        for key, value in extract_localization_map(Path(path).read_bytes()).items():
            if "_description" not in key:
                out[key] = value.strip()
    if not out:
        raise SystemExit(f"no fish names found under {LANG}")
    return out


def sheet_rows() -> list[list[str]]:
    raw = urllib.request.urlopen(SHEET).read().decode("utf-8")
    rows = list(csv.reader(io.StringIO(raw)))
    head = next(i for i, r in enumerate(rows) if len(r) > 1 and r[1].strip() == "Fish Name")
    return [[c.strip() for c in r] for r in rows[head + 1:] if len(r) > 1 and r[1].strip()]


def number(text: str) -> float | None:
    try:
        return float(text)
    except ValueError:
        return None


def build() -> tuple[list[str], list[str], list[str], list[str], list[str]]:
    names = game_names()
    by_name: dict[str, list[str]] = {}
    for key, value in names.items():
        by_name.setdefault(value, []).append(key)
    trophies_by_stem = trophy_names()
    owner = trophy_stems(trophies_by_stem, by_name)

    liquids: list[str] = []
    pools: list[str] = []
    poles: list[str] = []
    rows: list[str] = []

    def slot(table: list[str], value: str) -> int:
        if value not in table:
            table.append(value)
        return table.index(value)

    for r in sheet_rows():
        rarity, name, liquid, pool, pole, weight = r[0], r[1], r[2], r[3], r[4], r[5]
        name = ALIAS.get(name, name)
        keys = by_name.get(name)
        if not keys:
            raise SystemExit(f"{name!r} is in the sheet but not in the game's fish names")
        if len(keys) > 1:
            raise SystemExit(f"{name!r} has more than one translation key: {keys}")
        if weight not in RANGE:
            raise SystemExit(f"{name!r} has an unknown weight class {weight!r}")
        if rarity not in RARITY:
            raise SystemExit(f"{name!r} has an unknown rarity {rarity!r}")

        low, high = number(r[6]), number(r[7])
        if (low, high) != RANGE[weight]:
            raise SystemExit(f"{name!r} is {weight} but weighs {low}-{high}, "
                             f"not {RANGE[weight]}")
        was_low, was_high = number(r[8]), number(r[9])
        old = was_low is not None and was_high is not None
        if old and (was_low, was_high) != WAS[weight]:
            raise SystemExit(f"{name!r} is {weight} but used to weigh {was_low}-{was_high}, "
                             f"not {WAS[weight]}")

        rows.append("|".join([keys[0], str(RARITY.index(rarity)),
                              str(WEIGHT.index(weight)), str(slot(liquids, liquid)),
                              str(slot(pools, pool)), str(slot(poles, pole)),
                              "1" if old else "0", r[10], r[11]]))

    at = {row.split("|")[0]: i for i, row in enumerate(rows)}
    orphans = sorted(stem for stem, key in owner.items() if key not in at)
    if orphans:
        print(f"  {len(orphans)} trophies name a fish the sheet does not list, skipped: "
              + ", ".join(orphans))
    mounted = sorted(f"{stem}|{at[key]}|{trophies_by_stem[stem][1]}"
                     for stem, key in owner.items() if key in at)
    return rows, liquids, pools, poles, mounted


def quoted(values: list[str], indent: str) -> str:
    out, line = [], indent
    for i, value in enumerate(values):
        piece = '"' + value.replace("\\", "\\\\").replace('"', '\\"') + '"'
        if i < len(values) - 1:
            piece += ","
        if len(line) + len(piece) > 96 and line.strip():
            out.append(line.rstrip())
            line = indent
        line += piece
    out.append(line.rstrip())
    return "\n".join(out)


HEAD = '''package
{
   public class Fish
   {

      public static const COMMON:int = 0;

      public static const UNCOMMON:int = 1;

      public static const RARE:int = 2;

      public static const MASTERY:Array = [5,15,25];

      private static const TROPHY:String = "$prefabs_placeable_deco_trophy_fish_";

      private static const TIERS:Array = ["basic","silver","gold"];

      private static const TAILS:Array = ["_item_name","_name"];

      private static var words:Array = null;

      private static var prefix:String = null;

      public static function rarityWord(rarity:int) : String
      {
         if(words == null || String(words[0]).charAt(0) == "$")
         {
            words = [IggyFunctions.translate("$Rarity_Common"),
                     IggyFunctions.translate("$Rarity_Uncommon"),
                     IggyFunctions.translate("$Rarity_Rare")];
         }
         return String(words[rarity < 0 ? 0 : (rarity > 2 ? 2 : rarity)]);
      }

      public static function get weighed() : String
      {
         var form:String = null;
         var at:int = 0;
         if(prefix != null)
         {
            return prefix;
         }
         form = String(IggyFunctions.translate("$FishWeightFormat"));
         at = form.indexOf("{");
         if(at <= 0)
         {
            return "";
         }
         prefix = form.substring(0,at);
         return prefix;
      }

      public static function weightIn(body:String) : Number
      {
         var text:String = stripped(body);
         var mark:String = weighed;
         var digits:String = "";
         var at:int = 0;
         var ch:String = null;
         if(mark.length == 0)
         {
            return NaN;
         }
         at = text.indexOf(mark);
         if(at < 0)
         {
            return NaN;
         }
         at += mark.length;
         while(at < text.length)
         {
            ch = text.charAt(at);
            if(ch >= "0" && ch <= "9")
            {
               digits += ch;
            }
            else if((ch == "." || ch == ",") && digits.length > 0
                    && digits.indexOf(".") == -1)
            {
               digits += ".";
            }
            else if(digits.length > 0)
            {
               break;
            }
            at++;
         }
         return digits.length == 0 ? NaN : Number(digits);
      }

      private static function stripped(body:String) : String
      {
         var out:String = "";
         var depth:int = 0;
         var at:int = 0;
         var ch:String = null;
         if(body == null)
         {
            return "";
         }
         while(at < body.length)
         {
            ch = body.charAt(at);
            if(ch == "<")
            {
               depth++;
            }
            else if(ch == ">")
            {
               if(depth > 0)
               {
                  depth--;
               }
            }
            else if(depth == 0)
            {
               out += ch;
            }
            at++;
         }
         return out;
      }

      public static const LOW:Array = [19.05,38.25,67.25,115.25];

      public static const HIGH:Array = [20,40,70,120];

      public static const WASLOW:Array = [7.5,21,35,75];

      public static const WASHIGH:Array = [10,30,50,100];
'''

TAIL = '''
      private static var index:Object = null;

      public var key:String = "";

      public var rarity:int = 0;

      public var weight:int = 0;

      public var liquid:String = "";

      public var pool:String = "";

      public var pole:String = "";

      public var aged:Boolean = false;

      public var hint:String = "";

      public var note:String = "";

      public function Fish()
      {
         super();
      }

      public function get low() : Number
      {
         return Number(LOW[this.weight]);
      }

      public function get high() : Number
      {
         return Number(HIGH[this.weight]);
      }

      public function get worth() : int
      {
         return int(MASTERY[this.rarity]);
      }

      public function fraction(caught:Number) : Number
      {
         var least:Number = this.old(caught) ? Number(WASLOW[this.weight]) : this.low;
         var most:Number = this.old(caught) ? Number(WASHIGH[this.weight]) : this.high;
         var part:Number = most <= least ? 0 : (caught - least) / (most - least);
         return part < 0 ? 0 : (part > 1 ? 1 : part);
      }

      public function fits(caught:Number) : Boolean
      {
         if(this.old(caught))
         {
            return true;
         }
         return !isNaN(caught) && caught >= this.low && caught <= this.high;
      }

      public function old(caught:Number) : Boolean
      {
         return this.aged && caught >= Number(WASLOW[this.weight])
             && caught <= Number(WASHIGH[this.weight]);
      }

      public static const PLAIN:int = 0;

      public static const LEAST:int = 1;

      public static const RECORD:int = 2;

      public static const HAIR:int = 3;

      public static const WHOLE:int = 4;

      public static const NOTHING:int = 5;

      public function standing(caught:Number) : int
      {
         var least:Number = this.old(caught) ? Number(WASLOW[this.weight]) : this.low;
         var most:Number = this.old(caught) ? Number(WASHIGH[this.weight]) : this.high;
         if(isNaN(caught))
         {
            return PLAIN;
         }
         if(near(caught,0))
         {
            return NOTHING;
         }
         if(near(caught,least))
         {
            return LEAST;
         }
         if(near(caught,most))
         {
            return RECORD;
         }
         if(near(caught,least + 0.01) || near(caught,most - 0.01))
         {
            return HAIR;
         }
         if(near(caught,Math.round(caught)) && caught > least && caught < most)
         {
            return WHOLE;
         }
         return PLAIN;
      }

      private static function near(a:Number, b:Number) : Boolean
      {
         return Math.abs(a - b) < 0.001;
      }

      public static function named(displayName:String) : Fish
      {
         var name:String = displayName == null ? "" : trimmed(displayName.toLowerCase());
         var map:Object = null;
         if(name.length == 0)
         {
            return null;
         }
         if(index == null)
         {
            map = built();
            if(map == null)
            {
               return null;
            }
            index = map;
         }
         return index[name] as Fish;
      }

      private static function built() : Object
      {
         var out:Object = {};
         var made:Array = [];
         var row:String = null;
         var parts:Array = null;
         var fish:Fish = null;
         var tier:String = null;
         var tail:String = null;
         var found:int = 0;
         for each(row in TABLE)
         {
            parts = row.split("|");
            fish = new Fish();
            fish.key = parts[0];
            fish.rarity = int(parts[1]);
            fish.weight = int(parts[2]);
            fish.liquid = LIQUID[int(parts[3])];
            fish.pool = POOL[int(parts[4])];
            fish.pole = POLE[int(parts[5])];
            fish.aged = parts[6] == "1";
            fish.hint = parts[7];
            fish.note = parts[8];
            made.push(fish);
            found += put(out,fish.key,fish);
         }
         for each(row in MOUNTED)
         {
            parts = row.split("|");
            fish = made[int(parts[1])] as Fish;
            tail = String(TAILS[int(parts[2])]);
            for each(tier in TIERS)
            {
               put(out,TROPHY + parts[0] + "_" + tier + tail,fish);
            }
         }
         return found == 0 ? null : out;
      }

      private static function put(into:Object, key:String, fish:Fish) : int
      {
         var name:String = trimmed(String(IggyFunctions.translate(key)).toLowerCase());
         if(name.length == 0 || name.charAt(0) == "$")
         {
            return 0;
         }
         into[name] = fish;
         return 1;
      }


      private static function trimmed(body:String) : String
      {
         var from:int = 0;
         var to:int = body.length;
         while(from < to && body.charAt(from) <= " ")
         {
            from++;
         }
         while(to > from && body.charAt(to - 1) <= " ")
         {
            to--;
         }
         return body.substring(from,to);
      }
   }
}
'''


PLAIN, LEAST, RECORD, HAIR, WHOLE, NOTHING = range(6)

STRING = re.compile(r'"((?:[^"\\]|\\.)*)"')


def strings(body: str) -> list[str]:
    """Every string literal in an ActionScript array, unescaped.

    A literal quote has to be read back as one rather than as the end of the string:
    a hint that names an event in quotes would otherwise split into three, and the row
    counts that guard the table would be counting fragments."""
    return [s.replace('\\"', '"').replace("\\\\", "\\") for s in STRING.findall(body)]


def array(src: str, name: str, where: str) -> list[str]:
    block = re.search(r"const " + name + r":Array = \[(.*?)\];", src, re.S)
    if not block:
        raise SystemExit(f"{where} has no {name} table")
    return strings(block.group(1))


def parse() -> list[dict]:
    """The shipped Fish.as read back as data, so what is checked is the table that is
    actually compiled in rather than what the generator meant to write."""
    src = OUT.read_text(encoding="utf-8")

    def table(name: str) -> list[str]:
        return array(src, name, "Fish.as")

    liquids, pools, poles = table("LIQUID"), table("POOL"), table("POLE")
    out = []
    for row in table("TABLE"):
        p = row.split("|")
        out.append({"key": p[0], "rarity": int(p[1]), "weight": int(p[2]),
                    "liquid": liquids[int(p[3])], "pool": pools[int(p[4])],
                    "pole": poles[int(p[5])], "aged": p[6] == "1",
                    "hint": p[7], "note": p[8]})
    return out


def near(a: float, b: float) -> bool:
    return abs(a - b) < 0.001


def standing(fish: dict, caught: float) -> int:
    """The mirror of Fish.standing. Written out a second time in a second language so a
    band that reads right in ActionScript has to also be right here to pass."""
    band = WEIGHT[fish["weight"]]
    aged = fish["aged"] and WAS[band][0] <= caught <= WAS[band][1]
    least, most = WAS[band] if aged else RANGE[band]
    if near(caught, 0):
        return NOTHING
    if near(caught, least):
        return LEAST
    if near(caught, most):
        return RECORD
    if near(caught, least + 0.01) or near(caught, most - 0.01):
        return HAIR
    if near(caught, round(caught)) and least < caught < most:
        return WHOLE
    return PLAIN


def verify_built(built: str) -> None:
    """The bands and the table as they came back out of the compiled SWF.

    Eight numbers stand in for a 154-row table of minimums and maximums, so they are the
    one thing here that a compiler folding a constant or a decompiler rendering a float
    could quietly change - and a range that is a hundredth out is wrong for a third of
    the fish in the game at once. Checked against the build rather than the source for
    exactly that reason."""
    for name, want in (("LOW", [RANGE[b][0] for b in WEIGHT]),
                       ("HIGH", [RANGE[b][1] for b in WEIGHT]),
                       ("WASLOW", [WAS[b][0] for b in WEIGHT]),
                       ("WASHIGH", [WAS[b][1] for b in WEIGHT])):
        found = re.search(name + r"(?::Array)? *= *\[([0-9.,\- ]+)\]", built)
        if not found:
            raise SystemExit(f"the build has no {name} band table")
        got = [float(n) for n in found.group(1).split(",")]
        if got != want:
            raise SystemExit(f"the build's {name} is {got}, expected {want}")
    rows = len(re.findall(r'"\$prefabs_[A-Za-z0-9_]+\|', built))
    if rows != len(parse()):
        raise SystemExit(f"the build carries {rows} fish, the table has {len(parse())}")
    mounted = trophies(built)
    if len(mounted) != rows:
        raise SystemExit(f"the build carries {len(mounted)} trophy stems for {rows} fish")
    print(f"  fish: {rows} species and {len(mounted) * len(TIERS)} trophy names in the "
          f"build, all four bands intact")


def trophies(built: str) -> list[str]:
    """The trophy stems in the build, checked against the language files.

    A mounted trophy carries its own name - "Gold Jumping Jadefin Trophy" - so the fish
    it belongs to is found through the trophy's key and not the fish's. A stem that named
    nothing would be a fish whose trophy is invisible to the tooltip, which is exactly the
    bug this table was added to fix and exactly as silent."""
    stems = [row.split("|") for row in array(built, "MOUNTED", "the build")]
    have: set[bytes] = set()
    for path in sorted(Path(r"E:\Trove\languages\en").glob("prefabs_placeable_deco*.binfab")):
        have |= set(re.findall(rb"\$[A-Za-z0-9_]+", path.read_bytes()))
    missing = [f"{TROPHY}{s[0]}_{t}{TAILS[int(s[2])]}"
               for s in stems for t in TIERS
               if f"{TROPHY}{s[0]}_{t}{TAILS[int(s[2])]}".encode() not in have]
    if missing:
        raise SystemExit(f"{len(missing)} trophy names are in no language file: "
                         + ", ".join(missing[:5]))
    return stems


def check() -> None:
    """Fuzz the classification over every fish at every hundredth of a pound it can
    weigh. The bands are eight numbers doing the work of a 154-row table, so a boundary
    that is one hundredth out is wrong for a third of the fish in the game at once and
    wrong nowhere a spot check would look."""
    fish = parse()
    if len(fish) != SPECIES:
        raise SystemExit(f"Fish.as holds {len(fish)} fish, expected {SPECIES}")
    seen = set()
    for f in fish:
        band = WEIGHT[f["weight"]]
        low, high = RANGE[band]
        if standing(f, low) != LEAST:
            raise SystemExit(f"{f['key']}: {low} is not read as the minimum")
        if standing(f, high) != RECORD:
            raise SystemExit(f"{f['key']}: {high} is not read as the record")
        if standing(f, round(high - 0.01, 2)) != HAIR:
            raise SystemExit(f"{f['key']}: {high - 0.01} is not read as a near miss")
        if standing(f, 0) != NOTHING:
            raise SystemExit(f"{f['key']}: a zero weight is not called out")
        if f["aged"]:
            was_low, was_high = WAS[band]
            if was_high >= low:
                raise SystemExit(f"{band}: the old band runs into the new one")
            if standing(f, was_low) != LEAST or standing(f, was_high) != RECORD:
                raise SystemExit(f"{f['key']}: the old band's ends are not read as ends")
        step = int(round((high - low) * 100))
        for i in range(step + 1):
            caught = round(low + i / 100, 2)
            part = (caught - low) / (high - low)
            if not -1e-9 <= part <= 1 + 1e-9:
                raise SystemExit(f"{f['key']}: {caught} sits {part} through its range")
            mark = standing(f, caught)
            if near(caught, round(caught)) and low < caught < high and mark != WHOLE:
                raise SystemExit(f"{f['key']}: {caught} is whole but read as {mark}")
        seen.add(f["key"])
    if len(seen) != len(fish):
        raise SystemExit("two fish share a translation key")
    print(f"  fish: {len(fish)} species, all four weight bands fuzzed end to end")


def main() -> None:
    rows, liquids, pools, poles, mounted = build()
    body = [HEAD]
    body.append("\n      private static const LIQUID:Array = [\n"
                + quoted(liquids, "         ") + "];\n")
    body.append("      private static const POOL:Array = [\n"
                + quoted(pools, "         ") + "];\n")
    body.append("      private static const POLE:Array = [\n"
                + quoted(poles, "         ") + "];\n")
    body.append("      private static const TABLE:Array = [\n"
                + quoted(rows, "         ") + "];\n")
    body.append("      private static const MOUNTED:Array = [\n"
                + quoted(mounted, "         ") + "];\n")
    body.append(TAIL)
    OUT.write_text("".join(body), encoding="utf-8")
    print(f"{OUT.name}: {len(rows)} fish, {len(mounted)} trophies, {len(liquids)} liquids, "
          f"{len(pools)} pools, {len(poles)} poles, {OUT.stat().st_size:,} bytes")


if __name__ == "__main__":
    main()
