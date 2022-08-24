bits 16         ; Switch to 16 bit real mode
org 7C00h

WIDTH                   equ 320
HEIGHT                  equ 200
COLS                    equ 32 
ROWS                    equ 20
SLOT_WIDTH              equ 10
APPLE_SIZE              equ 1
BG_COLOR                equ 11h
APPLE_COLOR             equ 0Ch
SNAKE_COLOR             equ 0Ah
TIMER                   equ 046Ch
VGA_START               equ 0A000h
SNAKE_DIR_UP            equ 00h
SNAKE_DIR_DOWN          equ 01h
SNAKE_DIR_RIGHT         equ 10h
SNAKE_DIR_LEFT          equ 11h

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
    mov ax, BG_COLOR
    call FillScreen
    call GetPlayerInput
    call UpdateFrame
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
    cmp ax, SNAKE_DIR_DOWN
    jz MoveSnake_Down
    cmp ax, SNAKE_DIR_UP
    jz MoveSnake_Up
    cmp ax, SNAKE_DIR_RIGHT
    jz MoveSnake_Right
    mov ax, [snake_x]
    dec ax
    cmp ax, 00h
    jz GameOver
    mov [snake_x], ax
    jmp short UpdateFrameEnd
    MoveSnake_Right:
    mov ax, [snake_x]
    inc ax
    cmp ax, WIDTH
    jz GameOver
    mov [snake_x], ax
    jmp short UpdateFrameEnd
    MoveSnake_Down:
    mov ax, [snake_y]
    dec ax
    cmp ax, HEIGHT
    jz GameOver
    mov [snake_y], ax
    jmp short UpdateFrameEnd
    MoveSnake_Up:
    mov ax, [snake_y]
    inc ax
    cmp ax, 00h
    jz GameOver
    mov [snake_y], ax
    jmp short UpdateFrameEnd
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

GetPlayerInput:
    xor ax, ax
    int 16h
    mov bl, 'a'
    mov cl, 'w'
    mov dl, 'd'
    cmp al, bl
    jz ChangeDirection_Left
    cmp al, dl
    jz ChangeDirection_Up
    cmp al, bl
    jz ChangeDirection_Right
    mov [snake_direction], byte SNAKE_DIR_DOWN
    jmp short GetPlayerInputEnd
    ChangeDirection_Left:
    mov [snake_direction], byte SNAKE_DIR_LEFT
    jmp short GetPlayerInputEnd
    ChangeDirection_Up:
    mov [snake_direction], byte SNAKE_DIR_UP
    jmp short GetPlayerInputEnd
    ChangeDirection_Right:
    mov [snake_direction], byte SNAKE_DIR_RIGHT
GetPlayerInputEnd:
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
    mov ax, 00h
    call FillScreen
    jmp GameOver

FillScreen:
    mov cx, WIDTH*HEIGHT ; set cx to 64000 and use it with stosb to set destination register (di) values
    xor di, di
    rep stosb   ; change every address between di and es (so 0000:A000) to the value at al
    ret

;; Data Segment
Data: 
db 01h                  ; snake_size
db 00h                  ; snake_direction 
db 10h                  ; snake_y
db HEIGHT/2,            ; apple_y
dw 0010h                ; snake_x
dw WIDTH/2              ; apple_x

times 510-($-$$) db 0
dw 0AA55h