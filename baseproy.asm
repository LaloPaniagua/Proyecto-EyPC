title "Proyecto: Tetris" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada página de código
	.model small	;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
	.386			;directiva para indicar version del procesador
	.stack 512 		;Define el tamano del segmento de stack, se mide en bytes
	.data			;Definicion del segmento de datos
	x db 6
	y db  6
	flagBorrar db 0
	time db 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Definición de constantes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Valor ASCII de caracteres para el marco del programa
marcoEsqInfIzq 		equ 	200d 	;'╚'
marcoEsqInfDer 		equ 	188d	;'╝'
marcoEsqSupDer 		equ 	187d	;'╗'
marcoEsqSupIzq 		equ 	201d 	;'╔'
marcoCruceVerSup	equ		203d	;'╦'
marcoCruceHorDer	equ 	185d 	;'╣'
marcoCruceVerInf	equ		202d	;'╩'
marcoCruceHorIzq	equ 	204d 	;'╠'
marcoCruce 			equ		206d	;'╬'
marcoHor 			equ 	205d 	;'═'
marcoVer 			equ 	186d 	;'║'
;Atributos de color de BIOS
;Valores de color para carácter
cNegro 			equ		00h
cAzul 			equ		01h
cVerde 			equ 	02h
cCyan 			equ 	03h
cRojo 			equ 	04h
cMagenta 		equ		05h
cCafe 			equ 	06h
cGrisClaro		equ		07h
cGrisOscuro		equ		08h
cAzulClaro		equ		09h
cVerdeClaro		equ		0Ah
cCyanClaro		equ		0Bh
cRojoClaro		equ		0Ch
cMagentaClaro	equ		0Dh
cAmarillo 		equ		0Eh
cBlanco 		equ		0Fh
;Valores de color para fondo de carácter
bgNegro 		equ		00h
bgAzul 			equ		10h
bgVerde 		equ 	20h
bgCyan 			equ 	30h
bgRojo 			equ 	40h
bgMagenta 		equ		50h
bgCafe 			equ 	60h
bgGrisClaro		equ		70h
bgGrisOscuro	equ		80h
bgAzulClaro		equ		90h
bgVerdeClaro	equ		0A0h
bgCyanClaro		equ		0B0h
bgRojoClaro		equ		0C0h
bgMagentaClaro	equ		0D0h
bgAmarillo 		equ		0E0h
bgBlanco 		equ		0F0h
;Valores para delimitar el área de juego
lim_superior 	equ		1
lim_inferior 	equ		23
lim_izquierdo 	equ		1
lim_derecho 	equ		30
;Valores de referencia para la posición inicial de la primera pieza
ini_columna 	equ 	lim_derecho/2
ini_renglon 	equ 	2

;Valores para la posición de los controles e indicadores dentro del juego
;Next
next_col 		equ  	lim_derecho+7
next_ren 		equ  	4

;Data
hiscore_ren	 	equ 	10
hiscore_col 	equ 	lim_derecho+7
level_ren	 	equ 	12
level_col 		equ 	lim_derecho+7
lines_ren	 	equ 	14
lines_col 		equ 	lim_derecho+7

;Botón STOP
stop_col 		equ 	lim_derecho+15
stop_ren 		equ 	lim_inferior-4
stop_izq 		equ 	stop_col
stop_der 		equ 	stop_col+2
stop_sup 		equ 	stop_ren
stop_inf 		equ 	stop_ren+2

;Botón PAUSE
pause_col 		equ 	lim_derecho+25
pause_ren 		equ 	lim_inferior-4
pause_izq 		equ 	pause_col
pause_der 		equ 	pause_col+2
pause_sup 		equ 	pause_ren
pause_inf 		equ 	pause_ren+2

;Botón PLAY
play_col 		equ 	lim_derecho+35
play_ren 		equ 	lim_inferior-4
play_izq 		equ 	play_col
play_der 		equ 	play_col+2
play_sup 		equ 	play_ren
play_inf 		equ 	play_ren+2

;Piezas
linea 			equ 	0
cuadro 			equ 	1
lnormal 		equ 	2
linvertida	 	equ 	3
tnormal 		equ 	4
snormal 		equ 	5
sinvertida 		equ 	6

;status
paro 			equ 	0
activo 			equ 	1
pausa			equ 	2pieza_col
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;////////////////////////////////////////////////////
;Definición de variables
;////////////////////////////////////////////////////
titulo 			db 		"TETRIS"
finTitulo 		db 		""
levelStr 		db 		"LEVEL"
finLevelStr 	db 		""
linesStr 		db 		"LINES"
finLinesStr 	db 		""
hiscoreStr		db 		"HI-SCORE"
finHiscoreStr 	db 		""
nextStr			db 		"NEXT"
finNextStr 		db 		""
blank			db 		"     "
lines_score 	dw 		0
hiscore 		dw 		0
speed 			dw 		4
next 			db 		?
isNext			db		0 			;Bandera que determina si DIBUJA_PIEZA está dibujando una next o la actual.
status_linea	db		1			;Bandera que indica en que posición está la linea
aux_giro		db		0			;Ayuda al giro de la linea, 0 es izquierda 1 es derecha
col_det			db		0			;Indica si se ha detectado una colisión

