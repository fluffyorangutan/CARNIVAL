#!/usr/bin/python3
# crimewave · reads the largest icon out of a Windows exe or dll and writes a PNG
# MIT · written by Claude (AI) on Nevil Hitesh's ask · 19 nov 2026
# use: icon.py list FILE...          show the icons in each file
#      icon.py png FILE OUT.png      write the best icon, scaled up with hard pixels
import struct, sys, zlib

def resources(data):
    """yield (type_id, name_id, bytes) for each resource in a PE file"""
    pe = struct.unpack_from('<I', data, 0x3c)[0]
    nsec = struct.unpack_from('<H', data, pe + 6)[0]
    opt = struct.unpack_from('<H', data, pe + 20)[0]
    sec = pe + 24 + opt
    for i in range(nsec):
        name, vsize, va, rsize, raw = struct.unpack_from('<8sIIII', data, sec + 40 * i)
        if name.rstrip(b'\0') != b'.rsrc':
            continue
        def walk(off, path):
            named, ids = struct.unpack_from('<HH', data, raw + off + 12)
            for j in range(named + ids):
                ident, ptr = struct.unpack_from('<II', data, raw + off + 16 + 8 * j)
                if ptr & 0x80000000:
                    yield from walk(ptr & 0x7fffffff, path + [ident])
                else:
                    rva, size = struct.unpack_from('<II', data, raw + ptr)
                    start = rva - va + raw
                    yield path + [ident], data[start:start + size]
        for path, blob in walk(0, []):
            yield path[0], path[1], blob

def icons(data):
    """return list of (width, height, bits, image bytes), from the icon groups"""
    imgs, groups = {}, []
    for typ, name, blob in resources(data):
        if typ == 3:
            imgs[name] = blob
        elif typ == 14:
            groups.append(blob)
    out = []
    for g in groups:
        count = struct.unpack_from('<H', g, 4)[0]
        for k in range(count):
            w, h, colors, _, planes, bits, size, ident = struct.unpack_from('<BBBBHHIH', g, 6 + 14 * k)
            if ident in imgs:
                out.append((w or 256, h or 256, bits, imgs[ident]))
    return out

def decode(img):
    """one icon image -> (width, height, rows of RGBA bytes)"""
    if img[:8] == b'\x89PNG\r\n\x1a\n':
        return None
    hsize, w, h2, planes, bpp = struct.unpack_from('<IiiHH', img, 0)
    h = h2 // 2
    ncol = struct.unpack_from('<I', img, 32)[0] or (1 << bpp if bpp <= 8 else 0)
    pal = [struct.unpack_from('<BBBB', img, hsize + 4 * i) for i in range(ncol)]
    xor = hsize + 4 * ncol
    xrow = ((w * bpp + 31) // 32) * 4
    arow = ((w + 31) // 32) * 4
    andm = xor + xrow * h
    rows = []
    for y in range(h - 1, -1, -1):
        row = bytearray()
        for x in range(w):
            o = xor + y * xrow
            if bpp == 32:
                b, g, r, a = img[o + 4 * x:o + 4 * x + 4]
            elif bpp == 24:
                b, g, r = img[o + 3 * x:o + 3 * x + 3]; a = 255
            else:
                if bpp == 8:
                    i = img[o + x]
                elif bpp == 4:
                    i = (img[o + x // 2] >> (4 if x % 2 == 0 else 0)) & 15
                else:
                    i = (img[o + x // 8] >> (7 - x % 8)) & 1
                b, g, r, _ = pal[i]; a = 255
            if bpp != 32 and (img[andm + y * arow + x // 8] >> (7 - x % 8)) & 1:
                a = 0
            row += bytes((r, g, b, a))
        rows.append(row)
    if bpp == 32 and not any(r[i] for r in rows for i in range(3, len(r), 4)):
        for y, r in enumerate(rows):
            for x in range(w):
                if not (img[andm + (h - 1 - y) * arow + x // 8] >> (7 - x % 8)) & 1:
                    r[4 * x + 3] = 255
    return w, h, rows

def write_png(path, w, h, rows, scale):
    raw = bytearray()
    for r in rows:
        line = bytearray()
        for x in range(w):
            line += r[4 * x:4 * x + 4] * scale
        raw += (b'\0' + line) * scale
    def chunk(t, d):
        return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d))
    png = b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w * scale, h * scale, 8, 6, 0, 0, 0))
    png += chunk(b'IDAT', zlib.compress(bytes(raw), 9)) + chunk(b'IEND', b'')
    open(path, 'wb').write(png)

def main():
    if len(sys.argv) >= 3 and sys.argv[1] == 'list':
        for f in sys.argv[2:]:
            for w, h, bits, img in icons(open(f, 'rb').read()):
                kind = 'png' if img[:4] == b'\x89PNG' else 'bmp'
                print(f.split('/')[-1], w, h, bits, kind, len(img))
        return 0
    if len(sys.argv) == 4 and sys.argv[1] == 'png':
        found = icons(open(sys.argv[2], 'rb').read())
        found.sort(key=lambda i: (i[0] * i[1], i[2]), reverse=True)
        for w, h, bits, img in found:
            if img[:4] == b'\x89PNG':
                open(sys.argv[3], 'wb').write(img)
                return 0
            w, h, rows = decode(img)
            write_png(sys.argv[3], w, h, rows, max(1, 512 // max(w, h)))
            return 0
        return 1
    print('use: icon.py list FILE... | icon.py png FILE OUT.png')
    return 2

sys.exit(main())
