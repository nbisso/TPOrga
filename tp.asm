; LINUX
; rax           rdi rsi rdx rcx r8 r9 stack...

; type funcName(p1, p2, p3, p4, p5, p6, p7,..., pn)
;nasm  tp.asm -f elf64 -g -F dwarf 
;gcc   tp.o  -o tp.out -no-pie

;nasm tp.asm -f elf64 && gcc tp.o -o tp.out && ./tp.out
; Se tienen n objetos de pesos P1, P2, ..., Pn (con n <= 20) que deben ser enviados por correo a una
; misma dirección. La forma más simple sería ponerlos todos en un mismo paquete; sin embargo, el
; correo no acepta que los paquetes tengan más de 15 Kg. y la suma de los pesos podría ser mayor
; que eso. Afortunadamente, cada uno de los objetos no pesa más de 15 Kg.
; Se trata entonces de pensar un algoritmo que de un método para armar los paquetes, tratando de
; optimizar su cantidad. Debe escribir un programa en assembler Intel 80x86 que:
; ● Permita la entrada de un entero positivo n.
; ● La entrada de los n pesos, verificando que 0<Pi<=15 donde i <=n.
; ● Los Pi pueden ser valores enteros.
; ● Exhiba en pantalla la forma en que los objetos deben ser dispuestos en los paquetes.
; A su vez existen tres destinos posibles: Posadas, Salta y Tierra del Fuego. El correo por normas internas
; de funcionamiento no puede poner en el mismo paquete objetos que vayan a distinto destino.
; Desarrollar un algoritmo que proporcione una forma de acomodar los paquetes de forma que no haya
; objetos de distinto destino en un mismo paquete y cumpliendo las restricciones de peso.


global	main
extern  puts
extern  fopen
extern  fclose
extern  fgets
extern  sscanf
extern  fwrite
extern  gets
extern  printf

section	.data
    msjInicio			                db	'Bienvenido al TP 1 EJ 8',0
    msjIngCantidadDePaquetes		    db	'Ingrese la cantidad de paquetes a trasladar 1 - 20: ',0
    msjIngPeso              		    db	'Ingrese el peso del paquete entre 1 - 15: ',0
    msjValoresAgregados                 db	'Valores Agregados son: ',0

    inicioPaqueteMsj                 db	'[',0


    lugaresMensaje					    db	"Ingrese el numero del destino: 1)Mar del Plata, 2)Bariloche 3)Posadas.",0
    lugaresVec                          db  "Mar del Plata",0,"Bariloche    ",0,"Posadas      ",0

    numCantidadDePaquetesFormat		    db	'%li',0	;%i 32 bits / %li 64 bits
    msjImpNumCantidadDePaquetes         db	'Usted ingreso %i paquetes a trasladar',10,0

    msjDebug                            db	'peso %i',10,0

    saltoLinea db '',0

    msjElementoResulatdo                db	'%i ',0

    msjDestino                          db	'Destino: %i',10,0
    msjDebug2                           db	'Peso %i destino %s',10,0
    msjParaDestino                      db  'Para el destino %s tenemos:',10,0
    nombreDestino                       db  'XXXXXXXXXXXXX',0

    vecPesos	                        times 20 dw 0
    vecDestinos	                        times 20 dw 0
    posicion		                    dq	1
    posicionY		                    dq	1
    posicionSuma                        dq  1
    destinoPaqueteActualName            db  'XXXXXXXXXXXXX',0
    cambio                              db  'N',0

    vecActual                           times 20 dw 0
    resultado                           times 39 dw 0

    actual  dw 0


section .bss
    buffer		                resb	10
    cantidadDePaquetes		    resq	1
    cantidadDeElementosVector   resq	1
    contador	                resq	1
    contadorY	                resq	1
    contadorSuma	            resq	1
    pesoPaqueteActual           resq    1
    destinoPaqueteActual        resq    1

    suma                        resw    1
    
    

    plusRsp		                resq	1    
    
section  .text
main:
    call mostrarMensajeInicio

    call pedirCantidadDePesos

    call llenarPesos

    call mostrarPesosPorDestino

    ret


mostrarMensajeInicio:
    mov     rdi,msjInicio
    call    puts
    ret

