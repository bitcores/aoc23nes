.segment "CODE"

.proc part2

  dopart2:
    ; set the counter
    lda #COUNTER2
    sta COUNT_PTR

    ; store max range
    lda #$C8
    sta $18
    lda #$54
    sta $19

    ; addr of inputs data
    lda #<inputs
    sta $10
    lda #>inputs
    sta $11

    lda #$00
    sta $15 ; first digit found
    sta $16 ; updated each following digit found
    sta $17 ; check if first digit found
    
    ; counters
    ldx #$00
    ldy #$00
    loop: lda ($10),y
    cmp #$00
    beq doeval
    ; put in memory
    sta $14
    ; check if a letter
    and #$C0
    bne shuffbuff
    ; not letter, load and get integer val
    lda $14
    and #$0F
    ; store in "last" space
    sta $16
    ; load first digit check
    lda $17
    ; if value above 0, branch to shuffbuff
    and #$FF
    bne shuffbuff
    ; store first digit and check
    lda $16
    sta $15
    sta $17

    shuffbuff:
    lda ($10),y
    sta $65
    sty $1d

    ; shuffle buffer
    ldy #$04
    :lda $60, y
    sta $66
    lda $65
    sta $60, y
    lda $66
    sta $65
    dey
    bpl :-

    ldy $1d

    jsr checkwords

    jmp incmem
    
    doeval:
    jsr evalline

  

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

  checkwords:
  ; check buffer for word numbers
    lda $60
    ; t, s or e, possible word
    cmp #$74
    bne chkseven
    lda $61
    cmp #$68
    bne chkseven
    lda $62
    cmp #$72
    bne chkseven
    lda $63
    cmp #$65
    bne chkseven
    lda $64
    cmp #$65
    bne chkseven
    lda #$03
    jmp spike
  
  chkseven:
    lda $60
    ; t, s or e, possible word
    cmp #$73
    bne chkeight
    lda $61
    cmp #$65
    bne chkeight
    lda $62
    cmp #$76
    bne chkeight
    lda $63
    cmp #$65
    bne chkeight
    lda $64
    cmp #$6E
    bne chkeight
    lda #$07
    jmp spike

  chkeight:
    lda $60
    ; t, s or e, possible word
    cmp #$65
    bne chknine
    lda $61
    cmp #$69
    bne chknine
    lda $62
    cmp #$67
    bne chknine
    lda $63
    cmp #$68
    bne chknine
    lda $64
    cmp #$74
    bne chknine
    lda #$08
    jmp spike

  chknine:
    ; f or n, possible word
    lda $61
    cmp #$6E
    bne chkfour
    lda $62
    cmp #$69
    bne chkfour
    lda $63
    cmp #$6E
    bne chkfour
    lda $64
    cmp #$65
    bne chkfour
    lda #$09
    jmp spike

  chkfour:
    ; f or n, possible word
    lda $61
    cmp #$66
    bne chkone
    lda $62
    cmp #$6F
    bne chkfive
    lda $63
    cmp #$75
    bne chkfive
    lda $64
    cmp #$72
    bne chkfive
    lda #$04
    jmp spike
  
  chkfive:
    ; f or n, possible word
    lda $62
    cmp #$69
    bne chkone
    lda $63
    cmp #$76
    bne chkone
    lda $64
    cmp #$65
    bne chkone
    lda #$05
    jmp spike

  chkone:
    ; f or n, possible word
    lda $62
    cmp #$6F
    bne chktwo
    lda $63
    cmp #$6E
    bne chktwo
    lda $64
    cmp #$65
    bne chktwo
    lda #$01
    jmp spike
  
  chktwo:
    ; f or n, possible word
    lda $62
    cmp #$74
    bne chksix
    lda $63
    cmp #$77
    bne chksix
    lda $64
    cmp #$6F
    bne chksix
    lda #$02
    jmp spike
  
  chksix:
    ; f or n, possible word
    lda $62
    cmp #$73
    bne goback
    lda $63
    cmp #$69
    bne goback
    lda $64
    cmp #$78
    bne goback
    lda #$06
    jmp spike

  
  spike:
    sta $16
    ; load first digit check
    lda $17
    ; if value above 0, branch to incmem
    and #$FF
    bne goback
    ; store first digit and check
    lda $16
    sta $15
    sta $17
  goback:
    rts


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
  rts

.endproc