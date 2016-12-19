@;=                                                          	     	=
@;=== RSI_timer3.s: rutinas para desplazar el fondo 3 (imagen bitmap) ===
@;=                                                           	    	=
@;=== Programador tarea 2H: albert.canellas@estudiants.urv.cat		  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.align 2
		.global update_bg3
	update_bg3:	.hword	0				@;1 -> actualizar fondo 3
		.global timer3_on
	timer3_on:	.hword	0 				@;1 -> timer3 en marcha, 0 -> apagado
		.global offsetBG3X
	offsetBG3X: .hword	0				@;desplazamiento vertical fondo 3
	sentidBG3X:	.hword	0				@;sentido desplazamiento (0-> inc / 1-> dec)
	divFreq3: .hword	-13091,5				@;divisor de frecuencia para timer 3 -13091,5 per a una freq de entrada de 130915 Hz
	


@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Hb;
@;activa_timer3(); rutina para activar el timer 3.
	.global activa_timer3
activa_timer3:

		push {r1-r5, lr}
			ldr r1, =timer3_on			@;ficar timer3_on a 1
			mov r2, #1
			strh r2, [r1]
			ldr r3, =divFreq3			@;DIV FREQ
			ldrh r4, [r3]
			ldr r5, =0x0400010C			@;guardar freq en timer3_data
			orr r4, #0x00c20000			@;mascara 1100 0010 per activar el timer i def freq
			str r4, [r5]
		pop {r1-r5, pc}



@;TAREA 2Hc;
@;desactiva_timer3(); rutina para desactivar el timer 3.
	.global desactiva_timer3
desactiva_timer3:
		push {r0, r1,lr}
			ldr r0, =timer3_on
			mov r1, #0
			strh r1, [r0] 				@;Deactivem timer0_on
			ldr r0, =0x0400010E			@;0x0400010E	Timer3_control
			ldrh r1, [r0]
			bic r1, #128				@;Posem bit 7 a 0 (desactiva timer) 1000 0000
			strh r1, [r0]				@;Guardem al registre de control
		pop {r0, r1,pc}


@;TAREA 2Hd;
@;rsi_timer3(); rutina de Servicio de Interrupciones del timer 3: incrementa o
@;	decrementa el desplazamiento X del fondo 3 (sobre la variable global
@;	'offsetBG3X'), según el sentido de desplazamiento actual; cuando el
@;	desplazamiento llega a su límite, se cambia el sentido; además, se avisa
@;	a la RSI de retroceso vertical para que realice la actualización del
@;	registro de control del fondo correspondiente.
	.global rsi_timer3
rsi_timer3:
		push {r1-r6, lr}

			ldr r1, =sentidBG3X
			ldrh r2, [r1]
			ldr r3, =offsetBG3X			@;offsetBG3x= desplaçament pixels imatges
			ldrh r4, [r3]
			cmp r4, #255				@;comparar amb el limit inferior 
			moveq r2, #1				@;com no podem baixar mes canviem de sentit a 1
			cmp r4, #0					@;comparar amb el limit superior
			moveq r2, #0				@;com no podem pujar mes canviem el sentita a 0
			strh r2, [r1]
			cmp r2, #0	
			bne .Lno_incrementar
			add r4, #1					@;si sentit es 0 incrementar
			strh r4, [r3]
			b .Lfigir
			.Lno_incrementar:
			sub r4, #1					@;si sentit es 1 decrementar
			strh r4, [r3]
			.Lfigir:
			ldr r5, =update_bg3
			mov r6, #1
			strh r6, [r5]

		pop {r1-r6, pc}



.end
