/***************

PROGRAMA: REPPAGAR.prg

FUN€AO: RELATORIO DE CONTAS A PAGAR

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'
#include 'ComBo.ch'
#include 'RepClass.CH'

#DEFINE  COLUNAS  154

***********************
PROCEDURE ReportPAGAR()
***********************
LOCAL cCor, cTela, nCurs, nII,;
      oRelat, oCol1, oCol1A, oCol2, oCol3, oCol4, oCol5, oCol6, oCol7, oCol8, oCol9,;
      bFiltro, cFiltro, nCodFor, nCodCen, nCodGru, cOnde := ' ', cPrinter, cQuebra,;
      pRESET, pCOMPR, pDESCO, pDOUBL, pENFAT, pDESEN, cData,;
      cNomFor, cNomGru, cNomCen,;
      GETLIST := {}

MEMVAR dData1, dData2, cCodFor, cCodCen, cCodGru, cSitua, cCond, cQual

SELE PAGAR
SET RELATION TO PAGAR->CODFOR INTO FORNEC ,;
             TO PAGAR->CODGRU INTO GRUPOS

cCor  := SetColor( SETCORES(2) )
nCurs := SetCursor( SC_NORMAL )
cTela := TELAReport( ' RELA€AO DE CONTAS A PAGAR ' )

nCodFor := nCodCen := nCodGru := 0
dData1  := dData2 := CTOD('')
cCond   := '  '
cSitua  := cQual := cPrinter := ' '
cQuebra := 'N'

WHILE .T.

   @ 7, 10 SAY 'Fornecedor:' ;
           GET nCodFor PICT '99999999' ;
           WHEN FMENS( 'Digite o C¢digo do Fornecedor. F7=Fornecedores.' ) ;
           VALID PESQFOR( nCodFor, 7, 32 ) .OR. VERIFICA( nCodFor, 7, 32 )

   @  9,10 SAY '          Grupo:' ;
           GET nCodGru PICT "999" ;
           WHEN FMENS( 'Digite o C¢digo do Grupo. F10=Grupos' ) ;
           VALID PESQGRU( nCodGru, 9, 32 ) .OR. VERIFICA( nCodGru, 9, 32 )

   @ 12,10 SAY 'Data Inicial:' ;
           GET dData1 ;
           WHEN FMENS( '' )

   @ 12,40 SAY 'Data Final:' ;
           GET dData2 ;
           WHEN FMENS( '' )

   @ 14,10 SAY 'Situa‡ao:'
   @ 14,20 GET cCond PICT "@!" COMBO {"== Igual","<> Diferente","   Nada"} ;
           VALID cCond == "==" .OR. cCond == "<>" .OR. cCond == "  "

   @ 14,23 GET cSitua PICT "!" COMBO A_SITUA WHEN cCond <> "  "

/*
   @ 14,30 SAY 'Quebra por Centro de Custo (S/N):' GET cQuebra PICT '!';
           VALID cQuebra$'SN'.OR. (LastKey() == K_UP);
*/

   @ 16,10 SAY 'Emite Contas Pagas, Nao pagas ou Todas: ' ;
           GET cQual PICT "!" COMBO { "Pagas","Nao Pagas","Todas" } ;
           VALID cQual$"PNT".OR. (LastKey() == K_UP)

   @ 18,10 SAY "Impressora ou Tela:" GET cOnde PICT "!" ;
           COMBO { 'Impressora','Tela' } ;
           VALID cOnde$'TI'.OR. (LastKey() == K_UP)

   @ 20,10 SAY "Impressora:" GET cPrinter ;
           COMBO A_PRINT ;
           VALID cPrinter$"1234".OR. (LastKey() == K_UP);
           WHEN cOnde == "I"

   READ

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
   
   cNomFor := cNomGru := cNomCen := PadR( 'TODOS', 40 )
   
   IF nCodFor != 0
      cNomFor := FORNEC->NOME
   END
   
   IF nCodGru != 0
      cNomGru := GRUPOS->NOME
   END
   
   oRelat := ReportNew( 56 )

   .oRelat:header := { || { pDOUBL+M->cNomeC,;
                            PADR(M->cNomeA,COLUNAS),;
                            pDOUBL+pENFAT+PADC('RELACAO DE CONTAS A PAGAR',COLUNAS/2)+pDESEN,'',;
                            'Periodo de: ' + dtoc( dData1 ) + ' a ' + dtoc( dData2 ) +;
                            '        Emitindo Contas: ' + IF(cQual=="N","NAO PAGAS",IF(cQUAL=="P","PAGAS","TODAS")),'',;
                            'Fornecedor: '+ '  ' + cNomFor,;
                            '        Grupo: ' + '  ' + cNomGru,'',;
                            PADR('Data: ' + DTOC( DATE() ),COLUNAS/2 ) +;
                            PADL('Pagina: '+STR( .oRelat:pageCounter, 4, 0 ),COLUNAS/2-2 ) } }


