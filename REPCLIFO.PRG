/***************

PROGRAMA: REPBANCOS.prg

FUN€AO: RELATORIO DE BANCOS

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'
#include 'RepClass.CH'

#DEFINE  COLUNAS  50

****************************
PROCEDURE RELCLIFOR( cTipo )
****************************
LOCAL cCor, cTela, nCurs,;
      oRelat, oCol1, oCol2, oCol3, oCol4, oCol5,;
      bFiltro,;
      GETLIST := {}

SELE CLIFOR
SET ORDER TO 2

cCor := SETCOLOR( M->cCor2 )
nCurs := SETCURSOR( SC_NORMAL )
cTela := LIMPA( 4, 1, MAXROW()-3, MAXCOL()-1 )

@ 4, 1 SAY PADC ( 'RELACAO DE CLIENTES/FORNECEDORES', 78 )
@ 5, 1 SAY PADC ( 'ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß', 78 )

// WHILE .T.
   
   oRelat := ReportNew( 56 )

   .oRelat:header := { || { M->cNomeP,P_DOUBL+M->cNomeC,;
                            PADR(M->cNomeA,COLUNAS),;
                            SPACE(COLUNAS/2)+P_ENFAT+'RELACAO DE '+IF(cTipo='C','CLIENTES','FORNECEDORES')+P_DESEN,'',;
                            PADR('Data: ' + DTOC( DATE() ),COLUNAS/2 ) +; 
                            PADL('Pagina: '+STR( .oRelat:pageCounter, 4, 0 ),COLUNAS/2 ) } }
// .oRelat:rodape := {'','',''}
   

   bFiltro := { || SUBSTR(CLIFOR->CODIGO,1,1)==cTipo }
   .oRelat:skipBlock := {| nRecords | RepSkipF( nRecords, bFiltro ) }

   oCol1 := TBColumnNew ( 'Codigo ' ,{ || CLIFOR->CODIGO } )
   oCol1:picture := '@!'

   oCol2 := TBColumnNew ( PADR('Razao Social',35),{ || CLIFOR->RAZAO } )
   oCol2:picture := '@!'

   // Adiciona colunas ao TBrowser
   .oRelat:addColumn ( oCol1 )
   .oRelat:addColumn ( oCol2 )

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

// END

SET RELATION TO
Fmens('')

SETCOLOR( cCor )
SETCURSOR( nCurs )
RESTSCREEN( 4, 1, MAXROW()-3, MAXCOL()-1, cTela )

RETURN