pedirCantidadDePesos:
    pedirCantidadDePesosInicio:
    mov     rdi,msjIngCantidadDePaquetes
    call    puts

	mov		rdi,buffer
	call	gets

    mov		rdi,buffer		;Parametro 1: campo donde están los datos a leer
	mov		rsi,numCantidadDePaquetesFormat	;Parametro 2: dir del string q contiene los formatos
	mov		rdx,cantidadDePaquetes		;Parametro 3: dir del campo que recibirá el dato formateado
    call	checkAlign      ;no va en Windows
    sub		rsp,[plusRsp]   ;sub rsp,32
	call	sscanf
    add		rsp,[plusRsp]   ;add rsp,32

    cmp		rax,1			;rax tiene la cantidad de campos que pudo formatear correctamente
	jl		pedirCantidadDePesosInicio
    ;valido que sea un numero entre 1 a 20
    cmp		dword[cantidadDePaquetes],1
	jl		pedirCantidadDePesosInicio
	cmp		dword[cantidadDePaquetes],20
	jg		pedirCantidadDePesosInicio

	mov		rdi,msjImpNumCantidadDePaquetes
	mov		rsi,[cantidadDePaquetes]
	call	printf

    ret


llenarPesos:
    mov rcx,[cantidadDePaquetes]
    recorrer:

    mov		qword[contador],rcx

    mov		rcx,[posicion]	;rcx = posicion
	dec		rcx							;(posicion-1)
	imul	ebx,ecx,2				;(posicion-1)*longElem

    call pedirPeso
    call pedirLugar
   
    mov	cx,word[pesoPaqueteActual]	
    mov word[vecPesos+ebx],cx

    mov	cx,word[destinoPaqueteActual]	
    mov word[vecDestinos+ebx],cx

	mov		rdi,msjDebug
	mov		rsi,[pesoPaqueteActual]
	call	printf


    inc qword[posicion]

    mov		rcx,qword[contador]			;Recupero el rcx para el loop
    loop recorrer

    mov rdi,msjValoresAgregados
    call puts

    mov rcx,[cantidadDePaquetes]
    mov qword[posicion],1

    recorrer2:
    mov		qword[contador],rcx

    mov rdi,qword[posicion]
    call obtenerDatosParaMostrar

    mov rax,qword[destinoPaqueteActual]

    call obtenerNombreCiudadPorID

    LEA rdx, [lugaresVec + rdi] ;muevo el puntero al lugares vec + el delta

	mov		rdi,msjDebug2
	mov		rsi,qword[pesoPaqueteActual]
    ; mov     rdx,lugaresVec
	call	printf

    inc qword[posicion]

    mov		rcx,qword[contador]			;Recupero el rcx para el loop
    loop recorrer2


    ret

;rax llega el id rdi retorno el nombre
obtenerNombreCiudadPorID:
    ; mov		rdi,msjDebug
	; mov		rsi,qword[destinoPaqueteActual]
	; call	printf
    
    mov		rcx,rax	;rcx = posicion
	dec		rcx							;(posicion-1)
	imul	rbx,rcx,14		;(posicion-1)*longElem
    ; cwde									;eax= elemento (4 bytes / doble word)
	; cdqe									;rax= elemento (8 bytes / quad word)
    mov rdi,rbx
    ret

;de la pos actual toma el vecPesos en pos el peso y del vecdestino en pos el destino
obtenerDatosParaMostrar:
    mov		rcx,rdi	;rcx = posicion
	dec		rcx							;(posicion-1)
	imul	ebx,ecx,2				;(posicion-1)*longElem

    mov		ax,[vecPesos+ebx]	;ax = elemento (2 bytes / word)

    cwde									;eax= elemento (4 bytes / doble word)
	cdqe									;rax= elemento (8 bytes / quad word)

    mov qword[pesoPaqueteActual],rax

    mov		ax,[vecDestinos+ebx]	;ax = elemento (2 bytes / word)

    cwde									;eax= elemento (4 bytes / doble word)
	cdqe									;rax= elemento (8 bytes / quad word)

    mov qword[destinoPaqueteActual],rax
    
    ret


pedirPeso:
    pedirPesoInicio:
    mov     rdi,msjIngPeso
	; mov		rsi,[posicion]
	call	puts

	mov		rdi,buffer
	call	gets

    mov		rdi,buffer		;Parametro 1: campo donde están los datos a leer
	mov		rsi,numCantidadDePaquetesFormat	;Parametro 2: dir del string q contiene los formatos
	mov		rdx,pesoPaqueteActual		;Parametro 3: dir del campo que recibirá el dato formateado
    call	checkAlign      ;no va en Windows
    sub		rsp,[plusRsp]   ;sub rsp,32
	call	sscanf
    add		rsp,[plusRsp]   ;add rsp,32

    cmp		rax,1			;rax tiene la cantidad de campos que pudo formatear correctamente
	jl		pedirPesoInicio
    ;valido que sea un numero entre 1 a 15
    cmp		dword[pesoPaqueteActual],1
	jl		pedirPesoInicio
	cmp		dword[pesoPaqueteActual],15
	jg		pedirPesoInicio

    ret


