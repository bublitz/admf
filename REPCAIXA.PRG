/***************

PROGRAMA: REPCAIXA.prg

FUN€AO: RELATORIO DE CAIXA

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'
#include 'ComBo.ch'
#include 'Set.ch'
#include 'RepClass.CH'

#DEFINE  COLUNAS  102

***********************
PROCEDURE ReportCAIXA()
***********************
LOCAL cCor, cTela, nCurs, dData, ;
      oRelat, oCol1, oCol2, oCol3, oCol4, oCol5,;
      bFiltro, cPrinter,;
      pRESET, pCOMPR, pDESCO, pDOUBL, pENFAT, pDESEN,;
      GETLIST := {}

SELE CAIXA
SET ORDER TO 1

cCor := SETCOLOR( SETCORES(2) )
nCurs := SETCURSOR( SC_NORMAL )
cTela := TELAReport( ' MOVIMENTO DE CAIXA ' )

dData := DATE()
cPrinter := ' '

WHILE .T.
   
   @ 8, 10 SAY 'Data: ' GET dData WHEN FMENS( 'Digite a data para emitir o caixa.')

   @ 10,10 SAY "Impressora:" GET cPrinter ;
           COMBO A_PRINT ;
           VALID cPrinter$"1234" ;
           WHEN FMENS( 'Escolha a Impressora.' )

   READ
   
   FMENS('')
   
   IF LASTKEY() == K_ESC ; EXIT ; END
   
   PRINTER->( dbGoto( Val( cPrinter ) ) )
   pRESET := PR_COMM( AllTrim( PRINTER->RESET ) )
   pCOMPR := PR_COMM( AllTrim( PRINTER->COMPR ) )
   pDESCO := PR_COMM( AllTrim( PRINTER->DESCO ) )
   pDOUBL := PR_COMM( AllTrim( PRINTER->DOUBL ) )
   pENFAT := PR_COMM( AllTrim( PRINTER->ENFAT ) )
   pDESEN := PR_COMM( AllTrim( PRINTER->DESEN ) )

   oRelat := {}
   oRelat := ReportNew( 56 )

   .oRelat:header := { || { pDOUBL+M->cNomeC,;
                            PADR(M->cNomeA,COLUNAS),;
                            pDOUBL+pENFAT+PADC('MOVIMENTO DE CAIXA',COLUNAS/2)+pDESEN,'',;
                            PADR('Data: ' + DTOC( dData ),COLUNAS/2 ) +;
                            PADL('Pagina: '+STR( .oRelat:pageCounter, 4, 0 ),COLUNAS/2 ) } }


// .oRelat:rodape := {'','',''}
   
   bFiltro := { || CAIXA->DATA == dData }
   .oRelat:skipBlock := {| nRecords | RepSkipF( nRecords, bFiltro ) }

   oCol1 := TBColumnNew ( PADR('Historico', 50 ) ,{ || CAIXA->HISTORICO } )
   oCol1:picture := '@!'

   oCol2 := TBColumnNew ( PADL('Entrada',18),{ || CAIXA->ENTRADA } )
   oCol2:picture := '@E 999,999,999,999.99'
   oCol2:cargo := { || CAIXA->ENTRADA }

   oCol3 := TBColumnNew ( PADL('Saida',18),{ || CAIXA->SAIDA } )
   oCol3:picture := '@E 999,999,999,999.99'
   oCol3:cargo := { || CAIXA->SAIDA }

   oCol4 := TBColumnNew ( PADL('Saldo',20),{ || CAIXA->ENTRADA-CAIXA->SAIDA } )
   oCol4:picture := '@E 9 999 999 999 999.99'
   oCol4:cargo := { || CAIXA->ENTRADA-CAIXA->SAIDA }

   // Adiciona colunas ao TBrowser
   .oRelat:addColumn ( oCol1 )
   .oRelat:addColumn ( oCol2 )
   .oRelat:addColumn ( oCol3 )
   .oRelat:addColumn ( oCol4 )

   RepSkipperF ( 0 )
   GoTop ( bFiltro )

   IF FPRINTER ()
      FMENS( 'Aguarde... Emitindo Relatorio...' )
      SET DEVICE TO PRINT

      //SET ( _SET_MARGIN    , 10 )

      @ 0,0 SAY pRESET + pCOMPR

      .oRelat:groupExp := Nil
      WHILE ! .oRelat:stabilize()
      END

      .oRelat:lineCounter += 4
      @ .oRelat:lineCounter++, 10 SAY 'Detalhes do Saldo:'
      @ .oRelat:lineCounter  , 10 SAY "Dinheiro...........:" 
      @ .oRelat:lineCounter++, 33 SAY DETALHE->DINHEIRO PICT '@E 9,999,999.99'
      @ .oRelat:lineCounter  , 10 SAY "Cheques............:" 
      @ .oRelat:lineCounter++, 33 SAY DETALHE->CHEQUES PICT '@E 9,999,999.99'
      @ .oRelat:lineCounter  , 10 SAY DETALHE->DESC1   PICT '@!'
      @ .oRelat:lineCounter++, 33 SAY DETALHE->VALO1   PICT '@E 9,999,999.99'
      @ .oRelat:lineCounter  , 10 SAY DETALHE->DESC2   PICT '@!'
      @ .oRelat:lineCounter++, 33 SAY DETALHE->VALO2   PICT '@E 9,999,999.99'
      @ .oRelat:lineCounter  , 10 SAY DETALHE->DESC3   PICT '@!'
      @ .oRelat:lineCounter++, 33 SAY DETALHE->VALO3   PICT '@E 9,999,999.99'

      .oRelat:lineCounter += 3
      @ .oRelat:lineCounter++, 30 SAY '________________________                 __________________________'
      @ .oRelat:lineCounter++, 30 SAY 'CAIXA                                    VISTO'
      
      SET ( _SET_MARGIN    , 0 )
      
      EJECT

      SET PRINTER TO
      SET DEVICE TO SCREEN
      FMENS('')
   END

   ATENCAO( 'Emitido!' )

END

SET RELATION TO
Fmens('')

SETCOLOR( cCor )
SETCURSOR( nCurs )
RESTSCREEN( 4, 1, MAXROW()-3, MAXCOL()-1, cTela )

RETURN
