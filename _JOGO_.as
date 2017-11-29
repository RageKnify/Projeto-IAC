SP_INICIAL      EQU     FDFFh
FIM_STR         EQU     '@'
IO_TEMP         EQU     FFF6h
IO_TC           EQU     FFF7h
INT_MASK_ADDR   EQU     FFFAh
INT_MASK        EQU     1000010001111110b
IO              EQU     FFFEh
IO_CURSOR       EQU     FFFCh
IO_DISPLAY0     EQU     FFF0h
IO_DISPLAY1     EQU     FFF1h
LCD_CURSOR      EQU     FFF4h
LCD             EQU     FFF5h
MASC            EQU     1000000000010110b



;*************************************************************************************
;****************************MEMORIA*************************************************

                ORIG    8000h
tentativa           WORD    0    ;tentativa nao modificavel
tentativa_m         WORD    0    ;tentativa modificavel
codigo              WORD    0    ;codigo nao modificavel
codigo_m            WORD    0    ;codigo modificavel
loc_cursor          WORD    0    ;localizaçao do cursor da janela de texto
novo_jogo_          WORD    0    ; variavel que define se se deve comecar um novo jogo
cont_jogadas        WORD    0    ;contador de jogadas == pont_act
acertou             WORD    0    ;se acertou esta a 1 
perdeu_jogo         WORD    0    ; 1 ou 0 consoante perdeu jogo ou nao
apaga_led           WORD    0    ;se for para apagae algum led esta a 1
cron                WORD    0
recorde             WORD    12
contador            WORD    0
certos              WORD    0    ;contador de certos    
errados             WORD    0    ;contador errados
cruzes              WORD    0    ;contador cruzes
bolas               WORD    0    ;contador bolas
tracos              WORD    0    ;contador traços

VarStr_INICIO_JOGO  STR     'Carregue no botao IA para iniciar@'
STR_perdeu_jogo     STR        'Fim do jogo@'
STR_recomecar       STR        'Carregue em IA para recomecar@'
STR_ganhou          STR        'Parabens, teve sorte@'
VarStr_recorde      STR     'RECORDE --> @'


;*************************************************************************************
;**************************INTERRUPÇOES*********************************************
            ORIG    FE01h
INT1        WORD    INT1F
INT2        WORD    INT2F
INT3        WORD    INT3F
INT4        WORD    INT4F
INT5        WORD    INT5F
INT6        WORD    INT6F

            ORIG    FE0Fh
INTF        WORD     INTFF ; key15
            ORIG    FE0Ah
INTA        WORD    INTAF    ; key A




;*************************************************************************************
;**********************************CODIGO********************************************
            ORIG    0000h
            MOV     R7,SP_INICIAL
            MOV     SP,R7
            MOV     R7, INT_MASK
            MOV     M[INT_MASK_ADDR], R7
            MOV     R7,FFFFh            
            MOV     M[IO_CURSOR],R7            ;para se poder mecher no cursor
            MOV     R7,R0
            JMP     inicio




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
;*********************Codificar 16-> 12***************************************

codi_12:    PUSH   R1
            PUSH    R2
            PUSH    R3
            PUSH    R4
            MOV     R1,M[SP+6]  ;le o valor que queremos codificar
c_codi:     MOV     R2,7h
            AND     R2,R1       ;fica com 3 bits
            ADD     R3,R2       ;adiciona ao resultado
            ROR     R1,4
            ROR     R3,3
            INC     R4          ;faz uma vez para cada digito
            CMP     R4,4
            BR.NZ   c_codi
            ROR     R3,4
            MOV     M[SP+7],R3  ;coloca o valor na resposta
            POP     R4
            POP     R3
            POP     R2
            POP     R1
            RETN    1


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
				CMP		R1,24
				BR.Z	fim_limpar
				ROL		R1,8
				BR		cicle
fim_limpar:		MOV		M[loc_cursor],R0
				MOV		M[IO_CURSOR],R0
				;meter IO a zero
				POP		R2
				POP		R1
				RET
				
;***********************************************************************************
;***************************CODIGO SECRETO******************************************


