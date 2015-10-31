; Logo scanline $00
logo_splitter	ldy #$18
		sty $d016
		nop
		nop
		nop
		nop
		nop
		nop


		ldx #$00

; Logo scanline $01
		ldy #$19
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l01_4	lda #$0b
split_l01_0	ldy #$0b
		sty $d022
split_l01_1	ldy #$0b
		sty $d022
split_l01_2	ldy #$0b
		sty $d022
split_l01_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l01_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $02
		ldy #$1a
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l02_4	lda #$0b
split_l02_0	ldy #$0b
		sty $d022
split_l02_1	ldy #$0b
		sty $d022
split_l02_2	ldy #$0b
		sty $d022
split_l02_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l02_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $03
		ldy #$1b
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l03_4	lda #$0b
split_l03_0	ldy #$0b
		sty $d022
split_l03_1	ldy #$0b
		sty $d022
split_l03_2	ldy #$0b
		sty $d022
split_l03_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l03_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $04
		ldy #$1c
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l04_4	lda #$0b
split_l04_0	ldy #$0b
		sty $d022
split_l04_1	ldy #$0b
		sty $d022
split_l04_2	ldy #$0b
		sty $d022
split_l04_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l04_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $05
		ldy #$1d
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l05_4	lda #$0b
split_l05_0	ldy #$0b
		sty $d022
split_l05_1	ldy #$0b
		sty $d022
split_l05_2	ldy #$0b
		sty $d022
split_l05_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l05_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $06
		ldy #$1e
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l06_4	lda #$0b
split_l06_0	ldy #$0b
		sty $d022
split_l06_1	ldy #$0b
		sty $d022
split_l06_2	ldy #$0b
		sty $d022
split_l06_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l06_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $07
		ldy #$1f
		sty $d016
		ldy #logo_base_col
		sty $d022

		ldx #$09
		dex
		bne *-$01
		nop
		nop
		nop


; Logo scanline $08
		ldy #$18
		sty $d016
		nop
		nop
		nop
		nop
		nop
		nop
		ldx #$00

; Logo scanline $09
		ldy #$19
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l09_4	lda #$0b
split_l09_0	ldy #$0b
		sty $d022
split_l09_1	ldy #$0b
		sty $d022
split_l09_2	ldy #$0b
		sty $d022
split_l09_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l09_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $0a
		ldy #$1a
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l0a_4	lda #$0b
split_l0a_0	ldy #$0b
		sty $d022
split_l0a_1	ldy #$0b
		sty $d022
split_l0a_2	ldy #$0b
		sty $d022
split_l0a_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l0a_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $0b
		ldy #$1b
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l0b_4	lda #$0b
split_l0b_0	ldy #$0b
		sty $d022
split_l0b_1	ldy #$0b
		sty $d022
split_l0b_2	ldy #$0b
		sty $d022
split_l0b_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l0b_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $0c
		ldy #$1c
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l0c_4	lda #$0b
split_l0c_0	ldy #$0b
		sty $d022
split_l0c_1	ldy #$0b
		sty $d022
split_l0c_2	ldy #$0b
		sty $d022
split_l0c_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l0c_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $0d
		ldy #$1d
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l0d_4	lda #$0b
split_l0d_0	ldy #$0b
		sty $d022
split_l0d_1	ldy #$0b
		sty $d022
split_l0d_2	ldy #$0b
		sty $d022
split_l0d_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l0d_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $0e
		ldy #$1e
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l0e_4	lda #$0b
split_l0e_0	ldy #$0b
		sty $d022
split_l0e_1	ldy #$0b
		sty $d022
split_l0e_2	ldy #$0b
		sty $d022
split_l0e_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l0e_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $0f
		ldy #$1f
		sty $d016
		ldy #logo_base_col
		sty $d022

		ldx #$09
		dex
		bne *-$01
		nop
		nop
		nop


; Logo scanline $10
		ldy #$18
		sty $d016
		nop
		nop
		nop
		nop
		nop
		nop
		ldx #$00

; Logo scanline $11
		ldy #$19
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l11_4	lda #$0b
split_l11_0	ldy #$0b
		sty $d022
split_l11_1	ldy #$0b
		sty $d022
split_l11_2	ldy #$0b
		sty $d022
split_l11_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l11_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $12
		ldy #$1a
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l12_4	lda #$0b
split_l12_0	ldy #$0b
		sty $d022
split_l12_1	ldy #$0b
		sty $d022
split_l12_2	ldy #$0b
		sty $d022
split_l12_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l12_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $13
		ldy #$1b
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l13_4	lda #$0b
split_l13_0	ldy #$0b
		sty $d022
split_l13_1	ldy #$0b
		sty $d022
split_l13_2	ldy #$0b
		sty $d022
split_l13_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l13_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $14
		ldy #$1c
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l14_4	lda #$0b
split_l14_0	ldy #$0b
		sty $d022
split_l14_1	ldy #$0b
		sty $d022
split_l14_2	ldy #$0b
		sty $d022
split_l14_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l14_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $15
		ldy #$1d
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l15_4	lda #$0b
split_l15_0	ldy #$0b
		sty $d022
