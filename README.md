# Game Boy BrickBreak

This is my variation of a "brick breaking" games for the Game Boy. I'm following along the guide from [gbdev.io](https://gbdev.io). My goal is to become more comfortable working with assembly; the specific flavor of assembly is the Rednex Game Boy Assembly from [Rednex Game Boy Developemt System](https://rgbds.gbdev.io/).

I've been wanting to work with assembly for awhile because it seems interesting and that intersected with my interest of Game Boy (/Color) ROM hacks.

## Setup

(For when I forget)

```
# Compile the assembly
rgbasm -L -o main.o main.asm

# Create the ROM
rgblink -o brickbreak.gb main.o

# Add header info to ROM
# "Fixes" the header
rgbfix -v -p 0xFF brickbreak.gb

# Create symbols file so debugger
# can use label names
rgblink -n brickbreak.sym main.o
```

## Todo:

- Setup auto compile and rebuild on save
