;;-----------------------------LICENSE NOTICE------------------------------------
;;	This program is free software under the terms of the GNU Lesser General Public License as published by
;;  	the Free Software Foundation.
;;
;;  	See the GNU Lesser General Public License for more details.
;;  	<http://www.gnu.org/licenses/>.
;;
;;	Devs: Borja Pozo, Carlos Romero and Mateo Linas 
;;-------------------------------------------------------------------------------
;;
;;	SYSTEM INPUT
;;
.include "cpctelera.h.s"
.include "man/entity.h.s"
.include "cmp/entity.h.s"
.include "man/game.h.s"
.include "cpct_functions.h.s"
.include "assets/assets.h.s"
.include "sys/music.h.s"

.module input_system

sys_input_init::
	ret

sys_input_start_screen::

	;; Scan keyboard
	call 	cpct_scanKeyboard_f_asm
	;; HL -> Key
	ld 	hl, #Key_Space
	;; Key in HL pressed?
	call 	cpct_isKeyPressed_asm
	ret 	nz

      ;; Scan keyboard
	call 	cpct_scanKeyboard_f_asm
	;; HL -> Key
	ld 	hl, #Joy0_Fire1
	;; Key in HL pressed?
	call 	cpct_isKeyPressed_asm
	ret 	nz
	
	;; Scan keyboard
	call 	cpct_scanKeyboard_f_asm
	;; HL -> Key
	ld 	hl, #Joy1_Fire1
	;; Key in HL pressed?
	call 	cpct_isKeyPressed_asm
	ret 	nz

	call 	sys_music_update

	jr 	sys_input_start_screen

;; INPUT - IX -> pointer to the first entity (player)
sys_input_update::

	;; if e_jp_state bit(0) == 1, player is jumping, so we will ignore the keyboard
	ld 	 a, e_jp_state(ix)
	bit 	 0, a
	jr 	 z, check_keyboard	;; e_jp_state == xxxxxxx0 -> not moving
						;; e_jp_state == xxxxxxx1 -> moving

	bit 	 1, a			
	jr 	 z, moving_right		;; e_jp_state == xxxxxx0x -> moving right
						;; e_jp_state == xxxxxx1x -> moving left

moving_left:
	;; at this point, we set v_x to the left
	ld  	e_vx(ix), #-v_x
	;; and we update v_y
	jr 	v_jump_update

moving_right:
	;; at this point we set v_x to the right
	ld 	e_vx(ix), #v_x

v_jump_update:

	ld  	 a, e_jp_counter(ix)		;; jp counter now in a
	inc 	 a 					;; inc counter
	cp  	#jp_counter_max			;; if a != jp_counter_max
	ld  	e_jp_counter(ix), a
	ret 	nz					;; we don't do anything
							;; if a == jp_counter_max
	inc 	e_vy(ix)				;; once jump starts, we inc v_y -> gravity
	ld 	e_jp_counter(ix), #0		;; update counter to 0 again

	ret

check_keyboard:
	;; if we are stuck to the wall, v_y will always be 1 as we are supposed to be falling
	ld 	e_vy(ix), #v_y
	;; at this point we are supposed to be waiting for space to be pressed
	ld 	e_vx(ix), #0		;; so v_x = 0 for the moment
	
	;; Scan keyboard
	call 	cpct_scanKeyboard_f_asm
	;; HL -> Key
	ld 	hl, #Key_Space
	;; Key in HL pressed?
	call 	cpct_isKeyPressed_asm
	jr 	nz, pressed

	;; Scan keyboard
	call 	cpct_scanKeyboard_f_asm
	;; HL -> Key
	ld 	hl, #Joy0_Fire1
	;; Key in HL pressed?
	call 	cpct_isKeyPressed_asm
	jr 	nz, pressed
	
	;; Scan keyboard
	call 	cpct_scanKeyboard_f_asm
	;; HL -> Key
	ld 	hl, #Joy1_Fire1
	;; Key in HL pressed?
	call 	cpct_isKeyPressed_asm
	jr 	nz, pressed

	;; if nothing is pressed, we return
	ret

pressed:

	inc 	e_jp_state(ix)		;; xxxxxx00 -> xxxxxx01 // xxxxx10 -> xxxxxx11

	ld  	e_vy(ix), #v_jump - 1	;; that means v_y must be v_jump (-1 because we will inc v_y
						;; in the next iteration)
	ret
