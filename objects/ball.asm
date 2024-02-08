SECTION "BALL", ROM0

; Updates Ball Momentum Y
; @param a: New value of ball
UpdateBallMomentumY::
  ld [wBallMomentumY], a
	ret

; Updates Ball Momentum X
; @param a: New value of ball
UpdateBallMomentumX::
  ld [wBallMomentumX], a
	ret

; Get Ball Momentum X
; Loads value into a
; @param a: Current value of ball
GetBallMomentumX::
	ld a, [wBallMomentumX]
	ret

; Get Ball Momentum Y
; Loads value into a
; @param a: Current value of ball
GetBallMomentumY::
	ld a, [wBallMomentumY]
	ret

SECTION "Ball Data", WRAM0
wBallMomentumX: db
wBallMomentumY: db
