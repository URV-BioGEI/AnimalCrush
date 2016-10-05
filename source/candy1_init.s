@;=                                                          	     	=
@;=== candy1_init.s: rutinas para inicializar la matriz de juego	  ===
@;=                                                           	    	=
@;=== Programador tarea 1A: cristina.izquierdo@estudiants.urv.cat				  ===
@;=== Programador tarea 1B: cristina.izquierdo@estudiants.urv.cat				  ===
@;=                                                       	        	=



.include "../include/candy1_incl.i"



@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
@; matrices de recombinación: matrices de soporte para generar una nueva matriz
@;	de juego recombinando los elementos de la matriz original.
	mat_recomb1:	.space ROWS*COLUMNS
	mat_recomb2:	.space ROWS*COLUMNS



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1A;
@; inicializa_matriz(*matriz, num_mapa): rutina para inicializar la matriz de
@;	juego, primero cargando el mapa de configuración indicado por parámetro (a
@;	obtener de la variable global 'mapas'), y después cargando las posiciones
@;	libres (valor 0) o las posiciones de gelatina (valores 8 o 16) con valores
@;	aleatorios entre 1 y 6 (+8 o +16, para gelatinas)
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocará la rutina
@;			'mod_random'
@;		* para evitar generar secuencias se invocará la rutina
@;			'cuenta_repeticiones' (ver fichero "candy1_move.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = número de mapa de configuración  ---> indice de fila
@;	Registres:
@;		R2 = indice columna
@;		R3 = backup numero del numero de mapa de configuracion
@;		R4 = backup de la direccion base se la matriz
@;		R5 = valor casella + valor random --> guardar matriu de joc
@;		R6 = puntero
@;		R7 = mapas
@;		R8 = valor casilla

	.global inicializa_matriz
inicializa_matriz:
		push {r0-r8, lr}			@;guardar registros utilizados
		
		mov r4, r0					@;backup de la direccion base de la matriz
		mov r3, r1					@;backup del numero de mapa de configuracio
		
		ldr r7, =mapas				@;carreguem els mapes
		mov r5, #COLUMNS			@;total columnes a r5 
		mov r1, #ROWS				@;total files a r1
		mul r8, r5, r1				@;multipliquem files per columnes
		mul r8, r3					@;passem el numero de mapa de configuracio
		add r7, r8					@;accedim al mapa
		
		mov r6, #0					@;inicializamos puntero
		mov r1, #0					@;inicializamos filas
	.L_buclefilas:
		mov r2, #0					@;inicializamos columnas
	.L_buclecol:
		ldrb r8, [r7, r6]			@;R8 = valor casilla (r1, r2)
		
		cmp r8, #0					@;comparamos con objeto variable
		beq	.L_buclerandom			@;si es variable saltamos al bucle random
		cmp r8, #8
		beq .L_buclerandom
		cmp r8, #16
		beq .L_buclerandom
		
		b .L_final					@;si es un objecte fixe, passem a la seguent casella
		
	.L_buclerandom:					@;bucle per asignar un numero aleatori, si forma un combinacio de 3, es busca un altre numero
		mov r5, #0					@;netegem el temporal
		mov r0, #6					@;li passem el maxim de rang aleatori
		bl mod_random				@;cridem a la funcio random
		add r0, #1					@;li sumem 1 per a que no surti cap 0
		add r5, r8, r0				@;al temporal r5 guardo el valor de la seva posicio mes el valor random que hem obtingut
		mov r0, r4					@;recuperem la direccio base per passar-li al cuenta_repeticiones
		mov r3, #2					@;i li passem la direccio (oest) a r3
		strb r5, [r4, r6]			@;copio a la matriu de joc
		bl cuenta_repeticiones	
		cmp r0, #3					@;comprovar que no formi una repeticio de 3
		bge .L_buclerandom			@;torna a repetir el bucle si forma repeticio
		@;ara fem el mateix pero per la direcico nord
		mov r0, r4					@;tornem a posar a r0 la direccio base
		mov r3, #3					@;i li passem la direccio (nord) a r3
		bl cuenta_repeticiones	 
		cmp r0, #3					@;comprovar que no formi una repeticio de 3
		bge .L_buclerandom			@;torna a repetir el bucle si forma repeticio
	.L_final:
		@;si no forma cap repeticio, anem a la seguent posicio
		add r6, #1					@;avanza posicion
		add r2, #1					@;avanza columna
		cmp r2, #COLUMNS			@;comprueba que no sea el final de la fila
		blo .L_buclecol				@;sino esta al final, avanza al siguiente elemento
		@;si esta al final de columna:
		add r1, #1					@;avanza fila
		cmp r1, #ROWS				@;comprueba que no sea el final de columna
		blo .L_buclefilas			@;si no esta al final, avanza al siguiente elemento
		
		pop {r0-r8, pc}				@;recuperar registros y volver



@;TAREA 1B;
@; recombina_elementos(*matriz): rutina para generar una nueva matriz de juego
@;	mediante la reubicación de los elementos de la matriz original, para crear
@;	nuevas jugadas.
@;	Inicialmente se copiará la matriz original en 'mat_recomb1', para luego ir
@;	escogiendo elementos de forma aleatoria y colocandolos en 'mat_recomb2',
@;	conservando las marcas de gelatina.
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocará la rutina
@;			'mod_random'
@;		* para evitar generar secuencias se invocará la rutina
@;			'cuenta_repeticiones' (ver fichero "candy1_move.s")
@;		* para determinar si existen combinaciones en la nueva matriz, se
@;			invocará la rutina 'hay_combinacion' (ver fichero "candy1_comb.s")
@;		* se supondrá que siempre existirá una recombinación sin secuencias y
@;			con combinaciones
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Regitres:
@;		R1 = índice de fila
@;		R2 = índice de columna
@;		R3 = valor casella matriu
@;		R4 = backup de la direccion base de la matriz
@;		R5 = temporal
@;		R6 = puntero
@;		R7 = mat_recomb1
@;		R8 = mat_recomb2
@;		R9 = contador de iteracions
@;		R10= puntero per saber la posicio aleatoria de mat_recomb1 creada
@;		R11= temporal
	.global recombina_elementos
recombina_elementos:
		push {r0-r11, lr}
		
		mov r4, r0					@;backup de la direccio base de la matriu
		ldr r7, =mat_recomb1		@;carreguem mat_recomb1
		ldr r8, =mat_recomb2		@;carreguem mat_recomb2
		@;recorrer matriu de joc:
		
	.L_inicialMJOC:
		
		mov r6, #0					@;inicializamos puntero
		mov r1, #0					@;inicializamos filas
	.L_buclefilasMJOC:
		mov r2, #0					@;inicializamos columnas
		mov r3, #COLUMNS			@;guardem al temporal r3 el maxim de columnes
		mul r3, r1, r3				@;r3=index files x columnes
	.L_buclecolMJOC:
		add r6, r3, r2				@;preparamos puntero
		ldrb r3, [r4, r6]			@;R3 = valor casilla (r1, r2) matriu de joc
		
		cmp r3, #0					@;si es un espai buit
		beq .L_copiar2				@;el copiem directament a mat_recomb2
		cmp r3, #7					@;si es un bloc solid
		beq .L_copiar2				@;el copiem directament a mat_recomb2 i a mat_recomb1
		cmp r3, #15					@;si es un hueco
		beq .L_copiar2				@;el copiem directament a mat_recomb2 i a mat_recomb1
		
		b .L_finalMJOC				@;Per si un cas no es cap d'aquests casos, passem a la seguent casella
		
		mov r5, r3, lsr#3			@;movem al temporal el valor dels dos primers bits de la casella (els bits de tipus)
		and r5, #0x03				@;fem una màscara per a poder comparar directament els dos bits
		cmp r5, #8					@;comparem amb una gelatina simple
		beq .L_gelsimple			@;si es simple ho portem al bucle corresponent
		cmp r5, #16					@;comparem amb una gelatina doble
		beq .L_geldoble				@;si es doble ho portem al bucle corresponent
		
		b .L_finalMJOC				@;si no es cap d'aquests casos, passem a la seguent casella
		
	.L_gelsimple:		@;bucle per passar les gelatines simples a mat_recomb1 i mat_recomb2
		mov r5, #8					@;li possem el seu codi base
		strb r7, [r5, r6]			@;passem el codi base de la gelatina simple, en la mateixa posicio, a mat_recomb1
		strb r8, [r5, r6]			@;passem el codi base de la gelatina simple, en la mateixa posicio, a mat_recomb2
		b .L_finalMJOC				@;una vegada finalitza va al bucle final per seguir recorrent la matriu de joc
		
	
	.L_geldoble:		@;bucle per passar les gelatines dobles a mat_recomb1 i mat_recomb2
		mov r5, #16					@;li possem el codi base
		strb r7, [r5, r6]			@;passem el codi base de la gelatina doble, en la mateixa posicio, a mat_recomb1
		strb r8, [r5, r6]			@;passem el codi base de la gelatina doble, en la mateixa posicio, a mat_recomb2
		b .L_finalMJOC				@;una vegada finalitza va al bucle final per seguir recorrent la matriu de joc 
		
	.L_copiar2:			@;bucle per a copiar directament a mat_recomb2
		strb r8, [r3, r6]			@;copio el valor de la matriu de joc a mat_recomb2
		mov r3, #0					@;canviem el valor de un bloc solid (7) o un hueco(15) a 0
		strb r7, [r3, r6]			@;guardem a la mat_recomb1 un 0 en la posicio del bloc solid/hueco
		
	.L_finalMJOC:
		@;si no forma cap repeticio, anem a la seguent posicio
		add r6, #1					@;avanza posicion
		add r2, #1					@;avanza columna
		cmp r2, #COLUMNS			@;comprueba que no sea el final de la fila
		blo .L_buclecolMJOC			@;sino esta al final, avanza al siguiente elemento
		@;si esta al final de columna:
		add r1, #1					@;avanza fila
		cmp r1, #ROWS				@;comprueba que no sea el final de columna
		blo .L_buclefilasMJOC		@;si no esta al final, avanza al siguiente elemento
		
	.L_inicialRECOMB2:
		
		mov r6, #0					@;inicializamos puntero
		mov r1, #0					@;inicializamos filas
	.L_buclefilasRECOMB2:
		mov r2, #0					@;inicializamos columnas
		mov r3, #COLUMNS			@;guardem al temporal r3 el maxim de columnes
		mul r3, r1, r3				@;r3=index files x columnes
	.L_buclecolRECOMB2:
		add r6, r3, r2				@;preparamos puntero
		ldrb r3, [r8, r6]			@;R3 = valor casilla (r1, r2) mat_recomb2
		
	@;caselles que requereixen codi:
		cmp r3, #0					@;comparem el valor de la casella amb un element base
		beq .L_casellarandom		@;buscarem un codi de la mat_recomb1
		cmp r3, #8					@;comparem el valor de la casella amb una gelatina simple
		beq .L_casellarandom		@;buscarem un codi de la mat_recomb1
		cmp r3, #16					@;comparem el valor de la casella amb una gelatina dobles
		beq .L_casellarandom		@;buscarem un codi de la mat_recomb1
		
		b .L_finalRECOMB2			@;per si un cas el codi no coincideix amb cap dels anteriors, passem a la seguent casella
		
		mov r9, #0					@;inicialitzem el contador de interacions, per si un cas es queda en bucle infinit
	.L_casellarandom:
		mov r0, #COLUMNS			@;li passem a mod_random el limit del nombre de columnes
		bl mod_random				@;generem un numero de columna aleatori
		mov r11, r0					@;r11=valor columna random
		@;idem per les files
		mov r0, #ROWS				@;li passem a mod_random el limit del nombre de files
		bl mod_random				@;generem un numero de fila aleatori
		mov r5, r0					@;r5=valor fila random
		mov r0, #COLUMNS			@;fem servir r0 de temporal per guardar el total de columnes
		mla r10, r5, r0, r11		@;r10 = (index fila*columna)+index columna
		ldrb r5, [r7, r10]			@;r5 = valor de mat_recomb1 a la casella aleatoria
	@;hem de sumar el contador abans de tornar a començar el bucle (en cas de que trobem un 0)
		add r9, #1					@;sumem 1 al contador
		cmp r9, #99				@;posem un maxim de iteracions
		beq .L_FINAL				@;terminem el programa si fa masses iteracions (anem directament al final ja que voldra dir que no queden caselles de codi)
		
		cmp r5, #0					@;comparem la casella aleatoria amb 0 (element ja usat)
		beq .L_casellarandom		@;si ja esta usada anem a buscar una altra
		add r5, r3					@;si no esta usada afegim el valor random al codi base
		strb r5, [r8, r6]			@;carreguem el valor random (r5) a mat_recomb2 en la posicio del puntero r6
		mov  r0, r8					@;passem la direccio base de la matriu
		mov r11, r3					@;salvem el valor de r3 al temporal
		mov r3, #2					@;li passem la direccio oest
		bl cuenta_repeticiones		@;anem al cuenta_repeticiones
		mov r3, r11					@;recuperem el valor de r3
		cmp r0, #3					@;comparem amb 3 repeticions
		bge .L_casellarandom		@;tornem a buscar un altre casella random en cas de que trobem una secuencia
		mov r3, #0					@;guardem al temporal 0
		strb r3, [r7, r6]			@;una vez comprobamos que no hay combinacion, guardamos un 0 en la mat_recomb1
		
	.L_finalRECOMB2:
		@;si no forma cap repeticio, anem a la seguent posicio
		add r6, #1					@;avanza posicion
		add r2, #1					@;avanza columna
		cmp r2, #COLUMNS			@;comprueba que no sea el final de la fila
		blo .L_buclecolRECOMB2		@;sino esta al final, avanza al siguiente elemento
		@;si esta al final de columna:
		add r1, #1					@;avanza fila
		cmp r1, #ROWS				@;comprueba que no sea el final de columna
		blo .L_buclefilasRECOMB2	@;si no esta al final, avanza al siguiente elemento
		
	.L_FINAL:
	
		mov r0, r8					@;passem la direccio de la mat_recomb2
		bl hay_combinacion			@;mirem si hi ha alguna combinacio posible
		cmp r0, #0					@;en cas de que no hi hagi cap sequencia possible tornem a fer la funcio
		beq .L_inicialMJOC
	
	@;una vegada tenim la mat_recomb2 finalitzada, la copiem a la matriu de joc
	
		mov r6, #0					@;inicializamos puntero
		mov r1, #0					@;inicializamos filas
	.L_buclefilasFIN:
		mov r2, #0					@;inicializamos columnas
		mov r3, #COLUMNS			@;guardem al temporal r3 el maxim de columnes
		mul r3, r1, r3				@;r3=index files x columnes
	.L_buclecolFIN:
		add r6, r3, r2				@;preparamos puntero
		ldrb r3, [r8, r6]			@;R3 = valor casilla (r1, r2) mat_recomb2
		
		strb r4, [r3, r6]			@;guardem a la matriu de joc el valor de mat_recomb2 a la mateixa posicio
		
	.L_finalFIN:
		@;si no forma cap repeticio, anem a la seguent posicio
		add r6, #1					@;avanza posicion
		add r2, #1					@;avanza columna
		cmp r2, #COLUMNS			@;comprueba que no sea el final de la fila
		blo .L_buclecolFIN			@;sino esta al final, avanza al siguiente elemento
		@;si esta al final de columna:
		add r1, #1					@;avanza fila
		cmp r1, #ROWS				@;comprueba que no sea el final de columna
		blo .L_buclefilasFIN		@;si no esta al final, avanza al siguiente elemento
		
		pop {r0-r11, pc}



@;:::RUTINAS DE SOPORTE:::



@; mod_random(n): rutina para obtener un número aleatorio entre 0 y n-1,
@;	utilizando la rutina 'random'
@;	Restricciones:
@;		* el parámetro 'n' tiene que ser un valor entre 2 y 255, de otro modo,
@;		  la rutina lo ajustará automáticamente a estos valores mínimo y máximo
@;	Parámetros:
@;		R0 = el rango del número aleatorio (n)
@;	Resultado:
@;		R0 = el número aleatorio dentro del rango especificado (0..n-1)
	.global mod_random
mod_random:
		push {r1-r4, lr}

		cmp r0, #2				@;compara el rango de entrada con el mínimo
		bge .Lmodran_cont
		mov r0, #2				@;si menor, fija el rango mínimo
	.Lmodran_cont:
		and r0, #0xff			@;filtra los 8 bits de menos peso
		sub r2, r0, #1			@;R2 = R0-1 (número más alto permitido)
		mov r3, #1				@;R3 = máscara de bits
	.Lmodran_forbits:
		cmp r3, r2				@;genera una máscara superior al rango requerido
		bhs .Lmodran_loop
		mov r3, r3, lsl #1
		orr r3, #1				@;inyecta otro bit
		b .Lmodran_forbits
		
	.Lmodran_loop:
		bl random				@;R0 = número aleatorio de 32 bits
		and r4, r0, r3			@;filtra los bits de menos peso según máscara
		cmp r4, r2				@;si resultado superior al permitido,
		bhi .Lmodran_loop		@; repite el proceso
		mov r0, r4			@; R0 devuelve número aleatorio restringido a rango
		
		pop {r1-r4, pc}



@; random(): rutina para obtener un número aleatorio de 32 bits, a partir de
@;	otro valor aleatorio almacenado en la variable global 'seed32' (declarada
@;	externamente)
@;	Restricciones:
@;		* el valor anterior de 'seed32' no puede ser 0
@;	Resultado:
@;		R0 = el nuevo valor aleatorio (también se almacena en 'seed32')
random:
	push {r1-r5, lr}
		
	ldr r0, =seed32				@;R0 = dirección de la variable 'seed32'
	ldr r1, [r0]				@;R1 = valor actual de 'seed32'
	ldr r2, =0x0019660D
	ldr r3, =0x3C6EF35F
	umull r4, r5, r1, r2
	add r4, r3					@;R5:R4 = nuevo valor aleatorio (64 bits)
	str r4, [r0]				@;guarda los 32 bits bajos en 'seed32'
	mov r0, r5					@;devuelve los 32 bits altos como resultado
		
	pop {r1-r5, pc}	



.end
