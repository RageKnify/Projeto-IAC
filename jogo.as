SP_INICIAL  		EQU		FDFFh
FIM_STR 			EQU 	'@'
IO_TEMP				EQU	FFF6h
IO_TC				EQU	FFF7h
INT_MASK_ADDR		EQU FFFAh
INT_MASK 			EQU FFFFh
IO					EQU     FFFEh
IO_CURSOR			EQU		FFFCh
NL					EQU		000Ah



;*************************************************************************************
;****************************MEMORIA*************************************************

					ORIG	8000h
tentativa			WORD	0	;tentativa nao modificavel
codigo				WORD	0	;codigo nao modificavel
perdeu_jogo			WORD	0	; 1 ou 0 consoante perdeu jogo ou nao
loc_cursor			WORD	0	;localizaçao do cursor da janela de texto
novo_jogo_			WORD	0	; variavel que define se se deve comecar um novo jogo
cont_jogadas		WORD	0	;contador de jogadas == pont_act
acertou				WORD	0	;se acertou esta a 1 
codigo_m			WORD	0	;codigo modificavel
tentativa_m			WORD	0	;tentativa modificavel
certos				WORD	0	;contador de certos	
errados				WORD	0	;contador errados
cruzes				WORD	0	;contador cruzes
bolas				WORD	0	;contador bolas
tracos				WORD	0	;contador traços
apaga_led			WORD	0	;se for para apagae algum led esta a 1
cron				WORD	0
VarStr_INICIO_JOGO	STR 	'Carregue no botao IA para iniciar@'
STR_perdeu_jogo		STR		'Fim do jogo@'
STR_recomecar		STR		'Carregue em IA para recomecar@'


;*************************************************************************************
;**************************INTERRUPÇOES*********************************************
			ORIG	FE01h
INT1		WORD	INT1F
INT2		WORD	INT2F
INT3		WORD	INT3F
INT4		WORD	INT4F
INT5		WORD	INT5F
INT6		WORD	INT6F

			ORIG	FE0Fh
INTF		WORD 	INTFF ; key15
			ORIG	FE0Ah
INTA		WORD	INTAF	; key A




;*************************************************************************************
;**********************************CODIGO********************************************
			ORIG	0000h
			MOV     R7,SP_INICIAL
			MOV     SP,R7
			MOV 	R7, INT_MASK
			MOV 	M[INT_MASK_ADDR], R7
			MOV		R7,FFFFh			
			MOV		M[IO_CURSOR],R7			;para se poder mecher no cursor
			MOV		R7,R0
			JMP		inicio


	

;**********************************************************************************
;**************************INPUT**************************************


				
;interrupcoes das teclas
;colocam na variavel da tentativa o novo digito
INT1F:		PUSH	R1
			MOV		R1,M[tentativa]
			ROL		R1,4
			ADD		R1,1
			MOV		M[tentativa],R1
			POP		R1
			RTI	
INT2F:		PUSH	R1
			MOV		R1,M[tentativa]
			ROL		R1,4
			ADD		R1,2
			MOV		M[tentativa],R1
			POP		R1
			RTI	
INT3F:		PUSH	R1
			MOV		R1,M[tentativa]
			ROL		R1,4
			ADD		R1,3
			MOV		M[tentativa],R1
			POP		R1
			RTI	
INT4F:		PUSH	R1
			MOV		R1,M[tentativa]
			ROL		R1,4
			ADD		R1,4
			MOV		M[tentativa],R1
			POP		R1
			RTI	
INT5F:		PUSH	R1
			MOV		R1,M[tentativa]
			ROL		R1,4
			ADD		R1,5
			MOV		M[tentativa],R1
			POP		R1
			RTI	
INT6F:		PUSH	R1
			MOV		R1,M[tentativa]
			ROL		R1,4
			ADD		R1,6
			MOV		M[tentativa],R1
			POP		R1
			RTI	
			

;**********************************************************************************
;*********************PERDEU JOGO***************************************	
INTAF:				PUSH	R1          ; coloca novo_jogo a 1 para que se recomece o jogo
					MOV		R1,1
					MOV		M[novo_jogo_],R1
					POP		R1
					RTI			
				

