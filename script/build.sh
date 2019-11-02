#!/bin/sh
# This script will compile the liblouis shared libraries.
# For linux libraries, this script can be run natively.
# Windows libraries require a gcc based crosscompiler toolchain.
# For OSX a clang based crosscompiler toolchain is used.

# Currently, this script runs on a Arch Linux machine with the following packages installed:
# core/gcc 9.1.0-2
# aur/mingw-w64-gcc-bin 9.2.0-1
# aur/apple-darwin-osxcross 325.16efae8-1

BUILD_SCRIPT_DIR="$(dirname "$(readlink -f "$0")")" # The path containing this script
TEMP_DIR="$(dirname "$(mktemp -u)")/libloius_builds" # Temporary source tree location
LIB_DIR="$BUILD_SCRIPT_DIR/../bin" # Where the libs are copied to - root dir

MAKE_FLAGS=$*

LIBLOUIS_VER="3.11.0"
LIBLOUIS_ARCHIVE="liblouis-$LIBLOUIS_VER.tar.gz"

# --------------------------------------------------------------------------- #
# Method declarations

error() {
    if [ -z "$1" ]; then
        error "No error specified for error print!" # Oh the iron E
        return
    fi

    echo "Error: $1"
    exit 1
}

fetch_source() {
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    curl -L -O "https://github.com/liblouis/liblouis/releases/download/v$LIBLOUIS_VER/$LIBLOUIS_ARCHIVE"
}

# param 1: cross toolchain id
# param 2: sub dir
# param 3: lib file to export
# param 4: strip?
# param 5: CC to use
compile_gcc() {
    CROSS_ID="$1"
    SUB_DIR="$2"
    LIB_FILE="$3"
    STRIP="$4"
    export CC="$5"

    echo ""
    echo "--------------------------------------------------------------------------------"
    echo "Starting build for $CROSS_ID"
    echo "--------------------------------------------------------------------------------"

    mkdir -p "$TEMP_DIR/$SUB_DIR/src"
    cd "$TEMP_DIR/$SUB_DIR/src"
    tar xf "$TEMP_DIR/$LIBLOUIS_ARCHIVE" --strip-components 1
    ./configure --prefix="$TEMP_DIR/$SUB_DIR/install" --host="$CROSS_ID" --without-yaml
    make clean
    make install # "$MAKE_FLAGS" # mingw64 currently has some problems with multiple jobs (-j8), so this is currently disabled

    if [ $4 == "true" ]; then
        install -s -D "$TEMP_DIR/$SUB_DIR/install/$LIB_FILE" -t "$LIB_DIR/$SUB_DIR"
    else
        install -D "$TEMP_DIR/$SUB_DIR/install/$LIB_FILE" -t "$LIB_DIR/$SUB_DIR"
    fi
}

compile_linux_x86_64() {
    compile_gcc "x86_64-pc-linux-gnu" "x86_64/linux" "lib/liblouis.so" "true" "gcc"
}

compile_windows_x86_64() {
    compile_gcc "x86_64-w64-mingw32" "x86_64/win32" "bin/liblouis.dll" "true" "x86_64-w64-mingw32-gcc"
}

compile_windows_x86_32() {
    compile_gcc "i686-w64-mingw32" "x86_32/win32" "bin/liblouis.dll" "true" "i686-w64-mingw32-gcc"
}

compile_apple_osx() {
    compile_gcc "x86_64-apple-darwin17" "x86_64/osx" "lib/liblouis.dylib" "false" "o64-clang"
}


# --------------------------------------------------------------------------- #
# Start of the script main procedure

set -e # Terminate right after the first error

command -v curl >/dev/null 2>&1 || { error "curl is required, please install the according package"; }
command -v tar >/dev/null 2>&1 || { error "tar is required, please install the according package"; }
command -v make >/dev/null 2>&1 || { error "make is required, please install the according package"; }

echo "Using temporary directory for builds: \"$TEMP_DIR\""
echo "Using makeflags: \"$MAKE_FLAGS\""

fetch_source
compile_linux_x86_64
compile_windows_x86_64
compile_windows_x86_32
compile_apple_osx
