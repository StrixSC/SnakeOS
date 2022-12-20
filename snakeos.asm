bits 16 
org 7C00h

; Set the segment registers
mov ax, 0x10  
mov ds, ax    
mov es, ax    
; Set the video mode
mov ah, 0x00  
mov al, 0x13  
int 0x10

; Set the snake starting position
mov dword [snake_x], 160 
mov dword [snake_y], 100 

; Set the direction of the snake (1=right)
mov byte [direction], 2

; Set the length of the snake
mov byte [length], 5     ; Set the starting length of the snake to 5

; Set the speed of the snake
mov byte [delay], 50     ; Set the delay between movements to 50 milliseconds

; Set the score
mov byte [score], 0

; Set the apple position
call set_apple 
jmp main_loop
; Main loop

main_loop:
    call move_snake      
    call check_apple       
    call draw_snake       
    call draw_apple        
    call draw_score       
    call check_collision  
    call delay_func            
    jmp main_loop         

; Function to move the snake
move_snake:
    ; Save the current position of the snake's head
    mov bx, [snake_x]
    mov cx, [snake_y]
    
    ; Update the position of the snake's head based on the direction
    cmp byte [direction], 1  ; Check if the direction is right (1)
    jne move_left 
    add bx, 8     
    jmp update_position ; Jump to the "update_position" label
    
move_left:
    cmp byte [direction], 2  ; Check if the direction is left (2)
    jne move_up   
    sub bx, 8     
    jmp update_position ; Jump to the "update_position" label
    
move_up:
    cmp byte [direction], 3  ; Check if the direction is up (3)
    jne move_down 
    sub cx, 8     
    jmp update_position ; Jump to the "update_position" label

move_down:
    cmp byte [direction], 4  ; Check if the direction is down (4)
    jne update_position ; If the direction is not down, jump to the "update_position" label
    add cx, 8     

; Update the position of the snake
update_position:
    mov [snake_x], bx  ; Set the new X position of the snake
    mov [snake_y], cx  ; Set the new Y position of the snake
    ret          

; Function to check for collision
check_collision:
    ; Check if the snake has collided with the edges of the screen
    cmp dword [snake_x], 8  
    jl game_over      
    cmp dword [snake_x], 312
    jg game_over      
    cmp dword [snake_y], 8  
    jl game_over      
    cmp dword [snake_y], 192
    jg game_over      

    ; Check if the snake has collided with itself
    mov bx, [snake_x] 
    mov cx, [snake_y] 
    
    mov si, snake_positions  ; Set the index register to the start of the snake positions array
    mov di, si            
    
collision_loop:
    cmp si, di    
    je check_done  
    
    mov ax, [si]  
    cmp ax, bx    
    jne check_y    
    
    mov ax, [si+2]
    cmp ax, cx    
    jne check_y    
    
    jmp game_over 

check_y:
    add si, 4     
    jmp collision_loop   ; Jump back to the start of the loop

check_done:
    ret           

; Function to check if the snake has eaten the apple
check_apple:
    ; Check if the snake's head is in the same position as the apple
    mov bx, [snake_x]    
    cmp bx, [apple_x]     
    jne check_done2
    mov cx, [snake_y]    
    cmp cx, [apple_y]     
    jne check_done2
    
    ; If the snake's head is in the same position as the apple, update the snake's position and set a new apple position
    mov bx, [snake_x]    
    mov cx, [snake_y]    
    mov si, snake_positions  ; Set the index register to the start of the snake positions array
    mov ax, [length]
    imul ax, 4
    add si, ax   ; Increment the index by the length of the snake (each position is 4 bytes)
    mov [si], bx   
    mov [si+2], cx 
    inc byte [length]   
    call set_apple  
    inc dword [score]    

check_done2:
    ret            

; Function to draw the snake
draw_snake:
    mov si, snake_positions  ; Set the index register to the start of the snake positions array
    mov di, si            
    
    draw_loop:
    mov bx, [si]  
    mov cx, [si+2]
    call draw_pixel     ; Call the function to draw a pixel at the current position
    
    add si, 4     
    cmp si, di    
    jne draw_loop 
    
    ret           
    
; Function to draw the apple
draw_apple:
    mov bx, [apple_x]    ; Load the X position of the apple
    mov cx, [apple_y]    ; Load the Y position of the apple
    call draw_pixel     ; Call the function to draw a pixel at the current position
    ret           
    
; Function to draw the score
draw_score:
    mov bx, 0     
    mov cx, 0     
    mov ax, [score]     ; Load the current score
    call draw_number    ; Call the function to draw the score
    ret           

