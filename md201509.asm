;
; MD201509 :: CHARLATAN-STYLE FLI "SPLITTER"
;

; Code by T.M.R/Cosine
; Graphics by T.M.R/Cosine
; Music by 4-Mat/ex-Cosine


; This source code is formatted for the ACME cross assembler from
; http://sourceforge.net/projects/acme-crossass/
; Compression is handled with PuCrunch which can be downloaded at
; http://csdb.dk/release/?id=6089


; Select an output filename
		!to "md201509.prg",cbm


; Yank in binary data
		* = $5800
		!binary "data/x-real_sprites.raw"

		* = $60f0
		!src "includes/bitmap_colour.asm"

		* = $6780
		!binary "data/x-real_bitmap.raw"

		* = $8800
char_data	!binary "data/7px.chr"

		* = $c000
		!binary "data/mystery_chords.dat",,2


; Constants
rstr1p		= $00
rstr2p		= $2c

; Labels
rn		= $50
sync		= $51
irq_store_1	= $52
rt_store_1	= $53

d016_mirror	= $54
scroll_x	= $55
scroll_speed	= $56
left_char	= $57

pset_flag	= $58
pset_tmr	= $59

blob_cnt	= $5a
blob_pulse_tmr	= $5b
blob_pls_dst	= $5c
blob_pls_dst_ct	= $5d


cos_at_1	= $60
cos_speed_1	= $61
cos_offset_1	= $62
cos_at_2	= $63

fli_split_tbl	= $70		; $30 bytes long

fli_colours	= $0400


; Code entry point at $0812
		* = $0812

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

; Merge the two effect colour tables
		ldx #$00
colour_merge	lda fli_colours_1,x
		asl
		asl
		asl
		asl
		ora fli_colours_2,x
		sta fli_colours,x
		inx
		bne colour_merge

; Build some sprites for the mask
		ldx #$00
		lda #$00
clr_sprite	sta $bf80,x
		inx
		cpx #$80
		bne clr_sprite

		ldx #$00
		lda #$ff
gen_sprite	sta $bf80,x
		inx
		cpx #$33
		bne gen_sprite

; Set the colour RAM and...
		ldx #$00
		lda #$0b
set_scrn_col	sta $d800,x
		sta $d900,x
		sta $da00,x
		sta $dae8,x
		inx
		bne set_scrn_col

; ...nuke the FLI colour data for all eight screens
		ldx #$00
		lda #$bb
colour_nuke	sta $a000,x
		sta $a400,x
		sta $a800,x
		sta $ac00,x
		sta $b000,x
		sta $b400,x
		sta $b800,x
		sta $bc00,x
		inx
		cpx #$c8
		bne colour_nuke

; Set colours for the lower bitmap picture
		ldx #$00
bmp_col_init	lda #$bb
		sta $5c00,x
		sta $5d00,x
		sta $5e00,x
		sta $5ee8,x
		inx
		bne bmp_col_init

; Invert the scrolling message character set
		ldx #$00
font_invert	lda $8800,x
		eor #$ff
		sta $8800,x
		lda $8900,x
		eor #$ff
		sta $8900,x
		inx
		bne font_invert

; Initialise the scrolling message
		jsr reset
		lda #$00
		sta scroll_x
		lda #$02
		sta scroll_speed
		lda #$08
		sta d016_mirror

; Set up the preset system/first movement settings
		lda #$00
		sta pset_flag
		sta pset_tmr
		jsr pset_reset

		lda #$00
		sta cos_at_1
		lda #$01
		sta cos_speed_1
		lda #$00
		sta cos_offset_1

		lda #$00
		sta blob_cnt
		sta blob_pulse_tmr

		lda #$1a
		sta blob_pls_dst

; Initialise the music
		jsr $c048

		cli


; Wait for the scroller to enable the dissolve effect
main_wait	ldy #$f0
		jsr sync_wait_long
		ldy #$30
		jsr sync_wait_long

main_wait_2	jsr sync_wait
		jsr blob_update

		lda pset_flag
		beq main_wait_2

		jsr pset_load

; Rez between the two colour tables
main_loop	ldy #$96
		jsr sync_wait
		jsr blob_update
		dey
		bne main_loop+$02

; Dissolve the bitmap between two possible states
		ldx #$00
main_dissolve	jsr sync_wait
		stx rt_store_1
		jsr blob_update
		ldx rt_store_1

		ldy random_data,x
		lda bitmap_data+$000,y
		eor #$ff
		and bitmap_mask+$000,y
		sta bitmap_data+$000,y

		lda bitmap_data+$100,y
		eor #$ff
		and bitmap_mask+$100,y
		sta bitmap_data+$100,y

		lda bitmap_data+$200,y
		eor #$ff
		and bitmap_mask+$200,y
		sta bitmap_data+$200,y

		lda bitmap_data+$300,y
		eor #$ff
		and bitmap_mask+$300,y
		sta bitmap_data+$300,y

		lda bitmap_data+$400,y
		eor #$ff
		and bitmap_mask+$400,y
		sta bitmap_data+$400,y

		lda bitmap_data+$500,y
		eor #$ff
		and bitmap_mask+$500,y
		sta bitmap_data+$500,y

		cpy #$40
		bcs md_skip
		lda bitmap_data+$600,y
		eor #$ff
		and bitmap_mask+$600,y
		sta bitmap_data+$600,y

md_skip		inx
		bne main_dissolve

		jmp main_loop

; Blob colour updater
blob_update	ldx blob_cnt
		lda blob_wrt_low,x
		sta bupd_call+$01
		lda blob_wrt_high,x
		sta bupd_call+$02

		ldx blob_pulse_tmr
		lda blob_pulse_cols,x
bupd_call	jsr blob_00_write
		inx
		cpx blob_pls_dst
		bne bupd_xb

		lda blob_cnt
		clc
		adc #$01
		and #$1f
		sta blob_cnt

		ldx blob_pls_dst_ct
		inx
		cpx #$05
		bne bupd_xb2
		ldx #$00
bupd_xb2	stx blob_pls_dst_ct
		lda blob_dests,x
		sta blob_pls_dst

		ldx #$00
bupd_xb		stx blob_pulse_tmr

		rts

; Top right cluster of blobs
blob_00_write	sta $6104
		sta $6105
		sta $6106
		sta $6107
		sta $612d
		sta $612e
		rts

blob_01_write	sta $6108
		sta $6109
		sta $610a
		sta $6130
		sta $6131
		sta $6132
		rts

blob_02_write	sta $610b
		sta $610c
		sta $610d
		sta $610e
		sta $610f
		sta $6133
		sta $6134
		sta $6135
		sta $6136
		sta $6137
		sta $615b
		sta $615c
		sta $615d
		sta $615e
		sta $615f
		sta $6184
		sta $6185
		sta $6186
		sta $6187
		rts

blob_03_write	sta $6110
		sta $6111
		sta $6138
		sta $6139
		rts

blob_04_write	sta $6112
		rts

blob_05_write	sta $6113
		sta $6114
		sta $6115
		sta $6116
		sta $6117
		sta $613b
		sta $613c
		sta $613d
		sta $613e
		sta $6165
		rts

blob_06_write	sta $6163
		rts

blob_07_write	sta $6156
		sta $6157
		sta $617e
		sta $617f
		rts

blob_08_write	sta $6158
		sta $6159
		sta $615a
		sta $6180
		sta $6181
		sta $6182
		sta $6183
		sta $61a8
		sta $61a9
		sta $61aa
		sta $61ab
		sta $61d0
		sta $61d1
		sta $61d2
		sta $61d3
		rts

