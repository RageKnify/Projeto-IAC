SP_INICIAL  EQU		FDFFh
IO			EQU     FFFEh
IO_TEMP		EQU		FFF6h
IO_TC		EQU		FFF7h
IO_DISPLAY0 EQU 	FFF0h
IO_DISPLAY1 EQU 	FFF1h
IO_DISPLAY2 EQU 	FFF2h
IO_DISPLAY3 EQU 	FFF3h
INT_MASK_ADDR EQU 	FFFAh
INT_MASK 	EQU 	1000000000000010b
NL			EQU     000Ah
MASC    	EQU     1000000000010110b

			ORIG 	FE0Fh
INTF		WORD 	INTFF ; key15
			
			ORIG	8000h
certos		WORD	0
errados		WORD	0
cruzes		WORD	0
bolas		WORD	0
tracos		WORD	0
crono		WORD	0
codigo		WORD	0
codigom		WORD	0
tentativa	WORD	0
tentativam	WORD	0

			ORIG	0000h
			JMP		Inicio

INTFF:		PUSH	R1
			MOV		R1,M[crono]
			INC		R1
			MOV		M[crono],R1
			MOV 	R1,10		;iniciar o temporizador novamente
			MOV		M[IO_TEMP],R1
			MOV		R1,1
			MOV		M[IO_TC],R1
			POP		R1
			RTI

ran:		PUSH	R1
			PUSH	R2
			PUSH	R3
			PUSH	R4
			PUSH	R5
			MOV		R1,M[codigo]
			CMP		R1,0
			BR.NZ	E_PAR
			MOV		R1,M[crono]	;utiliza a funcao pseudo-aleatoria para escolher a sequencia secreta
E_PAR:		MOV		R2,R1
			AND		R2,1h		;ve se o N0 e par
			CMP		R2,0
			BR.Z    ran_p
			BR      ran_i
ran_p:		ROR     R1,1
			BR      ran_d
ran_i:  	XOR     R1,MASC
        	ROR     R1,1
ran_d:  	MOV		R3,0		;vai dividir por 6 e somar 1 a cada digito para que os digitos estejam entre 1 e 6
			MOV		R4,0
c_div6:		MOV		R2,Fh
			AND		R2,R1
			MOV		R5,6
			DIV		R2,R5
			INC		R5
			ADD		R3,R5
			ROR		R3,4
			ROR		R1,4
			INC		R4
			CMP		R4,4
			BR.NZ	c_div6
			MOV		M[codigo],R3
			POP		R5
			POP		R4
			POP		R3
			POP		R2
			POP		R1
			RET

Inicio:		MOV     R7,SP_INICIAL
			MOV     SP,R7
			MOV		R7,R0
