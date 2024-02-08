include "../hardware.inc"

SECTION "Paddle", ROM0

HandlePaddleBounce::

PaddleBounce:
  ; First, check if the ball is low enough to bounce off the paddle.
  ld a, [_OAMRAM]
  ld b, a
  ld a, [_OAMRAM + 4]
  add a, 6
  cp a, b
  jp nz, PaddleBounceDone ; If the ball isn't at the same Y position as the paddle, it can't bounce.
  ; Now let's compare the X positions of the objects to see if they're touching.
  ld a, [_OAMRAM + 5] ; Ball's X position.
  ld b, a
  ld a, [_OAMRAM + 1] ; Paddle's X position.
  sub a, 8
  cp a, b
  jp nc, PaddleBounceDone
  add a, 8 + 16 ; 8 to undo, 16 as the width.
  cp a, b
  jp c, PaddleBounceDone

  ld a, -1
	call UpdateBallMomentumY

PaddleBounceDone:

	ret
