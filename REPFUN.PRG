/***************

PROGRAMA: REPFUN.prg

FUN€AO: RELACAO DE FUNCIONARIOS

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'
#include 'COMBO.CH'
#include 'REPCLASS.CH'

#DEFINE  COLUNAS  102

*********************
PROCEDURE RepFUNCIO()
*********************
LOCAL cCor, cTela, nCurs, ;
      oRelat, oCol0, oCol1, oCol2, oCol3, oCol4, oCol5, oCol6,;
      cOnde, cPrinter, bFiltro,;
      pRESET, pCOMPR, pDESCO, pDOUBL, pENFAT, pDESEN, ;
      GETLIST := {}

cCor  := SetColor( M->cCor2 )
nCurs := SetCursor( SC_NORMAL )
cTela := TELAReport( ' RELA€AO DE FUNCIONARIOS ' )

cOnde := cPrinter := ' '

SELE FUNCIONA
SET ORDER TO 2
FUNCIONA->(dbGoTop())

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
                            pDOUBL+pENFAT+PADC('RELACAO DE FUNCIONARIOS',COLUNAS/2)+pDESEN,'',;
                            PADR('Data: ' + DTOC( DATE() ),COLUNAS/2 ) +;
                            PADL('Pagina: '+STR( .oRelat:pageCounter, 4, 0 ),COLUNAS/2 ) } }

   ELSE
      .oRelat:header := { || { M->cNomeC,;
                            PADR(M->cNomeA,COLUNAS),;
                            PADC('RELACAO DE FUNCIONARIOS',COLUNAS),'',;
                            PADR('Data: ' + DTOC( DATE() ),COLUNAS/2 ) +;
                            PADL('Pagina: '+STR( .oRelat:pageCounter, 4, 0 ),COLUNAS/2 ) } }

   END

   bFiltro := { || !Empty(FUNCIONA->RECISAO) }
   
   RepSkipperF ( 0 )
   GoTop ( bFiltro )

   .oRelat:skipBlock := {| nRecords | RepSkipF( nRecords, bFiltro ) }

   .oRelat:rodape   := {'','',''}

   .oRelat:groupExp := { || FUNCIONA->NOME+pDESEN }
   .oRelat:groupHeader := pENFAT + 'Funcionario: '

   oCol0 := TBColumnNew ( 'Codigo' ,{ || " "+FUNCIONA->CODIGO+"  " } )
   oCol0:picture := '@!'

   oCol1 := TBColumnNew ( PadR('Apelido', 15 ) ,{ || FUNCIONA->APELIDO } )
   oCol1:picture := '@!'

   oCol2 := TBColumnNew ( PadR('Atividade', 30 ) ,;
            { || FUNCIONA->ATIVIDADE } )
   oCol2:picture := '@!'

   oCol3 := TBColumnNew ( PadL('Salario', 12),{ || FUNCIONA->SALARIO } )
   oCol3:picture := '@E 9,999,999.99'

   oCol4 := TBColumnNew ( PadL('Saldo', 12),{ || FUNCIONA->SALDO } )
   oCol4:picture := '@E 9,999,999.99'

   oCol5 := TBColumnNew ( 'Contracao ',{ || FUNCIONA->CONTRATO } )
   oCol5:picture := ''

   oCol6 := TBColumnNew ( 'Recisao   ',{ || FUNCIONA->RECISAO } )
   oCol6:picture := ''

   // Adiciona colunas ao TBrowser
   .oRelat:addColumn ( oCol0 )
   .oRelat:addColumn ( oCol1 )
   .oRelat:addColumn ( oCol2 )
   .oRelat:addColumn ( oCol3 )
   .oRelat:addColumn ( oCol4 )
   .oRelat:addColumn ( oCol5 )
//   .oRelat:addColumn ( oCol6 )

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

SELE FUNCIONA
SET RELATION TO
SET ORDER TO 1
Fmens('')

SETCOLOR( cCor )
SETCURSOR( nCurs )
RESTSCREEN( 4, 1, MAXROW()-3, MAXCOL()-1, cTela )

RETURN

/*
*************************
FUNCTION VERIFICA( nCod, nL, nC )
*************************
LOCAL lRet := FALSE
IF nCod == 0 
   @ nL, nC SAY PadR( 'TODOS', 35 ) 
   lRet := TRUE
END
RETURN lRet

*************************
FUNCTION PR_COMM( cComm )
*************************
LOCAL cRet := '', nI
FOR nI := 1 TO Len( cComm ) STEP 2
    cRet += Chr( Hexa10( SubStr( cComm, nI, 2 ) ) )
NEXT
RETURN cRet

********************
FUNCTION Hexa10( X )
********************    
LOCAL A := SubStr( X, 1, 1 ), B := SubStr( X, 2, 1 )

IF     A == "A" ; A := 10
ELSEIF A == "B" ; A := 11
ELSEIF A == "C" ; A := 12
ELSEIF A == "D" ; A := 13
ELSEIF A == "E" ; A := 14
ELSEIF A == "F" ; A := 15
ELSE ; A := Val( A )
END

IF     B == "A" ; B := 10
ELSEIF B == "B" ; B := 11
ELSEIF B == "C" ; B := 12
ELSEIF B == "D" ; B := 13
ELSEIF B == "E" ; B := 14
ELSEIF B == "F" ; B := 15
ELSE ; B := Val( B )
END

RETURN ( A*16+B )
*/
