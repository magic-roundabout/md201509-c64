;
; MD201509 :: ZOOMED LOGO AND VERTICAL SPLIT INTRO
;

; Code by T.M.R/Cosine
; Graphics by T.M.R/Cosine
; Music by 4-Mat/ex-Cosine


; This source code is formatted for the ACME cross assembler from
; http://sourceforge.net/projects/acme-crossass/
; Compression is handled with PuCrunch which can be downloaded at
; http://csdb.dk/release/?id=6089

; This overwrites existing code to patch it so generates "segment
; starts" errors when assembled!


; Select an output filename
		!to "md201509_intro.prg",cbm


; Yank in binary data
		* = $0800
		!binary "data/nasa.chr"

		* = $3500
		!binary "data/super_bass.prg",,2

		* = $4001
		!binary "md201509_pu.prg",,2

; Constants
rstr1p		= $00
rstr2p		= $33

logo_base_col	= $0c


; Labels
rn		= $50
sync		= $51
irq_store_1	= $52

d011_mask	= $53
d011_mirror	= $54
d016_mirror_1	= $55
d016_mirror_2	= $56

scroll_x_2	= $57
scroll_spd_2	= $58
char_width_2	= $59


cos_at_1	= $5a
cos_offset_1	= $e4		; constant

cos_at_2	= $5b

line_text_1	= $0340


; Entry point at $0812
		* = $1000

; Stop interrupts, disable the ROMS and set up NMI and IRQ interrupt pointers
entry		sei

		lda #$01
		sta rn

		lda #<nmi
		sta $fffa
		lda #>nmi
		sta $fffb

		lda #<int
		sta $fffe
		lda #>int
		sta $ffff

		lda #$7f
		sta $dc0d
		sta $dd0d

		lda $dc0d
		lda $dd0d

		lda #rstr1p
		sta $d012

		lda #$0b
		sta $d011
		lda #$01
		sta $d019
		sta $d01a

		lda #$35
		sta $01


; Clear work spaces on the zeropage
		ldx #$40
		lda #$00
nuke_zp		sta $00,x
		inx
		bne nuke_zp


; Set up the screen
		ldx #$00
		txa
screen_clr	sta $0400,x
		sta $0500,x
		sta $0600,x
		sta $06e8,x
		sta $d800,x
		sta $d900,x
		sta $da00,x
		sta $dae8,x
		inx
		bne screen_clr

		ldx #$00
logo_draw	lda logo_data+$000,x
		sta $0427+$00,x
		sta $06a7+$00,x
		lda logo_data+$028,x
		sta $044f+$01,x
		sta $06cf+$01,x
		lda logo_data+$050,x
		sta $0477+$02,x
		sta $06f7+$02,x
		lda logo_data+$078,x
		sta $049f+$03,x
		sta $071f+$03,x
		lda logo_data+$0a0,x
		sta $04c7+$04,x
		sta $0747+$04,x
		lda logo_data+$0c8,x
		sta $04ef+$05,x
		sta $076f+$05,x
		lda logo_data+$0f0,x
		sta $0517+$06,x
		sta $0797+$06,x
		inx
		cpx #$22
		bne logo_draw

		ldx #$00
		lda #$09
logo_col_draw	ldy $0428,x
		cpy #$fd
		bne *+$08
		sta $d828,x
		sta $daa8,x

		ldy $04b4,x
		cpy #$fd
		bne *+$08
		sta $d8b4,x
		sta $db34,x

		inx
		cpx #$8c
		bne logo_col_draw

; Build the text line
		ldx #$00
		lda #$40
		sta irq_store_1
		lda #$01
		sta char_width_2

line_build	dec char_width_2
		beq lb_mread

; Continue processing current character
		lda line_text_1-$01,x
		clc
		adc #$01
		sta line_text_1,x

		inx

		jmp lb_count

; Fetch new character
lb_mread	ldy lt1_data
		lda char_decode,y
		sta line_text_1,x

		lda char_width_dcd,y
		sta char_width_2

		inc lb_mread+$01
		bne *+$05
		inc lb_mread+$02
		inx

		jmp lb_count

lb_count	cpx #$48
		bcc line_build

; Reset the scrolling message
		jsr reset_2
		lda #$01
		sta char_width_2
		lda #$03
		sta scroll_spd_2

; Initialise the music
		jsr $3548

; Set up a couple of labels
		lda #$1b
		sta d011_mirror
		lda #$18
		sta d011_mask

		cli

; Wait for space to be pressed
main_loop	lda $dc01
		cmp #$ef
		bne main_loop

; Turn off the screen and fade out the music
		lda #$0b
		sta d011_mirror
		lda #$08
		sta d011_mask

		ldx #$1f
volume_fade	jsr sync_wait
		jsr sync_wait
		jsr sync_wait
		jsr sync_wait
		jsr sync_wait
		jsr sync_wait
		jsr sync_wait
		jsr sync_wait
		stx $d418
		dex
		cpx #$10
		bne volume_fade

; Shut everything down
		sei
		ldx #$00
		txa
sid_nuke	sta $d400,x
		inx
		cpx #$1c
		bne sid_nuke

		lda #$0b
		sta $d011
		lda #$81
		sta $dc0d
		lda #$71
		sta $dd0d
		lda $dc0d
		lda $dd0d

; Repoint the interrupts at an RTI written to the ZP
		lda link_rti
		sta $02

		lda #$02
		sta $fffa
		sta $fffe
		lda #$00
		sta $fffb
		sta $ffff

; Copy block shift code to the cassette buffer
		ldx #$00
bs_copy		lda block_shift,x
		sta $0340,x
		inx
		cpx #$20
		bne bs_copy

		jmp $0340

; Actual block shift code - runs from $0340
block_shift	ldx #$00
bs_loop		lda $4000,x
		sta $0800,x
		inx
		bne bs_loop

		inc $0344
		inc $0347
		lda $0344
		cmp #$d0
		bne block_shift

; Call the crunched file
		jmp $080e

; An RTI command used by the linker (gets copied to ZP)
link_rti	rti


; IRQ interrupt
int		pha
		txa
		pha
		tya
		pha

		lda $d019
		and #$01
		sta $d019
		bne ya
		jmp ea31

ya		lda rn
		cmp #$02
		bne *+$05
		jmp rout2