split_l15_1	ldy #$0b
		sty $d022
split_l15_2	ldy #$0b
		sty $d022
split_l15_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l15_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $16
		ldy #$1e
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l16_4	lda #$0b
split_l16_0	ldy #$0b
		sty $d022
split_l16_1	ldy #$0b
		sty $d022
split_l16_2	ldy #$0b
		sty $d022
split_l16_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l16_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $17
		ldy #$1f
		sty $d016
		ldy #logo_base_col
		sty $d022

		ldx #$09
		dex
		bne *-$01
		nop
		nop
		nop


; Logo scanline $18
		ldy #$18
		sty $d016
		nop
		nop
		nop
		nop
		nop
		nop
		ldx #$00

; Logo scanline $19
		ldy #$19
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l19_4	lda #$0b
split_l19_0	ldy #$0b
		sty $d022
split_l19_1	ldy #$0b
		sty $d022
split_l19_2	ldy #$0b
		sty $d022
split_l19_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l19_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $1a
		ldy #$1a
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l1a_4	lda #$0b
split_l1a_0	ldy #$0b
		sty $d022
split_l1a_1	ldy #$0b
		sty $d022
split_l1a_2	ldy #$0b
		sty $d022
split_l1a_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l1a_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $1b
		ldy #$1b
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l1b_4	lda #$0b
split_l1b_0	ldy #$0b
		sty $d022
split_l1b_1	ldy #$0b
		sty $d022
split_l1b_2	ldy #$0b
		sty $d022
split_l1b_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l1b_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $1c
		ldy #$1c
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l1c_4	lda #$0b
split_l1c_0	ldy #$0b
		sty $d022
split_l1c_1	ldy #$0b
		sty $d022
split_l1c_2	ldy #$0b
		sty $d022
split_l1c_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l1c_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $1d
		ldy #$1d
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l1d_4	lda #$0b
split_l1d_0	ldy #$0b
		sty $d022
split_l1d_1	ldy #$0b
		sty $d022
split_l1d_2	ldy #$0b
		sty $d022
split_l1d_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l1d_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $1e
		ldy #$1e
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l1e_4	lda #$0b
split_l1e_0	ldy #$0b
		sty $d022
split_l1e_1	ldy #$0b
		sty $d022
split_l1e_2	ldy #$0b
		sty $d022
split_l1e_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l1e_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $1f
		ldy #$1f
		sty $d016
		ldy #logo_base_col
		sty $d022

		ldx #$09
		dex
		bne *-$01
		nop
		nop
		nop


; Logo scanline $20
		ldy #$18
		sty $d016
		nop
		nop
		nop
		nop
		nop
		nop
		ldx #$00

; Logo scanline $21
		ldy #$19
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l21_4	lda #$0b
split_l21_0	ldy #$0b
		sty $d022
split_l21_1	ldy #$0b
		sty $d022
split_l21_2	ldy #$0b
		sty $d022
split_l21_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l21_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $22
		ldy #$1a
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l22_4	lda #$0b
split_l22_0	ldy #$0b
		sty $d022
split_l22_1	ldy #$0b
		sty $d022
split_l22_2	ldy #$0b
		sty $d022
split_l22_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l22_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $23
		ldy #$1b
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l23_4	lda #$0b
split_l23_0	ldy #$0b
		sty $d022
split_l23_1	ldy #$0b
		sty $d022
split_l23_2	ldy #$0b
		sty $d022
split_l23_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l23_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $24
		ldy #$1c
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l24_4	lda #$0b
split_l24_0	ldy #$0b
		sty $d022
split_l24_1	ldy #$0b
		sty $d022
split_l24_2	ldy #$0b
		sty $d022
split_l24_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l24_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $25
		ldy #$1d
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l25_4	lda #$0b
split_l25_0	ldy #$0b
		sty $d022
split_l25_1	ldy #$0b
		sty $d022
split_l25_2	ldy #$0b
		sty $d022
split_l25_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l25_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $26
		ldy #$1e
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l26_4	lda #$0b
split_l26_0	ldy #$0b
		sty $d022
split_l26_1	ldy #$0b
		sty $d022
split_l26_2	ldy #$0b
		sty $d022
split_l26_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l26_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $27
		ldy #$1f
		sty $d016
		ldy #logo_base_col
		sty $d022

		ldx #$09
		dex
		bne *-$01
		nop
		nop
		nop


; Logo scanline $28
		ldy #$18
		sty $d016
		nop
		nop
		nop
		nop
		nop
		nop
		ldx #$00

; Logo scanline $29
		ldy #$19
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l29_4	lda #$0b
split_l29_0	ldy #$0b
		sty $d022
split_l29_1	ldy #$0b
		sty $d022
split_l29_2	ldy #$0b
		sty $d022
split_l29_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l29_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $2a
		ldy #$1a
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l2a_4	lda #$0b
split_l2a_0	ldy #$0b
		sty $d022
split_l2a_1	ldy #$0b
		sty $d022
split_l2a_2	ldy #$0b
		sty $d022
