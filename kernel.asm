
[BITS 16]
[ORG 0x1000]

start:
    ; Switch to text mode
    mov ax, 0x0003
    int 0x10

    ; Enable mouse
    mov ax, 0xC200
    mov bx, 0x0000
    int 0x15

    ; Install mouse handler
    mov ax, 0xC207
    mov bx, mouse_handler
    int 0x15

    ; Display welcome message
    mov si, welcome_msg
    call print_string

    ; Display prompt
    mov si, prompt_msg
    call print_string

    ; Main command loop
main_loop:
    call read_command
    call process_command
    
    ; Display prompt again
    mov si, prompt_msg
    call print_string
    jmp main_loop

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0
    int 0x10
    jmp print_string
.done:
    ret

print_newline:
    mov ah, 0x0E
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    ret

read_command:
    mov di, command_buffer
    mov cx, 0
.read_loop:
    mov ah, 0x00
    int 0x16
    
    cmp al, 13  ; Enter key
    je .done
    
    cmp al, 8   ; Backspace
    je .backspace
    
    cmp cx, 79  ; Max command length
    jae .read_loop
    
    ; Echo character
    mov ah, 0x0E
    int 0x10
    
    ; Store character
    stosb
    inc cx
    jmp .read_loop

.backspace:
    cmp cx, 0
    je .read_loop
    
    dec di
    dec cx
    
    ; Move cursor back
    mov ah, 0x0E
    mov al, 8
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 8
    int 0x10
    
    jmp .read_loop

.done:
    mov al, 0
    stosb
    call print_newline
    ret

process_command:
    mov si, command_buffer
    
    ; Check for "help" command
    mov di, cmd_help
    call compare_strings
    cmp ax, 1
    je .show_help
    
    ; Check for "clear" command
    mov di, cmd_clear
    call compare_strings
    cmp ax, 1
    je .clear_screen
    
    ; Check for "mem" command
    mov di, cmd_mem
    call compare_strings
    cmp ax, 1
    je .show_memory
    
    ; Check for "time" command
    mov di, cmd_time
    call compare_strings
    cmp ax, 1
    je .show_time
    
    ; Unknown command
    mov si, unknown_cmd_msg
    call print_string
    ret

.show_help:
    mov si, help_msg
    call print_string
    ret

.clear_screen:
    mov ax, 0x0003
    int 0x10
    mov si, welcome_msg
    call print_string
    ret

.show_memory:
    mov si, mem_msg
    call print_string
    
    ; Display total memory (simplified - shows 640KB)
    mov si, mem_total_msg
    call print_string
    ret

.show_time:
    mov si, time_msg
    call print_string
    
    ; Get time from BIOS
    mov ah, 0x02
    int 0x1A
    
    ; Convert and display hours
    mov al, ch
    call print_hex_byte
    mov al, ':'
    mov ah, 0x0E
    int 0x10
    
    ; Convert and display minutes
    mov al, cl
    call print_hex_byte
    mov al, ':'
    mov ah, 0x0E
    int 0x10
    
    ; Convert and display seconds
    mov al, dh
    call print_hex_byte
    
    call print_newline
    ret

print_hex_byte:
    push ax
    shr al, 4
    call print_hex_digit
    pop ax
    and al, 0x0F
    call print_hex_digit
    ret

print_hex_digit:
    cmp al, 9
    jle .digit
    add al, 7
.digit:
    add al, '0'
    mov ah, 0x0E
    int 0x10
    ret

compare_strings:
    ; Compare string at SI with string at DI
    ; Returns AX = 1 if equal, 0 if not equal
.loop:
    lodsb
    mov bl, al
    mov al, [di]
    inc di
    
    cmp al, bl
    jne .not_equal
    
    cmp al, 0
    je .equal
    
    jmp .loop

.equal:
    mov ax, 1
    ret

.not_equal:
    mov ax, 0
    ret

mouse_handler:
    pusha
    ; Mouse moved - update cursor position
    mov ah, 0x01
    mov bh, 0
    mov cx, [mouse_x]
    mov dx, [mouse_y]
    int 0x10
    popa
    iret

; Data section
welcome_msg db 'SimpleOS v1.0 - Enhanced Edition', 13, 10
            db 'Type "help" for available commands', 13, 10, 0

prompt_msg db '> ', 0

help_msg db 'Available commands:', 13, 10
         db '  help  - Show this help message', 13, 10
         db '  clear - Clear the screen', 13, 10
         db '  mem   - Show memory information', 13, 10
         db '  time  - Show current time', 13, 10, 0

unknown_cmd_msg db 'Unknown command. Type "help" for available commands.', 13, 10, 0

mem_msg db 'Memory Information:', 13, 10, 0
mem_total_msg db 'Total conventional memory: 640KB', 13, 10, 0

time_msg db 'Current time: ', 0

cmd_help db 'help', 0
cmd_clear db 'clear', 0
cmd_mem db 'mem', 0
cmd_time db 'time', 0

command_buffer times 80 db 0
mouse_x dw 40
mouse_y dw 12

times 512-($-$$) db 0
