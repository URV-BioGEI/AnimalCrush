/*------------------------------------------------------------------------------

	$ candy2_graf.c $

	Funciones de inicialización de gráficos (ver 'candy2_main.c')

	Analista-programador: santiago.romani@urv.cat
	Programador tarea 2A: Aleix.Marine@estudiants.urv.cat
	Programador tarea 2B: bernat.bosca@estudiants.urv.cat
	Programador tarea 2C: cristina.izquierdo@estudiants.urv.cat
	Programador tarea 2D: albert.canelon@estudiants.urv.cat

------------------------------------------------------------------------------*/
#include <nds.h>
#include <candy2_incl.h>
#include <Graphics_data.h>
#include <Sprites_sopo.h>


/* variables globales */
int n_sprites = 0;					// número total de sprites creados
elemento vect_elem[ROWS*COLUMNS];	// vector de elementos
gelatina mat_gel[ROWS][COLUMNS];	// matriz de gelatinas



// TAREA 2Ab
/* genera_sprites(): inicializar los sprites con prioridad 1, creando la
	estructura de datos y las entradas OAM de los sprites correspondiente a la
	representación de los elementos de las casillas de la matriz que se pasa
	por parámetro (independientemente de los códigos de gelatinas).*/
void genera_sprites(char mat[][COLUMNS])
{
	int i,j;
	
	for (i=0; i<ROWS*COLUMNS; i++)
	{
		vect_elem[i].ii=-1;
	}
	SPR_ocultarSprites(128);
	for (int i=0; i<ROWS; i++)
	{
		for (j=0; j<COLUMNS; j++)
		{
			if ((mat[i][j]>0 && mat[i][j]<7) || (mat[i][j]>8 && mat[i][j]<15) || mat[i][j]>16)
			{
				
				crea_elemento(mat[i][j]&0x7, i, j);
				n_sprites++;
			}
		}
	}
	for (i=0; i<ROWS*COLUMNS; i++)
	{
		SPR_fijarPrioridad(i,1);
	}
	swiWaitForVBlank();
	SPR_actualizarSprites(OAM,128);
}

// TAREA 2Bb
/* genera_mapa2(*mat): generar un mapa de baldosas como un tablero ajedrezado
	de meta-baldosas de 32x32 píxeles (4x4 baldosas), en las posiciones de la
	matriz donde haya que visualizar elementos con o sin gelatina, bloques
	sólidos o espacios vacíos sin elementos, excluyendo sólo los huecos.*/
void genera_mapa2(char mat[][COLUMNS])
{


}



// TAREA 2Cb
/* genera_mapa1(*mat): generar un mapa de baldosas correspondiente a la
	representación de las casillas de la matriz que se pasa por parámetro,
	utilizando meta-baldosas de 32x32 píxeles (4x4 baldosas), visualizando
	las gelatinas simples y dobles y los bloques sólidos con las meta-baldosas
	correspondientes, (para las gelatinas, basta con utilizar la primera
	meta-baldosa de la animación); además, hay que inicializar la matriz de
	control de la animación de las gelatinas mat_gel[][COLUMNS]. */
void genera_mapa1(char mat[][COLUMNS])
{


}



// TAREA 2Db
/* ajusta_imagen3(int ibg): rotar 90 grados a la derecha la imagen del fondo
	cuyo identificador se pasa por parámetro (fondo 3 de procesador principal)
	y desplazarla para que se visualice en vertical a partir del primer píxel
	de la pantalla. */
void ajusta_imagen3(int ibg)
{
	int angle=0;
	bgSetCenter(ibg, 256, 128);
	angle=degreesToAngle(-90);
	bgSetRotate(ibg, angle);
	bgSetScroll(ibg, 140, 0);
	bgUpdate();
}




// TAREAS 2Aa,2Ba,2Ca,2Da
/* init_grafA(): inicializaciones generales del procesador gráfico principal,
				reserva de bancos de memoria y carga de información gráfica,
				generando el fondo 3 y fijando la transparencia entre fondos.*/
