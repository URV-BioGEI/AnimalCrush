@;=                                                          	     	=
@;=== RSI_timer3.s: rutinas para desplazar el fondo 3 (imagen bitmap) ===
@;=                                                           	    	=
@;=== Programador tarea 2H: xxx.xxx@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.align 2
		.global update_bg3
	update_bg3:	.hword	0			@;1 -> actualizar fondo 3
		.global timer3_on
	timer3_on:	.hword	0 			@;1 -> timer3 en marcha, 0 -> apagado
		.global offsetBG3X
	offsetBG3X: .hword	0			@;desplazamiento vertical fondo 3
	sentidBG3X:	.hword	0			@;sentido desplazamiento (0-> inc / 1-> dec)
	divFreq3: .hword	1			@;divisor de frecuencia para timer 3
	


@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Hb;
@;activa_timer3(); rutina para activar el timer 3.
	.global activa_timer3
activa_timer3:
		push {r1-r4, lr}
		ldr r1, =timer3_on			@;poner timer3_on a 1
		ldrh r2, [r1]
		mov r2, #1
		strh r2, [r1]
		ldr r1, =divFreq3
		ldrh r2, [r1]
		ldr r2, #-3272		@;tindria de ser negatiu pero no me deja (-3272)
		str r2, [r1]
		ldr r3, =TIMER3_CR
		ldr r4, [r3]
		orr r4, #0x23		@;mascara 0010 0011
		str r4, [r3]
		pop {r1-r4, pc}


@;TAREA 2Hc;
@;desactiva_timer3(); rutina para desactivar el timer 3.
	.global desactiva_timer3
desactiva_timer3:
		push {r1-r4, lr}
		ldr r1, =TIMER3_CR
		ldr r2, [r1]
		and r2, #0x03		@;mascara 0000 0011
		str r2, [r1]
		ldr r3, =timer3_on
		ldrh r4, [r3]
		mov r4, #0
		strh r4, [r3]		@;ficar timer3_on a 0
		pop {r1-r4, pc}



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
		ldr r1, =sentidBG3
		ldrh r2, [r1]
		ldr r3, =offsetBG3x
		ldrh r4, [r3]
		cmp r4, #320			@;comparar amb el limit inferior 
		moveq r2, #1			@;com no podem baixar mes canviem de sentit a 1
		cmp r4, #0				@;comparar amb el limit superior
		moveq r2, #0			@;com no podem pujar mes canviem el sentita a 0
		cmp r2, #0
		bne .Lno_incrementar
		add r4, #1				@;si sentit es 0 incrementar
		strh r4, [r3]
		b .Lfigir
		.Lno_incrementar:
		sub r4, #1				@;si sentit es 1 decrementar
		strh r4, [r3]
		.Lfigir:
		ldr r5, =update_bg3
		mov r6, #1
		strh r6, [r5]
		pop {r1-r6, pc}



.end
