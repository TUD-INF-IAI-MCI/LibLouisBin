# liblouis_bin

This repo contains compiled liblouis shared library artifacts.
These libraries are intended for use in the [BraillePlot](https://github.com/TUD-INF-IAI-MCI/BraillePlot) project.

## Project structure

The dynamic libraries are placed according to the following scheme:
``` bash
bin/$ARCH/$OS
```

For example, the structure  for the integration of shared libraries for
* 32 bit Windows on a [x86](https://en.wikipedia.org/wiki/X86) capable CPU
* 64 bit Linux on a [AMD64](https://en.wikipedia.org/wiki/X86-64) capable CPU
* 64 bit Apple OSX on a [AMD64](https://en.wikipedia.org/wiki/X86-64) capable CPU
* 64 bit Windows on a [AMD64](https://en.wikipedia.org/wiki/X86-64) capable CPU

would look like this:

``` bash
.
├── bin
│   ├── x86_32
│   │   └── win32
│   │       └── liblouis.dll
│   └── x86_64
│       ├── linux
│       │   └── liblouis.so
│       ├── osx
│       │   └── liblouis.dylib
│       └── win32
│           └── liblouis.dll
├── README.md
└── script
    └── build.sh

```

The script [script/build.sh](script/build.sh) will compile libraries for both Linux and Windows for 64 bit systems and for 32 bit windows on a 64 bit linux system - required you have a working native `x86_64-pc-linux-gnu`, and `x86_64-w64-mingw32` cross compiler toolchain installed.
In order to build libraries for OSX, a related compiler toolchain has to be installed.

See [the build script](script/build.sh) for details.