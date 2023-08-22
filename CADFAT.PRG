/***************

PROGRAMA: CADFAT.prg

FUN€AO: GERA FATURAS

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'

*******************
PROCEDURE FATURAS()
*******************
LOCAL cTela, cTelaLimpa, cCor, nEscolha,;
      nII, nCursor, GETLIST := {},;
      dData1, dData2, nMes, dPagto, nAno,;
      cCodFunc, nSaldo, cNroFatura

cTela   := SAVESCREEN ( 0, 0, MAXROW(), MAXCOL() )
nCursor := SETCURSOR( SC_NORMAL )
cCor    := SETCOLOR( M->cCor2 )

FOR nII := 1 TO MAXROW()-7
   SCROLL( 4, 1, MAXROW()-3, MAXCOL()-1, 0, -nII )
   INKEY( .01 )
NEXT
SCROLL( 4, 1, MAXROW()-3, MAXCOL()-1 )

@ 4, 1 SAY PADC ( 'FATURAS', 78 ) ;
       COLOR M->cCor2

@ 5, 1 SAY PADC ( 'ßßßßßßß', 78 ) ;
       COLOR M->cCor2

@  7, 2 SAY "Mes de Referencia:       Ano:"
@  9, 2 SAY "Data Inicial:"
@ 11, 2 SAY "Data Final:"
@ 13, 2 SAY "Previsao de Pagamento:"
FMENS('')

SETCOLOR( M->cCor1 )

cTelaLimpa := SAVESCREEN ( 0, 0, MAXROW(), MAXCOL() )

dData1 := dData2 := dPagto := CTOD('')

WHILE TRUE

   RESTSCREEN ( 0, 0, MAXROW(), MAXCOL(), cTelaLimpa )

   SETCURSOR ( SC_NORMAL )

   nMes := nAno := 0
   @  7, 21 GET  nMes   PICT "99" VALID nMes>0 .AND. nMes<13
   @  7, 32 GET  nAno   PICT "99"
   @  9, 17 GET  dData1 VALID !Empty( dData1 )
   @ 11, 15 GET  dData2 VALID dData2 >= dData1
   @ 13, 25 GET  dPagto
   READ

   IF LASTKEY() == K_ESC ; EXIT ; END

   IF nAno < SET( _SET_EPOCH )-1900
      nAno += 2000
   ELSE
      nAno += 1900
   END

   FMENS( "AGUARDE... Gerando Faturas..." )
   SELE MOVIMENT
   SET RELATION TO MOVIMENT->CODPROV INTO PRODES

   SELE FUNCIONA
   SET ORDER TO 1
   FUNCIONA->(dbGoTop())

   WHILE !FUNCIONA->(EOF())
       cCodFunc := FUNCIONA->CODIGO
       nSaldo   := FUNCIONA->SALARIO

       @ 15, 2 SAY "Funcionario: " + cCodFunc
       
       cNroFatura := Str( nAno,4,0 ) + StrZero( nMes, 2, 0 ) + cCodFunc
       
       SELE MOVIMENT
       SEEK cCodFunc
       WHILE MOVIMENT->CODFUNC == cCodFunc .AND. !MOVIMENT->(EOF())
           IF MOVIMENT->DATA >= dData1 .AND. MOVIMENT->DATA <= dData2
              IF EMPTY( MOVIMENT->NROFATURA ) .OR. MOVIMENT->NROFATURA == cNroFatura
                 MOVIMENT->NROFATURA := cNroFatura
                 nSaldo += IF( PRODES->TIPO == "D", -MOVIMENT->VALOR, MOVIMENT->VALOR )
              END
           END
           MOVIMENT->(dbSkip())
       END

       SELE FATURAS
       SEEK cNroFatura
       IF !Found() ; FATURAS->(dbAppend()) ; END
       IF Empty( FATURAS->DTPAGTO )
          FATURAS->NUMERO     := cNroFatura
          FATURAS->DTPREVISAO := dPagto
          FATURAS->DTEMISS    := Date()
          FATURAS->VALOR      := nSaldo
          FATURAS->SALDOANTER := FUNCIONA->SALDO
       END
       FUNCIONA->(dbSkip())
   END
   
   @ 15, 2 SAY "                    "

   SELE MOVIMENT
   SET RELATION TO

END

RESTSCREEN ( 0, 0, MAXROW(), MAXCOL(), cTela )
SETCOLOR( cCor )
SETCURSOR( nCursor )
RETURN
