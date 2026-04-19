global _start

section .data
    hex_digits db '0123456789abcdef'

section .bss
    inbuf       resb 16
    linebuf     resb 80
    path_ptr    resq 1
    read_fd     resd 1
    offset_val  resd 1
    bytes_read  resd 1
    write_left  resd 1
    write_ptr   resq 1

section .text

; Convert the byte in AL into two lowercase hex characters at [RDI].
; Clobbers: AL, RBX
byte_to_hex:
    mov bl, al
    shr al, 4
    and eax, 0x0f
    mov al, [hex_digits + rax]
    mov [rdi], al

    mov al, bl
    and eax, 0x0f
    mov al, [hex_digits + rax]
    mov [rdi + 1], al
    ret

; Write the 32-bit offset in EAX as 8 hex digits at [RDI].
; Clobbers: RAX, RBX, RCX, RDX
print_offset:
    mov ecx, 8
    lea rdx, [rdi + 7]
.loop:
    mov ebx, eax
    and ebx, 0x0f
    mov bl, [hex_digits + rbx]
    mov [rdx], bl
    shr eax, 4
    dec rdx
    loop .loop
    ret

; Format one hexdump line into linebuf and return its length in EAX.
; Uses bytes_read and offset_val globals plus inbuf contents.
; Clobbers: general purpose caller-saved registers
format_line:
    lea rdi, [linebuf]
    mov eax, [offset_val]
    call print_offset

    mov byte [linebuf + 8], ' '
    mov byte [linebuf + 9], ' '
    mov byte [linebuf + 34], ' '

    xor ecx, ecx
.hex_loop:
    cmp ecx, 16
    jae .after_hex

    lea rdi, [linebuf + 10 + rcx + rcx * 2]
    cmp ecx, 8
    jb .hex_slot
    inc rdi
.hex_slot:
    cmp ecx, [bytes_read]
    jae .hex_pad

    mov al, [inbuf + rcx]
    call byte_to_hex
    jmp .hex_sep

.hex_pad:
    mov byte [rdi], ' '
    mov byte [rdi + 1], ' '

.hex_sep:
    mov byte [rdi + 2], ' '
    inc ecx
    jmp .hex_loop

.after_hex:
    mov byte [linebuf + 59], ' '
    mov byte [linebuf + 60], ' '

    xor ecx, ecx
.ascii_loop:
    cmp ecx, [bytes_read]
    jae .ascii_done

    mov al, [inbuf + rcx]
    cmp al, 32
    jb .non_printable
    cmp al, 126
    ja .non_printable
    mov [linebuf + 61 + rcx], al
    jmp .ascii_next

.non_printable:
    mov byte [linebuf + 61 + rcx], '.'

.ascii_next:
    inc ecx
    jmp .ascii_loop

.ascii_done:
    mov byte [linebuf + 61 + rcx], 10
    lea eax, [rcx + 62]
    ret

_start:
    mov dword [read_fd], 0
    mov dword [offset_val], 0

    mov rax, [rsp]
    cmp rax, 1
    jle .read_loop

    mov rax, [rsp + 16]
    mov [path_ptr], rax

    mov eax, 257            ; openat
    mov edi, -100           ; AT_FDCWD
    mov rsi, [path_ptr]
    xor edx, edx            ; O_RDONLY
    xor r10d, r10d          ; mode unused
    syscall

    test eax, eax
    js .exit_error
    mov [read_fd], eax

.read_loop:
    mov eax, 0              ; read
    mov edi, [read_fd]
    lea rsi, [inbuf]
    mov edx, 16
    syscall

    test eax, eax
    js .exit_error
    jz .exit_ok

    mov [bytes_read], eax
    call format_line

    mov [write_left], eax
    lea rax, [linebuf]
    mov [write_ptr], rax

.write_loop:
    mov eax, 1              ; write
    mov edi, 1
    mov rsi, [write_ptr]
    mov edx, [write_left]
    syscall

    test eax, eax
    js .exit_error

    sub dword [write_left], eax
    add qword [write_ptr], rax
    cmp dword [write_left], 0
    jne .write_loop

    mov eax, [bytes_read]
    add dword [offset_val], eax
    jmp .read_loop

.exit_ok:
    mov eax, 60
    xor edi, edi
    syscall

.exit_error:
    mov eax, 60
    mov edi, 1
    syscall
