"""Do the icons this config asks for actually exist in the font Neovide loads?

    python docs/glyphcheck.py                 # sweep config + installed plugins
    python docs/glyphcheck.py F057 F071 E8EB  # check specific codepoints
    python docs/glyphcheck.py --font "C:/path/to/Some NF-Regular.ttf"

Two failure modes this catches, both of which render as an empty box:

  1. An icon field written as a bare space (`icon = " "`) — no glyph at all.
  2. Font version drift. Nerd Fonts adds codepoints every release and
     nvim-web-devicons tracks the latest, so a font a couple of releases
     behind silently loses icons. 3.2.1 was missing 24 of them here
     (yaml, css, vite.config.*, next.config.*, *.stories.*, ...).

Both subtables matter. Neovide resolves BMP codepoints through the (3,1)
format-4 cmap and astral ones — the whole nf-md-* Material Design set at
U+F0001+ — through (3,10) format-12. Checking only (3,1) reports every
Material Design icon as missing, because a (3,1) subtable cannot address
anything above U+FFFF.
"""
import os
import re
import struct
import sys

sys.stdout.reconfigure(encoding='utf-8', errors='backslashreplace')

CONFIG = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LAZY = os.path.expanduser(r'~\AppData\Local\nvim-data\lazy')
FONT = os.path.expanduser(
    r'~\AppData\Local\Microsoft\Windows\Fonts\JetBrainsMonoNerdFont-Regular.ttf')

# Private Use Area (nf-*), then the Material Design plane.
RANGES = ((0xE000, 0xF8FF), (0xF0000, 0xFFFFD))
# Plugin repos carry demo icons in their own docs; only ship-path files count.
SKIP = re.compile(r'/(examples?|specs?|tests?|docs?|fixtures)/')


def _cmap_offset(b):
    for i in range(struct.unpack('>H', b[4:6])[0]):
        tag, _, off, _ = struct.unpack('>4sIII', b[12 + 16 * i:28 + 16 * i])
        if tag == b'cmap':
            return off
    raise AssertionError('no cmap table')


def _fmt4(b, sub):
    segx2 = struct.unpack('>H', b[sub + 6:sub + 8])[0]
    seg = segx2 // 2
    end = struct.unpack(f'>{seg}H', b[sub + 14:sub + 14 + segx2])
    sp = sub + 16 + segx2
    start = struct.unpack(f'>{seg}H', b[sp:sp + segx2])
    dp = sp + segx2
    delta = struct.unpack(f'>{seg}h', b[dp:dp + segx2])
    rp = dp + segx2
    rng = struct.unpack(f'>{seg}H', b[rp:rp + segx2])

    def gid(cp):
        if cp > 0xFFFF:
            return 0
        for i in range(seg):
            if start[i] <= cp <= end[i]:
                if rng[i] == 0:
                    return (cp + delta[i]) & 0xFFFF
                o = rp + 2 * i + rng[i] + 2 * (cp - start[i])
                g = struct.unpack('>H', b[o:o + 2])[0]
                return (g + delta[i]) & 0xFFFF if g else 0
        return 0
    return gid


def _fmt12(b, sub):
    n = struct.unpack('>I', b[sub + 12:sub + 16])[0]
    groups = [struct.unpack('>III', b[sub + 16 + 12 * i:sub + 28 + 12 * i]) for i in range(n)]

    def gid(cp):
        lo, hi = 0, n - 1
        while lo <= hi:
            mid = (lo + hi) // 2
            s, e, gstart = groups[mid]
            if cp < s:
                hi = mid - 1
            elif cp > e:
                lo = mid + 1
            else:
                return gstart + (cp - s)
        return 0
    return gid


def lookup(path):
    """gid(codepoint) -> 0 when the font cannot render it. Reads both subtables."""
    b = open(path, 'rb').read()
    off = _cmap_offset(b)
    subs = {}
    for i in range(struct.unpack('>H', b[off + 2:off + 4])[0]):
        pid, eid, so = struct.unpack('>HHI', b[off + 4 + 8 * i:off + 12 + 8 * i])
        subs[(pid, eid)] = off + so
    fns = []
    for key in ((3, 10), (3, 1)):
        sub = subs.get(key)
        if sub is None:
            continue
        fmt = struct.unpack('>H', b[sub:sub + 2])[0]
        fns.append(_fmt4(b, sub) if fmt == 4 else _fmt12(b, sub) if fmt == 12 else None)
    fns = [f for f in fns if f]
    assert fns, f'{path}: no usable (3,10) or (3,1) cmap subtable'
    return lambda cp: next((g for g in (f(cp) for f in fns) if g), 0)


