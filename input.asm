include "hardware.inc"
SECTION "INPUT", ROM0

; Handle keypresses
UpdateKeys::
  ; Poll half the controller
  ld a, P1F_GET_BTN
  call .onenibble
  ld b, a ; B7-4 = 1; B3-0 = unpressed buttons

  ; Poll the other half
  ld a, P1F_GET_DPAD
  call .onenibble
  swap a ; A3-0 = unpressed directions; A7-4 = 1
  xor a, b ; A = pressed buttons + directions
  ld b, a ; B = pressed buttons + directions

  ; And release the controller
  ld a, P1F_GET_NONE
  ldh [rP1], a

  ; Combine with previous wCurKeys to make wNewKeys
  ld a, [wCurKeys]
  xor a, b ; A = keys that changed state
  and a, b ; A = keys that changed to pressed
  ld [wNewKeys], a
  ld a, b
  ld [wCurKeys], a
  ret

.onenibble
  ldh [rP1], a ; switch the key matrix
  call .knownret ; burn 10 cycles calling a known ret
  ldh a, [rP1] ; ignore value while waiting for the key matrix to settle
  ldh a, [rP1]
  ldh a, [rP1] ; this read counts
  or a, $F0 ; A7-4 = 1; A3-0 = unpressed keys
.knownret
  ret

CheckKeys::
  ; First, check if left button pressed
CheckLeft:
  ld a, [wCurKeys]
  and a, PADF_LEFT
  jp z, CheckRight
Left:
  ; Move paddle left one pixel
  ld a, [_OAMRAM + 1]
  dec a
  ; If we hit edge of playfield, don't move
  cp a, 15
  jp z, Main
  ld [_OAMRAM + 1], a
  jp Main

  ;Then check right
CheckRight:
  ld a, [wCurKeys]
  and a, PADF_RIGHT
  jp z, Main
Right:
  ; Move paddle right one pixel
  ld a, [_OAMRAM + 1]
  inc a
  ; If we hit edge of playfield, don't move
  cp a, 105 
  jp z, Main
  ld [_OAMRAM + 1], a
  jp Main

SECTION "Input Variables", WRAM0
wCurKeys: db
wNewKeys: db
