bits 16
org 7C00h

WIDTH       equ 320
HEIGHT      equ 200
COLS        equ 40 
ROWS        equ 25
APPLE_SIZE  equ 5
BG_COLOR    equ 11h 
APPLE_COLOR equ 0Ch
SNAKE_COLOR equ 0Ah
variables   equ 0FA00h
snake_size  equ 0FA00h
snake_x     equ 0FB00h
snake_y     equ 0FC00h
snake_dx    equ 0FD00h
snake_dy    equ 0FE00h
apple_x     equ 0FF00h
apple_y     equ 10000h

;; SETUP:
Setup:
    mov ax, 0013h
    int 10h
    push 0A000h
    pop es  ; ES now points to 0A000h (see mode 13h VGA docs to understand video memory)
    mov di, variables
    mov si, Data        
    mov cl, 7           
    rep movsw           
    push es
    pop ds

FillScreen:
    mov ax, [snake_size]
    mov cx, WIDTH*HEIGHT ; set cx to 64000 and use it with stosb to set destination register (di) values
    xor di, di
    rep stosb   ; change every address between di and es (so 0000:A000) to the value at al
    
GameLoop:
    Delay:
    mov ax, [046Ch]  ; 046C address contains the real clock timer logged by the BIOS
    inc ax           ; increment ax until ax matches the current time + 1 tick. 
    .wait:
    cmp [046Ch], ax
    jl .wait

    call FillScreen ; After filling screen, edi -> 0FA00h

    ; Draw Apple
    jmp GameLoop

;; Data Segment
Data: 
db BG_COLOR ; snake_size
db 00h ; snake_x
db 00h ; snake_y
db 01h ; snake_dx
db 01h ; snake_dy
db WIDTH/2 ; apple_x
db HEIGHT/2 ; apple_y

times 510-($-$$) db 0
dw 0AA55h

