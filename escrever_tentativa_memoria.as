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
digito			WORD	0









;codigo		
				ORIG	0000h
				JMP		inicio

				
				
				
				
				
				
				
;interrupcoes das teclas
INT1F:		PUSH	R1
			MOV		R1,1
			MOV		M[digito],R1
			POP		R1
			RTI	
INT2F:		PUSH	R1
			MOV		R1,2
			MOV		M[digito],R1
			POP		R1
			RTI	
INT3F:		PUSH	R1
			MOV		R1,3
			MOV		M[digito],R1
			POP		R1
			RTI	
INT4F:		PUSH	R1
			MOV		R1,4
			MOV		M[digito],R1
			POP		R1
			RTI	
INT5F:		PUSH	R1
			MOV		R1,5
			MOV		M[digito],R1
			POP		R1
			RTI	
INT6F:		PUSH	R1
			MOV		R1,6
			MOV		M[digito],R1
			POP		R1
			RTI	
			
			
		
	
	
		
nova_tentativa:		MOV		R1,M[digito]
					MOV		M[digito],R0
					MOV		R2,M[tentativa]
					ROL		R2,4
					ADD		R2,R1
					MOV		M[tentativa],R2
					AND		R2,F000h
					BR.Z	label
					RET
label:				MOV		R1,M[digito]
novo_digito:		CMP		R1,0
					BR.Z	novo_digito
					JMP		nova_tentativa


					
					
					
					
					

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