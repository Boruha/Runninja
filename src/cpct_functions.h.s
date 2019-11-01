;;
;;	FUNCIONS CPCT
;;
.globl cpct_disableFirmware_asm
.globl cpct_waitVSYNC_asm
.globl cpct_setVideoMode_asm
.globl cpct_setPalette_asm
.globl cpct_scanKeyboard_f_asm
.globl cpct_isKeyPressed_asm

;;(2B DE) songdata	Pointer to the start of the array containing song’s data in AKS binary format
.globl cpct_akp_musicInit_asm
.globl cpct_akp_musicPlay_asm
.globl cpct_akp_stop_asm

;;	INPUTS
;;(2B HL) sprite	Source Sprite Pointer (array with pixel data)
;;(2B DE) memory	Destination video memory pointer
;;(1B C ) width	Sprite Width in bytes [1-63] (Beware, not in pixels!)
;;(1B B ) height	Sprite Height in bytes (>0)
.globl cpct_drawSprite_asm

;;	INPUTS
;;(2B DE) memory	Video memory pointer to the upper left box corner byte
;;(1B A ) colour_pattern	1-byte colour pattern (in screen pixel format) to fill the box with
;;(1B C ) width	Box width in bytes [1-64] (Beware!  not in pixels!)
;;(1B B ) height	Box height in bytes (>0)
.globl cpct_drawSolidBox_asm

;;	INPUTS
;;(2B DE) screen_start	Pointer to the start of the screen (or a backbuffer)
;;(1B C ) x	[0-79] Byte-aligned column starting from 0 (x coordinate,
;;(1B B ) y	[0-199] row starting from 0 (y coordinate) in bytes)
;;	RETURNS
;;(2B HL) screenPtr 
.globl cpct_getScreenPtr_asm

;; 	INPUTS
;;(2B DE) dest_end	Ending (latest) byte of the destination (decompressed) array
;;(2B HL) source_end	Ending (latest) byte of the source (compressed) array
.globl cpct_zx7b_decrunch_s_asm