;**********************************************************************************
;*******************************ciclo que escreve string na janela*****************
esc_linha_seg:	PUSH	R1
				MOV		R1,M[loc_cursor]	;mete cursor na linha seguinte na primeira coluna
				AND		R1,FF00h
				ADD		R1,100h
				MOV		M[loc_cursor],R1
				POP		R1
				
				
passar_str:		PUSH	R1
				PUSH	R2
				PUSH	R3
				MOV     R1,M[SP+5]		;coloca endereço dos caracteres em R1
				MOV		R3,M[loc_cursor]		;coloca localizaçao do cursor em R3
				MOV		M[IO_CURSOR],R3
escrever:		MOV 	R2, M[R1]		;mete caracter em R2
				CMP		R2,FIM_STR
				BR.Z	end_out
				MOV		M[IO],R2		;mete caracter na janela
				INC		R1				
				INC		R3				;incrementa cursor
				MOV		M[IO_CURSOR],R3
				BR		escrever
end_out:		MOV		M[loc_cursor],R3	;guarda em variavel a localizaçao do cursor
				POP		R3
				POP		R2
				POP		R1
				RETN	1

	
			
			
;***********************************************************************************
;********************************LEDS***********************************************
INTFF:			PUSH	R1			
				MOV		R1,M[cron]
				INC		R1
				MOV		M[cron],R1
				MOV		R1,5
				MOV		M[IO_TEMP],R1
				MOV		R1,1
				MOV		M[IO_TC],R1
				POP		R1
				RTI
				
apagar_led:		SHR		R1,1			;apaga um led
				MOV		M[FFF8h],R1
				MOV		R2,M[cron]
				JMP		travao


ligar_leds:		PUSH	R1
				PUSH	R2
				PUSH	R3
				MOV		R1,FFFFh		;R1 guarda os leds que estao acesos
				MOV		M[FFF8h],R1
				MOV		R2,M[cron]
				
travao:			MOV		R3,M[tentativa]
				AND		R3,F000h			;se a tentativa ja tiver 4 digitos sai
				CMP		R3,0
				BR.NZ	sai
				CMP		R1,0
				JMP.Z	todos_apagados		;se os leds tiverem todos apagados 
				CMP		M[cron],R2
				JMP.NZ	apagar_led
				JMP		travao
				
				
sai:			MOV		M[FFF8h],R0;quando sai apaga os leds todos
				POP		R3
				POP		R2
				POP		R1
				RET

todos_apagados:	MOV		R1,1			;se tiverem apagado todos perdeu jogo
				MOV		M[perdeu_jogo],R1
				POP		R3
				POP		R2
				POP		R1
				RET		
				
			
			
			
;***********************************************************************************
;********************************limpar a janela de texto******************

limpar_janela:	PUSH	R1
				PUSH	R2
				MOV		R1,R0
cicle:			MOV		M[IO_CURSOR],R1
				MOV		R2,' '
				MOV		M[IO],R2
				INC		R1
				MOV		R2,R1
				AND		R2,FFh
				CMP		R2,79
				BR.NZ	cicle
				SUB		R1,79
				ADD		R1,100h
				ROR		R1,8
				CMP		R1,23
				BR.Z	fim_limpar
				ROL		R1,8
				BR		cicle
fim_limpar:		MOV		M[loc_cursor],R0
				POP		R2
				POP		R1
				RET
				
;***********************************************************************************
;***************************CODIGO SECRETO******************************************

codigo_secreto:	PUSH	R1
				MOV		R1,1234h
				MOV		M[codigo],R1
				POP		R1
				RET
				
				
				
;***********************************************************************************
;ciclo que escreve caracter a frente
esc_frent:	PUSH	R1
			MOV		R1,M[loc_cursor]
			INC		R1
			MOV		M[loc_cursor],R1
			MOV		M[IO_CURSOR],R1
			MOV		R1,M[SP+3];mete o caracter num registo
			MOV		M[IO],R1
			POP		R1
			RET
