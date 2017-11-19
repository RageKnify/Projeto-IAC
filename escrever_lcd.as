FIM_STR 	EQU 	'@'
SP_INICIAL  EQU		FDFFh
MASC    	EQU     1000000000010110b
	
	
			ORIG	8000h
VarStr_INICIO_JOGO	STR 	'Carregue no botao IA para iniciar@'




		
		ORIG	0000h
		MOV     R7,SP_INICIAL
		MOV     SP,R7
		MOV		R7,R0
		JMP		inicio

		
		
		
		

FRASE_INIC:	PUSH	R1
			PUSH	R2
			PUSH	R3
			PUSH	R4
			MOV		R1, VarStr_INICIO_JOGO
			MOV		R3,8000h
			MOV		M[FFF4h],R3
C_escrita: 	MOV 	R2, M[R1]
			MOV 	M[FFF5h], R2
			INC		R3
			MOV		M[FFF4h],R3
			INC 	R1
			MOV		R4, FIM_STR 
			CMP		M[R1], R4
			BR.NZ	C_escrita
			POP		R3
			POP		R2
			POP		R1
			POP		R4
			RET


			
	
	
	
	

inicio:		CALL	FRASE_INIC






fim:		BR		fim









