.segment "CODE"

.proc part1

  dopart1:
    ; set the counter
    lda #COUNTER1
    sta COUNT_PTR

    ; store max range
    lda #$C8
    sta $18
    lda #$54
    sta $19

    lda #$00
    sta $15 ; first digit found
    sta $16 ; updated each following digit found
    sta $17 ; check if first digit found

    ; addr of inputs data
    lda #<inputs
    sta $10
    lda #>inputs
    sta $11
    
    ; counters
    ldx #$00
    ldy #$00
    loop: lda ($10),y
    ; if the byte is 00 eval the numbers we have
    cmp #$00
    beq evalline
    ; put in memory
    sta $14
    ; check if a letter
    and #$C0
    bne incmem
    ; not letter, load and get integer val
    lda $14
    and #$0F
    ; store in "last" space
    sta $16
    ; load first digit check
    lda $17
    ; if value above 0, branch to incmem
    and #$FF
    bne incmem
    ; store first digit and check
    lda $16
    sta $15
    sta $17
    jmp incmem

  evalline:
    sty $1d

    clc
    ldy #$05
    lda (COUNT_PTR), y
    adc $16
    sta (COUNT_PTR), y
    sec
    lda #$09
    sbc (COUNT_PTR), y
    bpl addfirst
    sec
    lda (COUNT_PTR), y
    sbc #$0A
    sta (COUNT_PTR), Y
    jsr counter::incr_tens
  addfirst:
    clc
    ldy #$04
    lda (COUNT_PTR), y
    adc $15
    sta (COUNT_PTR), y
    sec
    lda #$09
    sbc (COUNT_PTR), y
    bpl finisheval
    sec
    lda (COUNT_PTR), y
    sbc #$0A
    sta (COUNT_PTR), Y
    jsr counter::incr_hunds

  finisheval:
    clc
    lda #$00
    sta $15
    sta $16
    sta $17

    ldy $1d



  incmem:    ; increment the mem addr offset
    iny
    ; check if y rolled over to $00
    bne chkx
    clc
    ; increment x if it has rolled over
    inx
    ; increment high byte of mem addr
    inc $11

    chkx:
    cpy $18
    bne loop
    cpx $19
    bne loop
    rts


.endproc