/***************

PROGRAMA: BAIXAFAT.prg

FUN€AO: BAIXA DE FATURAS

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'

*****************
PROCEDURE BAIXA()
*****************
LOCAL cTela, cTelaLimpa, cCor, nEscolha,;
      nII, nCursor, GETLIST := {},;
      nMes, nAno, nCodFunc, nSaldo, cNroFatura, nValor

cTela   := SAVESCREEN ( 0, 0, MAXROW(), MAXCOL() )
nCursor := SETCURSOR( SC_NORMAL )
cCor    := SETCOLOR( M->cCor2 )

FOR nII := 1 TO MAXROW()-7
   SCROLL( 4, 1, MAXROW()-3, MAXCOL()-1, 0, nII )
   INKEY( .01 )
NEXT
SCROLL( 4, 1, MAXROW()-3, MAXCOL()-1 )

@ 4, 1 SAY PADC ( 'BAIXA DE FATURAS', 78 ) COLOR M->cCor2
@ 5, 1 SAY PADC ( 'ßßßßßßßßßßßßßßßß', 78 ) COLOR M->cCor2

//                   1         2         3
//           23456789 123456789 123456789
@  7,  2 SAY "Mes de Referencia:       Ano:"
@ 11,  2 SAY "Funcionario:"
@ 12,  2 SAY "Saldo Atual:"
@ 14,  2 SAY "Fatura:"
@ 15,  2 SAY "Valor:"
@ 17, 10 SAY "Valor a Receber:"
@ 19, 10 SAY "Valor a Pagar:"

FMENS('')

SETCOLOR( M->cCor1 )

cTelaLimpa := SAVESCREEN ( 0, 0, MAXROW(), MAXCOL() )

WHILE TRUE

   RESTSCREEN ( 0, 0, MAXROW(), MAXCOL(), cTelaLimpa )

   SETCURSOR ( SC_NORMAL )

   nMes := nAno := nCodFunc := 0

   @  7, 21 GET  nMes   PICT "99" VALID nMes>0 .AND. nMes<13
   @  7, 32 GET  nAno   PICT "99"
   READ

   IF LASTKEY() == K_ESC ; EXIT ; END

   IF nAno < SET( _SET_EPOCH )-1900
      nAno += 2000
   ELSE
      nAno += 1900
   END

   WHILE .T.
      @ 11, 15 GET nCodFunc PICT "999" VALID PESQFUN( nCodFunc )
      READ

      IF LASTKEY() == K_ESC ; EXIT ; END

      cNroFatura := Str( nAno,4,0 ) + StrZero( nMes, 2, 0 ) + StrZero( nCodFunc, 3, 0 )

      SELE FATURAS
      SEEK cNroFatura
      IF !Found()
         ALERT( "ATENCAO!;Fatura nao foi Gerada!",{"Retorna"}, M->cCor3 )
         LOOP
      END

      IF !Empty( FATURAS->DTPAGTO )
         ALERT( "ATENCAO!;Fatura ja foi Baixada!",{"Retorna"}, M->cCor3 )
         LOOP
      END

      @ 12, 15 SAY FUNCIONA->SALDO PICT "@E 9,999,999.99" COLOR M->cCor1
      @ 14, 10 SAY cNroFatura PICT "@R 9999.99.999" COLOR M->cCor1
      @ 15,  9 SAY FATURAS->VALOR PICT "@E 9,999,999.99" COLOR M->cCor1
      @ 17, 27 SAY FATURAS->VALOR+FUNCIONA->SALDO PICT "@E 99,999,999.99" COLOR M->cCor1

      nValor := nSaldo := FATURAS->VALOR+FUNCIONA->SALDO
      @ 19, 25 GET nValor PICT "@E 9,999,999.99" VALID nValor >= 0
      READ

      IF LASTKEY() == K_ESC ; LOOP ; END
      
      nSaldo := ABS( nSaldo ) - nValor

      IF ATENCAO( 'Confirma Baixa?; ',{'Nao','Sim'}, M->cCor2 ) == 2
         FATURAS->DTPAGTO   := Date()
         FATURAS->VALORPAGO := nValor
         FUNCIONA->SALDO    := nSaldo
      END
      
   END

END

RESTSCREEN ( 0, 0, MAXROW(), MAXCOL(), cTela )
SETCOLOR( cCor )
SETCURSOR( nCursor )
RETURN
