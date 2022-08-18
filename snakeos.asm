org 7C00h

WIDTH equ 320
HEIGHT equ 200
COLS equ 40 
ROWS equ 25
APPLE_SIZE equ 5
BG_COLOR equ 11h 
APPLE_COLOR equ 0Ch
SNAKE_COLOR equ 0Ah

Setup:
        mov ax, 00h
        mov ds, ax
        mov ax, 00013h ; mode 13h (VGA) 320x200x256 (320 columns, 200 rows, 256 colors).
        int 10h
        push 0A000h
        pop es
        jmp short GameLoop

FillScreen:
        mov cx, WIDTH*HEIGHT    ; Set cx to 64000
        xor di, di              ; reset di to 0
        rep stosb               ; Write AL to [DI] a total of CX times.
        ret

ClearScreen:
        mov al, 00h             ; set color to VGA Black
        call FillScreen  
        ret

DrawApple:
        inc cx          
        mov ax, cx
        sub ax, [apple_x]
        cmp ax, APPLE_SIZE
        jng DrawApple 
        mov cx, [apple_x]
        inc dx
        mov ax, dx
        sub ax, [apple_y]
        cmp ax, APPLE_SIZE
        jng DrawApple
        mov al, APPLE_COLOR
        ret

GameLoop:
        mov al, BG_COLOR
        call FillScreen
        ; mov [apple_y], word 100
        ; mov [apple_x], word 200
        mov al, APPLE_COLOR
        mov cx, [apple_x]
        mov dx, [apple_y]
        ; call DrawApple
        int 10h
        ; TODO: DrawSnake
        ; TODO: Move Snake
        ; TODO: Check Collision
                ; TODO: Snake + Wall
                ; TODO: Snake + Apple
        ; TODO: Get player input
        jmp GameLoop

times 0200h - 02h - ($ - $$) db 0
dw 0AA55h

snake_size:             dw 1
snake_orientation:      dw 0
snake_velocity:         dw 1
snake_x:                dw 0
snake_y:                dw 0
snake_dx:               dw 0
snake_dy:               dw 0
apple_x:                dw WIDTH/2
apple_y:                dw HEIGHT/2