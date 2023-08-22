/***************

PROGRAMA: REPPAG.prg

FUN€AO: RELACAO DE CTAS PAGAR

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'
#include 'COMBO.CH'
#include 'REPCLASS.CH'

#DEFINE  COLUNAS  62

********************
PROCEDURE RepPAGAR()
********************
LOCAL cCor, cTela, nCurs, ;
      oRelat, oCol0, oCol1, oCol2,;
      cOnde, cPrinter, nMes, nAno, cAnoMes, bFiltro,;
      pRESET, pCOMPR, pDESCO, pDOUBL, pENFAT, pDESEN, ;
      GETLIST := {}

cCor  := SetColor( M->cCor2 )
nCurs := SetCursor( SC_NORMAL )
cTela := TELAReport( ' RELA€AO DE CONTAS A PAGAR ' )

cOnde := cPrinter := ' '

SELE FUNCIONA
SET ORDER TO 1

SELE FATURAS
SET RELATION TO SubStr( FATURAS->NUMERO, 7 ) INTO FUNCIONA
FATURAS->(dbGoTop())

WHILE .T.

   nMes := nAno := 0

   @ 11,10 SAY 'Mes de Referencia:' GET nMes PICT '99'
   @ 11,40 SAY 'Ano:' GET nAno PICT '99'

   @ 17,10 SAY "Impressora ou Tela:" GET cOnde PICT "!" ;
           COMBO { 'Impressora','Tela' } ;
           VALID cOnde$'TI'

   @ 19,10 SAY "Impressora:" GET cPrinter ;
           COMBO A_PRINT ;
           VALID cPrinter$"123" ;
           WHEN cOnde == "I"

   READ

   IF LASTKEY() == K_ESC ; EXIT ; END

   IF nAno < SET( _SET_EPOCH )-1900
      nAno += 2000
   ELSE
      nAno += 1900
   END

   cAnoMes := Str( nAno, 4, 0 ) + StrZero( nMes, 2, 0 )
   
   PRINTER->( dbGoto( Val( cPrinter ) ) )
   pRESET := PR_COMM( AllTrim( PRINTER->RESET ) )
   pCOMPR := PR_COMM( AllTrim( PRINTER->COMPR ) )
   pDESCO := PR_COMM( AllTrim( PRINTER->DESCO ) )
   pDOUBL := PR_COMM( AllTrim( PRINTER->DOUBL ) )
   pENFAT := PR_COMM( AllTrim( PRINTER->ENFAT ) )
   pDESEN := PR_COMM( AllTrim( PRINTER->DESEN ) )

   oRelat := ReportNew( 56 )

   IF cOnde == "I"
      .oRelat:header := { || { pDOUBL+M->cNomeC,;
                            PADR(M->cNomeA,COLUNAS),;
                            pDOUBL+pENFAT+PADC('RELACAO DE CONTAS A PAGAR',COLUNAS/2)+pDESEN,'',;
                            PADR('Data: ' + DTOC( DATE() ),COLUNAS/2 ) +;
                            PADL('Pagina: '+STR( .oRelat:pageCounter, 4, 0 ),COLUNAS/2 ) } }

   ELSE
      .oRelat:header := { || { M->cNomeC,;
                            PADR(M->cNomeA,COLUNAS),;
                            PADC('RELACAO DE CONTAS A PAGAR',COLUNAS),'',;
                            PADR('Data: ' + DTOC( DATE() ) + ;
                            "     Mes / Ano Referencia: " + ;
                            Str( nAno, 4, 0 ) + " / " + StrZero( nMes, 2, 0 ),COLUNAS/2 ) +;
                            PADL('Pagina: '+STR( .oRelat:pageCounter, 4, 0 ),COLUNAS/2 ) } }

   END

   bFiltro := { || SubStr( FATURAS->NUMERO, 1, 6 ) == cAnoMes }
   
   RepSkipperF ( 0 )
   GoTop ( bFiltro )

   .oRelat:skipBlock := {| nRecords | RepSkipF( nRecords, bFiltro ) }

   oCol0 := TBColumnNew ( 'Fatura     ' ,{ || Transform(FATURAS->NUMERO,'@R 9999.99.999') } )
   oCol0:picture := '@!'

   oCol1 := TBColumnNew ( PadR('Funcionario', 35 ) ,{ || FUNCIONA->NOME } )
   oCol1:picture := '@!'

   oCol2 := TBColumnNew ( PadL('Valor', 12),{ || FATURAS->VALOR } )
   oCol2:picture := '@E 9,999,999.99'
   oCol2:cargo   := { || FATURAS->VALOR }
   
   // Adiciona colunas ao TBrowser
   .oRelat:addColumn ( oCol0 )
   .oRelat:addColumn ( oCol1 )
   .oRelat:addColumn ( oCol2 )

   IF cOnde == "T" .OR. FPRINTER ()
      FMENS( 'Aguarde... Emitindo Relatorio...' )
      SET DEVICE TO PRINT

      IF     cOnde == "T"
             SET ( 24, "$REL." + M->cTerm, FALSE )

      ELSE
             @ PRow(),PCol() SAY pRESET

      END

      WHILE ! .oRelat:stabilize()
      END

      IF cOnde == "I" ; EJECT ; END

      SET PRINTER TO
      SET DEVICE TO SCREEN

      FMENS('')

      IF cOnde == "T"
         REPTELA( "$REL." + M->cTerm )
         FErase( "$REL." + M->cTerm )

      ELSE
         ATENCAO( 'Emitido!' )

      END

      FMENS('')
   END


END

SELE FATURAS
SET RELATION TO
SET ORDER TO 1
Fmens('')

SETCOLOR( cCor )
SETCURSOR( nCurs )
RESTSCREEN( 4, 1, MAXROW()-3, MAXCOL()-1, cTela )

RETURN
