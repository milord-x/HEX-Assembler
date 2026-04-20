# Hex Assembler

Minimal hex viewer written in pure x86-64 Linux assembly.

---

## Overview

This project was created as a **first practical step in learning Assembly language**.
The goal was to understand how low-level programs interact directly with the operating system without relying on high-level abstractions.

Instead of using standard libraries or runtime environments, this program operates entirely through **Linux syscalls**, providing a clear view of how data flows from disk (or stdin) to the terminal.

---

## What the program does

Hex Assembler reads binary data and displays it in a structured format:

* File offset (position in file)
* Hexadecimal representation of bytes
* ASCII representation (human-readable characters)

Example output:

```text
00000000  48 65 6c 6c 6f 20 41 53  4d 21 0a                 Hello ASM!.
```

This allows inspection of any file at the byte level, regardless of its type.

---

## Learning goals

This project focuses on core low-level concepts:

* Direct interaction with the Linux kernel via syscalls
* Working with file descriptors (`openat`, `read`)
* Manual memory handling using a fixed buffer
* Byte-level data processing
* Converting raw bytes into human-readable formats (hex + ASCII)
* Building a complete program without libc or runtime support

---

## Features

* Reads input from:

  * a file path (`argv[1]`)
  * or `stdin` if no argument is provided
* Uses only syscalls:

  * `openat`
  * `read`
  * `write`
  * `exit`
* Fixed 16-byte buffer per read
* Classic hex dump layout (offset + hex + ASCII)
* Printable ASCII characters are shown directly
* Non-printable bytes are replaced with `.`

---

## Build

```sh
make
```

---

## Usage

### Download the package

Arch Linux
```bash
sudo pacman -S nasm
```
Ubuntu
```bash
sudo apt install -y nasm
```

Debian
```bash
sudo apt install nasm
```
### Launch

```bash
make
```
### Read from file

```sh
./hexasm /bin/ls
```

### Read from stdin

```sh
printf 'Hello ASM!\n' | ./hexasm
```

---

## Technical notes

* Architecture: x86-64 (Linux)
* Entry point: `_start`
* No libc, no dynamic memory allocation
* Offset increments by the number of bytes actually read
* Output is formatted manually without helper functions from standard libraries

---

## Limitations

* No command-line flags (minimal design)
* Fixed output width (16 bytes per line)
* No paging or interactive navigation
* No error messages (only exit codes)

---

## Future improvements

Possible extensions for further learning:

* Vertical mode (1 byte per line)
* Colored output using ANSI escape sequences
* Configurable bytes per line
* File size detection and progress display
* Interactive viewer (scrolling / paging)

---

## Motivation

The purpose of this project is not to compete with existing tools like `hexdump` or `xxd`, but to understand:

* how such tools work internally
* how data is represented at the lowest level
* how software can be built from scratch with minimal dependencies

---

## Conclusion

Hex Assembler is a small but complete low-level utility that demonstrates:

* control over execution flow
* direct system interaction
* manual data formatting

It serves as a foundation for more complex Assembly projects.
