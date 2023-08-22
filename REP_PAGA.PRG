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

#DEFINE  COLUNAS  134

***********************
PROCEDURE ReportPAGAR()
***********************
LOCAL cCor, cTela, nCurs, nII,;
      oRelat, oCol1, oCol2, oCol3, oCol4, oCol5, oCol6, oCol7, oCol8, oCol9,;
      bFiltro, cFiltro, nCodFor, nCodCen, nCodGru, cOnde := ' ', cPrinter, cQuebra,;
      pRESET, pCOMPR, pDESCO, pDOUBL, pENFAT, pDESEN, cData,;
      GETLIST := {}

MEMVAR dData1, dData2, cCodFor, cCodCen, cCodGru, cSitua, cCond, cQual

SELE PAGAR
SET RELATION TO PAGAR->CODCEN INTO CCUSTO ,;
             TO PAGAR->CODFOR INTO FORNEC ,;
             TO PAGAR->CODGRU INTO GRUPOS

cCor  := SetColor( SETCORES(2) )
nCurs := SetCursor( SC_NORMAL )
cTela := TELAReport( ' RELA€AO DE CONTAS A PAGAR ' )

nCodFor := nCodCen := nCodGru := 0
dData1  := dData2 := CTOD('')
cCond   := '  '
cSitua  := cQual := cPrinter := ' '
cQuebra := 'S'

WHILE .T.

   @ 7, 10 SAY 'Fornecedor:' ;
           GET nCodFor PICT '99999999' ;
           WHEN FMENS( 'Digite o C¢digo do Fornecedor. F7=Fornecedores.' ) ;
           VALID PESQFOR( nCodFor, 7, 32 ) .OR. VERIFICA( nCodFor, 7, 32 )

   @ 9, 10 SAY 'Centro de Custo:' ;
           GET nCodCen PICT "999" ;
           WHEN FMENS( 'Digite o C¢digo do Centro de Custo. F6=Centro de Custos.' ) ;
           VALID PESQCEN( nCodCen, 9, 32 ) .OR. VERIFICA( nCodCen, 9, 32 )

   @ 10,10 SAY '          Grupo:' ;
           GET nCodGru PICT "999" ;
           WHEN FMENS( 'Digite o C¢digo do Grupo. F10=Grupos' ) ;
           VALID PESQGRU( nCodGru, 10, 32 ) .OR. VERIFICA( nCodGru, 10, 32 )

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

   @ 14,30 SAY 'Quebra por Centro de Custo (S/N):' GET cQuebra PICT '!';
           VALID cQuebra$'SN'.OR. (LastKey() == K_UP);

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
                            'Periodo de: ' + dtoc( dData1 ) + ' a ' + dtoc( dData2 ) +;
                            '        Emitindo Contas: ' + IF(cQual=="N","NAO PAGAS",IF(cQUAL=="P","PAGAS","TODAS")),;
                            PADR('Data: ' + DTOC( DATE() ),COLUNAS/2 ) +;
                            PADL('Pagina: '+STR( .oRelat:pageCounter, 4, 0 ),COLUNAS/2-2 ) } }

   ELSE
      .oRelat:header := { || { M->cNomeC,;
                            PADR(M->cNomeA,COLUNAS),;
                            PADC('RELACAO DE CONTAS A PAGAR',COLUNAS),'',;
                            'Periodo de: ' + dtoc( dData1 ) + ' a ' + dtoc( dData2 ),;
                            PADR('Data: ' + DTOC( DATE() ),COLUNAS/2 ) +;
                            PADL('Pagina: '+STR( .oRelat:pageCounter, 4, 0 ),COLUNAS/2 ) } }

   END

// .oRelat:rodape := {'','',''}

   cFiltro := ''
   IF cCond != "  "
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

   oCol1 := TBColumnNew ( PadR('Lancto', 6 ) ,{ || Right(PAGAR->NUMERO,6) } )
   oCol1:picture := '999999'
//   oCol1:colSep := ' ³ '

   oCol2 := TBColumnNew ( PadR('Fornecedor', 25 ) ,;
            { || PadR( FORNEC->NOME, 25 ) } )
   oCol2:picture := '@!'
