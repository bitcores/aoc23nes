.segment "CODE"

.proc background
    ldy #$20
    ldx #$a0
    :lda PPUSTATUS
    lda #$23
    sta PPUADDR
    stx PPUADDR
    lda #$0e
    sta PPUDATA
    inx
    dey
    bne :-

    ;; backround text nametable
    ;; day title
    lda PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$8d
    sta PPUADDR
    ldx #$0e
    stx PPUDATA

    lda PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$8e
    sta PPUADDR
    ldx #$0b
    stx PPUDATA

    lda PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$8f
    sta PPUADDR
    ldx #$23
    stx PPUDATA

    lda PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$91
    sta PPUADDR
    ldx #$01
    stx PPUDATA

    lda PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$92
    sta PPUADDR
    ldx #$03
    stx PPUDATA

    ;; part 1 title
    lda $2002
    lda #$21
    sta $2006
    lda #$27
    sta $2006
    ldx #$1a
    stx $2007

    lda $2002
    lda #$21
    sta $2006
    lda #$28
    sta $2006
    ldx #$0b
    stx $2007

    lda $2002
    lda #$21
    sta $2006
    lda #$29
    sta $2006
    ldx #$1c
    stx $2007

    lda $2002
    lda #$21
    sta $2006
    lda #$2a
    sta $2006
    ldx #$1e
    stx $2007

    lda $2002
    lda #$21
    sta $2006
    lda #$2c
    sta $2006
    ldx #$02
    stx $2007

    lda $2002
    lda #$21
    sta $2006
    lda #$2d
    sta $2006
    ldx #$28
    stx $2007

    ;; part 2 title
    lda $2002
    lda #$21
    sta $2006
    lda #$67
    sta $2006
    ldx #$1a
    stx $2007

    lda $2002
    lda #$21
    sta $2006
    lda #$68
    sta $2006
    ldx #$0b
    stx $2007

    lda $2002
    lda #$21
    sta $2006
    lda #$69
    sta $2006
    ldx #$1c
    stx $2007

    lda $2002
    lda #$21
    sta $2006
    lda #$6a
    sta $2006
    ldx #$1e
    stx $2007

    lda $2002
    lda #$21
    sta $2006
    lda #$6c
    sta $2006
    ldx #$03
    stx $2007

    lda $2002
    lda #$21
    sta $2006
    lda #$6d
    sta $2006
    ldx #$28
    stx $2007

    ;; text attribute table
    lda $2002
    lda #$23
    sta $2006
    lda #$c0
    sta $2006
    lda #%00000000
    sta $2007


    rts

.endproc