void init_grafA()
{
	int bg3A, bg1A, bg2A; 

	videoSetMode(MODE_3_2D | DISPLAY_BG3_ACTIVE |DISPLAY_SPR_1D_LAYOUT | DISPLAY_SPR_ACTIVE);
	
// Tarea 2Aa:
	// reservar banco F para sprites, a partir de 0x06400000								
		vramSetBankF(VRAM_F_MAIN_SPRITE_0x06400000);				//Assigna el banc F com a contenidor principal dels sprites a partir de 0x06400000
// Tareas 2Ba y 2Ca:
	// reservar banco E para fondos 1 y 2, a partir de 0x06000000
		vramSetBankE(VRAM_E_MAIN_BG);											//inicialitzacio de VRAM_E
		bg1A = bgInit(1, BgType_Text8bpp, BgSize_T_256x256, 1, 0); 			//Inicialitzar fondo 1 "text" (bg1) 8bpp 32x32
		bgSetPriority(bg1A, 0);													//Priridat fondo 1 a nivell 0
		decompress(BaldosasTiles, (unsigned int *)0x06000000, LZ77Vram);		//cargar baldosas 
		dmaCopy(BaldosasPal, (unsigned int *)0X05000000, sizeof(BaldosasPal));			//cargar paleta
		

// Tarea 2Da:
	// reservar bancos A y B para fondo 3, a partir de 0x06020000
	vramSetBankA(VRAM_A_MAIN_BG_0x06020000);							//Inicialitzacio de VRAM_A
	vramSetBankB(VRAM_B_MAIN_BG_0x06040000);							//Inicialitzacio de VRAM_B
	bg3A = bgInit(3, BgType_Bmp16, BgSize_B16_512x256, 8, 0);			//Inicialitzar fondo
	bgSetPriority(bg3A, 3);												//Prioridad fondo
	decompress(FondoBitmap, bgGetGfxPtr(bg3A), LZ77Vram);				//Cargar pixeles
	ajusta_imagen3(3);



// Tarea 2Aa:
	// cargar las baldosas de la variable SpritesTiles[] a partir de la
	// dirección virtual de memoria gráfica para sprites, y cargar los colores
	// de paleta asociados contenidos en  la variable SpritesPal[]
		dmaCopy(SpritesTiles, (unsigned int *)0X06400000, sizeof(SpritesTiles)); // copiar baldosas a 0x06400000=SPRITE_GFX, por tanto el desplazamiento de baldosas = 0 cuando bg init,
		dmaCopy(SpritesPal, (unsigned int *) 0x05000200, sizeof(SpritesPal));	//  Sprite Palette display engine A =0x05000200 = SPRITE_PALETTE
// Tarea 2Ba:
	// inicializar el fondo 2 con prioridad 2



// Tarea 2Ca:
	//inicializar el fondo 1 con prioridad 0



// Tareas 2Ba y 2Ca:
	// descomprimir (y cargar) las baldosas de la variable BaldosasTiles[] a
	// partir de la dirección de memoria correspondiente a los gráficos de
	// las baldosas para los fondos 1 y 2, cargar los colores de paleta
	// correspondientes contenidos en la variable BaldosasPal[]


	
// Tarea 2Da:
	// inicializar el fondo 3 con prioridad 3


	// descomprimir (y cargar) la imagen de la variable FondoBitmap[] a partir
	// de la dirección virtual de vídeo correspondiente al banco de vídeoRAM A



	// fijar display A en pantalla inferior (táctil)
	lcdMainOnBottom();

	/* transparencia fondos:
		//	bit 1 = 1 		-> 	BG1 1st target pixel
		//	bit 2 = 1 		-> 	BG2 1st target pixel
		//	bits 7..6 = 01	->	Alpha Blending
		//	bit 11 = 1		->	BG3 2nd target pixel
		//	bit 12 = 1		->	OBJ 2nd target pixel
	*/
	*((u16 *) 0x04000050) = 0x1846;	// 0001100001000110
	/* factor de "blending" (mezcla): 
		//	bits  4..0 = 01001	-> EVA coefficient (1st target)
		//	bits 12..8 = 00111	-> EVB coefficient (2nd target)
	*/
	*((u16 *) 0x04000052) = 0x0709;
}

