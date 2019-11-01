;;-----------------------------LICENSE NOTICE------------------------------------
;;	This program is free software under the terms of the GNU Lesser General Public License as published by
;;  the Free Software Foundation.
;;
;;  See the GNU Lesser General Public License for more details.
;;  <http://www.gnu.org/licenses/>.
;;
;;	Devs: Borja Pozo, Carlos Romero and Mateo Linas 
;;-------------------------------------------------------------------------------

.globl _sp_ninja_0	;; prepared to jump to the right
.globl _sp_ninja_1	;; prepared to jump to the left
.globl _sp_ninja_2	;; jumping to the right
.globl _sp_ninja_3	;; damage while jumping right
.globl _sp_ninja_4	;; jumping to the left
.globl _sp_ninja_5	;; damage while jumping left

.globl _sp_shuriken_0
.globl _sp_shuriken_1
.globl _sp_shuriken_2
.globl _sp_shuriken_3

.globl _sp_planti_0
.globl _sp_planti_1
.globl _sp_planti_2
.globl _sp_planti_3
.globl _sp_planti_4
.globl _sp_planti_5
.globl _sp_planti_6
.globl _sp_planti_7

.globl _sp_plantd_0
.globl _sp_plantd_1
.globl _sp_plantd_2
.globl _sp_plantd_3
.globl _sp_plantd_4
.globl _sp_plantd_5
.globl _sp_plantd_6
.globl _sp_plantd_7

.globl _palette_ninja
.globl _sp_orb

.globl _intro 		;; intro  music
.globl _ingame 		;; ingame music
	
plant_width  ==  6
plant_height == 28

plant_size == #plant_width * #plant_height