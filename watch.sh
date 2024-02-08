#!/bin/bash
compile() {
	rgbasm -L -o main.o main.asm
	rgbasm -L -o ./objects/paddle.o ./objects/paddle.asm
	rgblink -o brickbreak.gb main.o
	rgbfix -v -p 0xFF brickbreak.gb
	rgblink -n brickbreak.sym main.o
}

compile

# Watch for changes in all .asm files
fswatch -o */**.asm | while read -r; do
	compile
done