blob_09_write	sta $61ac
		sta $61ad
		sta $61ae
		sta $61d4
		sta $61d5
		sta $61d6
		sta $61fc
		sta $61fd
		sta $61fe
		rts

blob_0a_write	sta $61fb
		rts

blob_0b_write	sta $6224
		sta $6225
		rts

blob_0c_write	sta $6161
		sta $6162
		sta $6188
		sta $6189
		sta $618a
		sta $61b0
		sta $61b1
		sta $61b2
		rts

; Bottom right cluster of blobs
blob_0d_write	sta $622f
		sta $6257
		rts

blob_0e_write	sta $6255
		sta $6256
		sta $627c
		sta $627d
		sta $627e
		sta $627f
		sta $62a4
		sta $62a5
		sta $62a6
		sta $62a7
		sta $62cc
		sta $62cd
		sta $62ce
		sta $62cf
		rts

blob_0f_write	sta $62a1
		sta $62c8
		sta $62c9
		sta $62ca
		sta $62ef
		sta $62f0
		sta $62f1
		sta $62f2
		sta $6318
		sta $6319
		sta $631a
		rts

blob_10_write	sta $6317
		sta $633f
		rts

blob_11_write	sta $6314
		sta $6315
		sta $6316
		sta $633c
		sta $633d
		sta $633e
		sta $6364
		sta $6365
		rts

blob_12_write	sta $6340
		sta $6341
		sta $6366
		sta $6367
		sta $6368
		sta $6369
		sta $636a
		sta $636b
		sta $638e
		sta $638f
		sta $6390
		sta $6391
		sta $6392
		sta $6393
		sta $63b6
		sta $63b7
		sta $63b8
		sta $63b9
		sta $63ba
		sta $63bb
		sta $63de
		sta $63df
		sta $63e0
		sta $63e1
		sta $63e2
		sta $63e3
		rts

blob_13_write	sta $638b
		sta $638c
		sta $638d
		sta $63b2
		sta $63b3
		sta $63b4
		sta $63b5
		sta $63da
		sta $63db
		sta $63dc
		sta $63dd
		rts

blob_14_write	sta $6362
		sta $638a
		rts

blob_15_write	sta $6388
		sta $6389

		sta $63af
		sta $63b0
		sta $63b1

		sta $63d8
		sta $63d9
		rts

blob_16_write	sta $63ae
		rts

blob_17_write	sta $62f4
		sta $62f5
		sta $631b
		sta $631c
		sta $631d
		sta $6343
		sta $6344
		sta $6345
		sta $636c
		sta $636d
		rts

blob_18_write	sta $62f3
		rts

blob_19_write	sta $62f7
		sta $631e
		sta $631f
		sta $6346
		sta $6347
		sta $636f
		rts

blob_1a_write	sta $6395
		sta $6396
		sta $6397
		sta $63bd
		sta $63be
		sta $63bf
		sta $63e5
		sta $63e6
		sta $63e7
		rts

; Top left cluster of blobs
blob_1b_write	sta $61ba
		rts

blob_1c_write	sta $61e1
		sta $61e2
		sta $6209
		sta $620a
		rts

blob_1d_write	sta $6230
		sta $6258
		rts

blob_1e_write	sta $62a8
		rts

blob_1f_write	sta $6348
		rts

; Runtime synchronisation
sync_wait	lda #$00
		sta sync
sw_loop		cmp sync
		beq sw_loop
		rts

sync_wait_long	jsr sync_wait
		dey
		bne sync_wait_long
		rts


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


; Raster split 1 (only called for the first frame)
rout1		lda #$02
		sta rn
		lda #rstr2p
		sta $d012

		lda #$0b
		sta $d020
		sta $d021

; Sprite data pointers for the masks
		lda #$ff
		sta $a3fe
		sta $a7fe
		sta $abfe
		sta $affe
		sta $b3fe
		sta $b7fe
		sta $bbfe
		sta $bffe

		lda #$fe
		sta $a3ff
		sta $a7ff
		sta $abff
		sta $afff
		sta $b3ff
		sta $b7ff
		sta $bbff
		sta $bfff

; Setups for the moving block sprites
		ldx #$66
		stx $63f8
		stx $63f9
		stx $63fa
		stx $63fb

		lda #$0c
		sta $d027
		lda #$0a
		sta $d028
		lda #$05
		sta $d029
		lda #$0e
		sta $d02a


		lda #$c5
		sta $dd00

		jmp ea31


		* = ((*/$100)+1)*$100

; Raster split 2
rout2		lda #$3b
		sta $d011
		nop
		nop
		bit $ea

; Time up for the FLI
		lda $d012
		cmp #rstr2p+$01
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		nop
		nop
		lda $d012
		cmp #rstr2p+$02
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		nop
		lda $d012
		cmp #rstr2p+$03
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		nop
		lda $d012
		cmp #rstr2p+$04
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		bit $ea
		nop
		lda $d012
		cmp #rstr2p+$05
		bne *+$02
;		sta $d020

		lda fli_split_tbl+$00
		sta $d021
		lda #$18
		sta $d016
		lda #$80
		sta $d018
		lda #$3b
		sta $d011
		lda #$c5
		sta $dd00
		bit $ea

		ldx #$04
		dex
		bne *-$01
		lda $d012
		cmp #rstr2p+$06
		bne *+$02
;		sta $d020


; Unrolled FLI routine - first character line
fli_start	ldx #$0c
		dex
		bne *-$01
		nop

		ldx #$3c
		ldy #$90
		lda fli_split_tbl+$01
		sta $d021
		sty $d018
		stx $d011

		ldx #$3d
		ldy #$a0
		lda fli_split_tbl+$02
		sta $d021
		sty $d018
		stx $d011

		ldx #$3e
		ldy #$b0
		lda fli_split_tbl+$03
		sta $d021
		sty $d018
		stx $d011

		ldx #$3f
		ldy #$c0
		lda fli_split_tbl+$04
		sta $d021
		sty $d018
		stx $d011

		ldx #$38
		ldy #$d0
		lda fli_split_tbl+$05
		sta $d021
		sty $d018
		stx $d011

		ldx #$39
		ldy #$e0
		lda fli_split_tbl+$06
		sta $d021
		sty $d018
		stx $d011

		ldx #$3a
		ldy #$f0
		lda fli_split_tbl+$07
		sta $d021
		sty $d018
		stx $d011

; Unrolled FLI routine - second character line onwards
!set line_cnt=$00
!do {
		ldx #$3b
		ldy #$80
		lda fli_split_tbl+$08+(line_cnt*$08)
		sta $d021
		sty $d018
		stx $d011

		ldx #$3c
		ldy #$90
		lda fli_split_tbl+$09+(line_cnt*$08)
		sta $d021
		sty $d018
		stx $d011

!if line_cnt<$03 {

		ldx #$3d
		ldy #$a0
		lda fli_split_tbl+$0a+(line_cnt*$08)
		sta $d021
		sty $d018
		stx $d011

		ldx #$3e
		ldy #$b0
		lda fli_split_tbl+$0b+(line_cnt*$08)
		sta $d021
		sty $d018
		stx $d011

		ldx #$3f
		ldy #$c0
		lda fli_split_tbl+$0c+(line_cnt*$08)
		sta $d021
		sty $d018
		stx $d011

		ldx #$38
		ldy #$d0
		lda fli_split_tbl+$0d+(line_cnt*$08)
		sta $d021
		sty $d018
		stx $d011

		ldx #$39
		ldy #$e0
		lda fli_split_tbl+$0e+(line_cnt*$08)
		sta $d021
		sty $d018
		stx $d011

		ldx #$3a
		ldy #$f0
		lda fli_split_tbl+$0f+(line_cnt*$08)
		sta $d021
		sty $d018
		stx $d011

} else {

; Unrolled FLI routine - last character line
		ldx #$3d
		ldy #$c0
		lda #$0b
		sta $d021
		sty $d018
		stx $d011
}
		!set line_cnt=line_cnt+$01
} until line_cnt=$04

		lda #$00
		sta $d017

		lda #$3b
		sta $d011
		lda #$82
		sta $d018

		ldx #$34
		dex
		bne *-$01

		lda scroll_x
		lda d016_mirror
		and #$07
		sta $d00c
		nop
		nop
		nop
		nop
		nop
		nop

