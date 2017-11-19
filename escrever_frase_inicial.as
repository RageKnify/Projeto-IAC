SP_INICIAL  EQU		FDFFh
IO			EQU     FFFEh
NL			EQU     000Ah
FIM_STR 	EQU 	'@'

			
			ORIG	8000h
VarStr_INICIO_JOGO	STR 	'Carregue no botao IA para iniciar@'

			ORIG	0000h
			MOV     R7,SP_INICIAL
			MOV     SP,R7
			MOV		R7,R0
			JMP		inicio

		
frase_inicial:	MOV     R1,VarStr_INICIO_JOGO
escrever:		MOV 	R2, M[R1]
				CMP		R2,FIM_STR
				BR.Z	fim_out
				MOV		M[IO],R2
				INC		R1
				BR		escrever
fim_out:RET


			
inicio:		CALL	frase_inicial
			
		
fim:		BR		fim









