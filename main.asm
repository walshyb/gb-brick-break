include "hardware.inc"

; Constants
DEF BRICK_LEFT EQU $05
DEF BRICK_RIGHT EQU $06
DEF BLANK_TILE EQU $08

; Make space for the ROM header
; Header info needs to be at address $100
; Appropriate info added by rgbfix  
SECTION "HEADER", ROM0[$100]
  jp EntryPoint
  ds $150 - @

EntryPoint:
  ; Don't turn off LCD outside of VBlank

WaitVBlank:
  ld a, [rLY]
  cp 144
  jp c, WaitVBlank

  ; Turn the LCD Off
  ld a, 0
  ld [rLCDC], a

; Copy the tile data
ld de, Tiles
ld hl, $9000
ld bc, TilesEnd - Tiles
call Memcopy

; Copy the tilemap
ld de, Tilemap
ld hl, $9800
ld bc, TilemapEnd - Tilemap
call Memcopy

; Prep loading of the Paddle object
ld a, 0
ld b, 160
ld hl, _OAMRAM

; Copy the paddle tile data
ld de, Paddle
ld hl, $8000
ld bc, PaddleEnd - Paddle
call Memcopy

; Copy the ball tile
ld de, Ball
ld hl, $8010
ld bc, BallEnd - Ball
call Memcopy

; Initialize the paddle sprite in OAM
ld hl, _OAMRAM
ld a, 128 + 16
ld [hli], a
ld a, 16 + 8
ld [hli], a
ld a, 0
ld [hli], a
ld [hli], a

; Now initialize the ball sprite
ld a, 100 + 16
ld [hli], a
ld a, 32 + 8
ld [hli], a
ld a, 1
ld [hli], a
ld a, 0
ld [hli], a

; The ball starts out going up and to the right
ld a, 1
call UpdateBallMomentumX
ld a, -1
call UpdateBallMomentumY

; Clear Object Attribute Memory
; because OAM is filled with junk on init
ClearOam:
  ld [hli], a
  dec b
  jp nz, ClearOam

; Draw paddle object by writing its properties
ld hl, _OAMRAM
ld a, 128 + 16 ; Changes Y position
ld [hli], a
ld a, 16 + 8 ; Changes X position
ld [hli], a
ld a, 0
ld [hli], a
ld [hl], a

; Turn the LCD on,
; Enabling, LCD, BG Pallet, and Objects
ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
ld [rLCDC], a

; During the first (blank) frame, initialize display registers
ld a, %11100100
ld [rBGP], a

; Initialize object pallet
ld a, %11100100
ld [rOBP0], a

; Initialize frame counter to 0
ld a, 0
ld [wFrameCounter], a


Main::
  ld a, [rLY]
  cp 144
  jp nc, Main
WaitVBlank2:
  ld a, [rLY]
  cp 144
  jp c, WaitVBlank2

  ; Only update graphics every 15 frames
  ld a, [wFrameCounter]
  inc a
  ld [wFrameCounter], a
  cp a, 15 ; Every 15 frames (a quarter of a second), run the following code
  jp nz, Main
  
  ; Reset the frame counter back to 0
  ld a, 0
  ld [wFrameCounter], a

  ; Add the ball's momentum to its position in OAM.
	call GetBallMomentumX
  ld b, a
  ld a, [_OAMRAM + 5]
  add a, b
  ld [_OAMRAM + 5], a

	call GetBallMomentumY
  ld b, a
  ld a, [_OAMRAM + 4]
  add a, b
  ld [_OAMRAM + 4], a

BounceOnTop:
  ; Remember to offset the OAM position!
  ; (8, 16) in OAM coordinates is (0, 0) on the screen.
  ld a, [_OAMRAM + 4]
  sub a, 16 + 1
  ld c, a
  ld a, [_OAMRAM + 5]
  sub a, 8
  ld b, a
  call GetTileByPixel ; Returns tile address in hl
  ld a, [hl]
  call IsWallTile
  jp nz, BounceOnRight
  call CheckAndHandleBrick
  ld a, 1
	call UpdateBallMomentumY

