.PHONY: all

all:
	nasm -f bin -o snakeos snakeos.asm
run:
	qemu-system-x86_64.exe -drive file=snakeos,format=raw,index=0,media=disk
clean:
	rm -rf ${BIN_DIR}/*.o ${BIN_DIR}/*.out ${BIN_DIR}/*.bin ${BIN_DIR}/${PROJECT_NAME}