// .oRelat:rodape := {'','',''}

   cFiltro := ''
   IF cCond != "  "
      cFiltro := "PAGAR->SITUACAO " + cCond + " cSitua"
   END

   IF nCodFor != 0
      IF !Empty( cFiltro ) ; cFiltro += " .AND. " ; END
      cFiltro += "PAGAR->CODFOR == cCodFor"
   END

   IF nCodGru != 0
      IF !Empty( cFiltro ) ; cFiltro += " .AND. " ; END
      cFiltro += "PAGAR->CODGRU == cCodGru"
   END

   cData := IF( cQual == "P", "PAGAR->DTPAGTO","PAGAR->VENCTO")
   
   IF !Empty( dData1 )
      IF !Empty( cFiltro ) ; cFiltro += " .AND. " ; END
      cFiltro += cData + " >= dData1"
   END

   IF !Empty( dData2 )
      IF !Empty( cFiltro ) ; cFiltro += " .AND. " ; END
      cFiltro += cData + " <= dData2"
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
      cCodGru := StrZero( nCodGru, 3, 0 )

      cFiltro := "{ || " + cFiltro + " }"
      bFiltro := &cFiltro.  // ARGH !!!

      .oRelat:skipBlock := {| nRecords | RepSkipF( nRecords, bFiltro ) }

   END

   IF cQual == "P"
      .oRelat:groupExp := { || pDOUBL + DTOC(PAGAR->DTPAGTO) + pDESEN }
      .oRelat:groupHeader := pENFAT + 'Pagamento: '
      SET ORDER TO 3

   ELSE
      .oRelat:groupExp := { || pDOUBL + DTOC(PAGAR->VENCTO) + pDESEN }
      .oRelat:groupHeader := pENFAT + 'Vencimento: '
      SET ORDER TO 2

   END

   IF cQuebra == "S"
      .oRelat:subExp := { || PAGAR->CODCEN + " - " + AllTrim(CCUSTO->NOME) + ;
                        ' / ' + PAGAR->CODGRU + " - " + pDOUBL + AllTrim(GRUPOS->NOME) }
      .oRelat:subHeader := 'Centro de Custo/Grupo: '

   END

   oCol1 := TBColumnNew ( PadR('Lancto', 6 ) ,;
            { || Right(PAGAR->NUMERO,6) } )
   oCol1:picture := '@!'
//   oCol1:colSep := '   '

   oCol1A := TBColumnNew ( 'C.Custo' ,;
                        { || PadR( PAGAR->CODCEN, 7 ) } )
   oCol1A:picture := '@!'
   oCol1A:colSep := '   '

   oCol2 := TBColumnNew ( PadR('Fornecedor', 40 ), { || FORNEC->NOME } )
   oCol2:picture := '@!'

   oCol3 := TBColumnNew ( PadL('Valor',18),{ || PAGAR->VALOR } )
   oCol3:picture := '@E 999,999,999,999.99'
   oCol3:cargo   := { || PAGAR->VALOR }
//   oCol3:colSep := ' | '

   oCol4 := TBColumnNew ( PadR('Historico',50),{ || PAGAR->DESCRICAO } )
   oCol4:picture := '@!'
   oCol4:colSep := '  '

   oCol5 := TBColumnNew ( PadL('Valor Pago',17),{ || PAGAR->VLPAGTO } )
   oCol5:picture := '@E 99,999,999,999.99'
   oCol5:cargo   := { || PAGAR->VLPAGTO }