BounceOnRight:
  ld a, [_OAMRAM + 4]
  sub a, 16
  ld c, a
  ld a, [_OAMRAM + 5]
  sub a, 8 - 1
  ld b, a
  call GetTileByPixel
  ld a, [hl]
  call IsWallTile
  jp nz, BounceOnLeft
  call CheckAndHandleBrick
  ld a, -1
	call UpdateBallMomentumX

BounceOnLeft:
  ld a, [_OAMRAM + 4]
  sub a, 16
  ld c, a
  ld a, [_OAMRAM + 5]
  sub a, 8 + 1
  ld b, a
  call GetTileByPixel
  ld a, [hl]
  call IsWallTile
  jp nz, BounceOnBottom
  call CheckAndHandleBrick
  ld a, 1
	call UpdateBallMomentumX

BounceOnBottom:
  ld a, [_OAMRAM + 4]
  sub a, 16 - 1
  ld c, a
  ld a, [_OAMRAM + 5]
  sub a, 8
  ld b, a
  call GetTileByPixel
  ld a, [hl]
  call IsWallTile
  jp nz, BounceDone
  call CheckAndHandleBrick
  ld a, -1
	call UpdateBallMomentumY
BounceDone:

	call HandlePaddleBounce

  ; Check the current keys every frame and move left or right
  call UpdateKeys

	; TODO:
	; See if I can convert this to func call
	jp CheckKeys

  
Done:
  jp Done


; Checks if a brick was collided with and breaks it if possible.
; @param hl: address of tile.
CheckAndHandleBrick:
  ld a, [hl]
  cp a, BRICK_LEFT
  jr nz, CheckAndHandleBrickRight
  ; Break a brick from the left side.
  ld [hl], BLANK_TILE
  inc hl
  ld [hl], BLANK_TILE
CheckAndHandleBrickRight:
  cp a, BRICK_RIGHT
  ret nz
  ; Break a brick from the right side.
  ld [hl], BLANK_TILE
  dec hl
  ld [hl], BLANK_TILE
  ret

; Convert a pixel position to a tilemap address
; hl = $9800 + X + Y * 32
; @param b: X
; @param c: Y
; @return hl: tile address
GetTileByPixel:
  ; First, we need to divide by 8 to convert a pixel position to a tile position.
  ; After this we want to multiply the Y position by 32.
  ; These operations effectively cancel out so we only need to mask the Y value.
  ld a, c
  and a, %11111000
  ld l, a
  ld h, 0
  ; Now we have the position * 8 in hl
  add hl, hl ; position * 16
  add hl, hl ; position * 32
  ; Convert the X position to an offset.
  ld a, b
  srl a ; a / 2
  srl a ; a / 4
  srl a ; a / 8
  ; Add the two offsets together.
  add a, l
  ld l, a
  adc a, h
  sub a, l
  ld h, a
  ; Add the offset to the tilemap's base address, and we are done!
  ld bc, $9800
  add hl, bc
  ret

; @param a: tile ID
; @return z: set if a is a wall.
IsWallTile:
  cp a, $00
  ret z
  cp a, $01
  ret z
  cp a, $02
  ret z
  cp a, $04
  ret z
  cp a, $05
  ret z
  cp a, $06
  ret z
  cp a, $07
  ret

; Copy bytes from one area to another.
; @param de: Source
; @param hl: Destination
; @param bc: Length
Memcopy:
  ld a, [de]
  ld [hli], a
  inc de
  dec bc
  ld a, b
  or a, c
  jp nz, Memcopy
  ret

