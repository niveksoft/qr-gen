package simple

import "core:c"
import "core:fmt"
import "core:strings"

// Direct bindings without a separate package for simplicity
when ODIN_OS == .Windows {
    foreign import qrcodegen "qrcodegen.lib"
} else when ODIN_OS == .Linux || ODIN_OS == .Darwin {
    foreign import qrcodegen "system:qrcodegen"
}

VERSION_MIN :: 1
VERSION_MAX :: 40
BUFFER_LEN_MAX :: 3918

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

@(default_calling_convention = "c", link_prefix = "qrcodegen_")
foreign qrcodegen {
    encodeText :: proc(text: cstring, tempBuffer: [^]u8, qrcode: [^]u8, ecl: Ecc, minVersion: c.int, maxVersion: c.int, mask: Mask, boostEcl: c.bool) -> c.bool ---

    getSize :: proc(qrcode: [^]u8) -> c.int ---
    getModule :: proc(qrcode: [^]u8, x: c.int, y: c.int) -> c.bool ---
}

main :: proc() {
    fmt.println("QR Code Generator - Odin + C Library")
    fmt.println()

    qrcode: [BUFFER_LEN_MAX]u8
    temp_buffer: [BUFFER_LEN_MAX]u8

    text := "Hello from Odin!"

    ok := encodeText(
        strings.clone_to_cstring(text),
        raw_data(temp_buffer[:]),
        raw_data(qrcode[:]),
        .MEDIUM,
        VERSION_MIN,
        VERSION_MAX,
        .AUTO,
        true,
    )

    if !ok {
        fmt.println("Error: Failed to generate QR code")
        return
    }

    fmt.printf("Successfully generated QR code for: \"%s\"\n\n", text)

    size := getSize(raw_data(qrcode[:]))
    fmt.printf("Size: %d x %d modules\n\n", size, size)

    // Print border
    for _ in 0 ..< size + 2 {
        fmt.print("██")
    }
    fmt.println()

    // Print QR code with borders
    for y in 0 ..< size {
        fmt.print("██")
        for x in 0 ..< size {
            is_dark := getModule(raw_data(qrcode[:]), x, y)
            if is_dark {
                fmt.print("  ") // Light module
            } else {
                fmt.print("██") // Dark module
            }
        }
        fmt.println("██")
    }

    // Print border
    for _ in 0 ..< size + 2 {
        fmt.print("██")
    }
    fmt.println()
    fmt.println()
    fmt.println("Scan this QR code with your phone!")
}
