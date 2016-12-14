@;=                                                         	      	=
@;=== candy1_move: rutinas para contar repeticiones y bajar elementos ===
@;=                                                          			=
@;=== Programador tarea 1E: aleix.marine@estudiants.urv.cat			  ===
@;=== Programador tarea 1F: aleix.marine@estudiants.urv.cat			  ===
@;=                                                         	      	=



.include "../include/candy1_incl.i"



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1E;
@; cuenta_repeticiones(*matriz,f,c,ori): rutina para contar el número de
@;	repeticiones del elemento situado en la posición (f,c) de la matriz, 
@;	visitando las siguientes posiciones según indique el parámetro de
@;	orientación 'ori'.
@;	Restricciones:
@;		* sólo se tendrán en cuenta los 3 bits de menor peso de los códigos
@;			almacenados en las posiciones de la matriz, de modo que se ignorarán
@;			las marcas de gelatina (+8, +16)
@;		* la primera posición también se tiene en cuenta, de modo que el número
@;			mínimo de repeticiones será 1, es decir, el propio elemento de la
@;			posición inicial
@;	Parámetros:
@;		R0 = dirección base de la matriz
@;		R1 = fila 'f'
@;		R2 = columna 'c'
@;		R3 = orientación 'ori' (0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte)
@;	Resultado:
@;		R0 = número de repeticiones detectadas (mínimo 1)
@;  Variables associades a registres:
@;  	r4 = repeticions de l'element
@;		r5 = tres bits de menys pes del primer element
@;		r6 = Apuntador-> matriu + (i*COLUMNS+j)
@;		r7 = tres bits de menys pes de l'element actual

	.global cuenta_repeticiones
cuenta_repeticiones:
		push {r1-r11,lr}
		@;Seccio ENTRADA
		mov r4, #1 					@;r4: repeticions de l'element=1
		mov r10, #COLUMNS 			@;r10 registre temporal per a guardar el valor de la constant COLUMNS
		mla r7, r1, r10, r2 		@;Obtenim a r7 i*COLUMNS + j
		add r6, r7, r0 				@;Obtenim a r6 i*COLUMNS+j+@matriu, obtenint la direcció a la que apunta el primer element
		ldrb r8, [r6]				@;Carreguem a registres el contingut de la posició actual de la matriu
		and r5, r8, #0x00000007		@;Fem una màscara, posant tots els bits a 0 excepte els 3 ultims que mantindran el seu valor a r5
		cmp r3, #1					@;comparem ori amb 1
		bgt .Mesgran				@;si es mes gran es 2 o 3 ves a mes gran
		beq .Sud					@;Si es 1 vol dir que ori es sud  i ves a sud
		@;Seccio EST
		.Est:
		mov r11, #COLUMNS
		sub r11, #1
		cmp r2, r11					@;Comparem amb COLUMNS
		bge .Exit					@;Si es mes gran o igual ves a la seccio de sortida
		add r6, #1 					@;Passem al següent element
		add r2, #1					@;Modifiquem l'index sumant 1
		ldrb r8, [r6]				@;Carreguem a r8 el contingut de memoria al que apunta r6 (següent element)
		and r7, r8, #0x00000007		@;Tres bits de menys pes de l'element actual
		cmp r5, r7					@;Comparem els tres bits de menys pes de l'element actual amb el primer element
		bne .Exit					@;Si son diferents ves a la seccio exit
		add r4, #1					@;Afegeix repeticio perque son iguals
		b .Est
		.Sud:
		@;Seccio SUD
		mov r11, #ROWS
		sub r11, #1
		cmp r1, r11					@;Comparem amb ROWS
		bge .Exit					@;Si es mes gran o igual ves a la seccio de sortida
		mov r8, #COLUMNS			@;Carreguem el valor de COLUMNS a r8
		add r6, r8		 			@;Passem al següent element
		add r1, #1					@;Modifiquem l'index sumant 1
		ldrb r8, [r6]				@;Carreguem a r8 el contingut de memoria al que apunta r6 (següent element)
		and r7, r8, #0x00000007		@;Tres bits de menys pes de l'element actual a r7
		cmp r5, r7					@;Comparem els tres bits de menys pes de l'element actual amb el primer element
		bne .Exit					@;Si son diferents ves a la seccio exit
		add r4, #1					@;Afegeix repeticio perque son iguals
		b .Sud						@;Torna a començar el bucle de recorregut
		.Mesgran:
		cmp r3, #2
		beq .Oest
		@;Seccio NORD
		.Nord:
		cmp r1, #0					@;Comparem amb 0
		ble .Exit					@;Si es mes petit o igual ves a la seccio de sortida
		mov r8, #COLUMNS			@;Carreguem el valor de COLUMNS a r8
		sub r6, r8					@;Passem al següent element
		sub r1, #1					@;Modifiquem l'index restant 1
		ldrb r8, [r6]				@;Carreguem a r8 el contingut de memoria al que apunta r6 (següent element)
		and r7, r8, #0x00000007		@;Tres bits de menys pes de l'element actual a r7
		cmp r5, r7					@;Comparem els tres bits de menys pes de l'element actual amb el primer element
		bne .Exit					@;Si son diferents ves a la seccio exit
		add r4, #1					@;Afegeix repeticio perque son iguals
		b .Nord						@;Torna a començar el bucle de recorregut
		.Oest:
		@;Seccio OEST
		cmp r2, #0
		ble .Exit
		sub r6, #1 					@;Passem al següent element
		sub r2, #1					@;Modifiquem l'index restant 1
		ldrb r8, [r6]				@;Carreguem a r8 el contingut de memoria al que apunta r6 (següent element)
		and r7, r8, #0x00000007		@;Tres bits de menys pes de l'element actual
		cmp r5, r7					@;Comparem els tres bits de menys pes de l'element actual amb el primer element
		bne .Exit					@;Si son diferents ves a la seccio exit
		add r4, #1					@;Afegeix repeticio perque son iguals
		b .Oest
		@;Seccio EXIT El programa sempre acabara aqui, per tant fem les operacions pertinents de sortida
		.Exit:
		mov r0, r4
		pop {r1-r11, pc}



