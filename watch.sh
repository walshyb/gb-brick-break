#!/bin/bash
compile() {
	# Compile the main file
	rgbasm -o main.o main.asm

	# Compile the paddle
	rgbasm -o ./objects/paddle.o ./objects/paddle.asm
	rgbasm -o ./objects/ball.o ./objects/ball.asm

	# Link all the objects and output a .gb file
	rgblink -m brickbreak.map -n brickbreak.sym -o brickbreak.gb main.o ./objects/*.o

	# Fix the header (adds checksum, logo, and ROM size) of the .gb file
	rgbfix -v -p 0xFF brickbreak.gb
}

compile

# Watch for changes in all .asm files
fswatch -o */**.asm | while read -r; do
	compile
done
