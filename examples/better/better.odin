package better

import "core:c"
import "core:fmt"
import "core:strings"

import qr "../../qrcodegen"

main :: proc() {
    example_simple_text()
    example_binary_data()
    example_segments()
}

example_simple_text :: proc() {
    fmt.println("Example 1: Simple Text Encoding")
    fmt.println("================================")

    qrcode: [qr.BUFFER_LEN_MAX]u8
    temp_buffer: [qr.BUFFER_LEN_MAX]u8

    text := "Hello, Odin!"

    ok := qr.encodeText(
        strings.clone_to_cstring(text),
        raw_data(temp_buffer[:]),
        raw_data(qrcode[:]),
        .MEDIUM,
        qr.VERSION_MIN,
        qr.VERSION_MAX,
        .AUTO,
        true,
    )

    if !ok {
        fmt.println("Error: Failed to encode text")
        return
    }

    print_qr(raw_data(qrcode[:]))
}

example_binary_data :: proc() {
    fmt.println("Example 2: Binary Data Encoding")
    fmt.println("================================")

    // Binary data (UTF-8 bytes for "あ" in Japanese)
    data := []u8{0xE3, 0x81, 0x82}

    qrcode := make([]u8, qr.BUFFER_LEN_FOR_VERSION(40))
    data_and_temp := make([]u8, qr.BUFFER_LEN_FOR_VERSION(40))

    copy(data_and_temp[:], data)

    ok := qr.encodeBinary(
        raw_data(data_and_temp[:]),
        c.size_t(len(data)),
        raw_data(qrcode[:]),
        .MEDIUM,
        2,
        7,
        .MASK_4,
        false,
    )

    if !ok {
        fmt.println("Error: Failed to encode binary data")
        return
    }

    print_qr(raw_data(qrcode[:]))
}

example_segments :: proc() {
    fmt.println("Example 3: Using Segments for Numeric Data")
    fmt.println("===========================================")

    qrcode: [qr.BUFFER_LEN_MAX]u8
    temp_buffer: [qr.BUFFER_LEN_MAX]u8

    // Create a numeric segment (more efficient for numbers)
    digits := "314159265358979323846"
    seg_buf_size := qr.calcSegmentBufferSize(.NUMERIC, c.size_t(len(digits)))
    seg_buffer := make([]u8, seg_buf_size)
    defer delete(seg_buffer)

    segment := qr.makeNumeric(
        strings.clone_to_cstring(digits),
        raw_data(seg_buffer),
    )

    segments := []qr.Segment{segment}
    ok := qr.encodeSegments(
        raw_data(segments),
        c.size_t(len(segments)),
        .MEDIUM,
        raw_data(temp_buffer[:]),
        raw_data(qrcode[:]),
    )

    if !ok {
        fmt.println("Error: Failed to encode segments")
        return
    }

    print_qr(raw_data(qrcode[:]))
}

print_qr :: proc(qrcode: [^]u8) {
    size := qr.getSize(qrcode)

    fmt.printf("QR Code size: %d x %d\n\n", size, size)

    // Print top border
    for i in 0 ..< size + 2 {
        fmt.print("██")
    }
    fmt.println()

    // Print QR code with side borders
    for y in 0 ..< size {
        fmt.print("██") // Left border

        for x in 0 ..< size {
            module := qr.getModule(qrcode, x, y)
            if module {
                fmt.print("  ") // White module
            } else {
                fmt.print("██") // Black module
            }
        }

        fmt.print("██") // Right border
        fmt.println()
    }

    // Print bottom border
    for i in 0 ..< size + 2 {
        fmt.print("██")
    }
    fmt.println()
    fmt.println()
}
