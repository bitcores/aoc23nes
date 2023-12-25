.segment "CODE"

.proc part1

  dopart1:

  ; clear about 5kB of prg_ram for the mapping tables (300 address blocks)
    ldx #$00
  clear_prgram:
    lda #$00
  ; clear any previous run data too
    sta $0300, x
    sta $6000, x
    sta $6100, x
    sta $6200, x
    sta $6300, x
    sta $6400, x
    sta $6500, x
    sta $6600, x
    sta $6700, x
    sta $6800, x
    sta $6900, x
    sta $6A00, x
    sta $6B00, x
    sta $6C00, x
    sta $6D00, x
    sta $6E00, x
    sta $6F00, x
    sta $7000, x
    sta $7100, x
    sta $7200, x
    sta $7300, x
    sta $7400, x
    sta $7500, x
    inx
    bne clear_prgram

    ldx #$70
    :dex
      sta $30,x
      bne :-
    
    ; pointer for inserting map values
    sta $0E
    lda #$60
    sta $0F

    ; we'll store how many map groups there are, $70, and how many
    ; maps are in each group from $71 ->

    ; test input size
    ; 0154
    ; input size
    ; 1C19
    ; set the interval target to $21 below for full input
    ; search "inter$21" to find it

    ; store max range
    lda #$54
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
    ; init input state: 0 seed title, 1 seed numbers, 2 map numbers,
    ; 3 map title, 4 skip one
    sty $09

    mainloop: lda ($10),y

    sta $14
    lda $09
    ; load seeds mode
    cmp #$01
    beq loadseeds
    ; skip one character
    cmp #$04
    bne :+
      dec $09
      jsr incmem
      jmp mainloop
    :cmp #$03
    beq maphead
    cmp #$02
    beq loadmaps

    ; check if we start loading seed numbers
    lda $14
    cmp #$3A
    bne :+
    lda #$01
    sta $09
    jsr incmem
    :jsr incmem
    jmp mainloop

  loadseeds:
    lda $14
    ; check if it is the end of seed numbers
    cmp #$00
    bne :+
      lda #$04
      sta $09
      ; convert the last number
      jmp saveseed
      ; check if it is the end of a number
    :cmp #$20
    beq saveseed

    jmp readnum

  saveseed:
    sty $1D
    stx $1E
    jsr doconvert

    ; copy hex to seed store
    lda $0300
    asl
    asl
    tay
    ldx #$00
    :lda $6C,x
      sta $0301,y
      iny
      inx
      cpx #$04
      bne :-
    inc $0300

    jsr cleanum

    ldx $1E
    ldy $1D

    jsr incmem
    jmp mainloop

  maphead:
    ; check if we reached the end of the current map header
    lda $14
    cmp #$3A
    bne :+
    lda #$02
    sta $09
    jsr incmem
    :jsr incmem
    jmp mainloop

  loadmaps:
    lda $14
    ; the end of map numbers will be two #$00
    cmp #$00
    bne chkgap
      ; if $30 is #$00, last map number in group
      lda $30
      cmp #$00
      bne doneset
        lda #$03
        sta $09
        ; increment pointers for next inserts
        inc $70

        tya
        pha
        lda #$60
        ldy $70
        clc
        :adc #$03
          dey
          bne :-
        sta $0F
        pla
        tay

        lda #$00
        sta $0E

        jsr incmem
        jmp mainloop
      ; convert the last number
    doneset:
      txa
      pha
      ldx $70
      inc $71,x
      pla
      tax
      jmp savemap
      ; check if it is the end of a number
  chkgap:
    cmp #$20
    beq savemap

    jmp readnum

  savemap:
    sty $1D
    stx $1E
    jsr doconvert

    ; copy hex to seed store
    ldy #$00
    ldx #$00
    :lda $6C,x
      sta ($0E),y
      iny
      inx
      cpx #$04
      bne :-
    
    tya
    clc
    adc $0E
    sta $0E
    bcc :+
      inc $0F

    :jsr cleanum

    ldx $1E
    ldy $1D

    jsr incmem
    jmp mainloop
  
  doconvert:
    ldx #$09
    ldy $30

    :dey
      lda $31,y
      sta $44,x
      dex
      cpy #$00
      bne :-

    jsr dthl

    rts


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
    jmp solve
    :rts

  cleanum:
    tya
    pha

    ldy #$1F
    lda #$00
    :dey
      sta $30, y
      sta $50, y
    bne :-
    sta $30
    sta $31
    sta $32

    pla
    tay
    rts

  readnum:
    ; load our input number into $31 -> and use $30 to count
    tya
    pha

    ldy $30
    lda $14
    and #$0F
    sta $31,y
    inc $30

    pla
    tay
    jsr incmem
    jmp mainloop

  
  solve:
    ; load my seed counter
    lda #$00
    sta $8E
    sta $8F

    ; store our lowest result
    lda #$FF
    sta $30
    sta $31
    sta $32
    sta $33

    lda #COUNTER1
    sta COUNT_PTR

    testseed:    
      lda #$60
      sta $0F
      lda #$00
      sta $0E
      sta $60
  
      ; make a copy of our map counters
      ldy #$FF
      :iny
        lda $71,y
        sta $61,y
        cpy $70
        bne :- 

      jsr loadseednum

      jsr p1maps

      ; move the seed num pointer
      inc $8F
      lda $8F
      cmp $0300
      beq part1output

      lda #$04
      clc
      adc $8E
      sta $8E

      jsr counter::increment

      jmp testseed

    part1output:
      ldx #$03
      :lda $30,x
        sta $40,x
        dex
        bpl :-
      
      jsr doscore

  ; start part 2 solution
  lda #COUNTER2
  sta COUNT_PTR

  
  lda #$00
  sta $30
  sta $20
  sta $31
  sta $21
  sta $32
  sta $22
  sta $33
  sta $33
  ; start by doing about a million steps
  lda #$10
  sta $23   ; inter$21
  ldy #$00
  upseeds:
    lda #$60
    ldy $70
    clc
    :adc #$03
      dey
      bne :-
    sta $0F
    lda #$00
    sta $0E
    sta $8F

    ; back up this interval so we can revert later
    ldy #$00
    :lda $30,y
      sta $24,y
      iny
      cpy #$04
      bne :-
    
    ; make a copy of our map counters
    ldy #$FF
    :iny
      lda $71,y
      sta $61,y
      cpy $70
      bne :-

    lda $70
    sta $60

    jsr loadp2num

    jsr p2maps


  testvsseeds:
    lda #$00
    ldy #$00
    clc
    :cpy $8F
      beq tvsty
      adc #$04
      iny
      jmp :-
  tvsty: tay

    ldx #$00

    ; flag for number confirmed above bottom range
    sty $1D

    ibottomr: lda $0301,y
      cmp $40,x
      ; if greater than range, definitely above bottom
      bcc isubbottomr
      ; if not equal, got next
      bne iloadnextseed
      iny
      inx
      cpx #$04
      bne ibottomr
    
    isubbottomr:
    lda $1D
    clc
    adc #$03
    tay

    ldx #$03
    isublen:lda $40,x
      sec
      sbc $0301,y
      sta $40,x
      ; problem carrying forward the carry
      txa
      pha
      bcs insof
        :dex
        lda $40,x
        sbc #$00
        sta $40,x
        bcc :-
      insof: pla
      tax
      dey
      dex
      cpx #$00
      bne isublen

    
    itopr:
    tya
    clc
    adc #$04
    tay

    ldx #$00
    :lda $0301,y
      cmp $40,x
      ; if greater than range, go to next
      bcc iloadnextseed
      ; if not equal to range, definitely within range
      bne is2result
      iny
      inx
      cpx #$04
      bne :-

    iloadnextseed:
      inc $8F
      inc $8F
      lda $8F
      cmp $0300
      bcc testvsseeds

    trynext2seed:
      ; incrementing bullshit
      ldx #$04
    incinter:dex
      cpx #$00
      beq nop2of
      lda $20,x
      clc
      adc $30,x
      sta $30,x
      bcc incinter
      txa
      tay
      lda #$00
      :dey
        adc $30,y
        sta $30,y
        bcs :-
      jmp incinter


    nop2of:
      jsr doscore
      jmp upseeds

    dec2jump:
      ; revert last interval
      ldx #$00
      
      rberband:lda $30,x
        sec
        sbc $20,x
        bpl :+
          dex
          dec $30,x
          inx
        :sec
        sbc $20,x
        bpl :+
          dex
          dec $30,x
          inx
        :sta $30,x
        inx
        cpx #$04
        bne rberband

      lsr $21
      ror $22
      ror $23
      jmp trynext2seed

    is2result:
      lda $21
      cmp #$00
      bne dec2jump
      lda $22
      cmp #$00
      bne dec2jump
      lda $23
      cmp #$01
      bne dec2jump
    
      ldx #$03
      :lda $30,x
        sta $40,x
        dex
        bpl :-
      
      jsr doscore

  rts


  p1maps:
    
  testmap:
    jsr restorenum

    ldy #$04
    ldx #$00
    ; flag for number confirmed above bottom range
    stx $4F
    bottomr: lda ($0E),y
      cmp $40,x
      ; if greater than range, definitely above bottom
      bcc subbottomr
      ; if not equal, got next
      bne loadnextmap
      iny
      inx
      cpx #$04
      bne bottomr
    
    subbottomr:
    ldy #$07
    ldx #$03
    sublen:lda $40,x
      sec
      sbc ($0E),y
      sta $40,x
      ; problem carrying forward the carry
      txa
      pha
      bcs nsof
        :dex
        lda $40,x
        sbc #$00
        sta $40,x
        bcc :-
      nsof: pla
      tax
      dey
      dex
      cpy #$03
      bne sublen

    
    topr:
    ldy #$08
    ldx #$00
    :lda ($0E),y
      cmp $40,x
      ; if greater than range, go to next
      bcc loadnextmap
      ; if not equal to range, definitely within range
      bne isgood
      iny
      inx
      cpx #$04
      bne :-
    
    isgood:
    ldy #$03
    addest:lda ($0E),y
      clc
      adc $40,y
      sta $40,y
      ; problem carrying forward the carry
      tya
      pha
      bcc naof
        :dey
        lda #$00
        adc $40,y
        sta $40,y
        bcs :-
      naof: pla
      tay
      dey
      cpy #$FF
      bne addest
    
    jsr backupnum
    jmp nextmapgroup

  loadnextmap:
    ldx $60
    dec $61,x
    lda $61,x
    cmp #$00
    beq nextmapgroup

    lda $0E
    clc
    adc #$0C
    sta $0E
    bcc :+
      inc $0F
    :jmp testmap

  nextmapgroup:
    inc $60
    lda $60
    cmp $70
    bcc :+
      bne validresult

    :lda #$60
    ldy $60
    clc
    :adc #$03
      dey
      bne :-
    sta $0F
    lda #$00
    sta $0E
    jmp testmap


  validresult:
    jsr restorenum
    ldx #$00
    :lda $30,x
      cmp $40,x
      bcc nextseed
      bne newlow
      inx
      cpx #$04
      bne :-
    
    ; if lower than current stored result
    ; copy in new result
    newlow: 
    ldx #$04
    :dex
      lda $40,x
      sta $30,x
      cpx #$00
      bne :-

  nextseed:

  rts

  loadseednum:
    tya
    pha
    txa
    pha
  
    ldy $8E
    ldx #$00
      :lda $0301,y
        sta $80,x
        iny
        inx
        cpx #$04
        bne :-
    
    pla
    tax
    pla
    tay
    rts

  backupnum:
    txa
    pha
  
    ldx #$00
      :lda $40,x
        sta $80,x
        inx
        cpx #$04
        bne :-
    
    pla
    tax
    rts

  restorenum:
    txa
    pha
  
    ldx #$00
      :lda $80,x
        sta $40,x
        inx
        cpx #$04
        bne :-
    
    pla
    tax
    rts

  loadp2num:
    tya
    pha
    txa
    pha
  
    ldx #$00
      :lda $30,x
        sta $80,x
        inx
        cpx #$04
        bne :-
    
    pla
    tax
    pla
    tay
    rts 
    
  p2maps:
    
  test2map:
    jsr restorenum

    ldy #$00
    ; flag for number confirmed above bottom range
    bottom2r: lda ($0E),y
      cmp $40,y
      ; if greater than range, definitely above bottom
      bcc subbottom2r
      ; if not equal, got next
      bne loadnext2map
      iny
      cpy #$04
      bne bottom2r
    
    subbottom2r:
    ldy #$03
    ldx #$03
    sub2len:lda $40,x
      sec
      sbc ($0E),y
      sta $40,x
      ; problem carrying forward the carry
      txa
      pha
      bcs ns2of
        :dex
        lda $40,x
        sbc #$00
        sta $40,x
        bcc :-
      ns2of: pla
      tax
      dey
      dex
      cpy #$FF
      bne sub2len

    
    top2r:
    ldy #$08
    ldx #$00
    :lda ($0E),y
      cmp $40,x
      ; if greater than range, go to next
      bcc loadnext2map
      ; if not equal to range, definitely within range
      bne is2good
      iny
      inx
      cpx #$04
      bne :-
    jmp loadnext2map
    
    is2good:
    ldy #$07
    ldx #$03
    ad2dest:lda ($0E),y
      clc
      adc $40,x
      sta $40,x
      ; problem carrying forward the carry
      txa
      pha
      bcc na2of
        :dex
        lda #$00
        adc $40,x
        sta $40,x
        bcs :-
      na2of: pla
      tax
      dex
      dey
      cpy #$03
      bne ad2dest
    
    jsr backupnum
    jmp nextmap2group

  loadnext2map:
    ldx $60
    dec $61,x
    lda $61,x
    cmp #$00
    beq nextmap2group

    lda $0E
    clc
    adc #$0C
    sta $0E
    bcc :+
      inc $0F
    :jmp test2map

  nextmap2group:
    dec $60
    lda $60
    cmp #$FF
    beq next2seed

    lda #$60
    ldy #$00
    clc
    :cpy $60
      beq fmpfp2
      adc #$03
      iny
      jmp :-
  fmpfp2:
    sta $0F
    lda #$00
    sta $0E
    jmp test2map

  next2seed:

  rts

  ; this should push whatever 32bit value is in $40 to $43 to
  ; the active COUNTER
  doscore:
    txa
    pha
    tya
    pha
    ; whenever I call do score, clear the "counter" first
    jsr counter::init
    
  htdl0:
    lda $40
    cmp #$00
    beq htdl1
    dec $40
    ldy #$09
    clc
    :lda DECTAB+20, y
      adc (COUNT_PTR), y
      sta (COUNT_PTR), y
      jsr flowup
      dey
      bpl :-

  htdl1:
    lda $41
    cmp #$00
    beq htdl2
    dec $41
    ldy #$09
    clc
    :lda DECTAB+10, y
      adc (COUNT_PTR), y
      sta (COUNT_PTR), y
      jsr flowup
      dey
      bpl :-

  htdl2:
    lda $42
    cmp #$00
    beq htdl3
    dec $42
    ldy #$09
    clc
    :lda DECTAB, y
      adc (COUNT_PTR), y
      sta (COUNT_PTR), y
      jsr flowup
      dey
      bpl :-

  htdl3:
    ldy #$09
    lda $43
    cmp #$00
    beq htdle
    sec
    sbc #$09 
    bcs :+
      lda $43
      tay
      lda #$00
    :sta $43
    tya
    ldy #$09
    clc
    adc (COUNT_PTR), y
    sta (COUNT_PTR), y
    jsr flowup
    
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
    lda $43
    cmp #$00
    bne htdl3

    pla
    tay
    pla
    tax

    rts

  htdls:
    ; clear the output
    ldy #$03
    lda #$00
    :sta $40, y
      dey
      bne :-
  rts

  flowup:
    tya
    pha

  flowloop:
    sec
    lda #$09
    sbc (COUNT_PTR), y
    bpl flowno
    sec
    lda (COUNT_PTR), y
    sbc #$0A
    sta (COUNT_PTR), y
      dey
      clc
      lda #$01
      adc (COUNT_PTR), y
      sta (COUNT_PTR), y
      iny
  flowno:
    dey
    bpl flowloop

    clc
    pla
    tay
    rts

  ; going to use $50 to $6f for converting input to hex
  ; $50 to $59 for the input decimal
  ; $5c to $5f for working set
  ; $68 to $6b for temp addition
  ; $6c to $6f for output
  ; we will store decimal numbers in $44 to ??
  dthl:
    tya
    pha
    ldy #$09

    ; add the ones
    lda $44, y
    sta $6F
    dey

    ; add the tens
    lda $44, y
    cmp #$00
    beq :+
    sta $5F
    jsr m10
    jsr addout

    ; add the hundreds
    :dey
    lda $44, y
    cmp #$00
    beq :+
    sta $5F
    jsr m100
    jsr addout

    ; add the thousands
    :dey
    lda $44, y
    cmp #$00
    beq :+
    sta $5F
    jsr m1000
    jsr addout

    ; add the ten thousands
    :dey
    lda $44, y
    cmp #$00
    beq :+
    sta $5F
    jsr m10
    jsr m1000
    jsr addout

    ; add the hundred thousands
    :dey
    lda $44, y
    cmp #$00
    beq :+
    sta $5F
    jsr m100
    jsr m1000
    jsr addout

    ; add the millions
    :dey
    lda $44, y
    cmp #$00
    beq :+
    sta $5F
    jsr m1000
    jsr m1000
    jsr addout

    ; add the ten millions
    :dey
    lda $44, y
    cmp #$00
    beq :+
    sta $5F
    jsr m10
    jsr m1000
    jsr m1000
    jsr addout

    ; add the hundred millions
    :dey
    lda $44, y
    cmp #$00
    beq :+
    sta $5F
    jsr m100
    jsr m1000
    jsr m1000
    jsr addout

    ; add the billions
    :dey
    lda $44, y
    cmp #$00
    beq :+
    sta $5F
    jsr m1000
    jsr m1000
    jsr m1000
    jsr addout


    ; the hex form should be available on $6c to $6f
    :pla
    tay
    rts
    
  m10:
    lda $5F
    asl
    sta $6B
    asl
    asl
    clc
    adc $6B
    sta $6B
    ; add the result and return
    jmp tempback

  m100:
    lda $5F
    ; multiply by 4
    asl
    asl
    sta $5F
    ; add this to the result first
    jsr addtemp
    clc
    lda $5F
    ; multiply by 32
    asl

    asl
    rol $5E
    asl
    rol $5E
    sta $5F
    ; add the result
    jsr addtemp
    clc
    lda $5F
    ; multiply by 64
    asl
    rol $5E
    sta $5F
    ; add the result and return
    jsr addtemp
    jmp tempback

  m1000:
    tya
    pha

    lda $5F
    ; multiply by 8
    asl
    rol $5E
    rol $5D
    rol $5C
    asl
    rol $5E
    rol $5D
    rol $5C
    asl
    rol $5E
    rol $5D
    rol $5C
    sta $5F
    ; add this to the result first
    jsr addtemp
    clc
    lda $5F
    ; multiply by 32
    asl
    rol $5E
    rol $5D
    rol $5C
    asl
    rol $5E
    rol $5D
    rol $5C
    sta $5F
    ; add the result
    jsr addtemp
    clc
    lda $5F
    ldy #$03
    :; multiply by 64, 128, 256
      asl
      rol $5E
      rol $5D
      rol $5C
      sta $5F
      ; add the result
      jsr addtemp
      clc
      lda $5F
      dey
      bne :-
    ; multiply by 512
    asl
    rol $5E
    rol $5D
    rol $5C
    sta $5F
    ; add the result and return
    jsr addtemp

    pla
    tay
    jmp tempback
  

  addtemp:
    ldx #$04
    :dex
      lda $5C,x
      clc
      adc $68,x
      sta $68,x
      bcc notflow
      txa
      pha   
      :dex
        inc $68,x
        lda $68,x
        cmp #$00
        beq :-
      pla
      tax
    notflow: cpx #$00
    bne :--
    rts
  
  tempback:
    ldx #$04
    :dex
      lda $68,x
      sta $5C,x
      lda #$00
      sta $68,x
      cpx #$00
      bne :-
    rts

  addout:
    ldx #$04
    :dex
      lda $5C,x
      clc
      adc $6C,x
      sta $6C,x
      bcc noflow
      txa
      pha   
      :dex
        inc $6C,x
        lda $6C,x
        cmp #$00
        beq :-
      pla
      tax
    noflow: 
    lda #$00
    sta $5C,x
    cpx #$00
    bne :--
    rts
  
  DECTAB: .byte  $00, $00, $00, $00, $00, $00, $00, $02, $05, $06
          .byte  $00, $00, $00, $00, $00, $06, $05, $05, $03, $06
          .byte  $00, $00, $01, $06, $07, $07, $07, $02, $01, $06

.endproc