; Raster has reached the scroller's area of the screen
		lda #$1b
		bit $ea
		sta $d011

		lda d016_mirror
		sta $d016

		bit $ea
		nop

; Vertical colour splits for the scroller
		lda #$02
		sta $d021
		lda #$08
		sta $d021
		lda #$0a
		sta $d021
		lda #$0f
		sta $d021
		lda #$0e
		sta $d021
		lda #$04
		sta $d021
		lda #$0b
		sta $d021

		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop

		lda #$08
		sta $d021
		lda #$0a
		sta $d021
		lda #$0f
		sta $d021
		lda #$0d
		sta $d021
		lda #$0f
		sta $d021
		lda #$0e
		sta $d021
		lda #$04
		sta $d021

		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop

		lda #$0a
		sta $d021
		lda #$0f
		sta $d021
		lda #$07
		sta $d021
		lda #$01
		sta $d021
		lda #$0d
		sta $d021
		lda #$0f
		sta $d021
		lda #$0e
		sta $d021

		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop

		lda #$0f
		sta $d021
		lda #$07
		sta $d021
		lda #$01
		sta $d021
		lda #$01
		sta $d021
		lda #$01
		sta $d021
		lda #$0d
		sta $d021
		lda #$0f
		sta $d021

		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop

		lda #$0a
		sta $d021
		lda #$0f
		sta $d021
		lda #$07
		sta $d021
		lda #$01
		sta $d021
		lda #$0d
		sta $d021
		lda #$0f
		sta $d021
		lda #$0e
		sta $d021

		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop

		lda #$08
		sta $d021
		lda #$0a
		sta $d021
		lda #$0f
		sta $d021
		lda #$0d
		sta $d021
		lda #$03
		sta $d021
		lda #$0e
		sta $d021
		lda #$04
		sta $d021

		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop

		lda #$02
		sta $d021
		lda #$08
		sta $d021
		lda #$0a
		sta $d021
		lda #$0f
		sta $d021
		lda #$0e
		sta $d021
		lda #$04
		sta $d021
		lda #$0b
		sta $d021

		lda #$08
		sta $d016

		lda #$78
		sta $d018
		lda #$c6
		sta $dd00
		lda #$3f
		sta $d011


		ldx #$0c
		dex
		bne *-$01
		lda #$88
		sta $d018

; Hide the scroller mask sprite
		lda #$40
		sta $d00c

; Set up sprite underlays for turtle
		lda #$50
		sta $d008
		lda #$80
		sta $d00a
		lda #$b0
		sta $d00e
		lda #$6d
		sta $d009
		sta $d00b
		sta $d00f

		ldx #$60
		stx $63fc
		inx
		stx $63fd
		inx
		stx $63ff

		lda #$0e
		sta $d02b
		sta $d02c
		sta $d02e

		lda #$0f
		sta $d017
		lda #$ff
		sta $d01b
		sta $d01d

; Main effect unrolled colour update - $D021 splits
		lda cos_at_1
		clc
		adc cos_speed_1
		sta cos_at_1
		tax
		ldy fli_cosinus,x
		stx irq_store_1
!set line_cnt=$00
!do {
		lda fli_colours+line_cnt,y
		ldx bitmap_data+$18+line_cnt
		cpx #$55
		bne *+$06
		lsr
		lsr
		lsr
		lsr
		sta fli_split_tbl+line_cnt

		!set line_cnt=line_cnt+$01
} until line_cnt=$22

		ldx irq_store_1

; Main effect unrolled colour update - FLI colours
!set column_cnt=$00
!do {
		txa
		clc
		adc cos_offset_1
		tax
		ldy fli_cosinus,x
		lda fli_colours+$00,y
		sta $a003+column_cnt
		lda fli_colours+$01,y
		sta $a403+column_cnt
		lda fli_colours+$02,y
		sta $a803+column_cnt
		lda fli_colours+$03,y
		sta $ac03+column_cnt
		lda fli_colours+$04,y
		sta $b003+column_cnt
		lda fli_colours+$05,y
		sta $b403+column_cnt
		lda fli_colours+$06,y
		sta $b803+column_cnt
		lda fli_colours+$07,y
		sta $bc03+column_cnt

		lda fli_colours+$08,y
		sta $a02b+column_cnt
		lda fli_colours+$09,y
		sta $a42b+column_cnt
		lda fli_colours+$0a,y
		sta $a82b+column_cnt
		lda fli_colours+$0b,y
		sta $ac2b+column_cnt
		lda fli_colours+$0c,y
		sta $b02b+column_cnt
		lda fli_colours+$0d,y
		sta $b42b+column_cnt
		lda fli_colours+$0e,y
		sta $b82b+column_cnt
		lda fli_colours+$0f,y
		sta $bc2b+column_cnt

		lda fli_colours+$10,y
		sta $a053+column_cnt
		lda fli_colours+$11,y
		sta $a453+column_cnt
		lda fli_colours+$12,y
		sta $a853+column_cnt
		lda fli_colours+$13,y
		sta $ac53+column_cnt
		lda fli_colours+$14,y
		sta $b053+column_cnt
		lda fli_colours+$15,y
		sta $b453+column_cnt
		lda fli_colours+$16,y
		sta $b853+column_cnt
		lda fli_colours+$17,y
		sta $bc53+column_cnt

		lda fli_colours+$18,y
		sta $a07b+column_cnt
		lda fli_colours+$19,y
		sta $a47b+column_cnt
		lda fli_colours+$1a,y
		sta $a87b+column_cnt
		lda fli_colours+$1b,y
		sta $ac7b+column_cnt
		lda fli_colours+$1c,y
		sta $b07b+column_cnt
		lda fli_colours+$1d,y
		sta $b47b+column_cnt
		lda fli_colours+$1e,y
		sta $b87b+column_cnt
		lda fli_colours+$1f,y
		sta $bc7b+column_cnt

		lda fli_colours+$20,y
		sta $a0a3+column_cnt
		lda fli_colours+$21,y
		sta $a4a3+column_cnt

; Pause during the updating to move the mask sprites
		!if column_cnt=$02 {

		lda #$34
		sta $d00a
		lda #$66
		sta $d00c
		lda #$d8
		sta $d00e
		lda #$8e
		sta $d00b
		lda #$90
		sta $d00d
		lda #$a6
		sta $d00f

		lda #$64
		sta $63fd
		lda #$63
		sta $63fe
		lda #$65
		sta $63ff

		lda #$0c
		sta $d02c
		lda #$0f
		sta $d02d
		lda #$05
		sta $d02e

		}

		!set column_cnt=column_cnt+$01
}until column_cnt=$25

; Update the scrolling message
		ldy scroll_speed

scroll_upd_loop	ldx scroll_x
		inx
		cpx #$08
		bne sx_xb

		lda $a0c8
		sta left_char

; Shift the line that the scroller sits on
		ldx #$00
mover		lda $a0c9,x
		sta $a0c8,x
		inx
		cpx #$27
		bne mover

