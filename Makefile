BIN_DIR=build
SRC_DIR=src
IN_FILE=snakeos.asm
PROJECT_NAME=snakeos
ENTRY_SYMBOL=_start

all:
	mkdir -p ${BIN_DIR}
	nasm -o ${BIN_DIR}/${PROJECT_NAME} ${SRC_DIR}/${IN_FILE}
	ls -lh ${BIN_DIR}/${PROJECT_NAME}
clean:
	rm -rf ${BIN_DIR}/*.o ${BIN_DIR}/*.out ${BIN_DIR}/*.bin ${BIN_DIR}/${PROJECT_NAME}