random:     	PUSH	R1			; gera o numero dos jogos
       			PUSH	R2
       			PUSH	R3
       			PUSH	R4
       			PUSH	R5
       			MOV		R1,M[codigo]; verifica se ja existe um codigo
       			CMP		R1,0
       			BR.NZ	E_PAR		;se houver aplica a funcao fornecida
       			MOV		R1,M[contador]	;se nao houver utiliza o segundo atual
E_PAR:			MOV		R2,R1
       			AND		R2,1h		;ve se o N0 e par
       			CMP		R2,0
       			BR.Z    ran_p
       			BR      ran_i
ran_p:			ROR     R1,1
       			BR      ran_ambos
ran_i:  		XOR     R1,MASC
               	ROR     R1,1
ran_ambos: 		MOV		R3,0		;vai dividir por 6 e somar 1 a cada digito para que os digitos estejam entre 1 e 6
       			MOV		R4,0
c_div6:			MOV		R2,Fh
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
                POP     R3
                POP     R2
                POP     R1
                RET


;***********************************************************************************
;ciclo que escreve caracter a frente
esc_frent:  PUSH    R1
            MOV     R1,M[loc_cursor]
            MOV     M[IO_CURSOR],R1
            MOV     R1,M[SP+3];mete o caracter num registo
            MOV     M[IO],R1
            MOV     R1,M[loc_cursor]
            INC     R1
            MOV     M[loc_cursor],R1
            POP     R1
            RET
;***********************************************************************************				
output:     PUSH    R1
            PUSH    R2
            PUSH    R3
            MOV     R3,0
            MOV     R1,M[tentativa]
            ROL     R1,4

cic_output: ROL     R1,3
            MOV     R2,7
            AND     R2,R1
            ADD     R2,48
            PUSH    R2
            CALL    esc_frent
            MOV     R2,'-'
            PUSH    R2
            CALL    esc_frent
            INC     R3
            CMP     R3,3
            BR.NZ   cic_output

            ROL     R1,3
            MOV     R2,7
            AND     R2,R1
            ADD     R2,48
            PUSH    R2
            CALL    esc_frent
            MOV     R2,' '
            PUSH    R2
            CALL    esc_frent

X_:         POP     R3               ;R3 fica com 0x0o onde 'x' e o numero de certas e 'o' e o numero de erradas
            PUSH    R3
            SHR     R3,8
            CMP     R3,4             ;ve se ha 4 cruzes (jogo acaba)
            BR.N    n_acertou
            MOV     R2,1
            MOV     M[acertou],R2
n_acertou:  MOV     R2,0
C_x:        CMP     R2,R3
            BR.Z    O_
            MOV     R1, 'x'
            PUSH    R1
            CALL    esc_frent
            INC     R2
            BR      C_x

O_:         POP     R3
            PUSH    R3
            AND     R3,Fh           ;retira o numero de bolas
            MOV     R2,0
C_o:        CMP     R2,R3
            BR.Z    Trc
            MOV     R1, 'o'
            PUSH    R1
            CALL    esc_frent
            INC     R2
            BR      C_o

Trc:        POP     R3
            PUSH    R3
            MOV     R2,Fh
            AND     R2,R3
            SHL     R3,8
            ADD     R3,R2
            MOV     R2,0
C_trc:      CMP     R2,R3
            BR.Z    fim_out             ;depois de imprimir todos vai retornar
            MOV     R1, '-'
            PUSH    R1
            CALL    esc_frent
            INC     R2
            BR      C_trc
fim_out:    MOV     R1,M[loc_cursor]    ;no fim do output deixa o cursor na linha seguinte
            AND     R1,FF00h
            ADD     R1,100h
            MOV     M[loc_cursor],R1
            MOV     M[IO_CURSOR],R1
            POP     R3
            POP     R2
            POP     R1
            RET

;*****************************************************************************
atua_R3:    PUSH    R1
            PUSH    R2
            MOV     R3,0
Conta_x:    MOV     R1,M[certos]    ;retira o numero de algarismos na posicao certa
            MOV     R2,0
