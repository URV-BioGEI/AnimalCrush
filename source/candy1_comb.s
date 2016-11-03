@;=                                                               		=
@;=== candy1_combi.s: rutinas para detectar y sugerir combinaciones   ===
@;=                                                               		=
@;=== Programador tarea 1G: albert.cañellas@estudiants.urv.cat				  ===
@;=== Programador tarea 1H: albert.cañellas@estudiants.urv.cat				  ===
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
				mov r5, r0							@;!*Moviment horitzontal*! guardar direcio base a r5
				mov r3, #ROWS						@;dim de files
				mov r12, #COLUMNS					@;dim de columnes
				mov r0, #6							@;variable que controla si s'ha trobat una combinacio
				mov r1, #0							@;r1=files 
				mov r2, #0							@;r2=columnes
			.Lwhilef1:
				cmp r1, #ROWS						@;comprovar condicio f<rows 
				bge .Lfinwhilef1					@;saltar a final del while de files
				cmp r0, #6							@;comprovar que no s'hagi trobat ja una combinacio
				bne .Lfi
				.Lwhilec1:
					mov r12, #COLUMNS
					sub r12, #1						@;r12=dim de columnes-1
					cmp r2, r12
					bge .Lfinwhilec1
					cmp r0, #6
					bne .Lfi
					mul r4, r1 ,r12
					add r4, r2						@;r4=desplaçament(rows*f+c)
					ldrb r6, [r5, r4]				@;r6= tipus de gelatina actual
					cmp r6, #0						@;comparacio amb llocs especials a gelatina actual
					beq .Lif1
					cmp r6, #7
					beq .Lif1
					cmp r6, #15
					beq .Lif1					
					add r4, #1
					ldrb r8, [r5, r4]				@;r8= tipus gelatina seguent			
					cmp r8, #0						@;comparacio amb llocs especials a gelatina seguent
					beq .Lif1
					cmp r8, #7
					beq .Lif1
					cmp r8, #15
					beq .Lif1	 				
					and r7, r6, #0x00000007			@;r7 mascara per comparar el bits de menor pes de les gelatines (gelatina actual)
					and r11, r8, #0x00000007		@;r11=mascara per comparar (gelatina seguent)
					cmp r7, r11						@;comparacio de les gelatines si son igual no intercanviar
					beq .Lgeligual
					strb r6, [r5, r4]				@;intercanvi gelatina actual al lloc de la seguent
					sub r4, #1						@;intercanvi gelatina seguent al lloc de l'actual
					strb r8, [r5, r4]
					.Lgeligual:
					bl detectar_orientacion			@;crida a la funcio que detecta orientacio en la posicio actual
					cmp r0, #6
					bne .Lintercanvi_org_hor		@;si e trobat combinacio ves al final
					add r2, #1
					bl detectar_orientacion			@;detectar orientacio en la posicio seguent
					sub r2, #1
					cmp r0, #6
					bne .Lintercanvi_org_hor		@;si e trobat combinacio ves al final
					cmp r7, r11
					beq .Lif1
					strb r6, [r5, r4]				@;r6=gelatina actual torna al lloc original
					add r4, #1						@;desplaçament+1
					strb r8, [r5, r4]				@;r8=gelatina seguent torna al lloc original
					.Lif1:
					add r2, #1						@;c+1
					b .Lwhilec1
				.Lfinwhilec1:
				add r1, #1							@;f+1
				mov r2, #0							@;c=0
				b .Lwhilef1
			.Lfinwhilef1:
				mov r1, #0							@;!*Moviment vertical*! r1=files 
				mov r2, #0							@;r2=columnes, r1=files 
				mov r3, #ROWS						@;dim de files
				mov r12, #COLUMNS					@;dim de columnes
				add r12, #1
			.Lwhilef2:
				mov r11, #ROWS
				sub r11, #1							@;r11=dim de files-1
				cmp r1, r11							@;comprovar condicio f<rows 
				bge .Lfi							@;saltar a final del while de files
				cmp r0, #6							@;comprovar que no s'hagi trobat ja una combinacio
				bne .Lfi
				.Lwhilec2:
					cmp r2, #COLUMNS
					bge .Lfinwhilec2
					cmp r0, #6
					bne .Lfi
					mul r4, r1 ,r12
					add r4, r2						@;r4=desplaçament(rows*f+c)
					ldrb r6, [r5, r4]				@;r6= tipus de gelatina actual
					cmp r6, #0						@;comparacio amb llocs especials
					beq .Lif2
					cmp r6, #7
					beq .Lif2
					cmp r6, #15
					beq .Lif2						
					add r4, r12						@;+row al desplaçament per anar a la seguent fila
					ldrb r8, [r5, r4]				@;r8= tipus gelatina seguent			
					cmp r8, #0						@;comparacio amb gelatina seguent amb llocs especials
					beq .Lif2
					cmp r8, #7
					beq .Lif2
					cmp r8, #15
					beq .Lif2	 					
					and r7, r6, #0x00000007			@;r7 mascara per comparar el bits de menor pes de les gelatines (gelatina actual)
					and r11, r8, #0x00000007		@;r11=mascara per comparar (gelatina seguent)
					cmp r7, r11						@;comparacio de les gelatines si son igual no intercanviar 
					beq .Lgeligual2
					strb r6, [r5, r4]				@;intercanvi gelatina actual al lloc de la seguent
					sub r4, r12						@;intercanvi gelatina seguent al lloc de l'actual
					strb r8, [r5, r4]
					.Lgeligual2:
					bl detectar_orientacion			@;crida a la funcio que detecta orientacio en la posicio actual
					cmp r0, #6
					bne .Lintercanvi_org_ver		@;si e trobat combinacio ves al final
					add r1, #1						
					bl detectar_orientacion			@;detectar orientacio en la posicio seguent
					sub r1, #1
					cmp r0, #6
					bne .Lintercanvi_org_ver		@;si e trobat combinacio ves al final
					cmp r7, r11
					beq .Lif2
					strb r6, [r5, r4]				@;r6=gelatina actual torna al lloc original
					add r4, r12						@;desplaçament+dim
					strb r8, [r5, r4]				@;gelatina seguent torna al lloc original
					.Lif2:
					add r2, #1						@;c+1
					b .Lwhilec2
				.Lfinwhilec2:
				add r1, #1							@;f+1
				mov r2, #0							@;c=0
				b .Lwhilef2
			.Lintercanvi_org_hor:					@;intercanvi en cas de seq trobada al mov. horitzontal per tornar les gelatines al seu lloc original
				cmp r7, r11
				beq .Lfi
				strb r6, [r5, r4]
				add r4, #1
				strb r8, [r5, r4]
				b .Lfi
			.Lintercanvi_org_ver:					@;intercanvi en cas de seq trobada al mov. vertical per tornar les gelatines al seu lloc original
				cmp r7, r11
				beq .Lfi
				strb r6, [r5, r4]
				add r4, r12
				strb r8, [r5, r4]
		.Lfi:										@;final 
		cmp r0, #6
		beq .Lcanv									
		mov r0, #1									@;si comb=trobada tornar 1
		b .Lfinal
		.Lcanv:
		mov r0, #0									@;si comb=no trobada tornar 0
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
			mov r5, r0									@;guardar direccio base matriu joc en r5	entre mov r8, r1 i cmp r0, #0 va aixo:bl hay_combinacion
			mov r8, r1
			bl hay_combinacion
			cmp r0, #0
			beq .Lfi_sug								@;si no hi ha combinacio sortir del metode
				mov r1, #0								@;inicialitzacio fila
				mov r2, #0								@;inicialitzacio columna
				mov r3, #6								@;inicializacio cod_ori
				mov r4, #0								@;inicialitzacio cod_pos_ini
				mov r6, #0								@;inicialitzacio desplaçament
				mov r10, #COLUMNS
				mov r0, #ROWS
				bl mod_random							@;mod_random per escollir una fila
				mov r1, r0								@;r1=f
				mov r0, #COLUMNS
				bl mod_random							@;mod_random per escollir una columna
				mov r2, r0								@;r2=c
				b .Lwhilef_sug
				.Lrecorregut:							@;si la cerca s'acaba la matriu tornar a començar
					mov r1, #0
					mov r2, #0
				.Lwhilef_sug:
					cmp r1, #ROWS						
					bge .Lfiwhilef_sug
					.Lwhilec_sug:
						cmp r2, #COLUMNS				
						bge .Lfiwhilec_sug
						mul r6, r10, r1					@;desplaçament en r6
						add r6, r2
						ldrb r7, [r5, r6]				@;r7=tipus gelatina actual			
						cmp r7, #0						@;comparacio de r7 amb llocs especials
						beq .Lfi_gel_esp
						cmp r7, #7
						beq .Lfi_gel_esp
						cmp r7, #15
						beq .Lfi_gel_esp				@;revisar si es te de comprovar que les gelatines que la rodejen son bloc normals?
						cmp r1, #0						@;/*Dalt*/
						beq .Lfi_comprov1				@;saltar al final de comprovar dalt
							sub r6, r10				
							ldrb r9, [r5, r6]			@;r9=tipus gelatina seguent
							cmp r9, #0
							beq .Lerror_seg1			@;comparacio r9 en llocs especials
							cmp r9, #7
							beq .Lerror_seg1
							cmp r9, #15
							beq .Lerror_seg1
							and r11, r7, #0x00000007	@;r11 mascara per comparar el bits de les gelatines (gelatina actual)
							and r12, r9, #0x00000007	@;r12=mascara per comparar (gelatina seguent)
							cmp r11, r12				@;comparacio de les gelatines si son iguals no intercanviar
							beq .Liguals1	 			
							strb r7, [r5, r6]			@;intercanvi pos de gelatines
							add r6, r10
							strb r9, [r5, r6]
							.Liguals1:
							bl detectar_orientacion		@;detectar orientacio, obtencio del r3=cod_ori
							mov r3, r0
							mov r4, #3					@;codi_pos_ini=3 (vertical_baix)
							cmp r11, r12
							beq .Lerror_seg1
							strb r7, [r5,r6]			@;tornar les gelatines posicio original
							sub r6, r10
							strb r9, [r5, r6]
							.Lerror_seg1:
							cmp r3, #6
							bne .Lfiwhilef_sug			@;s'hi ha seq saltar al final de comprovacio
						.Lfi_comprov1:
						mov r12, #ROWS
						sub r12, #1
						cmp r1, r12						@;/*Baix*/
						bge .Lfi_comprov2				@;saltar al final de comprovar baix
							mul r6, r10, r1
							add r6, r2
							ldrb r7, [r5, r6]
							add r6, r10				
							ldrb r9, [r5, r6]			@;r9=tipus gelatina seguent
							cmp r9, #0	
							beq .Lerror_seg2			@;comparacio r9 en llocs especials
							cmp r9, #7
							beq .Lerror_seg2
							cmp r9, #15
							beq .Lerror_seg2
							and r11, r7, #0x00000007	@;r11 mascara per comparar el bits de les gelatines (gelatina actual)
							and r12, r9, #0x00000007	@;r12=mascara per comparar (gelatina seguent)
							cmp r11, r12
							beq .Liguals2
							strb r7, [r5, r6]			@;inercanvi gelatines
							sub r6, r10
							strb r9, [r5, r6]
							.Liguals2:
							bl detectar_orientacion		@;detectar orientacio, obtencio del r3=cod_ori
							mov r3, r0
							mov r4, #2					@;codi_pos_ini=2 (vertical_dalt)
							cmp r11, r12
							beq .Lerror_seg2
							strb r7, [r5,r6]			@;tornar les gelatines posicio original
							add r6, r10
							strb r9, [r5, r6]
							.Lerror_seg2:
							cmp r3, #6
							bne .Lfiwhilef_sug			@;s'hi ha seq saltar al final de comprovacio
						.Lfi_comprov2:
						mov r12, #COLUMNS
						sub r12, #1
						cmp r2, r12						@;/*Dreta*/
						bge .Lfi_comprov3				@;saltar al final de comprovar dreta
							mul r6, r10, r1
							add r6, r2
							ldrb r7, [r5, r6]
							add r6, #1			
							ldrb r9, [r5, r6]			@;r9=tipus gelatina seguent
							cmp r9, #0
							beq .Lerror_seg3			@;comparacio r9 en llocs especials
							cmp r9, #7
							beq .Lerror_seg3
							cmp r9, #15
							beq .Lerror_seg3
							and r11, r7, #0x00000007	@;r11 mascara per comparar el bits de les gelatines (gelatina actual)
							and r12, r9, #0x00000007	@;r12=mascara per comparar (gelatina seguent)
							cmp r11, r12
							beq .Liguals3
							strb r7, [r5, r6]			@;intercanvi gelatines 
							sub r6, #1
							strb r9, [r5, r6]
							.Liguals3:
							bl detectar_orientacion		@;detectar orientacio, obtencio del r3=cod_ori
							mov r3, r0
							mov r4, #0					@;codi_pos_ini=0 (horitzontal_esquerra)
							cmp r11, r12
							beq .Lerror_seg3
							strb r7, [r5,r6]			@;tornar les gelatines posicio original
							add r6, #1
							strb r9, [r5, r6]
							.Lerror_seg3:
							cmp r3, #6
							bne .Lfiwhilef_sug			@;s'hi ha seq saltar al final de comprovacio
						.Lfi_comprov3:
						cmp r2, #0						@;/*Esquerra*/
						beq .Lfi_comprov4				@;saltar al final de comprovar esquerra
							mul r6, r10, r1
							add r6, r2
							ldrb r7, [r5, r6]
							sub r6, #1				
							ldrb r9, [r5, r6]			@;r9=tipus gelatina seguent
							cmp r9, #0
							beq .Lerror_seg4			@;comparacio r9 en llocs especials
							cmp r9, #7
							beq .Lerror_seg4
							cmp r9, #15
							beq .Lerror_seg4
							and r11, r7, #0x00000007	@;r11 mascara per comparar el bits de les gelatines (gelatina actual)
							and r12, r9, #0x00000007	@;r12=mascara per comparar (gelatina seguent)
							cmp r11, r12
							beq .Liguals4
							strb r7, [r5, r6]			@;inercanvi gelatines
							add r6, #1
							strb r9, [r5, r6]
							.Liguals4:
							bl detectar_orientacion		@;detectar orientacio, obtencio del r3=cod_ori
							mov r3, r0
							mov r4, #1					@;codi_pos_ini=1 (horitzontal_dreta)
							cmp r11, r12
							beq .Lerror_seg4
							strb r7, [r5,r6]			@;tornar les gelatines posicio original
							sub r6, #1
							strb r9, [r5, r6]
							.Lerror_seg4:
							cmp r3, #6
							bne .Lfiwhilef_sug			@;s'hi ha seq saltar al final de comprovacio
						.Lfi_comprov4:
						.Lfi_gel_esp:
						cmp r3, #6						@;mirar si s'ha trobat alguna comb, si es aixi sortir del bulce
						bne .Lfiwhilef_sug
						add r2, #1						@;c+1
						b .Lwhilec_sug
					.Lfiwhilec_sug:	
					add r1, #1							@;f+1
					mov r2, #0							@;c=0
					b .Lwhilef_sug
				.Lfiwhilef_sug:
				cmp r3, #6								@;si s'ha acabat la matriu i no ha trobat comb, saltar al principi del bulce per tornar a començar la cerca en la matriu
				beq .Lrecorregut
				mov r0, r8								@;recuperar la direccio de memoria del vector de posicions
				bl generar_posiciones					@;crida a generar posicions
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
			cmp r4, #0							@;si cod_pos_ini==0
			bne .Lpos1
				mov r8, #0						@;r8=registre index del vector de direccions
				add r2, #1						@;guardar pos_inicial
				strb r2, [r0, r8]				@;c+1
				add r8, #1
				strb r1, [r0, r8]				@;f
				sub r2, #1
				cmp r3, #1						@;si cod_ori==1
				bne .Lcod1
					add r8, #1
					strb r2, [r0, r8]			@;c
					add r1, #1
					add r8, #1
					strb r1, [r0, r8]			@;f+1
					add r8, #1
					strb r2, [r0, r8]			@;c
					add r1, #1
					add r8, #1
					strb r1, [r0, r8]			@;f+2
					b .Lfi_vec
				.Lcod1:
				cmp r3, #2						@;si cod_ori==2
				bne .Lcod2
					sub r2, #1		
					add r8, #1
					strb r2, [r0, r8]			@;c-1
					add r8, #1
					strb r1, [r0, r8]			@;f
					sub r2, #1
					add r8, #1
					strb r2, [r0, r8]			@;c-2
					add r8, #1
					strb r1, [r0, r8]			@;f
					b .Lfi_vec
				.Lcod2:
				cmp r3, #3						@;si cod_ori==3
				bne .Lcod3
					add r8, #1
					strb r2, [r0, r8]			@;c
					sub r1, #1
					add r8, #1
					strb r1, [r0, r8]			@;f-1
					add r8, #1
					strb r2, [r0, r8]			@;c
					sub r1, #1
					add r8, #1
					strb r1, [r0, r8]			@;f-2
					b .Lfi_vec
				.Lcod3:
				cmp r3, #5						@;si cod_ori==5
				bne .Lcod4
					add r8, #1
					strb r2, [r0, r8]			@;c
					sub r1, #1
					add r8, #1
					strb r1, [r0, r8]			@;f-1
					add r8, #1
					strb r2, [r0, r8]			@;c
					add r1, #2
					add r8, #1
					strb r1, [r0, r8]			@;f+1
					b .Lfi_vec
				.Lcod4:
			.Lpos1:
			cmp r4, #1							@;si cod_pos_ini==1
			bne .Lpos2
				mov r8, #0						@;r8=registre index del vector de direccions
				sub r2, #1						@;@;guardar pos_inicial
				strb r2, [r0, r8]				@;c-1
				add r8, #1
				strb r1, [r0, r8]				@;f
				add r2, #1 
				cmp r3, #0						@;si cod_ori==0
				bne .Lcod1_1
					add r2, #1
					add r8, #1
					strb r2, [r0, r8]			@;c+1
					add r8, #1
					strb r1, [r0, r8]			@;f
					add r2, #1
					add r8, #1
					strb r2, [r0, r8]			@;c+2
					add r8, #1
					strb r1, [r0, r8]			@;f
					b .Lfi_vec
				.Lcod1_1:
				cmp r3, #1						@;si cod_ori==1
				bne .Lcod2_1
					add r8, #1
					strb r2, [r0, r8]			@;c
					add r1, #1
					add r8, #1
					strb r1, [r0, r8]			@;f+1
					add r8, #1
					strb r2, [r0, r8]			@;c
					add r1, #1
					add r8, #1
					strb r1, [r0, r8]			@;f+2
					b .Lfi_vec
				.Lcod2_1:
				cmp r3, #3						@;si cod_ori==3
				bne .Lcod3_1
					add r8, #1
					strb r2, [r0, r8]			@;c
					sub r1, #1
					add r8, #1
					strb r1, [r0, r8]			@;f-1
					add r8, #1
					strb r2, [r0, r8]			@;c
					sub r1, #1
					add r8, #1
					strb r1, [r0, r8]			@;f-2
					b .Lfi_vec
				.Lcod3_1:
				cmp r3, #5						@;si cod_ori==5
				bne .Lcod4_1
					add r8, #1
					strb r2, [r0, r8]			@;c
					sub r1, #1
					add r8, #1
					strb r1, [r0, r8]			@;f-1
					add r8, #1
					strb r2, [r0, r8]			@;c
					add r1, #2
					add r8, #1
					strb r1, [r0, r8]			@;f+1
					b .Lfi_vec
				.Lcod4_1:
			.Lpos2:
			cmp r4, #2							@;si cod_pos_ini==2
			bne .Lpos3
				mov r8, #0						@;r8=registre index del vector de direccions
				add r1, #1						@;guardar pos_inicial
				strb r2, [r0, r8]				@;c
				add r8, #1
				strb r1, [r0, r8]				@;f+1
				sub r1, #1
				cmp r3, #0						@;si cod_ori==0
				bne .Lcod1_2
					add r2, #1
					add r8, #1
					strb r2, [r0, r8]			@;c+1
					add r8, #1
					strb r1, [r0, r8]			@;f
					add r2, #1
					add r8, #1
					strb r2, [r0, r8]			@;c+2
					add r8, #1
					strb r1, [r0, r8]			@;f
					b .Lfi_vec	
				.Lcod1_2:
				cmp r3, #2						@;si cod_ori==2
				bne .Lcod2_2
					sub r2, #1
					add r8, #1
					strb r2, [r0, r8]			@;c-1
					add r8, #1
					strb r1, [r0, r8]			@;f
					sub r2, #1
					add r8, #1
					strb r2, [r0, r8]			@;c-2
					add r8, #1
					strb r1, [r0, r8]			@;f
					b .Lfi_vec
				.Lcod2_2:
				cmp r3, #3						@;si cod_ori==3
				bne .Lcod3_2
					add r8, #1
					strb r2, [r0, r8]			@;c
					sub r1, #1
					add r8, #1
					strb r1, [r0, r8]			@;f-1
					add r8, #1
					strb r2, [r0, r8]			@;c
					sub r1, #1
					add r8, #1
					strb r1, [r0, r8]			@;f-2
					b .Lfi_vec
				.Lcod3_2:
				cmp r3, #4						@;si cod_ori==4
				bne .Lcod4_2
					sub r2, #1
					add r8, #1
					strb r2, [r0, r8]			@;c-1
					add r8, #1
					strb r1, [r0, r8]			@;f
					add r2, #2
					add r8, #1
					strb r2, [r0, r8]			@;c+1
					add r8, #1
					strb r1, [r0, r8]			@;f
					b .Lfi_vec
				.Lcod4_2:
			.Lpos3:
			cmp r4, #3							@;si cod_pos_ini==3
			bne .Lpos4							
				mov r8, #0						@;r8=registre index del vector de direccions @;guardar pos_inicial					
				strb r2, [r0, r8]				@;c
				add r8, #1
				sub r1, #1
				strb r1, [r0, r8]				@;f-1
				add r1, #1
				cmp r3, #0						@;si cod_ori==0
				bne .Lcod1_3
					add r2, #1
					add r8, #1
					strb r2, [r0, r8]			@;c+1
					add r8, #1
					strb r1, [r0, r8]			@;f
					add r2, #1
					add r8, #1
					strb r2, [r0, r8]			@;c+2
					add r8, #1
					strb r1, [r0, r8]			@;f
					b .Lfi_vec
				.Lcod1_3:
				cmp r3, #1						@;si cod_ori==1
				bne .Lcod2_3
					add r8, #1
					strb r2, [r0, r8]			@;c
					add r1, #1
					add r8, #1
					strb r1, [r0, r8]			@;f+1
					add r8, #1
					strb r2, [r0, r8]			@;c
					add r1, #1
					add r8, #1
					strb r1, [r0, r8]			@;f+2
					b .Lfi_vec
				.Lcod2_3:				
				cmp r3, #2						@;si cod_ori==2
				bne .Lcod3_3
					sub r2, #1
					add r8, #1
					strb r2, [r0, r8]			@;c-1
					add r8, #1
					strb r1, [r0, r8]			@;f
					sub r2, #1
					add r8, #1
					strb r2, [r0, r8]			@;c-2
					add r8, #1
					strb r1, [r0, r8]			@;f
					b .Lfi_vec
				.Lcod3_3:
				cmp r3, #4						@;si cod_ori==4
				bne .Lcod4_3
					sub r2, #1
					add r8, #1
					strb r2, [r0, r8]			@;c-1
					add r8, #1
					strb r1, [r0, r8]			@;f
					add r2, #2
					add r8, #1
					strb r2, [r0, r8]			@;c+1
					add r8, #1
					strb r1, [r0, r8]			@;f
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
@;		R5 = matriz de juego
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
