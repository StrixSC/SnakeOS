.PHONY: all

all:
	nasm -f bin -o snakeos snakeos.asm
run:
	qemu-system-x86_64.exe -drive file=snakeos,format=raw,index=0,media=disk
clean:
	rm -rf *.o *.out *.bin snakeos