Tiles:
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33322222
  dw `33322222
  dw `33322222
  dw `33322211
  dw `33322211
  dw `33333333
  dw `33333333
  dw `33333333
  dw `22222222
  dw `22222222
  dw `22222222
  dw `11111111
  dw `11111111
  dw `33333333
  dw `33333333
  dw `33333333
  dw `22222333
  dw `22222333
  dw `22222333
  dw `11222333
  dw `11222333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33322211
  dw `33322211
  dw `33322211
  dw `33322211
  dw `33322211
  dw `33322211
  dw `33322211
  dw `33322211
  dw `22222222
  dw `20000000
  dw `20111111
  dw `20111111
  dw `20111111
  dw `20111111
  dw `22222222
  dw `33333333
  dw `22222223
  dw `00000023
  dw `11111123
  dw `11111123
  dw `11111123
  dw `11111123
  dw `22222223
  dw `33333333
  dw `11222333
  dw `11222333
  dw `11222333
  dw `11222333
  dw `11222333
  dw `11222333
  dw `11222333
  dw `11222333
  dw `00000000
  dw `00000000
  dw `00000000
  dw `00000000
  dw `00000000
  dw `00000000
  dw `00000000
  dw `00000000
  dw `11001100
  dw `11111111
  dw `11111111
  dw `21212121
  dw `22222222
  dw `22322232
  dw `23232323
  dw `33333333

  ; Logo

  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33302333
  dw `33333133
  dw `33300313
  dw `33300303
  dw `33013330
  dw `30333333
  dw `03333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `03333333
  dw `30333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333330
  dw `33333320
  dw `33333013
  dw `33330333
  dw `33100333
  dw `31001333
  dw `20001333
  dw `00000333
  dw `00000033
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33330333
  dw `33300333
  dw `33333333
  dw `33033333
  dw `33133333
  dw `33303333
  dw `33303333
  dw `33303333
  dw `33332333
  dw `33332333
  dw `33333330
  dw `33333300
  dw `33333300
  dw `33333100
  dw `33333000
  dw `33333000
  dw `33333100
  dw `33333300
  dw `00000001
  dw `00000000
  dw `00000000
  dw `00000000
  dw `00000000
  dw `00000000
  dw `00000000
  dw `00000000
  dw `10000333
  dw `00000033
  dw `00000003
  dw `00000000
  dw `00000000
  dw `00000000
  dw `00000000
  dw `00000000
  dw `33332333
  dw `33302333
  dw `32003333
  dw `00003333
  dw `00003333
  dw `00013333
  dw `00033333
  dw `00033333
  dw `33333300
  dw `33333310
  dw `33333330
  dw `33333332
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `00000000
  dw `00000000
  dw `00000000
  dw `00000000
  dw `30000000
  dw `33000000
  dw `33333000
  dw `33333333
  dw `00000000
  dw `00000000
  dw `00000000
  dw `00000003
  dw `00000033
  dw `00003333
  dw `02333333
  dw `33333333
  dw `00333333
  dw `03333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333
  dw `33333333

TilesEnd:

Tilemap:
  db $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $02, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
  db $04, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
  db $04, $08, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
  db $04, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
  db $04, $08, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
  db $04, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
  db $04, $08, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
  db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
  db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
  db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
  db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
  db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
  db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
  db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $0A, $0B, $0C, $0D, $03, 0,0,0,0,0,0,0,0,0,0,0,0
  db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $0E, $0F, $10, $11, $03, 0,0,0,0,0,0,0,0,0,0,0,0
  db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $12, $13, $14, $15, $03, 0,0,0,0,0,0,0,0,0,0,0,0
  db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $16, $17, $18, $19, $03, 0,0,0,0,0,0,0,0,0,0,0,0
  db $04, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
TilemapEnd:

Paddle:
    dw `13333331
    dw `30000003
    dw `13333331
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
PaddleEnd:

Ball:
    dw `00033000
    dw `00322300
    dw `03222230
    dw `03222230
    dw `00322300
    dw `00033000
    dw `00000000
    dw `00000000
BallEnd:

SECTION "Counter", WRAM0
wFrameCounter: db
