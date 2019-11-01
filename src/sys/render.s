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
;;	ENTITY RENDER System
;;
.include "cpctelera.h.s"
.include "cpct_functions.h.s"
.include "cmp/entity.h.s"
.include "assets/assets.h.s"
.include "sys/render.h.s"
.include "bin/compressed/compresion.h.s"
.include "bin/compressed/compresionFondo.h.s"
.include "bin/compressed/compresionWin.h.s"
.include "man/game.h.s"
.include "sys/physics.h.s"
.include "sys/music.h.s"

.module sys_entity_render

;;=================================================
;;Square render system constants
screen_start  == 0xC000

_HL_temp: .dw 0x0000
_counter_temp: .db 0x00

;;=================================================
;;Render System Variables

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,
;;SYS_ENTITY_RENDER::INIT
;;	Inits the render system
;;DESTROYS: AF, BC, DE, HL
;;
sys_render_init::

	ld     c, #0       ; MODO 0
   	call  cpct_setVideoMode_asm
   	ld 	hl, #_palette_ninja
   	ld 	de, #16 
   	call 	cpct_setPalette_asm
   	cpctm_setBorder_asm HW_PINK

   	call 	sys_render_draw_startScreen

	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,
;;SYS_ENTITY_RENDER::DRAW_SS
;; 	draw startscreen
;;INPUTS: -
;;DESTROYS: HL, DE, BC
;;
sys_render_draw_startScreen:
	ld 	hl, #_compresion_end
	ld 	de, #decompress_buffer_end
	call  cpct_zx7b_decrunch_s_asm

	ld    hl, #0x40
	ld    de, #0xC000     	;; Destino
	ld    bc, #0x4000       ;; Tamano = 80x200 bytes (HEX)
	ldir 

	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,
;;SYS_ENTITY_RENDER::DRAW_BG
;; 	draw background before entities
;;INPUTS: -
;;DESTROYS: HL, DE, BC
;;
sys_render_draw_bg:: 
	ld 	hl, #_compresionFondo_end
	ld 	de, #decompress_buffer_end
	call  cpct_zx7b_decrunch_s_asm

	ld    hl, #0x40
	ld    de, #screen_start     	;; Destino
	ld    bc, #0x4000       	;; Tamano = 80x200 bytes (HEX)
	ldir 

	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,
;;SYS_ENTITY_RENDER::DRAW_WIN
;; 	draw win screen
;;INPUTS: -
;;DESTROYS: HL, DE, BC
;;
sys_render_draw_win:: 
	ld 	hl, #_compresionWin_end
	ld 	de, #decompress_buffer_end
	call  cpct_zx7b_decrunch_s_asm

	ld    hl, #0x40
	ld    de, #screen_start     	;; Destino
	ld    bc, #0x4000       	;; Tamano = 80x200 bytes (HEX)
	ldir 

	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,
;;SYS_ENTITY_RENDER::UPDATE
;;	Updates the render system
;;	Draws all entity components
;;	Assumes that entities are contiguous and all valids
;; 	Assumes there is at least entity to render
;;INPUT:
;; 	IX: Pointer to the entity array
;; 	 A: Number of elements in the array 
;;DESTROYS: AF, BC, DE, HL, IX
;;STACK USE: 4 bytes
;;
sys_render_update::
	
	call 	man_game_is_player_alive 	;; flag Z player is dead
	jr 	z, death

	call 	sys_render_render_entities
	ret

death:
	call 	sys_music_stop
	call 	sys_render_death_animation
	ret


sys_render_death_animation:
	;; IX input is the player at this point
	ld 	e, e_lastVP_l(ix)
	ld  	d, e_lastVP_h(ix)
	ld 	c, e_w(ix)
	ld 	b, e_h(ix)
	xor  	a
	call  cpct_drawSolidBox_asm

	ld 	a, #8
	ld 	(_counter_temp), a

	bit 	1, e_jp_state(ix)
	jr 	z, planti

plantd:

	ld 	hl, #_sp_plantd_0
	ld 	(_HL_temp), hl

loop_plantd:

	ld 	 c, #screen_width_max - 1
	call 	prepare_plant
	call 	draw_plant_manage_loop
	jr 	nz, loop_plantd
	jr 	wait_2_secs

planti:

	ld 	hl, #_sp_planti_0
	ld 	(_HL_temp), hl

loop_planti:

	ld 	 c, #screen_width_min + 2
	call 	prepare_plant
	call 	draw_plant_manage_loop
	jr 	nz, loop_planti

wait_2_secs:

	ld 	a, #4
	ld 	(_counter_temp), a

loop_wait_2_secs:

	call 	man_game_wait_half_sec
	ld 	a, (_counter_temp)
	dec 	a
	ld 	(_counter_temp), a
	jr 	nz, loop_wait_2_secs
	
	call  man_game_reset
	
	ret

prepare_plant:
	
	ld 	de, #screen_start
	ld 	 b, #200 - #plant_height
	call 	cpct_getScreenPtr_asm

	ex 	de, hl
	ld 	 c, #plant_width
	ld 	 b, #plant_height

	ret

draw_plant_manage_loop:

	ld 	hl, (_HL_temp)
	call 	cpct_drawSprite_asm
	
	call 	man_game_wait_half_sec

	ld 	hl, (_HL_temp)
	ld 	de, #plant_size
	add 	hl, de
	ld 	(_HL_temp), hl
	
	ld 	a, (_counter_temp)
	dec 	a
	ld 	(_counter_temp), a

	ret

