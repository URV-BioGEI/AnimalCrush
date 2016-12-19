@;=                                                          	     	=
@;=== RSI_timer1.s: rutinas para escalar los elementos (sprites)	  ===
@;=                                                           	    	=
@;=== Programador tarea 2F: bernat.bosca@estudiants.urv.cat			  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.align 2
		.global timer1_on
	timer1_on:	.hword	0 			@;1 -> timer1 en marcha, 0 -> apagado
	divFreq1: .hword	-5727,5		@;divisor de frecuencia para timer 1 per a 0,35s amb freq. entrada 523656,96875 Hz


@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
	escSen: .space	2				@;sentido de escalado (0-> dec, 1-> inc)
	escFac: .space	2				@;Factor actual de escalado
	escNum: .space	2				@;número de variaciones del factor


@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Fb;
@;activa_timer1(init); rutina para activar el timer 1, inicializando el sentido
@;	de escalado según el parámetro init.
@;	Parámetros:
@;		R0 = init;  valor a trasladar a la variable 'escSen' (0/1)
	.global activa_timer1
activa_timer1:
		push {r1-r3, lr}
			ldr r1, =timer1_on
			ldrh r2, [r1]
			mov r2, #1
			strh r2, [r1]				@;Fiquem timer1_on a 1
			ldr r2, =divFreq1
			ldrh r3, [r2]
			ldr r2, =0x04000104			@;Timer1_data
			orr r3, #0x00C10000			@;Mascara 1100 0001 per activar el timer i def freq, amb 523657 Hz d'entrada
			str r3, [r2]
			mov r1, #0
			ldr r2, =escNum
			strh r1, [r2]				@;Fiquem a 0 escNum
			ldr r1, =escSen
			strh r0, [r1]				@;Guardem init en escSen
			cmp r0, #0
			bne .Lend
				mov r1, #1
				mov r0, r1, lsl #8		@;Per ficar 1,0 en format 0.8.8
				ldr r1, =escFac
				strh r0, [r1]			@;Figem la variable escFac a 1,0
				mov r1, r0
				mov r2, r0
				mov r0, #0				@;0 perque volem el grup 0
				bl SPR_fijarEscalado
			.Lend:			
		pop {r1-r3, pc}


@;TAREA 2Fc;
@;desactiva_timer1(); rutina para desactivar el timer 1.
	.global desactiva_timer1
desactiva_timer1:
		push {r0, r1,lr}
			ldr r0, =timer1_on
			mov r1, #0
			strh r1, [r0] 				@;Deactivem timer1_on
			ldr r0, =0x04000106			@;0x04000106	Timer1_control
			ldrh r1, [r0]
			bic r1, #128				@;Posem bit 7 a 0 (desactiva timer) 0111 1111
			strh r1, [r0]				@;Guardem al registre de control
		pop {r0, r1,pc}



@;TAREA 2Fd;
@;rsi_timer1(); rutina de Servicio de Interrupciones del timer 1: incrementa el
@;	número de escalados y, si es inferior a 32, actualiza factor de escalado
@;	actual según el código de la variable 'escSen'. Cuando se llega al máximo
@;	se desactivará el timer1.
	.global rsi_timer1
rsi_timer1:
		push {r0-r2, lr}
			ldr r0, =escNum
			ldrh r1, [r0]
			add r1, #1
			strh r1, [r0]				@;Incrementem escNum
			cmp r1, #32
			bne .Lno32
				bl desactiva_timer1		@;Si escNum = 32 -> desactivar_timer1
				b .Lfin
			.Lno32:
			ldr r0, =escSen
			ldrh r1, [r0]
			ldr r0, =escFac
			ldrh r2, [r0]
			cmp r1, #0					@;Si escSen = 1 decrementar escFac, si es 0 incrementar escFac
			subne r2, #32
			cmp r1, #0
			addeq r2, #32
			strh r2, [r0]				@;Actualisem escFac
			mov r1, r2
			mov r0, #0
			bl SPR_fijarEscalado		@;Actualisem el factor de escalado del Grup0
			ldr r0, =update_spr
			mov r1, #1
			strh r1, [r0]				@;Activem la variable update_spr
		.Lfin:
		pop {r0-r2, pc}



.end
