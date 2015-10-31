;
; MD201509 :: FINAL LINKER
;

; This just loads the compressed file and removes $d030 writes and a CLI from
; the PuCrunch decruncher. This doesn't NEED to be done, but it makes the final
; release a little prettier, at least to my mind.

; This source code is formatted for the ACME cross assembler from
; http://sourceforge.net/projects/acme-crossass/
; Compression is handled with PuCrunch which can be downloaded at
; http://csdb.dk/release/?id=6089

; This overwrites existing code to patch it so generates "segment
; starts" errors when assembled!


; Select an output filename
		!to "md201509_link.prg",cbm


; Yank in binary data
		* = $0801
		!binary "md201509_intro_pu.prg",,2


; Cheap and cheerful patches to the crunched binary
; Remove $D030 writes
		* = $080e
		nop
		nop
		nop

		* = $092c
		nop
		nop
		nop

; Remove CLI
		* = $0937
		nop
