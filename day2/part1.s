.segment "CODE"

.proc part1

  dopart1:
    ; set max r, g, b values
    ldy #$0C
    sty $0A
    iny
    sty $0B
    iny
    sty $0C

    ; store max range - input size (+1)
    ; input2t.bin is 141, my real input is 27FB
    lda #$41
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
    ; init input state: 0 game number, 1 draw, 2 wait for , or ;
    sty $09

    ; $30 game id, $31 number stack pointer, $32-$34 num digits
    ; $35 draw r value, $36 draw g value, $37 draw b value, $38 game valid
    ; should all be clear at start

    loop: lda ($10),y
    ; store it temporarily
    sta $14
    ; if the byte is 00, we have finished evaluating a game
    cmp #$00
    beq evalgame
    ; check byte based on game state
    lda $09
    cmp #$00
    bne checkdraw
    jmp gameid
  checkdraw:
    cmp #$01
    bne checkwait
    jmp ballnums
  checkwait:
    jmp dowait

  evalgame:
    sty $1d
    stx $1e

    lda $38
    ; if game valid, add game id to counter 1
    cmp #$00
    bne factorgame

    lda #COUNTER1
    sta COUNT_PTR
  
addid:
    lda #$08
    sta $17
    lda $30
    sec
    sbc $17
    bpl doadd
    lda $30
    sta $17
  doadd:
    clc
    ldy #$05
    lda (COUNT_PTR), y
    adc $17
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
    sec
    lda $30
    sbc $17
    sta $30
    cmp #$00
    bne addid
  
  factorgame:
    lda #COUNTER2
    sta COUNT_PTR

    jsr mulrg

    ldx $37
  loopfa:
    lda $0D
    sta $3D
    lda $0E
    sta $3E
  addfac:
    lda #$08
    sta $17
    lda $3E
    sec
    sbc $17
    ; if negative check
    bpl fadd
    lda $3E
    bmi fadd
    dec $3D

    bpl fadd
    lda $3E
    sta $17
  fadd:
    clc
    ldy #$05
    lda (COUNT_PTR), y
    adc $17
    sta (COUNT_PTR), y
    sec
    lda #$09
    sbc (COUNT_PTR), y
    bpl skipftens
    sec
    lda (COUNT_PTR), y
    sbc #$0A
    sta (COUNT_PTR), y
    jsr counter::incr_tens
  skipftens:
    sec
    lda $3E
    sbc $17
    sta $3E
    cmp #$00
    bne addfac
    lda $3D
    cmp #$FF
    bne addfac

    dex
    bne loopfa

  finisheval:
    clc
    lda #$00
    sta $09
    sta $25
    sta $26
    sta $27
    sta $17
    ldy #$08
    :sta $30, y
    dey
    bne :-

    ldy $1d
    ldx $1e

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
    bne reloop
    cpx $19
    bne reloop
    rts
  
  reloop:
    jmp loop


  readnum:
    sty $1D

    lda $14
    and #$0F
    ldy $31
    sta $32, y
    iny
    sty $31

    ldy $1D
  
  nextchar:
    jmp incmem
  

  gameid:
    lda $14
    ; check if a letter
    and #$C0
    bne nextchar
    lda $14
    ; is it a space
    cmp #$20
    beq nextchar
    lda $14
    ; change state
    cmp #$3A
    bne readnum
    lda #$01
    sta $09
    ; take the number that has been loaded, store it as the game id
    jsr numtohex
    lda $26
    sta $30
    jsr clearnum
    jmp nextchar


  ballnums:
    lda $14
    ; is it a space
    cmp #$20
    beq nextchar
    ; is it a letter
    and #$C0
    bne chkballtype
    ; its a number
    jmp readnum


  dowait:
    lda $14
    ; is it comma
    cmp #$2C
    beq setdraw
    ; is it semicolon
    cmp #$3B
    beq setdraw
    jmp nextchar
  setdraw:
    lda #$01
    sta $09
    jmp nextchar

  chkballtype:
    ; this WILL be rgb, so put num in hex
    jsr numtohex

    lda $14
    ; we want to take if it is r, g or b. anything else, nextchar
    cmp #$72
    bne checkg
    lda $35
    sec
    sbc $26
    bpl valr
    lda $26
    sta $35
  valr:
    lda $0A
    sec
    sbc $26
    bpl setwait
    lda #$01
    sta $38
    jmp setwait

  checkg:
    cmp #$67
    bne checkb
    lda $36
    sec
    sbc $26
    bpl valg
    lda $26
    sta $36
  valg:
    lda $0B
    sec
    sbc $26
    bpl setwait
    lda #$01
    sta $38
    jmp setwait

  checkb:
    cmp #$62
    lda $37
    sec
    sbc $26
    bpl valb
    lda $26
    sta $37
  valb:
    lda $0C
    sec
    sbc $26
    bpl setwait
    lda #$01
    sta $38
    jmp setwait


  setwait:
    lda #$02
    sta $09
    jsr clearnum
    jmp nextchar

  
  numtohex:
    txa
    pha
    tya
    pha

    ldy #$00
    sty $25
    sty $26
    loobn: lda $32, y
    sta $25
    sty $27

    clc
    lda $31
    sbc $27
    tax
    cpx #$00
    beq donemul
    jsr addten
    dex
    cpx #$00
    beq donemul
    jsr addten
    dex
    donemul:
    clc
    lda $25
    adc $26
    sta $26
    iny
    cpy $31
    bne loobn

    pla
    tay
    pla
    tax
    rts


  addten:
    ; multiply by 10
    txa
    pha
    tya
    pha

    lda $25
    ldy #$09
    :clc
    adc $25
    dey
    bne :-

    sta $25

    pla
    tay
    pla
    tax
    rts

  clearnum:
    lda #$00
    sta $31
    sta $32
    sta $33
    sta $34
    rts

  mulrg:
    ; multiply r and g values
    txa
    pha
    tya
    pha

    lda #$00
    sta $0D
    sta $0E
    
    ldy $36
    :clc
    lda $35
    adc $0E
    bcc putlow
    inc $0D
  putlow:
    sta $0E
    dey
    bne :-

    sta $25

    pla
    tay
    pla
    tax
    rts

.endproc