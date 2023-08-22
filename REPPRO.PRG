/***************

PROGRAMA: REPFUN.prg

FUN€AO: RELACAO DE PROVENTOS E DESCONTOS

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'
#include 'COMBO.CH'
#include 'REPCLASS.CH'

#DEFINE  COLUNAS  52

*********************
PROCEDURE RepPRODES()
*********************
LOCAL cCor, cTela, nCurs, ;
      oRelat, oCol1, oCol2, oCol3,;
      cOnde, cPrinter,;
      pRESET, pCOMPR, pDESCO, pDOUBL, pENFAT, pDESEN, ;
      GETLIST := {}

cCor  := SetColor( M->cCor2 )
nCurs := SetCursor( SC_NORMAL )
cTela := TELAReport( ' RELA€AO DE PROVENTOS E DESCONTOS ' )

cOnde := cPrinter := ' '

SELE PRODES
PRODES->(dbGoTop())

WHILE .T.

   @ 17,10 SAY "Impressora ou Tela:" GET cOnde PICT "!" ;
           COMBO { 'Impressora','Tela' } ;
           VALID cOnde$'TI'

   @ 19,10 SAY "Impressora:" GET cPrinter ;
           COMBO A_PRINT ;
           VALID cPrinter$"123" ;
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

   oRelat := ReportNew( 56 )

   IF cOnde == "I"
      .oRelat:header := { || { pDOUBL+M->cNomeC,;
                            PADR(M->cNomeA,COLUNAS),;
                            pDOUBL+pENFAT+PADC('PROVENTOS E DESCONTOS',COLUNAS/2)+pDESEN,'',;
                            PADR('Data: ' + DTOC( DATE() ),COLUNAS/2 ) +;
                            PADL('Pagina: '+STR( .oRelat:pageCounter, 4, 0 ),COLUNAS/2 ) } }

   ELSE
      .oRelat:header := { || { M->cNomeC,;
                            PADR(M->cNomeA,COLUNAS),;
                            PADC('PROVENTOS E DESCONTOS',COLUNAS),'',;
                            PADR('Data: ' + DTOC( DATE() ),COLUNAS/2 ) +;
                            PADL('Pagina: '+STR( .oRelat:pageCounter, 4, 0 ),COLUNAS/2 ) } }

   END

   oCol1 := TBColumnNew ( 'Codigo' ,{ || " "+PRODES->CODIGO+"  " } )
   oCol1:picture := '@!'

   oCol2 := TBColumnNew ( PadR('Descricao', 35 ) ,{ || PRODES->DESCRICAO } )
   oCol2:picture := '@!'

   oCol3 := TBColumnNew ( PadR('Tipo', 8 ), { || FTIPO(PRODES->TIPO) } )
   oCol3:picture := '@!'

   // Adiciona colunas ao TBrowser
   .oRelat:addColumn ( oCol1 )
   .oRelat:addColumn ( oCol2 )
   .oRelat:addColumn ( oCol3 )

   IF cOnde == "T" .OR. FPRINTER ()
      FMENS( 'Aguarde... Emitindo Relatorio...' )
      SET DEVICE TO PRINT

      IF     cOnde == "T"
             SET ( 24, "$REL." + M->cTerm, FALSE )

      ELSE
             @ PRow(),PCol() SAY pRESET + pCOMPR

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

SELE PRODES
SET RELATION TO
SET ORDER TO 1
Fmens('')

SETCOLOR( cCor )
SETCURSOR( nCurs )
RESTSCREEN( 4, 1, MAXROW()-3, MAXCOL()-1, cTela )

RETURN



FUNCTION FTIPO( X )
LOCAL RET
IF     X == "P" ; RET := "PROVENTO"
ELSEIF X == "D" ; RET := "DESCONTO"
ELSE            ; RET := "        "
END
RETURN RET
