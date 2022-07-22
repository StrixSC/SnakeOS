.code16
.global _start  
.intel_syntax noprefix

_start:
    # Set video mode - 320x200 - mode 13h
    mov ah, 0x00
    mov al, 0x13
    int 0x10

    # Draw the pixel
    mov ah, 0x0c
    mov cx, 160
    mov dx, 100
    mov al, 4
    int 0x10

    # Wait for keypress before exiting program
    mov ah, 0x00
    int 0x16

    # Return to text mode
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    # Terminate the program
    mov ah, 0x4c
    int 0x21


.fill 510-(.-_start), 1, 0
.word 0xaa55