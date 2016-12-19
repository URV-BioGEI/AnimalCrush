@;=                                                          	     	=
@;=== RSI_timer2.s: rutinas para animar las gelatinas (metabaldosas)  ===
@;=                                                           	    	=
@;=== Programador tarea 2G: cristina.izquierdo@estudiants.urv.cat	  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.align 2
		.global update_gel
	update_gel:	.hword	0			@;1 -> actualizar gelatinas
		.global timer2_on
	timer2_on:	.hword	0 			@;1 -> timer2 en marcha, 0 -> apagado
	divFreq2: .hword	-3343,374		@;divisor de frecuencia para timer 2 per a fer 10 canvis de metabaldosa per segon, amb una freq. d'entrada de 130.914,9921875 Hz



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Gb;
@;activa_timer2(); rutina para activar el timer 2.
	.global activa_timer2
activa_timer2:
		push {r0-r3, lr}
		ldr r0, =timer2_on		@;r0=@timer2_on
		mov r1, #1
		strh r1, [r0]			@;posem timer2_on = 1
		ldr r0, =0x04000108 	@;r0=@registre de dades del timer2
		ldr r1, =divFreq2		@;r1=@divisor de freq
		ldrh r2, [r1]
		orr r3, r2, #0x00C10000		@;activar timer2
		str r3, [r0]
		pop {r0-r3, pc}

@;TAREA 2Gc;
@;desactiva_timer2(); rutina para desactivar el timer 2.
	.global desactiva_timer2
desactiva_timer2:
		push {r0-r1, lr}
		ldr r0, =timer2_on		@;r0=@timer2_on
		mov r1, #0
		strh r1, [r0]			@;posem timer2_on = 0
		ldr r0, =0x0400010A		@;r0=@registre de control del timer2
		ldrh r1, [r0]
		bic r1, #128			@;bit 7 a 0 (start/stop)
		strh r1, [r0]			@;desactivem el timer2
		pop {r0-r1, pc}



@;TAREA 2Gd;
@;rsi_timer2(); rutina de Servicio de Interrupciones del timer 2: recorre todas
@;	las posiciones de la matriz mat_gel y, en el caso que el código de
@;	activación (ii) sea mayor o igual a 1, decrementa dicho código en una unidad
@;	y, en el caso que alguna llegue a 0, incrementa su código de metabaldosa y
@;	activa una variable global update_gel para que la RSI de VBlank actualize
@;	la visualización de dicha metabaldosa.
	.global rsi_timer2
rsi_timer2:
		push {r0-r6, lr}
			ldr r0, =mat_gel			@;r0=mat_gel[][COLUMNS]
			mov r1, #0					@;r1=index
		.L_recorreMatGel:
			ldrb r3, [r0, #GEL_II]		@;r3=camp ii
			cmp r3, #0
			beq .Aumentar_Actualizar	@;si es 0, actualitza i augmenta im
			tst r3, #0x80				@;comparem el bit de signe (1000 0000)
			beq .Decrementar			@;si es positiu decrementar
			b .L_final					@;si es -1 s'ha d'ignorar
		.Aumentar_Actualizar:
			ldr r4, =update_gel 		@;si el camp ii es un 0
			mov r5, #1					@;posem un 1 a la variable update_gel
			strb r5, [r4]				@;per actualitzar la metabaldosa
			ldrb r3, [r0, #GEL_IM]			@;r3=camp im
			add r3, #1
			strb r3, [r0, #GEL_IM]			@;augmentem l'index im
			cmp r3, #7					@;final simple
			bgt .Fsimple
			cmp r3, #15					@;final soble
			bgt .Fdoble
			b .L_final					@;sino esta al final de simple o doble passa a la seg posicio
		.Fsimple:
			mov r3, #0
			strb r3, [r0, #GEL_IM]			@;tornem al index im inicial de la simple
			b .L_final
		.Fdoble:
			mov r3, #8
			strb r3, [r0, #GEL_IM]			@;tornem al index im inicial de la doble
			b .L_final
		.Decrementar:
			sub r3, #1					@;si es superior a 0, decrementem
			strb r3, [r0]				@;i passem a la seguent posicio
			b .L_final
		.L_final:
			add r1, #1					@;augmentem index
			add r0, #GEL_TAM			@;seguent casella (char ii + char im)
			cmp r1, #ROWS*COLUMNS					@;comparem amb el final de la matriu
			ble .L_recorreMatGel		@;si es mes petit o igual al final, passem a la seguent casella
		
		pop {r0-r6, pc}


.end
