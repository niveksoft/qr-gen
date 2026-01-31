package qrcodegen

// Odin bindings for Nayuki's QR Code generator C library
// https://github.com/nayuki/QR-Code-generator/tree/master/c

import "core:c"

when ODIN_OS == .Windows {
    foreign import qrcodegen "qrcodegen.lib"
} else {
    foreign import qrcodegen "system:qrcodegen"
}

VERSION_MIN :: 1
VERSION_MAX :: 40

// Maximum buffer length needed for version 40
// Use this if you want to support any QR code version (1-40).
// For smaller codes, you can allocate less using BUFFER_LEN_FOR_VERSION(n)
BUFFER_LEN_MAX :: 3918

// Calculate buffer length for a specific version
// Note: The actual version used is determined dynamically by the library
// based on the data size and the min/max version range you provide.
// Use this to allocate appropriately sized buffers.
BUFFER_LEN_FOR_VERSION :: proc(n: c.int) -> c.int {
    return ((n * 4 + 17) * (n * 4 + 17) + 7) / 8 + 1
}

Ecc :: enum c.int {
    LOW = 0,
    MEDIUM,
    QUARTILE,
    HIGH,
}

Mask :: enum c.int {
    AUTO = -1,
    MASK_0 = 0,
    MASK_1,
    MASK_2,
    MASK_3,
    MASK_4,
    MASK_5,
    MASK_6,
    MASK_7,
}

Mode :: enum c.int {
    NUMERIC      = 0x1,
    ALPHANUMERIC = 0x2,
    BYTE         = 0x4,
    KANJI        = 0x8,
    ECI          = 0x7,
}

Segment :: struct {
    mode:      Mode,
    numChars:  c.int,
    data:      [^]u8,
    bitLength: c.int,
}

@(default_calling_convention = "c", link_prefix = "qrcodegen_")
foreign qrcodegen {
    encodeText :: proc(text: cstring, tempBuffer: [^]u8, qrcode: [^]u8, ecl: Ecc, minVersion: c.int, maxVersion: c.int, mask: Mask, boostEcl: c.bool) -> c.bool ---
    encodeBinary :: proc(dataAndTemp: [^]u8, dataLen: c.size_t, qrcode: [^]u8, ecl: Ecc, minVersion: c.int, maxVersion: c.int, mask: Mask, boostEcl: c.bool) -> c.bool ---
    encodeSegments :: proc(segs: [^]Segment, len: c.size_t, ecl: Ecc, tempBuffer: [^]u8, qrcode: [^]u8) -> c.bool ---
    encodeSegmentsAdvanced :: proc(segs: [^]Segment, len: c.size_t, ecl: Ecc, minVersion: c.int, maxVersion: c.int, mask: c.int, boostEcl: c.bool, tempBuffer: [^]u8, qrcode: [^]u8) -> c.bool ---
    getSize :: proc(qrcode: [^]u8) -> c.int ---
    getModule :: proc(qrcode: [^]u8, x: c.int, y: c.int) -> c.bool ---
    makeNumeric :: proc(digits: cstring, buf: [^]u8) -> Segment ---
    makeAlphanumeric :: proc(text: cstring, buf: [^]u8) -> Segment ---
    makeBytes :: proc(data: [^]u8, len: c.size_t, buf: [^]u8) -> Segment ---
    makeEci :: proc(assignVal: c.long, buf: [^]u8) -> Segment ---
    calcSegmentBufferSize :: proc(mode: Mode, numChars: c.size_t) -> c.size_t ---
    isNumeric :: proc(text: cstring) -> c.bool ---
    isAlphanumeric :: proc(text: cstring) -> c.bool ---
}