@;TAREA 1F;
@; baja_elementos(*matriz): rutina para bajar elementos hacia las posiciones
@;	vacías, primero en vertical y después en sentido inclinado; cada llamada a
@;	la función sólo baja elementos una posición y devuelve cierto (1) si se ha
@;	realizado algún movimiento, o falso (0) si está todo quieto.
@;	Restricciones:
@;		* para las casillas vacías de la primera fila se generarán nuevos
@;			elementos, invocando la rutina 'mod_random' (ver fichero
@;			"candy1_init.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica se ha realizado algún movimiento, de modo que puede que
@;				queden movimientos pendientes. 
	.global baja_elementos
baja_elementos:
		push {r4, lr}
		mov r4, r0
		.b:
		bl baja_verticales
		cmp r0, #1
		beq .end
		bl baja_laterales
		.end:
		pop {r4, pc}



@;:::RUTINAS DE SOPORTE:::



@; baja_verticales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en vertical; cada llamada a la función sólo baja elementos una posición y
@;	devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento. 
@;	Variables associades a registres
@;		r0 = registre de treball de rutina mod_random parametres/sortida
@;		r1 = fila
@;		r2 = columna
@;		r3 = apuntador de posicio actual
@;		r4 = direccio base matriu de joc
@;		r5 = temporal
@;		r6 = apuntador de posicio en un tractamentc
@;		r8 = contingut de la posicio a tractar (sera 0, 8 o 16)
@;		r9 = Codi de tipus de la gelatina
@; 		r10 = emmagatzema si hi ha hagut moviments (r0 esta en ús tota l'estona per mod random)
baja_verticales:
		push {r1-r11, lr}
		@;add r4, #COLUMNS				Factor de correcció: La vista de la nds i la posicio en memoria de la matriu es troben desplaçades una fila
		mov r10, #0						@;No haurem fet cap moviment fins que no es faci el contrari
		mov r1, #ROWS					@;Carreguem index files
		mov r2, #COLUMNS				@;Carreguem index columnes				
		mla r3, r1, r2, r4				@;Anem a l'ultima posicio per tant, els index son els valors de les constants
		sub r3, #1						@;Restem 1 per a ajustar (sen va una casella mes enlla de lultima posicio de la matriu)
		sub r1, #1						@;fase 2IC:Restem 1 per a ajustar l'index (0-ROWS-1)
		sub r2, #1						@;fase 2IC:Restem 1 per a ajustar l'index (0-COLUMNS-1)
		@;BUCLE DE RECORREGUT DE LA MATRIU
		.whilemove: 				
		ldrb r8, [r3]					@;Carreguem a r8 el contingut de la posicio actual
		cmp r1, #0						@;Mira si es la primera fila				
		beq .primerafila				@;tracta primera fila
		.segueix:
		and r11, r8, #7					@;Netegem bits de tipus
		cmp r11, #0						@;Comparem bits de menys pes amb 0
		bne .notractes					@;Salta al final del while si l'element no es buit (passem a la seguent cel.la)
		b .tractar						@;Sino tractem l'element 
		@;SECCIO PRIMERA FILA (ELEMENTS A 0 PRIMERA FILA)
		.primerafila:
		mov r7, r3						@;Guardem la posicio en la que estem
		mov r5, r1						@;fase 2IC: Utilitzem el temporal r5 per a poder calcular la fila on s'ha de crear l'sprite
		.bucle:
		cmp r8, #15						@;Comparem amb 15
		addeq r7, #COLUMNS				@;Desplacem cap a baix
		addeq r5, #1					@;fase 2IC: sumem 1 per a actualitzar l'index
		ldrb r8, [r7]					@;Carreguem contingut de la posicio de mes avall (o la mateixa si no hem trobat huecos)
		cmp r8, #15						@;Compara amb 15
		beq .bucle						@;Segueix baixant si trobes 15
		and r11, r8, #7					@;corregeix bits
		cmp r11, #0						@;Compara amb 0
		bne .notractes					@;si no es element buit surt...
		@;I sino hauras de generar nun aleatori
		mov r0, #6						@;Li passem un 6 a la rutina mod random
		bl mod_random					@;Cridem mod random (genera aleatori entre 0 i 5)
		add r0, #1						@;Sumem 1 per a corregir 
		
		push {r0-r2}						@;fase 2IC: Salvem estat del registre r1
		mov r1, r5						@;fase 2IC: movem la fila on s'ha de crear l'sprite a r1 per a passar els paràmetres
		bl crea_elemento				@;fase 2IC:	generacio del sprite (es passa per r0=tipus de gelatina, r1=fila, r2=columna)	
		pop {r0-r2}						@;fase 2IC: Recuperem estat del registre r1
		
		add r8, r0						@;Sumem la gelatina que hi havia (que sera 0, 8 o 16) al aleatori corresponent
		strb r8, [r7]					@;Guardem l'element generat a la posicio que li toca
		mov r10, #1						@;Sortida de parametres
		b .notractes					@;Sortim d'aquesta seccio per a avançar
		@;SECCIO ELEMENT BUIT
		.tractar:
		mov r5, r1						@;fase 2IC: Utilitzem el temporal r5 per a poder calcular la fila origen (paràmetre de activa_elemento)
		mov r6, r3						@;Salvem la posicio tractada a r6					
		.whiletractar:					@;Bucle de tractament
		sub r6, #COLUMNS				@;restem el valor de columnes per accedir a la casella superior
		sub r5, #1						@;fase 2IC: Restem 1 a l'index
		@;cmp r5, #-1						@;fase 2IC: Si la fila es -1, hem sortit de la matriu. Seria codi de la primera part pero l'etiqueto com a seeegona part per si dona problemes
		@;beq .notractes					@;fase 2IC: Per tant si es -1 avança al següent element
		ldrb r8, [r6]					@;Carreguem a r8 el contingut de la casella superior
		cmp r8, #15						@;Si hi ha un "hueco"...
		beq .whiletractar				@;...pugem una casella mes
		cmp r8, #7						@;Mirem si hi ha un bloc fixe
		beq .notractes					@;I sortim si n'hi ha un
		and r9, r8, #7					@;mascara de bits
		cmp r9, #0						@;Si es un element buit llavors... 
		beq .notractes					@;...sortim
		sub r12, r8, r9					@;i sino a la casella superior li treiem els bits de tipus
		strb r12, [r6]					@;Guarda els bits de gelatina a la posicio on era (hem eliminat els de tipus) per tant quedara a 0, 8 o 16
		ldrb r11, [r3]					@;Carreguem a r11 gelatina a tractar que sera 0, 8 o 16
		add r6, r11, r9					@;Suma bits de la casella a tractar mes el tipus de la que baixa
		
		push {r0-r4}					@;fase 2IC: salvem estat del resgistres per a la passada de parametres
		mov r0, r5 						@;fase 2IC: r0=fila origen
		mov r4, r1						@;fase 2IC: Salvo el valor de fila destí
		mov r1, r2						@;fase 2IC: r1=columna origen
		mov r3, r2						@;fase 2IC: r3=columna destí (serà la mateixa que la origen degut a que es un desplaçament vertical)
		mov r2, r4						@;fase 2IC: r2=fila destí
		bl activa_elemento				@;fase 2IC: fila origen, columna origen, fila destí, columna destí	
		pop {r0-r4}						@;fase 2IC: recuperem estat del resgistres
		
		strb r6, [r3]					@;Guardaho a la casella tractada (la inferior)
		mov r10, #1						@;Hem fet moviment per tant...
		@;SECCIO AVANÇAR/TRACTAMENT D'INDEX
		.notractes:
		sub r3, #1						@;Restem 1, com que les matrius en ARM són en realitat taules podem desplaçarnos restant 1 fins que l'element actual sigui la posicio base de la matriu
		cmp r2, #0						@;Comprovem que l'index de columna no ha arribat a 0
		bne .canvicolumna				@;Si no ha arribat a 0 canvia la columna
		cmp r1, #0						@;si ha arribat a 0, Comparo fila amb 0
		beq .Surt						@;i si tot es 0 ves a la sortida perque ja hem recorregut la matriu
		mov r2, #COLUMNS				@;Si nomes la columna es 0, tornem a carregar el maxim numero de columnes...
		sub r2, #1
		sub r1, #1						@;...restem una fila i 
		b .whilemove					@;passem a la següent cel·la...
		.canvicolumna:
		sub r2, #1						@;Resta 1 a columnes si encara no ha arribat a 0
		b .whilemove					@;i passa a la següent cel·la...
		.Surt:
		mov r0, r10						@;Sortida de parametres
		pop {r1-r11, pc}



@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en diagonal; cada llamada a la función sólo baja elementos una posición y
@;	devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento. 
@;	Registres associats a variables
@;		r0 = registre utilitzat per la sortida de mod random
@;		r1 = index fila
@;		r2 = index columna
@;		r3 = apuntador a posicio actual de la matriu
@;		r4 = direccio base de la matriu 
@;		r5 = apuntador a posicio de tractament de la matriu
@;		r6 = contingut de posicio a tractar
@;		r7 = bits de menys pes de la posicio a tractar
@;		r8 = valor de la posicio que sha de moure
@;		r9 = Flag de posicio posible
@;		r10= resultat de la funcio
baja_laterales:
		push {r0-r10, lr}
		mov r1, #ROWS				@;Carreguem index fila
		mov r2, #COLUMNS			@;Carreguem index columna	
		mov r10, #0					@;No haurem fet cap moviment fins que no es faci el contrari
		mla r3, r1, r2, r4			@;Apuntem a la primera posicio valida de la matriu
		sub r3, #1					@;restem 1 per a corregir
		.buclewhile:
		ldrb r6, [r3]				@;Carreguem contingut a r6
		and r7, r6, #7				@;bit clear
		cmp r7, #0					@;Comparem amb 0
		bne .passaseguent			@;Passem al següent element
		mov r9, #0					@;posem flag a 0
		@;Caselles de lesquerra
		cmp r2, #1					@;mira si estas al limit esquerra de la matriu
		beq .comprovadret			@;Si estas al limit de la matriu passa a dret directament
		sub r5, r3, #COLUMNS		@;Restar columnes
		sub r5, r5, #1				@;restem 1 per a ajustar
		ldrb r8, [r5]				@;Carregar a r8 el contingut de la posicio que sha de moure
		and r8, r8, #7				@;filtrem bits
		cmp r8, #7					@;comparem amb 7
		beq .comprovadret			@;si no pots comprova lelement de la dreta
		cmp r8, #0					@;compara amb el 0 per a saber si lelement esta buit
		addne r9, r9, #1			@;Afegeix al flag un 1
		.comprovadret:
		cmp r2, #COLUMNS			@;mira si estas al limit dret de la matriu
		beq .fi						@;tractem l'element esquerra
		sub r5, r3, #COLUMNS		@;Restar columnes
		add r5, r5, #1				@;Afegim 1 a l'index per 
		ldrb r8, [r5]				@;carrega la posicio de la dreta
		and r8, r8, #7				@;filtrem bits
		cmp r8, #7					@;comparem amb 7 
		beq .fi						@;si no pots ves al fi
		cmp r8, #0					@;compara amb el 0 per a saber si lelement esta buit
		addne r9, r9, #2			@;Afegeix dos al flag
		.fi:
		cmp r9, #1					@;Compara amb un 1 el flag
		beq .Esquerra				@;Si 1 es pot baixar l'esquerra
		cmp r9, #2					@;Compara amb 2 el flag
		beq .Dreta					@;Si 2 es pot baixar el dret
		cmp r9, #0					@;Compara amb 0 el flag
		beq .passaseguent			@;passa al seguent si no hi ha cap element susceptible de per baixat
		@;SECCIO D'ELECCIO ALEATORIA
		@; Llavors el flag es 9 i podem baixar pels dos llocs, per tant generem laleatori
		mov r0, #1					@;Carreguem un 1 a r0 (per a passar parametre)
		bl mod_random				@;cridem mod random
		cmp r0, #0					@;Si no es 0			
		bne .Dreta					@;Anem a la dreta arbitrariament
		@;SECCIO ESQUERRA
		.Esquerra:
		
		push {r0-r3}				@;Funcio I
		mov r0, r1
		mov r1, r2
		add r2, r0, #1
		sub r3, r1, #1
		bl activa_elemento
		pop {r0-r3}
		
		sub r5, r3, #COLUMNS		@;Restar columnes
		sub r5, #1					@;restem 1 per a ajustar
		ldrb r8, [r5]				@;Carregar a r8 el contingut de la posicio que sha de moure
		and r9, r8, #24				@;Bit clear
		strb r9, [r5]				@;Guarda els bits de mes pes on estaven
		sub r8, r8, r9				@;obte el codi de menor pes
		add r9, r8, r6				@;Carrega a r9 el contingut de la posicio actual (sera 0, 8 o 16) mes el codi de  menys pes
		strb r9, [r3]				@;Guarda a la posicio actual
		mov r10, #1					@;Passada de parametres
		b .passaseguent				@;Sortim
		@;SECCIO DRETA
		.Dreta:
		
		push {r0-r3}				@;Funcio I
		mov r0, r1
		mov r1, r2
		add r2, r0, #1
		add r3, r1, #1
		bl activa_elemento
		pop {r0-r3}
		
		sub r5, r3, #COLUMNS		@;Restar columnes
		add r5, r5, #1				@;sumem 1 per a ajustar
		ldrb r8, [r5]				@;Carregar a r8 el contingut de la posicio que sha de moure
		and r9, r8, #24				@;Bit clear
		strb r9, [r5]				@;Guarda els bits de mes pes on estaven
		sub r8, r8, r9				@;obte el codi de menor pes
		add r9, r8, r6				@;Carrega a r9 el contingut de la posicio actual (sera 0, 8 o 16) mes el codi de  menys pes
		strb r9, [r3]				@;Guarda a la posicio actual
		mov r10, #1					@;Passada de parametres
		@;SECCIO AVANÇAR/TRACTAMENT D'INDEX
		.passaseguent:
		sub r3, r3, #1					@;restem 1 per decrementar lindex
		cmp r2, #1						@;Comprovem que l'index de columna no ha arribat a 1
		bne .passacolumna				@;Si no ha arribat a 1 canvia la columna
		cmp r1, #2						@;si ha arribat a 1, Comparo fila amb 2
		beq .Sortir						@;i si tot es el limit ves a la sortida perque ja hem recorregut la matriu
		mov r2, #COLUMNS				@;Si nomes la columna es 1, tornem a carregar COLUMNS a columnes...
		sub r1, r1, #1					@;...restem una fila una fila i 
		b .buclewhile					@;passem a la següent cel·la...
		.passacolumna:
		sub r2 ,r2, #1					@;suma 1 a columnes si encara no ha arribat a 1
		b .buclewhile					@;i passa a la següent cel·la...
		.Sortir:
		mov r0, r10	
		pop {r0-r10,pc}


@;:::RUTINAS DE SOPORTE:::



@; mod_random(n): rutina para obtener un número aleatorio entre 0 y n-1,
@;	utilizando la rutina 'random'
@;	Restricciones:
@;		* el parámetro 'n' tiene que ser un valor entre 2 y 255, de otro modo,
@;		  la rutina lo ajustará automáticamente a estos valores mínimo y máximo
@;	Parámetros:
@;		R0 = el rango del número aleatorio (n)
@;	Resultado:
@;		R0 = el número aleatorio dentro del rango especificado (0..n-1).global mod_random
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
		
		
		
@;random(): rutina para obtener un número aleatorio de 32 bits, a partir de
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

