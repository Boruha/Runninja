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
;;	COLLISION SYSTEM
;;		This manager will control all collisions
;; 
.include "cpctelera.h.s"
.include "man/entity.h.s"
.include "man/game.h.s"
.include "cmp/entity.h.s"
.include "sys/render.h.s"

.module sys_entity_collision

;;==================================================
;;	Collision manager private variables

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;SYS_COLLISION::INIT
;;INPUT: -
;;DESTROYS: -
;;
sys_collision_init::
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;SYS_COLLISION::COLOR_SCREEN
;;	Save a pointer and set screen color
;;INPUT:
;;	HL = Pointer to entity
;;DESTROYS: -
;;STACK USE: 2
;;
.macro colorScreen _color 
	push 	hl
	cpctm_setBorder_asm _color
	pop	hl
.endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;SYS_COLLISION::UPDATE
;;	Loop which go over the entity array and call collision checker
;;INPUT: HL
;; 	HL = Pointer to start of collision array 
;;DESTROYS: AF, HL, IX, IY 
;;STACK USE: 0 bytes
;;
sys_collision_update::			
	;colorScreen HW_GREEN
	ld 	 e, (hl)				
	inc 	hl 
	ld 	 d, (hl)
	;comprobation null
	ld 	 a, d 				
	or 	 e
	jr 	 z, _end
	;load in IX pointer to ent1 	
	ld__ixh_d
	ld__ixl_e

_loop_iy:
	inc 	hl
	ld 	 e, (hl)
	inc  	hl 
	ld 	 d, (hl)
	;comprobation null
	ld 	 a, d 
	or 	 e 					
	jr 	 z, _end
	;load in IY pointer to ent2 
	ld__iyh_d
	ld__iyl_e					

	call 	sys_collision_check
	jr 	_loop_iy

_end:
	;colorScreen HW_PINK
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;SYS_COLLISION::CHECK
;;	Get 2 pointers to entities and print a red line if collide 
;;INPUT: 
;;	IX = Pointer to ent1
;;	IY = Pointer to ent2
;;DESTROYS: AF 
;;STACK USE: 2 bytes
;;
sys_collision_check::

; X COMPROBATIONS
	;; calculating if (x1 + w1) - x2 <= 0
	ld 	 a, e_x(ix)  		;a = x1 
	add 	e_w(ix) 			;x1 + w1
	sub 	e_x(iy)			; - x2
	jr 	 z, no_collision
	jp 	 m, no_collision

	;: calculating if (x2 + w2) - x1 <= 0
	ld 	 a, e_x(iy)			;a = x2
	add 	e_w(iy)			;x1 + w2
	sub 	e_x(ix)			; - x1
	jr 	 z, no_collision
	jp 	 m, no_collision

;; Y COMPROBATIONS
	;; calculating if (y1 + h1) - y2 <= 0
	ld 	 a, e_y(ix)  		;a = y1 
	add 	e_h(ix)			;y1 + h1
	sub 	e_y(iy)			; - y2
	jr 	 z, no_collision
	jp 	 m, no_collision

	;; calculating if (y2 + h2) - y1 <= 0
	ld 	 a, e_y(iy)			;a = y2
	add 	e_h(iy)			;y2 + h2
	sub 	e_y(ix) 				; - y1
	jr 	 z, no_collision
	jp 	 m, no_collision

;; collision OK
	;;if pts_1 obj
	ld 	 a, e_type(iy)
	bit 	 1, a 	
	jr 	nz, iy_pts1			
	;;if enemy
	bit 	 3, a
	jr 	nz, iy_enemy 		
	;;nothing
	ret

iy_enemy:
	;; IX is the player
	ld 	a, e_damage(ix)
	bit 	0, a
	ret   nz 		 		;; already been hit
	inc 	e_damage(ix) 		;; if not yet, now we are being hit
	call 	clean_entity_touched
	call 	man_game_dec_score
	ret

iy_pts1:
	ld 	a, e_damage(iy)
	bit 	0, a
	ret 	nz
	call 	clean_entity_touched
	call 	man_game_inc_score
	ret 

no_collision:
	ret	

clean_entity_touched:

	inc 	e_damage(iy) 		
	push 	iy 
	pop  	ix 				;; we need iy pointer in ix
	call  sys_render_clean_entity 

	ret