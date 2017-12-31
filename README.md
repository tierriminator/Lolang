# Lolang

## Introduction

### Description

Lolang is a simple, fun to use, register based programming language.  
Its name derives itself from the expression "lol", as well as a short term for low-level-language.
In Lolang, every command should refer to a common english slang word, what ensures, that programming in Lolang is always modern and a lot of fun.  
Memory is abstracted as a continuous space of registers (in fancy words, a register number is a virtual address for a memory location).  
Lolang is held simple, so that new programmers (noobs) will find it easy to write their first programs.
Therefore a single reference to the operational register is maintained.

### Command summary

Command | Description
--- | ---
`trololol...` | Increases operational register by number of 'ol's minus 1 (initializes with 0)
`lololol...` | Decreases operational register by number of 'ol's minus 1
`rofl` | If operational register is equal to 0, go to the command after the next `copter`, otherwise continue
`copter` | Go to most previous `rofl`
`moolah` | Increase operational register reference by one
`yolo` | Decrease operational register reference by one
`dope` | Set operational register reference to the value of the operational register
`bra<number>` | Set operational register reference to the specified number
`fuuu...` | Copy the value of the operational register to the register with the index of the number of 'u's minus 1 and set the operational register reference to that
`<whitespace>` | Sequence operator: execute the command before if one exists, and then execute the command after

### A few more things

- Lolang source files should have the file extension .lol
- Because Lolang is such a simplistic language, comments should not be necessary and are therefore not included (though they might be included in future releases)

## lolc

### Description

This package provides an implementation of Lolang: lolc.
lolc is a compiler for Lolang, written in Swift, which compiles to LLVM IR and therefore acts as a frontend to LLVM.

### Usage

`lolc <source> [options]` where options are:

option | description
--- | ---
`-o <path>` | specify destination file
`-l` | output LLVM IR
`-a` | output assembly file
`-b` | output object file
`-O<char>` | optimization level \[`-O0`, `-O1`, `-O2`, `-O3`\] (default: `-O2`)

The options `-l -a -b` are greedy in this order, meaning if `-l` is specified, the other two are ignored and if `-a` is specified, `-b` is ignored

### Implementation details

- lolc uses a custom memory management with multi-level page tables.
- pages are allocated when accessed
- a page holds 2048 bytes, or 256 registers
- a register is 64 bit and a register index 40 bit wide
- a page table has the size of a page

### Requirements

The following libraries are required:
- LLVM >= 5
- Standard C library (for Linux: glibc)

The following programs are required and should be accessible via `PATH`:
- `llc`
- `ld`

### Installation

#### Build yourself

lolc is written in [Swift](https://github.com/apple/swift). So to build it it is necessary to have Swift 4 installed.

1. clone this repository
2. Ensure `llvm-config`, `llc` and `ld` are in your `PATH`. They can normally be found in the `bin` directory of your LLVM installation directory.
3. Create a pkg-config file for your LLVM installation. A utility is provided for this in the `utils` directory.
You can use it as follows from the project root: `sudo swift utils/make-pkgconfig.swift`
4. Build with `swift build -c release`
5. Fetch the executable at the specified location, normally at `.build/release/lolc` and place it where you want.

### Credits

lolc makes heavy use of [LLVMSwift](https://github.com/trill-lang/LLVMSwift), from which the `make-pkgconfig.swift` utility is also provided.  
It also uses [PathKit](https://github.com/kylef/PathKit).

Thanks a lot to the authors of the above projects.

## Author

Tierry Hörmann

## License

This project is released under the MIT license
