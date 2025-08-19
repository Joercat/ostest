
[BITS 16]
[ORG 0x7C00]

start:
    ; Set up segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Load kernel from sector 2
    mov ah, 0x02    ; Read sectors
    mov al, 1       ; Number of sectors
    mov ch, 0       ; Cylinder
    mov cl, 2       ; Sector
    mov dh, 0       ; Head
    mov bx, 0x1000  ; Load address
    int 0x13

    ; Jump to kernel
    jmp 0x1000

    ; Fill remainder of sector with zeros and add boot signature
    times 510-($-$$) db 0
    dw 0xAA55