def version(path):
    b = open(path, 'rb').read()
    for i in range(struct.unpack('>H', b[4:6])[0]):
        tag, _, off, _ = struct.unpack('>4sIII', b[12 + 16 * i:28 + 16 * i])
        if tag != b'name':
            continue
        count, storage = struct.unpack('>HH', b[off + 2:off + 6])
        for j in range(count):
            pid, _, _, nid, ln, o = struct.unpack('>6H', b[off + 6 + 12 * j:off + 18 + 12 * j])
            if pid == 3 and nid == 5:
                return b[off + storage + o:off + storage + o + ln].decode('utf-16-be', 'replace')
    return '?'


# Fields whose upstream default really is blank padding, not a lost glyph.
BLANK_OK = ('entry_prefix',)


def blanks(root):
    """Icon fields holding whitespace instead of a glyph — failure mode 1."""
    out = []
    for r, _, files in os.walk(root):
        if '/.git' in r.replace('\\', '/'):
            continue
        for x in files:
            if not x.endswith('.lua'):
                continue
            p = os.path.join(r, x)
            for i, line in enumerate(open(p, encoding='utf-8').read().split('\n'), 1):
                if not re.search(r'(icon|symbol|glyph|expander|prefix|caret|marker)\w*\s*=\s*["\']\s+["\']', line):
                    continue
                if any(f in line for f in BLANK_OK):
                    continue
                out.append(f"{os.path.relpath(p, root)}:{i}: {line.strip()}")
    return out


def scan(root, label, g, skip_docs=False):
    seen, miss = set(), {}
    for r, _, files in os.walk(root):
        rel = r.replace('\\', '/') + '/'
        if '/.git' in rel or (skip_docs and SKIP.search(rel)):
            continue
        for x in files:
            if not x.endswith('.lua'):
                continue
            p = os.path.join(r, x)
            try:
                text = open(p, encoding='utf-8').read()
            except OSError:
                continue
            for i, line in enumerate(text.split('\n'), 1):
                for c in line:
                    o = ord(c)
                    if any(lo <= o <= hi for lo, hi in RANGES):
                        seen.add(o)
                        if not g(o):
                            miss.setdefault(o, f"{os.path.relpath(p, root)}:{i}")
    if miss or label == 'config':
        detail = ''.join(f"\n    U+{o:04X} {chr(o)}  {w}" for o, w in sorted(miss.items()))
        print(f"  {label}: {len(seen)} glyphs, {len(miss)} missing{detail}")
    return len(miss)


def main(argv):
    font = FONT
    if '--font' in argv:
        i = argv.index('--font')
        font = argv[i + 1]
        del argv[i:i + 2]
    g = lookup(font)
    print(f"font: {os.path.basename(font)}  ({version(font)})\n")

    if argv:
        bad = 0
        for cp in (int(x, 16) for x in argv):
            ok = g(cp) != 0
            bad += not ok
            print(f"U+{cp:04X} {chr(cp)} {'OK' if ok else 'MISSING'}")
        return 1 if bad else 0

    empty = blanks(CONFIG)
    print(f"blank icon fields in config: {len(empty)}")
    for b in empty:
        print(f"    {b}")

    print('\ncoverage:')
    bad = scan(CONFIG, 'config', g)
    if os.path.isdir(LAZY):
        for plugin in sorted(os.listdir(LAZY)):
            if os.path.isdir(os.path.join(LAZY, plugin)):
                bad += scan(os.path.join(LAZY, plugin), plugin, g, skip_docs=True)
    else:
        print(f"  (no plugin dir at {LAZY} — config only)")

    print(f"\n{bad} missing, {len(empty)} blank")
    if bad:
        print("Font is behind what the plugins ship. Update it: "
              "https://github.com/ryanoasis/nerd-fonts/releases/latest")
    return 1 if (bad or empty) else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
