bits 16
org 7C00h

WIDTH           equ 320
HEIGHT          equ 200
COLS            equ 40 
ROWS            equ 25
COL_ROW_SIZE    equ 8
APPLE_SIZE      equ 10
BG_COLOR        equ 11h 
APPLE_COLOR     equ 0Ch
SNAKE_COLOR     equ 0Ah
TIMER           equ 046Ch
variables       equ 0FA00h
snake_size      equ 0FA00h      ; Each memory address is a double word
snake_dx        equ 0FA01h
snake_dy        equ 0FA02h
apple_y         equ 0FA03h
snake_y         equ 0FA04h
apple_x         equ 0FA05h
snake_x         equ 0FA06h

;; SETUP:
Setup:
    mov ax, 0013h
    int 10h
    push 0A000h
    pop es          ; ES now points to 0A000h (see mode 13h VGA docs to understand video memory)
    mov di, variables
    mov si, Data        
    mov cl, 5           
    rep movsb       ; Moves the data from si to di and increments both si and di  
    mov cl, 2
    rep movsw
    push es
    pop ds      ; We want DS to point to the data that we just moved.
    jmp short GameLoop

FillScreen:
    mov ax, [snake_size]
    mov cx, WIDTH*HEIGHT ; set cx to 64000 and use it with stosb to set destination register (di) values
    xor di, di
    rep stosb   ; change every address between di and es (so 0000:A000) to the value at al
    ret

DrawApple:
    mov cx, [apple_x]
    sub cx, APPLE_SIZE/2
    mov [apple_x], cx
    mov dx, [apple_y]
    sub dx, APPLE_SIZE/2
    mov [apple_y], dx
    mov ax, 0c0ch

DrawSquare:
    int 10h
    inc cx
    mov bx, cx
    sub bx, [apple_x]
    cmp bx, APPLE_SIZE
    jb DrawSquare
    mov cx, [apple_x]
    inc dx
    mov bx, dx
    sub bx, [apple_y]
    cmp bx, APPLE_SIZE
    jb DrawSquare
    ret

; DrawSquare:
;     xor bx, bx
;     jmp short draw_cols
;     draw_rows:
;         inc bx
;         push bx
;         cmp [sp], [sp-1]
;         draw_cols:
;             cmp bx, [sp]
;             je draw_rows
;             push ax
;             int 10h
;             pop ax
;             inc cx
;             jmp draw_cols
;     reset:
;         pop bx

GameLoop:
    call FillScreen ; After filling screen, edi -> 0FA00h
    call DrawApple
    Delay:
        mov ax, [TIMER]  ; 046C address contains the real clock timer logged by the BIOS
        inc ax           ; increment ax until ax matches the current time + 1 tick. 
        .wait:
        cmp [TIMER], ax
        jl .wait

    jmp GameLoop

;; Data Segment
Data: 
db BG_COLOR ; snake_size
db 01h ; snake_dx
db 01h ; snake_dy
db HEIGHT/2 ; apple_y
db 00h ; snake_y
dw WIDTH/2 ; apple_x
db 00h ; snake_x

times 510-($-$$) db 0
dw 0AA55h

