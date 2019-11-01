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
;;	SYSTEM PHYSICS 
;;
.include "cpctelera.h.s"
.include "man/entity.h.s"
.include "cmp/entity.h.s"
.include "cpct_functions.h.s"
.include "sys/render.h.s"
.include "man/game.h.s"
.include "sys/physics.h.s"

.module sys_entity_physics

;;;;;;;;;;;;;;;;;;;;;;;;;
;;Physic system variables
;;
_actual_set: 		.dw 0x0000
_actual_composition: 	.dw 0x0000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	Inits the render System
;;
sys_physics_init::
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;SYS_PHYSICS::UPDATE
;;	Updates all Physics components of player
;;	Assumes that entities are continious and all valids
;;	Assumes there is at least one entity in the array
;;INPUT:
;;	IX = Pointer to the entity array
;;	 A = Number of elemts in the array
;;DESTROYS: AF, BC, DE, IX
;;STACK USE: 4 bytes
;;
sys_physics_update::

	ld 	d, a
	push 	de 
	;; last bottom memory video pointer
	ld 	de, #screen_start
	pop 	de
	
	ld 	 c, e_x(ix)
	ld 	 a, e_y(ix)
	add 	 e_h(ix)
	sub 	 #v_jump_abs
	
	ld 	 b, a
	
	call   cpct_getScreenPtr_asm

	ld 	e_bottom_border_lastVP_l(ix), l
	ld 	e_bottom_border_lastVP_h(ix), h

	;;update X
	;;c = pos_X + VX
	ld	 a, e_x(ix)
	add 	e_vx(ix)	
	ld 	 c, a
	;;a = x_max
	ld 	 a, #screen_width_max + 1	
	;sub 	e_w(ix)								
	;;check if limit right
	sub 	 c 
	jr 	 z, invalid_x
	;;b = x_min
	;;a = pos_X + VX
	ld 	 a, #screen_width_min + 1
	;sub 	e_w(ix)
	ld 	 b, a
	ld 	 a, c
	;;check if limit left
	sub 	 b
	jr 	 z, invalid_x	
	
valid_x:
 	ld 	e_x(ix), c
 	jr 	endif_x

invalid_x:
	inc 	e_jp_state(ix)		;; jump state will now be xxxxxx00 or xxxxxx10
	bit 	0, e_damage(ix)
	jr 	z, no_inc_dmg
	inc 	e_damage(ix)
	;;clean other entities
no_inc_dmg:
	push 	ix
	call 	sys_physics_update_np_entities 
	pop 	ix 

endif_x:
	ld	 a, e_y(ix)
	add 	e_vy(ix)
	ld 	 c, a		
	;;a = y_max
	ld 	 a, #screen_height_max + 1	
	sub 	e_h(ix)							
	;;check if limit down
	sub 	 c 
	jr 	 z, down_invalid_y
	;;b = y_min
	;;a = pos_Y + VY
	ld 	 a, #screen_height_min + 1
	;sub 	e_h(ix)
	ld 	 b, a
	ld 	 a, c
	;;check if limit top
	sub 	 b
	jp 	 m, endif_y

valid_y:
 	ld 	e_y(ix), c
 	jr 	endif_y

down_invalid_y:
	;; if we fall, we will stop and animate our death
	ld    e_vy(ix), #0
	call 	man_game_player_dead
	jr 	endif_y

endif_y:
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;SYS_PHYSICS::UPDATE_NP_ENTITIES
;;	Updates all Physics components of np entities
;;	Assumes that entities are continious and all valids
;;	Assumes there is at least one entity in the array
;;INPUT:
;;	IX = Pointer to the entity array
;;	 D = Number of elemts in the array
;;DESTROYS: AF, BC, DE, HL, IX
;;STACK USE: 2 bytes
;;
sys_physics_update_np_entities::
	;;save in _ent_counter a value
	ld 	 a, d
	;;dec 1 bcs we dont count player who is the 1st ent
	dec 	 a
	ld 	(_ent_counter), a
	;;start loop from 2nd entity (player is 1st)
	ld 	bc, #sizeof_e
	add 	ix, bc
	;;(v0.2)set on hl composition pointer
	ld 	hl, #_actual_set
	ld 	 e, (hl)
	inc 	hl
	ld 	 d, (hl)
	ex 	de, hl

_update_np_loop:
	;;DESTROYS: AF, BC, DE, HL
	push 	hl
	call 	sys_render_clean_entity
	pop 	hl

_composition_loop:
	;;e = new X and d = new Y
	ld 	 e, (hl)				
	inc 	hl 
	ld 	 d, (hl)
	inc 	hl
	;comprobation null
	ld 	 a, d 
	or  	 e
	jr 	 z, _composition_reset
	;;update position and _actual_set
	ld 	e_x(ix), e
	ld 	e_y(ix), d
	ld 	(_actual_set), hl
	ld 	e_damage(ix), #0
	;;pointer to position of A + 1
	_ent_counter = .+1			
	ld 	 a, #0
	dec 	 a
	ret 	 z

	ld 	(_ent_counter), a
	ld 	bc, #sizeof_e
	add 	ix, bc 
	jp 	_update_np_loop

;;end of 4th composition
_composition_reset:
	;;change the composition to 1st and go back to loop
	ld 	hl, #_actual_composition
	ld 	 e, (hl)
	inc 	hl
	ld 	 d, (hl)
	ex 	de, hl
	ld 	(_actual_set), hl
	jp 	_composition_loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;SYS_PHYSICS::SET_COMPOSITION
;;	Updates all Physics components of np entities
;;	Assumes that entities are continious and all valids
;;	Assumes there is at least one entity in the array
;;INPUT:
;;	 A = Pointer to the entity array
;;DESTROYS: HL 
;;STACK USE: 0 bytes
;;
sys_physics_set_composition::
	cp    #1
   	jr    nz, compo_2

;compo_1:
   	;;load in hl ptr to comp_1
   	ld 	hl, #_composition_1 
	ld 	(_actual_composition), hl
	ld 	(_actual_set), hl
	ret

compo_2:
	ld 	hl, #_composition_2
	ld 	(_actual_composition), hl
	ld 	(_actual_set), hl
	ret 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;SYS_PHYSICS::RESET_ACTUAL_SET
;;	Set 1st position of _actual_composition
;;	Assumes that entities are continious and all valids
;;	Assumes there is at least one entity in the array
;;INPUT: -
;;DESTROYS: HL, DE 
;;STACK USE: 0 bytes
;;
sys_physics_reset_actualSet::
	ld 	hl, #_actual_composition
	ld 	 e, (hl)
	inc 	hl
	ld 	 d, (hl)
	ex 	de, hl 
	ld 	(_actual_set), hl
	
	ret
