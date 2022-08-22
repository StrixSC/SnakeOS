bits 16
org 7C00h

WIDTH           equ 320
HEIGHT          equ 200
COLS            equ 40 
ROWS            equ 25
COL_ROW_SIZE    equ 8
APPLE_SIZE      equ 4
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

    ;;
    ;;  position_x = *apple_x
    ;;  for(int i = 0; i < APPLE_SIZE; i++) 
    ;;  {
    ;;      position_x++
    ;;      printf(int 10h)
    ;;  }
    ;;
DrawApple:
    mov cx, [apple_x]
    mov dx, [apple_y]
    mov ah, 0Ch
    int 10h
    xor bl, bl
    .DrawAppleY:
        cmp bl, APPLE_SIZE
        je .end
        int 10h
        inc dx
        inc bl
        xor al, al
        .DrawAppleX:
            cmp al, APPLE_SIZE
            je .DrawAppleY   
            int 10h
            inc cx
            inc al
    .end:
        ret

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