; Raster split 1
rout1		lda #$02
		sta rn
		lda #rstr2p
		sta $d012

		lda #$0b
		sta $d020
		sta $d021

		lda d011_mirror
		sta $d011
		lda #$18
		sta $d016
		lda #$12
		sta $d018

		jsr $3521

		jmp ea31


; Raster split 2 - starts at the next page boundary
		* = ((*/$100)+1)*$100
rout2		ldx #$00
raster_sync	lda $d012
		and #$07
		ora d011_mask
		sta $d011
		nop
		nop
		inx
		cpx #$04
		bne raster_sync
		lda #$1b
		sta $d011

		ldx #$1e
		dex
		bne *-$01

		ldy #logo_base_col
		sty $d022
		ldy #$00
		sty $d023

		bit $ea
		nop

		jsr logo_splitter

; Update first logo letter's raster colour data
		ldx cos_at_1
		inx
		stx cos_at_1
		ldy logo_cosinus,x

		lda logo_colours_1+$01,y
		sta split_l01_0+$01
		lda logo_colours_1+$02,y
		sta split_l02_0+$01
		lda logo_colours_1+$03,y
		sta split_l03_0+$01
		lda logo_colours_1+$04,y
		sta split_l04_0+$01
		lda logo_colours_1+$05,y
		sta split_l05_0+$01
		lda logo_colours_1+$06,y
		sta split_l06_0+$01

		lda logo_colours_1+$09,y
		sta split_l09_0+$01
		lda logo_colours_1+$0a,y
		sta split_l0a_0+$01
		lda logo_colours_1+$0b,y
		sta split_l0b_0+$01
		lda logo_colours_1+$0c,y
		sta split_l0c_0+$01
		lda logo_colours_1+$0d,y
		sta split_l0d_0+$01
		lda logo_colours_1+$0e,y
		sta split_l0e_0+$01

		lda logo_colours_1+$11,y
		sta split_l11_0+$01
		lda logo_colours_1+$12,y
		sta split_l12_0+$01
		lda logo_colours_1+$13,y
		sta split_l13_0+$01
		lda logo_colours_1+$14,y
		sta split_l14_0+$01
		lda logo_colours_1+$15,y
		sta split_l15_0+$01
		lda logo_colours_1+$16,y
		sta split_l16_0+$01

		lda logo_colours_1+$19,y
		sta split_l19_0+$01
		lda logo_colours_1+$1a,y
		sta split_l1a_0+$01
		lda logo_colours_1+$1b,y
		sta split_l1b_0+$01
		lda logo_colours_1+$1c,y
		sta split_l1c_0+$01
		lda logo_colours_1+$1d,y
		sta split_l1d_0+$01
		lda logo_colours_1+$1e,y
		sta split_l1e_0+$01

		lda logo_colours_1+$21,y
		sta split_l21_0+$01
		lda logo_colours_1+$22,y
		sta split_l22_0+$01
		lda logo_colours_1+$23,y
		sta split_l23_0+$01
		lda logo_colours_1+$24,y
		sta split_l24_0+$01
		lda logo_colours_1+$25,y
		sta split_l25_0+$01
		lda logo_colours_1+$26,y
		sta split_l26_0+$01

		lda logo_colours_1+$29,y
		sta split_l29_0+$01
		lda logo_colours_1+$2a,y
		sta split_l2a_0+$01
		lda logo_colours_1+$2b,y
		sta split_l2b_0+$01
		lda logo_colours_1+$2c,y
		sta split_l2c_0+$01
		lda logo_colours_1+$2d,y
		sta split_l2d_0+$01
		lda logo_colours_1+$2e,y
		sta split_l2e_0+$01

		lda logo_colours_1+$31,y
		sta split_l31_0+$01
		lda logo_colours_1+$32,y
		sta split_l32_0+$01
		lda logo_colours_1+$33,y
		sta split_l33_0+$01
		lda logo_colours_1+$34,y
		sta split_l34_0+$01
		lda logo_colours_1+$35,y
		sta split_l35_0+$01
		lda logo_colours_1+$36,y
		sta split_l36_0+$01

; Update second logo letter's raster colour data
		txa
		clc
		adc #cos_offset_1
		tax
		ldy logo_cosinus,x


		lda logo_colours_2+$01,y
		sta split_l01_1+$01
		lda logo_colours_2+$02,y
		sta split_l02_1+$01
		lda logo_colours_2+$03,y
		sta split_l03_1+$01
		lda logo_colours_2+$04,y
		sta split_l04_1+$01
		lda logo_colours_2+$05,y
		sta split_l05_1+$01
		lda logo_colours_2+$06,y
		sta split_l06_1+$01

		lda logo_colours_2+$09,y
		sta split_l09_1+$01
		lda logo_colours_2+$0a,y
		sta split_l0a_1+$01
		lda logo_colours_2+$0b,y
		sta split_l0b_1+$01
		lda logo_colours_2+$0c,y
		sta split_l0c_1+$01
		lda logo_colours_2+$0d,y
		sta split_l0d_1+$01
		lda logo_colours_2+$0e,y
		sta split_l0e_1+$01

		lda logo_colours_2+$11,y
		sta split_l11_1+$01
		lda logo_colours_2+$12,y
		sta split_l12_1+$01
		lda logo_colours_2+$13,y
		sta split_l13_1+$01
		lda logo_colours_2+$14,y
		sta split_l14_1+$01
		lda logo_colours_2+$15,y
		sta split_l15_1+$01
		lda logo_colours_2+$16,y
		sta split_l16_1+$01

		lda logo_colours_2+$19,y
		sta split_l19_1+$01
		lda logo_colours_2+$1a,y
		sta split_l1a_1+$01
		lda logo_colours_2+$1b,y
		sta split_l1b_1+$01
		lda logo_colours_2+$1c,y
		sta split_l1c_1+$01
		lda logo_colours_2+$1d,y
		sta split_l1d_1+$01
		lda logo_colours_2+$1e,y
		sta split_l1e_1+$01

		lda logo_colours_2+$21,y
		sta split_l21_1+$01
		lda logo_colours_2+$22,y
		sta split_l22_1+$01
		lda logo_colours_2+$23,y
		sta split_l23_1+$01
		lda logo_colours_2+$24,y
		sta split_l24_1+$01
		lda logo_colours_2+$25,y
		sta split_l25_1+$01
		lda logo_colours_2+$26,y
		sta split_l26_1+$01

		lda logo_colours_2+$29,y
		sta split_l29_1+$01
		lda logo_colours_2+$2a,y
		sta split_l2a_1+$01
		lda logo_colours_2+$2b,y
		sta split_l2b_1+$01
		lda logo_colours_2+$2c,y
		sta split_l2c_1+$01
		lda logo_colours_2+$2d,y
		sta split_l2d_1+$01
		lda logo_colours_2+$2e,y
		sta split_l2e_1+$01

		lda logo_colours_2+$31,y
		sta split_l31_1+$01
		lda logo_colours_2+$32,y
		sta split_l32_1+$01
		lda logo_colours_2+$33,y
		sta split_l33_1+$01
		lda logo_colours_2+$34,y
		sta split_l34_1+$01
		lda logo_colours_2+$35,y
		sta split_l35_1+$01
		lda logo_colours_2+$36,y
		sta split_l36_1+$01

