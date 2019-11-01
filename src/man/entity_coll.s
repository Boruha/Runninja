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
;;	MANAGER COLLISIONABLE ENTITTIES 
;;
.include "cmp/array_structure.h.s"
.include "man/entity.h.s"
.include "cpctelera.h.s"

.module entity_collisionable_manager

;;MANAGER MEMBER VARIABLES

;;--------------- Entity Components ----------------
DefinePointerArrayStructure _collision, max_entities

;===============================================================
;===============================================================
;;MANAGER PUBLIC FUNCTIONS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAN_ENTITY::GET_COLLISION_ARRAY
;;	GETS A POINTER TO THE ARRAY OF COLLISION ARRAY
;; INPUTS: -
;; DESTROYS: HL
;; RETURNS:
;;	HL: POINTER TO THE START OF THE ARRAY
;;
man_entity_collision_getArray::
	ld	hl, #_collision_array
	
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAN_ENTITY::INIT
;;	INITIALIZES THE ENTITY MANAGER. IT
;; 	SET UPS EVERYTHING WITH 0 ENTITIES AND
;;	READY TO START CREATING NEW ONES
;; INPUTS: -
;; DESTROYS: AF, HL
;;
man_entity_collision_init::
	ld 	hl, #_collision_array
	ld 	(_collision_pend), hl


	ret 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAN_ENTITY::pCOLLISION
;;	Save a pointer to collisionable entity into _collision_array
;; INPUT: 
;;	IX: POINTER TO ENTITY IN ENTITY_ARRAY 
;; DESTROYS: -
;;
man_entity_collision_addPointer::

	ld 	hl, (_collision_pend) 	; hl = pointer to first byte of _collision_array
	ld__a_ixl
	ld 	(hl), a 			; save 1st byte of pointer 
	inc 	hl
	ld__a_ixh 
	ld 	(hl), a   			; save 2nd byte of pointer
	inc 	hl 
	ld 	(_collision_pend), hl

	ret