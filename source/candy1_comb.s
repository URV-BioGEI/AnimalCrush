@;=                                                               		=
@;=== candy1_combi.s: rutinas para detectar y sugerir combinaciones   ===
@;=                                                               		=
@;=== Programador tarea 1G: albert.canellas@estudiants.urv.cat				  ===
@;=== Programador tarea 1H: albert.canellas@estudiants.urv.cat				  ===
@;=                                                             	 	=



.include "../include/candy1_incl.i"



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1G;
@; hay_combinacion(*matriz): rutina para detectar si existe, por lo menos, una
@;	combinación entre dos elementos (diferentes) consecutivos que provoquen
@;	una secuencia válida, incluyendo elementos en gelatinas simples y dobles.
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 si hay una secuencia, 0 en otro caso
	.global hay_combinacion
hay_combinacion:
		push {r1-r12,lr}
				mov r4, r0						;@*Moviment horitzontal guardar direcio base
				mov r3, #ROWS					;@dim de files
				mov r12, #COLUMNS				;@dim de columnes
				mov r0, #0						;@variable que controla si s'ha trobat una combinacio
				mov r1, #0						;@r1=files , inicialitza a 0 per fer totes les files en el mov. hor
				mov r2, #0						;@r2=columnes,
				sub r12, #1						;@c<columns-1
			.Lwhilef1:
				cmp r1, r3						;@comprovar condicio f<rows === es  igual a aixo f<rows?????
				bge .Lfinwhilef1				;@saltar a final del while de files
				cmp r0, #6						;@comprovar que no s'hagi trobat ja una combinacio
				beq .Lfi
				.Lwhilec1:
					cmp r2, r12
					bge .Lfinwhilec1
					cmp r0, #6
					beq .Lfinwhilec1
					mul r5, r1 ,r3
					add r5, r2					;@r5=desplaçament(rows*f+c)
					ldrb r6, [r4, r5]			;@r6= tipus de gelatina actual
					cmp r6, #0
					beq .Lif1
					cmp r6, #7
					beq .Lif1
					cmp r6, #15
					beq .Lif1					;@comparacio amb llocs especials
					add r5, #1
					ldrb r8, [r4, r5]			;@r8= tipus gelatina seguent			
					and r7, r6, #0x00000007		;@r7 mascara per comparar el bits de les gelatines (gelatina actual)
					and r11, r8, #0x00000007	;@r11=mascara per comparar (gelatina seguent)
					cmp r7, r11
					beq .Lgeligual
					cmp r8, #0
					beq .Lif1
					cmp r8, #7
					beq .Lif1
					cmp r8, #15
					beq .Lif1	 				;@comparacio amb gelatina seguent amb llocs especials
					strb r6, [r4, r5]			;@mov de gelatina actual a r9=actual
					sub r5, #1					;@mov de gelatina seguent a r10=seguent
					strb r8, [r4, r5]
					.Lgeligual:
					bl detectar_orientacion
					cmp r0, #6
					bne .Lfi					;@si e trobat combinacio ves al final
					add r2, #1					;@c+1
					bl detectar_orientacion
					sub r2, #1
					cmp r0, #6
					bne .Lfi					;@si e trobat combinacio ves al final
					.Lif1:
					add r2, #1
					b .Lwhilec1
				.Lfinwhilec1:
				add r1, #1
				b .Lwhilef1
			.Lfinwhilef1:	
				mov r1, #0						;@!*Moviment vertical*! r1=files , inicialitza a 0 per fer totes les files en el mov. hor
				mov r2, #0						;@r2=columnes, r1=files 
				mov r3, #ROWS					;@dim de files
				mov r12, #COLUMNS				;@dim de columnes
				add r12, #1	
				sub r3, #1						;@c<rows-1
			.Lwhilef2:
				cmp r1, r3						;@comprovar condicio f<rows === es  igual a aixo f<rows?????
				bge .Lfinwhilef2				;@saltar a final del while de files
				cmp r0, #6						;@comprovar que no s'hagi trobat ja una combinacio
				bne .Lfi
				.Lwhilec2:
					cmp r2, r12
					bge .Lfinwhilec2
					cmp r0, #6
					bne .Lfinwhilec2
					mul r5, r1 ,r3
					add r5, r2					;@r5=desplaçament(rows*f+c)
					ldrb r6, [r4, r5]			;@r6= tipus de gelatina actual
					cmp r6, #0
					beq .Lif2
					cmp r6, #7
					beq .Lif2
					cmp r6, #15
					beq .Lif2					;@comparacio amb llocs especials
					add r5, r3					;@+row al desplaçament per anar a la seguent fila
					ldrb r8, [r4, r5]			;@!*comença punt 3*! r8= tipus gelatina seguent			
					and r7, r6, #0x00000007		;@r7 mascara per comparar el bits de les gelatines (gelatina actual)
					and r11, r8, #0x00000007	;@r11=mascara per comparar (gelatina seguent)
					cmp r7, r11
					beq .Lgeligual2
					cmp r8, #0
					beq .Lif2
					cmp r8, #7
					beq .Lif2
					cmp r8, #15
					beq .Lif2	 				;@comparacio amb gelatina seguent amb llocs especials		strb r6, [r4, r5]	,mov r9, r6
					strb r6, [r4, r5]					;@mov de gelatina actual a r9=actual				sub r5,r3			,mov r10, r8	
					sub r5, r3					;@mov de gelatina seguent a r10=seguent						strb r8, [r4, r5]	,mov r6, r10
					strb r8, [r4, r5]			;@																			,mov r8, r9
					.Lgeligual2:
					bl detectar_orientacion		;@
					cmp r0, #6
					bne .Lfi					;@si e trobat combinacio ves al final
					add r1, #1					;@f+1
					bl detectar_orientacion
					sub r1, #1
					cmp r0, #6
					bne .Lfi					;@si e trobat combinacio ves al final
					.Lif2:
					add r2, #1
					b .Lwhilec2
				.Lfinwhilec2:
				add r1, #1
				b .Lwhilef2
			.Lfinwhilef2:	
			
		.Lfi:									;@final final 
		cmp r0, #6
		beq .Lcanv
		mov r0, #1
		b .Lfinal
		.Lcanv:
		mov r0, #0
		.Lfinal:
		pop {r1-r12,pc}