; Update third logo letter's raster colour data
		txa
		clc
		adc #cos_offset_1
		tax
		ldy logo_cosinus,x


		lda logo_colours_3+$01,y
		sta split_l01_2+$01
		lda logo_colours_3+$02,y
		sta split_l02_2+$01
		lda logo_colours_3+$03,y
		sta split_l03_2+$01
		lda logo_colours_3+$04,y
		sta split_l04_2+$01
		lda logo_colours_3+$05,y
		sta split_l05_2+$01
		lda logo_colours_3+$06,y
		sta split_l06_2+$01

		lda logo_colours_3+$09,y
		sta split_l09_2+$01
		lda logo_colours_3+$0a,y
		sta split_l0a_2+$01
		lda logo_colours_3+$0b,y
		sta split_l0b_2+$01
		lda logo_colours_3+$0c,y
		sta split_l0c_2+$01
		lda logo_colours_3+$0d,y
		sta split_l0d_2+$01
		lda logo_colours_3+$0e,y
		sta split_l0e_2+$01

		lda logo_colours_3+$11,y
		sta split_l11_2+$01
		lda logo_colours_3+$12,y
		sta split_l12_2+$01
		lda logo_colours_3+$13,y
		sta split_l13_2+$01
		lda logo_colours_3+$14,y
		sta split_l14_2+$01
		lda logo_colours_3+$15,y
		sta split_l15_2+$01
		lda logo_colours_3+$16,y
		sta split_l16_2+$01

		lda logo_colours_3+$19,y
		sta split_l19_2+$01
		lda logo_colours_3+$1a,y
		sta split_l1a_2+$01
		lda logo_colours_3+$1b,y
		sta split_l1b_2+$01
		lda logo_colours_3+$1c,y
		sta split_l1c_2+$01
		lda logo_colours_3+$1d,y
		sta split_l1d_2+$01
		lda logo_colours_3+$1e,y
		sta split_l1e_2+$01

; First scroller
		nop
		lda d016_mirror_1
		sta $d016
		stx irq_store_1

		jsr scroll_splitter

		ldx irq_store_1

; Back to the updating
		lda logo_colours_3+$21,y
		sta split_l21_2+$01
		lda logo_colours_3+$22,y
		sta split_l22_2+$01
		lda logo_colours_3+$23,y
		sta split_l23_2+$01
		lda logo_colours_3+$24,y
		sta split_l24_2+$01
		lda logo_colours_3+$25,y
		sta split_l25_2+$01
		lda logo_colours_3+$26,y
		sta split_l26_2+$01

		lda logo_colours_3+$29,y
		sta split_l29_2+$01
		lda logo_colours_3+$2a,y
		sta split_l2a_2+$01
		lda logo_colours_3+$2b,y
		sta split_l2b_2+$01
		lda logo_colours_3+$2c,y
		sta split_l2c_2+$01
		lda logo_colours_3+$2d,y
		sta split_l2d_2+$01
		lda logo_colours_3+$2e,y
		sta split_l2e_2+$01

		lda logo_colours_3+$31,y
		sta split_l31_2+$01
		lda logo_colours_3+$32,y
		sta split_l32_2+$01
		lda logo_colours_3+$33,y
		sta split_l33_2+$01
		lda logo_colours_3+$34,y
		sta split_l34_2+$01
		lda logo_colours_3+$35,y
		sta split_l35_2+$01
		lda logo_colours_3+$36,y
		sta split_l36_2+$01

; Update fourth logo letter's raster colour data
		txa
		clc
		adc #cos_offset_1
		tax
		ldy logo_cosinus,x


		lda logo_colours_4+$01,y
		sta split_l01_3+$01
		lda logo_colours_4+$02,y
		sta split_l02_3+$01
		lda logo_colours_4+$03,y
		sta split_l03_3+$01
		lda logo_colours_4+$04,y
		sta split_l04_3+$01
		lda logo_colours_4+$05,y
		sta split_l05_3+$01
		lda logo_colours_4+$06,y
		sta split_l06_3+$01

		lda logo_colours_4+$09,y
		sta split_l09_3+$01
		lda logo_colours_4+$0a,y
		sta split_l0a_3+$01
		lda logo_colours_4+$0b,y
		sta split_l0b_3+$01
		lda logo_colours_4+$0c,y
		sta split_l0c_3+$01
		lda logo_colours_4+$0d,y
		sta split_l0d_3+$01
		lda logo_colours_4+$0e,y
		sta split_l0e_3+$01

		lda logo_colours_4+$11,y
		sta split_l11_3+$01
		lda logo_colours_4+$12,y
		sta split_l12_3+$01
		lda logo_colours_4+$13,y
		sta split_l13_3+$01
		lda logo_colours_4+$14,y
		sta split_l14_3+$01
		lda logo_colours_4+$15,y
		sta split_l15_3+$01
		lda logo_colours_4+$16,y
		sta split_l16_3+$01

		lda logo_colours_4+$19,y
		sta split_l19_3+$01
		lda logo_colours_4+$1a,y
		sta split_l1a_3+$01
		lda logo_colours_4+$1b,y
		sta split_l1b_3+$01
		lda logo_colours_4+$1c,y
		sta split_l1c_3+$01
		lda logo_colours_4+$1d,y
		sta split_l1d_3+$01
		lda logo_colours_4+$1e,y
		sta split_l1e_3+$01

		lda logo_colours_4+$21,y
		sta split_l21_3+$01
		lda logo_colours_4+$22,y
		sta split_l22_3+$01
		lda logo_colours_4+$23,y
		sta split_l23_3+$01
		lda logo_colours_4+$24,y
		sta split_l24_3+$01
		lda logo_colours_4+$25,y
		sta split_l25_3+$01
		lda logo_colours_4+$26,y
		sta split_l26_3+$01

