.segment "CODE"

.proc background
    

    ;; backround text nametable
    ;; day title
    lda PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$cd
    sta PPUADDR
    ; D
    ldx #$0e
    stx PPUDATA
    ; A
    ldx #$0b
    stx PPUDATA
    ; Y
    ldx #$23
    stx PPUDATA

    ldx #$00
    stx PPUDATA

    ; 0
    ldx #$01
    stx PPUDATA
    ; 5
    ldx #$06
    stx PPUDATA

    ;; part 1 title
    lda PPUSTATUS
    lda #$21
    sta PPUADDR
    lda #$66
    sta PPUADDR
    ; P
    ldx #$1a
    stx PPUDATA
    ; A
    ldx #$0b
    stx PPUDATA
    ; R
    ldx #$1c
    stx PPUDATA
    ; T
    ldx #$1e
    stx PPUDATA

    ldx #$00
    stx PPUDATA
    ; 1
    ldx #$02
    stx PPUDATA
    ; :
    ldx #$28
    stx PPUDATA

    ;; part 2 title
    lda PPUSTATUS
    lda #$21
    sta PPUADDR
    lda #$a6
    sta PPUADDR
    ; P
    ldx #$1a
    stx PPUDATA
    ; A
    ldx #$0b
    stx PPUDATA
    ; R
    ldx #$1c
    stx PPUDATA
    ; T
    ldx #$1e
    stx PPUDATA

    ldx #$00
    stx PPUDATA
    ; 2
    ldx #$03
    stx PPUDATA
    ; :
    ldx #$28
    stx PPUDATA

    ;; text attribute table
    lda PPUSTATUS
    lda #$23
    sta PPUADDR
    lda #$c0
    sta PPUADDR
    lda #%00000000
    sta PPUDATA

    lda PPUSTATUS
    lda #$23
    sta PPUADDR
    lda #$d3
    sta PPUADDR
    lda #%01000000
    sta PPUDATA
    lda #%01010000
    sta PPUDATA
    lda #%01010000
    sta PPUDATA

    lda PPUSTATUS
    lda #$23
    sta PPUADDR
    lda #$db
    sta PPUADDR
    lda #%00001000
    sta PPUDATA
    lda #%00001010
    sta PPUDATA
    lda #%00001010
    sta PPUDATA

    


    rts

.endproc