.segment "CODE"

.proc part1

  dopart1:
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
    sta $6800, x
    sta $6900, x
    sta $6A00, x
    sta $6B00, x
    sta $6C00, x
    sta $6D00, x
    sta $6E00, x
    sta $6F00, x
    inx
    bne clear_prgram
    
    ; buffer for numbers, $30 - valid?, $31 len, $32-$34 number, $35 adj to *, $36,$37 * memaddr low,high

    ; pointer to insert location in potential gear table
    sta $0E
    lda #$60
    sta $0F

    ; sample up, down chars are 11 bytes behind/ahead 0B
    ; 006D
    ; input are 141 bytes behind/ahead 8D
    ; 4D1C

    ; store max range
    lda #$6D
    sta $18
    lda #$00
    sta $19

    ; addr of inputs data
    lda #<inputs
    sta $10
    sta $12
    sta $14
    lda #>inputs
    sta $11
    sta $13
    sta $15

    ; addr of trailing lookup $12 $13
    lda $12
    cmp #$0C   ;;; test 0C  input 8E
    bcs skipti
    dec $13
  skipti:
    sec
    sbc #$0C   ;;; test 0C  input 8E
    sta $12 

    ; addr of leading lookup $14 $15
    lda $14
    clc
    adc #$0A  ;;; test 0A   input 8C
    bcc skipli
    inc $15
  skipli:
    sta $14

    ; end of input address
    lda $11
    clc
    adc $19
    sta $17

    lda $10
    clc
    adc $18
    bcc skipggg
    inc $17
  skipggg:
    sta $16

    ;; eeeeeeeend

    
    ; counters
    ldx #$00
    ldy #$00
    ; init input state: 0 game number, 1 draw, 2 wait for , or ;
    sty $09


    loop: lda ($10),y
    ; if the byte is 00, we have finished a "line", might need to save number
    cmp #$00
    beq dealsymbol

    ; symbol below 0
    cmp #$30
    bcc dealsymbol
    ; symbol above 9
    cmp #$3A
    bpl dealsymbol

    sty $1D
    stx $1E
    ; store the digits
    ldy $31
    and #$0F
    sta $32,y
    iny
    sty $31

    ldx $1E
    ldy $1D
    jsr lradj
    ldx $1E
    ldy $1D
    jsr udadj

    ldx $1E
    ldy $1D
    jmp incmem

  dealsymbol:
    lda #$00
    cmp $31
    beq incmem
    cmp $30
    beq cleanum

    jsr addnum
    jmp cleanum


  incmem:    ; increment the mem addr offset
    iny
    ; check if y rolled over to $00
    bne chkx
    clc
    ; increment x if it has rolled over
    inx
    ; increment high byte of mem addrs
    inc $11
    inc $13
    inc $15

    chkx:
    cpy $18
    bne loop
    cpx $19
    bne loop
    rts

  cleanum:
    sty $1D

    ldy #$09
    lda #$00
    :dey
    sta $30,y
    bne :-

    ldy $1D
    jmp incmem

  addnum:
    sty $1D
    stx $1E

    lda $35
    cmp #$00
    ; if not adj to *, just go to addition
    beq doaddition
    
    ; check if * is in the table, result on x
    jsr isgearchk
    cpx #$01
    beq doaddition

    ldy #$01
    ; store memaddr of *
    :lda $36, y
    sta ($0E), y
    dey
    cpy #$FF
    bne :-

    ; store number
    ldx $31
    dex 
    ldy $31
    iny
    iny
    :lda $32,x
    sta ($0E), y
    dex
    dey
    cpy #$01
    bne :-

    ; shift table pointer
    lda #$06
    clc
    adc $0E
    bcc :+
    inc $0F
    :sta $0E


  doaddition:
    ldx $1E
    ldy $1D

    lda #COUNTER1
    sta COUNT_PTR
    jmp numcalc


  isgearchk:
    ldx #$00

    ; set up table search pointer
    lda #$60
    sta $0D
    stx $0C

    ldy #$00
    ; loop the table
    tableloop:lda ($0C),y
    ; hit 00, end of table probably

    sty $4E
    ; check if add in $36 $37 matches current table entry
    lda $0D
    ; $4C 4D temporarily holds the addr of asterix
    sta $4D
    tya
    sta $4C
    
    ldy #$00

    lda ($4C),y
    cmp $36
    bne nogmatch
    iny
    lda ($4C),y
    cmp $37
    bne nogmatch

    ; if we have made it here, the two are equal. we're gonna multiply baby
    jsr multigear
    ldx #$01

    ldy $4E
    jmp finadd

  nogmatch:
    lda $4E
    clc
    adc #$06
    bcc :+
    inc $0D
    :tay
    lda $0F
    ; overflow breakout
    cmp $0D
    bpl tableloop
  
  finadd:
    rts


  multigear:
    jsr numtohex

    lda #COUNTER2
    sta COUNT_PTR

    ldy $45
    ldx $46
  loopm:
    jsr numcalc
    dey
    bne loopm
    dex
    cpx #$FF
    bne loopm

    rts


  numcalc:
    txa
    pha
    tya
    pha

    ldx $31
    dex

    ldy #$07
    lda (COUNT_PTR), y
    clc
    adc $32,x
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
    cpx #$00
    beq skipthous
    dex

    ldy #$06
    lda (COUNT_PTR), y
    clc
    adc $32,x
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
    cpx #$00
    beq skipthous
    dex

    ldy #$05
    lda (COUNT_PTR), y
    clc
    adc $32,x
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

    pla
    tay
    pla
    tax

    rts

  lradj:
    sty $3C
    stx $3D

    ; copy the address we're at and gonna check
    lda $11
    sta $3B

    ; what a mess
    lda $10
    sta $3A
    tya
    clc
    adc $3A
    bcc stpbak
    inc $3B
  stpbak:
    sta $3A
    dec $3A
    lda #$FF
    cmp $3A
    bne chkl
    dec $3B

  chkl:
    ; this will "check" the current pointer addres, who cares
    jsr readthree

    ldx $3D
    ldy $3C
    rts

  udadj:
    sty $3E
    stx $3F
    ; load trailing address
    lda $12
    sta $3A
    lda $13
    sta $3B

    ; what a mess
    lda $12
    sta $3A
    tya
    clc
    adc $3A
    bcc ustpbak   
    inc $3B
  ustpbak:
    sta $3A

  chku:
    jsr readthree
    
    ; check down memory space
  dod:
    ldy $1D
    ; load leading address
    
    lda $14
    sta $3A
    lda $15
    sta $3B

    ; what a mess
    lda $14
    sta $3A
    tya
    clc
    adc $3A
    bcc dstpbak
    inc $3B
  dstpbak:
    sta $3A

  chkd:
    jsr readthree
  
  udend:
    rts

  readthree:
    ; bounds check
    lda $3B
    cmp #>inputs
    bcc finishrt
    bne upperbounds
    lda $3A
    cmp #<inputs
    bcc finishrt

  upperbounds:
    lda $17
    cmp $3B
    bcc finishrt
    bne runrt
    lda $16
    cmp $3A
    bcc finishrt
    ; bounds checkign done

  runrt:
    ldy #$02
    :jsr symchk
    dey
    bpl :-
    
  finishrt:
    rts

  symchk:
    lda ($3A),y
    ; eol rare case
    cmp #$00
    beq sychkdone
    ; if it is a period, leave
    cmp #$2E
    beq sychkdone

    ; if next to an asterix check
    cmp #$2A
    bne nogear
    lda $35
    cmp #$00
    bne sychkdone
    ; if not already known gear, set flag and save addr of gear
    lda #$01
    sta $30
    sta $35
    lda $3B
    sta $37
    tya
    clc
    adc $3A
    bcc noroll
    inc $37
  noroll:
    sta $36
    jmp sychkdone
    
  nogear:
    ; symbol above 9
    cmp #$3A
    bcc symblow
    lda #$01
    sta $30
    jmp sychkdone
  symblow:
    ; symbol below 0
    cmp #$30
    bpl sychkdone
    lda #$01
    sta $30
    
  sychkdone:
    rts

  numtohex:
    txa
    pha
    tya
    pha

    ldx #$00
    ; top byte
    stx $46
    ; bottom byte
    stx $45
    ldy #$02

    ; load the len of the number
    lda ($4C), y
    sta $4A
    clc
    adc #$02
    tay

    loobn: lda ($4C), y
    
    cpx #$01
    beq m10
    cpx #$02
    beq m100
    sta $45
    jmp nextd
  m10:
    asl
    sta $4B
    asl
    asl
    clc
    adc $4B
    clc
    adc $45
    sta $45
    jmp nextd

  m100:
    asl
    sta $4B
    asl
    asl
    clc
    adc $4B

    asl
    sta $4B

    asl
    rol $46
    asl
    rol $46

    clc
    adc $4B
    bcc :+
    inc $46

    :clc
    adc $45
    bcc :+
    inc $46

    :sta $45

  nextd:
    inx
    dey
    cpy #$02
    bne loobn

    pla
    tay
    pla
    tax
    rts
  

.endproc