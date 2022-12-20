# Snake OS

[WIP]

## Setup 

```
make
make run
```


WIDTH, the width of the screen, equal to 320
HEIGHT, the height of the screen, equal to 200
cols, the number of columns that we divide the width size by, equal to 32
rows, the number of rows that we divide the height size by, equal to 200
SLOT_WIDTH, the width of the slots made by the division in columns and rows, equal to 10 
APPLE_SIZE, the size of the apple that the snake is looking to eat.
BG_COLOR, the background color of the screen, set at 11h
APPLE_COLOR, the color of the apple the snake wants to eat, set at 0Ch
SNAKE_COLOR, the color of the snake, set at 0Ah
TIMER, the timer address in memory, set at 046Ch, used for delays
VGA_START, the starting memory of the VGA addressing slot, set at 0A000h
SNAKE_DIR_UP, a random value to define the snake going upwards, set at 00h
SNAKE_DIR_DOWN, a random value to define the snake going downwards, set at 01h
SNAKE_DIR_DOWN, a random value to define the snake going downwards, set at 01h
SNAKE_DIR_RIGHT, a random value to define the snake going right, set at 10h
SNAKE_DIR_LEFT, a random value to define the snake going left, set at 11h

Variable addresses:
snake_size located at address 0FA00h
snake_direction located at address 0FA01h
snake_y located at address 0FA02h
apple_y located at address 0FA03h
snake_x located at address 0FA04h
apple_x located at address 0FA06h
