package tinypngout

// Odin bindings for Nayuki's Tiny PNG Out
// https://www.nayuki.io/page/tiny-png-output

import "core:c"
import "core:c/libc"

when ODIN_OS == .Windows {
    foreign import qrcodegen "tinypngout.lib"
} else {
    foreign import qrcodegen "system:tinypngout"
}

Status :: enum c.int {
    OK = 0,
    INVALID_ARGUMENT,
    IMAGE_TOO_LARGE,
    IO_ERROR,
}

TinyPngOut :: struct {
    // Immutable configuration
    width:         c.uint32_t,
    height:        c.uint32_t,
    lineSize:      c.uint32_t,

    // Running state
    output:        uintptr,
    positionX:     c.uint32_t,
    positionY:     c.uint32_t,
    uncompRemain:  c.uint32_t,
    deflateFilled: c.uint16_t,
    crc:           c.uint32_t,
    adler:         c.uint32_t,
}

@(default_calling_convention = "c", link_prefix = "TinyPngOut_")
foreign qrcodegen {
    init :: proc(this: ^TinyPngOut, w: c.int, h: c.int, out: ^libc.FILE) -> Status ---
    write :: proc(this: ^TinyPngOut, pixels: [^]c.uint8_t, count: c.size_t) -> Status ---
}
