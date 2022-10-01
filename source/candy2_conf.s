@;=                                                        				=
@;=== candy2_conf: variables globales de configuraci�n del juego  	  ===
@;=                                                       	        	=
@;=== autor: Santiago Roman� 	(2014-10-06)					  	  ===
@;=                                                       	        	=


@;-- .data. variables (globales) inicializadas ---
.data
		.align 2


@; l�mites de movimientos para cada nivel;
@;	los l�mites corresponder�n a los niveles 0, 1, 2, ..., hasta MAXLEVEL-1
@;								(MAXLEVEL est� definida en "include/candy1.h")
@;	cada l�mite debe ser un n�mero entre 3 y 99.
		.global max_mov
	max_mov:	.byte 20, 27, 11, 25, 24, 20, 21, 30, 25, 10


@; objetivo de puntos para cada nivel;
@;	si el objetivo es cero, se supone que existe otro reto para superar el
@;	nivel, por ejemplo, romper todas las gelatinas.
@;	el objetivo de puntos debe ser un n�mero menor que cero, que se ir�
@;	incrementando a medida que se rompan elementos.
		.align 2
		.global pun_obj
	pun_obj:	.word -1000, -330, -500, 0, -240, -500, -200, -900, -10, -10



@; mapas de configuraci�n de la matriz;
@;	cada mapa debe contener tantos n�meros como posiciones tiene la matriz,
@;	con el siguiente significado para cada posicion:
@;		0:		posici�n vac�a (a rellenar con valor aleatorio)
@;		1-6:	elemento concreto
@;		7:		bloque s�lido (irrompible)
@;		8+:		gelatinas simple (a sumarle c�digo de elemento)
@;		16+:	gelatina doble (a sumarle c�digo de elemento)
		.global mapas
	mapas:

	@; mapa 0: todo aleatorio
		.byte 0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0

	@; mapa 1: paredes horizontales y verticales
		.byte 0,0,7,7,0,0,0,0
		.byte 0,0,0,0,0,0,0,0
		.byte 0,7,7,7,7,7,0,0
		.byte 0,7,0,0,0,0,0,0
		.byte 0,7,0,0,0,7,7,7
		.byte 0,7,0,0,0,0,0,0

	@; mapa 2: huecos y bloques s�lidos
		.byte 15,15,7,15,0,0,0,0
		.byte 0,15,15,7,15,0,0,0
		.byte 0,0,0,0,0,15,0,0
		.byte 0,0,0,0,0,0,7,7
		.byte 0,0,0,0,2,1,2,15
		.byte 15,0,15,15,1,2,1,1
	
	@; mapa 3: gelatinas simples
		.byte 0,0,0,8,8,8,0,0
		.byte 0,0,0,0,8,0,0,0
		.byte 0,0,8,8,8,8,0,0
		.byte 0,0,8,0,8,0,0,0
		.byte 0,0,8,0,8,0,0,0
		.byte 0,0,8,0,8,0,0,0

	@; mapa 4: gelatinas dobles
		.byte 0,15,0,15,0,7,0,15
		.byte 0,0,7,0,0,7,0,0
		.byte 10,3,8,1,1,8,3,3
		.byte 10,1,9,0,0,20,3,4
		.byte 17,2,15,15,3,19,4,3
		.byte 3,2,10,0,0,20,0,15

	@; mapa 5: combinaciones en horizontal de 3, 4 y 5 elementos
		.byte 1,1,1,15,2,2,2,2
		.byte 3,3,3,3,3,15,7,7
		.byte 4,1,4,4,4,4,15,7
		.byte 1,4,4,2,6,3,7,0
		.byte 5,2,2,15,5,5,5,5
		.byte 6,5,5,2,5,6,6,6

	@; mapa 6: combinaciones en vertical de 3, 4 y 5 elementos
		.byte 1,3,4,1,5,6,2,15
		.byte 1,3,1,4,2,5,7,15
		.byte 1,3,4,4,2,5,15,7
		.byte 2,3,4,2,6,15,2,7
		.byte 2,3,4,15,6,6,5,7
		.byte 2,7,4,3,5,15,6,7

	@; mapa 7: combinaciones cruzadas (hor/ver) de 5, 6 y 7 elementos
		.byte 1,2,3,3,4,3,7,0
		.byte 1,2,7,5,3,7,7,0
		.byte 4,1,1,2,3,16,7,0
		.byte 1,4,4,2,6,3,7,0
		.byte 4,2,2,5,2,2,7,0
		.byte 4,5,5,2,5,5,7,0
		
	@; mapa 8: no hay combinaciones ni secuencias
		.byte 1,2,3,3,7,3,15,15
		.byte 1,2,7,5,3,7,15,15
		.byte 7,1,1,2,3,9,15,15
		.byte 1,4,20,10,9,6,15,15
		.byte 6,18,22,5,6,2,15,15
		.byte 12,5,4,3,11,5,15,15
		
	@; mapa 9: no hay combinaciones
		.byte 1,2,3,4,5,6,1,2
		.byte 2,3,4,5,6,1,2,3
		.byte 3,4,5,6,1,2,3,4
		.byte 4,5,6,1,2,3,4,5
		.byte 5,6,1,2,3,4,5,6
		.byte 6,1,2,3,4,5,6,1

	@; etc.



.end
	