; Read a byte from the scroll text
mread		lda scroll_text
		bne okay
		jsr reset_2
		jmp mread

; Check for the effect trigger byte
okay		cmp #$ff
		bne okay_2
		lda #$01
		sta pset_flag
		lda #$20

; Check for a speed control byte
okay_2		cmp #$81
		bcc okay_3
		and #$0f
		sta scroll_speed

		inc mread+$01
		bne *+$05
		inc mread+$02
		jmp mread

; Write byte to scroller
okay_3		sta $a0c8+$27

		inc mread+$01
		bne *+$05
		inc mread+$02

		ldx #$00
sx_xb		stx scroll_x

		dey
		bne scroll_upd_loop

		txa
		and #$07
		eor #$0f
		sta d016_mirror

; Copy the lefthand character of the scroller to a sprite
		lda left_char
		sta def_copy+$01
		lda #$00
		asl def_copy+$01
		rol
		asl def_copy+$01
		rol
		asl def_copy+$01
		rol
		clc
		adc #>char_data
		sta def_copy+$02

		ldx #$01
		ldy #$03
def_copy	lda $6464,x
		sta $bfc2,y
		iny
		iny
		iny
		inx
		cpx #$08
		bne def_copy

; Play the music
		jsr $c021

; Set the sprites up for the start of the next frame
		lda #$ff
		sta $d015
		lda #$80
		sta $d017

		lda #$00
		sta $d01b
		lda #$3f
		sta $d01d

		lda #$5a
		sta $d00d

		lda #$10
		sta $d00e
		lda #$32
		sta $d00f

		lda #$0b
		sta $d02d
		lda #$00
		sta $d02e
		lda #$00
		sta $d010

; Update the coloured block sprite positions
		lda block_x+$03
		cmp #$d0
		bcc *+$05
		sec
		sbc #$04
		asl
		rol $d010
		ora block_x_nudge+$03
		sta $d006

		lda block_x+$02
		cmp #$d0
		bcc *+$05
		sec
		sbc #$04
		asl
		rol $d010
		ora block_x_nudge+$02
		sta $d004

		lda block_x+$01
		cmp #$d0
		bcc *+$05
		sec
		sbc #$04
		asl
		rol $d010
		ora block_x_nudge+$01
		sta $d002

		lda block_x+$00
		cmp #$d0
		bcc *+$05
		sec
		sbc #$04
		asl
		rol $d010
		ora block_x_nudge+$00
		sta $d000

		inc cos_at_2
		ldx cos_at_2
		lda block_cosinus,x
		sta $d001

		txa
		clc
		adc #$37
		tax
		lda block_cosinus,x
		sta $d003

		txa
		clc
		adc #$37
		tax
		lda block_cosinus,x
		sta $d005

		txa
		clc
		adc #$37
		tax
		lda block_cosinus,x
		sta $d007

		dec block_x+$03
		dec block_x+$03
		dec block_x+$02

		ldx block_x_nudge+$01
		dex
		cpx #$ff
		bne *+$07
		dec block_x+$01
		ldx #$01
		stx block_x_nudge+$01

		ldx block_x_nudge+$00
		dex
		cpx #$ff
		bne *+$07
		dec block_x+$00
		ldx #$01
		dex
		cpx #$ff
		bne *+$07
		dec block_x+$00
		ldx #$01
		dex
		cpx #$ff
		bne *+$07
		dec block_x+$00
		ldx #$01
		stx block_x_nudge+$00

; Chec to see if the preset system is running and if a new one is needed
		lda pset_flag
		beq no_preset

		dec pset_tmr
		bne no_preset

		jsr pset_load

; Get ready exit the interrupt
no_preset	lda #rstr2p
		sta $d012
		lda #$01
		sta sync

ea31		pla
		tay
		pla
		tax
		pla
nmi		rti

; Scroller self mod resets (start and restart points respectively)
reset		lda #<scroll_text
		sta mread+$01
		lda #>scroll_text
		sta mread+$02
		rts

reset_2		lda #<scroll_text_wp
		sta mread+$01
		lda #>scroll_text_wp
		sta mread+$02
		rts

; Effect preset handler
pset_load	jsr pset_mread
		cmp #$7f
		bne psl_okay
		jsr pset_reset
		jmp pset_load

psl_okay	cmp #$80
		beq *+$04
		sta cos_at_1

		jsr pset_mread
		cmp #$80
		beq *+$04
		sta cos_speed_1

		jsr pset_mread
		cmp #$80
		beq *+$04
		sta cos_offset_1

		jsr pset_mread
		sta pset_tmr

		rts

; Effect preset handler's self mod code and reset
pset_mread	lda pset_data
		inc pset_mread+$01
		bne *+$05
		inc pset_mread+$02
		rts

pset_reset	lda #<pset_data
		sta pset_mread+$01
		lda #>pset_data
		sta pset_mread+$02
		rts


; Scrolling message - initial start
scroll_text	!scr "  "
		!scr "hey, what's that black area over there?   well...   "
		!scr "it's a split.   you can see two splits, can't you...?   "
		!scr "that wasn't a good joke..."
		!scr "         "
		!byte $ff	; enable preset mode/dissolve
		!scr "        "

