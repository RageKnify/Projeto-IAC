SP_INICIAL  EQU		FDFFh
IO			EQU     FFFEh
IO_TEMP		EQU		FFF6h
IO_TC		EQU		FFF7h
IO_DISPLAY0 EQU 	FFF0h
IO_DISPLAY1 EQU 	FFF1h
IO_DISPLAY2 EQU 	FFF2h
IO_DISPLAY3 EQU 	FFF3h
INT_MASK_ADDR EQU 	FFFAh
INT_MASK 	EQU 	1000010001111110b
NL			EQU     000Ah
MASC    	EQU     1000000000010110b

			ORIG	FE0Ah
INTA		WORD	INTAF	; key A

			ORIG 	FE0Fh
INTF		WORD 	INTFF	; temporizador
			
			ORIG	8000h
certos		WORD	0		; numero de digitos na posicao certa
errados		WORD	0		; numero de digitos na posicao errada
cruzes		WORD	0		; numero de cruzes
bolas		WORD	0		; numero de bolas
tracos		WORD	0		; numero de tracos
crono		WORD	0		; cronometro
codigo		WORD	0		; codigo secreto
codigo_m	WORD	0		; codigo secreto que alteramos
tentativa	WORD	0		; tentativa
tentativa_m	WORD	0		; tentativa que alteramos
n_jogo		WORD	0		; variavel que define se se deve comecar um novo jogo
acertou		WORD	0		; variavel que define se o jogador acertou nos 4 algarismos

			ORIG	0000h
			MOV     R7,SP_INICIAL
			MOV     SP,R7
			MOV		R7,R0
			JMP		inicio

INTAF:		PUSH	R1          ; coloca n_jogo a 1 para que se recomece o jogo
			MOV		R1,1
			MOV		M[n_jogo],R1
			POP		R1
			RTI

INTFF:		PUSH	R1			; aumenta o crono(metro) e volta a contar 1 seg
			MOV		R1,M[crono]
			INC		R1
			MOV		M[crono],R1
			MOV 	R1,10		;iniciar o temporizador novamente
			MOV		M[IO_TEMP],R1
			MOV		R1,1
			MOV		M[IO_TC],R1
			POP		R1
			RTI
			
ran:		PUSH	R1			; gera o numero dos jogos
			PUSH	R2
			PUSH	R3
			PUSH	R4
			PUSH	R5
			MOV		R1,M[codigo]; verifica se ja existe um codigo 
			CMP		R1,0
			BR.NZ	E_PAR		;se houver aplica a funcao fornecida
			MOV		R1,M[crono]	;se nao houver utiliza o segundo atual
E_PAR:		MOV		R2,R1		
			AND		R2,1h		;ve se o N0 e par
			CMP		R2,0
			BR.Z    ran_p
			BR      ran_i
ran_p:		ROR     R1,1
			BR      ran_ambos
ran_i:  	XOR     R1,MASC
        	ROR     R1,1
ran_ambos: 	MOV		R3,0		;vai dividir por 6 e somar 1 a cada digito para que os digitos estejam entre 1 e 6
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
			MOV		M[codigo],R3	;guarda o novo codigo na memoria
			POP		R5
			POP		R4
			POP		R3
			POP		R2
			POP		R1
			RET

output: 	PUSH	R1
			PUSH	R2
			PUSH	R3
			MOV		R1,NL		;passa a proxima linha antes de escrever
			MOV		M[IO],R1
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
			
c_errada:	PUSH	R1
			PUSH	R2
			PUSH	R3
			PUSH	R4
			PUSH	R5
			CMP		R5,4		;verifica se testou os 4 algarismos da sequencia secreta
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
			BR.NZ	r_t_		;se tiver, retornar
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
			PUSH	R3
			MOV		M[cruzes],R0;poe os contadores de cruzes, bolas e tracos a 0
			MOV		M[bolas],R0
			MOV		M[tracos],R0
l_sep_R3:	CMP		R2,4		;ve se ja passou pelos 4 algarismos de R3
			BR.NZ	dois		;se nao tiver testar para 2
			POP		R3
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

			
input:		CMP		R2,R0	;cria um loop 'a espera que o utilizador escreva a tentativa em R2
			BR.Z	input
			RET

			
inicio:		MOV 	R1,10		;iniciar o temporizador
			MOV		M[IO_TEMP],R1
			MOV		R1,1
			MOV		M[IO_TC],R1
			ENI

novo_jogo:	CMP		M[n_jogo],R0	;vamos introduzir aqui o codigo que escreve no ecra "Carregue no botao..."
			BR.Z	novo_jogo
			CALL	ran		;cria o codigo secreto e guarda-o em R1
			
c_tents:	CMP		R7,12	; ve se ja foram feitas 12 jogadas
			JMP.Z	fim		; se sim acaba jogo
			PUSH	R7		; guarda contador de jogadas
			MOV		R2,R0	;limpa R2 para receber tentativa nova
			CALL	input	;receber nova tentativa
			MOV		R1,M[codigo]
			MOV		M[codigo_m],R1
			MOV		M[tentativa],R2
			MOV		M[tentativa_m],R2
			CALL	p_certa		;verificar se ha algum algarismo na posicao certa
			CALL	c_errada	;verificar se ha algum algarismo na posicao certa
			MOV		R1,M[codigo]
			CALL	atua_R3		;codifica R3 
			CALL	sep_R3		;descodifica R3
			CALL	output		;escreve o output na janela de texto
			MOV		R6,M[acertou]
			CMP		R6,1		;se tiver acertado nesta tentativa acaba o jogo
			JMP.Z	fim			;E PRECISO MUDAR PARA COMECAR UM NOVO JOGO
			POP		R7			;reavem contador de jogadas
			INC		R7			;incrementa o contador de jogadas
			JMP		c_tents		;comeca uma nova jogadas
			
		
fim:		BR		fim