; Function to draw a pixel
draw_pixel:
    mov ah, 0x0c  
    int 0x10      
    ret           

; Function to draw a number
draw_number:
    ; Check if the number is greater than 9
    cmp ax, 9     
    jle draw_digit
    
    ; Divide the number by 10 and draw the second digit
    mov dx, 0     
    div word [ten]
    add dl, '0'   
    mov ah, 0x0e  
    int 0x10      
    
; Draw the first digit
draw_digit:
    add al, '0'   
    mov ah, 0x0e  
    int 0x10      
    ret           

; Function to delay the game
delay_func:
    mov bx, [delay]     ; Load the delay value
delay_loop:
    dec bx        
    jnz delay_loop
    ret           

; Function to generate a random number
random:
    mov ah, 0x00  
    int 0x1a      
    ret           
    
; Data definitions
snake_positions  db 20    
snake_x          dw 0     
snake_y          dw 0     
direction        db 0     
length           dw 0     
delay            dw 0     
score            dw 0     
apple_x           dw 0     
apple_y           dw 0     
ten              dw 10    

; Interrupt handler to handle key input
keyboard_handler:
    mov ah, 0x01  
    int 0x16      
    
    cmp al, 0x4b  
    je update_direction  ;right arrow
    cmp al, 0x4d  
    je update_direction  ;left arrow
    cmp al, 0x48  
    je update_direction  ;up arrow
    cmp al, 0x50  
    je update_direction  ;down arrow
    
    ; If the key pressed is not an arrow key, do nothing
    
    ret           

; Function to update the direction of the snake
update_direction:
    cmp al, 0x4b  
    je set_direction    ;right arrow
    cmp al, 0x4d  
    je set_direction    ;left arrow
    cmp al, 0x48  
    je set_direction    ;up arrow
    cmp al, 0x50  
    je set_direction    ;down arrow
    ret           
    
; Function to set the direction of the snake
set_direction:
    mov [direction], al ; Set the direction based on the key pressed
    ret           

; Function to set the position of the apple
set_apple:
    call random   
    mov bx, ax    
    and bx, 31    
    shl bx, 3     
    add bx, 16    
    mov [apple_x], bx    ; Set the X position of the apple
    
    call random   
    mov cx, ax    
    and cx, 15    
    shl cx, 3     
    add cx, 8     
    mov [apple_y], cx    ; Set the Y position of the apple
    
    ret           

; Function to clear the screen
clear_screen:
    mov ah, 0x00  
    mov al, 0x03  
    int 0x10      
    ret           

; ; Function to display the game over screen
game_over:
    call clear_screen   ; Call the function to clear the screen
    
    mov bx, 0     
    mov cx, 10    
    mov ax, 'G'   
    mov ah, 0x0e  
    int 0x10      
    
    inc bx        
    mov ax, 'A'   
    mov ah, 0x0e  
    int 0x10      
    
    inc bx        
    mov ax, 'M'   
    mov ah, 0x0e  
    int 0x10      
    
    inc bx        
    mov ax, 'E'   
    mov ah, 0x0e  
    int 0x10      
    
    inc bx        
    inc bx        
    mov ax, 'O'   
    mov ah, 0x0e  
    int 0x10      
    
    inc bx        
    mov ax, 'V'   
    mov ah, 0x0e  
    int 0x10      
    
    inc bx        
    mov ax, 'E'   
    mov ah, 0x0e  
    int 0x10      
    
    inc bx        
    mov ax, 'R'   
    mov ah, 0x0e  
    int 0x10      
    
    inc bx        
    mov ax, '!'   
    mov ah, 0x0e  
    int 0x10      

; Display the score
    mov bx, 30    
    mov cx, 13    
    mov ax, 'S'   
    mov ah, 0x0e  
    int 0x10      
    
    inc bx        
    mov ax, 'C'   
    mov ah, 0x0e  
    int 0x10      
    
    inc bx        
    mov ax, 'O'   
    mov ah, 0x0e  
    int 0x10      
    
    inc bx        
    mov ax, 'R'   
    mov ah, 0x0e  
    int 0x10      
    
    inc bx        
    mov ax, 'E'   
    mov ah, 0x0e  
    int 0x10      
    
    mov bx, 40    
    mov ax, ':'   
    mov ah, 0x0e  
    int 0x10      
    
    inc bx        
    inc bx        
    mov ax, [score]     ; Load the current score
    call draw_number    ; Call the function to draw the score
    
    hlt           

; End of program
times 510-($-$$) db 0 ; Pad the program with zeros to fill a 512-byte sector
dw 0xaa55       