; Scrolling message - restart point
scroll_text_wp	!byte $83
		!scr "hello and welcome to"
		!byte $81
		!scr "   md201509  from  cosine   "
		!byte $83
		!scr "(or monthly demo - september 2015 to use it's full title) "

		!scr "which is the first in what will hopefully be an ongoing "
		!scr "series of regular one-filed demos from the cosine dungeons "
		!scr "deep in the heart of darkest yorkshire!   well okay, it's "
		!scr "actually a spare bedroom but you get the idea..."
		!scr "        "

		!scr "a few people will already have spotted that this is a cover "
		!scr "version of the classic "
		!byte $81
		!scr "charlatan by beyond force "
		!byte $83
		!scr " - which donated the start of this text as well - "
		!scr "because i woke up one morning about a month ago and found "
		!scr "myself wondering about writing something that used the same "
		!scr "general technique but added an extra colour split in the fli "
		!scr "area to finally "
		!byte $22
		!scr "beat"
		!byte $22,$20
		!scr "solomon's long-standing thirty seven split record!"
		!scr "        "

		!scr "and don't worry kids, i'm really not being serious about "
		!scr "aiming for that record;   "
		!scr "this code was written to get my head around how that original "
		!scr "demo was done and then experiment with cycle timing (there "
		!scr "are sprites over the fli area and the left edge of this "
		!scr "scroller since the screen is forty columns wide) "
		!scr "but i liked the movement of the bars and that dissolve "
		!scr "effect too much for this to just gather virtual dust "
		!scr "somewhere on my hard disk so, after a couple of days spent "
		!scr "sprucing everything up, here it is."
		!scr "        "

		!byte $82
		!scr "the credits for both this part and the intro are as follows:   "
		!scr "coding, graphics and wiring by t.m.r whilst accompanied "
		!scr "by former cosine member 4-mat on the sid.   "
		!scr "the bitmap below was originally drawn by prof4d for the "
		!scr "spectrum and manipulated by t.m.r to add colour - the "
		!scr "original was monochrome - and fill the c64's 40 column "
		!scr "display."
		!scr "        "

		!byte $83
		!scr "so...   why monthly demos you might be asking?   well, i'm "
		!scr "decrepit enough to remember those days in the mid 1980s when "
		!scr "our teenage selves would rip some graphics or sound, throw a "
		!scr "chunk of code around it and just release the results on the "
		!scr "next spread disk.   "

		!scr "so a couple of months back whilst i was mumbling about those "
		!scr "days, i happened to stumble on some monthly demos by the "
		!scr "second ring and ideas sort of fell into place...   why not "
		!scr "try to write little one-filers to release each month?   "
		!scr "i can wire pictures and convert fonts easily enough and "
		!scr "there are quite a few tunes by cosine members that were "
		!scr "never used in a demo, but if this idea sticks i'll start "
		!scr "properly asking around to find people willing to "
		!scr "collaborate as well."
		!scr "        "

		!scr "not all of the monthly demos are going to be aimed at the "
		!scr "c64 though (i already have a few ideas to try on other "
		!scr "8-bit systems) and knowing me it shouldn't come as a surprise "
		!scr "if the occasional deadline drifts lazily past without event "
		!scr "but, after an unexpectedly protracted amount of soul searching "
		!scr "with the other cosine members "
		!scr "both online and in a couple of cases across a table at "
		!scr "play margate, here we go!"
		!scr "        "

		!byte $84
		!scr "that said, one thing i haven't quite got my head around is "
		!scr "writing the reams of scrolltext these demos will need "
		!scr "so, since the ideas well is dry and there's nobody around "
		!scr "to top it up, this seems a good moment to be getting the "
		!scr "greetings sorted."
		!scr "    "
		!scr "cheery waves head out in the general "
		!scr "direction of..."
		!scr "    "

		!byte $86
		!scr "abyss connection - "
		!scr "arkanix labs - "
		!scr "artstate - "
		!scr "ate bit - "
		!scr "booze design - "
		!scr "camelot - "
		!scr "chorus - "
		!scr "chrome - "
		!scr "c.n.c.d. - "
		!scr "c.p.u. - "
		!scr "crescent - "
		!scr "crest - "
		!scr "covert bitops - "
		!scr "defence force - "
		!scr "dekadence - "
		!scr "desire - "
		!scr "d.a.c. - "
		!scr "dmagic - "
		!scr "dual crew - "
		!scr "fairlight - "
		!scr "fire - "
		!scr "focus - "
		!scr "funkscientist productions - "
		!scr "genesis project - "
		!scr "gheymaid inc. - "
		!scr "hitmen - "
		!scr "hokuto force - "
		!scr "level64 - "
		!scr "m and m - "
		!scr "maniacs of noise - "
		!scr "meanteam - "
		!scr "metalvotze - "
		!scr "noname - "
		!scr "nostalgia - "
		!scr "nuance - "
		!scr "offence - "
		!scr "onslaught - "
		!scr "orb - "
		!scr "oxyron - "
		!scr "padua - "
		!scr "plush - "
		!scr "psytronik - "
		!scr "reptilia - "
		!scr "resource - "
		!scr "rgcd - "
		!scr "secure - "
		!scr "shape - "
		!scr "side b - "
		!scr "slash - "
		!scr "slipstream - "
		!scr "success and trc - "
		!scr "style - "
		!scr "suicyco industries - "
		!scr "taquart - "
		!scr "tempest - "
		!scr "tek - "
		!scr "triad - "
		!scr "trsi - "
		!scr "viruz - "
		!scr "vision - "
		!scr "wow - "
		!scr "wrath - "
		!scr "xenon - "
		!scr "and of course a now traditional apology to anybody who "
		!scr "was forgotten!"
		!scr "                                        "

		!byte $82

		!scr "don't forget to visit the cosine website over at "
		!byte $81
		!scr "http://cosine.org.uk/"
		!byte $83,$20
		!scr "once in a while or my own website at "
		!byte $81
		!scr "http://jasonkelk.me.uk/"
		!byte $83,$20
		!scr "and that's pretty much me done i think...   "
		!scr "your host for this demo has been     "

		!byte $84
		!scr "the magic roundabout of cosine  - signing off on 2015-09-10"
		!scr "... .. .  .      "
		!scr "              "

		!byte $00	; end of text marker

; Block sprite X positions
block_x		!byte $40,$c0,$40,$c0
block_x_nudge	!byte $00,$00,$00,$00