; Second scroller
		stx irq_store_1

		ldx #$05
		dex
		bne *-$01
		bit $ea
		nop
		lda d016_mirror_2
		sta $d016

		jsr scroll_splitter

		ldx irq_store_1

; And back to updating raster colour data again

		lda logo_colours_4+$29,y
		sta split_l29_3+$01
		lda logo_colours_4+$2a,y
		sta split_l2a_3+$01
		lda logo_colours_4+$2b,y
		sta split_l2b_3+$01
		lda logo_colours_4+$2c,y
		sta split_l2c_3+$01
		lda logo_colours_4+$2d,y
		sta split_l2d_3+$01
		lda logo_colours_4+$2e,y
		sta split_l2e_3+$01

		lda logo_colours_4+$31,y
		sta split_l31_3+$01
		lda logo_colours_4+$32,y
		sta split_l32_3+$01
		lda logo_colours_4+$33,y
		sta split_l33_3+$01
		lda logo_colours_4+$34,y
		sta split_l34_3+$01
		lda logo_colours_4+$35,y
		sta split_l35_3+$01
		lda logo_colours_4+$36,y
		sta split_l36_3+$01

; Update fifth logo letter's raster colour data
		txa
		clc
		adc #cos_offset_1
		tax
		ldy logo_cosinus,x


		lda logo_colours_5+$01,y
		sta split_l01_4+$01
		lda logo_colours_5+$02,y
		sta split_l02_4+$01
		lda logo_colours_5+$03,y
		sta split_l03_4+$01
		lda logo_colours_5+$04,y
		sta split_l04_4+$01
		lda logo_colours_5+$05,y
		sta split_l05_4+$01
		lda logo_colours_5+$06,y
		sta split_l06_4+$01

		lda logo_colours_5+$09,y
		sta split_l09_4+$01
		lda logo_colours_5+$0a,y
		sta split_l0a_4+$01
		lda logo_colours_5+$0b,y
		sta split_l0b_4+$01
		lda logo_colours_5+$0c,y
		sta split_l0c_4+$01
		lda logo_colours_5+$0d,y
		sta split_l0d_4+$01
		lda logo_colours_5+$0e,y
		sta split_l0e_4+$01

		lda logo_colours_5+$11,y
		sta split_l11_4+$01
		lda logo_colours_5+$12,y
		sta split_l12_4+$01
		lda logo_colours_5+$13,y
		sta split_l13_4+$01
		lda logo_colours_5+$14,y
		sta split_l14_4+$01
		lda logo_colours_5+$15,y
		sta split_l15_4+$01
		lda logo_colours_5+$16,y
		sta split_l16_4+$01

		lda logo_colours_5+$19,y
		sta split_l19_4+$01
		lda logo_colours_5+$1a,y
		sta split_l1a_4+$01
		lda logo_colours_5+$1b,y
		sta split_l1b_4+$01
		lda logo_colours_5+$1c,y
		sta split_l1c_4+$01
		lda logo_colours_5+$1d,y
		sta split_l1d_4+$01
		lda logo_colours_5+$1e,y
		sta split_l1e_4+$01

		lda logo_colours_5+$21,y
		sta split_l21_4+$01
		lda logo_colours_5+$22,y
		sta split_l22_4+$01
		lda logo_colours_5+$23,y
		sta split_l23_4+$01
		lda logo_colours_5+$24,y
		sta split_l24_4+$01
		lda logo_colours_5+$25,y
		sta split_l25_4+$01
		lda logo_colours_5+$26,y
		sta split_l26_4+$01

		lda logo_colours_5+$29,y
		sta split_l29_4+$01
		lda logo_colours_5+$2a,y
		sta split_l2a_4+$01
		lda logo_colours_5+$2b,y
		sta split_l2b_4+$01
		lda logo_colours_5+$2c,y
		sta split_l2c_4+$01
		lda logo_colours_5+$2d,y
		sta split_l2d_4+$01
		lda logo_colours_5+$2e,y
		sta split_l2e_4+$01

		lda logo_colours_5+$31,y
		sta split_l31_4+$01
		lda logo_colours_5+$32,y
		sta split_l32_4+$01
		lda logo_colours_5+$33,y
		sta split_l33_4+$01
		lda logo_colours_5+$34,y
		sta split_l34_4+$01
		lda logo_colours_5+$35,y
		sta split_l35_4+$01
		lda logo_colours_5+$36,y
		sta split_l36_4+$01

