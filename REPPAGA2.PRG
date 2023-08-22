/***************

PROGRAMA: REPPAGAR.prg

FUN€AO: RELATORIO DE CAIXA

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'
#include 'ComBo.ch'
#include 'RepClass.CH'

#DEFINE  COLUNAS  107

***********************
PROCEDURE ReportPAGAR()
***********************
LOCAL cCor, cTela, nCurs, ;
      oRelat, oCol1, oCol2, oCol3, oCol4, oCol5, oCol6, oCol7, ;
      bFiltro, cFiltro, nCodFor, nCodCen, cOnde := ' ', cPrinter, ;
      pRESET, pCOMPR, pDESCO, pDOUBL, pENFAT, pDESEN, ;
      GETLIST := {}

MEMVAR dData1, dData2,cCodFor, cCodCen, cSitua, cCond, cQual

SELE PAGAR
SET ORDER TO 2
SET RELATION TO PAGAR->CODCEN INTO CCUSTO ,;
             TO PAGAR->CODFOR INTO FORNEC ,;
             TO PAGAR->CODGRU INTO GRUPOS

GO TOP

cCor  := SetColor( SETCORES(2) )
nCurs := SetCursor( SC_NORMAL )
cTela := TELAReport( ' RELA€AO DE CONTAS A PAGAR ' )

nCodFor := nCodCen := 0
dData1  := dData2 := CTOD('')
cCond   := '  '
cSitua  := cQual := cPrinter := ' '

WHILE .T.

   @ 7, 10 SAY 'Fornecedor:' ;
           GET nCodFor PICT '99999999' ;
           WHEN FMENS( 'Digite o C¢digo do Fornecedor. F7=Fornecedores.' ) ;
           VALID PESQFOR( nCodFor, 7, 32 ) .OR. VERIFICA( nCodFor, 7, 32 )

   @ 9, 10 SAY 'Centro de Custo:' ;
           GET nCodCen PICT "999" ;
           WHEN FMENS( 'Digite o C¢digo do Centro de Custo.' ) ;
           VALID PESQCEN( nCodCen, 9, 32 ) .OR. VERIFICA( nCodCen, 9, 32 )

   @ 11,10 SAY 'Data Inicial:' ;
           GET dData1 ;
           WHEN FMENS( '' )

   @ 11,40 SAY 'Data Final:' ;
           GET dData2 ;
           WHEN FMENS( '' )

   @ 13,10 SAY 'Situa‡ao:'
   @ 13,20 GET cCond PICT "@!" COMBO {"== Igual","<> Diferente",".. Nada"} ;
           VALID cCond == "==" .OR. cCond == "<>" .OR. cCond == ".."

   @ 13,23 GET cSitua PICT "!" COMBO A_SITUA WHEN cCond <> ".."

   @ 15,10 SAY 'Emite Contas Pagas, Nao pagas ou Todas: ' ;
           GET cQual PICT "!" COMBO { "Pagas","Nao Pagas","Todas" } ;
           VALID cQual$"PNT"

   @ 17,10 SAY "Impressora ou Tela:" GET cOnde PICT "!" ;
           COMBO { 'Impressora','Tela' } ;
           VALID cOnde$'TI'

   @ 19,10 SAY "Impressora:" GET cPrinter ;
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
   
   oRelat := ReportNew( 56 )

   IF cOnde == "I"
      .oRelat:header := { || { pDOUBL+M->cNomeC,;
                            PADR(M->cNomeA,COLUNAS),;
                            PADC(+pENFAT+'RELACAO DE CONTAS A PAGAR'+pDESEN,COLUNAS),'',;
                            PADR('Data: ' + DTOC( DATE() ),COLUNAS/2 ) +; 
                            PADL('Pagina: '+STR( .oRelat:pageCounter, 4, 0 ),COLUNAS/2 ) } }

   ELSE
      .oRelat:header := { || { M->cNomeC,;
                            PADR(M->cNomeA,COLUNAS),;
                            PADC('RELACAO DE CONTAS A PAGAR',COLUNAS),'',;
                            PADR('Data: ' + DTOC( DATE() ),COLUNAS/2 ) +; 
                            PADL('Pagina: '+STR( .oRelat:pageCounter, 4, 0 ),COLUNAS/2 ) } }

   END

// .oRelat:rodape := {'','',''}
   
   cFiltro := ''
   IF cCond != ".."    
      cFiltro := "PAGAR->SITUACAO " + cCond + " cSitua"
   END

   IF nCodFor != 0     
      IF !Empty( cFiltro ) ; cFiltro += " .AND. " ; END
      cFiltro += "PAGAR->CODFOR == cCodFor" 
   END

   IF nCodCen != 0     
      IF !Empty( cFiltro ) ; cFiltro += " .AND. " ; END
      cFiltro += "PAGAR->CODCEN == cCodCen" 
   END

   IF !Empty( dData1 )
      IF !Empty( cFiltro ) ; cFiltro += " .AND. " ; END
      cFiltro += "PAGAR->VENCTO >= dData1" 
   END

   IF !Empty( dData2 )
      IF !Empty( cFiltro ) ; cFiltro += " .AND. " ; END
      cFiltro += "PAGAR->VENCTO <= dData2" 
   END

   IF     cQual == "N"
          IF !Empty( cFiltro ) ; cFiltro += " .AND. " ; END
          cFiltro += "Empty(PAGAR->DTPAGTO)" 

   ELSEIF cQual == "P"
          IF !Empty( cFiltro ) ; cFiltro += " .AND. " ; END
          cFiltro += "!Empty(PAGAR->DTPAGTO)" 

   END

   IF !Empty( cFiltro )
      cCodFor := StrZero( nCodFor, 8, 0 )
      cCodCen := StrZero( nCodCen, 3, 0 )
      
      cFiltro := "{ || " + cFiltro + " }"
      bFiltro := &cFiltro.

      .oRelat:skipBlock := {| nRecords | RepSkipF( nRecords, bFiltro ) }

   END
   
   .oRelat:groupExp := { || pDOUBL + PAGAR->CODCEN + " - " + CCUSTO->NOME }
   .oRelat:groupHeader := 'Centro de Custo: '

   .oRelat:subExp := { || pDOUBL + PAGAR->CODGRU + " - " + GRUPOS->NOME }
   .oRelat:subHeader := 'Grupo: '

   oCol1 := TBColumnNew ( PadR('N. Lancamento', 15 ) ,{ || PAGAR->NUMERO } )
   oCol1:picture := '999999999999999'

   oCol2 := TBColumnNew ( PadR('Fornecedor', 30 ) ,;
            { || PadR( PAGAR->CODFOR + ' - ' + FORNEC->NOME, 30 ) } )
   oCol2:picture := '@!'

   oCol3 := TBColumnNew ( PadR('Emissao',10),{ || PAGAR->EMISSAO } )
   oCol3:picture := '@!'

   oCol4 := TBColumnNew ( PadR('Vencto',10),{ || PAGAR->VENCTO } )
   oCol4:picture := '@!'

   oCol5 := TBColumnNew ( PadL('Valor',18),{ || PAGAR->VALOR } )
   oCol5:picture := '@E 999,999,999,999.99'
   oCol5:cargo   := { || PAGAR->VALOR }

   oCol6 := TBColumnNew ( PadR('Pagto',10),{ || PAGAR->DTPAGTO } )
   oCol6:picture := '@!'

   oCol7 := TBColumnNew ( PadL('Valor Pago',18),{ || PAGAR->VLPAGTO } )
   oCol7:picture := '@E 999,999,999,999.99'
   oCol7:cargo   := { || PAGAR->VLPAGTO }

   // Adiciona colunas ao TBrowser
   .oRelat:addColumn ( oCol1 )
   .oRelat:addColumn ( oCol2 )
//   .oRelat:addColumn ( oCol3 )
   .oRelat:addColumn ( oCol4 )
   .oRelat:addColumn ( oCol5 )
   IF cQual != "N"
      .oRelat:addColumn ( oCol6 )
      .oRelat:addColumn ( oCol7 )
   END

   IF !Empty( bFiltro )
      RepSkipperF ( 0 )
      GoTop ( bFiltro )

   ELSE
      PAGAR->(dbGoTop())

   END

   IF cOnde == "T" .OR. FPRINTER ()
      FMENS( 'Aguarde... Emitindo Relatorio...' )
      SET DEVICE TO PRINT

      IF     cOnde == "T"
             SET ( 24, "$REL." + M->cTerm, FALSE )

      ELSE
             @ 0,0 SAY pRESET + pCOMPR

      END

      WHILE ! .oRelat:stabilize()
      END

      IF cOnde == "I" ; EJECT ; END

      SET PRINTER TO
      SET DEVICE TO SCREEN

      IF cOnde == "T"
         REPTELA( "$REL." + M->cTerm )
         FErase( "$REL." + M->cTerm )

      ELSE
         ATENCAO( 'Emitido!' )

      END

      FMENS('')
   END


END

SELE PAGAR
SET RELATION TO
SET ORDER TO 1
Fmens('')

SETCOLOR( cCor )
SETCURSOR( nCurs )
RESTSCREEN( 4, 1, MAXROW()-3, MAXCOL()-1, cTela )

RETURN




******************************************
FUNCTION VERIFICA( nCod, nLinha, nColuna )
******************************************
LOCAL lRet := FALSE
IF nCod == 0 
   @ nLinha, nColuna SAY PadR( 'TODOS', 40 ) 
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
