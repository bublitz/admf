/***************

PROGRAMA: REPBANCOS.prg

FUN€AO: RELATORIO DE BANCOS

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'
#include 'RepClass.CH'

#DEFINE  COLUNAS  102

*********************
PROCEDURE RELBANCOS()
*********************
LOCAL cCor, cTela, nCurs,;
      oRelat, oCol1, oCol2, oCol3, oCol4, oCol5,;
      bFiltro,;
      GETLIST := {}

SELE BANCOS
SET ORDER TO 1

cCor := SETCOLOR( M->cCor2 )
nCurs := SETCURSOR( SC_NORMAL )
cTela := LIMPA( 4, 1, MAXROW()-3, MAXCOL()-1 )

@ 4, 1 SAY PADC ( 'RELATORIO DE BANCOS', 78 )
@ 5, 1 SAY PADC ( 'ßßßßßßßßßßßßßßßßßßß', 78 )

// WHILE .T.
   
   oRelat := ReportNew( 56 )

   .oRelat:header := { || { M->cNomeP,P_DOUBL+M->cNomeC,;
                            PADR(M->cNomeA,COLUNAS),;
                            SPACE(COLUNAS/2)+P_ENFAT+'RELACAO DE BANCOS'+P_DESEN,'',;
                            PADR('Data: ' + DTOC( DATE() ),COLUNAS/2 ) +; 
                            PADL('Pagina: '+STR( .oRelat:pageCounter, 4, 0 ),COLUNAS/2 ) } }
// .oRelat:rodape := {'','',''}
   
   oCol1 := TBColumnNew ( 'Codigo' ,{ || BANCOS->CODIGO+'  ' } )
   oCol1:picture := '@!'

   oCol2 := TBColumnNew ( PADR('Nome',35),{ || BANCOS->NOME } )
   oCol2:picture := '@!'

   oCol3 := TBColumnNew ( PADL('Disponivel',18),{ || BANCOS->SALDODISP } )
   oCol3:picture := '@E 999,999,999,999.99'

   oCol4 := TBColumnNew ( PADL('Vinculado',18),{ || BANCOS->SALDOVINC } )
   oCol4:picture := '@E 999,999,999,999.99'

   oCol5 := TBColumnNew ( PADL('Total',20),{ || BANCOS->SALDODISP+BANCOS->SALDOVINC } )
   oCol5:picture := '@E 9 999 999 999 999.99'

   // Adiciona colunas ao TBrowser
   .oRelat:addColumn ( oCol1 )
   .oRelat:addColumn ( oCol2 )
   .oRelat:addColumn ( oCol3 )
   .oRelat:addColumn ( oCol4 )
   .oRelat:addColumn ( oCol5 )

//   RepSkipperF ( 0 )
//   GoTop ( bFiltro )
    GO TOP

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
