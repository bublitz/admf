/***************

PROGRAMA: REPCAMEN.prg

FUN€AO: RELATORIO DE CAIXA MENSAL

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
PROCEDURE ReportCAMEN()
***********************
LOCAL cCor, cTela, nCurs,;
      oRelat, oCol1, oCol2, oCol3, oCol4, oCol0,;
      bFiltro, cPrinter, cOnde,;
      pRESET, pCOMPR, pDESCO, pDOUBL, pENFAT, pDESEN,;
      GETLIST := {}

MEMVAR dData1, dData2

SELE CAIXA
SET ORDER TO 1

cCor := SETCOLOR( SETCORES(2) )
nCurs := SETCURSOR( SC_NORMAL )
cTela := TELAReport( ' MOVIMENTO DE CAIXA ' )

dData1 := dData2 := CTOD('')
cPrinter := cOnde := ' '

WHILE .T.
   
   @ 8, 10 SAY 'Data Inicial: ' GET dData1 WHEN FMENS( 'Digite a data inicial para emitir o caixa.')

   @ 10, 10 SAY 'Data Final: ' GET dData2 WHEN FMENS( 'Digite a data final para emitir o caixa.')

   @ 18,10 SAY "Impressora ou Tela:" GET cOnde PICT "!" ;
           COMBO { 'Impressora','Tela' } ;
           VALID cOnde$'TI'.OR. (LastKey() == K_UP) ;
           WHEN FMENS('')

   @ 20,10 SAY "Impressora:" GET cPrinter ;
           COMBO A_PRINT ;
           VALID cPrinter$"1234" ;
           WHEN cOnde == 'I' .AND. FMENS( 'Escolha a Impressora.' )

   READ
   
   FMENS('')
   
   IF LASTKEY() == K_ESC ; EXIT ; END
   
   IF cOnde == 'I'
      PRINTER->( dbGoto( Val( cPrinter ) ) )
      pRESET := PR_COMM( AllTrim( PRINTER->RESET ) )
      pCOMPR := PR_COMM( AllTrim( PRINTER->COMPR ) )
      pDESCO := PR_COMM( AllTrim( PRINTER->DESCO ) )
      pDOUBL := PR_COMM( AllTrim( PRINTER->DOUBL ) )
      pENFAT := PR_COMM( AllTrim( PRINTER->ENFAT ) )
      pDESEN := PR_COMM( AllTrim( PRINTER->DESEN ) )

   ELSE
      pRESET := pCOMPR := pDESCO := pDOUBL := pENFAT := pDESEN := ''

   END

   oRelat := {}
   oRelat := ReportNew( 56 )

   .oRelat:header := { || { pDOUBL+M->cNomeC,;
                            PADR(M->cNomeA,COLUNAS),;
                            pDOUBL+pENFAT+PADC('MOVIMENTO DE CAIXA',COLUNAS/2)+pDESEN,'',;
                            PADR('Data Inicial: ' + DTOC( dData1 ) + '    Data Final: ' + DTOC( dData2 ), COLUNAS/2 ) + ;
                            PADL('Pagina: '+STR( .oRelat:pageCounter, 4, 0 ),COLUNAS/2 ) } }


// .oRelat:rodape := {'','',''}
   
   bFiltro := { || CAIXA->DATA >= dData1 .AND. CAIXA->DATA <= dData2 }
   .oRelat:skipBlock := {| nRecords | RepSkipF( nRecords, bFiltro ) }

   oCol0 := TBColumnNew ( PADR('Data', 10 ) ,{ || CAIXA->DATA } )
   oCol0:picture := '@!'

   oCol1 := TBColumnNew ( PADR('Historico', 50 ) ,{ || CAIXA->HISTORICO } )
   oCol1:picture := '@!'

   oCol2 := TBColumnNew ( PADL('Entrada',18),{ || CAIXA->ENTRADA } )
   oCol2:picture := '@ZE 999,999,999,999.99'
   oCol2:cargo := { || CAIXA->ENTRADA }

   oCol3 := TBColumnNew ( PADL('Saida',18),{ || CAIXA->SAIDA } )
   oCol3:picture := '@ZE 999,999,999,999.99'
   oCol3:cargo := { || CAIXA->SAIDA }

   oCol4 := TBColumnNew ( PADL('Saldo',20),{ || CAIXA->ENTRADA-CAIXA->SAIDA } )
   oCol4:picture := '@ZE 9 999 999 999 999.99'
   oCol4:cargo := { || CAIXA->ENTRADA-CAIXA->SAIDA }

   // Adiciona colunas ao TBrowser
   .oRelat:addColumn ( oCol1 )
   .oRelat:addColumn ( oCol2 )
   .oRelat:addColumn ( oCol3 )
   .oRelat:addColumn ( oCol4 )

   RepSkipperF ( 0 )
   GoTop ( bFiltro )

   IF cOnde == "T" .OR. FPRINTER ()
      FMENS( 'Aguarde... Emitindo Relatorio...' )
      SET DEVICE TO PRINT

      //SET ( _SET_MARGIN    , 10 )

      IF     cOnde == "T"
             SET ( 24, "$RELCM." + M->cTerm, FALSE )

      ELSE
             @ 0,0 SAY pRESET + pCOMPR

      END


      .oRelat:groupExp := Nil
      WHILE ! .oRelat:stabilize()
      END

      .oRelat:lineCounter += 3
      @ .oRelat:lineCounter++, 30 SAY '________________________                 __________________________'
      @ .oRelat:lineCounter++, 30 SAY 'CAIXA                                    VISTO'
      
      SET ( _SET_MARGIN    , 0 )
      
      EJECT

      SET PRINTER TO
      SET DEVICE TO SCREEN
      FMENS('')

      IF cOnde == "T"
         RepTela( "$RELCM." + M->cTerm )
         FErase( "$RELCM." + M->cTerm )

      ELSE
         ATENCAO( 'Emitido!' )

      END

   END

   ATENCAO( 'Emitido!' )

END

SET RELATION TO
Fmens('')

SETCOLOR( cCor )
SETCURSOR( nCurs )
RESTSCREEN( 4, 1, MAXROW()-3, MAXCOL()-1, cTela )

RETURN