//   oCol5:colSep := ' | '

   oCol6 := TBColumnNew ( '  %   ',{ || 100-(PAGAR->VLPAGTO*100/PAGAR->VALOR) } )
   oCol6:picture := '@E 999.99'
//   oCol6:colSep := ' | '

   oCol7 := TBColumnNew ( PadR('Documento', 15 ) ,{ || PAGAR->DOCUMENTO } )
   oCol7:picture := '@!'

/*
   oCol7 := TBColumnNew ( PadL('Atual',18) ,;
            { || VLFUTURO( PAGAR->VALOR, PAGAR->MULTA, PAGAR->TPMULTA,;
                 PAGAR->JUROS, PAGAR->TIPO, PAGAR->VENCTO ) } )
   oCol7:picture := '@E 999,999,999,999.99'
   oCol7:cargo   := { ||VLFUTURO( PAGAR->VALOR, PAGAR->MULTA, PAGAR->TPMULTA,;
                         PAGAR->JUROS, PAGAR->TIPO, PAGAR->VENCTO ) }
   oCol7:colSep := ' | '
*/

   oCol8 := TBColumnNew ( Space(5),{ || "_____" } )
   oCol8:picture := '@!'
//   oCol8:colSep := ' | '

   oCol9 := TBColumnNew ( 'Situacao',;
            { || SITUACAO( PAGAR->NUMERO ) } )
//            { || pDOUBL + SITUACAO( PAGAR->NUMERO ) } )
   oCol9:picture := '@!'
//   oCol9:colSep := ' | '

   // Adiciona colunas ao TBrowser
   .oRelat:addColumn ( oCol1  )          // lancamento
   //   .oRelat:addColumn ( oCol1A )          // centro de custo
   .oRelat:addColumn ( oCol2  )          // fornecedor
   .oRelat:addColumn ( oCol7 )           // documento
   .oRelat:addColumn ( oCol4  )          // historico

   IF cQual == "P"
      .oRelat:addColumn ( oCol5 )       // valor pago
//      .oRelat:addColumn ( oCol6 )     // %
      .oRelat:addColumn ( oCol9 )       // situacao

   ELSEIF cQual == "N"
      .oRelat:addColumn ( oCol3 )       // valor
      IF cOnde == "I" ; .oRelat:addColumn ( oCol8 ) ; END  // espaco para visto

   ELSEIF cQual == "T"
      .oRelat:addColumn ( oCol3 )       // valor
      .oRelat:addColumn ( oCol9 )       // situacao

   END

   PAGAR->(dbGoTop())
   
   IF !Empty( bFiltro )
      RepSkipperF ( 0 )
      GoTop ( bFiltro )
   END
   
   IF PAGAR->(Eof())
      Alert( 'Nao h  Dados!' )
      LOOP
   END

   IF cOnde == "T" .OR. FPRINTER ()
      FMENS( 'Aguarde... Emitindo Relatorio...' )
      nII := 0
      SET DEVICE TO PRINT

      IF     cOnde == "T"
             SET ( 24, "$REL." + M->cTerm, FALSE )

      ELSE
             Imprime( pRESET + pCOMPR ) // Mais adiante

      END

      WHILE ! .oRelat:stabilize()
          TERMO( 23, 50, ++nII )
      END

      EJECT

      ACAO( 'EMITIU RELATORIO DE CONTAS A PAGAR' )
      
      SET PRINTER TO
      SET DEVICE TO SCREEN

      FMENS('')

      IF cOnde == "T"
         RepTela( "$REL." + M->cTerm )
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

***********************************
STATIC FUNCTION SITUACAO( cNumero )
***********************************
LOCAL cRet, nParc
IF     EMPTY(PAGAR->DTPAGTO)
       cRet := "NAO PAGA"

ELSE
       cRet := "PAGA"

END
RETURN PadR( cRet, 15 )

****************************
PROCEDURE Imprime( cCodigo )
****************************
   SET CONSOLE OFF
   SET PRINTER ON
   ?? cCodigo
   SET PRINTER OFF
   SET CONSOLE ON
RETURN

/*

  FIM - REPPAGAR.PRG
  
*/
