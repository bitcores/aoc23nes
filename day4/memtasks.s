.segment "CODE"

.proc mem
	
	clear_ntm:
		lda PPUSTATUS
		lda #$20
		sta PPUADDR
		lda #$00
		sta PPUADDR
		lda #0
		ldy #4
		: ldx #0
		: sta PPUDATA
		inx
		bne :-
		dey
		bne :--
	
	rts
	
.endproc