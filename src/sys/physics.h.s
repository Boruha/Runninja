;;
;;	PHYSICS SYSTEM HEADER
;;
.globl sys_physics_init
.globl sys_physics_update
.globl sys_physics_set_composition
.globl sys_physics_reset_actualSet

;;========================================
;;Physics System Constants
screen_width_min	==  18	;;[18 - 55]
screen_width_max	==  55	;;[18 - 55]
screen_height_min ==  58 	;;[60 - 192]
screen_height_max	== 192	;;[60 - 192]

;;Estructure composition_X:
;;	- (x, y) shuriken_1
;;	- (x, y) shuriken_2 (not in lvl 1)
;; 	- (x, y) pts_1
;; 	- (x, y) pts_2
;; 	- (x, y) nullpointer
_composition_1:
;_composition_11:
	.db 	35, 100
	.db 	40,  60
	.db 	50, 140
;_composition_12:
	.db 	40,  95
	.db 	35,  70
	.db 	50, 130
;_composition_13:
	.db 	35,  60
	.db 	45, 100
	.db 	45, 140
;_composition_14:
	.db 	35, 160
	.db 	40, 100
	.db 	30,  70
	.db 	00,  00

_composition_2:
;_composition_21:
	.db 	35, 100
	.db 	30, 160
	.db 	40,  60
	.db 	50, 140
;_composition_22:
	.db 	40,  95
	.db 	40, 150
	.db 	35,  70
	.db 	50, 130
;_composition_23:
	.db 	35,  60
	.db 	30, 160
	.db 	45, 100
	.db 	45, 140
;_composition_24:
	.db 	35, 160
	.db 	50,  60
	.db 	40, 100
	.db 	30,  70
	.db 	00,  00
