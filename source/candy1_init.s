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
	.global recombina_elementos
recombina_elementos:
		push {lr}
		
		
		pop {pc}



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
