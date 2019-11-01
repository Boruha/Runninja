;;
;;	HEADER RENDER SYS
;;
.globl sys_render_init
.globl sys_render_update
.globl sys_render_render_entities
.globl sys_render_clean_screen
.globl sys_render_clean_entity
.globl sys_render_draw_startScreen
.globl sys_render_draw_bg
.globl sys_render_draw_win
.globl screen_start


;; 	LOCAL VARIABLES DECOMPRESSION
decompress_buffer 		= 0x040
level_max_size 			= 0x4000
decompress_buffer_end 	= decompress_buffer + level_max_size - 1