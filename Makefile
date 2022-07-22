BIN_DIR=build
SRC_DIR=src
IN_FILE=snakeos.s
PROJECT_NAME=snakeos
ENTRY_SYMBOL=_start

all:
	mkdir -p ${BIN_DIR}
	as -msyntax=intel -o ${BIN_DIR}/${PROJECT_NAME}.o ${SRC_DIR}/${PROJECT_NAME}.s
	ld -o ${BIN_DIR}/${PROJECT_NAME} --oformat binary --entry ${ENTRY_SYMBOL} ${BIN_DIR}/${PROJECT_NAME}.o
	ls -lh ${BIN_DIR}/${PROJECT_NAME}
clean:
	rm -rf ${BIN_DIR}/*.o ${BIN_DIR}/*.out ${BIN_DIR}/*.bin ${BIN_DIR}/${PROJECT_NAME}