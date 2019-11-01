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
;;	COMPONENT ARRAY DATA STRUCTURE
;;


 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;INPUT:
 ;;	_Tname: Name of the COMPONENT type
 ;;	_N: 	  Size of the array in number components
 ;;	_DefineTypeMacroDefault: Macro to be called to generate default
 ;;
 .macro DefineComponentArrayStructure _Tname, _N, _DefineTypeMacroDefault
 	_Tname'_num:	.db 0
 	_Tname'_pend:	.dw _Tname'_array
 	_Tname'_array:
 	.rept _N 
 		_DefineTypeMacroDefault
 	.endm
 .endm


.macro DefinePointerArrayStructure _Tname, _N
 	_Tname'_pend:	.dw _Tname'_array
 	_Tname'_array:
 	.rept _N 
 		.dw 0x0000
 	.endm
.endm