; Effect preset data - position in curve, add speed, offset, run length
; first byte as $7f means wrap, $80 in any byte means skip
pset_data	!byte $fe,$01,$08,$f0
		!byte $80,$fe,$80,$40
		!byte $80,$fd,$80,$10
		!byte $80,$fc,$80,$80

		!byte $80,$80,$09,$04
		!byte $80,$80,$0a,$04
		!byte $80,$80,$0b,$04
		!byte $80,$80,$0c,$04
		!byte $80,$80,$0d,$04
		!byte $80,$80,$0e,$04
		!byte $80,$80,$0f,$04
		!byte $80,$80,$10,$04
		!byte $80,$80,$11,$04
		!byte $80,$80,$12,$04
		!byte $80,$80,$13,$04
		!byte $80,$80,$14,$04
		!byte $80,$80,$15,$04
		!byte $80,$80,$16,$04
		!byte $80,$80,$17,$04
		!byte $80,$80,$18,$c0

		!byte $80,$fd,$18,$14
		!byte $80,$fe,$80,$14
		!byte $80,$ff,$80,$14
		!byte $80,$00,$80,$80
		!byte $80,$01,$80,$14
		!byte $80,$02,$80,$14
		!byte $80,$03,$80,$14
		!byte $80,$04,$80,$f0
		!byte $80,$80,$80,$f0

		!byte $80,$80,$17,$02
		!byte $80,$80,$16,$02
		!byte $80,$80,$15,$02
		!byte $80,$80,$14,$02
		!byte $80,$80,$13,$02
		!byte $80,$80,$12,$02
		!byte $80,$80,$11,$02
		!byte $80,$80,$10,$02
		!byte $80,$80,$0f,$02
		!byte $80,$80,$0e,$02
		!byte $80,$80,$0d,$02
		!byte $80,$80,$0c,$02
		!byte $80,$80,$0b,$02
		!byte $80,$80,$0a,$02
		!byte $80,$80,$09,$02
		!byte $80,$80,$08,$02
		!byte $80,$80,$07,$02
		!byte $80,$80,$06,$02
		!byte $80,$80,$05,$02
		!byte $80,$80,$04,$02
		!byte $80,$80,$03,$02
		!byte $80,$80,$02,$02
		!byte $80,$80,$01,$a0

		!byte $80,$fe,$2e,$01
		!byte $80,$80,$01,$01
		!byte $80,$fe,$2e,$01
		!byte $80,$80,$01,$01
		!byte $80,$fe,$2e,$01
		!byte $80,$80,$01,$01
		!byte $80,$fe,$2e,$01
		!byte $80,$80,$01,$01
		!byte $80,$fe,$2e,$01
		!byte $80,$80,$01,$01
		!byte $80,$fe,$2e,$01
		!byte $80,$80,$01,$01
		!byte $80,$fe,$2e,$01
		!byte $80,$80,$01,$01
		!byte $80,$fe,$2e,$01
		!byte $80,$80,$01,$01

		!byte $80,$fe,$2e,$01
		!byte $80,$80,$01,$01
		!byte $80,$fe,$2e,$01
		!byte $80,$80,$01,$01
		!byte $80,$fe,$2e,$01
		!byte $80,$80,$01,$01
		!byte $80,$fe,$2e,$01
		!byte $80,$80,$01,$01
		!byte $80,$fe,$2e,$01
		!byte $80,$80,$01,$01
		!byte $80,$fe,$2e,$01
		!byte $80,$80,$01,$01
		!byte $80,$fe,$2e,$01
		!byte $80,$80,$01,$01
		!byte $80,$fe,$2e,$01
		!byte $80,$80,$01,$01

		!byte $80,$fe,$2e,$c0
		!byte $80,$80,$2c,$20
		!byte $80,$80,$2a,$20
		!byte $80,$80,$28,$20
		!byte $80,$80,$26,$20
		!byte $80,$80,$24,$20
		!byte $80,$80,$22,$20
		!byte $80,$80,$20,$20
		!byte $80,$80,$1e,$c0

		!byte $fe,$01,$01,$c0
		!byte $80,$80,$02,$03
		!byte $80,$80,$03,$03
		!byte $80,$80,$04,$03
		!byte $80,$80,$05,$03
		!byte $80,$80,$06,$03
		!byte $80,$80,$07,$03
		!byte $80,$02,$08,$03
		!byte $80,$80,$09,$03
		!byte $80,$03,$0a,$03
		!byte $80,$80,$0b,$03
		!byte $80,$04,$0c,$03
		!byte $80,$80,$0d,$03
		!byte $80,$05,$0e,$03
		!byte $80,$80,$0f,$03
		!byte $80,$06,$10,$03
		!byte $80,$80,$10,$03
		!byte $80,$07,$10,$03
		!byte $80,$80,$10,$03
		!byte $80,$08,$10,$c0

		!byte $80,$80,$0f,$02
		!byte $80,$07,$0e,$02
		!byte $80,$80,$0d,$02
		!byte $80,$06,$0c,$02
		!byte $80,$80,$0b,$02
		!byte $80,$05,$0a,$02
		!byte $80,$80,$09,$02
		!byte $80,$04,$08,$02
		!byte $80,$80,$07,$02
		!byte $80,$03,$06,$02
		!byte $80,$80,$05,$02
		!byte $80,$02,$04,$02
		!byte $80,$80,$03,$02
		!byte $80,$01,$02,$02
		!byte $80,$80,$01,$02
		!byte $80,$00,$00,$40

		!byte $80,$81,$80,$c0
		!byte $80,$80,$ff,$05
		!byte $80,$80,$fe,$05
		!byte $80,$80,$fd,$05
		!byte $80,$80,$fc,$05
		!byte $80,$80,$fb,$05
		!byte $80,$80,$fa,$05
		!byte $80,$80,$f9,$05
		!byte $80,$80,$f8,$05
		!byte $80,$80,$f7,$05
		!byte $80,$80,$f6,$05
		!byte $80,$80,$f5,$a0

		!byte $80,$82,$80,$01
		!byte $80,$83,$80,$01
		!byte $80,$84,$80,$01
		!byte $80,$85,$80,$01
		!byte $80,$86,$80,$01
		!byte $80,$87,$80,$01
		!byte $80,$88,$80,$01
		!byte $80,$89,$80,$01
		!byte $80,$8a,$80,$01
		!byte $80,$8b,$80,$01
		!byte $80,$8c,$80,$01
		!byte $80,$8d,$80,$01
		!byte $80,$8e,$80,$01
		!byte $80,$8f,$80,$01

		!byte $80,$90,$80,$01
		!byte $80,$91,$80,$01
		!byte $80,$92,$80,$01
		!byte $80,$93,$80,$01
		!byte $80,$94,$80,$01
		!byte $80,$95,$80,$01
		!byte $80,$96,$80,$01
		!byte $80,$97,$80,$01
		!byte $80,$98,$80,$01
		!byte $80,$99,$80,$01
		!byte $80,$9a,$80,$01
		!byte $80,$9b,$80,$01
		!byte $80,$9c,$80,$01
		!byte $80,$9d,$80,$01
		!byte $80,$9e,$80,$01
		!byte $80,$9f,$80,$01

		!byte $80,$a0,$80,$01
		!byte $80,$a1,$80,$01
		!byte $80,$a2,$80,$01
		!byte $80,$a3,$80,$01
		!byte $80,$a4,$80,$01
		!byte $80,$a5,$80,$01
		!byte $80,$a6,$80,$01
		!byte $80,$a7,$80,$01
		!byte $80,$a8,$80,$01
		!byte $80,$a9,$80,$01
		!byte $80,$aa,$80,$01
		!byte $80,$ab,$80,$01
		!byte $80,$ac,$80,$01
		!byte $80,$ad,$80,$01
		!byte $80,$ae,$80,$01
		!byte $80,$af,$80,$01

		!byte $80,$b0,$80,$01
		!byte $80,$b1,$80,$01
		!byte $80,$b2,$80,$01
		!byte $80,$b3,$80,$01
		!byte $80,$b4,$80,$01
		!byte $80,$b5,$80,$01
		!byte $80,$b6,$80,$01
		!byte $80,$b7,$80,$01
		!byte $80,$b8,$80,$01
		!byte $80,$b9,$80,$01
		!byte $80,$ba,$80,$01
		!byte $80,$bb,$80,$01
		!byte $80,$bc,$80,$01
		!byte $80,$bd,$80,$01
		!byte $80,$be,$80,$01
		!byte $80,$bf,$80,$01

		!byte $80,$c0,$80,$01
		!byte $80,$c1,$80,$01
		!byte $80,$c2,$80,$01
		!byte $80,$c3,$80,$01
		!byte $80,$c4,$80,$01
		!byte $80,$c5,$80,$01
		!byte $80,$c6,$80,$01
		!byte $80,$c7,$80,$01
		!byte $80,$c8,$80,$01
		!byte $80,$c9,$80,$01
		!byte $80,$ca,$80,$01
		!byte $80,$cb,$80,$01
		!byte $80,$cc,$80,$01
		!byte $80,$cd,$80,$01
		!byte $80,$ce,$80,$01
		!byte $80,$cf,$80,$01

		!byte $80,$d0,$80,$01
		!byte $80,$d1,$80,$01
		!byte $80,$d2,$80,$01
		!byte $80,$d3,$80,$01
		!byte $80,$d4,$80,$01
		!byte $80,$d5,$80,$01
		!byte $80,$d6,$80,$01
		!byte $80,$d7,$80,$01
		!byte $80,$d8,$80,$01
		!byte $80,$d9,$80,$01
		!byte $80,$da,$80,$01
		!byte $80,$db,$80,$01
		!byte $80,$dc,$80,$01
		!byte $80,$dd,$80,$01
		!byte $80,$de,$80,$01
		!byte $80,$df,$80,$01

		!byte $80,$e0,$80,$01
		!byte $80,$e1,$80,$01
		!byte $80,$e2,$f6,$01
		!byte $80,$e3,$80,$01
		!byte $80,$e4,$80,$01
		!byte $80,$e5,$f7,$01
		!byte $80,$e6,$80,$01
		!byte $80,$e7,$80,$01
		!byte $80,$e8,$f8,$01
		!byte $80,$e9,$80,$01
		!byte $80,$ea,$80,$01
		!byte $80,$eb,$f9,$01
		!byte $80,$ec,$80,$01
		!byte $80,$ed,$80,$01
		!byte $80,$ee,$fa,$01
		!byte $80,$ef,$80,$01

		!byte $80,$f0,$80,$01
		!byte $80,$f1,$fb,$01
		!byte $80,$f2,$80,$01
		!byte $80,$f3,$80,$01
		!byte $80,$f4,$fc,$01
		!byte $80,$f5,$80,$01
		!byte $80,$f6,$80,$01
		!byte $80,$f7,$fd,$01
		!byte $80,$f8,$80,$01
		!byte $80,$f9,$80,$01
		!byte $80,$fa,$fe,$01
		!byte $80,$fb,$80,$01
		!byte $80,$fc,$80,$01
		!byte $80,$fd,$80,$01
		!byte $80,$fe,$80,$01
		!byte $80,$ff,$80,$01

		!byte $80,$00,$80,$a0

		!byte $7f		; end of preset data