Ciclo_x:    CMP     R2,R1
            BR.Z    Conta_o
            ADD     R3,1            ;codifica o R3, posicoes certas escreve 2
            INC     R2
            BR      Ciclo_x
Conta_o:    SHL     R3,8
            MOV     R1,M[errados]   ;retira o numero de numeros na posicao errada
            MOV     R2,0
Ciclo_o:    CMP     R2,R1
            BR.Z    f_atua_R3
            ADD     R3,1            ;codifica o R3, posicoes erradas escreve 1
            INC     R2
            BR      Ciclo_o
f_atua_R3:  POP     R2
            POP      R1
            RET


mais_nove:  PUSH    R1                  ;guardar R1(contador de ciclos_ROR), funçao estraga-o
            MOV     R1,M[codigo_m]      ;mais_nove > poe na posiçao um algarismo incompativel
            AND     R1,FFF8h            ;passa os 3 bits menos significativos para 0 para nao ser 'x' e 'o'
            MOV     M[codigo_m],R1
            MOV     R1,M[tentativa_m]
            AND     R1,FFF8h            ;passa os 3 bits menos significativos para 0 para nao ser 'x' e 'o'
            MOV     M[tentativa_m],R1
            POP     R1                  ;reavem o R1
            RET


p_certa:    PUSH	R1
            PUSH	R2
            PUSH	R3
            PUSH	R4
            MOV		R4,R0
            MOV		R3,R0
            MOV		R2,M[tentativa_m]
            MOV		R1,M[codigo_m]
c_certa:    AND		R1,7h			;ficam os 3 bits menos significativos
            AND		R2,7h
            CMP		R1,R2
            BR.NZ	ciclo_ROR		;caso nao sejam iguais > ciclo_ROR para passar ao proximo algarismo
            INC		R3				;caso sejam iguais incrementa contador respostas corretas
            CALL	mais_nove		;alteramos os algarismos que eram iguais
ciclo_ROR:	MOV		R1,M[codigo_m]	;coloca a sequencia secreta no R1
            MOV		R2,M[tentativa_m];coloca a tentaiva no R2
            ROR		R1,3			;passa ao proximo algarismo
            ROR		R2,3
            MOV		M[codigo_m],R1	;coloca de volta na memoria
            MOV		M[tentativa_m],R2
            INC		R4				;incrementa contador de ciclos_ROR
            CMP		R4,4			;verifica se verificou os 4 algarismos, se sim retorna
            JMP.NZ	c_certa
            ROR   R1,4
            ROR   R2,4
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
          AND		R1,7h		;ficam os 3 bits menos significativos
          AND		R2,7h
          CMP		R1,0h		;verifica se o algarismo e 0
          BR.Z	  r_certo	;se for == 0 rodar para o proximo algarismo
          CMP		R1,R2
          BR.NZ	r_certo
          INC		R4			;se forem iguais aumentar o contador de respostas corretas
          CALL	mais_nove	;alteramos os algarismos que eram iguais
r_certo:	MOV		R1,M[codigo_m]	;coloca a sequencia secreta no R1
          ROR		R1,3		;roda para o proximo lagarismo
          MOV		M[codigo_m],R1	;coloca de volta na memoria
          INC		R5			;incrementar contador de rotacoes da sequencia
          JMP		c_errada	;testar com o novo algarismo da sequencia
r_tenta:	ROR   R1,4
          MOV   M[codigo_m],R1
          CMP		R3,4		;verifica se testou os 4 algarismos da tentativa
          BR.NZ	r_t_		;se tiver
          ROR   R2,4
          MOV   M[tentativa_m],R2
          MOV		M[errados],R4
          POP		R5
          POP		R4
          POP		R3
          POP		R2
          POP		R1
          RET

r_t_:	    MOV		R2,M[tentativa_m];colocar a tentativa em R2
          ROR		R2,3			;rodar para o proximo algarismo da tentativa
          MOV		M[tentativa_m],R2;colocar de volta na memoria
          INC		R3				;incrementar contador de rotacoes da tentativa
          MOV		R5,R0			;reiniciar contador de rotacoes da sequencia
          JMP		c_errada		;testar com o novo algarismo da tentativa

	
