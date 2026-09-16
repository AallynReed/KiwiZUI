"""Graft Trove's controller buttons into a compiled SWF as one clip, `PadArt`.

The art is the game's own, out of `ui/uixbshared.swf` - the button library the PC client
loads for a gamepad. Each `btn_console_<name>` there is a sprite placing one bitmap; here
every one becomes a frame of a single sprite labelled `<name>`, so `ui.Pad` reaches any
button with `gotoAndStop(name)`.

The bitmaps are drawn through a shape's clipped fill rather than placed bare, the one form
ART.md saw Iggy draw. Character ids are renumbered above everything the SWF already
defines, so this runs after any other graft without colliding with it.

    from padart import graft, labels
    raw = graft(raw, HERE / "uixbshared.vanilla.swf")
"""

from __future__ import annotations

import struct
import zlib
from pathlib import Path

SYMBOL = "PadArt"

PREFIX = "btn_console_"

BUTTONS = ["south", "east", "west", "north", "lb", "rb", "lt", "rt", "dpad", "dpad_north",
           "dpad_south", "dpad_west", "dpad_east", "dpad_updown", "dpad_updowneast",
           "analog_top_left", "analog_top_right", "analog_side_left", "analog_side_right",
           "menu", "view", "XB", "keyboard"]

DEFINES = {2, 6, 7, 10, 11, 13, 14, 20, 21, 22, 32, 33, 34, 35, 36, 37, 39, 46, 48, 60, 75,
           83, 84, 87, 88, 90, 91}

BITMAPS = {35, 36}


def _rect_end(b: bytes, p: int) -> int:
    return p + ((5 + (b[p] >> 3) * 4) + 7) // 8


def _matrix_end(b: bytes, p: int) -> int:
    bit = 0

    def take(n: int) -> int:
        nonlocal p, bit
        v = 0
        for _ in range(n):
            v = (v << 1) | ((b[p] >> (7 - bit)) & 1)
            bit += 1
            if bit == 8:
                bit, p = 0, p + 1
        return v

    for _ in range(2):
        if take(1):
            take(take(5) * 2)
    take(take(5) * 2)
    return p + (1 if bit else 0)


def _tags(body: bytes, start: int) -> list[tuple[int, bytes]]:
    p, out = start, []
    while p < len(body):
        code = struct.unpack("<H", body[p:p + 2])[0]
        p += 2
        tag, length = code >> 6, code & 0x3F
        if length == 0x3F:
            length = struct.unpack("<I", body[p:p + 4])[0]
            p += 4
        out.append((tag, body[p:p + length]))
        p += length
        if tag == 0:
            break
    return out


def _pack(tag: int, payload: bytes) -> bytes:
    if len(payload) < 0x3F:
        return struct.pack("<H", (tag << 6) | len(payload)) + payload
    return struct.pack("<HI", (tag << 6) | 0x3F, len(payload)) + payload


def _body(raw: bytes) -> bytes:
    return zlib.decompress(raw[8:]) if raw[:3] == b"CWS" else raw[8:]


def _symbols(tags: list[tuple[int, bytes]]) -> dict[str, int]:
    out = {}
    for tag, payload in tags:
        if tag != 76:
            continue
        p = 2
        for _ in range(struct.unpack("<H", payload[:2])[0]):
            cid = struct.unpack("<H", payload[p:p + 2])[0]
            end = payload.index(b"\x00", p + 2)
            out[payload[p + 2:end].decode()] = cid
            p = end + 1
    return out


def _size(tag: int, payload: bytes) -> tuple[int, int]:
    if tag == 36:
        return struct.unpack("<HH", payload[3:7])
    jpeg = payload[6:6 + struct.unpack("<I", payload[2:6])[0]]
    p = 0
    while p < len(jpeg):
        if jpeg[p] != 0xFF:
            raise SystemExit("uixbshared: a JPEG with no frame header")
        marker = jpeg[p + 1]
        if marker in (0xD8, 0xD9):
            p += 2
            continue
        if marker in (0xC0, 0xC1, 0xC2):
            h, w = struct.unpack(">HH", jpeg[p + 5:p + 9])
            return w, h
        p += 2 + struct.unpack(">H", jpeg[p + 2:p + 4])[0]
    raise SystemExit("uixbshared: a JPEG with no frame header")


class _Bits:
    def __init__(self) -> None:
        self.out = bytearray()
        self.bit = 0

    def put(self, value: int, n: int) -> None:
        for i in range(n - 1, -1, -1):
            if self.bit == 0:
                self.out.append(0)
            self.out[-1] |= ((value >> i) & 1) << (7 - self.bit)
            self.bit = (self.bit + 1) % 8

    def align(self) -> None:
        self.bit = 0


def _width(*values: int) -> int:
    return max(max(v, -v - 1).bit_length() + 1 for v in values)