; Update sixth logo letter's raster colour data
		txa
		clc
		adc #cos_offset_1
		tax
		ldy logo_cosinus,x


		lda logo_colours_6+$01,y
		sta split_l01_5+$01
		lda logo_colours_6+$02,y
		sta split_l02_5+$01
		lda logo_colours_6+$03,y
		sta split_l03_5+$01
		lda logo_colours_6+$04,y
		sta split_l04_5+$01
		lda logo_colours_6+$05,y
		sta split_l05_5+$01
		lda logo_colours_6+$06,y
		sta split_l06_5+$01

		lda logo_colours_6+$09,y
		sta split_l09_5+$01
		lda logo_colours_6+$0a,y
		sta split_l0a_5+$01
		lda logo_colours_6+$0b,y
		sta split_l0b_5+$01
		lda logo_colours_6+$0c,y
		sta split_l0c_5+$01
		lda logo_colours_6+$0d,y
		sta split_l0d_5+$01
		lda logo_colours_6+$0e,y
		sta split_l0e_5+$01

		lda logo_colours_6+$11,y
		sta split_l11_5+$01
		lda logo_colours_6+$12,y
		sta split_l12_5+$01
		lda logo_colours_6+$13,y
		sta split_l13_5+$01
		lda logo_colours_6+$14,y
		sta split_l14_5+$01
		lda logo_colours_6+$15,y
		sta split_l15_5+$01
		lda logo_colours_6+$16,y
		sta split_l16_5+$01

		lda logo_colours_6+$19,y
		sta split_l19_5+$01
		lda logo_colours_6+$1a,y
		sta split_l1a_5+$01
		lda logo_colours_6+$1b,y
		sta split_l1b_5+$01
		lda logo_colours_6+$1c,y
		sta split_l1c_5+$01
		lda logo_colours_6+$1d,y
		sta split_l1d_5+$01
		lda logo_colours_6+$1e,y
		sta split_l1e_5+$01

		lda logo_colours_6+$21,y
		sta split_l21_5+$01
		lda logo_colours_6+$22,y
		sta split_l22_5+$01
		lda logo_colours_6+$23,y
		sta split_l23_5+$01
		lda logo_colours_6+$24,y
		sta split_l24_5+$01
		lda logo_colours_6+$25,y
		sta split_l25_5+$01
		lda logo_colours_6+$26,y
		sta split_l26_5+$01

		lda logo_colours_6+$29,y
		sta split_l29_5+$01
		lda logo_colours_6+$2a,y
		sta split_l2a_5+$01
		lda logo_colours_6+$2b,y
		sta split_l2b_5+$01
		lda logo_colours_6+$2c,y
		sta split_l2c_5+$01
		lda logo_colours_6+$2d,y
		sta split_l2d_5+$01
		lda logo_colours_6+$2e,y
		sta split_l2e_5+$01

		lda logo_colours_6+$31,y
		sta split_l31_5+$01
		lda logo_colours_6+$32,y
		sta split_l32_5+$01
		lda logo_colours_6+$33,y
		sta split_l33_5+$01
		lda logo_colours_6+$34,y
		sta split_l34_5+$01
		lda logo_colours_6+$35,y
		sta split_l35_5+$01
		lda logo_colours_6+$36,y
		sta split_l36_5+$01

		ldx #$16
		dex
		bne *-$01

		jsr logo_splitter

		ldx cos_at_2
		inx
		cpx #$fe
		bne *+$04
		ldx #$02
		stx cos_at_2
		lda text_cosinus,x
		and #$07
		eor #$07
		sta d016_mirror_1
		lda text_cosinus,x
		lsr
		lsr
		lsr
		tay

		ldx #$00
mover_1		lda line_text_1,y
		sta $0590,x
		clc
		adc #$53
		sta $05b8,x
		iny
		inx
		cpx #$27
		bne mover_1

; Scroll mover 2
		ldy scroll_spd_2
scroll_2_upd	ldx scroll_x_2
		inx
		cpx #$08
		bne sx2_xb

; Shift the character lines
		ldx #$00
mover_2		lda $0609,x
		sta $0608,x
		clc
		adc #$53
		sta $0630,x
		inx
		cpx #$26
		bne mover_2

		dec char_width_2
		beq mread_2

; Bump the current character value by one
		lda $0608+$26
		clc
		adc #$01
		sta $0608+$26
		clc
		adc #$53
		sta $0630+$26
		jmp no_fetch_2

; Fetch a new character
mread_2		ldx scroll_text_2
		bne okay_2
		jsr reset_2
		jmp mread_2

okay_2		cpx #$81
		bcc okay_2b
		txa
		and #$0f
		sta scroll_spd_2
		ldx #$20

okay_2b		lda char_decode,x
		sta $0608+$26
		clc
		adc #$53
		sta $0630+$26
		lda char_width_dcd,x
		sta char_width_2

		inc mread_2+$01
		bne *+$05
		inc mread_2+$02


no_fetch_2	ldx #$00
sx2_xb		stx scroll_x_2

		txa
		and #$07
		eor #$07
		sta d016_mirror_2

		dey
		bne scroll_2_upd

		lda #$01
		sta rn
		sta sync
		lda #rstr1p
		sta $d012

ea31		pla
		tay
		pla
		tax
		pla
nmi		rti

; Runtime synchronisation
sync_wait	lda #$00
		sta sync
sw_loop		cmp sync
		beq sw_loop
		rts

; Scrolling message reset
reset_2		lda #<scroll_text_2
		sta mread_2+$01
		lda #>scroll_text_2
		sta mread_2+$02
		rts

; Colour splitter code
		* = ((*/$100)+1)*$100
		!src "includes/intro_splitter.asm"

; Screen data for the logo
logo_data	!byte $00,$fd,$fd,$fd,$fe,$00,$00,$fd
		!byte $fd,$fd,$fe,$00,$00,$fd,$fd,$fd
		!byte $fe,$00,$fd,$fd,$fd,$fd,$fe,$00
		!byte $fd,$fd,$fd,$fe,$00,$00,$fd,$fd
		!byte $fd,$fe,$00,$00,$00,$00,$00,$00

		!byte $fd,$fd,$fe,$00,$fd,$fe,$fd,$fe
		!byte $00,$fd,$fd,$fe,$fd,$fd,$fe,$00
		!byte $fd,$fe,$00,$fd,$fd,$fe,$00,$fd
		!byte $fe,$00,$fd,$fd,$fe,$fd,$fd,$fe
		!byte $00,$fd,$fe,$00,$00,$00,$00,$00

		!byte $fd,$fd,$fe,$00,$00,$00,$fd,$fe
		!byte $00,$fd,$fd,$fe,$fd,$fd,$fe,$00
		!byte $00,$00,$00,$fd,$fd,$fe,$00,$fd
		!byte $fe,$00,$fd,$fd,$fe,$fd,$fd,$fe
		!byte $00,$00,$00,$00,$00,$00,$00,$00

		!byte $fd,$fd,$fe,$00,$00,$00,$fd,$fe
		!byte $00,$fd,$fd,$fe,$00,$fd,$fd,$fd
		!byte $fe,$00,$00,$fd,$fd,$fe,$00,$fd
		!byte $fe,$00,$fd,$fd,$fe,$fd,$fd,$fd
		!byte $fd,$fe,$00,$00,$00,$00,$00,$00

		!byte $fd,$fd,$fe,$00,$00,$00,$fd,$fe
		!byte $00,$fd,$fd,$fe,$00,$00,$00,$fd
		!byte $fd,$fe,$00,$fd,$fd,$fe,$00,$fd
		!byte $fe,$00,$fd,$fd,$fe,$fd,$fd,$fe
		!byte $00,$00,$00,$00,$00,$00,$00,$00

		!byte $fd,$fd,$fe,$00,$fd,$fe,$fd,$fe
		!byte $00,$fd,$fd,$fe,$fd,$fe,$00,$fd
		!byte $fd,$fe,$00,$fd,$fd,$fe,$00,$fd
		!byte $fe,$00,$fd,$fd,$fe,$fd,$fd,$fe
		!byte $00,$fd,$fe,$00,$00,$00,$00,$00

		!byte $00,$fd,$fd,$fd,$fe,$00,$00,$fd
		!byte $fd,$fd,$fe,$00,$00,$fd,$fd,$fd
		!byte $fe,$00,$fd,$fd,$fd,$fd,$fe,$fd
		!byte $fe,$00,$fd,$fd,$fe,$00,$fd,$fd
		!byte $fd,$fe,$00,$00,$00,$00,$00,$00