@;TAREA 1H;
@; sugiere_combinacion(*matriz, *sug): rutina para detectar una combinación
@;	entre dos elementos (diferentes) consecutivos que provoquen una secuencia
@;	válida, incluyendo elementos en gelatinas simples y dobles, y devolver
@;	las coordenadas de las tres posiciones de la combinación (por referencia).
@;	Restricciones:
@;		* se supone que existe por lo menos una combinación en la matriz
@;			 (se debe verificar antes con la rutina 'hay_combinacion')
@;		* la combinación sugerida tiene que ser escogida aleatoriamente de
@;			 entre todas las posibles, es decir, no tiene que ser siempre
@;			 la primera empezando por el principio de la matriz (o por el final)
@;		* para obtener posiciones aleatorias, se invocará la rutina 'mod_random'
@;			 (ver fichero "candy1_init.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección del vector de posiciones (char *), donde la rutina
@;				guardará las coordenadas (x1,y1,x2,y2,x3,y3), consecutivamente.
	.global sugiere_combinacion
sugiere_combinacion:
		push {lr}
		
		
		pop {pc}




@;:::RUTINAS DE SOPORTE:::



@; generar_posiciones(vect_pos,f,c,ori,cpi): genera las posiciones de sugerencia
@;	de combinación, a partir de la posición inicial (f,c), el código de
@;	orientación 'ori' y el código de posición inicial 'cpi', dejando las
@;	coordenadas en el vector 'vect_pos'.
@;	Restricciones:
@;		* se supone que la posición y orientación pasadas por parámetro se
@;			corresponden con una disposición de posiciones dentro de los límites
@;			de la matriz de juego
@;	Parámetros:
@;		R0 = dirección del vector de posiciones 'vect_pos'
@;		R1 = fila inicial 'f'
@;		R2 = columna inicial 'c'
@;		R3 = código de orientación;
@;				inicio de secuencia: 0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte
@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
@;		R4 = código de posición inicial:
@;				0 -> izquierda, 1 -> derecha, 2 -> arriba, 3 -> abajo
@;	Resultado:
@;		vector de posiciones (x1,y1,x2,y2,x3,y3), devuelto por referencia
generar_posiciones:
		push {lr}
		
		
		pop {pc}



@; detectar_orientacion(f,c,mat): devuelve el código de la primera orientación
@;	en la que detecta una secuencia de 3 o más repeticiones del elemento de la
@;	matriz situado en la posición (f,c).
@;	Restricciones:
@;		* para proporcionar aleatoriedad a la detección de orientaciones en las
@;			que se detectan secuencias, se invocará la rutina 'mod_random'
@;			(ver fichero "candy1_init.s")
@;		* para detectar secuencias se invocará la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;		* sólo se tendrán en cuenta los 3 bits de menor peso de los códigos
@;			almacenados en las posiciones de la matriz, de modo que se ignorarán
@;			las marcas de gelatina (+8, +16)
@;	Parámetros:
@;		R1 = fila 'f'
@;		R2 = columna 'c'
@;		R4 = dirección base de la matriz
@;	Resultado:
@;		R0 = código de orientación;
@;				inicio de secuencia: 0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte
@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
@;				sin secuencia: 6 
detectar_orientacion:
		push {r3,r5,lr}
		
		
		pop {r3,r5,pc}



.end
