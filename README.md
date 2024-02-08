# Game Boy BrickBreak

This is my variation of a "brick breaking" games for the Game Boy. I'm following along the guide from [gbdev.io](https://gbdev.io). My goal is to become more comfortable working with assembly; the specific flavor of assembly is the Rednex Game Boy Assembly from [Rednex Game Boy Developemt System](https://rgbds.gbdev.io/).

I've been wanting to work with assembly for awhile because it seems interesting and that intersected with my interest of Game Boy (/Color) ROM hacks.

## Setup
(For when I forget)


### Build Requirements

**[RGBDS](https://rgbds.gbdev.io/install/)** (Rednex Game Boy Development System), to have the tools to compile our game:
```
brew install rgbds
```

**fswatch** for file watching:
```
# Mac OS X
brew install fswatch
```

**[Emulicious](https://emulicious.net/)** emulator + debugger. I setup an alias `emu` that calls the Emulicious -jar in my .zshrc:

```
alias emu='java -jar /Applications/Emulicious/Emulicious.jar'
```

### Run compile on save script:

In one shell, run the `watch` script that listens for when our assembly changes so it compiles:

```
./watch.sh
```

In another shell, run the Emulicious emulator:
```
emu brickbreak.gb
```
*Note*: Emulicious can auto restart the ROM on .gb update by ensuring File -> "Reload ROM On Change" is selected.

### If you want to run manually (not on save):

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

[x] Setup auto compile and rebuild on save
[ ] Add score
[ ] Add start screen
[ ] Add more levels
[ ] Elongate paddle