;***********************************************************************************				
output: 	PUSH	R1
			PUSH	R2
			PUSH	R3
			MOV		R1,M[loc_cursor]
			AND		R1,FF00h
			ADD		R1,100h
			MOV		M[loc_cursor],R1
			MOV		M[IO_CURSOR],R1
			;MOV		R1,NL		passa a proxima linha antes de escrever
			;MOV		M[IO],R1
			MOV     R1,M[tentativa]	;coloca a tentativa em R1
        	AND     R1,F000h    ;imprime a tentaiva letra a letra
        	SHR     R1,12
        	ADD     R1,48
        	MOV     M[IO],R1
        	MOV     R1, '-'
        	MOV     M[IO], R1
        	MOV     R1,M[tentativa]
        	AND     R1,F00h
        	SHR     R1,8
        	ADD     R1,48
        	MOV     M[IO],R1
        	MOV     R1, '-'
        	MOV     M[IO], R1
        	MOV     R1,M[tentativa]
        	AND     R1,F0h
        	SHR     R1,4
        	ADD     R1,48
        	MOV     M[IO],R1
        	MOV     R1, '-'
        	MOV     M[IO], R1
        	MOV     R1,M[tentativa]
        	AND     R1,Fh
        	ADD     R1,48
        	MOV     M[IO],R1
        	MOV     R1,' '          ;imprime um espaco antes do resultado
        	MOV     M[IO],R1
X_:     	MOV     R2,M[cruzes]    ;retira o numero de cruzes
        	CMP		R2,4			;ve se ha 4 cruzes (jogo acaba)
			BR.NZ	n_acaba
			MOV		R3,1
			MOV		M[acertou],R3
n_acaba:	MOV     R3,0
C_x:    	CMP     R3,R2
        	BR.Z    O_
        	MOV     R1, 'x'
        	MOV     M[IO], R1		;imprime as cruzes
        	INC     R3
        	BR      C_x
O_:     	MOV     R2,M[bolas]     ;retira o numero de bolas
        	MOV     R3,0
C_o:    	CMP     R3,R2
        	BR.Z    Trc
        	MOV     R1, 'o'
        	MOV     M[IO], R1		;imprime as bolas
        	INC     R3
        	BR      C_o
Trc:    	MOV     R2,M[tracos]	;retira o numero de tracos
        	MOV     R3,0
C_trc:  	CMP     R3,R2
        	BR.Z	fim_out			;depois de imprimir todos vai retornar
        	MOV     R1, '-'
        	MOV     M[IO], R1		;imprime os tracos
        	INC     R3
        	BR      C_trc
fim_out:	POP		R3
			POP		R2
			POP		R1
			RET
;*****************************************************************************

atua_R3:	PUSH	R1
			PUSH	R2
			MOV		R3,0
Conta_x:    MOV     R1,M[certos]	;retira o numero de algarismos na posicao certa
			MOV     R2,0
			MOV		R3,0
Ciclo_x:    CMP     R2,R1
			BR.Z    Conta_o
			SHL		R3,4
			ADD		R3,2			;codifica o R3, posicoes certas escreve 2
			INC     R2
			BR      Ciclo_x
		
Conta_o:    MOV     R1,M[errados]	;retira o numero de numeros na posicao errada
			MOV     R2,0
Ciclo_o:    CMP     R2,R1
			BR.Z    Conta_t
			SHL		R3,4
			ADD		R3,1			;codifica o R3, posicoes erradas escreve 1
			INC     R2
			BR      Ciclo_o
		
Conta_t:    MOV     R2,M[certos]
			ADD     R2,M[errados]
			MOV     R1,4
			SUB     R1,R2
			MOV     R2,0
Ciclo_t:  	CMP     R2,R1
			BR.NZ  next
			POP		R2
			POP		R1
			RET
next:		SHL		R3,4			;codifica o R3, algarismos errados escreve 0
			INC     R2
			BR      Ciclo_t
			
			
