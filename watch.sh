#!/bin/bash
compile() {
	rgbasm -L -o main.o main.asm
	rgblink -o brickbreak.gb main.o
	rgbfix -v -p 0xFF brickbreak.gb
	rgblink -n brickbreak.sym main.o
}

fswatch -o main.asm | while read -r; do
	compile
done
