/***************

PROGRAMA: REPFAT.prg

FUN€AO: RELACAO DE FATURAS

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'
#include 'COMBO.CH'

STATIC pRESET, pCOMPR, pDESCO, pDOUBL, pENFAT, pDESEN

*********************
PROCEDURE RepFATURA()
*********************
LOCAL cCor, cTela, nCurs, nCodFun,;
      cQual, dData1, dData2, nMes, nAno, cOnde, cPrinter,;
      GETLIST := {}

cCor  := SetColor( M->cCor2 )
nCurs := SetCursor( SC_NORMAL )
cTela := TELAReport( ' RELA€AO DE FATURAS ' )

cOnde := cPrinter := cQual := ' '
dData1 := dData2 := CTOD('')
nCodFun := 0

WHILE .T.

   nMes := nAno := 0

   @  7,10 SAY 'Imprime Previsao ou Fatura:' GET cQual PICT '!' ;
           COMBO { 'Previsao','Fatura' } ;
           VALID cQual$'PF'

   // PREVISAO
   @  9,10 SAY 'Data Inicial:' GET dData1 WHEN cQual == 'P' VALID !Empty(dData1)
   @  9,40 SAY 'Data Final:'   GET dData2 WHEN cQual == 'P' VALID dData2 >= dData1

   // FATURA
   @ 11,10 SAY 'Mes de Referencia:' GET nMes PICT '99' ;
           WHEN cQual == 'F' VALID nMes>0 .AND. nMes<13
   @ 11,40 SAY 'Ano:' GET nAno PICT '99' WHEN cQual == 'F'


   @ 13,10 SAY 'Funcionario:' ;
           GET nCodFun PICT '999' ;
           VALID PESQFUN( nCodFun ) .OR. VERIFICA( nCodFun, 13, 28 )

   @ 17,10 SAY 'Impressora ou Tela:' GET cOnde PICT '!' ;
           COMBO { 'Impressora','Tela' } ;
           VALID cOnde$'TI'

   @ 19,10 SAY 'Impressora:' GET cPrinter ;
           COMBO A_PRINT ;
           VALID cPrinter$'123' ;
           WHEN cOnde == 'I'

   READ

   IF LASTKEY() == K_ESC ; EXIT ; END

   IF nAno < SET( _SET_EPOCH )-1900
      nAno += 2000
   ELSE
      nAno += 1900
   END

   PRINTER->( dbGoto( Val( cPrinter ) ) )
   pRESET := PR_COMM( AllTrim( PRINTER->RESET ) )
   pCOMPR := PR_COMM( AllTrim( PRINTER->COMPR ) )
   pDESCO := PR_COMM( AllTrim( PRINTER->DESCO ) )
   pDOUBL := PR_COMM( AllTrim( PRINTER->DOUBL ) )
   pENFAT := PR_COMM( AllTrim( PRINTER->ENFAT ) )
   pDESEN := PR_COMM( AllTrim( PRINTER->DESEN ) )

   IF cOnde == 'T' .OR. FPRINTER ()
      FMENS( 'Aguarde... Emitindo Relatorio...' )
      SET DEVICE TO PRINT

      IF     cOnde == 'T'
             SET ( 24, '$REL.' + M->cTerm, FALSE )

      ELSE
             @ PRow(),PCol() SAY pRESET + pCOMPR

      END

      IF cQual == 'P'  // PREVISAO
         RepPRE( dData1, dData2, cOnde, nCodFun )
      ELSE
         RepFA1( nMes, nAno, cOnde, nCodFun )
      END

      IF cOnde == 'I' ; EJECT ; END

      SET PRINTER TO
      SET DEVICE TO SCREEN

      FMENS('')

      IF cOnde == 'T'
         REPTELA( '$REL.' + M->cTerm )
         FErase( '$REL.' + M->cTerm )

      ELSE
         ATENCAO( 'Emitido!' )

      END

      FMENS('')
   END


END

Fmens('')

SETCOLOR( cCor )
SETCURSOR( nCurs )
RESTSCREEN( 4, 1, MAXROW()-3, MAXCOL()-1, cTela )

RETURN

******************************************
PROCEDURE RepPRE( D1, D2, cOnde, nCodFun )
******************************************
LOCAL nLinha, nPagina, cCodFun, nColuna, nDebito, nCredito, lImprimiu, lPV,;
      nSalario, nSaldo

SELE FUNCIONA
SET ORDER TO 1

SELE MOVIMENT
SET RELATION TO MOVIMENT->CODFUNC INTO FUNCIONA ,;
             TO MOVIMENT->CODPROV INTO PRODES

IF nCodFun == 0
   MOVIMENT->(dbGoTop())
   cCodFun := MOVIMENT->CODFUNC

ELSE
   cCodFun := StrZero( nCodFun, 3, 0 )
   SEEK cCodFun

END

nLinha := 100
nPagina := nDebito := nCredito := 0
lImprimiu := FALSE
lPV := TRUE

WHILE !MOVIMENT->(EOF())
    lImprimiu := TRUE
    IF nLinha > 56 // EMITE CABECALHO
       IF cOnde == 'I'
          @  0, 0 SAY pDOUBL+M->cNomeC
          @  1, 0 SAY M->cNomeA
          @  2, 0 SAY pDOUBL+pENFAT+PADC('RELACAO DE PREVISAO DE FATURAS', 53 )+pDESEN
       ELSE
          @  0, 0 SAY M->cNomeC
          @  1, 0 SAY M->cNomeA
          @  2, 0 SAY PADC('RELACAO DE PREVISAO DE FATURAS', 106 )
       END
       @  4, 0 SAY 'Data: ' + DTOC( DATE() )
       @  4,20 SAY 'Periodo: ' + DTOC( D1 ) + ' a ' + DTOC( D2 )
       @  4,106 SAY 'Pagina: '+STR( ++nPagina, 3, 0 )
       @  5, 0 SAY Replicate( '-', 117 )
       @  6, 0 SAY 'DATA       DESCRICAO                              /HISTORICO                                   CREDITO         DEBITO'
       @  7, 0 SAY Replicate( '-', 117 )
       IF cOnde == 'I'
          @  9, 0 SAY pENFAT+'Funcionario: ' + pDOUBL+MOVIMENT->CODFUNC + '  ' +;
                  FUNCIONA->NOME+pDESEN
       ELSE
          @  9, 0 SAY 'Funcionario: '+MOVIMENT->CODFUNC+'  '+FUNCIONA->NOME
       END
       nSalario := FUNCIONA->SALARIO
       nSaldo   := FUNCIONA->SALDO
       nLinha := 11
    END
    IF MOVIMENT->DATA >= D1 .AND. MOVIMENT->DATA <= D2
       IF cCodFun # MOVIMENT->CODFUNC   // SE MUDOU FUNCIONARIO
          nLinha++
          @ ++nLinha, 70 SAY 'TOTAL:'
          @ nLinha,   89 SAY nCredito PICT '@E 99,999,999.99'
          @ nLinha,   104 SAY nDebito  PICT '@E 99,999,999.99'
          nLinha++
          @ ++nLinha, 70 SAY 'SALDO:'
          @ nLinha,   104 SAY nCredito-nDebito  PICT '@E 99,999,999.99'
          @ ++nLinha, 0 SAY "       "

          nDebito := nCredito := 0
          lPV := TRUE

          IF nCodFun # 0 // SE FOR SO DE UM FUNCIONARIO
             MOVIMENT->(dbGoBottom())
             MOVIMENT->(dbSkip())
          END
          nLinha := 100 // MUDA DE PAGINA
          cCodFun := MOVIMENT->CODFUNC
          LOOP
       END
       IF lPV   // SE E' PRIMEIRA VEZ, IMPRIME SALARIO E O SALDO
          @ nLinha,  0 SAY 'Salario'
          @ nLinha++, 89 SAY nSalario PICT '@E 99,999,999.99'
          lPV := FALSE
          nCredito += nSalario
	  IF nSaldo != 0
	     @ nLinha,  0 SAY 'Saldo'
             IF nSaldo > 0
                nCredito += nSaldo
                nColuna := 89
             ELSE
                nDebito += ABS( nSaldo )
                nColuna := 104
             END
             @ nLinha++, nColuna SAY ABS(nSaldo) PICT '@E 99,999,999.99'

	  END
       END
       @ nLinha, 0 SAY DTOC( MOVIMENT->DATA ) + ' ' + MOVIMENT->CODPROV + ' '+;
                       PRODES->DESCRICAO + '/' + MOVIMENT->HISTORICO
       IF PRODES->TIPO == 'P'
          nCredito += MOVIMENT->VALOR
          nColuna := 89
       ELSE
          nDebito += MOVIMENT->VALOR
          nColuna := 104
       END
       @ nLinha++, nColuna SAY MOVIMENT->VALOR PICT '@E 99,999,999.99'
    END
    MOVIMENT->(dbSkip())
END

nLinha++
@ ++nLinha, 70 SAY 'TOTAL:'
@ nLinha, 89 SAY nCredito PICT '@E 99,999,999.99'
@ nLinha, 104 SAY nDebito  PICT '@E 99,999,999.99'
nLinha++
@ ++nLinha, 70 SAY 'SALDO:'
@ nLinha,   104 SAY nCredito-nDebito  PICT '@E 99,999,999.99'


SELE MOVIMENT
SET RELATION TO
RETURN




********************************************
PROCEDURE RepFA1( MES, ANO, cOnde, nCodFun )
********************************************
LOCAL nLinha, nPagina, cCodFun, nColuna,; 
      nDebito, nCredito, cCodFat, cAnoMes, nSalario, lImprimiu, lPV

cAnoMes := Str( ANO, 4, 0 ) + StrZero( MES, 2, 0 )
ALTD()

SELE FUNCIONA
SET RELATION TO
SET ORDER TO 1

SELE MOVIMENT
SET ORDER TO 2
SET RELATION TO MOVIMENT->NROFATURA INTO FATURAS ,;
             TO MOVIMENT->CODFUNC INTO FUNCIONA ,;
             TO MOVIMENT->CODPROV INTO PRODES

IF nCodFun == 0
   SEEK cAnoMes
   cCodFat := FATURAS->NUMERO
   cCodFun := SubStr( FATURAS->NUMERO, 7 )

ELSE
   cCodFun := StrZero( nCodFun, 3, 0 )
   cCodFat := cAnoMes + cCodFun
   SEEK cCodFat

END

nLinha := 100
nPagina := nDebito := nCredito := 0
lImprimiu := FALSE
lPV := TRUE

SELE MOVIMENT
WHILE !MOVIMENT->(EOF())
    lImprimiu := TRUE
    IF nLinha > 56 // EMITE CABECALHO
       IF cOnde == 'I'
          @  0, 0 SAY pDOUBL+M->cNomeC
          @  1, 0 SAY M->cNomeA
          @  2, 0 SAY pDOUBL+pENFAT+PADC('RELACAO DE FATURAS', 53 )+pDESEN
       ELSE
          @  0, 0 SAY M->cNomeC
          @  1, 0 SAY M->cNomeA
          @  2, 0 SAY PADC('RELACAO DE FATURAS', 106 )
       END
       @  4, 0 SAY 'Data: ' + DTOC( DATE() )
       @  4,50 SAY 'Mes/Ano: ' + StrZero( MES, 2, 0 ) + ' / ' + Str( ANO, 4, 0 )
       @  4,106 SAY 'Pagina: '+STR( ++nPagina, 3, 0 )
       @  5, 0 SAY Replicate( '-', 117 )
       @  6, 0 SAY 'DATA       DESCRICAO                              /HISTORICO                                   CREDITO         DEBITO'
       @  7, 0 SAY Replicate( '-', 117 )
       IF cOnde == 'I'
          @  9, 0 SAY pENFAT+'Fatura: ' + pDOUBL + ;
                  Transform( FATURAS->NUMERO, "@R 9999.99.999" ) + '  ' +;
                  FUNCIONA->NOME+pDESEN
       ELSE
          @  9, 0 SAY 'Fatura: '+ Transform( FATURAS->NUMERO, "@R 9999.99.999" ) +;
                  '  ' + FUNCIONA->NOME
       END
       nSalario := FUNCIONA->SALARIO
       nLinha := 11
    END
    IF SubStr( MOVIMENT->NROFATURA, 1, 6 ) == cAnoMes
       IF cCodFun # MOVIMENT->CODFUNC   // SE MUDOU FUNCIONARIO
          MOVIMENT->(dbSkip(-1))
          @ ++nLinha, 65 SAY 'Sub-Total:'
          @ nLinha,   89 SAY nCredito PICT '@E 99,999,999.99'
          @ nLinha,   104 SAY nDebito  PICT '@E 99,999,999.99'
          nLinha++
          IF FATURAS->SALDOANTER < 0
             @ ++nLinha, 65 SAY '(-)Saldo:'
             @ nLinha,   104 SAY -FATURAS->SALDOANTER PICT '@E 99,999,999.99'
          ELSE
             @ ++nLinha, 65 SAY '(+)Saldo:'
             @ nLinha,   89 SAY FATURAS->SALDOANTER PICT '@E 99,999,999.99'
          END
          @ ++nLinha, 65 SAY 'Total:'
          IF FATURAS->SALDOANTER < 0
             @ nLinha,   89 SAY nCredito PICT '@E 99,999,999.99'
             @ nLinha,   104 SAY nDebito-FATURAS->SALDOANTER PICT '@E 99,999,999.99'
          ELSE
             @ nLinha,   89 SAY nCredito+FATURAS->SALDOANTER PICT '@E 99,999,999.99'
             @ nLinha,   104 SAY nDebito PICT '@E 99,999,999.99'
          END
          nLinha++
          @ ++nLinha,  75 SAY "Valor a Pagar:"
          @ nLinha, 104 SAY FATURAS->VALOR PICT '@E 99,999,999.99'
          nLinha++
          IF FATURAS->VALORPAGO != 0.00
             @ ++nLinha, 75 SAY "Valor Pago:"
             @   nLinha, 104 SAY FATURAS->VALORPAGO PICT '@E 99,999,999.99'
             @ ++nLinha, 75 SAY "Saldo:"
             @   nLinha, 104 SAY FATURAS->VALOR-FATURAS->VALORPAGO PICT '@E 99,999,999.99'
          ELSE
             nLinha += 5
             @ nLinha++, 10 SAY "___/___/_____,______________________________                              VALOR PAGO: ______________"
             @ nLinha++, 24 SAY FUNCIONA->NOME
          END
          @ ++nLinha, 0 SAY "       "

          nDebito := nCredito := 0
          lPV := TRUE
          
          IF nCodFun # 0 // SE FOR SO DE UM FUNCIONARIO
             MOVIMENT->(dbGoBottom())
             MOVIMENT->(dbSkip())
          END
          MOVIMENT->(dbSkip())
          nLinha := 100 // MUDA DE PAGINA
          cCodFun := MOVIMENT->CODFUNC
          LOOP
       END
       IF lPV   // SE E' PRIMEIRA VEZ, IMPRIME SALARIO
          @ nLinha,  0 SAY 'Salario'
          @ nLinha++, 89 SAY nSalario PICT '@E 99,999,999.99'
          lPV := FALSE
          nCredito += nSalario
       END
       @ nLinha, 0 SAY DTOC( MOVIMENT->DATA ) + ' ' + MOVIMENT->CODPROV + ' '+;
                       PRODES->DESCRICAO + '/' + MOVIMENT->HISTORICO
       IF PRODES->TIPO == 'P'
          nCredito += MOVIMENT->VALOR
          nColuna := 89
       ELSE
          nDebito += MOVIMENT->VALOR
          nColuna := 104
       END
       @ nLinha, nColuna SAY MOVIMENT->VALOR PICT '@E 99,999,999.99'
       nLinha++
    ELSE
       MOVIMENT->(dbGoBottom())
    END
    MOVIMENT->(dbSkip())
END
IF lImprimiu // .AND. nCodFun == 0
   MOVIMENT->(dbSkip(-1))
   @ ++nLinha, 65 SAY 'Sub-Total:'
   @ nLinha,   89 SAY nCredito PICT '@E 99,999,999.99'
   @ nLinha,   104 SAY nDebito  PICT '@E 99,999,999.99'
   nLinha++
   IF FATURAS->SALDOANTER < 0
      @ ++nLinha, 65 SAY '(-)Saldo:'
      @ nLinha,   104 SAY -FATURAS->SALDOANTER PICT '@E 99,999,999.99'
   ELSE
      @ ++nLinha, 65 SAY '(+)Saldo:'
      @ nLinha,   89 SAY FATURAS->SALDOANTER PICT '@E 99,999,999.99'
   END
   @ ++nLinha, 65 SAY 'Total:'
   IF FATURAS->SALDOANTER < 0
      @ nLinha,   89 SAY nCredito PICT '@E 99,999,999.99'
      @ nLinha,   104 SAY nDebito-FATURAS->SALDOANTER PICT '@E 99,999,999.99'
   ELSE
      @ nLinha,   89 SAY nCredito+FATURAS->SALDOANTER PICT '@E 99,999,999.99'
      @ nLinha,   104 SAY nDebito PICT '@E 99,999,999.99'
   END
   nLinha++
   @ ++nLinha,  75 SAY "Valor a Pagar:"
   @ nLinha, 104 SAY FATURAS->VALOR PICT '@E 99,999,999.99'
   nLinha++
   IF FATURAS->VALORPAGO != 0.00
      @ ++nLinha, 75 SAY "Valor Pago:"
      @   nLinha, 104 SAY FATURAS->VALORPAGO PICT '@E 99,999,999.99'
      @ ++nLinha, 75 SAY "Saldo:"
      @   nLinha, 104 SAY FATURAS->VALOR-FATURAS->VALORPAGO PICT '@E 99,999,999.99'
   ELSE
      nLinha += 5
      @ nLinha++, 10 SAY "___/___/_____,______________________________                              VALOR PAGO: ______________"
      @ nLinha++, 24 SAY FUNCIONA->NOME
   END
   @ ++nLinha, 0 SAY "       "
END

SELE FATURAS
SET RELATION TO

SELE MOVIMENT
SET ORDER TO 1
SET RELATION TO
RETURN