;Coordenadas de la posición de referencia para la pieza en el área de juego
pieza_col		db 		ini_columna
pieza_ren		db 		ini_renglon
;Coordenadas de los pixeles correspondientes a la pieza en el área de juego
;El arreglo cols guarda las columnas, y rens los renglones
pieza_cols 		db 		0,0,0,0
pieza_rens 		db 		0,0,0,0
;Coordenadas para el bloque negro
bn_cols        	db		0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3
bn_rens         db      1,1,1,1,2,2,2,2,3,3,3,3,0,0,0,0
;Matrix de figura (Muestra el estado actual de la figura en una matriz binaria
cm_r1			db		0,0,0			; Current_matriz
cm_r2			db		0,0,0
cm_r3			db		0,0,0
;Valor de la pieza actual correspondiente a las constantes Piezas
pieza_actual 	db 		tnormal
;Color de la pieza actual, correspondiente a los colores del carácter
actual_color 	db 		0
;Coordenadas de los pixeles correspondientes a la pieza siguiente
next_cols 		db 		0,0,0,0
next_rens 		db 		0,0,0,0
;Color de la pieza siguiente, correspondiente con los colores del carácter
next_color 		db 		0
;Valor de la pieza siguiente correspondiente a Piezas
pieza_next 		db 		cuadro
;A continuación se tienen algunas variables auxiliares
;Variables min y max para almacenar los extremos izquierdo, derecho, inferior y superior, para detectar colisiones
pieza_col_max 	db 		0
pieza_col_min 	db 		0
pieza_ren_max 	db 		0
pieza_ren_min 	db 		0
;Variable para pasar como parámetro al imprimir una pieza
pieza_color 	db 		0
;Variables auxiliares de uso general
aux1	 		db 		0
aux2 			db 		0
aux3			db		0

;Variables auxiliares para el manejo de posiciones
col_aux 		db 		0
ren_aux 		db 		0

;variables para manejo del reloj del sistema
ticks 			dw		0 		;contador de ticks
tick_ms			dw 		55 		;55 ms por cada tick del sistema, esta variable se usa para operación de MUL convertir ticks a segundos
mil				dw		1000 	;dato de valor decimal 1000 para operación DIV entre 1000
diez 			dw 		10

status 			db 		0 		;Status de juegos: 0 stop, 1 active, 2 pause
conta 			db 		0 		;Contador auxiliar para algunas operaciones

;Variables que sirven de parámetros de entrada para el procedimiento IMPRIME_BOTON
boton_caracter 	db 		0
boton_renglon 	db 		0
boton_columna 	db 		0
boton_color		db 		0


;Auxiliar para calculo de coordenadas del mouse
ocho			db 		8
;Cuando el driver del mouse no está disponible
no_mouse		db 		'No se encuentra driver de mouse. Presione [enter] para salir$'

;////////////////////////////////////////////////////

;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;Macros;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;
;clear - Limpia pantalla
clear macro
	mov ax,0003h 	;ah = 00h, selecciona modo video
					;al = 03h. Modo texto, 16 colores
	int 10h		;llama interrupcion 10h con opcion 00h. 
				;Establece modo de video limpiando pantalla
endm

;posiciona_cursor - Cambia la posición del cursor a la especificada con 'renglon' y 'columna' 
posiciona_cursor macro renglon,columna
	mov dh,renglon	;dh = renglon
	mov dl,columna	;dl = columna
	mov bx,0
	mov ax,0200h 	;preparar ax para interrupcion, opcion 02h
	int 10h 		;interrupcion 10h y opcion 02h. Cambia posicion del cursor
endm 

;inicializa_ds_es - Inicializa el valor del registro DS y ES
inicializa_ds_es 	macro
	mov ax,@data
	mov ds,ax
	mov es,ax 		;Este registro se va a usar, junto con BP, para imprimir cadenas utilizando interrupción 10h
endm

;muestra_cursor_mouse - Establece la visibilidad del cursor del mouser
muestra_cursor_mouse	macro
	mov ax,1		;opcion 0001h
	int 33h			;int 33h para manejo del mouse. Opcion AX=0001h
					;Habilita la visibilidad del cursor del mouse en el programa
endm

;posiciona_cursor_mouse - Establece la posición inicial del cursor del mouse
posiciona_cursor_mouse	macro columna,renglon
	mov dx,renglon
	mov cx,columna
	mov ax,4		;opcion 0004h
	int 33h			;int 33h para manejo del mouse. Opcion AX=0001h
					;Habilita la visibilidad del cursor del mouse en el programa
endm

;oculta_cursor_teclado - Oculta la visibilidad del cursor del teclado
oculta_cursor_teclado	macro
	mov ah,01h 		;Opcion 01h
	mov cx,2607h 	;Parametro necesario para ocultar cursor
	int 10h 		;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm

;apaga_cursor_parpadeo - Deshabilita el parpadeo del cursor cuando se imprimen caracteres con fondo de color
;Habilita 16 colores de fondo
apaga_cursor_parpadeo	macro
	mov ax,1003h 		;Opcion 1003h
	xor bl,bl 			;BL = 0, parámetro para int 10h opción 1003h
  	int 10h 			;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm

;imprime_caracter_color - Imprime un caracter de cierto color en pantalla, especificado por 'caracter', 'color' y 'bg_color'. 
;Los colores disponibles están en la lista a continuacion;
; Colores:
; 0h: Negro
; 1h: Azul
; 2h: Verde
; 3h: Cyan
; 4h: Rojo
; 5h: Magenta
; 6h: Cafe
; 7h: Gris Claro
; 8h: Gris Oscuro
; 9h: Azul Claro
; Ah: Verde Claro
; Bh: Cyan Claro
; Ch: Rojo Claro
; Dh: Magenta Claro
; Eh: Amarillo
; Fh: Blanco
; utiliza int 10h opcion 09h
; 'caracter' - caracter que se va a imprimir
; 'color' - color que tomará el caracter
; 'bg_color' - color de fondo para el carácter en la celda
; Cuando se define el color del carácter, éste se hace en el registro BL:
; La parte baja de BL (los 4 bits menos significativos) define el color del carácter
; La parte alta de BL (los 4 bits más significativos) define el color de fondo "background" del carácter
imprime_caracter_color macro caracter,color,bg_color
	mov ah,09h				;preparar AH para interrupcion, opcion 09h
	mov al,caracter 		;AL = caracter a imprimir
	mov bh,0				;BH = numero de pagina
	mov bl,color 			
	or bl,bg_color 			;BL = color del caracter
							;'color' define los 4 bits menos significativos 
							;'bg_color' define los 4 bits más significativos 
	mov cx,1				;CX = numero de veces que se imprime el caracter
							;CX es un argumento necesario para opcion 09h de int 10h
	int 10h 				;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm

;imprime_caracter_color - Imprime un caracter de cierto color en pantalla, especificado por 'caracter', 'color' y 'bg_color'. 
; utiliza int 10h opcion 09h
; 'cadena' - nombre de la cadena en memoria que se va a imprimir
; 'long_cadena' - longitud (en caracteres) de la cadena a imprimir
; 'color' - color que tomarán los caracteres de la cadena
; 'bg_color' - color de fondo para los caracteres en la cadena
imprime_cadena_color macro cadena,long_cadena,color,bg_color
	mov ah,13h				;preparar AH para interrupcion, opcion 13h
	lea bp,cadena 			;BP como apuntador a la cadena a imprimir
	mov bh,0				;BH = numero de pagina
	mov bl,color 			
	or bl,bg_color 			;BL = color del caracter
							;'color' define los 4 bits menos significativos 
							;'bg_color' define los 4 bits más significativos 
	mov cx,long_cadena		;CX = longitud de la cadena, se tomarán este número de localidades a partir del apuntador a la cadena
	int 10h 				;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm

;lee_mouse - Revisa el estado del mouse
;Devuelve:
;;BX - estado de los botones
;;;Si BX = 0000h, ningun boton presionado
;;;Si BX = 0001h, boton izquierdo presionado
;;;Si BX = 0002h, boton derecho presionado
;;;Si BX = 0003h, boton izquierdo y derecho presionados
;;CX - columna en la que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
;;DX - renglon en el que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
;Ejemplo: Si la int 33h devuelve la posición (400,120) 
;Al convertir a resolución => 80x25 =>Columna: 400 x 80 / 640 = 50; Renglon: (120 x 25 / 200) = 15 => (50,15)
lee_mouse	macro
	mov ax,0003h
	int 33h
endm

;comprueba_mouse - Revisa si el driver del mouse existe
comprueba_mouse 	macro
	mov ax,0		;opcion 0
	int 33h			;llama interrupcion 33h para manejo del mouse, devuelve un valor en AX
					;Si AX = 0000h, no existe el driver. Si AX = FFFFh, existe driver
endm

;delimita_mouse_h - Delimita la posición del mouse horizontalmente dependiendo los valores 'minimo' y 'maximo'
delimita_mouse_h 	macro minimo,maximo
	mov cx,minimo  	;establece el valor mínimo horizontal en CX
	mov dx,maximo  	;establece el valor máximo horizontal en CX
	mov ax,7		;opcion 7
	int 33h			;llama interrupcion 33h para manejo del mouse
endm

;Imprime una línea negra en el área de juego
dibuja_linea_negra 	macro renglon
	mov cx,30
	linea_negra:
		posiciona_cursor renglon,cl
		mov dx,cx
		imprime_caracter_color 254,cNegro,bgNegro
		mov cx,dx
		loop linea_negra
endm



;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;Fin Macros;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

	.code
inicio:					;etiqueta inicio
	inicializa_ds_es
	comprueba_mouse		;macro para revisar driver de mouse
	xor ax,0FFFFh		;compara el valor de AX con FFFFh, si el resultado es zero, entonces existe el driver de mouse
	jz imprime_ui		;Si existe el driver del mouse, entonces salta a 'imprime_ui'
	;Si no existe el driver del mouse entonces se muestra un mensaje
	lea dx,[no_mouse]
	mov ax,0900h		;opcion 9 para interrupcion 21h
	int 21h				;interrupcion 21h. Imprime cadena.
	jmp salir_enter		;salta a 'salir_enter'
imprime_ui:
	clear 					;limpia pantalla
	oculta_cursor_teclado	;oculta cursor del mouse
	apaga_cursor_parpadeo 	;Deshabilita parpadeo del cursor
	call DIBUJA_UI 			;procedimiento que dibuja marco de la interfaz de usuario
	call GENERAR_PIEZA_NEXT
	;mov pieza_actual,4
	call DIBUJA_NEXT
	call DIBUJA_ACTUAL
	muestra_cursor_mouse 	;hace visible el cursor del mouse
	posiciona_cursor_mouse 320d,16d	;establece la posición del mouse
;Revisar que el boton izquierdo del mouse no esté presionado
;Si el botón está suelto, continúa a la sección "mouse"
;si no, se mantiene indefinidamente en "mouse_no_clic" hasta que se suelte
mouse_no_clic:
;;;;;;;;;;;;;;CONTROL DE TECLADO (SO FAR);;;;;;;;;;;;;;;
teclado:
	call GRAVEDAD
	mov ah, 01h ; OJO TIENE QUE ESTAR EN MINUSCULAS PARA FUNCIONAR
    int 16h
    jz teclado
	mov ah, 0  ; Se lee la tecla del teclado cuando el mouse no se presiona
    int 16h 
    cmp al,97 ; a checker (izquierda)
    je keya 
    cmp al,100 ; d checker (derecha)
    je keyd
    cmp al,115 ; s chechker (baja)
    je keys
    cmp al,113 ; q checker (Sale del programa)
    je salir
    cmp al,105
    je keyi
	cmp al, 106 ; j checker  (rota a la derecha)
	je keyj
	cmp al,102  ; f checker (rota a la izquierda 
	je keyf
	cmp al,119 ; w checker (SUBE SOLO PARA PRUEBAS)
	je keyw
    cmp al,120 ;x Dummy key (Para utilizar el mouse primero se tiene que dar x
    			; antes de cada click)
   	je mouse
   	jmp teclado
keyi:

	jmp teclado
keya: ; Desplazamiento a la izquierda
	call MOVER_IZQ
	jmp teclado
keys:; Desplazamiento hacia abajo
	call MOVER_ABAJO
	jmp teclado
keyd: ;Desplazamiento a la derecha
	call MOVER_DER
	jmp teclado
keyj:
	call GIRO_DER
	jmp teclado
keyf:
	call GIRO_IZQ
	jmp teclado
keyw:
	call MOVER_ARRIBA
	jmp teclado


;Lee el mouse y avanza hasta que se haga clic en el boton izquierdo
mouse:
	lee_mouse
conversion_mouse:
	;Leer la posicion del mouse y hacer la conversion a resolucion
	;80x25 (columnas x renglones) en modo texto
	mov ax,dx 			;Copia DX en AX. DX es un valor entre 0 y 199 (renglon)
	div [ocho] 			;Division de 8 bits
						;divide el valor del renglon en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov dx,ax 			;Copia AX en DX. AX es un valor entre 0 y 24 (renglon)

	mov ax,cx 			;Copia CX en AX. CX es un valor entre 0 y 639 (columna)
	div [ocho] 			;Division de 8 bits
						;divide el valor de la columna en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov cx,ax 			;Copia AX en CX. AX es un valor entre 0 y 79 (columna)

	;Aquí se revisa si se hizo clic en el botón izquierdo
	test bx,0001h 		;Para revisar si el boton izquierdo del mouse fue presionado
	jz mouse 			;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Aqui va la lógica de la posicion del mouse;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Si el mouse fue presionado en el renglon 0
	;se va a revisar si fue dentro del boton [X]
	cmp dx,0
	je boton_x
	jmp mouse_no_clic
boton_x:
	jmp boton_x1
;Lógica para revisar si el mouse fue presionado en [X]
;[X] se encuentra en renglon 0 y entre columnas 76 y 78
boton_x1:
	cmp cx,76
	jge boton_x2
	jmp mouse_no_clic
boton_x2:
	cmp cx,78
	jbe boton_x3
	jmp mouse_no_clic
boton_x3:
	;Se cumplieron todas las condiciones
	jmp salir

	jmp mouse_no_clic
;Si no se encontró el driver del mouse, muestra un mensaje y el usuario debe salir tecleando [enter]
salir_enter:
	mov ah,08h
	int 21h 			;int 21h opción 08h: recibe entrada de teclado sin eco y guarda en AL
	cmp al,0Dh			;compara la entrada de teclado si fue [enter]
	jnz salir_enter 	;Sale del ciclo hasta que presiona la tecla [enter]

salir:				;inicia etiqueta salir
	clear 			;limpia pantalla
	mov ax,4C00h	;AH = 4Ch, opción para terminar programa, AL = 0 Exit Code, código devuelto al finalizar el programa
	int 21h			;señal 21h de interrupción, pasa el control al sistema operativo

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;PROCEDIMIENTOS;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	DIBUJA_UI proc
		;imprimir esquina superior izquierda del marco
		posiciona_cursor 0,0
		imprime_caracter_color marcoEsqSupIzq,cGrisClaro,bgNegro
		
		;imprimir esquina superior derecha del marco
		posiciona_cursor 0,79
		imprime_caracter_color marcoEsqSupDer,cGrisClaro,bgNegro
		
		;imprimir esquina inferior izquierda del marco
		posiciona_cursor 24,0
		imprime_caracter_color marcoEsqInfIzq,cGrisClaro,bgNegro
		
		;imprimir esquina inferior derecha del marco
		posiciona_cursor 24,79
		imprime_caracter_color marcoEsqInfDer,cGrisClaro,bgNegro
		
		;imprimir marcos horizontales, superior e inferior
		mov cx,78 		;CX = 004Eh => CH = 00h, CL = 4Eh 
	marcos_horizontales:
		mov [col_aux],cl
		;Superior
		posiciona_cursor 0,[col_aux]
		imprime_caracter_color marcoHor,cGrisClaro,bgNegro
		;Inferior
		posiciona_cursor 24,[col_aux]
		imprime_caracter_color marcoHor,cGrisClaro,bgNegro
		
		mov cl,[col_aux]
		loop marcos_horizontales

		;imprimir marcos verticales, derecho e izquierdo
		mov cx,23 		;CX = 0017h => CH = 00h, CL = 17h 
	marcos_verticales:
		mov [ren_aux],cl
		;Izquierdo
		posiciona_cursor [ren_aux],0
		imprime_caracter_color marcoVer,cGrisClaro,bgNegro
		;Derecho
		posiciona_cursor [ren_aux],79
		imprime_caracter_color marcoVer,cGrisClaro,bgNegro
		;Interno
		posiciona_cursor [ren_aux],lim_derecho+1
		imprime_caracter_color marcoVer,cGrisClaro,bgNegro

		mov cl,[ren_aux]
		loop marcos_verticales

		;imprimir marcos horizontales internos
		mov cx,79-lim_derecho-1 		
	marcos_horizontales_internos:
		push cx
		mov [col_aux],cl
		add [col_aux],lim_derecho
		;Interno superior 
		posiciona_cursor 8,[col_aux]
		imprime_caracter_color marcoHor,cGrisClaro,bgNegro

		;Interno inferior
		posiciona_cursor 16,[col_aux]
		imprime_caracter_color marcoHor,cGrisClaro,bgNegro

		mov cl,[col_aux]
		pop cx
		loop marcos_horizontales_internos

		;imprime intersecciones internas	
		posiciona_cursor 0,lim_derecho+1
		imprime_caracter_color marcoCruceVerSup,cGrisClaro,bgNegro
		posiciona_cursor 24,lim_derecho+1
		imprime_caracter_color marcoCruceVerInf,cGrisClaro,bgNegro

		posiciona_cursor 8,lim_derecho+1
		imprime_caracter_color marcoCruceHorIzq,cGrisClaro,bgNegro
		posiciona_cursor 8,79
		imprime_caracter_color marcoCruceHorDer,cGrisClaro,bgNegro

		posiciona_cursor 16,lim_derecho+1
		imprime_caracter_color marcoCruceHorIzq,cGrisClaro,bgNegro
		posiciona_cursor 16,79
		imprime_caracter_color marcoCruceHorDer,cGrisClaro,bgNegro

		;imprimir [X] para cerrar programa
		posiciona_cursor 0,76
		imprime_caracter_color '[',cGrisClaro,bgNegro
		posiciona_cursor 0,77
		imprime_caracter_color 'X',cRojoClaro,bgNegro
		posiciona_cursor 0,78
		imprime_caracter_color ']',cGrisClaro,bgNegro

		;imprimir título
		posiciona_cursor 0,37
		imprime_cadena_color [titulo],finTitulo-titulo,cBlanco,bgNegro
		call IMPRIME_TEXTOS
		call IMPRIME_BOTONES
		call IMPRIME_DATOS_INICIALES
		ret
	endp

	IMPRIME_TEXTOS proc
		;Imprime cadena "NEXT"
		posiciona_cursor next_ren,next_col
		imprime_cadena_color nextStr,finNextStr-nextStr,cGrisClaro,bgNegro

		;Imprime cadena "LEVEL"
		posiciona_cursor level_ren,level_col
		imprime_cadena_color levelStr,finlevelStr-levelStr,cGrisClaro,bgNegro

		;Imprime cadena "LINES"
		posiciona_cursor lines_ren,lines_col
		imprime_cadena_color linesStr,finLinesStr-linesStr,cGrisClaro,bgNegro

		;Imprime cadena "HI-SCORE"
		posiciona_cursor hiscore_ren,hiscore_col
		imprime_cadena_color hiscoreStr,finHiscoreStr-hiscoreStr,cGrisClaro,bgNegro
		ret
	endp

	IMPRIME_BOTONES proc
		;Botón STOP
		mov [boton_caracter],254d
		mov [boton_color],bgAmarillo
		mov [boton_renglon],stop_ren
		mov [boton_columna],stop_col
		call IMPRIME_BOTON
		;Botón PAUSE
		mov [boton_caracter],19d
		mov [boton_color],bgAmarillo
		mov [boton_renglon],pause_ren
		mov [boton_columna],pause_col
		call IMPRIME_BOTON
		;Botón PLAY
		mov [boton_caracter],16d
		mov [boton_color],bgAmarillo
		mov [boton_renglon],play_ren
		mov [boton_columna],play_col
		call IMPRIME_BOTON
		ret
	endp

	IMPRIME_SCORES proc
		call IMPRIME_LINES
		call IMPRIME_HISCORE
		call IMPRIME_LEVEL
		ret
	endp

	IMPRIME_LINES proc
		mov [ren_aux],lines_ren
		mov [col_aux],lines_col+20
		mov bx,[lines_score]
		call IMPRIME_BX
		ret
	endp

	IMPRIME_HISCORE proc
		mov [ren_aux],hiscore_ren
		mov [col_aux],hiscore_col+20
		mov bx,[hiscore]
		call IMPRIME_BX
		ret
	endp

	IMPRIME_LEVEL proc
		mov [ren_aux],level_ren
		mov [col_aux],level_col+20
		mov bx,[lines_score]
		call IMPRIME_BX
		ret
	endp

	;BORRA_SCORES borra los marcadores numéricos de pantalla sustituyendo la cadena de números por espacios
	BORRA_SCORES proc
		call BORRA_SCORE
		call BORRA_HISCORE
		ret
	endp

	BORRA_SCORE proc
		posiciona_cursor lines_ren,lines_col+20 		;posiciona el cursor relativo a lines_ren y score_col
		imprime_cadena_color blank,5,cBlanco,bgNegro 	;imprime cadena blank (espacios) para "borrar" lo que está en pantalla
		ret
	endp

	BORRA_HISCORE proc
		posiciona_cursor hiscore_ren,hiscore_col+20 	;posiciona el cursor relativo a hiscore_ren y hiscore_col
		imprime_cadena_color blank,5,cBlanco,bgNegro 	;imprime cadena blank (espacios) para "borrar" lo que está en pantalla
		ret
	endp

	;Imprime el valor del registro BX como entero sin signo (positivo)
	;Se imprime con 5 dígitos (incluyendo ceros a la izquierda)
	;Se usan divisiones entre 10 para obtener dígito por dígito en un LOOP 5 veces (una por cada dígito)
	IMPRIME_BX proc
		mov ax,bx
		mov cx,5
	div10:
		xor dx,dx
		div [diez]
		push dx
		loop div10
		mov cx,5
	imprime_digito:
		mov [conta],cl
		posiciona_cursor [ren_aux],[col_aux]
		pop dx
		or dl,30h
		imprime_caracter_color dl,cBlanco,bgNegro
		xor ch,ch
		mov cl,[conta]
		inc [col_aux]
		loop imprime_digito
		ret
	endp

	IMPRIME_DATOS_INICIALES proc
		call DATOS_INICIALES 		;inicializa variables de juego
		call IMPRIME_SCORES
		;implementar
		ret
	endp

	;Inicializa variables del juego
	DATOS_INICIALES proc
		mov [lines_score],0
		mov [pieza_rens],ini_renglon
		mov [pieza_cols],ini_columna
		mov [pieza_ren],ini_renglon
		mov [pieza_col],ini_columna
		;agregar otras variables necesarias
		ret
	endp

	;procedimiento IMPRIME_BOTON
	;Dibuja un boton que abarca 3 renglones y 5 columnas
	;con un caracter centrado dentro del boton
	;en la posición que se especifique (esquina superior izquierda)
	;y de un color especificado
	;Utiliza paso de parametros por variables globales
	;Las variables utilizadas son:
	;boton_caracter: debe contener el caracter que va a mostrar el boton
	;boton_renglon: contiene la posicion del renglon en donde inicia el boton
	;boton_columna: contiene la posicion de la columna en donde inicia el boton
	;boton_color: contiene el color del boton
	IMPRIME_BOTON proc
	 	;background de botón
		mov ax,0600h 		;AH=06h (scroll up window) AL=00h (borrar)
		mov bh,cRojo	 	;Caracteres en color amarillo
		xor bh,[boton_color]
		mov ch,[boton_renglon]
		mov cl,[boton_columna]
		mov dh,ch
		add dh,2
		mov dl,cl
		add dl,2
		int 10h
		mov [col_aux],dl
		mov [ren_aux],dh
		dec [col_aux]
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color [boton_caracter],cRojo,[boton_color]
	 	ret 			;Regreso de llamada a procedimiento
	endp	 			;Indica fin de procedimiento IMPRIME_BOTON para el ensamblador
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Los siguientes procedimientos se utilizan para dibujar piezas y utilizan los mismos parámetros
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Como parámetros se utilizan:
	;col_aux y ren_aux: Toma como referencia los valores establecidos en ren_aux y en col_aux
	;esas coordenadas son la referencia (esquina superior izquierda) de una matriz 4x4
	;si - apuntador al arreglo de renglones en donde se van a guardar esas posiciones
	;di - apuntador al arreglo de columnas en donde se van a guardar esas posiciones
	;si y di están parametrizados porque se puede dibujar la pieza actual o la pieza next
	;Se calculan las posiciones y se almacenan en los arreglos correspondientes
	;posteriormente se llama al procedimiento DIBUJA_PIEZA que hace uso de esas posiciones para imprimir la pieza en pantalla

	;Procedimiento para dibujar una pieza de cuadro
	DIBUJA_CUADRO proc
	
		mov [pieza_color],cAmarillo
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		inc ah
		mov [si],al
		mov [di],ah
		inc al
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		dec al
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de línea
	DIBUJA_LINEA proc
	;	mov [cm_r2],1		; 0 0 0 0
	;	mov [cm_r2+1],1  	; 1 1 1 1
	;	mov [cm_r2+2],1		; 0 0 0 0
	;	mov [cm_r2+3],1		; 0 0 0 0
		mov status_linea,1

		mov [pieza_color],cCyanClaro
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		inc ah
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de L
	DIBUJA_L proc
		mov [cm_r2],1		; 0 0 0
		mov [cm_r2+1],1	  	; 1 1 1 
		mov [cm_r2+2],1		; 1 0 0
		mov [cm_r3],1		

		mov [pieza_color],cCafe
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		inc ah
		mov [si],al
		mov [di],ah
		inc al
		mov [si+1],al
		mov [di+1],ah
		dec al
		inc ah
		mov [si+2],al
		mov [di+2],ah
		inc ah
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de L invertida
	DIBUJA_L_INVERTIDA proc
		mov [cm_r2],1		; 0 0 0 
		mov [cm_r2+1],1  	; 1 1 1 
		mov [cm_r2+2],1		; 0 0 1 
		mov [cm_r3+2],1		 

		mov [pieza_color],cAzul
		
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		inc al
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de T
	DIBUJA_T proc
		mov [cm_r2],1		; 0 0 0 
		mov [cm_r2+1],1  	; 1 1 1 
		mov [cm_r2+2],1		; 0 1 0 
		mov [cm_r3+1],1	

		mov [pieza_color],cMagenta
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		inc al
		mov [si+2],al
		mov [di+2],ah
		dec al
		inc ah
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de S
	DIBUJA_S proc
		mov [cm_r2+1],1		; 0 0 0 
		mov [cm_r2+2],1  	; 0 1 1 
		mov [cm_r3],1		; 1 1 0 
		mov [cm_r3+1],1		

		mov [pieza_color],cVerdeClaro
		mov al,[ren_aux]
		mov ah,[col_aux]
		add al,2
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		dec al
		mov [si+2],al
		mov [di+2],ah
		inc ah
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;Procedimiento para dibujar una pieza de S invertida
	DIBUJA_S_INVERTIDA proc
		;call CLEAN_CURRENT_MATRIX
		mov [cm_r2],1		; 0 1 1 
		mov [cm_r2+1],1  	; 1 1 0 
		mov [cm_r3+1],1		; 1 0 1 
		mov [cm_r3+2],1		

		mov [pieza_color],cRojoClaro
		mov al,[ren_aux]
		mov ah,[col_aux]
		inc al
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		inc al
		mov [si+2],al
		mov [di+2],ah
		inc ah
		mov [si+3],al
		mov [di+3],ah
		call DIBUJA_PIEZA
		ret
	endp

	;DIBUJA_PIEZA - procedimiento para imprimir una pieza en pantalla
	;Como parámetros recibe:
	;si - apuntador al arreglo de renglones
	;di - apuntador al arreglo de columnas
	
	DIBUJA_PIEZA proc
		cmp isNext,1
		je is_next
		lea di,[pieza_cols]
		lea si,[pieza_rens]
		mov cx,4
	loop_dibuja_pieza:
		push cx
		push si
		push di
		posiciona_cursor [si],[di]
		imprime_caracter_color 254,[pieza_color],bgGrisOscuro
		pop di
		pop si
		pop cx
		inc di
		inc si
		loop loop_dibuja_pieza
		ret
	is_next:
	lea di,[next_cols]
	lea si,[next_rens]
	mov cx,4
	jmp loop_dibuja_pieza

	endp
	
   BORRA_PIEZA proc
		cmp col_det,01H
		je salir_borrar
		lea di,[pieza_cols]
		lea si,[pieza_rens]
		mov cx,4
	loop_borra_pieza:
		push cx
		push si
		push di
		posiciona_cursor [si],[di]
		imprime_caracter_color 32,0,0
		pop di
		pop si
		pop cx
		inc di
		inc si
		loop loop_borra_pieza
		salir_borrar:
		mov col_det,00H
		ret
	endp

	;DIBUJA_NEXT - se usa para imprimir la pieza siguiente en pantalla
	;Primero se debe calcular qué pieza se va a dibujar
	;Dentro del procedimiento se utilizan variables referentes a la pieza siguiente
	DIBUJA_NEXT proc
		mov isNext,1
		lea di,[next_cols]
		lea si,[next_rens]
		mov [col_aux],next_col+10
		mov [ren_aux],next_ren-1
		cmp [next],cuadro
		je next_cuadro
		cmp [next],linea
		je next_linea
		cmp [next],lnormal
		je next_l
		cmp [next],linvertida
		je next_l_invertida
		cmp [next],tnormal
		je next_t
		cmp [next],snormal
		je next_s
		cmp [next],sinvertida
		je next_s_invertida
		jmp salir_dibuja_next
	next_cuadro:
		mov [pieza_next],cuadro
		mov [next_color],cAmarillo
		call DIBUJA_CUADRO
		jmp salir_dibuja_next
	next_linea:
		mov [pieza_next],linea
		mov [next_color],cCyanClaro
		call DIBUJA_LINEA
		jmp salir_dibuja_next
	next_l:
		mov [pieza_next],lnormal
		mov [next_color],cCafe
		call DIBUJA_L
		jmp salir_dibuja_next
	next_l_invertida:
		mov [pieza_next],linvertida
		mov [next_color],cAzul
		call DIBUJA_L_INVERTIDA
		jmp salir_dibuja_next
	next_t:
		mov [pieza_next],tnormal
		mov [next_color],cMagenta
		call DIBUJA_T
		jmp salir_dibuja_next
	next_s:
		mov [pieza_next],snormal
		mov [next_color],cVerdeClaro
		call DIBUJA_S
		jmp salir_dibuja_next
	next_s_invertida:
		mov [pieza_next],sinvertida
		mov [next_color],cRojoClaro
		call DIBUJA_S_INVERTIDA
	salir_dibuja_next:
		ret
	endp

	;DIBUJA_ACTUAL - se usa para imprimir la pieza actual en pantalla
	;Primero se debe calcular qué pieza se va a dibujar
	;Dentro del procedimiento se utilizan variables referentes a la pieza actual
	DIBUJA_ACTUAL proc
		mov isNext,0
		call CLEAN_CURRENT_MATRIX
		mov pieza_ren,ini_renglon
		mov pieza_col,ini_columna
		lea di,[pieza_cols] ; di es para x
		lea si,[pieza_rens] ; si para y
		mov al,pieza_col
		mov ah,pieza_ren
		mov [col_aux],al ; col_aux <- pieza_col  (x)
		mov [ren_aux],ah ; ren_aux <- pieza_ren  (y)
		;mov [pieza_col],al
		;mov [pieza_ren],ah
		cmp [pieza_actual],cuadro
		je inicia_actual_cuadro
		cmp [pieza_actual],linea
		je inicia_actual_linea
		cmp [pieza_actual],lnormal
		je inicia_actual_l
		cmp [pieza_actual],linvertida
		je inicia_actual_l_invertida
		cmp [pieza_actual],tnormal
		je inicia_actual_t
		cmp [pieza_actual],snormal
		je inicia_actual_s
		cmp [pieza_actual],sinvertida
		je inicia_actual_s_invertida
	inicia_actual_cuadro:
		mov [actual_color],cAmarillo
		call DIBUJA_CUADRO
		jmp salir_inicia_actual
	inicia_actual_linea:
		mov [actual_color],cCyanClaro
		call DIBUJA_LINEA
		jmp salir_inicia_actual
	inicia_actual_l:
		mov [actual_color],cCafe
		call DIBUJA_L
		jmp salir_inicia_actual
	inicia_actual_t:
		mov [actual_color],cMagenta
		call DIBUJA_T
		jmp salir_inicia_actual
	inicia_actual_s:
		mov [actual_color],cVerdeClaro
		call DIBUJA_S
		jmp salir_inicia_actual
	inicia_actual_s_invertida:
		mov [actual_color],cRojoClaro
		call DIBUJA_S_INVERTIDA
		jmp salir_inicia_actual
	inicia_actual_l_invertida:
		mov [actual_color],cAzul
		call DIBUJA_L_INVERTIDA
		jmp salir_inicia_actual
	salir_inicia_actual:
		ret
	endp

	CLEAN_CURRENT_MATRIX proc 	;Limpia la matriz binaria 3x3 que se usa para las piezas
		mov cx,3
		xor ax,ax
		lea di,[cm_r1]
		clean_r1:
		mov [di],al
		inc di
		loop clean_r1

		mov cx,3
		lea di,[cm_r2]
		clean_r2:
		mov [di],al
		inc di
		loop clean_r2

		mov cx,3
		lea di,[cm_r3]
		clean_r3:
		mov [di],al
		inc di
		loop clean_r3
		ret
	endp

	CODEC_MATRIX_3x3 proc ; Realiza una codificación. Donde haya 1's en su matriz, crea una coordenada en di y si
	xor ax,ax
	asig11:				; Si es 1, lo guarda en la pila, sigue verificando
		cmp [cm_r1],1
		jnz asig12
		mov al, [pieza_col]  
		mov ah, [pieza_ren]  
		push ax    ;AX = (AH,AL) = (X,Y)
	asig12:
		cmp [cm_r1+1],1
		jnz asig13
		mov al, [pieza_col]
		inc al
		mov ah, [pieza_ren]
		push ax
	asig13:
		cmp [cm_r1+2],1
		jnz asig21
		mov al, [pieza_col]
		add al,2
		mov ah, [pieza_ren]
		push ax
	asig21:
		cmp [cm_r2],1
		jnz asig22
		mov al, [pieza_col]
		mov ah, [pieza_ren]
		inc ah
		push ax
	asig22:
		cmp [cm_r2+1],1
		jnz asig23
		mov al, [pieza_col]
		inc al
		mov ah, [pieza_ren]
		inc ah
		push ax
	asig23:
		cmp [cm_r2+2],1
		jnz asig31
		mov al, [pieza_col]
		add al,2
		mov ah, [pieza_ren]
		inc ah
		push ax
	asig31:
		cmp [cm_r3],1
		jnz asig32
		mov al, [pieza_col]
		mov ah, [pieza_ren]
		add ah,2
		push ax
	asig32:
		cmp [cm_r3+1],1
		jnz asig33
		mov al, [pieza_col]
		inc al
		mov ah, [pieza_ren]
		add ah,2
		push ax
	asig33:
		cmp [cm_r3+2],1
		jnz coordenadas
		mov al, [pieza_col]
		add al,2
		mov ah, [pieza_ren]
		add ah,2
		push ax
	coordenadas:	; Los bits que fueron 1 se reajustan como coordenadas para dibujar las figuras respectivas 
		lea di,[pieza_cols]
		lea si,[pieza_rens]
		pop ax
		mov [di], al  ; y
		mov [si], ah   ; x
		pop ax
		mov [di+1], al
		mov [si+1], ah
		pop ax
		mov [di+2], al
		mov [si+2], ah
		pop ax
		mov [di+3], al
		mov [si+3], ah
		
		ret
	endp

	ROT_MATRIX_HORA proc ;ah auxiliar 1, al auxiliar2
		mov ah, [cm_r1]
		mov al, [cm_r3]
		mov cm_r1,al
		mov al, [cm_r3+2]
		mov cm_r3,al
		mov al, [cm_r1+2]
		mov [cm_r3+2],al
		mov [cm_r1+2],ah

		mov ah, [cm_r1+1]
		mov al, [cm_r2]
		mov [cm_r1+1],al
		mov al, [cm_r3+1]
		mov [cm_r2],al
		mov al, [cm_r2+2]
		mov [cm_r3+1],al
		mov [cm_r2+2],ah
		ret
	endp

	ROT_MATRIX_ANTIHORA proc
		mov ah, [cm_r1]
		mov al, [cm_r1+2]
		mov cm_r1,al
		mov al, [cm_r3+2]
		mov [cm_r1+2],al
		mov al, [cm_r3]
		mov [cm_r3+2],al
		mov [cm_r3],ah

		mov ah, [cm_r1+1]
		mov al, [cm_r2+2]
		mov [cm_r1+1],al
		mov al, [cm_r3+1]
		mov [cm_r2+2],al
		mov al, [cm_r2]
		mov [cm_r3+1],al
		mov [cm_r2],ah
		ret
	endp


	BORRA_PIEZA_ACTUAL proc
		;Implementar
		ret
	endp

	BORRA_NEXT proc
		posiciona_cursor 4,47
		imprime_caracter_color 254,0,0
		posiciona_cursor 4,48
		imprime_caracter_color 254,0,0
		posiciona_cursor 4,49
		imprime_caracter_color 254,0,0
		posiciona_cursor 4,50
		imprime_caracter_color 254,0,0
		posiciona_cursor 5,47
		imprime_caracter_color 254,0,0
		posiciona_cursor 5,48
		imprime_caracter_color 254,0,0
		posiciona_cursor 5,49
		imprime_caracter_color 254,0,0
		posiciona_cursor 5,50
		imprime_caracter_color 254,0,0
		ret
	endp

	MOVER_IZQ proc
		cmp pieza_cols,lim_izquierdo
		je dejar_mover_izq
		cmp pieza_cols+1,lim_izquierdo
		je dejar_mover_izq
		cmp pieza_cols+2,lim_izquierdo
		je dejar_mover_izq
		cmp pieza_cols+3,lim_izquierdo
		je dejar_mover_izq
		
		call BORRA_PIEZA
		lea di,[pieza_cols]
		dec pieza_col
		mov CX, 4
		loop_izq:
		mov al,[di]
		dec al
		mov [di],al
		inc di
		loop loop_izq
		;;;DETECTA COLISIÓN;;;;;;
		call DETECTAR_COLISION
		cmp col_det,01H
		je cancelar_movimiento_i
		;;;;;;;;;;;;;;;;;;
		call DIBUJA_PIEZA
		ret
		cancelar_movimiento_i:
		call MOVER_DER
		dejar_mover_izq:
		ret
	endp

	MOVER_DER proc
		cmp pieza_cols,lim_derecho
		je dejar_mover_der
		cmp pieza_cols+1,lim_derecho
		je dejar_mover_der
		cmp pieza_cols+2,lim_derecho
		je dejar_mover_der
		cmp pieza_cols+3,lim_derecho
		je dejar_mover_der

		call BORRA_PIEZA
		lea di,[pieza_cols]
		inc pieza_col
		mov CX, 4
		loop_der:
		mov al,[di]
		inc al
		mov [di],al
		inc di
		loop loop_der
		;;;DETECTA COLISIÓN;;;;;;
		call DETECTAR_COLISION
		cmp col_det,01H
		je cancelar_movimiento_d
		;;;;;;;;;;;;;;;;;;
		call DIBUJA_PIEZA
		ret
		cancelar_movimiento_d:
		call MOVER_IZQ
		dejar_mover_der:
		ret
	endp

	MOVER_ABAJO proc
		cmp [pieza_rens],lim_inferior
		je dejar_mover
		cmp [pieza_rens+1],lim_inferior
		je dejar_mover
		cmp [pieza_rens+2],lim_inferior
		je dejar_mover
		cmp [pieza_rens+3],lim_inferior
		je dejar_mover

		call BORRA_PIEZA
		lea di,[pieza_rens]
		inc pieza_ren
		mov CX, 4
		loop_abj:
		mov al,[di]
		inc al
		mov [di],al
		inc di
		loop loop_abj
		;;;DETECTA COLISIÓN;;;;;;
		call DETECTAR_COLISION
		cmp col_det,01H
		je cancelar_movimiento_ab
		;;;;;;;;;;;;;;;;;;

		call DIBUJA_PIEZA
		ret
		cancelar_movimiento_ab:
		call MOVER_ARRIBA
		dejar_mover:
		call RESET_PROC
		ret
	endp

	RESET_PROC proc
		mov pieza_ren,ini_renglon
		mov pieza_col,ini_columna
		call GENERAR_PIEZA_NEXT
		call BORRA_NEXT
		;call CLEAN_CURRENT_MATRIX
		call DIBUJA_NEXT
		;call CLEAN_CURRENT_MATRIX
		call DIBUJA_ACTUAL
		ret
	endp

	MOVER_ARRIBA proc
		cmp pieza_rens,lim_superior
		je dejar_mover
		cmp pieza_rens+1,lim_superior
		je dejar_mover
		cmp pieza_rens+2,lim_superior
		je dejar_mover
		cmp pieza_rens+3,lim_superior
		je dejar_mover

		call BORRA_PIEZA
		lea di,[pieza_rens]
		dec pieza_ren
		mov CX, 4
		loop_arb:
		mov al,[di]
		dec al
		mov [di],al
		inc di
		loop loop_arb
		call DIBUJA_PIEZA
		ret
	endp


	GIRO_DER proc
		call BORRA_PIEZA
		cmp pieza_actual, 1 ; si es un cuadro
		je fin_giro_der
		cmp pieza_actual,0 ; Si es una linea
		je girolinea_der
		normal_der:
		call ROT_MATRIX_HORA
		call CODEC_MATRIX_3x3
		jmp fin_giro_der
		girolinea_der:
		mov aux_giro,1
		call GIRO_LINEA
		fin_giro_der:
		call DIBUJA_PIEZA
		ret
	endp

	GIRO_IZQ proc
		call BORRA_PIEZA
		cmp pieza_actual, 1 ; si es un cuadro
		je fin_giro_izq
		cmp pieza_actual,0 ; Si es una linea
		je girolinea_izq
		normal_iz:
		call ROT_MATRIX_ANTIHORA
		call CODEC_MATRIX_3x3
		jmp fin_giro_izq
		girolinea_izq:
		mov aux_giro,0
		call GIRO_LINEA
		fin_giro_izq:
		call DIBUJA_PIEZA
		ret
	endp
  
	GIRO_LINEA proc
	lea di, [pieza_cols] ;eje x
	lea si, [pieza_rens] ;eje y
	mov al, pieza_ren
	mov ah, pieza_col
	cmp aux_giro, 0 ;Gira a la izquierda
	je GIROS_IZQUIERDOS
	jmp GIROS_DERECHOS
	GIROS_IZQUIERDOS:
	cmp status_linea,1
	je GIRO_12
	cmp status_linea,2
	je GIRO_23
	cmp status_linea,3
	je GIRO_34
	cmp status_linea,4
	je GIRO_41
	GIROS_DERECHOS:
	cmp status_linea,1
	je GIRO_14
	cmp status_linea,2
	je GIRO_21
	cmp status_linea,3
	je GIRO_32
	cmp status_linea,4
	je GIRO_43

	GIRO_12:
	inc ah
	dec	al
	mov status_linea,2
	jmp Vertical

	GIRO_23:
	add al,2
	dec ah
	mov status_linea,3
	jmp Horizontal

	GIRO_34:
	sub al,2
	add ah,2
	mov status_linea,4
	jmp Vertical

	GIRO_41:
	inc al
	sub ah,2
	mov status_linea,1
	jmp Horizontal

	GIRO_14:
	dec al
	add ah,2
	mov status_linea,4
	jmp Vertical

	GIRO_43:
	add al,2
	sub ah,2
	mov status_linea,3
	jmp Horizontal

	GIRO_32:
	sub al,2
	inc ah
	mov status_linea,2
	jmp Vertical

	GIRO_21:
	inc al
	dec ah
	mov status_linea,1
	jmp Horizontal


	Horizontal:   ; AL = Y y AH =X
		mov pieza_ren,al
		mov pieza_col,ah	
		mov [si],al
		mov [di],ah
		inc ah
		mov [si+1],al
		mov [di+1],ah
		inc ah
		mov [si+2],al
		mov [di+2],ah
		inc ah
		mov [si+3],al
		mov [di+3],ah
		jmp salir_giro
	Vertical:
		mov pieza_ren,al
		mov pieza_col,ah
		mov [si],al
		mov [di],ah
		inc al
		mov [si+1],al
		mov [di+1],ah
		inc al
		mov [si+2],al
		mov [di+2],ah
		inc al
		mov [si+3],al
		mov [di+3],ah
		jmp salir_giro
	salir_giro:
		ret
	endp
	
	GRAVEDAD proc
		mov ah,2Ch
		int 21h

		cmp dh,[time]
		je salto_gravedad
		mov [time],dh
		call MOVER_ABAJO
		salto_gravedad:
		ret
	endp
	
	GENERAR_PIEZA_NEXT proc
		mov ah, 02h      
   		int 1Ah
		mov cl, 7d
		mov al,dh
		div cl
		mov cl,[next]
		mov [pieza_actual],cl
		mov [next],ah
		ret 
	endp

	;TOMA COMO PARAMETROS PIEZA_COLS Y PIEZA_RENS que se supone ya deben estar actualizados. 
	;Altera el valor de la vandera col_det a uno si corresponde
	DETECTAR_COLISION proc
		mov col_det,0h
		lea di,[pieza_cols]
		lea si,[pieza_rens]
		mov cx,4
	loop_colisiona:
		push cx
		push si
		push di
		posiciona_cursor [si],[di]
		;detectar colisión 
		mov ah,08h ;checa la casilla y obtiene color (ah) y caracter (al)
		int 10H
		cmp al,254d
		jnz no_colision
			mov col_det,01h
	no_colision:
		pop di
		pop si
		pop cx
		inc di
		inc si
		loop loop_colisiona
		ret
	endp


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;ESTO ES NADA MÁS PARA HACER DEBUG VISUAL
	; mov [boton_caracter],95d
	; mov [boton_color],bgAmarillo
	; mov [boton_renglon],stop_ren
	; mov [boton_columna],stop_col
	; call IMPRIME_BOTON
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;ESTO ES NADA MÁS PARA HACER DEBUG VISUAL
	; mov [boton_caracter],al
	; mov [boton_color],bgAmarillo
	; mov [boton_renglon],stop_ren
	; mov [boton_columna],stop_col
	; call IMPRIME_BOTON

	; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;  xor bx,bx
	;  mov bl,al
	;  mov ren_aux,stop_ren
	;  mov col_aux,stop_col
	;  call IMPRIME_BX 	

	; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;FIN PROCEDIMIENTOS;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end inicio			;fin de etiqueta inicio, fin de programa
