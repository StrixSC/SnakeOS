bits 16         ; Switch to 16 bit real mode
org 7C00h

WIDTH           equ 320
HEIGHT          equ 200
COLS            equ 32 
ROWS            equ 20
SLOT_WIDTH      equ 10
APPLE_SIZE      equ 1
BG_COLOR        equ 11h
APPLE_COLOR     equ 0Ch
SNAKE_COLOR     equ 0Ah
TIMER           equ 046Ch
VGA_START       equ 0A000h

; Variable addresses:
snake_size      equ 0FA00h 
snake_direction equ 0FA01h 
snake_y         equ 0FA02h 
apple_y         equ 0FA03h 
snake_x         equ 0FA04h 
apple_x         equ 0FA06h 

Setup:
    mov ax, 0013h
    int 10h
    push VGA_START
    pop es          ; ES now points to 0A000h (see mode 13h VGA docs to understand video memory)
    mov di, snake_size
    mov si, Data        
    mov cl, 04h
    rep movsb
    mov cl, 02h
    rep movsw       ; Move CL data from Data segment to variables
    push es
    pop ds      ; We want DS to point to the data that we just moved.

GameLoop:
    call FillScreen
    call UpdateFrame
    call CheckCollision
    call DrawApple
    call DrawSnake
    Delay:
        mov ax, [CS:TIMER] 
        inc ax
        .wait:
            cmp [CS:TIMER], ax
            jl .wait
    jmp GameLoop

UpdateFrame:
    mov ax, [snake_direction]
    cmp ax, 00h
    jne Snake_MoveVertically
    mov ax, [snake_x]
    inc ax
    mov [snake_x], ax
    jmp short UpdateFrameEnd
    Snake_MoveVertically:
    mov ax, [snake_y]
    inc ax
    mov [snake_y], ax
UpdateFrameEnd:
    ret

DrawSnake:
    mov cx, [snake_x]
    mov dx, [snake_y]
    mov al, SNAKE_COLOR
    jmp short DrawPixel

DrawApple:
    mov cx, [apple_x]
    mov dx, [apple_y]
    mov al, APPLE_COLOR

DrawPixel:
    mov ah, 0ch
    int 10h
    ret

CheckCollision:
    mov ax, [snake_x]
    cmp ax, WIDTH
    je GameOver
    mov ax, [snake_y]
    cmp ax, HEIGHT
    je GameOver
    ret
    
GameOver:
    hlt

FillScreen:
    mov ax, BG_COLOR
    mov cx, WIDTH*HEIGHT ; set cx to 64000 and use it with stosb to set destination register (di) values
    xor di, di
    rep stosb   ; change every address between di and es (so 0000:A000) to the value at al
    ret

;; Data Segment
Data: 
db 00h                  ; snake_size
db 01h                  ; snake_direction 
db 00h                  ; snake_y
db HEIGHT/2,            ; apple_y
dw 0000h                  ; snake_x
dw WIDTH/2              ; apple_x

times 510-($-$$) db 0
dw 0AA55h