split_l2a_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l2a_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $2b
		ldy #$1b
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l2b_4	lda #$0b
split_l2b_0	ldy #$0b
		sty $d022
split_l2b_1	ldy #$0b
		sty $d022
split_l2b_2	ldy #$0b
		sty $d022
split_l2b_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l2b_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $2c
		ldy #$1c
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l2c_4	lda #$0b
split_l2c_0	ldy #$0b
		sty $d022
split_l2c_1	ldy #$0b
		sty $d022
split_l2c_2	ldy #$0b
		sty $d022
split_l2c_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l2c_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $2d
		ldy #$1d
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l2d_4	lda #$0b
split_l2d_0	ldy #$0b
		sty $d022
split_l2d_1	ldy #$0b
		sty $d022
split_l2d_2	ldy #$0b
		sty $d022
split_l2d_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l2d_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $2e
		ldy #$1e
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l2e_4	lda #$0b
split_l2e_0	ldy #$0b
		sty $d022
split_l2e_1	ldy #$0b
		sty $d022
split_l2e_2	ldy #$0b
		sty $d022
split_l2e_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l2e_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $2f
		ldy #$1f
		sty $d016
		ldy #logo_base_col
		sty $d022

		ldx #$09
		dex
		bne *-$01
		nop
		nop
		nop


; Logo scanline $30
		ldy #$18
		sty $d016
		nop
		nop
		nop
		nop
		nop
		nop
		ldx #$00

; Logo scanline $31
		ldy #$19
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l31_4	lda #$0b
split_l31_0	ldy #$0b
		sty $d022
split_l31_1	ldy #$0b
		sty $d022
split_l31_2	ldy #$0b
		sty $d022
split_l31_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l31_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $32
		ldy #$1a
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l32_4	lda #$0b
split_l32_0	ldy #$0b
		sty $d022
split_l32_1	ldy #$0b
		sty $d022
split_l32_2	ldy #$0b
		sty $d022
split_l32_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l32_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $33
		ldy #$1b
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l33_4	lda #$0b
split_l33_0	ldy #$0b
		sty $d022
split_l33_1	ldy #$0b
		sty $d022
split_l33_2	ldy #$0b
		sty $d022
split_l33_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l33_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $34
		ldy #$1c
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l34_4	lda #$0b
split_l34_0	ldy #$0b
		sty $d022
split_l34_1	ldy #$0b
		sty $d022
split_l34_2	ldy #$0b
		sty $d022
split_l34_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l34_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $35
		ldy #$1d
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l35_4	lda #$0b
split_l35_0	ldy #$0b
		sty $d022
split_l35_1	ldy #$0b
		sty $d022
split_l35_2	ldy #$0b
		sty $d022
split_l35_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l35_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $36
		ldy #$1e
		sty $d016
		bit $ea
		nop
		nop
		nop

split_l36_4	lda #$0b
split_l36_0	ldy #$0b
		sty $d022
split_l36_1	ldy #$0b
		sty $d022
split_l36_2	ldy #$0b
		sty $d022
split_l36_3	ldy #$0b
		sty $d022
		sta $d022,x
split_l36_5	ldy #$0b
		sty $d022
		bit $ea
		nop
		nop
		nop
		nop

; Logo scanline $37
		ldy #$1f
		sty $d016
		ldy #logo_base_col
		sty $d022

		ldx #$09
		dex
		bne *-$01


		rts

; Colour splits for the scrollers
scroll_splitter	ldx #$06
		dex
		bne *-$01
		bit $ea
		ldx #$09
		lda #$06
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021

		ldx #$02
		dex
		bne *-$01
		nop
		nop
		ldx #$0b
		lda #$0b
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021

		ldx #$02
		dex
		bne *-$01
		nop
		nop
		ldx #$08
		lda #$04
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021

		ldx #$02
		dex
		bne *-$01
		nop
		nop
		ldx #$0c
		lda #$0e
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021

		ldx #$02
		dex
		bne *-$01
		nop
		nop
		ldx #$0a
		lda #$05
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021

		ldx #$02
		dex
		bne *-$01
		nop
		nop
		ldx #$0f
		lda #$03
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021

		ldx #$02
		dex
		bne *-$01
		nop
		nop
		ldx #$07
		lda #$0d
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021

		lda #$01
		sta $d021

		ldx #$05
		dex
		bne *-$01
		bit $ea
		ldx #$07
		lda #$0d
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021

		ldx #$02
		dex
		bne *-$01
		nop
		nop
		ldx #$0f
		lda #$03
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021

		ldx #$02
		dex
		bne *-$01
		nop
		nop
		ldx #$0a
		lda #$05
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021

		ldx #$02
		dex
		bne *-$01
		nop
		nop
		ldx #$0c
		lda #$0e
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021

		ldx #$02
		dex
		bne *-$01
		nop
		nop
		ldx #$08
		lda #$04
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021

		ldx #$02
		dex
		bne *-$01
		nop
		nop
		ldx #$02
		lda #$0b
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021

		ldx #$02
		dex
		bne *-$01
		nop
		nop
		ldx #$09
		lda #$06
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021
		sta $d021
		stx $d021

		lda #$0b
		sta $d021

		rts
