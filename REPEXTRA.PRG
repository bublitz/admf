/***************

PROGRAMA: REPEXTRA.prg

FUN€AO: RELATORIO DE EXTRATO DE BANCOS

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'
#include 'RepClass.CH'
#include 'COMBO.CH'

#DEFINE  COLUNAS  84

*************************
PROCEDURE ReportEXTRATO()
*************************
LOCAL cCor, cTela, nCurs, dData1, dData2, cBanco, dData, cOnde,;
      oRelat, oCol0, oCol1, oCol2, oCol3, oCol4, oCol5,;
      pRESET, pCOMPR, pDESCO, pDOUBL, pENFAT, pDESEN, cPrinter := ' ',;
      bFiltro, nTotal, cNome,;
      GETLIST := {}

SELE LANCTOS
SET ORDER TO 2

cCor := SETCOLOR( SETCORES(2) )
nCurs := SETCURSOR( SC_NORMAL )
cTela := TELAReport( 'EXTRATO BANCARIO' )

dData1 := dData2 := DATE()
cBanco := '    '
cOnde  := ' ' 

WHILE .T.
   
   @  8, 10 SAY 'Banco: ' GET cBanco PICT '@K 9999' VALID fPESQBANCO( @cBanco, 8, 24)
   @ 10, 10 SAY 'Data Inicial: ' GET dData1
   @ 12, 10 SAY 'Data Final  : ' GET dData2 VALID dData2 >= dData1
   @ 14, 10 SAY "Impressora ou Tela:" GET cOnde PICT "!" ;
            COMBO { 'Impressora','Tela' } ;
            VALID cOnde$'TI'

   @ 16,10 SAY "Impressora:" GET cPrinter ;
           COMBO A_PRINT ;
           VALID cPrinter$"1234" ;
           WHEN cOnde == "I"

   READ
   
   IF LASTKEY() == K_ESC ; EXIT ; END
   
   PRINTER->( dbGoto( Val( cPrinter ) ) )
   pRESET := PR_COMM( AllTrim( PRINTER->RESET ) )
   pCOMPR := PR_COMM( AllTrim( PRINTER->COMPR ) )
   pDESCO := PR_COMM( AllTrim( PRINTER->DESCO ) )
   pDOUBL := PR_COMM( AllTrim( PRINTER->DOUBL ) )
   pENFAT := PR_COMM( AllTrim( PRINTER->ENFAT ) )
   pDESEN := PR_COMM( AllTrim( PRINTER->DESEN ) )

   cNome := BANCOS->NOME
   
   SELE LANCTOS
   oRelat := ReportNew( 56 )

   IF cOnde == "I"
      .oRelat:header := { || { pDOUBL+M->cNomeC,;
                            PADR(M->cNomeA,COLUNAS),;
                            PADC(pENFAT+'EXTRATO BANCARIO'+pDESEN,COLUNAS),'',;
                            'Banco : '+cBanco+'  '+cNome, ;
                            PADR('Data: ' + DTOC( DATE() )+'     Hora: '+TIME(),COLUNAS/2 ) +; 
                            PADL('Pagina: '+STR( .oRelat:pageCounter, 4, 0 ),COLUNAS/2 ) } }

   ELSE
      .oRelat:header := { || { M->cNomeC,;
                            PADR(M->cNomeA,COLUNAS),;
                            PADC('EXTRATO BANCARIO',COLUNAS),'',;
                            'Banco : '+cBanco+'  '+cNome, ; 
                            PADR('Data: ' + DTOC( DATE() )+'     Hora: '+TIME(),COLUNAS/2 ) +; 
                            PADL('Pagina: '+STR( .oRelat:pageCounter, 4, 0 ),COLUNAS/2 ) } }
   END
   .oRelat:rodape := {'Total do Extrato','',''}
   
   bFiltro := { || LANCTOS->DATA >= dData1 .AND. LANCTOS->DATA <= dData2  .AND. LANCTOS->BANCO == cBanco }
   .oRelat:skipBlock := {| nRecords | RepSkipF( nRecords, bFiltro ) }

   oCol0 := TBColumnNew ( PADR('Data', 10 ) ,{ || LANCTOS->DATA } )

   oCol1 := TBColumnNew ( PADR('Historico', 35 ) ,{ || LANCTOS->HISTORICO } )
   oCol1:picture := '@!'

   oCol2 := TBColumnNew ( PADR('Cheque N.',10),{ || LANCTOS->NUMCHEQUE } )
   oCol2:picture := '@!'

   oCol3 := TBColumnNew ( 'Banco',{ || LANCTOS->NUMBANCO } )
   oCol3:picture := '@!'

   oCol4 := TBColumnNew ( PADL('Valor',18), { || LANCTOS->VALOR } )
   oCol4:picture := '@)E 999,999,999,999.99'
   
   oCol5 := TBColumnNew( ' ', { || IF(LANCTOS->TIPO$'CV',' ','-' ) } )
   oCol5:colSep := ''

   // Adiciona colunas ao TBrowser
   .oRelat:addColumn ( oCol0 )
   .oRelat:addColumn ( oCol1 )
   .oRelat:addColumn ( oCol2 )
   .oRelat:addColumn ( oCol3 )
   .oRelat:addColumn ( oCol4 )
   .oRelat:addColumn ( oCol5 )

   RepSkipperF ( 0 )
   GoTop ( bFiltro )
   IF EOF()
      ALERT( 'NAO HA DADOS!' )
   END

   IF cOnde == "T" .OR. FPRINTER ()
      nTotal := 0
      FMENS( 'Aguarde... Emitindo Relat¢rio...' )
            
      SET DEVICE TO PRINT

      IF cOnde == "T"
         Set( 24, '$REL.' + M->cTerm, FALSE )

      ELSE
         Imprime( pRESET + pCOMPR )

      END

      .oRelat:cabecalho()

      SELE SALDOS
      SEEK cBanco + DTOS( LANCTOS->DATA )
      IF FOUND()
         dData := SALDOS->DATA
         SALDOS->(dbSkip( -1 ))
         IF SALDOS->BANCO == cBanco .AND. SALDOS->DATA != dData
            .oRelat:lineCounter++
            @ ++.oRelat:lineCounter, 47 SAY 'SALDO ANTERIOR ('+ DTOC( SALDOS->DATA ) +')'
            nTotal += SALDOS->DISPONIVEL
            @ ++.oRelat:lineCounter, 47 SAY 'Disp + Vinc...... '
            nTotal += SALDOS->VINCULADO
            @ .oRelat:lineCounter++  , PCOL() SAY nTotal PICT '@)E 999,999,999,999.99'
         END
      END

      SELE LANCTOS
      nTotal += IF(LANCTOS->TIPO$'CV',LANCTOS->VALOR,-LANCTOS->VALOR )
      WHILE ! .oRelat:stabilize()
         nTotal += IF(LANCTOS->TIPO$'CV',LANCTOS->VALOR,-LANCTOS->VALOR )
      END
     
      @ PROW()+2, 47 SAY 'Total............ '
      @ PROW()  , PCOL() SAY nTotal PICT '@)E 999,999,999,999.99'

      GoBottom( bFiltro )
      SELE SALDOS
      SEEK cBanco + DTOS( LANCTOS->DATA )
      IF FOUND()
         @ PROW()+2, 47 SAY 'SALDO EM '+ DTOC( LANCTOS->DATA )
         @ PROW()+1, 47 SAY 'Disponivel....... '
         @ PROW()  , PCOL() SAY SALDOS->DISPONIVEL PICT '@)E 999,999,999,999.99'
         @ PROW()+1, 47 SAY 'Vinculado........ '
         @ PROW()  , PCOL() SAY SALDOS->VINCULADO  PICT '@)E 999,999,999,999.99'
         @ PROW()+1, 47 SAY 'Total............ '
         @ PROW()  , PCOL() SAY SALDOS->VINCULADO+SALDOS->DISPONIVEL  PICT '@)E 999,999,999,999.99'
      END
/*
      SELE BANCOS
      SEEK cBanco
      @ PROW()+2, 47 SAY 'SALDO ATUAL '+ DTOC( DATE() )
      @ PROW()+1, 47 SAY 'Disponivel....... '
      @ PROW()  , PCOL() SAY BANCOS->SALDODISP PICT '@)E 999,999,999,999.99'
      @ PROW()+1, 47 SAY 'Vinculado........ '
      @ PROW()  , PCOL() SAY BANCOS->SALDOVINC  PICT '@)E 999,999,999,999.99'
      @ PROW()+1, 47 SAY 'Total............ '
      @ PROW()  , PCOL() SAY BANCOS->SALDOVINC+BANCOS->SALDODISP  PICT '@)E 999,999,999,999.99'
*/
      EJECT

      SET PRINTER TO
      SET DEVICE TO SCREEN

      IF cOnde == "T"
         REPTELA( '$REL.' + M->cTerm )
         FErase( '$REL.' + M->cTerm )
      ELSE
         ATENCAO( 'Emitido!' )
      END
   END

END

SELE LANCTOS
SET RELATION TO
SET ORDER TO 1
Fmens('')

SETCOLOR( cCor )
SETCURSOR( nCurs )
RESTSCREEN( 4, 1, MAXROW()-3, MAXCOL()-1, cTela )

RETURN



