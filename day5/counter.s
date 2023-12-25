.segment "CODE"

.proc counter

  init:
    lda #$00
    ldy #$0A
    ; initialize counter
    loop:
      dey
      sta (COUNT_PTR), y
      bne loop

    rts
  
  increment:
    ldy #$09
    clc
    lda #$01
    adc (COUNT_PTR), y
    sta (COUNT_PTR), y
    lda #$0a
    cmp (COUNT_PTR), y
    beq incr_tensz
    rts

  incr_tensz:
    lda #$00
    sta (COUNT_PTR), y
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
    lda #$0a
    cmp (COUNT_PTR), y
    beq incr_hundmillionz
    rts

  incr_hundmillionz:
    lda #$00
    sta (COUNT_PTR), y
  incr_hundmillion:
    dey
    clc
    lda #$01
    adc (COUNT_PTR), y
    sta (COUNT_PTR), y
    lda #$0a
    cmp (COUNT_PTR), y
    beq incr_billionz
    rts

  incr_billionz:
    lda #$00
    sta (COUNT_PTR), y
  incr_billion:
    dey
    clc
    lda #$01
    adc (COUNT_PTR), y
    sta (COUNT_PTR), y
    rts

.endproc