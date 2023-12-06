.segment "CODE"

.proc counter

  init:
    lda #$00
    ldy #$05
    ; initialize counter
    loop:
      sta (COUNT_PTR), y
      dey
      bne loop

    rts
  
  increment:
    ldy #$05
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
    beq incr_thous
    rts

  incr_thous:
    lda #$00
    sta (COUNT_PTR), y
    dey
    clc
    lda #$01
    adc (COUNT_PTR), y
    sta (COUNT_PTR), y
    lda #$0a
    cmp (COUNT_PTR), y
    beq incr_tenthous
    rts

  incr_tenthous:
    lda #$00
    sta (COUNT_PTR), y
    dey
    clc
    lda #$01
    adc (COUNT_PTR), y
    sta (COUNT_PTR), y
    lda #$0a
    cmp (COUNT_PTR), y
    beq incr_hundthous
    rts
  
  incr_hundthous:
    lda #$00
    sta (COUNT_PTR), y
    dey
    clc
    lda #$01
    adc (COUNT_PTR), y
    sta (COUNT_PTR), y
    rts

.endproc