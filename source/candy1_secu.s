@;=                                                               		=
@;=== candy1_secu.s: rutinas para detectar y elimnar secuencias 	  ===
@;=                                                             	  	=
@;=== Programador tarea 1C: bernat.bosca@estudiants.urv.cat			  ===
@;=== Programador tarea 1D: bernat.bosca@estudiants.urv.cat			  ===
@;=                                                           		   	=



.include "../include/candy1_incl.i"



@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
@; número de secuencia: se utiliza para generar números de secuencia únicos,
@;	(ver rutinas 'marcar_horizontales' y 'marcar_verticales') 
	num_sec:	.space 1



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1C;
@; hay_secuencia(*matriz): rutina para detectar si existe, por lo menos, una
@;	secuencia de tres elementos iguales consecutivos, en horizontal o en
@;	vertical, incluyendo elementos en gelatinas simples y dobles.
@;	Restricciones:
@;		* para detectar secuencias se invocará la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 si hay una secuencia, 0 en otro caso
	.global hay_secuencia
hay_secuencia:
		push {r1-r11, lr}
		mov r1, #0					@; R1: fila
		mov r2, #0					@; R2: columna
		mov r4, #ROWS				@; R4: rows
		mov r5, #COLUMNS			@; R5: columns
		mov r8, #0					@; R8: valor que detecta secuencia
		.LwhileFila:
			cmp r1, r4
			bge .LfiwhileFila
			.LwhileColum:
				cmp r2, r5
				bge .LfiwhileColum
				mul r10, r1, r5
				add r10, r4
				ldrb r11, [r0, r10]
				cmp r11, #7
				beq .Lif2
				cmp r11, #8
				beq .Lif2
				cmp r11, #15
				beq .Lif2
				cmp r11, #16
				beq .Lif2
				cmp r11, #0
				ble .Lif2
				cmp r11, #23
				bge .Lif2
				sub r6, r4, #1				@; R6: fila-1;
				cmp r1, r6
				bge .Lif1
				mov r3, #1					@; R3: orientacio de cuenta_repeticiones Sur
				mov r9, r0					@; R9: guardem matriz 
				bl cuenta_repeticiones		@; retorna a R0 número de repeticiones detectadas (mínimo 1)
				mov r8, r0					@; R8: arreplega el valor retornat
				mov r0, r9					@; R0: recupera matriz
				.Lif1:
				cmp r8, #3
				bge .LfiwhileFila
				sub r7, r5, #1				@; R7: columna-1;
				cmp r2, r7
				bge .Lif2
				mov r3, #0					@; R3: orientacio de cuenta_repeticiones Este
				mov r9, r0					@; R9: guardem matriz 
				bl cuenta_repeticiones		@; retorna a R0 número de repeticiones detectadas (mínimo 1)
				mov r8, r0					@; R8: arreplega el valor retornat
				mov r0, r9					@; R0: recupera matriz
				.Lif2:
				cmp r8, #3
				bge .LfiwhileFila
				add r2, #1
				b .LwhileColum
			.LfiwhileColum:
			add r1, #1
			mov r2, #0
			b .LwhileFila
		.LfiwhileFila:
		mov r0, #1
		cmp r8, #3
		bge .Lfifuncio
			mov r0, #0
		.Lfifuncio:
		pop {r1-r11, pc}



@;TAREA 1D;
@; elimina_secuencias(*matriz, *marcas): rutina para eliminar todas las
@;	secuencias de 3 o más elementos repetidos consecutivamente en horizontal,
@;	vertical o combinaciones, así como de reducir el nivel de gelatina en caso
@;	de que alguna casilla se encuentre en dicho modo; 
@;	además, la rutina marca todos los conjuntos de secuencias sobre una matriz
@;	de marcas que se pasa por referencia, utilizando un identificador único para
@;	cada conjunto de secuencias (el resto de las posiciones se inicializan a 0). 
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección de la matriz de marcas
	.global elimina_secuencias