; Cosinus data
		* = ((*/$100)+1)*$100
logo_cosinus	!byte $79,$79,$79,$79,$79,$79,$79,$79
		!byte $78,$78,$78,$77,$77,$76,$76,$75
		!byte $75,$74,$74,$73,$72,$72,$71,$70
		!byte $6f,$6e,$6d,$6d,$6c,$6b,$6a,$69
		!byte $68,$67,$65,$64,$63,$62,$61,$60
		!byte $5e,$5d,$5c,$5b,$59,$58,$57,$55
		!byte $54,$52,$51,$50,$4e,$4d,$4b,$4a
		!byte $48,$47,$45,$44,$42,$41,$3f,$3e

		!byte $3c,$3b,$39,$38,$36,$35,$33,$32
		!byte $30,$2f,$2e,$2c,$2b,$29,$28,$26
		!byte $25,$24,$22,$21,$20,$1e,$1d,$1c
		!byte $1a,$19,$18,$17,$16,$15,$13,$12
		!byte $11,$10,$0f,$0e,$0d,$0c,$0b,$0b
		!byte $0a,$09,$08,$07,$07,$06,$05,$05
		!byte $04,$04,$03,$03,$02,$02,$01,$01
		!byte $01,$00,$00,$00,$00,$00,$00,$00

		!byte $00,$00,$00,$00,$00,$00,$00,$00
		!byte $01,$01,$01,$02,$02,$03,$03,$04
		!byte $04,$05,$05,$06,$07,$08,$08,$09
		!byte $0a,$0b,$0c,$0d,$0e,$0e,$0f,$11
		!byte $12,$13,$14,$15,$16,$17,$18,$1a
		!byte $1b,$1c,$1d,$1f,$20,$21,$23,$24
		!byte $25,$27,$28,$2a,$2b,$2d,$2e,$2f
		!byte $31,$32,$34,$35,$37,$38,$3a,$3b

		!byte $3d,$3e,$40,$41,$43,$44,$46,$47
		!byte $49,$4a,$4c,$4d,$4f,$50,$51,$53
		!byte $54,$56,$57,$58,$5a,$5b,$5c,$5d
		!byte $5f,$60,$61,$62,$63,$65,$66,$67
		!byte $68,$69,$6a,$6b,$6c,$6d,$6e,$6f
		!byte $6f,$70,$71,$72,$72,$73,$74,$74
		!byte $75,$76,$76,$77,$77,$77,$78,$78
		!byte $78,$79,$79,$79,$79,$79,$79,$79

		* = logo_cosinus+$100
text_cosinus	!byte $d0,$d0,$d0,$d0,$d0,$d0,$cf,$cf
		!byte $ce,$ce,$cd,$cd,$cc,$cb,$ca,$c9
		!byte $c9,$c8,$c6,$c5,$c4,$c3,$c2,$c0
		!byte $bf,$bd,$bc,$ba,$b9,$b7,$b5,$b4
		!byte $b2,$b0,$ae,$ac,$aa,$a8,$a6,$a4
		!byte $a2,$a0,$9e,$9b,$99,$97,$95,$92
		!byte $90,$8d,$8b,$89,$86,$84,$81,$7f
		!byte $7c,$7a,$77,$75,$72,$70,$6d,$6a

		!byte $68,$65,$63,$60,$5e,$5b,$58,$56
		!byte $53,$51,$4e,$4c,$49,$47,$45,$42
		!byte $40,$3d,$3b,$39,$37,$34,$32,$30
		!byte $2e,$2c,$2a,$27,$25,$24,$22,$20
		!byte $1e,$1c,$1a,$19,$17,$15,$14,$12
		!byte $11,$10,$0e,$0d,$0c,$0b,$09,$08
		!byte $07,$06,$05,$05,$04,$03,$03,$02
		!byte $01,$01,$01,$00,$00,$00,$00,$00

		!byte $00,$00,$00,$00,$00,$00,$01,$01
		!byte $02,$02,$03,$03,$04,$05,$06,$07
		!byte $08,$09,$0a,$0b,$0c,$0d,$0f,$10
		!byte $11,$13,$14,$16,$18,$19,$1b,$1d
		!byte $1e,$20,$22,$24,$26,$28,$2a,$2c
		!byte $2e,$31,$33,$35,$37,$39,$3c,$3e
		!byte $40,$43,$45,$48,$4a,$4d,$4f,$52
		!byte $54,$57,$59,$5c,$5e,$61,$63,$66

		!byte $69,$6b,$6e,$70,$73,$75,$78,$7a
		!byte $7d,$7f,$82,$84,$87,$89,$8c,$8e
		!byte $91,$93,$95,$98,$9a,$9c,$9e,$a0
		!byte $a3,$a5,$a7,$a9,$ab,$ad,$af,$b1
		!byte $b2,$b4,$b6,$b8,$b9,$bb,$bc,$be
		!byte $bf,$c1,$c2,$c3,$c4,$c6,$c7,$c8
		!byte $c9,$ca,$cb,$cb,$cc,$cd,$ce,$ce
		!byte $cf,$cf,$cf,$d0,$d0,$d0,$d0,$d0

; Logo split colours
		* = logo_cosinus+$200