; Jump tables for the unrolled blob subroutines
blob_wrt_low	!byte <blob_0e_write
		!byte <blob_1a_write
		!byte <blob_0c_write
		!byte <blob_1c_write
		!byte <blob_1d_write
		!byte <blob_16_write
		!byte <blob_00_write
		!byte <blob_17_write

		!byte <blob_0d_write
		!byte <blob_03_write
		!byte <blob_08_write
		!byte <blob_01_write
		!byte <blob_04_write
		!byte <blob_0a_write
		!byte <blob_0f_write
		!byte <blob_1f_write

		!byte <blob_0b_write
		!byte <blob_1e_write
		!byte <blob_10_write
		!byte <blob_11_write
		!byte <blob_07_write
		!byte <blob_19_write
		!byte <blob_09_write
		!byte <blob_12_write

		!byte <blob_02_write
		!byte <blob_1b_write
		!byte <blob_14_write
		!byte <blob_06_write
		!byte <blob_15_write
		!byte <blob_05_write
		!byte <blob_18_write
		!byte <blob_13_write

blob_wrt_high	!byte >blob_0e_write
		!byte >blob_1a_write
		!byte >blob_0c_write
		!byte >blob_1c_write
		!byte >blob_1d_write
		!byte >blob_16_write
		!byte >blob_00_write
		!byte >blob_17_write

		!byte >blob_0d_write
		!byte >blob_03_write
		!byte >blob_08_write
		!byte >blob_01_write
		!byte >blob_04_write
		!byte >blob_0a_write
		!byte >blob_0f_write
		!byte >blob_1f_write

		!byte >blob_0b_write
		!byte >blob_1e_write
		!byte >blob_10_write
		!byte >blob_11_write
		!byte >blob_07_write
		!byte >blob_19_write
		!byte >blob_09_write
		!byte >blob_12_write

		!byte >blob_02_write
		!byte >blob_1b_write
		!byte >blob_14_write
		!byte >blob_06_write
		!byte >blob_15_write
		!byte >blob_05_write
		!byte >blob_18_write
		!byte >blob_13_write

; Blob colour table
blob_pulse_cols	!byte $09,$06,$02,$0b,$08,$04,$0a,$0e
		!byte $0f,$03,$07,$0d,$01,$01,$07,$0d
		!byte $0f,$03,$0a,$0e,$08,$04,$02,$0b
		!byte $09,$06

; Blob colour table destinations
blob_dests	!byte $1a,$15,$17,$19,$16

; Cosine curve data for the effect - starts at the next page boundary
		* = ((*/$100)+1)*$100
block_cosinus	!byte $d0,$d0,$d0,$d0,$d0,$d0,$d0,$d0
		!byte $cf,$cf,$cf,$cf,$ce,$ce,$cd,$cd
		!byte $cc,$cc,$cb,$cb,$ca,$ca,$c9,$c8
		!byte $c7,$c7,$c6,$c5,$c4,$c3,$c3,$c2
		!byte $c1,$c0,$bf,$be,$bd,$bc,$bb,$ba
		!byte $b9,$b8,$b6,$b5,$b4,$b3,$b2,$b1
		!byte $af,$ae,$ad,$ac,$aa,$a9,$a8,$a7
		!byte $a5,$a4,$a3,$a1,$a0,$9f,$9e,$9c

		!byte $9b,$9a,$98,$97,$96,$94,$93,$92
		!byte $90,$8f,$8e,$8d,$8b,$8a,$89,$88
		!byte $86,$85,$84,$83,$82,$81,$7f,$7e
		!byte $7d,$7c,$7b,$7a,$79,$78,$77,$76
		!byte $75,$74,$73,$72,$72,$71,$70,$6f
		!byte $6e,$6e,$6d,$6c,$6c,$6b,$6b,$6a
		!byte $6a,$69,$69,$68,$68,$67,$67,$67
		!byte $66,$66,$66,$66,$66,$66,$66,$66

		!byte $66,$66,$66,$66,$66,$66,$66,$66
		!byte $67,$67,$67,$67,$68,$68,$69,$69
		!byte $6a,$6a,$6b,$6b,$6c,$6d,$6d,$6e
		!byte $6f,$6f,$70,$71,$72,$73,$74,$74
		!byte $75,$76,$77,$78,$79,$7a,$7b,$7c
		!byte $7d,$7f,$80,$81,$82,$83,$84,$86
		!byte $87,$88,$89,$8a,$8c,$8d,$8e,$90
		!byte $91,$92,$93,$95,$96,$97,$99,$9a

		!byte $9b,$9d,$9e,$9f,$a1,$a2,$a3,$a4
		!byte $a6,$a7,$a8,$aa,$ab,$ac,$ad,$af
		!byte $b0,$b1,$b2,$b3,$b4,$b6,$b7,$b8
		!byte $b9,$ba,$bb,$bc,$bd,$be,$bf,$c0
		!byte $c1,$c2,$c3,$c4,$c5,$c5,$c6,$c7
		!byte $c8,$c8,$c9,$ca,$ca,$cb,$cc,$cc
		!byte $cd,$cd,$cd,$ce,$ce,$cf,$cf,$cf
		!byte $d0,$d0,$d0,$d0,$d0,$d0,$d0,$d0

; FLI movement curve
		* = block_cosinus+$100
fli_cosinus	!byte $7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
		!byte $7e,$7e,$7e,$7d,$7d,$7c,$7c,$7b
		!byte $7b,$7a,$79,$79,$78,$77,$76,$76
		!byte $75,$74,$73,$72,$71,$70,$6f,$6e
		!byte $6d,$6c,$6a,$69,$68,$67,$66,$64
		!byte $63,$62,$60,$5f,$5e,$5c,$5b,$59
		!byte $58,$56,$55,$53,$52,$50,$4f,$4d
		!byte $4c,$4a,$49,$47,$46,$44,$43,$41

		!byte $3f,$3e,$3c,$3b,$39,$38,$36,$34
		!byte $33,$31,$30,$2e,$2d,$2b,$2a,$28
		!byte $27,$25,$24,$23,$21,$20,$1e,$1d
		!byte $1c,$1b,$19,$18,$17,$16,$14,$13
		!byte $12,$11,$10,$0f,$0e,$0d,$0c,$0b
		!byte $0a,$09,$09,$08,$07,$06,$06,$05
		!byte $04,$04,$03,$03,$02,$02,$01,$01
		!byte $01,$00,$00,$00,$00,$00,$00,$00

		!byte $00,$00,$00,$00,$00,$00,$00,$00
		!byte $01,$01,$01,$02,$02,$03,$03,$04
		!byte $04,$05,$06,$06,$07,$08,$09,$0a
		!byte $0a,$0b,$0c,$0d,$0e,$0f,$10,$11
		!byte $12,$14,$15,$16,$17,$18,$1a,$1b
		!byte $1c,$1e,$1f,$20,$22,$23,$24,$26
		!byte $27,$29,$2a,$2c,$2d,$2f,$30,$32
		!byte $33,$35,$36,$38,$3a,$3b,$3d,$3e

		!byte $40,$41,$43,$45,$46,$48,$49,$4b
		!byte $4c,$4e,$4f,$51,$52,$54,$55,$57
		!byte $58,$5a,$5b,$5d,$5e,$5f,$61,$62
		!byte $63,$65,$66,$67,$68,$6a,$6b,$6c
		!byte $6d,$6e,$6f,$70,$71,$72,$73,$74
		!byte $75,$76,$77,$77,$78,$79,$7a,$7a
		!byte $7b,$7b,$7c,$7c,$7d,$7d,$7e,$7e
		!byte $7e,$7f,$7f,$7f,$7f,$7f,$7f,$7f