elimina_secuencias:
		push {r2-r11, lr}
		mov r2, #0					@; R2: fila
		mov r3, #0					@; R3: columna
		mov r4, #ROWS				@; R4: rows
		mov r5, #COLUMNS			@; R5: columns
		mov r6, #0					@; R6: 0 a colocar en la matriz de marcas
		.Lwfila:
			cmp r2, r4
			bge .Lwfinalfila
			.Lwcolumna:
				cmp r3, r5
				bge .Lwfinalcolumna
				mul r11, r2, r5			@; R11: fila per a coordena
				add r7, r11, r3			@; R7: coordena de la matriz
				strb r6, [r1, r7]		@; guarda R6 en la matriz de marca a la posició R7
				add r3, #1
				b .Lwcolumna
			.Lwfinalcolumna:
			add r2, #1
			mov r3, #0
			b .Lwfila
		.Lwfinalfila:
		bl marcar_horizontales
		bl marcar_verticales
		mov r2, r0					@; R2: matriz de juego
		mov r3, r1					@; R3: matriz de marcas
		mov r0, #0					@; R0: fila
		mov r1, #0					@; R1: columna
		.Lwfila2:
			cmp r0, r4
			bge .Lwfinalfila2
			.Lwcolumna2:
				cmp r1, r5
				bge .Lwfinalcolumna2
				mul r11, r0, r5			@; R11: fila per a coordena
				add r7, r11, r1			@; R7: coordena de la matriz
				ldrb r8, [r3, r7]		@; R8: carrega el que hi ha en la coordena R7 de la matriz_marcas
				cmp r8, #0
				beq .Lfinif
				ldrb r9, [r2, r7]		@; R9: carrega el que hi ha en la coordena R7 de la matriz de juego
				cmp r9, #14
				ble .Lif
				push {r0}
				bl elimina_elemento
				pop {r0}
				bl elimina_gelatina
				mov r10, #8				@; R10: guardar gelatina 8 en la matriz
				strb r10, [r2, r7]
				b .Lfinif
				.Lif:
					cmp r9, #8
					blgt elimina_gelatina	@; Si es mes gran de 8 sera una gelatina simple
					cmp r9, #7
					beq .Lfinif
					cmp r9, #8
					beq .Lfinif
					push {r0}
					bl elimina_elemento		@; guardem r0 perque la funcio retorna un valor
					pop {r0}
					mov r10, #0
					strb r10, [r2, r7]		@; R10: guardar 0 en la matriz
				.Lfinif:
				add r1, #1
				b .Lwcolumna2
			.Lwfinalcolumna2:
			add r0, #1
			mov r1, #0
			b .Lwfila2
		.Lwfinalfila2:
		pop {r2-r11, pc}


	
@;:::RUTINAS DE SOPORTE:::



@; marcar_horizontales(mat): rutina para marcar todas las secuencias de 3 o más
@;	elementos repetidos consecutivamente en horizontal, con un número identifi-
@;	cativo diferente para cada secuencia, que empezará siempre por 1 y se irá
@;	incrementando para cada nueva secuencia, y cuyo último valor se guardará en
@;	la variable global 'num_sec'; las marcas se guardarán en la matriz que se
@;	pasa por parámetro 'mat' (por referencia).
@;	Restricciones:
@;		* se supone que la matriz 'mat' está toda a ceros
@;		* para detectar secuencias se invocará la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección de la matriz de marcas
marcar_horizontales:
		push {r2-r12, lr}
		mov r2, #0					@; R2: fila
		mov r3, #0					@; R3: columna
		mov r6, #ROWS				@; R6: rows
		mov r7, #COLUMNS			@; R7: columns
		mov r8, #0					@; R8: num_repeticions
		mov r9, #0					@; R9: num_sec
		.LwhileFila23:
			cmp r2, r6
			bge .LfiwhileFila23
			.LwhileColum23:
				cmp r3, r7
				bge .LfiwhileColum23
				sub r10, r7, #1				@; R10: columna-1;
				cmp r3, r10
				bge .Lif23
				mul r12, r2, r7				@; R12: fila per a coordena
				add r11, r3, r12			@; R11: coordena matriz_marcas
				ldrb r12, [r0, r11]			@; R12: veu que hi ha a la matriz_marcas en coordena R11
				cmp r12, #7
				beq .Lif23
				cmp r12, #15				@; si a la casella hi ha un 7 o 15 saltem al final
				beq .Lif23
				mov r11, r1					@; R11: guardem matriz_marcas
				mov r1, r2					@; R1: pasa a ser FILA
				mov r2, r3					@; R2: pasa a ser COLUMNA
				mov r3, #0					@; R3: pasa a ser l'orientacio de cuenta_repeticiones Este
				mov r12, r0					@; R12: guardem matriz_base 
				bl cuenta_repeticiones		@; retorna a R0 número de repeticiones detectadas (mínimo 1)
				mov r8, r0					@; R8: arreplega el valor retornat
				mov r0, r12					@; R0: recupera matriz
				mov r3, r2					@; R3: torna a ser COLUMNA
				mov r2, r1					@; R2: torna a ser FILA
				mov r1, r11					@; R1: torna a ser matriz_marcas
				cmp r8, #3
				blt .Lif23
				mul r12, r2, r7				@; R12: fila per a coordena
				add r11, r3, r12			@; R11: coordena matriz_marcas
				ldrb r12, [r1, r11]			@; R12: veu que hi ha a la matriz_marcas en coordena R11
				cmp r12, #0
				bne .Lif23
				add r9, #1					@; num_sec++;
				.Lwhile8:
					cmp r8, #0
					beq .Lif23
					sub r8, #1				@; num_repeticions--;
					mul r12, r2, r7			@; R12: fila per a coordena
					add r11, r3, r8
					add r11, r12			@; R11: coordena [f][c+num_rep-1];
					strb r9, [r1, r11]		@; guarda R9 en la matriz de marca a la posició R11
					b .Lwhile8
				.Lif23:
				add r3, #1
				b .LwhileColum23
			.LfiwhileColum23:
			add r2, #1
			mov r3, #0
			b .LwhileFila23
		.LfiwhileFila23:
		ldrb r12, =num_sec				@; R12: puntero a num_sec
		strb r9, [r12]					@; guardem R9 a R12
		pop {r2-r12, pc}



