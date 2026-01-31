package topng

import "core:c"
import "core:c/libc"
import "core:fmt"
import "core:strings"

import qr "../../qrcodegen/"
import tp "../../tinypngout/"

main :: proc() {
    example_topng()
}


example_topng :: proc() {
    fmt.println("Example: To PNG")
    fmt.println("================================")

    qrcode: [qr.BUFFER_LEN_MAX]u8
    temp_buffer: [qr.BUFFER_LEN_MAX]u8

    text := "http://github.com/niveksoft/qr-gen"

    ok := qr.encodeText(
        strings.clone_to_cstring(text),
        raw_data(temp_buffer[:]),
        raw_data(qrcode[:]),
        .HIGH,
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

print_qr :: proc(qrcode: [^]u8) {
    size := qr.getSize(qrcode)
    scale: c.int = 25

    file := libc.fopen("out.png", "w")
    defer libc.fclose(file)

    rgb_black := [3]u8{0, 0, 0}
    rgb_white := [3]u8{255, 255, 255}

    writer: tp.TinyPngOut
    tp.init(&writer, size * scale, size * scale, file)

    for y in 0 ..< size * scale {
        for x in 0 ..< size * scale {
            module := qr.getModule(qrcode, x / scale, y / scale)
            tp.write(
                &writer,
                module ? raw_data(rgb_white[:]) : raw_data(rgb_black[:]),
                1,
            )
        }
    }
}
