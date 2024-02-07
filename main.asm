include "hardware.inc"

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

; Clear Object Attribute Memory
; because OAM is filled with junk on init
ClearOam:
  ld [hli], a
  dec b
  jp nz, ClearOam

; Draw paddle object by writing its properties
ld hl, _OAMRAM
ld a, 128 + 16
ld [hli], a
ld a, 16 + 8
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


Main:
  ld a, [rLY]
  cp 144
  jp nc, Main
WaitVBlank2:
  ld a, [rLY]
  cp 144
  jp c, WaitVBlank2

  ld a, [wFrameCounter]
  inc a
  ld [wFrameCounter], a
  cp a, 15 ; Every 15 frames (a quarter of a second), run the following code
  jp nz, Main

  ; Reset the frame counter back to 0
  ld a, 0
  ld [wFrameCounter], a

  ; Move the paddle one pixel to the right.
  ld a, [_OAMRAM + 1]
  inc a
  ld [_OAMRAM + 1], a
 jp Main

Done:
  jp Done

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

SECTION "Counter", WRAM0
wFrameCounter: db