logo_colours_1	!byte $0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b
		!byte $06,$06,$0b,$06,$0b,$0b,$04,$0b
		!byte $04,$04,$0e,$04,$0e,$0e,$0f,$0e
		!byte $0f,$0f,$0d,$0f,$0d,$0d,$01,$0d
		!byte $01,$01,$0d,$01,$0d,$0d,$0f,$0d
		!byte $0f,$0f,$0e,$0f,$0e,$0e,$04,$0e
		!byte $04,$04,$0b,$04,$0b,$0b,$06,$0b
		!byte $06,$06,$0b,$0b,$0b,$0b,$0b,$0b

		!byte $06,$06,$0b,$06,$0b,$0b,$04,$0b
		!byte $04,$04,$0e,$04,$0e,$0e,$0f,$0e
		!byte $0f,$0f,$0d,$0f,$0d,$0d,$01,$0d
		!byte $01,$01,$0d,$01,$0d,$0d,$0f,$0d
		!byte $0f,$0f,$0e,$0f,$0e,$0e,$04,$0e
		!byte $04,$04,$0b,$04,$0b,$0b,$06,$0b
		!byte $06,$06,$0b,$0b,$0b,$0b,$0b,$0b

		!byte $06,$06,$0b,$06,$0b,$0b,$04,$0b
		!byte $04,$04,$0e,$04,$0e,$0e,$0f,$0e
		!byte $0f,$0f,$0d,$0f,$0d,$0d,$01,$0d
		!byte $01,$01,$0d,$01,$0d,$0d,$0f,$0d
		!byte $0f,$0f,$0e,$0f,$0e,$0e,$04,$0e
		!byte $04,$04,$0b,$04,$0b,$0b,$06,$0b
		!byte $06,$06,$0b,$0b,$0b,$0b,$0b,$0b

		* = logo_cosinus+$300
logo_colours_2	!byte $0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b
		!byte $06,$06,$0b,$06,$0b,$0b,$08,$0b
		!byte $08,$08,$0e,$08,$0e,$0e,$0f,$0e
		!byte $0f,$0f,$0d,$0f,$0d,$0d,$01,$0d
		!byte $01,$01,$0d,$01,$0d,$0d,$0f,$0d
		!byte $0f,$0f,$0e,$0f,$0e,$0e,$08,$0e
		!byte $08,$08,$0b,$08,$0b,$0b,$06,$0b
		!byte $06,$06,$0b,$0b,$0b,$0b,$0b,$0b

		!byte $06,$06,$0b,$06,$0b,$0b,$08,$0b
		!byte $08,$08,$0e,$08,$0e,$0e,$0f,$0e
		!byte $0f,$0f,$0d,$0f,$0d,$0d,$01,$0d
		!byte $01,$01,$0d,$01,$0d,$0d,$0f,$0d
		!byte $0f,$0f,$0e,$0f,$0e,$0e,$08,$0e
		!byte $08,$08,$0b,$08,$0b,$0b,$06,$0b
		!byte $06,$06,$0b,$0b,$0b,$0b,$0b,$0b

		!byte $06,$06,$0b,$06,$0b,$0b,$08,$0b
		!byte $08,$08,$0e,$08,$0e,$0e,$0f,$0e
		!byte $0f,$0f,$0d,$0f,$0d,$0d,$01,$0d
		!byte $01,$01,$0d,$01,$0d,$0d,$0f,$0d
		!byte $0f,$0f,$0e,$0f,$0e,$0e,$08,$0e
		!byte $08,$08,$0b,$08,$0b,$0b,$06,$0b
		!byte $06,$06,$0b,$0b,$0b,$0b,$0b,$0b

		* = logo_cosinus+$400
logo_colours_3	!byte $0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b
		!byte $06,$06,$0b,$06,$0b,$0b,$08,$0b
		!byte $08,$08,$0e,$08,$0e,$0e,$0f,$0e
		!byte $0f,$0f,$07,$0f,$07,$07,$01,$07
		!byte $01,$01,$07,$01,$07,$07,$0f,$07
		!byte $0f,$0f,$0e,$0f,$0e,$0e,$08,$0e
		!byte $08,$08,$0b,$08,$0b,$0b,$06,$0b
		!byte $06,$06,$0b,$0b,$0b,$0b,$0b,$0b

		!byte $06,$06,$0b,$06,$0b,$0b,$08,$0b
		!byte $08,$08,$0e,$08,$0e,$0e,$0f,$0e
		!byte $0f,$0f,$07,$0f,$07,$07,$01,$07
		!byte $01,$01,$07,$01,$07,$07,$0f,$07
		!byte $0f,$0f,$0e,$0f,$0e,$0e,$08,$0e
		!byte $08,$08,$0b,$08,$0b,$0b,$06,$0b
		!byte $06,$06,$0b,$0b,$0b,$0b,$0b,$0b

		!byte $06,$06,$0b,$06,$0b,$0b,$08,$0b
		!byte $08,$08,$0e,$08,$0e,$0e,$0f,$0e
		!byte $0f,$0f,$07,$0f,$07,$07,$01,$07
		!byte $01,$01,$07,$01,$07,$07,$0f,$07
		!byte $0f,$0f,$0e,$0f,$0e,$0e,$08,$0e
		!byte $08,$08,$0b,$08,$0b,$0b,$06,$0b
		!byte $06,$06,$0b,$0b,$0b,$0b,$0b,$0b

		* = logo_cosinus+$500
logo_colours_4	!byte $0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b
		!byte $09,$09,$0b,$09,$0b,$0b,$08,$0b
		!byte $08,$08,$0e,$08,$0e,$0e,$0f,$0e
		!byte $0f,$0f,$07,$0f,$07,$07,$01,$07
		!byte $01,$01,$07,$01,$07,$07,$0f,$07
		!byte $0f,$0f,$0e,$0f,$0e,$0e,$08,$0e
		!byte $08,$08,$0b,$08,$0b,$0b,$09,$0b
		!byte $09,$09,$0b,$0b,$0b,$0b,$0b,$0b

		!byte $09,$09,$0b,$09,$0b,$0b,$08,$0b
		!byte $08,$08,$0e,$08,$0e,$0e,$0f,$0e
		!byte $0f,$0f,$07,$0f,$07,$07,$01,$07
		!byte $01,$01,$07,$01,$07,$07,$0f,$07
		!byte $0f,$0f,$0e,$0f,$0e,$0e,$08,$0e
		!byte $08,$08,$0b,$08,$0b,$0b,$09,$0b
		!byte $09,$09,$0b,$0b,$0b,$0b,$0b,$0b

		!byte $09,$09,$0b,$09,$0b,$0b,$08,$0b
		!byte $08,$08,$0e,$08,$0e,$0e,$0f,$0e
		!byte $0f,$0f,$07,$0f,$07,$07,$01,$07
		!byte $01,$01,$07,$01,$07,$07,$0f,$07
		!byte $0f,$0f,$0e,$0f,$0e,$0e,$08,$0e
		!byte $08,$08,$0b,$08,$0b,$0b,$09,$0b
		!byte $09,$09,$0b,$0b,$0b,$0b,$0b,$0b

		* = logo_cosinus+$600
