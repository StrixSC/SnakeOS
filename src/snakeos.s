# https://50linesofco.de/post/2018-02-28-writing-an-x86-hello-world-bootloader-with-assembly
.code16
.global _start  

_start:
    jmp _start
    
.fill 510-(.-_start), 1, 0
.word 0xaa55