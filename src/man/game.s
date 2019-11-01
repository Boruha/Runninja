;;-----------------------------LICENSE NOTICE------------------------------------
;; This program is free software under the terms of the GNU Lesser General Public License as published by
;;  the Free Software Foundation.
;;
;;  See the GNU Lesser General Public License for more details.
;;  <http://www.gnu.org/licenses/>.
;;
;; Devs: Borja Pozo, Carlos Romero and Mateo Linas 
;;-------------------------------------------------------------------------------
;;
;; MANAGER GAME
;;
.include "cpctelera.h.s"
.include "cpct_functions.h.s"

.include "sys/input.h.s"
.include "sys/physics.h.s"
.include "sys/collision.h.s"
.include "sys/music.h.s"
.include "sys/render.h.s"

.include "cmp/entity.h.s"

.include "man/entity.h.s"
.include "man/entity_coll.h.s"

.include "assets/assets.h.s"


.module game_manager

.area _DATA

;;    MANAGER MEMBER VARIABLES

;;LOCAL GAME
_lvl_score:    .db 00
_game_lvl:     .db 00
_player_alive: .db 01      ;; bit 0 == 0, player is dead

;;ENTITIES                
;;RANGE_POS: X:[20-55] / Y:[55-200]
;;                          X,    Y, VX, VY,  W,  H,       type, SPRITE POINTER
ninja:      DefineCmp_Entity 20,  90,  0,  0,  5, 26,  e_unknown, _sp_ninja_0
shuriken_1: DefineCmp_Entity 35, 160,  0,  0,  4, 16, e_shuriken, _sp_shuriken_0
shuriken_2: DefineCmp_Entity 50,  60,  0,  0,  4, 16, e_shuriken, _sp_shuriken_0
pts_1:      DefineCmp_Entity 40, 100,  0,  0,  2,  8,    e_pts_1, _sp_orb
pts_2:      DefineCmp_Entity 30,  70,  0,  0,  2,  8,    e_pts_1, _sp_orb

.area _CODE

;;    MANAGER PUBLIC FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;MAN_GAME::INIT
;;    Initialixes the game man to set
;;    it up for the starts of a new game.
;;INPUT: -
;;DESTROYS: AF, BC, DE, HL, IX
;;
man_game_init::

   ;;init systems
   ld    de, #_intro
   call  sys_music_init
  
   call  sys_render_init
   ;;inf loop
   call  sys_input_start_screen
   call  sys_music_stop
   ;; prevents key start to be taken as a game key
   call  man_game_wait_half_sec

reset_lvl:                                         ;;CHANGE, may clean only

   ld    de, #_ingame
   call  sys_music_init
   ;;entities in the center
   call  sys_physics_init
   ;; cleans screen before the game starts
   call  sys_render_clean_screen    
   ;;map drawing
   call  sys_render_draw_bg
   ;;cleans entity array and collisionable entity
   call  man_entity_init

   ;; sets player_alive to 1
   ld     a, #1
   ld    (_player_alive), a
   ;;sets score default
   ld     a, #4
   ld    (_lvl_score), a
   ;;LVL TO CHARGE SELECTION
   ld     a, (_game_lvl)
   cp    #1
   jr    nz, lvl_2 

lvl_1:
   ;;init entities
   ld    hl, #ninja 
   call  man_entity_create
   ld    hl, #shuriken_1
   call  man_entity_create
   ld    hl, #pts_1
   call  man_entity_create 
   ld    hl, #pts_2
   call  man_entity_create 

   ret

lvl_2:

   ld    hl, #ninja
   call  man_entity_create
   ld    hl, #shuriken_1
   call  man_entity_create
   ld    hl, #shuriken_2
   call  man_entity_create
   ld    hl, #pts_1
   call  man_entity_create 
   ld    hl, #pts_2
   call  man_entity_create 

   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAN GAME::UPDATE
