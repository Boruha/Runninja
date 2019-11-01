;;-----------------------------LICENSE NOTICE------------------------------------
;;	This program is free software under the terms of the GNU Lesser General Public License as published by
;;  	the Free Software Foundation.
;;
;;  	See the GNU Lesser General Public License for more details.
;;  	<http://www.gnu.org/licenses/>.
;;
;;	Devs: Borja Pozo, Carlos Romero and Mateo Linas 
;;------------------------------------------------------------------------------_
;;
;;	MUSIC SYSTEM
;;
.include "cpct_functions.h.s"
.include "assets/assets.h.s"

.module music_system

is_stop: 	.db 00 	;; bit 0 == 0 not stopped, bit 0 == 1 stopped

sys_music_init::
	call 	cpct_akp_musicInit_asm
	ld 	hl, #is_stop
	ld 	(hl), #0
	ret

sys_music_update::
	call 	cpct_waitVSYNC_asm

	ld 	hl, #is_stop
	bit 	0, (hl)
	ret 	nz
	
	call 	cpct_akp_musicPlay_asm
	ret

sys_music_stop::
	call 	cpct_akp_stop_asm
	ld 	hl, #is_stop
	inc 	(hl)
	ret