pedirLugar:
    pedirLugarInicio:
    mov     rdi,lugaresMensaje
	call	puts

	mov		rdi,buffer
	call	gets

    mov		rdi,buffer		;Parametro 1: campo donde están los datos a leer
	mov		rsi,numCantidadDePaquetesFormat	;Parametro 2: dir del string q contiene los formatos
	mov		rdx,destinoPaqueteActual		;Parametro 3: dir del campo que recibirá el dato formateado
    call	checkAlign      ;no va en Windows
    sub		rsp,[plusRsp]   ;sub rsp,32
	call	sscanf
    add		rsp,[plusRsp]   ;add rsp,32

    cmp		rax,1			;rax tiene la cantidad de campos que pudo formatear correctamente
	jl		pedirLugarInicio
    ;valido que sea un numero entre 1 a 3
    cmp		dword[destinoPaqueteActual],1
	jl		pedirLugarInicio
	cmp		dword[destinoPaqueteActual],3
	jg		pedirLugarInicio

    ret



mostrarPesosPorDestino:
    mov rcx,3 ;son 3 ciiuades
    mov qword[posicion],1

    loopCiudades:
    mov		qword[contador],rcx

    mov rax,qword[posicion]
    call obtenerNombreCiudadPorID

    LEA rsi, [lugaresVec + rdi] ;muevo el puntero al lugares vec + el delta

	mov		rdi,msjParaDestino
	call	printf

    call mostrarPaqueteActualPorCiudad


    inc qword[posicion]

    mov		rcx,qword[contador]			;Recupero el rcx para el loop
    loop loopCiudades

    ret

mostrarPaqueteActualPorCiudad:
    ; mov rcx,qword[posicion2]
    call	checkAlign      ;no va en Windows
    sub		rsp,[plusRsp]   ;sub rsp,32

    mov qword[posicionY],1
    mov rcx,[cantidadDePaquetes] ;son N paquetes
    mov qword[cantidadDeElementosVector],0 ;inicio en 0 elementos
    loopPaqueteActual:
        mov		qword[contadorY],rcx 
        
        mov rdi,qword[posicionY]
        call obtenerDatosParaMostrar

        mov rax,[destinoPaqueteActual]

        CMP rax,[posicion]

        JNE seguir

        ;agrego un elemento a recorrer
        inc qword[cantidadDeElementosVector]
        
        call agregarVecActual

        mov rax,qword[destinoPaqueteActual]

        call obtenerNombreCiudadPorID

        LEA rdx, [lugaresVec + rdi] ;muevo el puntero al lugares vec + el delta

        mov		rdi,msjDebug2
        mov		rsi,qword[pesoPaqueteActual]
        ; mov     rdx,lugaresVec
        call	printf

        seguir:
        inc qword[posicionY]
        mov		rcx,qword[contadorY]			;Recupero el rcx para el loop
        loop loopPaqueteActual


        ;aca ya tengo el vec con todos los elementes para ese destino en vecActual

        call ordenarVectorActual
        call crearPaquetes
        call mostrarVectorActual
        ; mov rdi,saltoLinea
        ; call puts
        add		rsp,[plusRsp]   ;sub rsp,32
        ret


mostrarVectorActual:
    call	checkAlign      ;no va en Windows
    sub		rsp,[plusRsp]   ;sub rsp,32

    mov qword[posicionY],1
    mov rcx,39 ;son N paquetes
    CMP qword[cantidadDeElementosVector],0
    JE finMostrarVectorActual
    loopmostrarVectorActual:
        mov     byte[cambio],"Y"
        MOV qword[contadorY],rcx

        mov		rcx,[posicionY]	;rcx = posicion
	    dec		rcx							;(posicion-1)
	    imul	ebx,ecx,2				;(posicion-1)*longElem

        mov		ax,[resultado+ebx]	;ax = elemento (2 bytes / word)

        cwde									;eax= elemento (4 bytes / doble word)
	    cdqe	    

        mov word[actual],ax

        CMP RAX,0
        JE mostrarSiguiente
    

        CMP RAX,-1
        JE finDeLinea

        mov		rdi,msjElementoResulatdo
        mov rsi,rax
        call	printf
        JMP mostrarSiguiente
        finDeLinea:
            mov rdi,saltoLinea
            call puts
        mostrarSiguiente:
        inc qword[posicionY]

        mov	rcx,qword[contadorY]			;Recupero el rcx para el loop
        loop loopmostrarVectorActual
    finMostrarVectorActual:

    add		rsp,[plusRsp]   ;sub rsp,32
    ret

agregarVecActual:
    mov		rcx,[posicionY]	;rcx = posicion
	dec		rcx							;(posicion-1)
	imul	ebx,ecx,2				;(posicion-1)*longElem
   
    mov	cx,word[pesoPaqueteActual]	
    mov word[vecActual+ebx],cx
    ret

