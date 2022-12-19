bits 16 ; Switch to 16 bit real mode
org 7C00h

WIDTH               equ 320
HEIGHT              equ 200
COLS                equ 32
ROWS                equ 20
SLOT_WIDTH          equ 10
APPLE_SIZE          equ 1
BG_COLOR            equ 11h
APPLE_COLOR         equ 0Ch
SNAKE_COLOR         equ 0Ah
TIMER               equ 046Ch
VGA_START           equ 0A000h
SNAKE_DIR_UP        equ 00h
SNAKE_DIR_DOWN      equ 01h
SNAKE_DIR_RIGHT     equ 10h
SNAKE_DIR_LEFT      equ 11h

; Variable addresses:
snake_size          equ 0FA00h
snake_direction     equ 0FA01h
snake_y             equ 0FA02h
apple_y             equ 0FA03h
snake_x             equ 0FA04h
apple_x             equ 0FA06h

Setup:
    mov ax, 0013h
    int 10h
    push VGA_START
    pop es  ; ES now points to 0A000h (see mode 13h VGA docs to understand video memory)
    mov di, snake_size
    mov si, Data
    mov cl, 04h
    rep movsb
    mov cl, 02h
    rep movsw ; Move CL data from Data segment to variables
    push es
    pop ds ; We want DS to point to the data that we just moved.

GameLoop:
    mov ax, BG_COLOR
    call FillScreen
    call DrawApple
    call DrawSnake
    call UpdateFrame
    call CheckForCollision
    call GetPlayerInput
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
    jmp UpdateFrameEnd
MoveSnake_Right:
    mov ax, [snake_x]
    inc ax
    cmp ax, WIDTH
    jz GameOver
    mov [snake_x], ax
    jmp UpdateFrameEnd
MoveSnake_Down:
    mov ax, [snake_y]
    dec ax
    cmp ax, HEIGHT
    jz GameOver
    mov [snake_y], ax
    jmp UpdateFrameEnd
MoveSnake_Up:
    mov ax, [snake_y]
    inc ax
    cmp ax, 00h
    jz GameOver
    mov [snake_y], ax
    jmp UpdateFrameEnd
UpdateFrameEnd:
    ret

DrawSnake:
    mov cx, [snake_x]
    mov dx, [snake_y]
    mov al, SNAKE_COLOR
    call DrawPixel
    mov ax, [snake_size]
    dec ax
    mov [snake_size], ax
    mov ax, [snake_direction]
    cmp ax, SNAKE_DIR_RIGHT
    jz DrawSnake_Right
    cmp ax, SNAKE_DIR_LEFT
    jz DrawSnake_Left
    cmp ax, SNAKE_DIR_UP
    jz DrawSnake_Up
    mov dx, [snake_y]
    dec dx
    mov [snake_y], dx
    jmp DrawSnakeEnd
DrawSnake_Right:
    mov cx, [snake_x]
    inc cx
    mov [snake_x], cx
    jmp DrawSnakeEnd
DrawSnake_Left:
    mov cx, [snake_x]
    dec cx
    mov [snake_x], cx
    jmp DrawSnakeEnd
DrawSnake_Up:
    mov dx, [snake_y]
    inc dx
    mov [snake_y], dx
    jmp DrawSnakeEnd
DrawSnakeEnd:
    ret

DrawApple:
    mov cx, [apple_x]
    mov dx, [apple_y]
    mov al, APPLE_COLOR
    call DrawPixel
    ret

DrawPixel:
    mov ah, 0ch
    int 10h
    ret

GetPlayerInput:
    xor ax, ax
    int 16h
    cmp al, 'a'
    jz ChangeDirection_Left
    cmp al, 'w'
    jz ChangeDirection_Up
    cmp al, 'd'
    jz ChangeDirection_Right
    mov [snake_direction], byte SNAKE_DIR_DOWN
    jmp GetPlayerInputEnd
    
ChangeDirection_Left:
    mov [snake_direction], byte SNAKE_DIR_LEFT
    jmp GetPlayerInputEnd

ChangeDirection_Up:
    mov [snake_direction], byte SNAKE_DIR_UP
    jmp GetPlayerInputEnd

ChangeDirection_Right:
    mov [snake_direction], byte SNAKE_DIR_RIGHT
    jmp GetPlayerInputEnd
    
GetPlayerInputEnd:
    ret

CheckForCollision:
    mov ax, [apple_x]
    cmp ax, [snake_x]
    jz Collision
    mov ax, [apple_y]
    cmp ax, [snake_y]
    jz Collision
    ret
    Collision:
    mov ax, [snake_size]
    inc ax
    mov [snake_size], ax
    call GenerateApple
    ret

GenerateApple:
    mov ax, APPLE_SIZE
    mov bx, SLOT_WIDTH
    mul bx
    mov [apple_x], ax
    mov ax, APPLE_SIZE
    mov bx, SLOT_WIDTH
    mul bx
    mov [apple_y], ax
    ret

FillScreen:
    mov cx, WIDTH*HEIGHT ; set cx to 64000 and use it with stosb to set destination register (di) values
    xor di, di
    rep stosb   ; change every address between di and es (so 0000:A000) to the value at al
    ret

GameOver:
    mov ax, 0013h
    int 10h
    mov si, GameOverText
    call PrintString
    jmp GameOverEnd
GameOverEnd:
    ret

PrintString:
    lodsb
    cmp al, 0
    je PrintStringEnd
    mov ah, 0ch
    int 10h
    jmp PrintString
    PrintStringEnd:
    ret

GameOverText db 'Game Over', 0

Data:
    dd          0100h
    dd          SNAKE_DIR_DOWN
    dd          0100h
    dd          0100h
    dd          0100h
    dd          0100h

times 510-($-$$) db 0
dw 0xAA55