;funçao que atualiza lcd e so o escreve se cont jogadas for melhor do que o valor que esta la
FIM_STR 	EQU 	'@'
SP_INICIAL  EQU		FDFFh
MASC    	EQU     1000000000010110b
LCD_CURSOR	EQU		FFF4h
LCD			EQU		FFF5h
	
			ORIG	8000h
VarStr_recorde	STR 	'RECORDE --> @'
recorde			WORD	12
cont_jogadas	WORD	4

		
		ORIG	0000h
		MOV     R7,SP_INICIAL
		MOV     SP,R7
		MOV		R7,R0
		
		
		JMP		inicio

esc_hsc:	PUSH	R1
			PUSH	R2
			PUSH	R3
			PUSH	R4;************comparar para ver se é maior, se nao for fim_hsc
			MOV		R1,M[cont_jogadas]
			MOV		R2,M[recorde]
			CMP		R1,R2
			JMP.NN	High
			MOV		R1,M[cont_jogadas]
			MOV		M[recorde],R1
High:		MOV		R1, VarStr_recorde
			MOV		R3,8000h
			MOV		M[LCD_CURSOR],R3
C_escrita: 	MOV 	R2, M[R1]
			MOV 	M[LCD], R2
			INC		R3
			MOV		M[LCD_CURSOR],R3
			INC 	R1
			MOV		R4, FIM_STR 
			CMP		M[R1], R4
			BR.NZ	C_escrita
			
			MOV		R4,R3
			MOV		R1,M[recorde]
			MOV		R2,10
			MOV		R3,R0
			DIV		R1,R2
			ADD		R3,R2
			ROL		R1,4
			ADD		R1,R3
			MOV		R3,R1
			PUSH	R3
			SHR		R3,4
			ADD		R3,48
			MOV		M[LCD_CURSOR],R4
			MOV		M[LCD],R3
			INC		R4
			POP		R3
			AND		R3,Fh
			ADD		R3,48
			MOV		M[LCD_CURSOR],R4
			MOV		M[LCD],R3

					
fim_hsc:	POP		R4
			POP		R3
			POP		R2
			POP		R1
			RET




inicio:		CALL	esc_hsc




