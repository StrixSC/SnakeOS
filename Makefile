BIN_DIR=bin
SRC_DIR=src
IN_FILE=${SRC_DIR}/boot.s
OUT_FILE=${BIN_DIR}/boot.o
PROJECT_NAME=${BIN_DIR}/snakeos
ENTRY_SYMBOL=_start

all:
	as -o ${OUT_FILE} ${IN_FILE}
	ld -o ${PROJECT_NAME} --format binary --entry ${ENTRY_SYMBOL} ${OUT_FILE}
