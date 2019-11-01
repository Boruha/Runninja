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
;; ENTITY MANAGER
;;
.include "cmp/array_structure.h.s"
.include "man/entity.h.s"
.include "cmp/entity.h.s"
.include "man/entity_coll.h.s"
.include "cpctelera.h.s"

.module entity_manager

;;MANAGER MEMBER VARIABLES

;;--------------- Entity Components ----------------
DefineComponentArrayStructure _entity, max_entities, DefineCmp_Entity_default

;===============================================================
;===============================================================
;;MANAGER PUBLIC FUNCTIONS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAN_ENTITY::GET_ARRAY
;;	GETS A POINTER TO THE ARRAY OF ENTITIES
;; 	IN IX AND ALSO THE NUMBER OF ENTITIES IN A
;; INPUTS: -
;; DESTROYS: A, IX
;; RETURNS:
;;	 A: NUMBER OS ENTITIES IN THE ARRAY
;;	IX: POINTER TO THE START OF THE ARRAY
;;
man_entity_getArray::
	ld	ix, #_entity_array
	ld	 a, (_entity_num)

	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAN_ENTITY::INIT
;;	INITIALIZES THE ENTITY MANAGER. IT
;; 	SET UPS EVERYTHING WITH 0 ENTITIES AND
;;	READY TO START CREATING NEW ONES
;; INPUTS: -
;; DESTROYS: AF, HL
;;
man_entity_init::
	;;set to 0
	xor	 a
	ld 	(_entity_num), a 		
	;;_pend = _array (start)
	ld 	hl, #_entity_array
	ld	(_entity_pend), hl 	 
	;;cleans collisionable array
	call 	man_entity_collision_init

	ret 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAN_ENTITY::NEW
;;	ADDS A NEW ENTITY COMPONENT TO THE ARRAY
;; 	WITHOUT INITIALIZING IT. IT DOES NOT
;;	PERFORM ANY CHECK FOR SPACE IN THE ARRAY
;; DESTROYS: F, BC, DE, HL
;; RETURNS:
;;	DE: POINTS TO ADDED ELEMT
;;	BC: SIZEOF (ENTITY_T)
;;
man_entity_new::
	;;increment number of created entities
	ld 	hl, #_entity_num
	inc 	(hl)
	;;increment pointer to point to the next
	;;free elemt in the array
	ld 	hl, (_entity_pend)
	ld 	 d, h 
	ld 	 e, l
	ld 	bc, #sizeof_e
	add 	hl, bc
	ld 	(_entity_pend), hl 

	ret 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAN_ENTITY::CREATE
;;	CREATE AND INITIALIZES NEW ENTITY
;; INPUT: 
;;	HL: POINTER TO VALUES FOR THE ENTITY 
;; DESTROYS: F, BC, DE, HL
;; RETURNS:
;;	IX: POINTER TO THE COMPONENT CREATED
;;
man_entity_create::
	;;save pointer to entity
	push 	hl
	call 	man_entity_new
	;;IX = DE 
	;;(IX returns the value of the pointer to the entity created)
	ld__ixh_d
	ld__ixl_e
	;;copy initialization values to new entity
	;;DE points to the new added entity
	;;BC holds sizeof(entity_t)
	;;copy initialization values
	pop 	hl
	;;copy from HL to DE (BC in byte size)
	ldir 	 	
	;;loads a pointer into collisionable array
	call 	man_entity_addPointer

	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAN_ENTITY::ADD_POINTER
;;	CALL MANAGER TO SAVE POINTERS
;; INPUT: 
;;	IX: POINTER TO VALUES FOR THE ENTITY 
;; DESTROYS: -
;;
man_entity_addPointer::
	
	call 	man_entity_collision_addPointer

	ret