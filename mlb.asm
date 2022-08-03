////////////////////////////////////////////////////
// meatloaf browser prototype
// for the commodore 64

//.segmentdef sprites
//.file [name="_in.spr", segments="sprites"]

#import "Constants.asm"

*=$0801 "BASIC"
 :BasicUpstart($0810)
*=$0810

.const X_POS = $6f
.const Y_POS = $55

begin_code:
    sei
    lda #BLACK
    sta BORDER_COLOR
    sta BACKGROUND_COLOR
    lda #$93
    jsr KERNAL_CHROUT

    lda #$01
    sta SPRITE_ENABLE
    lda #$00
    sta SPRITE_MULTICOLOR
    sta SPRITE_MSB_X

    lda #$2c
    sta SPRITE_0_POINTER
    
    lda #X_POS
    sta SPRITE_0_X
    lda #Y_POS
    sta SPRITE_0_Y
    
    lda #YELLOW
    sta SPRITE_0_COLOR

mainloop:
    inc $d020
    jsr KERNAL_GETIN

!check_next_key:
    cmp #$31 // 1 hit
    bne !check_next_key+
    jsr set_filename_buffer_1
    jsr load_data
    ClearScreen(BLACK)
    jmp mainloop

!check_next_key:
    cmp #$32 // 2 hit
    bne !check_next_key+
    jsr set_filename_buffer_2
    jsr load_data
    ClearScreen(BLACK)
    jmp mainloop

!check_next_key:
    jmp mainloop    

color_byte:
.byte 4
color_byte_underline:
.byte 1

////////////////////////////////////////////////////
load_data:
    ClearScreen(BLACK)
    ldx #$00
!ld:
    lda load_loading,x
    beq !ld+
    sta SCREEN_RAM,x
    lda color_byte
    sta COLOR_RAM,x
    inx
    jmp !ld-
    // draw filename to screencode
    cld
    clc
!ld:
    ldx #0
!ld:
    lda filename,x
    beq !ld+
    cmp #96
    bcc poke_screen
    sbc #96
poke_screen:
    sta SCREEN_RAM+8,x
    lda color_byte
    sta COLOR_RAM+8,x
    inx
    jmp !ld-

!ld:
    stx filename_length
    txa
    tay
    ldx #0
!ld:
    lda #43
    sta SCREEN_RAM+48,x
    lda color_byte_underline
    sta COLOR_RAM+48,x
    inx
    dey
    cpy #0
    bne !ld-

    lda #$01
    ldx drive_number
    ldy #$01
    jsr KERNAL_SETLFS
    lda filename_length
    ldx #<filename
    ldy #>filename
    jsr KERNAL_SETNAM
    ldx #00 // Set Load Address
    ldy #00 // 
    lda #00
    jsr KERNAL_LOAD
    lda #13
    jsr KERNAL_CHROUT
    jsr KERNAL_CHROUT
    jsr show_drive_status
    ldx #$00
!ld:
    lda dir_presskey_text,x
    beq !ld+
    jsr KERNAL_CHROUT
    inx
    jmp !ld-
!ld:
    jsr KERNAL_GETIN
    beq !ld-

    // ClearScreen(BLACK)
    rts

load_loading:
.encoding "screencode_mixed"
.text "loading "
.byte 0

////////////////////////////////////////////////////
show_drive_status:
    lda #$00
    sta $90 // clear status flags
    lda drive_number // device number
    jsr KERNAL_LISTEN
    lda #$6f // secondary address
    jsr KERNAL_SECLSN
    jsr KERNAL_UNLSTN
    lda $90
    bne sds_devnp // device not present
    lda drive_number
    jsr KERNAL_TALK
    lda #$6f // secondary address
    jsr KERNAL_SECTLK
sds_loop:
    lda $90 // get status flags
    bne sds_eof
    jsr KERNAL_IECIN
    jsr KERNAL_CHROUT
    jmp sds_loop
sds_eof:
    jsr KERNAL_UNTALK
    rts
sds_devnp:
    // handle device not present error handling
    rts

////////////////////////////////////////////////////
// Set filename buffer
set_filename_buffer_1:
    jsr zeroize_filename_buffer
    ldx #0
!sfb:
    lda filename1,x
    beq !sfb+
    sta filename,x
    inx
    jmp !sfb-
!sfb:
    stx filename_length
    rts

set_filename_buffer_2:
    jsr zeroize_filename_buffer
    ldx #0
!sfb:
    lda filename2,x
    beq !sfb+
    sta filename,x
    inx
    jmp !sfb-
!sfb:
    stx filename_length
    rts

////////////////////////////////////////////////////
// Zeroize filename buffer
zeroize_filename_buffer:
    ldx #0
!zfb:
    lda #0
    sta filename,x
    inx
    bne !zfb-
    rts

////////////////////////////////////////////////////
// Some vars
dir_presskey_text:
.encoding "screencode_mixed"
.byte $0d
.text "PRESS ANY KEY"
.byte 0
drive_number:
.byte 10
filename_length:
.byte 35
.encoding "screencode_upper"
filename: // reserve space for filename buffer
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
filename1:
.text "http://192.168.1.71/m64/ml.1.spr"
.byte 0
filename2:
.text "http://192.168.1.71/m64/ml.2.spr"
.byte 0

//.segment sprites
*=$0b00 "Sprites"
#import "sprites/cxn-sprite - Sprites.asm"

.macro ClearScreen(color) {
    lda #$93
    jsr KERNAL_CHROUT    // $FFD2
    lda #color
    sta BACKGROUND_COLOR // $D020
    sta BORDER_COLOR     // $D021
}
