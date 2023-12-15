.segment "CODE"

.proc tileloader
; with no actual CHR-RAM limited to 1k + 1k nametable, take care!
    lda #<tiledata
    sta $00
    lda #>tiledata
    sta $01

    ldy #$00
    sty PPUMASK
    sty PPUADDR
    sty PPUADDR
    ldx #$04  ; store up to 4x 256B pages

    @loop:
    lda ($00),y
    sta PPUDATA
    iny
    bne @loop ;
    inc $01
    dex
    bne @loop

    rts
.endproc

; data for CHR-RAM
.segment "RODATA"
tiledata: .incbin "./digits.chr"

