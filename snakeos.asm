bits 16
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
variables       equ 0FA00h
snake_direction equ 0FA00h
snake_size      equ 0FA00h+1
snake_y         equ 0FA01h
snake_x         equ 0FA01h+1
apple_y         equ 0FA02h
apple_x         equ 0FA02h+1
row_index       equ 0FA03h
col_index       equ 0FA03h+1
rect_y          equ 0FA04h
rect_x          equ 0FA04h+1
rect_color      equ 0FA05h



;; SETUP:
Setup:
    mov ax, 0013h
    int 10h
    push VGA_START
    pop es          ; ES now points to 0A000h (see mode 13h VGA docs to understand video memory)
    mov di, variables
    mov si, Data        
    mov cl, 6
    rep movsw       ; Move CL data from Data segment to variables
    push es
    pop ds      ; We want DS to point to the data that we just moved.
    jmp short GameLoop

FillScreen:
    mov ax, BG_COLOR
    mov cx, WIDTH*HEIGHT ; set cx to 64000 and use it with stosb to set destination register (di) values
    xor di, di
    rep stosb   ; change every address between di and es (so 0000:A000) to the value at al
    ret

DrawPixel:
    push es
    push 0A000h
    pop es
    mov ax, 320*SLOT_WIDTH*10
    mov bx, ax
    mov ax, 16*SLOT_WIDTH
    add bx, ax
    mov al, APPLE_COLOR
    mov [es:bx], al
    pop es
    ret

DrawApple:
    mov ax, [apple_y]
    mov bx, [apple_x]
    mov cx, APPLE_COLOR

DrawRectangle:
    push es
    push VGA_START
    pop es 
    ;; Code here:
    
    mov [rect_color], cx
    mov [rect_x], bx
    imul ax, ax, WIDTH*SLOT_WIDTH ; Mul Y * WIDTH * SLOT_WIDTH (320 * 10 * Y)
    mov bx, ax
    mov ax, [rect_x]
    imul ax, SLOT_WIDTH
    add bx, ax
    mov [es:bx], cx

    ;; End code    
    pop es
    ret                     

GameLoop:
    call FillScreen
    ; call DrawPixel
    call DrawPixel
    Delay:
        mov ax, [TIMER]  ; 046C address contains the real clock timer logged by the BIOS
        inc ax           ; increment ax until ax matches the current time + 1 tick. 
        .wait:
        cmp [TIMER], ax
        jl .wait

    jmp GameLoop

;; Data Segment
Data: 
db 00h, 00h ; snake_size, snake_direction
db 00h, 00h ; snake_x, snake_y
db COLS/2, ROWS/2 ; apple_x, apple_y
db 00h, 00h ; col_index, row_index
db 00h, 00h ; rect_x, rect_y
db 00h ; rect_x, rect_y

times 510-($-$$) db 0
dw 0AA55h


