BUILD_DIR=build
SRC_DIR=src
IN_FILE=${SRC_DIR}/boot.s
OUT_FILE=${BUILD_DIR}/boot.o
PROJECT_NAME=snakeos
ENTRY_SYMBOL=_start

all:
	as -o ${OUT_FILE} ${IN_FILE}
	ld -o ${PROJECT_NAME} --format binary --entry ${ENTRY_SYMBOL} ${OUT_FILE}