//   oCol2:colSep := ' ³ '

   oCol3 := TBColumnNew ( PadL('Valor',18),{ || PAGAR->VALOR } )
   oCol3:picture := '@E 999,999,999,999.99'
   oCol3:cargo   := { || PAGAR->VALOR }
   oCol3:colSep := ' ³ '

   oCol4 := TBColumnNew ( PadR('Descricao/Historico',50),{ || PAGAR->DESCRICAO } )
   oCol4:picture := '@!'
   oCol4:colSep := ' ³ '

   oCol5 := TBColumnNew ( PadL('Valor Pago',18),{ || PAGAR->VLPAGTO } )
   oCol5:picture := '@E 999,999,999,999.99'
   oCol5:cargo   := { || PAGAR->VLPAGTO }
   oCol5:colSep := ' ³ '

   oCol6 := TBColumnNew ( '  %   ',{ || 100-(PAGAR->VLPAGTO*100/PAGAR->VALOR) } )
   oCol6:picture := '@E 999.99'
   oCol6:colSep := ' ³ '

   oCol7 := TBColumnNew ( PadL('Atual',18) ,;
            { || VLFUTURO( PAGAR->VALOR, PAGAR->MULTA, PAGAR->TPMULTA,;
                 PAGAR->JUROS, PAGAR->TIPO, PAGAR->VENCTO ) } )
   oCol7:picture := '@E 999,999,999,999.99'
   oCol7:cargo   := { ||VLFUTURO( PAGAR->VALOR, PAGAR->MULTA, PAGAR->TPMULTA,;
                         PAGAR->JUROS, PAGAR->TIPO, PAGAR->VENCTO ) }
   oCol7:colSep := ' ³ '

   oCol8 := TBColumnNew ( Space(10),{ || "__________" } )
   oCol8:picture := '@!'
//   oCol8:colSep := ' ³ '

   oCol9 := TBColumnNew ( 'Situacao       ',;
            { || pDOUBL + SITUACAO( PAGAR->NUMERO ) } )
   oCol9:picture := '@!'
//   oCol9:colSep := ' ³ '

   // Adiciona colunas ao TBrowser
   .oRelat:addColumn ( oCol1 )          // lancamento
   .oRelat:addColumn ( oCol2 )          // fornecedor
   .oRelat:addColumn ( oCol4 )          // historico
   IF cQual == "P"
      .oRelat:addColumn ( oCol5 )       // valor pago
//      .oRelat:addColumn ( oCol6 )     // %
      .oRelat:addColumn ( oCol9 )       // situacao

   ELSEIF cQual == "N"
      .oRelat:addColumn ( oCol3 )       // valor
      .oRelat:addColumn ( oCol7 )       // valor atual
      IF cOnde == "I" ; .oRelat:addColumn ( oCol8 ) ; END  // espace para visto

   ELSEIF cQual == "T"
      .oRelat:addColumn ( oCol3 )       // valor
      .oRelat:addColumn ( oCol9 )       // situacao

   END

   IF !Empty( bFiltro )
      RepSkipperF ( 0 )
      GoTop ( bFiltro )

   ELSE
      PAGAR->(dbGoTop())

   END

   IF cOnde == "T" .OR. FPRINTER ()
      FMENS( 'Aguarde... Emitindo Relatorio...' )
      nII := 0
      SET DEVICE TO PRINT

      IF     cOnde == "T"
             SET ( 24, "$REL." + M->cTerm, FALSE )

      ELSE
             @ PRow(),PCol() SAY pRESET + pCOMPR

      END

      WHILE ! .oRelat:stabilize()
          TERMO( 23, 50, ++nII )
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
       SELE PARPAGAR
       SEEK cNumero
       IF Found() // E' PARCIAL
          nParc := 0
          WHILE PARPAGAR->NUMERO == cNumero .AND. !EOF()
             IF Empty( PARPAGAR->DATA2 ) ; EXIT ; END
             nParc := Val( SubStr( PARPAGAR->PARCELA, 1, 2 ) )
             PARPAGAR->(dbSkip())
          END
          IF PARPAGAR->NUMERO == cNumero .AND. !EOF()
             // NAO PAGOU TODAS
             cRet := 'PAGAS ' + AllTrim( Str( nParc ) ) + ' / '+ ;
                     SubStr( PARPAGAR->PARCELA, 4 )
          ELSE
             cRet := 'PAGA TOTALMENTE'
          END
       ELSE
          cRet := "PAGA"
       END
       SELE PAGAR
END
RETURN PadR( cRet, 15 )
