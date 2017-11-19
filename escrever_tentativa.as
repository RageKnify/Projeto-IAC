SP_INICIAL		EQU		FDFFh
INT_MASK_ADDR 	EQU 	FFFAh
INT_MASK 		EQU 	FFFFh

	
	
	
	
	
	
	
; Interrupcoes
				ORIG	FE01h
INT1			WORD	INT1F
INT2			WORD	INT2F
INT3			WORD	INT3F
INT4			WORD	INT4F
INT5			WORD	INT5F
INT6			WORD	INT6F







;variaveis em memoria			
				ORIG	8000h
tentativa		WORD	0









;codigo		
				ORIG	0000h
				JMP		inicio

				
				
				
				
				
				
				
;interrupcoes das teclas
INT1F:		MOV		R1,1
			RTI	
INT2F:		MOV		R1,2
			RTI	
INT3F:		MOV		R1,3
			RTI	
INT4F:		MOV		R1,4
			RTI	
INT5F:		MOV		R1,5
			RTI	
INT6F:		MOV		R1,6
			RTI	
			
			
		




nova_tentativa:		CMP		R2,0
					BR.NZ	dig_2
					SHL		R1,12
					ADD		M[tentativa],R1
					JMP	inc_cont
dig_2:				CMP		R2,1
					BR.NZ	dig_3
					SHL		R1,8
					ADD		M[tentativa],R1
					JMP	inc_cont
dig_3:				CMP		R2,2
					BR.NZ	dig_4
					SHL		R1,4
					ADD		M[tentativa],R1
					JMP	inc_cont
dig_4:				ADD		M[tentativa],R1

inc_cont:			MOV		R1,R0
					INC		R2
					CMP		R2,4
					BR.NZ	novo_digito
					RET			;se ja tiver os 4 digitos sai
novo_digito:		CMP		R1,0
					BR.Z	novo_digito
					JMP	nova_tentativa



inicio:				MOV 	R7, SP_INICIAL
					MOV 	SP, R7
					MOV 	R7, INT_MASK
					MOV 	M[INT_MASK_ADDR], R7
					MOV		R7,R0
					PUSH	R1
					PUSH	R2
					MOV		M[tentativa],R0
					ENI
					CALL	novo_digito
					POP		R2
					POP		R1
				
				
				

fim:			BR		fim				