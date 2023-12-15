.segment "CODE"

.proc part1

  dopart1:

  ; clearn 2kB of prg_ram to store our card totals and points
    ldx #$00
  clear_prgram:
    lda #$00
    sta $6000, x
    sta $6100, x
    sta $6200, x
    sta $6300, x
    sta $6400, x
    sta $6500, x
    sta $6600, x
    sta $6700, x
    inx
    bne clear_prgram
    
    ; each card will get two bytes to store points and three bytes to
    ; store the total number of cards

    ; counter for cards, less than 255 only need one byte
    sta $0D
    ; pointer to insert card points, etc
    sta $0E
    lda #$60
    sta $0F

    ; test input size
    ; 0126
    ; input size
    ; 606F

    ; store max range
    lda #$26
    sta $18
    lda #$01
    sta $19

    ; addr of inputs data
    lda #<inputs
    sta $10
    lda #>inputs
    sta $11
    
    ; counters
    ldx #$00
    ldy #$00
    ; init input state: 0 card number, 1 winning numbers, 2 card numbers
    sty $09
    sty $011F

    ; $0100 -> will store our winning numbers. $011F the pointer for insertions

    mainloop: lda ($10),y

    sta $14
    lda $09
    cmp #$01
    beq winnums
    cmp #$02
    beq loadnums

    ; check if end of card number
    lda $14
    cmp #$3A
    bne :+
    lda #$01
    sta $09
    jsr incmem
    :jsr incmem
    jmp mainloop

  winnums:
    lda $14
    ; check to switch between winning numbers and card numbers
    cmp #$7C
    bne loadnums
    lda $09
    ; starter point for points scoring
    sta $33
    sta $38
    inc $09
    jsr incmem
    jsr incmem
    jmp mainloop
  
  loadnums:
    lda $14
    sta $30
    jsr incmem
    lda ($10), y
    sta $31

    ; are we reading winning or cards?
    lda $09
    cmp #$01
    bne checknums

    sty $1D
    ldy $011F
    lda $30
    sta $0100,y
    iny
    lda $31
    sta $0100,y
    iny
    sty $011F

    ldy $1D
    jsr incmem
    jsr incmem
    jmp mainloop

  
  checknums:
    sty $1D

    ldy #$00

    :lda $0100, y
    cmp #$00
    beq endcheck
    cmp $30
    bne jumpnum
    iny
    lda $0100, y
    cmp $31
    bne nextnum
    ; increase points
    inc $32 ; how many following cards get extras
    sty $3D

    ldy #$01
    lsr $33
    lda ($0E), y
    rol
    sta ($0E), y
    dey
    lda ($0E), y
    rol
    sta ($0E), y
    ldy $3D
    jmp endcheck

  jumpnum:
    iny
  nextnum:
    iny
    jmp :-

  endcheck:
    ldy $1D
    jsr incmem

    lda ($10),y
    ; if the byte is 00, we have finished a "line"
    cmp #$00
    beq finishline

    jsr incmem
    jmp mainloop


  finishline:
    sty $1D
    stx $1E

    ldy #$04
    jsr addcards

    jsr addscore

    :lda ($0E), y
      sta $34, y
      dey
      cpy #$01
    bne :-

    ldy #$04
    ldx $32
    cpx #$00
    beq nowinners
    :tya
      clc
      adc #$05
      tay
      jsr addcards
      dex
    bne :-

  nowinners:
    lda $0E
    clc
    adc #$05
    bcc :+
      inc $0F
    :sta $0E
    lda #$00
    sta $09
    sta $011F

    ldx $1E
    ldy $1D

    jsr cleanum
    jsr incmem
    jmp mainloop


  incmem:    ; increment the mem addr offset
    iny
    ; check if y rolled over to $00
    bne chkx
    ; increment x if it has rolled over
    inx
    ; increment high byte of mem addrs
    inc $11

  chkx:
    cpy $18
    bne :+
    cpx $19
    bne :+
    ; pulling the last two values off the stack should
    ; remove the last jump address, leaving us with the 
    ; address we jumped in from in the day4.s code
    ; but now we CAN'T fall into incmem
    pla
    pla

    :rts

  cleanum:
    sty $1D

    ldy #$1E
    lda #$00
    :dey
      sta $0100, y
      sta $30, y
    bne :-
    sta $30
    sta $31
    sta $32

    ldy $1D
    rts


  addcards:
    sty $2D
    stx $2E
    ; my incoming y is where in prg-ram to add to
    ldx #$03
    clc
    php
    :lda $35, x
      plp
      adc ($0E), y
      sta ($0E), y
      php
      dey
      dex
    bne :-
    plp

    ldx $2E
    ldy $2D
    rts


  addscore:
    ; hold the points and no. cards temporarily in $40-$42
    ; set up pointer for loading prg_ram data
    sty $4D
    stx $4E

    lda #COUNTER1
    sta COUNT_PTR

    ldy #$00
    lda ($0E), y
    sta $41
    iny
    lda ($0E), y
    sta $42

    jsr doscore

    lda #COUNTER2
    sta COUNT_PTR

    iny
    lda ($0E), y
    sta $40
    iny
    lda ($0E), y
    sta $41
    iny
    lda ($0E), y
    sta $42

    jsr doscore

    ldx $4E
    ldy $4D

    rts

  doscore:
    txa
    pha
    tya
    pha
    
  htdl0:
    jsr htdls
    lda $40
    cmp #$00
    beq htdl1
    dec $40
    ldy #$04
    :lda DECTAB+5, y
      sta $44, y
      dey
      bpl :-
    jsr countup

  htdl1:
    jsr htdls
    lda $41
    cmp #$00
    beq htdl2
    dec $41
    ldy #$04
    :lda DECTAB, y
      sta $44, y
      dey
      bpl :-
    jsr countup

  htdl2:
    jsr htdls
    ldy #$09
    lda $42
    cmp #$00
    beq htdle
    sec
    sbc #$09 
    bcs :+
      lda $42
      tay
      lda #$00
    :sta $42

    sty $48
    jsr countup

  htdle:
    lda $40
    cmp #$00
    bne htdl0
    lda $41
    cmp #$00
    bne htdl1
    lda $42
    cmp #$00
    bne htdl2

    pla
    tay
    pla
    tax

    rts

  htdls:
    ; clear the region to hold the decimal rep
    ldy #$06
    lda #$00
    :sta $43, y
      dey
      bne :-
  rts

  countup:
    txa
    pha
    tya
    pha

    ldx #$05

    ldy #$07
    lda (COUNT_PTR), y
    clc
    adc $43,x
    sta (COUNT_PTR), y
    sec
    lda #$09
    sbc (COUNT_PTR), y
    bpl skiptens
    sec
    lda (COUNT_PTR), y
    sbc #$0A
    sta (COUNT_PTR), y
    jsr counter::incr_tens

  skiptens:
    dex
    lda $43, x
    cmp #$00
    beq skiphunds
    

    ldy #$06
    lda (COUNT_PTR), y
    clc
    adc $43,x
    sta (COUNT_PTR), y
    sec
    lda #$09
    sbc (COUNT_PTR), y
    bpl skiphunds
    sec
    lda (COUNT_PTR), y
    sbc #$0A
    sta (COUNT_PTR), y
    jsr counter::incr_hunds
  
  skiphunds:
    dex
    lda $43, x
    cmp #$00
    beq skipthous

    ldy #$05
    lda (COUNT_PTR), y
    clc
    adc $43,x
    sta (COUNT_PTR), y
    sec
    lda #$09
    sbc (COUNT_PTR), y
    bpl skipthous
    sec
    lda (COUNT_PTR), y
    sbc #$0A
    sta (COUNT_PTR), y
    jsr counter::incr_thous
  
  skipthous:
    dex
    lda $43, x
    cmp #$00
    beq skiptenthous

    ldy #$04
    lda (COUNT_PTR), y
    clc
    adc $43,x
    sta (COUNT_PTR), y
    sec
    lda #$09
    sbc (COUNT_PTR), y
    bpl skiptenthous
    sec
    lda (COUNT_PTR), y
    sbc #$0A
    sta (COUNT_PTR), y
    jsr counter::incr_tenthous

  skiptenthous:
    dex
    lda $43, x
    cmp #$00
    beq skiphundthous

    ldy #$03
    lda (COUNT_PTR), y
    clc
    adc $43,x
    sta (COUNT_PTR), y
    sec
    lda #$09
    sbc (COUNT_PTR), y
    bpl skiphundthous
    sec
    lda (COUNT_PTR), y
    sbc #$0A
    sta (COUNT_PTR), y
    jsr counter::incr_hundthous

  skiphundthous:
    dex
    lda $43, x
    cmp #$00
    beq skipmillion

    ldy #$02
    lda (COUNT_PTR), y
    clc
    adc $43,x
    sta (COUNT_PTR), y
    sec
    lda #$09
    sbc (COUNT_PTR), y
    bpl skipmillion
    sec
    lda (COUNT_PTR), y
    sbc #$0A
    sta (COUNT_PTR), y
    jsr counter::incr_million

  skipmillion:
    pla
    tay
    pla
    tax

    rts
  
  DECTAB: .byte $00, $00, $02, $05, $06,  $06, $05, $05, $03, $06

.endproc