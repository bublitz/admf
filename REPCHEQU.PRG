/***************

PROGRAMA: REPCHEQU.prg

FUN€AO: RELATORIO DE CHEQUES

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'
#include 'RepClass.CH'

#DEFINE  COLUNAS  102

**********************************
PROCEDURE RELCHEQU( dPar1, cPar2 )
**********************************
LOCAL cCor, cTela, nCurs, dData1, dData2, cPago,;
      oRelat, oCol1, oCol2, oCol3, oCol4, oCol5, oCol6,;
      bFiltro,;
      GETLIST := {}

SELE CLIFOR
SET ORDER TO 1

SELE CHEQUES
SET ORDER TO 1
SET RELATION TO CHEQUES->CLIFOR INTO CLIFOR

cCor := SETCOLOR( M->cCor2 )
nCurs := SETCURSOR( SC_NORMAL )
cTela := LIMPA( 4, 1, MAXROW()-3, MAXCOL()-1 )

@ 4, 1 SAY PADC ( 'RELACAO DE CHEQUES', 78 )
@ 5, 1 SAY PADC ( 'ßßßßßßßßßßßßßßßßßß', 78 )

IF dPar1 == Nil
   dData1 := dData2 := DATE()
   cPago := 'T'
ELSE
   dData1 := CTOD('01/01/1980')
   dData2 := dPar1
   cPago := 'N'
END      

WHILE .T.
   
   @ 10,  5 SAY 'De: ' GET dData1
   @ 10, 40 SAY 'At‚: ' GET dData2 VALID dData2 >= dData1
   @ 12,  5 SAY 'Emite (T)odos, (P)agos ou (N)ao Pagos (T/P/N): ' GET cPago ;
            PICT '!' VALID cPago $ 'TPN'
   IF dPar1 == Nil
      READ
   ELSE
      CLEAR GETS
   END
   
   IF LASTKEY() == K_ESC ; EXIT ; END
   
   dPar1 := NIL
   
   oRelat := ReportNew( 56 )

   .oRelat:header := { || { M->cNomeP,P_DOUBL+M->cNomeC,;
                            PADR(M->cNomeA,COLUNAS),;
                            SPACE(COLUNAS/2)+P_ENFAT+'RELACAO DE CHEQUES'+P_DESEN,'',;
                            'Emissao dos Cheques: ' + fCOMPLETA( cPago ) ,;
                            PADR('Data: ' + DTOC( DATE() ),COLUNAS/2 ) +; 
                            PADL('Pagina: '+STR( .oRelat:pageCounter, 4, 0 ),COLUNAS/2 ) } }

//   .oRelat:rodape := {'','',''}
   
   IF     cPago == 'T'
          bFiltro := { || CHEQUES->DTPAGAR >= dData1 .AND. CHEQUES->DTPAGAR <= dData2 }

   ELSEIF cPago == 'P'
          bFiltro := { || CHEQUES->DTPAGAR >= dData1 .AND. CHEQUES->DTPAGAR <= dData2 .AND. !EMPTY( CHEQUES->DTRECEBEU )}

   ELSEIF cPago == 'N'
          bFiltro := { || CHEQUES->DTPAGAR >= dData1 .AND. CHEQUES->DTPAGAR <= dData2 .AND. EMPTY( CHEQUES->DTRECEBEU )}

   ELSE
          LOOP

   END
   
   .oRelat:skipBlock := {| nRecords | RepSkipperF( nRecords, bFiltro ) }

   .oRelat:groupExp := { || CHEQUES->DTPAGAR }
   .oRelat:groupHeader := 'DATA: '

   oCol1 := TBColumnNew ( PADR('Numero', 10 ) ,{ || CHEQUES->NUMERO } )
   oCol1:picture := '@!'

   oCol2 := TBColumnNew ( PADR('Banco', 5 ) ,{ || CHEQUES->BANCO } )
   oCol2:picture := '@!'


   oCol3 := TBColumnNew ( PADR('Cliente/Fornecedor', 43 ) ,{ || CHEQUES->CLIFOR+'+'+CLIFOR->RAZAO } )
   oCol3:picture := '@!'

   oCol4 := TBColumnNew ( PADR('Pagar', 10 ) ,{ || CHEQUES->DTPAGAR } )

   oCol5 := TBColumnNew ( PADL('Valor',18),{ || CHEQUES->VALOR } )
   oCol5:picture := '@E 999,999,999,999.99'
   oCol5:cargo := { || CHEQUES->VALOR }

   oCol6 := TBColumnNew ( PADR('Pago', 10 ) ,{ || IF( EMPTY(CHEQUES->DTRECEBEU),;
                          SPACE(10),CHEQUES->DTRECEBEU ) } )

   // Adiciona colunas ao TBrowser
   .oRelat:addColumn ( oCol1 )
   .oRelat:addColumn ( oCol2 )
   .oRelat:addColumn ( oCol3 )
   .oRelat:addColumn ( oCol4 )
   .oRelat:addColumn ( oCol5 )
   IF cPago != 'N' ; .oRelat:addColumn ( oCol6 ) ; END

   RepSkipperF ( 0 )
   GoTop ( bFiltro )

   IF FPRINTER ()
      SET DEVICE TO PRINT

      @ 0,0 SAY P_RESET + P_COMPR

      WHILE ! .oRelat:stabilize()
      END

      EJECT

      SET PRINTER TO
      SET DEVICE TO SCREEN

   END

   ATENCAO( 'Emitido!' )

END

SET RELATION TO
Fmens('')

SETCOLOR( cCor )
SETCURSOR( nCurs )
RESTSCREEN( 4, 1, MAXROW()-3, MAXCOL()-1, cTela )

RETURN


FUNCTION fCOMPLETA( Q )
LOCAL R
IF     Q == 'P'
       R := 'Pagos'
ELSEIF Q == 'N'
       R := 'Nao Pagos' 
ELSE
       R := '(Todos)'
END
RETURN R
       