;***********************************************************************************

		
		
wrt_7seg:PUSH	R1
		PUSH	R2
		PUSH	R3
		MOV		R1,M[cont_jogadas]
		MOV		R2,10
		DIV		R1,R2
		MOV		R3,R2
		ROR		R3,4
		MOV		R2,10
		DIV		R1,R2
		ADD		R3,R2
		ROR		R3,12
		MOV		M[IO_DISPLAY0],R3
		ROR		R3,4
		MOV		M[IO_DISPLAY1],R3
		POP		R3
		POP		R2
		POP		R1
		RET

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
			CALL	output		;escreve o output na janela de texto
			PUSH	R1
			MOV		R1,M[acertou]	
			CMP		R1,1		;se tiver acertado nesta tentativa acaba o jogo
			JMP.Z	acertou_tent		;E PRECISO MUDAR PARA COMECAR UM NOVO JOGO
			MOV		R1,M[cont_jogadas]
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
;****************************highscore**********************************************

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
				
				

				
;***********************************************************************************				
;***********************************************************************************	
ganhou:				POP		R1
					MOV		M[acertou],R0
					PUSH	R1
					MOV		R1,STR_ganhou
					PUSH	R1
					CALL	esc_linha_seg
					MOV		R1,STR_recomecar
					PUSH	R1						;escreve para reiniciar
					CALL	esc_linha_seg
					POP		R1
					CALL	esc_hsc
					JMP		novo_jogo

perdeu:				POP		R1
					MOV		M[perdeu_jogo],R0	;reinicia variavel
					PUSH	R1
					MOV		R1,STR_perdeu_jogo	;escreve que perdeu
					PUSH	R1					;o ciclo remove este PUSH
					CALL	esc_linha_seg
					MOV		R1,STR_recomecar
					PUSH	R1						;escreve para reiniciar
					CALL	esc_linha_seg
					MOV		R1,12
					MOV		M[cont_jogadas],R1
					CALL	esc_hsc
					POP		R1

novo_jogo:			PUSH  R1
					MOV  R1,M[contador]
					INC  R1
					MOV  M[contador],R1
					POP  R1
					CMP		M[novo_jogo_],R0		;enquanto nao carregar em IA nao começa
					BR.Z	novo_jogo
					MOV		M[cont_jogadas],R0		;limpa contadores
					MOV		M[perdeu],R0
					MOV		M[acertou],R0
					MOV		M[novo_jogo_],R0
					CALL	random
					PUSH    R1
					MOV     R1,M[codigo]     ; passa o codigo para 12 bits e escree-o de volta na memoria
					PUSH    R1
					CALL    codi_12
					POP     R1
					MOV     M[codigo],R1
					POP     R1
					CALL	limpar_janela
nova_tentat:		MOV		M[tentativa],R0
					PUSH		R1
					MOV		R1,M[cont_jogadas]
					INC		R1
					MOV		M[cont_jogadas],R1
					CALL	wrt_7seg
					POP		R1
					CALL	ligar_leds
					PUSH	R1
					MOV		R1,M[perdeu_jogo]
					CMP		R1,R0				;se perdeu o jogo nao chama ciclo das tentativas faz logo novo jogo
					JMP.NZ	perdeu
					POP		R1
					PUSH    R1
					MOV     R1,M[codigo]     ; passa o codigo para 12 bits e escree-o de volta na memoria
					PUSH    R1
					CALL    codi_12
					POP     R1
					MOV     M[codigo],R1
					POP     R1
					CALL	c_tents
					PUSH	R1
					MOV		R1,M[acertou]		;caso tenha acertado reinicia
					CMP		R1,0
					JMP.NZ	ganhou
					MOV		R1,M[perdeu_jogo]	;caso tenha perdido o jogo reinicia
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
;7 segmentos chamar no inicio da jogada antes input (leds)
;quando acaba jogo atualizar highscore
;cicli esc coluna seg escreve primeiro e depois aumenta
							
fim:			BR		fim