; First FLI colour table
		* = block_cosinus+$200
fli_colours_1	!byte $09,$09,$02,$09,$02,$02,$08,$02
		!byte $08,$08,$0a,$08,$0a,$0a,$0f,$0a
		!byte $0f,$0f,$07,$0f,$07,$07,$01,$07
		!byte $01,$01,$07,$01,$07,$07,$0f,$07
		!byte $0f,$0f,$0a,$0f,$0a,$0a,$08,$0a
		!byte $08,$08,$02,$08,$02,$02,$09,$02

		!byte $09,$09,$02,$09,$02,$02,$08,$02
		!byte $08,$08,$0a,$08,$0a,$0a,$0f,$0a
		!byte $0f,$0f,$07,$0f,$07,$07,$01,$07
		!byte $01,$01,$07,$01,$07,$07,$0f,$07
		!byte $0f,$0f,$0a,$0f,$0a,$0a,$08,$0a
		!byte $08,$08,$02,$08,$02,$02,$09,$02

		!byte $09,$09,$02,$09,$02,$02,$08,$02
		!byte $08,$08,$0a,$08,$0a,$0a,$0f,$0a
		!byte $0f,$0f,$07,$0f,$07,$07,$01,$07
		!byte $01,$01,$07,$01,$07,$07,$0f,$07
		!byte $0f,$0f,$0a,$0f,$0a,$0a,$08,$0a
		!byte $08,$08,$02,$08,$02,$02,$09,$02

		!byte $09,$09,$02,$09,$02,$02,$08,$02
		!byte $08,$08,$0a,$08,$0a,$0a,$0f,$0a
		!byte $0f,$0f,$07,$0f,$07,$07,$01,$07
		!byte $01,$01,$07,$01,$07,$07,$0f,$07
		!byte $0f,$0f,$0a,$0f,$0a,$0a,$08,$0a
		!byte $08,$08,$02,$08,$02,$02,$09,$02

; Second FLI colour table
		* = block_cosinus+$300
fli_colours_2	!byte $06,$06,$0b,$06,$0b,$0b,$04,$0b
		!byte $04,$04,$0e,$04,$0e,$0e,$03,$0e
		!byte $03,$03,$0d,$03,$0d,$0d,$01,$0d
		!byte $01,$01,$0d,$01,$0d,$0d,$03,$0d
		!byte $03,$03,$0e,$03,$0e,$0e,$04,$0e
		!byte $04,$04,$0b,$04,$0b,$0b,$06,$0b

		!byte $06,$06,$0b,$06,$0b,$0b,$04,$0b
		!byte $04,$04,$0e,$04,$0e,$0e,$03,$0e
		!byte $03,$03,$0d,$03,$0d,$0d,$01,$0d
		!byte $01,$01,$0d,$01,$0d,$0d,$03,$0d
		!byte $03,$03,$0e,$03,$0e,$0e,$04,$0e
		!byte $04,$04,$0b,$04,$0b,$0b,$06,$0b

		!byte $06,$06,$0b,$06,$0b,$0b,$04,$0b
		!byte $04,$04,$0e,$04,$0e,$0e,$03,$0e
		!byte $03,$03,$0d,$03,$0d,$0d,$01,$0d
		!byte $01,$01,$0d,$01,$0d,$0d,$03,$0d
		!byte $03,$03,$0e,$03,$0e,$0e,$04,$0e
		!byte $04,$04,$0b,$04,$0b,$0b,$06,$0b

		!byte $06,$06,$0b,$06,$0b,$0b,$04,$0b
		!byte $04,$04,$0e,$04,$0e,$0e,$03,$0e
		!byte $03,$03,$0d,$03,$0d,$0d,$01,$0d
		!byte $01,$01,$0d,$01,$0d,$0d,$03,$0d
		!byte $03,$03,$0e,$03,$0e,$0e,$04,$0e
		!byte $04,$04,$0b,$04,$0b,$0b,$06,$0b

; "Random" data (it isn't really random) for the dissolve effect
random_data	!byte $ce,$65,$c9,$5f,$57,$93,$06,$ab
		!byte $fb,$b4,$77,$94,$bb,$1b,$82,$df
		!byte $54,$26,$29,$83,$8f,$21,$be,$42
		!byte $f7,$3f,$44,$72,$69,$00,$1e,$db
		!byte $6b,$40,$b9,$f5,$70,$22,$c4,$79
		!byte $51,$7b,$1d,$a4,$6a,$25,$f6,$ea
		!byte $43,$a2,$c7,$f4,$3a,$7a,$53,$48
		!byte $d9,$8e,$2d,$71,$e4,$17,$c3,$ac
		!byte $d8,$a9,$67,$d7,$62,$39,$a3,$d2
		!byte $b7,$20,$5b,$fd,$23,$49,$88,$4d
		!byte $85,$78,$63,$4f,$9d,$bc,$d0,$45
		!byte $6e,$1f,$ff,$e0,$cb,$81,$16,$a7
		!byte $8a,$e9,$04,$9b,$b0,$f1,$ad,$bf
		!byte $4b,$3b,$02,$32,$41,$de,$0b,$46
		!byte $c2,$09,$d1,$f0,$60,$2b,$ed,$18
		!byte $5e,$27,$37,$9e,$e5,$96,$58,$e1
		!byte $4c,$4a,$f2,$11,$cf,$a8,$0c,$0a
		!byte $14,$cc,$5d,$2a,$01,$87,$97,$33
		!byte $76,$90,$9c,$a5,$2e,$aa,$19,$31
		!byte $af,$e6,$34,$dd,$61,$ef,$c5,$50
		!byte $fa,$86,$2f,$98,$d4,$f3,$3e,$84
		!byte $64,$7c,$dc,$6f,$7d,$92,$13,$e8
		!byte $35,$ae,$d3,$73,$56,$b1,$7e,$8b
		!byte $c6,$12,$74,$bd,$10,$6d,$8d,$6c
		!byte $91,$ba,$28,$8c,$0d,$b5,$fe,$52
		!byte $75,$15,$7f,$e7,$a6,$c8,$f8,$36
		!byte $03,$55,$68,$e3,$d6,$07,$9f,$ee
		!byte $cd,$3c,$c0,$9a,$5c,$0e,$66,$f9
		!byte $38,$05,$99,$b3,$1a,$a0,$e2,$ca
		!byte $b2,$95,$1c,$da,$59,$08,$4e,$eb
		!byte $d5,$89,$80,$fc,$47,$2c,$b6,$a1
		!byte $b8,$30,$c1,$ec,$5a,$3d,$0f,$24

; Generate the FLI area's bitmap data
		* = $8000
bitmap_data

!set line_cnt=$00
!do {
		!byte $00,$00,$00,$00,$00,$00,$00,$00
		!byte $00,$00,$00,$00,$00,$00,$00,$00
		!byte $00,$00,$00,$00,$00,$00,$00,$00
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa

		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa

		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa

		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa

		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
		!byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa

		!set line_cnt=line_cnt+$01
} until line_cnt=$05

; Generate the FLI area's bitmap mask data
		* = $9000
bitmap_mask

!set line_cnt=$00
!do {
		!byte $00,$00,$00,$00,$00,$00,$00,$00
		!byte $00,$00,$00,$00,$00,$00,$00,$00
		!byte $00,$00,$00,$00,$00,$00,$00,$00
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		!byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

		!set line_cnt=line_cnt+$01
} until line_cnt=$05
