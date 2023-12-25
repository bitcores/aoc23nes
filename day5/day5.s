.include "constants.s"
.include "counter.s"
.include "memtasks.s"
.include "tileloader.s"
.include "background.s"
.include "part1.s"

.segment "HEADER"
  ; .byte "NES", $1A      ; iNES header identifier
  .byte $4E, $45, $53, $1A
  .byte $02               ; 2x 16KB PRG code
  .byte $00               ; 0x  8KB CHR data
  .byte $A9, $D0        ; mapper 0, vertical mirroring

.segment "VECTORS"
  ;; When an NMI happens (once per frame if enabled) the label nmi:
  .addr nmi
  ;; When the processor first turns on or is reset, it will jump to the label reset:
  .addr reset
  ;; External interrupt IRQ (unused)
  .addr 0

; "nes" linker config requires a STARTUP section, even if it's empty
.segment "STARTUP"

; Main code segment for the program
.segment "CODE"

reset:
  sei		; disable IRQs
  cld		; disable decimal mode
  ldx #$40
  stx $4017	; disable APU frame IRQ
  ldx #$ff 	; Set up stack
  txs		;  Set stack pointer to $FF
  ldx #$00
  stx PPUCTRL	; disable NMI
  stx PPUMASK 	; disable rendering
  stx $4010 	; disable DMC IRQs

;; first wait for vblank to make sure PPU is ready
  jsr vbwait
  

clear_ram:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  lda #$FE
  sta $0200, x
  inx
  bne clear_ram

;; second wait for vblank, PPU is ready after this
jsr vbwait

  lda #$00 	; Set SPR-RAM address to 0
  sta OAMADDR
  lda #$02  ; Set OAMDMA address to $0200
  sta OAMDMA

load_palettes:
  lda PPUSTATUS
  lda #$3f
  sta PPUADDR
  lda #$00
  sta PPUADDR
  ldx #$00
@loop:
  lda palettes, x
  sta PPUDATA
  inx
  cpx #$20
  bne @loop

;; clear nametable memory
jsr mem::clear_ntm

;; loading data into CHR-RAM can be done here
jsr tileloader

;; draw background
jsr background


main:
  ldy #$01
  lda #CNT_HI
  sta COUNT_PTR, y
  sta OUT_PTR, y

enable_rendering:
  lda #%10000000	; Enable NMI
  sta PPUCTRL
  lda #%00011010	; Enable sprites and background
  sta PPUMASK

forever:
  JSR READJOY
  LDA buttons
  AND #BUTTON_A
  bne runday
  jmp forever


READJOY: LDA #$00
      STA JOYPAD1
      LDA #$01
      STA JOYPAD1
      STA buttons
      LSR A
      STA JOYPAD1
      : LDA JOYPAD1
      LSR A
      ROL buttons
      BCC :-
      RTS

; prepare counters
runday:
  ldy #$01
  lda #CNT_HI
  sta COUNT_PTR, y
  sta OUT_PTR, y
  lda #COUNTER1
  sta COUNT_PTR
  jsr counter::init
  clc
  lda #COUNTER2
  sta COUNT_PTR
  jsr counter::init

; run part1
  jsr part1::dopart1

jsr vbwait
jmp forever

vbwait:
  bit PPUSTATUS
  bpl vbwait
  rts

nmi:
  ; push contents of flags, and registers onto stack
  php
  pha
  txa
  pha
  tya
  pha

  lda PPUSTATUS
  lda #$21    
  sta PPUADDR
  lda #$6e
  sta PPUADDR

  lda #COUNTER1
  sta OUT_PTR
  ldy #$00
output1loop:  
  lda (OUT_PTR), y
  clc
  adc #$01
  sta PPUDATA
  iny
  cpy #$0A ; length of counter
  bne output1loop

  ; second output
  lda PPUSTATUS
  lda #$21    
  sta PPUADDR
  lda #$ae
  sta PPUADDR

  lda #COUNTER2
  sta OUT_PTR
  ldy #$00
output2loop:
  lda (OUT_PTR), y
  clc
  adc #$01
  sta PPUDATA
  iny
  cpy #$0A ; length of counter
  bne output2loop

  lda PPUSTATUS
  lda #$00        ; set scroll
  sta PPUSCROLL
  sta PPUSCROLL

  ; restore contents of flags and registers from stack
  pla
  tay
  pla
  tax
  pla
  plp

  rti

      ; y, sprite, attr, x
;digits:
;  .byte $55, $00, $00, $55
;  .byte $5D, $01, $00, $5D
;  .byte $65, $02, $00, $65
;  .byte $6D, $03, $00, $6D
;  .byte $75, $04, $00, $75
;  .byte $7D, $05, $00, $7D
;  .byte $85, $06, $00, $85
;  .byte $8D, $07, $00, $8D
;  .byte $95, $08, $00, $95
;  .byte $9D, $09, $00, $9D
  
palettes:
  ; Background Palette
  .byte $0f, $00, $00, $00
  .byte $0f, $20, $00, $00
  .byte $0f, $17, $00, $00
  .byte $0f, $34, $00, $00

  ; Sprite Palette
  .byte $0f, $20, $17, $29
  .byte $0f, $07, $00, $00
  .byte $0f, $1a, $00, $00
  .byte $0f, $34, $00, $00

inputs: .incbin "./input5t.bin"