ordenarVectorActual:
    call	checkAlign      ;no va en Windows
    sub		rsp,[plusRsp]   ;sub rsp,32

    seguirSwapeando:
    mov qword[posicionY],1
    mov rcx,[cantidadDeElementosVector] ;son N paquetes
    DEC rcx;remuevo uno para hace el buble sort comparando current + next
    CMP rcx,0;si es 0 termine, solo hay 1 elemento
    JLE  finOrdenar
    mov     byte[cambio],"N"
    loopOrdenarVecActual:
        mov		qword[contadorY],rcx 
        ;comparo y swapeo
        
        mov		rcx,[posicionY]	;rcx = posicion
	    dec		rcx							;(posicion-1)
	    imul	ebx,ecx,2				;(posicion-1)*longElem

        mov AX,word[vecActual+ebx]
        CMP AX,word[vecActual+ebx+2]

        JGE continuar
        mov     byte[cambio],"Y"
        mov CX,word[vecActual+ebx+2]
        mov word[vecActual+ebx],CX
        mov word[vecActual+ebx+2],AX

        continuar:
        inc qword[posicionY]
        mov	rcx,qword[contadorY]			;Recupero el rcx para el loop
        loop loopOrdenarVecActual

        CMP byte[cambio],"Y"
        JE seguirSwapeando

    finOrdenar:
    add		rsp,[plusRsp]   ;sub rsp,32
    ret

crearPaquetes:
    call	checkAlign      ;no va en Windows
    sub		rsp,[plusRsp]   ;sub rsp,32

    CMP qword[cantidadDeElementosVector],0
    JE finCearPaquetes

    MOV qword[posicionSuma],1
    
    inicioCrearPaquete:

    MOV word[suma],0
    mov qword[posicionY],1
    mov rcx,[cantidadDeElementosVector] ;son N paquetes

     loopmSumarVectorActual:
        MOV qword[contadorY],rcx

        mov		rcx,[posicionY]	;rcx = posicion
	    dec		rcx							;(posicion-1)
	    imul	ebx,ecx,2				;(posicion-1)*longElem

        mov		ax,[vecActual+ebx]	;ax = elemento (2 bytes / word)

        mov word[actual],ax

        MOV cx,word[suma]
        ADD cx,word[actual]

        CMP cx,15

        JG  seguirSumando
        
        CMP cx,0

        JLE seguirSumando

        CMP cx,word[suma]

        JE seguirSumando

        MOV word[suma],cx

        call sumarAlListado

        seguirSumando:

        inc qword[posicionY]
        mov	rcx,qword[contadorY]			;Recupero el rcx para el loop
        loop loopmSumarVectorActual

        
        CMP word[suma],0
        JE  finCearPaquetes

        mov		rcx,qword[posicionSuma]	;rcx = posicion
	    dec		rcx							;(posicion-1)
	    imul	ebx,ecx,2				;(posicion-1)*longElem

        mov		word[resultado+ebx],-1	;ax = elemento (2 bytes / word)
        inc qword[posicionSuma]
        CMP word[suma],0
        JNE inicioCrearPaquete

    finCearPaquetes:

    add		rsp,[plusRsp]   ;sub rsp,32
    ret


sumarAlListado:
    call	checkAlign      ;no va en Windows
    sub		rsp,[plusRsp]   ;sub rsp,32

    
    MOV word[vecActual+ebx],0

    mov		rcx,qword[posicionSuma]	;rcx = posicion
    dec		rcx							;(posicion-1)
    imul	ebx,ecx,2				;(posicion-1)*longElem

    MOV AX,word[actual]
    MOV word[resultado+ebx],AX
    

    inc qword[posicionSuma]

    add		rsp,[plusRsp]   ;sub rsp,32
    ret

    
;----------------------------------------
;----------------------------------------
; ****	checkAlign ****
;----------------------------------------
;----------------------------------------
checkAlign:
	push rax
	push rbx
;	push rcx
	push rdx
	push rdi

	mov   qword[plusRsp],0
	mov		rdx,0

	mov		rax,rsp		
	add     rax,8		;para sumar lo q restó la CALL 
	add		rax,32	;para sumar lo que restaron las PUSH
	
	mov		rbx,16
	idiv	rbx			;rdx:rax / 16   resto queda en RDX

	cmp     rdx,0		;Resto = 0?
	je		finCheckAlign
;mov rdi,msj
;call puts
	mov   qword[plusRsp],8
finCheckAlign:
	pop rdi
	pop rdx
;	pop rcx
	pop rbx
	pop rax
	ret