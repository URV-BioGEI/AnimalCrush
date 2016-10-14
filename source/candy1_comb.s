@;=                                                               		=
@;=== candy1_combi.s: rutinas para detectar y sugerir combinaciones   ===
@;=                                                               		=
@;=== Programador tarea 1G: albert.canelles@estudiants.urv.cat				  ===
@;=== Programador tarea 1H: albert.canelles@estudiants.urv.cat				  ===
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
				mov r4, r0						@;*Moviment horitzontal guardar direcio base
				mov r3, #ROWS					@;dim de files
				mov r12, #COLUMNS				@;dim de columnes
				mov r0, #0						@;variable que controla si s'ha trobat una combinacio
				mov r1, #0						@;r1=files , inicialitza a 0 per fer totes les files en el mov. hor
				mov r2, #0						@;r2=columnes,
				sub r12, #1						@;c<columns-1
			.Lwhilef1:
				cmp r1, r3						@;comprovar condicio f<rows === es  igual a aixo f<rows?????
				bge .Lfinwhilef1				@;saltar a final del while de files
				cmp r0, #6						@;comprovar que no s'hagi trobat ja una combinacio
				beq .Lfi
				.Lwhilec1:
					cmp r2, r12
					bge .Lfinwhilec1
					cmp r0, #6
					beq .Lfinwhilec1
					mul r5, r1 ,r3
					add r5, r2					@;r5=desplaçament(rows*f+c)
					ldrb r6, [r4, r5]			@;r6= tipus de gelatina actual
					cmp r6, #0
					beq .Lif1
					cmp r6, #7
					beq .Lif1
					cmp r6, #15
					beq .Lif1					@;comparacio amb llocs especials
					add r5, #1
					ldrb r8, [r4, r5]			@;r8= tipus gelatina seguent			
					and r7, r6, #0x00000007		@;r7 mascara per comparar el bits de les gelatines (gelatina actual)
					and r11, r8, #0x00000007	@;r11=mascara per comparar (gelatina seguent)
					cmp r7, r11
					beq .Lgeligual
					cmp r8, #0
					beq .Lif1
					cmp r8, #7
					beq .Lif1
					cmp r8, #15
					beq .Lif1	 				@;comparacio amb gelatina seguent amb llocs especials
					strb r6, [r4, r5]			@;mov de gelatina actual a r9=actual
					sub r5, #1					@;mov de gelatina seguent a r10=seguent
					strb r8, [r4, r5]
					.Lgeligual:
					bl detectar_orientacion
					cmp r0, #6
					bne .Lintercanvi_org_hor					@;si e trobat combinacio ves al final
					strb r6, [r4, r5]			@;r6=gelatina actual torna al lloc original
					add r5, #1					@;desplaçament+1
					strb r8, [r4, r5]			@;gelatina seguent torna al lloc original
					sub r5, #1
					.Lif1:
					add r2, #1
					b .Lwhilec1
				.Lfinwhilec1:
				add r1, #1
				mov r2, #0
				b .Lwhilef1
			.Lfinwhilef1:
				mov r1, #0						@;!*Moviment vertical*! r1=files , inicialitza a 0 per fer totes les files en el mov. hor
				mov r2, #0						@;r2=columnes, r1=files 
				mov r3, #ROWS					@;dim de files
				mov r12, #COLUMNS				@;dim de columnes
				add r12, #1	
				sub r3, #1						@;c<rows-1
			.Lwhilef2:
				cmp r1, r3						@;comprovar condicio f<rows === es  igual a aixo f<rows?????
				bge .Lfinwhilef2				@;saltar a final del while de files
				cmp r0, #6						@;comprovar que no s'hagi trobat ja una combinacio
				bne .Lfi
				.Lwhilec2:
					cmp r2, r12
					bge .Lfinwhilec2
					cmp r0, #6
					bne .Lfinwhilec2
					mul r5, r1 ,r3
					add r5, r2					@;r5=desplaçament(rows*f+c)
					ldrb r6, [r4, r5]			@;r6= tipus de gelatina actual
					cmp r6, #0
					beq .Lif2
					cmp r6, #7
					beq .Lif2
					cmp r6, #15
					beq .Lif2					@;comparacio amb llocs especials
					add r5, r3					@;+row al desplaçament per anar a la seguent fila
					ldrb r8, [r4, r5]			@;!*comença punt 3*! r8= tipus gelatina seguent			
					and r7, r6, #0x00000007		@;r7 mascara per comparar el bits de les gelatines (gelatina actual)
					and r11, r8, #0x00000007	@;r11=mascara per comparar (gelatina seguent)
					cmp r7, r11
					beq .Lgeligual2
					cmp r8, #0
					beq .Lif2
					cmp r8, #7
					beq .Lif2
					cmp r8, #15
					beq .Lif2	 				@;comparacio amb gelatina seguent amb llocs especials		strb r6, [r4, r5]	,mov r9, r6
					strb r6, [r4, r5]					@;mov de gelatina actual a r9=actual				sub r5,r3			,mov r10, r8	
					sub r5, r3					@;mov de gelatina seguent a r10=seguent						strb r8, [r4, r5]	,mov r6, r10
					strb r8, [r4, r5]			@;																			,mov r8, r9
					.Lgeligual2:
					bl detectar_orientacion		@;
					cmp r0, #6
					bne .Lintercanvi_org_ver					@;si e trobat combinacio ves al final
					strb r6, [r4, r5]			@;r6=gelatina actual torna al lloc original
					add r5, r3					@;desplaçament+dim
					strb r8, [r4, r5]			@;gelatina seguent torna al lloc original
					sub r5, r3
					.Lif2:
					add r2, #1
					b .Lwhilec2
				.Lfinwhilec2:
				add r1, #1
				mov r2, #0
				b .Lwhilef2
			.Lintercanvi_org_hor:			@;intercanvi en cas de seq trobada al mov. horitzontal
				mul r5, r1 ,r3
				add r5, r2	
				strb r6, [r4, r5]
				add r5, #1
				strb r8, [r4, r5]
				sub r5, #1
				b .Lfi
			.Lintercanvi_org_ver:			@;intercanvi en cas de seq trobada al mov. vertical
				mul r5, r1 ,r3
				add r5, r2	
				strb r6, [r4, r5]
				add r5, r3
				strb r8, [r4, r5]
				sub r5, r3			
			.Lfinwhilef2:
		.Lfi:									@;final final 
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
		push {r2-r12, lr}
			mov r5, r0				@;guardar direccio base matriu joc en r5	entre mov r8, r1 i cmp r0, #0 va aixo:bl hay_combinacion
			mov r8, r1
			bl hay_combinacion
			cmp r0, #0
			beq .Lfi_sug
				mov r1, #0			@;inicialitzacio fila
				mov r2, #0			@;inicialitzacio columna
				mov r3, #6			@;inicializacio cod_ori
				mov r4, #0			@;inicialitzacio cod_pos_ini
				mov r6, #0			@;inicialitzacio desplaçament
				mov r10, #ROWS
				mov r0, #8
				bl mod_random
				mov r1, r0		@;r1=f
				mov r0, #8
				bl mod_random
				mov r2, r0		@;r2=c
				b .Lwhilef_sug
				.Lrecorregut:
					mov r1, #0
					mov r2, #0
				.Lwhilef_sug:
					cmp r1, #ROWS		@;rows=r10
					bge .Lfiwhilef_sug
					.Lwhilec_sug:
						cmp r2, #COLUMNS		@; columns=r10
						beq .Lfiwhilec_sug
						mul r6, r10, r1		@;al cpi=0, cod_ori=1 error en la multiplicacio
						add r6, r2
						ldrb r7, [r5, r6]	@;r7=tipus gelatina actual			
						cmp r7, #0
						beq .Lfi_gel_esp
						cmp r7, #7
						beq .Lfi_gel_esp
						cmp r7, #15
						beq .Lfi_gel_esp		@;revisar si es te de comprovar que les gelatines que la rodejen son bloc normals?
						cmp r1, #0				@;/*Dalt*/
						beq .Lfi_comprov1		@;saltar al final de comprovar dalt
							sub r6, r10				
							ldrb r9, [r5, r6]		@;r9=tipus gelatina seguent
							cmp r9, #0
							beq .Lerror_seg1
							cmp r9, #7
							beq .Lerror_seg1
							cmp r9, #15
							beq .Lerror_seg1
							and r11, r7, #0x00000007		@;r7 mascara per comparar el bits de les gelatines (gelatina actual)
							and r12, r9, #0x00000007
							cmp r11, r12
							beq .Liguals1	 
							strb r7, [r5, r6]	@; intercanvi pos de gelatines
							add r6, r10
							strb r9, [r5, r6]
							.Liguals1:
							bl detectar_orientacion
							mov r3, r0
							mov r4, #3	
							cmp r11, r12
							beq .Lerror_seg1
							strb r7, [r5,r6]
							sub r6, r10
							strb r9, [r5, r6]
							.Lerror_seg1:
							cmp r3, #6
							bne .Lfiwhilef_sug			@;s'hi ha seq saltar al final de comprovacio
						.Lfi_comprov1:
						cmp r1, #ROWS				@;/*Baix*/
						beq .Lfi_comprov2		@;saltar al final de comprovar baix
							mul r6, r10, r1
							add r6, r2
							ldrb r7, [r5, r6]
							add r6, r10				
							ldrb r9, [r5, r6]		@;r9=tipus gelatina seguent
							cmp r9, #0
							beq .Lerror_seg2
							cmp r9, #7
							beq .Lerror_seg2
							cmp r9, #15
							beq .Lerror_seg2
							and r11, r7, #0x00000007		@;r7 mascara per comparar el bits de les gelatines (gelatina actual)
							and r12, r9, #0x00000007
							cmp r11, r12
							beq .Liguals2
							strb r7, [r5, r6]		@;inercanvi gelatines
							sub r6, r10
							strb r9, [r5, r6]
							.Liguals2:
							bl detectar_orientacion
							mov r3, r0
							mov r4, #2	
							cmp r11, r12
							beq .Lerror_seg2
							strb r7, [r5,r6]
							add r6, r10
							strb r9, [r5, r6]
							.Lerror_seg2:
							cmp r3, #6
							bne .Lfiwhilef_sug			@;s'hi ha seq saltar al final de comprovacio
						.Lfi_comprov2:
						cmp r2, #COLUMNS				@;/*Dreta*/
						beq .Lfi_comprov3		@;saltar al final de comprovar dreta
							mul r6, r10, r1
							add r6, r2
							ldrb r7, [r5, r6]
							add r6, #1			
							ldrb r9, [r5, r6]		@;r9=tipus gelatina seguent
							cmp r9, #0
							beq .Lerror_seg3
							cmp r9, #7
							beq .Lerror_seg3
							cmp r9, #15
							beq .Lerror_seg3
							and r11, r7, #0x00000007		@;r7 mascara per comparar el bits de les gelatines (gelatina actual)
							and r12, r9, #0x00000007
							cmp r11, r12
							beq .Liguals3
							strb r7, [r5, r6]		@;intercanvi gelatines 
							sub r6, #1
							strb r9, [r5, r6]
							.Liguals3:
							bl detectar_orientacion
							mov r3, r0
							mov r4, #0
							cmp r11, r12
							beq .Lerror_seg3
							strb r7, [r5,r6]
							add r6, #1
							strb r9, [r5, r6]
							.Lerror_seg3:
							cmp r3, #6
							bne .Lfiwhilef_sug			@;s'hi ha seq saltar al final de comprovacio
						.Lfi_comprov3:
						cmp r2, #0			@;/*Esquerra*/
						beq .Lfi_comprov4		@;saltar al final de comprovar esquerra
							mul r6, r10, r1
							add r6, r2
							ldrb r7, [r5, r6]
							sub r6, #1				
							ldrb r9, [r5, r6]		@;r9=tipus gelatina seguent
							cmp r9, #0
							beq .Lerror_seg4
							cmp r9, #7
							beq .Lerror_seg4
							cmp r9, #15
							beq .Lerror_seg4
							and r11, r7, #0x00000007		@;r7 mascara per comparar el bits de les gelatines (gelatina actual)
							and r12, r9, #0x00000007
							cmp r11, r12
							beq .Liguals4
							strb r7, [r5, r6]		@;inercanvi gelatines
							add r6, #1
							strb r9, [r5, r6]
							.Liguals4:
							bl detectar_orientacion
							mov r3, r0
							mov r4, #1			
							cmp r11, r12
							beq .Lerror_seg4
							strb r7, [r5,r6]
							sub r6, #1
							strb r9, [r5, r6]
							.Lerror_seg4:
							cmp r3, #6
							bne .Lfiwhilef_sug			@;s'hi ha seq saltar al final de comprovacio
						.Lfi_comprov4:
						.Lfi_gel_esp:
						cmp r3, #6					@;mirar si s'ha trobat alguna comb i saltar a generar_pos, sortir bucle
						bne .Lfiwhilef_sug
						add r2, #1
						b .Lwhilec_sug
					.Lfiwhilec_sug:
					add r1, #1
					mov r2, #0
					b .Lwhilef_sug
				.Lfiwhilef_sug:
				cmp r3, #6
				beq .Lrecorregut
				mov r0, r8			
				bl generar_posiciones
			.Lfi_sug:
		pop {r2-r12, pc}




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
		push {r1-r12, lr}
			cmp r4, #0
			bne .Lpos1
				mov r8, #0		@;registre index
				add r2, #1
				strb r2, [r0, r8]
				add r8, #1
				strb r1, [r0, r8]
				sub r2, #1
				cmp r3, #1
				bne .Lcod1
					add r8, #1
					strb r2, [r0, r8]
					add r1, #1
					add r8, #1
					strb r1, [r0, r8]
					add r8, #1
					strb r2, [r0, r8]
					add r1, #1
					add r8, #1
					strb r1, [r0, r8]
					b .Lfi_vec
				.Lcod1:
				cmp r3, #2
				bne .Lcod2
					sub r2, #1
					add r8, #1
					strb r2, [r0, r8]
					add r8, #1
					strb r1, [r0, r8]
					sub r2, #1
					add r8, #1
					strb r2, [r0, r8]
					add r8, #1
					strb r1, [r0, r8]
					b .Lfi_vec
				.Lcod2:
				cmp r3, #3
				bne .Lcod3
					add r8, #1
					strb r2, [r0, r8]
					sub r1, #1
					add r8, #1
					strb r1, [r0, r8]
					add r8, #1
					strb r2, [r0, r8]
					sub r1, #1
					add r8, #1
					strb r1, [r0, r8]
					b .Lfi_vec
				.Lcod3:
				cmp r3, #5
				bne .Lcod4
					add r8, #1
					strb r2, [r0, r8]
					sub r1, #1
					add r8, #1
					strb r1, [r0, r8]
					add r8, #1
					strb r2, [r0, r8]
					add r1, #2
					add r8, #1
					strb r1, [r0, r8]
					b .Lfi_vec
				.Lcod4:
			.Lpos1:
			cmp r4, #1
			bne .Lpos2
				mov r8, #0		@;registre index
				sub r2, #1
				strb r2, [r0, r8]
				add r8, #1
				strb r1, [r0, r8]
				add r2, #1 @;
				cmp r3, #0
				bne .Lcod1_1
					add r2, #1
					add r8, #1
					strb r2, [r0, r8]
					add r8, #1
					strb r1, [r0, r8]
					add r2, #1
					add r8, #1
					strb r2, [r0, r8]
					add r8, #1
					strb r1, [r0, r8]
					b .Lfi_vec
				.Lcod1_1:
				cmp r3, #1
				bne .Lcod2_1
					add r8, #1
					strb r2, [r0, r8]
					add r1,#1
					add r8, #1
					strb r1, [r0, r8]
					add r8, #1
					strb r2, [r0, r8]
					add r1, #1
					add r8, #1
					strb r1, [r0, r8]
					b .Lfi_vec
				.Lcod2_1:
				cmp r3, #3
				bne .Lcod3_1
					add r8, #1
					strb r2, [r0, r8]
					sub r1, #1
					add r8, #1
					strb r1, [r0, r8]
					add r8, #1
					strb r2, [r0, r8]
					sub r1, #1
					add r8, #1
					strb r1, [r0, r8]
					b .Lfi_vec
				.Lcod3_1:
				cmp r3, #5
				bne .Lcod4_1
					add r8, #1
					strb r2, [r0, r8]
					sub r1, #1
					add r8, #1
					strb r1, [r0, r8]
					add r8, #1
					strb r2, [r0, r8]
					add r1, #2
					add r8, #1
					strb r1, [r0, r8]
					b .Lfi_vec
				.Lcod4_1:
			.Lpos2:
			cmp r4, #2
			bne .Lpos3
				mov r8, #0		@;registre index
				add r1, #1
				strb r2, [r0, r8]
				add r8, #1
				strb r1, [r0, r8]
				sub r1, #1
				cmp r3, #0
				bne .Lcod1_2
					add r2, #1
					add r8, #1
					strb r2, [r0, r8]
					add r8, #1
					strb r1, [r0, r8]
					add r2, #1
					add r8, #1
					strb r2, [r0, r8]
					add r8, #1
					strb r1, [r0, r8]
					b .Lfi_vec
				.Lcod1_2:
				cmp r3, #2
				bne .Lcod2_2
					sub r2, #1
					add r8, #1
					strb r2, [r0, r8]
					add r8, #1
					strb r1, [r0, r8]
					sub r2, #1
					add r8, #1
					strb r2, [r0, r8]
					add r8, #1
					strb r1, [r0, r8]
					b .Lfi_vec
				.Lcod2_2:
				cmp r3, #3
				bne .Lcod3_2
					add r8, #1
					strb r2, [r0, r8]
					sub r1, #1
					add r8, #1
					strb r1, [r0, r8]
					add r8, #1
					strb r2, [r0, r8]
					sub r1, #1
					add r8, #1
					strb r1, [r0, r8]
					b .Lfi_vec
				.Lcod3_2:
				cmp r3, #4
				bne .Lcod4_2
					sub r2, #1
					add r8, #1
					strb r2, [r0, r8]
					add r8, #1
					strb r1, [r0, r8]
					add r2, #2
					add r8, #1
					strb r2, [r0, r8]
					add r8, #1
					strb r1, [r0, r8]
					b .Lfi_vec
				.Lcod4_2:
			.Lpos3:
			cmp r4, #3
			bne .Lpos4
				mov r8, #0		@;registre index
				strb r2, [r0, r8]
				add r8, #1
				sub r1, #1
				strb r1, [r0, r8]
				add r1, #1
				cmp r3, #0
				bne .Lcod1_3
					add r2, #1
					add r8, #1
					strb r2, [r0, r8]
					add r8, #1
					strb r1, [r0, r8]
					add r2, #1
					add r8, #1
					strb r2, [r0, r8]
					add r8, #1
					strb r1, [r0, r8]
					b .Lfi_vec
				.Lcod1_3:
				cmp r3, #1
				bne .Lcod2_3
					add r8, #1
					strb r2, [r0, r8]
					add r1,#1
					add r8, #1
					strb r1, [r0, r8]
					add r8, #1
					strb r2, [r0, r8]
					add r1, #1
					add r8, #1
					strb r1, [r0, r8]
					b .Lfi_vec
				.Lcod2_3:				
				cmp r3, #2
				bne .Lcod3_3
					sub r2, #1
					add r8, #1
					strb r2, [r0, r8]
					add r8, #1
					strb r1, [r0, r8]
					sub r2, #1
					add r8, #1
					strb r2, [r0, r8]
					add r8, #1
					strb r1, [r0, r8]
					b .Lfi_vec
				.Lcod3_3:
				cmp r3, #4
				bne .Lcod4_3
					sub r2, #1
					add r8, #1
					strb r2, [r0, r8]
					add r8, #1
					add r1, #1 @;dadada
					strb r1, [r0, r8]
					add r2, #2
					add r8, #1
					strb r2, [r0, r8]
					add r8, #1
					add r1, #1 @;dsdsdadas
					strb r1, [r0, r8]
					b .Lfi_vec
				.Lcod4_3:
			.Lpos4:
		.Lfi_vec:
		pop {r1-r12, pc}



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
@;	Resultado:
@;		R0 = código de orientación;
@;				inicio de secuencia: 0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte
@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
@;				sin secuencia: 6 
detectar_orientacion:
		push {r3-r5,lr}
		mov r4, r5
		mov r5, #0				@;R5 = índice bucle de orientaciones
		mov r0, #4
		bl mod_random
		mov r3, r0				@;R3 = orientación aleatoria (0..3)
	.Ldetori_for:
		mov r0, r4
		bl cuenta_repeticiones
		cmp r0, #1
		beq .Ldetori_cont		@;no hay inicio de secuencia
		cmp r0, #3
		bhs .Ldetori_fin		@;hay inicio de secuencia
		add r3, #2
		and r3, #3				@;R3 = salta dos orientaciones (módulo 4)
		mov r0, r4
		bl cuenta_repeticiones
		add r3, #2
		and r3, #3				@;restituye orientación (módulo 4)
		cmp r0, #1
		beq .Ldetori_cont		@;no hay continuación de secuencia
		tst r3, #1
		bne .Ldetori_vert
		mov r3, #4				@;detección secuencia horizontal
		b .Ldetori_fin
	.Ldetori_vert:
		mov r3, #5				@;detección secuencia vertical
		b .Ldetori_fin
	.Ldetori_cont:
		add r3, #1
		and r3, #3				@;R3 = siguiente orientación (módulo 4)
		add r5, #1
		cmp r5, #4
		blo .Ldetori_for		@;repetir 4 veces
		mov r3, #6				@;marca de no encontrada
	.Ldetori_fin:
		mov r0, r3				@;devuelve orientación o marca de no encontrada
		pop {r3-r5,pc}



.end
