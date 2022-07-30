        org 7C00h

        jmp short Start ;Jump over the data (the 'short' keyword makes the jmp instruction smaller)

TitleScreen:   db "SnakeOS! "
EndTitleScreen:

; Function: DrawPixel()
; Draws a pixel at a position on the screen
; Expects 3 registers to contain values: 
; cx must contain the column
; dx must contain the row
; al must contain the numeric value of the color to draw (see https://www.fountainware.com/EXPL/vga_color_palettes.htm)
DrawPixel:
        mov ah, 0ch
        int 10h
        mov eax, 00h
        ret
EndDrawPixel:

; Function FillScreen
; Fills the entire screen the color of al
; Expects 1 register to contain values:
; al must contain the numeric value of the color to draw
FillScreen:
        mov ah, 0ch
        mov cx, 00h
        mov dx, 00h
        jmp RowLoop
        ColumnLoop:
        mov dx, 00h
        inc cx
        cmp cx, 320
        je EndFillScreen
        RowLoop:
        int 10h
        inc dx
        cmp dx, 160
        je ColumnLoop
        jmp RowLoop
EndFillScreen:
        ret

Start:  
        mov ah, 00h
        mov al, 13h     ; Visual Mode 320x160 VGA
        int 10h 

        mov cx, 160     
        mov dx, 100     
        mov al, 04h       
        call FillScreen


times 0200h - 2 - ($ - $$)  db 0    ;Zerofill up to 510 bytes

        dw 0AA55h       ;Boot Sector signature