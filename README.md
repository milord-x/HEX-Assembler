# HexAsm

Minimal hex viewer in pure x86-64 Linux assembly.

## Features

- Reads from a file path passed as `argv[1]`
- Falls back to `stdin` when no file argument is provided
- Uses only direct Linux syscalls: `openat`, `read`, `write`, `exit`
- No libc, no C runtime, no dynamic allocation
- Fixed 16-byte input buffer

## Build

```sh
make
```

## Usage

Dump a file:

```sh
./hexasm /bin/ls
```

Pipe data through stdin:

```sh
printf 'Hello ASM!\n' | ./hexasm
```

Example output:

```text
00000000  48 65 6c 6c 6f 20 41 53  4d 21 0a                 Hello ASM!.
```

## Notes

- Offsets are printed as 8 lowercase hexadecimal digits.
- Non-printable bytes are rendered as `.` in the ASCII column.
- The program exits with status `1` on syscall failure.
