/***************

PROGRAMA: MENUFUN.prg

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'

**********************
PROCEDURE MENUFUNCIO()
**********************
LOCAL cTela, nOpcao, cCor

cCor := SetColor( SETCORES( 2 ) )
cTela := ABRE2( 10, 14, 18, 33, TRUE )

WHILE TRUE
   FMENS('Use as Setas '+CHR(24)+' e '+CHR(25)+'.    F1=Help')
   @ 11, 16 PROMPT '1. Cadastros  '
   @ 13, 16 PROMPT '2. Movimentos '
   @ 15, 16 PROMPT '3. Relatorios '
   @ 17, 16 PROMPT '4. Adiant. 15¦'
   MENU TO nOpcao

   IF     nOpcao == 0 ; EXIT

   ELSEIF nOpcao == 1 ; CADASTROS()

   ELSEIF nOpcao == 2 ; MOVIMEN()

   ELSEIF nOpcao == 3 ; RELATORIO()

   ELSEIF nOpcao == 4 ; GERADESCTO()

   END

END

FECHA2( cTela )

SetColor ( cCor )

RETURN
              


**********************
PROCEDURE GERADESCTO()
**********************
LOCAL cTela, nCursor, nDescto := 0, GETLIST := {},;
      cCodFun, nValor, nSaldo, nLinha, nPagina, FLAG,;
      pRESET, pCOMPR, pDESCO, pDOUBL, pENFAT, pDESEN

cTela := ABRE( 11, 30, 15, 52, TRUE )
nCursor := SetCursor( SC_NORMAL )

FMENS('Digite o Percentual do Adiantamento.     Esc=Cancela.')
@ 11, 31 SAY "ADIANTAMENTO SALARIAL" COLOR "N/W+"
@ 13, 35 SAY "==> %" GET nDescto PICT "@E 99.99"
READ

IF LastKey() <> K_ESC
   FMENS( 'AGUARDE... Gerando Lan‡amentos de Adiantamento Salarial...' )
   USE DESCTO NEW
   ZAP
   INDEX ON DESCTO->CODIGO TO CODIGO

   SELE FUNCIONA
   SET RELATION TO FUNCIONA->CODIGO INTO MOVIMENT
   SET ORDER TO 1

   SELE MOVIMENT
   SET ORDER TO 1
   SET RELATION TO MOVIMENT->CODPROV INTO PRODES

   nDescto /= 100

   PRINTER->( dbGoto( 1 ) )
   pRESET := PR_COMM( AllTrim( PRINTER->RESET ) )
   pCOMPR := PR_COMM( AllTrim( PRINTER->COMPR ) )
   pDESCO := PR_COMM( AllTrim( PRINTER->DESCO ) )
   pDOUBL := PR_COMM( AllTrim( PRINTER->DOUBL ) )
   pENFAT := PR_COMM( AllTrim( PRINTER->ENFAT ) )
   pDESEN := PR_COMM( AllTrim( PRINTER->DESEN ) )

   FMENS( 'Ligue a Impressora...' )
   IF !FPRINTER ()
      FECHA( 11, 30, 15, 52, cTela, TRUE )
      SetCursor( nCursor )
      RETURN
   END

   FMENS( 'Aguarde... Emitindo Relatorio...' )
   nLinha := 100
   nPagina := 0

   SET DEVICE TO PRINT

   @ PRow(),PCol() SAY pRESET + pCOMPR

   FUNCIONA->(dbGoTop())
   FLAG := .T.
   WHILE !FUNCIONA->(EOF())
      IF !EMPTY( FUNCIONA->RECISAO )
         FUNCIONA->(dbSkip())
         FLAG := .T.
         LOOP
      END
      IF FLAG
         IF     nLinha >= 30 ; nLinha := 0

         ELSEIF nLinha < 30
                nLinha := 31
                @  30,  0 SAY Replicate( '-', 117 )
                @  30,  0 SAY Replicate( '=', 117 )
         END

         @  nLinha+1,  0 SAY pENFAT+'Funcionario: ' + pDOUBL+FUNCIONA->CODIGO +'  '+ ;
                  FUNCIONA->NOME+pDESEN
         @  nLinha+3,  0 SAY Replicate( '-', 117 )
         @  nLinha+4,  0 SAY 'DATA       DESCRICAO                              /HISTORICO                                     VALOR'
         @  nLinha+5,  0 SAY Replicate( '-', 117 )
         @  nLinha+7,  0 SAY Date()
         @  nLinha+7, 11 SAY nDescto*100 PICT "@E 99.99"
         @  nLinha+7, 16 SAY "% DO SALARIO"
         @  nLinha+7, 89 SAY FUNCIONA->SALARIO*nDescto PICT '@E 99,999,999.99'
         @  nLinha+7, 102 SAY '(+)'
         nLinha += 8
         IF FUNCIONA->SALDO != 0.00
            @ nLinha, 11 SAY "SALDO"
            IF FUNCIONA->SALDO > 0
               @  nLinha, 89 SAY FUNCIONA->SALDO PICT '@E 99,999,999.99'
               @  nLinha++, 102 SAY '(+)'
            ELSE
               @  nLinha, 89 SAY -FUNCIONA->SALDO PICT '@E 99,999,999.99'
               @  nLinha++, 102 SAY '(-)'
            END

         END
         FLAG := .F.
      END

      cCodFun := FUNCIONA->CODIGO
      nSaldo  := FUNCIONA->SALDO
      SELE MOVIMENT
      SEEK cCodFun
      WHILE MOVIMENT->CODFUNC == cCodFun .AND. !MOVIMENT->(EOF())
         IF Empty( MOVIMENT->NROFATURA )
            IF PRODES->TIPO == "D"
               nSaldo -= MOVIMENT->VALOR
               @ nLinha, 0 SAY DTOC( MOVIMENT->DATA )+' '+MOVIMENT->CODPROV+' '+;
                               PRODES->DESCRICAO+'/'+MOVIMENT->HISTORICO
               @ nLinha, 89 SAY MOVIMENT->VALOR PICT '@E 99,999,999.99'
               @ nLinha++, 102 SAY '(-)'
            END
         END
         MOVIMENT->(dbSkip())
      END

      nValor := FUNCIONA->SALARIO*nDescto + nSaldo

      @ ++nLinha, 0 SAY Replicate( '-', 117 )
      @ ++nLinha, 60 SAY "Valor do Adiantamento:"
      @ nLinha, 89 SAY nValor PICT '@E 99,999,999.99'

      nLinha += 5

      @ nLinha++, 10 SAY "___/___/_____,______________________________                              VALOR PAGO: ______________"

      @ nLinha++, 24 SAY FUNCIONA->NOME

      MOVIMENT->(dbAppend())
      MOVIMENT->CODFUNC    := cCodFun
      MOVIMENT->CODPROV    := "001"
      MOVIMENT->DATA       := Date()
      MOVIMENT->HISTORICO  := "***** L.A. *****"
      MOVIMENT->VALOR      := IF( nValor < 0, 0, nValor )

      DESCTO->(dbAppend())
      DESCTO->CODIGO := cCodFun
      DESCTO->VALOR  := IF( nValor < 0, 0, nValor )

      FUNCIONA->(dbSkip())
      FLAG := .T.

   END

   EJECT

   SET PRINTER TO
   SET DEVICE TO SCREEN
//   REPTELA( 'TESTE.$$$')

   FMENS('Tecle Enter.')

   ATENCAO( 'Emitido!' )

   SELE MOVIMENT
   SET RELATION TO
   
   SELE FUNCIONA
   SET ORDER TO 2
   SET RELATION TO FUNCIONA->CODIGO INTO DESCTO
   
   nLinha  := 100
   nPagina := 0

   SELE FUNCIONA
   SET ORDER TO 1
   SET RELATION TO
   
   SELE DESCTO
   dbCloseArea()

END
FECHA( 11, 30, 15, 52, cTela, TRUE )
SetCursor( nCursor )

RETURN

/****

  FIM MENUFUN.PRG

****/  
