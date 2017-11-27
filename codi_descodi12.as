;para usar estas funcoes e necessario usar o seguinte metodo:
;PUSH	R0 ;vai receber o resultado
;PUSH	R1 ;valor que queremos codificar/descodificar
;CALL	codi_12/descodi_12
;POP	R1 ;resultado da codificacao/descodificacao


codi_12:	PUSH	R1		
			PUSH	R2
			PUSH	R3
			PUSH	R4
			MOV		R1,M[SP+5]	;le o valor que queremos codificar
c_codi:		MOV		R2,7h
			AND		R2,R1		;fica com 3 bits
			ADD		R3,R2		;adiciona ao resultado
			ROR		R1,4
			ROR		R3,3
			INC		R4			;faz uma vez para cada digito
			CMP		R4,4
			BR.NZ	c_codi
			MOV		M[SP+6],R3	;coloca o valor na resposta
			POP		R4
			POP		R3
			POP		R2
			POP		R1
			RETN	1

descodi_12:	PUSH	R1
			PUSH	R2
			PUSH	R3
			PUSH	R4
			MOV		R1,M[SP+5]	;le o numero quue queremos descodificar
c_descodi:	MOV		R2,7h
			AND		R2,R1		;fica com 3 bits
			ADD		R3,R2		;adiciona ao resultado
			ROR		R1,3
			ROR		R3,4
			INC		R4			;faz uma vez para cada digito
			CMP		R4,4
			BR.NZ	c_codi
			MOV		M[SP+6],R3	;coloca o valor na resposta
			POP		R4
			POP		R3
			POP		R2
			POP		R1
			RETN	1