def _shape(cid: int, bitmap: int, w: int, h: int) -> bytes:
    tw, th = w * 20, h * 20
    bits = _Bits()
    n = _width(tw, th)
    bits.put(n, 5)
    for v in (0, tw, 0, th):
        bits.put(v, n)
    head = bytes(bits.out)

    bits = _Bits()
    scale = 20 << 16
    n = _width(scale)
    bits.put(1, 1)
    bits.put(n, 5)
    bits.put(scale, n)
    bits.put(scale, n)
    bits.put(0, 1)
    bits.put(0, 5)
    fill = bytes([1, 0x41]) + struct.pack("<H", bitmap) + bytes(bits.out) + bytes([0, 0x10])

    bits = _Bits()
    bits.put(0b000011, 6)
    bits.put(1, 5)
    bits.put(0, 1)
    bits.put(0, 1)
    bits.put(1, 1)
    for dx, dy in ((tw, 0), (0, th), (-tw, 0), (0, -th)):
        n = _width(dx or dy)
        bits.put(0b11, 2)
        bits.put(n - 2, 4)
        bits.put(0, 1)
        bits.put(1 if dx == 0 else 0, 1)
        bits.put(dy if dx == 0 else dx, n)
    bits.put(0, 6)
    return struct.pack("<H", cid) + head + fill + bytes(bits.out)


def _placement(sprite: bytes) -> tuple[int, bytes]:
    placed = [(t, p) for t, p in _tags(sprite, 4) if t in (26, 70)]
    if len(placed) != 1:
        raise SystemExit("uixbshared: a button sprite that is not one placement")
    tag, p = placed[0]
    start = 3 if tag == 26 else 4
    if p[0] != 0x06 or (tag == 70 and p[1] & ~0x10):
        raise SystemExit("uixbshared: a button placement carrying more than a matrix")
    end = _matrix_end(p, start + 2)
    if end != len(p):
        raise SystemExit("uixbshared: a button placement longer than its matrix")
    return struct.unpack("<H", p[start:start + 2])[0], p[start + 2:end]


def graft(ours: bytes, vanilla: Path) -> bytes:
    van = _body(Path(vanilla).read_bytes())
    vtags = _tags(van, _rect_end(van, 0) + 4)
    chars = {struct.unpack("<H", p[:2])[0]: (t, p) for t, p in vtags
             if t in DEFINES and len(p) >= 2}
    symbols = _symbols(vtags)

    body = _body(ours)
    head = _rect_end(body, 0) + 4
    tags = [list(t) for t in _tags(body, head)]
    used = {struct.unpack("<H", p[:2])[0] for t, p in tags if t in DEFINES and len(p) >= 2}
    if SYMBOL in _symbols([tuple(t) for t in tags]):
        raise SystemExit(f"{SYMBOL} is already bound in this SWF")
    at = next((i for i, (t, _) in enumerate(tags) if t == 76), -1)
    if at < 0:
        raise SystemExit("compiled SWF has no SymbolClass tag to bind onto")

    nxt = max(used, default=0) + 1
    grafted, control = b"", b""
    for i, name in enumerate(BUTTONS):
        sprite = chars.get(symbols.get(PREFIX + name, -1))
        if sprite is None or sprite[0] != 39:
            raise SystemExit(f"uixbshared has no sprite {PREFIX}{name}")
        bid, matrix = _placement(sprite[1])
        tag, payload = chars[bid]
        if tag not in BITMAPS:
            raise SystemExit(f"{PREFIX}{name} places something that is not a bitmap")
        w, h = _size(tag, payload)
        grafted += _pack(tag, struct.pack("<H", nxt) + payload[2:])
        grafted += _pack(2, _shape(nxt + 1, nxt, w, h))
        if i:
            control += _pack(28, struct.pack("<H", 1))
        control += _pack(26, bytes([0x06]) + struct.pack("<HH", 1, nxt + 1) + matrix)
        control += _pack(43, name.encode() + b"\x00")
        control += _pack(1, b"")
        nxt += 2
    if nxt > 0xFFFF:
        raise SystemExit("no character ids left to graft the pad art into")
    grafted += _pack(39, struct.pack("<HH", nxt, len(BUTTONS)) + control + _pack(0, b""))

    count = struct.unpack("<H", tags[at][1][:2])[0]
    tags[at][1] = (struct.pack("<H", count + 1) + tags[at][1][2:]
                   + struct.pack("<H", nxt) + SYMBOL.encode() + b"\x00")
    out = body[:head]
    for i, (tag, payload) in enumerate(tags):
        if i == at:
            out += grafted
        out += _pack(tag, payload)
    return b"CWS" + ours[3:4] + struct.pack("<I", 8 + len(out)) + zlib.compress(out, 9)


def labels(raw: bytes) -> list[str]:
    """The frame labels of the sprite bound to `PadArt`, read back out of a finished SWF."""
    body = _body(raw)
    tags = _tags(body, _rect_end(body, 0) + 4)
    cid = _symbols(tags).get(SYMBOL)
    for tag, payload in tags:
        if tag == 39 and struct.unpack("<H", payload[:2])[0] == cid:
            return [p[:-1].decode() for t, p in _tags(payload, 4) if t == 43]
    return []