logo_colours_5	!byte $0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b
		!byte $09,$09,$02,$09,$02,$02,$08,$02
		!byte $08,$08,$0e,$08,$0e,$0e,$0f,$0e
		!byte $0f,$0f,$07,$0f,$07,$07,$01,$07
		!byte $01,$01,$07,$01,$07,$07,$0f,$07
		!byte $0f,$0f,$0e,$0f,$0e,$0e,$08,$0e
		!byte $08,$08,$02,$08,$02,$02,$09,$02
		!byte $09,$09,$0b,$0b,$0b,$0b,$0b,$0b

		!byte $09,$09,$02,$09,$02,$02,$08,$02
		!byte $08,$08,$0e,$08,$0e,$0e,$0f,$0e
		!byte $0f,$0f,$07,$0f,$07,$07,$01,$07
		!byte $01,$01,$07,$01,$07,$07,$0f,$07
		!byte $0f,$0f,$0e,$0f,$0e,$0e,$08,$0e
		!byte $08,$08,$02,$08,$02,$02,$09,$02
		!byte $09,$09,$0b,$0b,$0b,$0b,$0b,$0b

		!byte $09,$09,$02,$09,$02,$02,$08,$02
		!byte $08,$08,$0e,$08,$0e,$0e,$0f,$0e
		!byte $0f,$0f,$07,$0f,$07,$07,$01,$07
		!byte $01,$01,$07,$01,$07,$07,$0f,$07
		!byte $0f,$0f,$0e,$0f,$0e,$0e,$08,$0e
		!byte $08,$08,$02,$08,$02,$02,$09,$02
		!byte $09,$09,$0b,$0b,$0b,$0b,$0b,$0b

		* = logo_cosinus+$700
logo_colours_6	!byte $0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b
		!byte $09,$09,$02,$09,$02,$02,$08,$02
		!byte $08,$08,$0a,$08,$0a,$0a,$0f,$0a
		!byte $0f,$0f,$07,$0f,$07,$07,$01,$07
		!byte $01,$01,$07,$01,$07,$07,$0f,$07
		!byte $0f,$0f,$0a,$0f,$0a,$0a,$08,$0a
		!byte $08,$08,$02,$08,$02,$02,$09,$02
		!byte $09,$09,$0b,$0b,$0b,$0b,$0b,$0b

		!byte $09,$09,$02,$09,$02,$02,$08,$02
		!byte $08,$08,$0a,$08,$0a,$0a,$0f,$0a
		!byte $0f,$0f,$07,$0f,$07,$07,$01,$07
		!byte $01,$01,$07,$01,$07,$07,$0f,$07
		!byte $0f,$0f,$0a,$0f,$0a,$0a,$08,$0a
		!byte $08,$08,$02,$08,$02,$02,$09,$02
		!byte $09,$09,$0b,$0b,$0b,$0b,$0b,$0b

		!byte $09,$09,$02,$09,$02,$02,$08,$02
		!byte $08,$08,$0a,$08,$0a,$0a,$0f,$0a
		!byte $0f,$0f,$07,$0f,$07,$07,$01,$07
		!byte $01,$01,$07,$01,$07,$07,$0f,$07
		!byte $0f,$0f,$0a,$0f,$0a,$0a,$08,$0a
		!byte $08,$08,$02,$08,$02,$02,$09,$02
		!byte $09,$09,$0b,$0b,$0b,$0b,$0b,$0b

; Start positions in the set for each character
char_decode	!byte $00,$01,$03,$05,$07,$09,$0b,$0d		; @ to G
		!byte $0f,$11,$12,$14,$16,$18,$1b,$1d		; H to O
		!byte $1f,$21,$23,$25,$27,$29,$2b,$2d		; P to W
		!byte $30,$32,$34,$00,$00,$00,$00,$00		; X to Z, 5 * punct.
		!byte $00,$4b,$00,$00,$00,$00,$00,$52		; space to '
		!byte $00,$00,$00,$00,$51,$4e,$50,$00		; ( to /
		!byte $36,$38,$39,$3b,$3d,$3f,$41,$43		; 0 to 7
		!byte $45,$47,$4c,$4d,$00,$00,$00,$49		; 8 to ?

; Width for each character
char_width_dcd	!byte $01,$02,$02,$02,$02,$02,$02,$02		; @ to G
		!byte $02,$01,$02,$02,$02,$03,$02,$02		; H to O
		!byte $02,$02,$02,$02,$02,$02,$02,$03		; P to W
		!byte $02,$02,$02,$01,$01,$01,$01,$01		; X to Z, 5 * punct.
		!byte $01,$01,$01,$01,$01,$01,$01,$01		; space to '
		!byte $01,$01,$01,$01,$01,$02,$01,$01		; ( to /
		!byte $02,$01,$02,$02,$02,$02,$02,$02		; 0 to 7
		!byte $02,$02,$01,$01,$01,$01,$01,$02		; 8 to ?

; Text for the "Cosine present" line
lt1_data	!scr "         cosine present    md201509          "

; Scrolling message
scroll_text_2	!byte $82
		!scr "the cosine factories present"

		!byte $81
		!scr "    ''md201509''    "

		!byte $83
		!scr "a shadowy flight into the dangerous world of an idiot trying "
		!scr "to write small demos once a month!"
		!scr "      "

		!scr "it might seem like a silly idea but even an arbitrary deadline "
		!scr "like this can act as an incentive...  in theory at least."
		!scr "      "

		!byte $85
		!scr "the greetings and credits are all in the main part, so hit the "
		!scr "space bar to continue - you can pop over to the cosine website "
		!scr "at"

		!byte $82
		!scr "     cosine.org.uk     "
		!byte $85,$20
		!scr "for more of the same..."
		!scr "              "

		!byte $88
		!scr "t.m.r of cosine - 10-09-2015"
		!scr "              "
		!byte $00


; Cheap and cheerful patches to the crunched binary
; Remove $D030 writes
		* = $400e
		nop
		nop
		nop

		* = $412c
		nop
		nop
		nop

; Remove CLI
		* = $4137
		nop
