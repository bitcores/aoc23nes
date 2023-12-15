.segment "CODE"

.proc counter

  init:
    lda #$00
    ldy #$08
    ; initialize counter
    loop:
      dey
      sta (COUNT_PTR), y
      bne loop

    rts
  
  increment:
    ldy #$07
    clc
    lda #$01
    adc (COUNT_PTR), y
    sta (COUNT_PTR), y
    lda #$0a
    cmp (COUNT_PTR), y
    beq incr_tens
    rts

  incr_tens:
    dey
    clc
    lda #$01
    adc (COUNT_PTR), y
    sta (COUNT_PTR), y
    lda #$0a
    cmp (COUNT_PTR), y
    beq incr_hundsz
    rts
    
  incr_hundsz:
    lda #$00
    sta (COUNT_PTR), y
  incr_hunds:
    dey
    clc
    lda #$01
    adc (COUNT_PTR), y
    sta (COUNT_PTR), y
    lda #$0a
    cmp (COUNT_PTR), y
    beq incr_thousz
    rts

  incr_thousz:
    lda #$00
    sta (COUNT_PTR), y
  incr_thous:
    dey
    clc
    lda #$01
    adc (COUNT_PTR), y
    sta (COUNT_PTR), y
    lda #$0a
    cmp (COUNT_PTR), y
    beq incr_tenthousz
    rts

  incr_tenthousz:
    lda #$00
    sta (COUNT_PTR), y
  incr_tenthous:
    dey
    clc
    lda #$01
    adc (COUNT_PTR), y
    sta (COUNT_PTR), y
    lda #$0a
    cmp (COUNT_PTR), y
    beq incr_hundthousz
    rts
  
  incr_hundthousz:
    lda #$00
    sta (COUNT_PTR), y
  incr_hundthous:
    dey
    clc
    lda #$01
    adc (COUNT_PTR), y
    sta (COUNT_PTR), y
    lda #$0a
    cmp (COUNT_PTR), y
    beq incr_millionz
    rts

  incr_millionz:
    lda #$00
    sta (COUNT_PTR), y
  incr_million:
    dey
    clc
    lda #$01
    adc (COUNT_PTR), y
    sta (COUNT_PTR), y
    lda #$0a
    cmp (COUNT_PTR), y
    beq incr_tenmillionz
    rts

  incr_tenmillionz:
    lda #$00
    sta (COUNT_PTR), y
  incr_tenmillion:
    dey
    clc
    lda #$01
    adc (COUNT_PTR), y
    sta (COUNT_PTR), y
    rts

.endproc