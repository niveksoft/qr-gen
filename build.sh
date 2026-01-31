#!/bin/bash

set -e

echo "Building QR Code Generator Example..."

# Create directory if it doesn't exist
mkdir -p lib bin

# Check if library exists, if not, try to build it
if [ ! -f "lib/libqrcodegen.a" ]; then
    echo "Library not found. Attempting to download and build..."

    # Change directory
    pushd qrcodegen

    # Download source files if not present
    if [ ! -f "qrcodegen.c" ]; then
        echo "Downloading qrcodegen.c..."
        wget -q https://raw.githubusercontent.com/nayuki/QR-Code-generator/master/c/qrcodegen.c
    fi

    if [ ! -f "qrcodegen.h" ]; then
        echo "Downloading qrcodegen.h..."
        wget -q https://raw.githubusercontent.com/nayuki/QR-Code-generator/master/c/qrcodegen.h
    fi

    # Compile the library
    echo "Compiling qrcodegen library..."
    gcc -c -O2 qrcodegen.c -o qrcodegen.o
    ar rcs ../lib/libqrcodegen.a qrcodegen.o
    rm qrcodegen.o qrcodegen.h qrcodegen.c

    echo "Library built successfully!"

    # Return to root
    popd
fi

odin build ./examples/better/ -extra-linker-flags:"-L./lib -lqrcodegen" -o:speed -out:bin/better
odin build ./examples/simple/ -extra-linker-flags:"-L./lib -lqrcodegen" -o:speed -out:bin/simple

echo "Build complete! Run with: ./bin/better or ./bin/simple"