;;    UPDATES 1 GAME CYCLE DOING EVERYTHING
;;    EXCEPT THE RENDERING. RENDERING IS
;;    CONSIDERED APART FOR ITS TIME CONTRAINTS
;; INPUT: - 
;; DESTROYS: - 
;;
man_game_update::
   ;;check inputs
   call  man_entity_getArray
   call  sys_input_update
   ;;calculate positions
   call  man_entity_getArray
   call  sys_physics_update
   ;;check collisions
   call  man_entity_collision_getArray
   call  sys_collision_update

   call  man_game_check_score
   call  sys_music_update
   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAN_GAME::RENDER
;;    DOES RENDERING PROCESS APART FROM
;;    GAME UPDATE TO ACCOUNT FOR ITS CONSTRAINTS
;; INPUTS: -
;; DESTROYS: -
;;
man_game_render::
   ;;draw all entities if necessary
   call  man_entity_getArray
   call  sys_render_update

   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAN_GAME::WAIT_HALF_SEC 
;;    Waits
;; INPUTS: -
;; DESTROYS: AF 
;;
man_game_wait_half_sec::
   ;; 300 halts more or less 1 sec
   ld     a, #150     

loop:
   halt
   dec    a
   jr    nz, loop

   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAN_GAME::RESTART
;;    Reset Game
;; INPUTS: -
;; DESTROYS: -
;;
man_game_restart::
   ld     a, #1
   call  man_game_set_lvl
   jp    man_game_init
   
   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAN_GAME::SET_LVL
;;    Set next lvl
;; INPUTS: 
;;    A = Num of lvl
;; DESTROYS: -
;;
man_game_set_lvl::
   ld    (_game_lvl), a
   call  sys_physics_set_composition

   ;;draw win screen
   bit   2, a
   ret   z
   ;;if lvl 3 ends and set 4th, then ends the game
   call man_game_win_end
   
   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAN_GAME::GET_LVL
;;    Get current lvl
;; RETURNS: 
;;    A = Num of lvl
;; DESTROYS: AF
;;
man_game_get_lvl::
   ld     a, (_game_lvl)
   
   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAN_GAME::RESET
;;    Reset current lvl
;; INPUTS: -
;; DESTROYS: -
;;
man_game_reset::
   call  sys_physics_reset_actualSet
   jp    reset_lvl
   
   ret

man_game_win_end::
   call  sys_render_draw_win
   call  man_game_wait_half_sec
   call  man_game_wait_half_sec
   call  man_game_wait_half_sec
   call  man_game_wait_half_sec
   call  sys_render_clean_screen
   call  man_game_wait_half_sec
   call  man_game_restart
   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAN_GAME::INC_SCORE
;;    increments current score
;; INPUT: - 
;; DESTROYS: AF
;;
man_game_inc_score::
   ld     a, (_lvl_score)
   inc    a
   ld    (_lvl_score), a
   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAN_GAME::DEC_SCORE
;;    Decrements current score
;; INPUT: - 
;; DESTROYS: AF
;;
man_game_dec_score::
   ld     a, (_lvl_score)
   dec    a
   ld    (_lvl_score), a
   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAN_GAME::CHECK_SCORE
;;    check if win or lose
;; INPUT: - 
;; DESTROYS: -
;;
man_game_check_score::
   ld     a, (_lvl_score)
   ;;check if lose
   cp    #0
   jr     z, lose
   ;;check if win
   bit    3, a
   ret    z
   ;;if z exit, if not, win
   call  man_game_wait_half_sec
   call  man_game_wait_half_sec
   call  man_game_get_lvl
   inc    a
   call  man_game_set_lvl
   call  man_game_reset

   ret 

lose:
   call  man_game_wait_half_sec
   call  man_game_wait_half_sec
   call  man_game_restart
   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  MAN_GAME_IS_PLAYER_ALIVE  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;     Returns flag Z         ;;
;;    if player is dead       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  INPUT:                    ;;
;;  DESTROYS: F, HL           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

man_game_is_player_alive::
   ld    hl, #_player_alive
   bit   0, (hl)
   ret

;; Sets _player_alive to 0, which means it is dead
;; Destroys: AF
man_game_player_dead::
   xor   a
   ld   (_player_alive), a
   ret