@; marcar_verticales(mat): rutina para marcar todas las secuencias de 3 o más
@;	elementos repetidos consecutivamente en vertical, con un número identifi-
@;	cativo diferente para cada secuencia, que seguirá al último valor almacenado
@;	en la variable global 'num_sec'; las marcas se guardarán en la matriz que se
@;	pasa por parámetro 'mat' (por referencia);
@;	sin embargo, habrá que preservar los identificadores de las secuencias
@;	horizontales que intersecten con las secuencias verticales, que se habrán
@;	almacenado en en la matriz de referencia con la rutina anterior.
@;	Restricciones:
@;		* se supone que la matriz 'mat' está marcada con los identificadores
@;			de las secuencias horizontales
@;		* la variable 'num_sec' contendrá el siguiente indentificador (>1)
@;		* para detectar secuencias se invocará la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección de la matriz de marcas
marcar_verticales:
		push {r2-r12, lr}
		mov r2, #0					@; R2: fila
		mov r3, #0					@; R3: columna
		mov r6, #ROWS				@; R6: rows
		mov r7, #COLUMNS			@; R7: columns
		mov r8, #0					@; R8: num_repeticions
		ldrb r12, =num_sec;
		ldrb r9, [r12]				@; R9: num_sec
		.LwhileFila69:
			cmp r2, r6
			bge .LfiwhileFila69
			.LwhileColum69:
				cmp r3, r7
				bge .LfiwhileColum69
				sub r10, r6, #1				@; R10: fila-1;
				cmp r2, r10
				bge .Lfinwhile33
				mul r12, r2, r7				@; R12: fila per a coordena
				add r11, r3, r12			@; R11: coordena matriz_marcas
				ldrb r12, [r0, r11]			@; R12: veu que hi ha a la matriz_marcas en coordena R11
				cmp r12, #7
				beq .Lfinwhile33
				cmp r12, #15				@; si a la casella hi ha un 7 o 15 saltem al final
				beq .Lfinwhile33
				mov r11, r1					@; R11: guardem matriz_marcas
				mov r1, r2					@; R1: pasa a ser FILA
				mov r2, r3					@; R2: pasa a ser COLUMNA
				mov r3, #1					@; R3: pasa a ser l'orientacio de cuenta_repeticiones Sur
				mov r12, r0					@; R12: guardem matriz_base 
				bl cuenta_repeticiones		@; retorna a R0 número de repeticiones detectadas (mínimo 1)
				mov r8, r0					@; R8: arreplega el valor retornat
				mov r0, r12					@; R0: recupera matriz
				mov r3, r2					@; R3: torna a ser COLUMNA
				mov r2, r1					@; R2: torna a ser FILA
				mov r1, r11					@; R1: torna a ser matriz_marcas
				cmp r8, #3
				blt .Lfinwhile33
				mov r4, r8					@; R4: guarda num_rep
				mov r5, #0					@; R5: combi (detecta si hi ha alguna combinació);
				push {r4}					@; Lliberem registres
				.Lwhileprova:
					cmp r8, #0
					beq .Lfinwhileprova
					sub r8, #1				@; num_rep--;
					mul r12, r2, r7			@; fila per a coordena
					mul r4, r8, r7			@; num_rep per a coordena
					add r11, r12, r4
					add r11, r3				@; R11: coordena[f+num_rep-1][c];
					ldrb r12, [r1, r11]		@; R12: llig que hi ha a la coordena R11 de la matriz_marcas
					cmp r12, #0
					beq .Lif345
					add r5, #1				@; combi++;
					mov r11, r12			@; R11: num que te la secuencia horitzontal
					b .Lfinwhileprova
					.Lif345:
						b .Lwhileprova
				.Lfinwhileprova:
				pop {r4}
				mov r8, r4					@; R8: recupera num_rep guardat anteriorment
				mov r4, r11					@; R4: num_sec_horitzontal
				cmp r5, #0
				ble .Lif24
					.Lwhilecombi:
						cmp r8, #0
						beq .Lfinwhile33
						sub r8, #1				@; num_rep--;
						mul r12, r2, r7			@; R12: fila per a coordena
						mul r5, r8, r7
						add r11, r12, r5
						add r11, r3				@; R11: coordena []f+num_rep-1][c];
						strb r4, [r1, r11]		@; guarda R4 en la matriz de marca a al posició R11
						b .Lwhilecombi
				.Lif24:
					add r9, #1					@; num_sec++;
					.Lwhile33:
						cmp r8, #0
						beq .Lfinwhile33
						sub r8, #1				@; num_repeticions--;
						mul r12, r2, r7			@; R12: fila per a coordena
						mul r5, r8, r7
						add r11, r12, r5
						add r11, r3				@; R11: coordena [f+num_rep-1][c];
						strb r9, [r1, r11]		@; guarda R9 en la matriz de marca a la posició R11
						b .Lwhile33
				.Lfinwhile33:
				add r3, #1
				b .LwhileColum69
			.LfiwhileColum69:
			add r2, #1
			mov r3, #0
			b .LwhileFila69
		.LfiwhileFila69:
		pop {r2-r12, pc}



.end
