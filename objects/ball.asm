SECTION "BALL", ROM0

; Updates Ball Momentum
; @param a: New Value of ball
UpdateBallMomentumY::
  ld [wBallMomentumY], a
	ret

; Updates Ball Momentum
; @param a: New Value of ball
UpdateBallMomentumX::
  ld [wBallMomentumX], a
	ret

GetBallMomentumX::
	ld a, [wBallMomentumX]
	ret

GetBallMomentumY::
	ld a, [wBallMomentumY]
	ret

SECTION "Ball Data", WRAM0
wBallMomentumX: db
wBallMomentumY: db
