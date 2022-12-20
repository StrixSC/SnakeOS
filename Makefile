.PHONY: all

all:
	nasm -f bin -o snakeos snakeos2.asm
run:
	qemu-system-x86_64.exe -drive file=snakeos,format=raw,index=0,media=disk
size:
	xxd snakeos
clean:
	rm -rf *.o *.out *.bin snakeos