;;SYS_ENTITY_RENDER::UPDATE
;;	Updates the render system
;;	Draws all entity components
;;	Assumes that entities are contiguous and all valids
;; 	Assumes there is at least entity to render
;;INPUT:
;; 	IX: Pointer to the entity array
;; 	 A: Number of elements in the array 
;;DESTROYS: AF, BC, DE, HL, IX
;;STACK USE: 2 bytes
;;
sys_render_render_entities::
	ld 	(_ent_counter), a

_update_loop:
	;;Erase previous instance (Draw background pixels)	

	ld 	 e, e_lastVP_l(ix)
	ld 	 d, e_lastVP_h(ix)
	ld 	 c, e_w(ix)
	ld 	 b, e_h(ix)
	push 	bc

	ld 	 a, e_type(ix)
	cp 	 #0
	jr 	nz, no_player

	xor 	 a
	call 	cpct_drawSolidBox_asm 	;; we only clean the ninja

	call 	animacion_ninja
	jr 	load_sprite

no_player:

	bit 	 0, e_damage(ix)
	jr  	nz, no_draw

	ld 	 a, e_type(ix)
	cp 	#e_shuriken
	jr    nz, draw

	ld 	l, e_pspr_l(ix)
	ld 	h, e_pspr_h(ix)

	call 	animacion_shuriken

load_sprite:

	ld 	e_pspr_l(ix), l
	ld 	e_pspr_h(ix), h

draw:

	;;Calculate new memory video pointer	
	ld 	de, #screen_start
	ld 	 c, e_x(ix)
	ld 	 b, e_y(ix)
	call 	cpct_getScreenPtr_asm

	;;Store video memory pointer as last 
	ld 	e_lastVP_l(ix), l 
	ld 	e_lastVP_h(ix), h 

	;;Draw entity sprite
	ex 	de, hl
	ld 	 l, e_pspr_l(ix)
	ld 	 h, e_pspr_h(ix)
	pop 	bc
	call 	cpct_drawSprite_asm

no_draw:


_ent_counter = .+1			;;pointer to position of A + 1
	ld 	 a, #0
	dec 	 a
	ret 	 z

	ld 	(_ent_counter), a
	ld 	bc, #sizeof_e
	add 	ix, bc 
	jp 	_update_loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Animation of the ninja  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Returns in HL sprite_ptr ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

animacion_ninja:

	bit 	0, e_jp_state(ix)
	jr 	z, anim_waiting

anim_jumping:

	bit 	1, e_jp_state(ix)
	jr 	z, anim_jp_right

anim_jp_left:

	bit  	0, e_damage(ix)
	jr 	z, no_damage_left

damage_left:

	ld 	hl, #_sp_ninja_5
	ret

no_damage_left:
	ld 	hl, #_sp_ninja_4
	ret

anim_jp_right:

	bit  	0, e_damage(ix)
	jr 	z, no_damage_right

damage_right:

	ld 	hl, #_sp_ninja_3
	ret

no_damage_right:
	
	ld 	hl, #_sp_ninja_2
	ret

anim_waiting:

	bit 	1, e_jp_state(ix)
	jr 	z, anim_wait_right

	ld 	hl, #_sp_ninja_1
	ret

anim_wait_right:

	ld 	hl, #_sp_ninja_0
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Animation of the shuriken ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

animacion_shuriken:

	ld 	a, e_jp_counter(ix)
	cp 	#9
	jr 	z, animating

	inc 	e_jp_state(ix)
	inc 	e_jp_counter(ix)

	ret

animating:

	ld 	e_jp_counter(ix), #0

	;; 	shuriken
	ld 	a, e_jp_state(ix) 	;; jp_state shuriken contains animation sprite

	bit 	0, a
	jr 	z, shuriken_0_2

shuriken_1_3: 			

	bit 	1, a
	jr 	z, shuriken_1

	ld 	hl, #_sp_shuriken_3	
	ret

shuriken_1:

	ld 	hl, #_sp_shuriken_1
	ret

shuriken_0_2:

	bit 	1, a
	jr 	z, shuriken_0

	ld 	hl, #_sp_shuriken_2
	ret

shuriken_0:

	ld 	hl, #_sp_shuriken_0
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Render clean screen ;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Clears memory video copying 0 ;;; 
;; in every position using ldir  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; it 0 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; HL -> C000 = 0x00 ;;;;;;;;;;;;;;;
;; DE -> C001 = XxXX ;;;;;;;;;;;;;;;
;; BC -> 3FFF = 0x4000 - 1 ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; it 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; HL -> C001 = 0x00 ;;;;;;;;;;;;;;;
;; DE -> C002 = XxXX ;;;;;;;;;;;;;;;
;; BC -> 3FFE ;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; until the whole memory is 0x00 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sys_render_clean_screen::

	ld 	hl, #screen_start 	;; 0xC000
	ld 	de, #screen_start + 1	;; 0xC001
	ld 	bc, #0x4000 - 1		;; 0x3FFF -> 0xC001 to 0xFFFF
	ld 	(hl), #0
	
	ldir

	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,
;;SYS_ENTITY_RENDER::CLEAN_ENTITY 
;;	Clean entity' sprite 
;;	Assumes that entities are contiguous and all valids
;; 	Assumes there is at least entity to render
;;INPUT:
;; 	IX: Pointer to the entity 
;;DESTROYS: AF, BC, DE, HL
;;STACK USE: 0 bytes
;;
sys_render_clean_entity::

	ld 	de, #screen_start
	ld 	 c, e_x(ix)
	ld 	 b, e_y(ix)
	call 	cpct_getScreenPtr_asm

	ex 	de, hl 
	ld 	 c, e_w(ix)
	ld 	 b, e_h(ix)
	xor 	 a
	call 	cpct_drawSolidBox_asm

	ret