mais_nove:	PUSH	R1				;guardar R1(contador de ciclos_ROR), funçao estraga-o
			MOV		R1,M[codigo_m]	;mais_nove > poe na posiçao um algarismo incompativel
			ADD		R1,8h		;adiciona 8 para ter um algarismo maior que 6
			MOV		M[codigo_m],R1
			MOV		R1,M[tentativa_m]
			ADD		R1,9h		;adiciona 9 para ter um algarismo maior que 6(nao pode ser 8 porque seria 'x' e 'o'
			MOV		M[tentativa_m],R1
			POP		R1				;reavem o R1
			RET
			
			
p_certa:	PUSH	R1
			PUSH	R2
			PUSH	R3
			PUSH	R4
			MOV		R4,R0
			MOV		R3,R0
			MOV		R1,M[codigo_m]
			MOV		R2,M[tentativa_m]
c_certa:	AND		R1,Fh			;ficam os 4 bits menos significativos
			AND		R2,Fh
			CMP		R1,R2			;ve se 4 menos significativos correspondem ao mesmo numero
			BR.NZ	ciclo_ROR		;caso nao sejam iguais > ciclo_ROR para passar ao proximo algarismo
			INC		R3				;caso sejam iguais incrementa contador respostas corretas
			CALL	mais_nove		;alteramos os algarismos que eram iguais
ciclo_ROR:	MOV		R1,M[codigo_m]	;coloca a sequencia secreta no R1
			MOV		R2,M[tentativa_m];coloca a tentaiva no R2
			ROR		R1,4			;passa ao proximo algarismo
			ROR		R2,4
			MOV		M[codigo_m],R1	;coloca de volta na memoria
			MOV		M[tentativa_m],R2	
			INC		R4				;incrementa contador de ciclos_ROR
			CMP		R4,4			;verifica se verificou os 4 algarismos, se sim retorna
			JMP.NZ	c_certa
			MOV		M[certos],R3
			POP		R4
			POP		R3
			POP		R2
			POP		R1
			RET
			
p_errada:	PUSH	R1
			PUSH	R2
			PUSH	R3
			PUSH	R4
			PUSH	R5
			MOV		R3,R0
			MOV		R4,R0
			MOV		R5,R0
c_errada:	CMP		R5,4		;verifica se testou os 4 algarismos da sequencia secreta
			JMP.Z	r_tenta		;se sim passar ao proximo algarismo da tentativa
			MOV		R1,M[codigo_m]	;coloca a sequencia secreta no R1
			MOV		R2,M[tentativa_m]	;coloca a tentativa no R2
			AND		R1,Fh		;ficam os 4 bits menos significativos
			AND		R2,Fh
			CMP		R1,7h		;verifica se o algarismo e menor que 7
			BR.NN	r_certo	;se for > 7 rodar para o proximo algarismo
			CMP		R1,R2		;se for < 7 comparar com o algarismo da tentativa
			BR.NZ	r_certo	;se forem diferentes rodar para o proximo algarismo
			INC		R4			;se forem iguais aumentar o contador de respostas corretas
			CALL	mais_nove	;alteramos os algarismos que eram iguais
r_certo:	MOV		R1,M[codigo_m]	;coloca a sequencia secreta no R1
			ROR		R1,4		;roda para o proximo lagarismo
			MOV		M[codigo_m],R1	;coloca de volta na memoria
			INC		R5			;incrementar contador de rotacoes da sequencia
			JMP		c_errada	;testar com o novo algarismo da sequencia
r_tenta:	CMP		R3,4		;verifica se testou os 4 algarismos da tentativa
			BR.NZ	r_t_		;se tiver
			MOV		M[errados],R4
			POP		R5
			POP		R4
			POP		R3
			POP		R2
			POP		R1
			RET

r_t_:		MOV		R2,M[tentativa_m];colocar a tentativa em R2
			ROR		R2,4			;rodar para o proximo algarismo da tentativa
			MOV		M[tentativa_m],R2;colocar de volta na memoria
			INC		R3				;incrementar contador de rotacoes da tentativa
			MOV		R5,R0			;reiniciar contador de rotacoes da sequencia
			JMP		c_errada		;testar com o novo algarismo da tentativa

			
sep_R3:		PUSH	R1
			PUSH	R2
			PUSH	R3		;************este push devia acontecer? R3 sai daqui com cenas?
			MOV		R2,R0		;poe o R2 a 0 para o utilizar
			MOV		M[cruzes],R0;poe os contadores de cruzes, bolas e tracos a 0
			MOV		M[bolas],R0
			MOV		M[tracos],R0
l_sep_R3:	CMP		R2,4		;ve se ja passou pelos 4 algarismos de R3
			BR.NZ	dois		;se nao tiver testar para 2
			POP		R3
			MOV		R3,0 ;*********************************limpei R3
			POP		R2
			POP		R1
			RET					;se ja tiver passado por todos retornar
dois:		ROL		R3,4		;rodar para o primeiro algarismo
			PUSH	R3			;guardar R3
			AND		R3,Fh		;ficar com o 4o algarismo
			CMP		R3,2		;comparar o algarismo com 2
			BR.NZ	um_zero		;se for 2 aumentar o contador das cruzes
			MOV		R1,1
			ADD		M[cruzes],R1
			BR		f_sep_R3	;finalizar loop
um_zero:	CMP		R3,1		;comparar o algarismo com 1
			BR.NZ	zero		;se for 1 aumentar o contador das bolas
			MOV		R1,1
			ADD		M[bolas],R1
			BR		f_sep_R3	;finalizar loop
zero:		MOV		R1,1		;se R1 != 2 e R1 != 1 entao R1 == 0, logo podemos aumentar o contador de tracos
			ADD		M[tracos],R1
f_sep_R3:	INC		R2			;incrementar o contador de algarismos verificados
			POP		R3			;recuperar R3 para o proximo algarismo
			JMP		l_sep_R3	;voltar ao inicio do loop

			
		
;***********************************************************************************
;***********************************************************************************


c_tents:	PUSH	R1
			MOV		R1,M[codigo]
			MOV		M[codigo_m],R1
			MOV		R1,M[tentativa]
			MOV		M[tentativa_m],R1
			POP		R1
			CALL	p_certa		;verificar se ha algum algarismo na posicao certa
			CALL	p_errada	;verificar se ha algum algarismo na posicao certa
			CALL	atua_R3		;codifica R3 
			CALL	sep_R3		;descodifica R3
			CALL	output		;escreve o output na janela de texto
			PUSH	R1
			MOV		R1,M[acertou]	
			CMP		R1,1		;se tiver acertado nesta tentativa acaba o jogo
			JMP.Z	acertou_tent		;E PRECISO MUDAR PARA COMECAR UM NOVO JOGO
			MOV		R1,M[cont_jogadas]
			INC		R1
			CMP		R1,12	; ve se ja foram feitas 12 jogadas
			JMP.Z	esgotou_tent	; se sim acaba jogo
			MOV		M[cont_jogadas],R1
acertou_tent:POP		R1
			RET
	
esgotou_tent:MOV	R1,1
			MOV		M[perdeu_jogo],R1
			POP		R1
			RET
			
;meter contador de jogadas a zero
;se nao perdeu o jogo queremos continuar a jogar				
;se acertou queremos recomeçar
				
				
				

				
;***********************************************************************************				
;***********************************************************************************	


perdeu:				POP		R1
					MOV		M[perdeu_jogo],R0	;reinicia variavel
					MOV		M[acertou],R0
					PUSH	R1
					MOV		R1,STR_perdeu_jogo	;escreve que perdeu
					PUSH	R1					;o ciclo remove este PUSH
					CALL	esc_linha_seg
					MOV		R1,STR_recomecar
					PUSH	R1						;escreve para reiniciar
					CALL	esc_linha_seg
					POP		R1

					
novo_jogo:			ENI
					CMP		M[novo_jogo_],R0		;enquanto nao carregar em IA nao começa
					BR.Z	novo_jogo
					MOV		M[cont_jogadas],R0		;limpa contadores
					MOV		M[novo_jogo_],R0
					CALL	codigo_secreto
					CALL	limpar_janela
nova_tentat:		MOV		M[tentativa],R0
					CALL	ligar_leds
					PUSH	R1
					MOV		R1,M[perdeu_jogo]
					CMP		R1,R0				;se perdeu o jogo nao chama ciclo das tentativas faz logo novo jogo
					JMP.NZ	perdeu
					POP		R1
					CALL	c_tents
					PUSH	R1
					MOV		R1,M[perdeu_jogo]	;caso tenha perdido o jogo reinicia
					CMP		R1,0
					JMP.NZ	perdeu				
					MOV		R1,M[acertou]		;caso tenha acertado reinicia
					CMP		R1,0
					JMP.NZ	perdeu
					POP		R1
					JMP		nova_tentat
				
	
;**********************************inicio*******************************************
inicio:			PUSH	VarStr_INICIO_JOGO
				CALL	passar_str
				PUSH	R1
				MOV		R1,5
				MOV		M[IO_TEMP],R1
				MOV		R1,1
				MOV		M[IO_TC],R1
				POP		R1
				ENI
				MOV		M[novo_jogo_],R0
				CALL	novo_jogo
				
				
				
;***********************************************************************************	
;***********************************************************************************	

							
fim:			BR		fim