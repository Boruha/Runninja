;;-----------------------------LICENSE NOTICE------------------------------------
;;	This program is free software under the terms of the GNU Lesser General Public License as published by
;;  the Free Software Foundation.
;;
;;  See the GNU Lesser General Public License for more details.
;;  <http://www.gnu.org/licenses/>.
;;
;;	Devs: Borja Pozo, Carlos Romero and Mateo Linas 
;;-------------------------------------------------------------------------------
;;
;;	ENTITY COMPONENT
;;		2B Position			(x, y)
;;		2B Velocity			(vx, vy)
;;		2B Size			(sx, sy)
;;		1B Entity type 		(type)
;;		2B Sprite Pointer		(pspr)
;;		2B Last video Pointer	(lastVP)
;;		

;;
;;	Define a new entity_t component 
;;	all entity_t data together to simplify access
;;
.macro DefineCmp_Entity _x, _y, _vx, _vy, _w, _h, _type, _pspr
	.db	_x, _y			;; Position
	.db	_vx, _vy			;; Velocity
	.db	_w, _h			;; Size
	.db 	_type				;; Type
	.dw	_pspr				;; Pointer to sprite
	.dw	0x0000			;; Last video memory pointer value
						;; Default to 0x0000 value
	.db   00				;; if _type == ninja
						;; xxxxxx00 -> preparing to jump right
						;; xxxxxx01 -> jumping right
						;; xxxxxx10 -> preparing to jump left
						;; xxxxxx11 -> jumping left
						;; if _type == shuriken
						;; xxxxxx00 -> shuriken_0
						;; xxxxxx01 -> shuriken_1
						;; xxxxxx10 -> shuriken_2
						;; xxxxxx11 -> shuriken_3
	.db 	00				;; if _type == ninja
						;; Jump counter
						;; if _type == shuriken
						;; Animation counter control
	.dw 	0x0000 			;; Last bottom border video memory pointer value
	.db 	00 				;; 0 -> not being hit, 1 -> being hit
.endm

;;entity_t offsets 
e_x 		 			= 0
e_y 		 			= 1
e_vx 		 			= 2
e_vy 		 			= 3
e_w 		 			= 4
e_h 		 			= 5
e_type 	 			= 6
e_pspr_l 	 			= 7
e_pspr_h 	 			= 8
e_lastVP_l 	 			= 9
e_lastVP_h 	 			= 10
e_jp_state 	 			= 11
e_jp_counter 			= 12
e_bottom_border_lastVP_l 	= 13
e_bottom_border_lastVP_h 	= 14
e_damage 				= 15
sizeof_e 	 			= 16	; 16 bytes per entity component


;;	ENTITY TYPE DEFINITIONS
e_unknown 	= 0x00	;;0b 0000 0000 		
e_pts_1 	= 0x02	;;0b 0000 0010	
e_pts_2 	= 0x04	;;0b 0000 0100	 	
e_shuriken  = 0x08	;;0b 0000 1000	

;; Default constructor for entity components
.macro DefineCmp_Entity_default
	DefineCmp_Entity 0, 0, 0, 0, 1, 1, e_unknown, 0x0000
.endm


;;
;;	CONST. PLAYER
;;

v_x == 1
v_y == 1

v_jump == -2
jp_counter_max == 8

v_jump_abs == -v_jump + 1