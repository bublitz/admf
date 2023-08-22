/***************

PROGRAMA: REPRECEB.prg

FUN€AO: RELATORIO DE CONTAS A RECEBER

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'
#include 'ComBo.ch'
#include 'RepClass.CH'

#DEFINE  COLUNAS  154

***********************
PROCEDURE ReportRECEB()
***********************
LOCAL cCor, cTela, nCurs, nII,;
      oRelat, oCol1, oCol1A, oCol2, oCol3, oCol4, oCol5, oCol6, oCol7, oCol8, oCol9,;
      bFiltro, cFiltro, nCodCli, nCodCen, nCodGru, cOnde := ' ', cPrinter, cQuebra,;
      pRESET, pCOMPR, pDESCO, pDOUBL, pENFAT, pDESEN, cData,;
      cNomFor, cNomGru, cNomCen,;
      GETLIST := {}

MEMVAR dData1, dData2, cCodCli, cCodCen, cCodGru, cSitua, cCond, cQual

SELE RECEB
SET RELATION TO RECEB->CODCLI INTO CLIENTES ,;
             TO RECEB->CODGRU INTO GRUPOS

cCor  := SetColor( SETCORES(2) )
nCurs := SetCursor( SC_NORMAL )
cTela := TELAReport( ' RELA€AO DE CONTAS A RECEBER ' )

nCodCli := nCodCen := nCodGru := 0
dData1  := dData2 := CTOD('')
cCond   := '  '
cSitua  := cQual := cPrinter := ' '
cQuebra := 'N'

WHILE .T.

   @ 7, 10 SAY '   Cliente:' ;
           GET nCodCli PICT '99999999' ;
           WHEN FMENS( 'Digite o C¢digo do Cliente. F2=Clientes.' ) ;
           VALID PESQCLI( nCodCli, 7, 32 ) .OR. VERIFICA( nCodCli, 7, 32 )

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
   
   IF nCodCli != 0
      cNomFor := CLIENTES->NOME
   END
   
   IF nCodGru != 0
      cNomGru := GRUPOS->NOME
   END
   
   oRelat := ReportNew( 56 )

   .oRelat:header := { || { pDOUBL+M->cNomeC,;
                            PADR(M->cNomeA,COLUNAS),;
                            pDOUBL+pENFAT+PADC('RELACAO DE CONTAS A RECEBER',COLUNAS/2)+pDESEN,'',;
                            'Periodo de: ' + dtoc( dData1 ) + ' a ' + dtoc( dData2 ) +;
                            '        Emitindo Contas: ' + IF(cQual=="N","NAO PAGAS",IF(cQUAL=="P","PAGAS","TODAS")),'',;
                            'Cliente: '+ '  ' + cNomFor,;
                            '        Grupo: ' + '  ' + cNomGru,'',;
                            PADR('Data: ' + DTOC( DATE() ),COLUNAS/2 ) +;
                            PADL('Pagina: '+STR( .oRelat:pageCounter, 4, 0 ),COLUNAS/2-2 ) } }


// .oRelat:rodape := {'','',''}

   cFiltro := ''
   IF cCond != "  "
      cFiltro := "RECEB->SITUACAO " + cCond + " cSitua"
   END

   IF nCodCli != 0
      IF !Empty( cFiltro ) ; cFiltro += " .AND. " ; END
      cFiltro += "RECEB->CODCLI == cCodCli"
   END

   IF nCodGru != 0
      IF !Empty( cFiltro ) ; cFiltro += " .AND. " ; END
      cFiltro += "RECEB->CODGRU == cCodGru"
   END

   cData := IF( cQual == "P", "RECEB->DTPAGTO","RECEB->VENCTO")
   
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
          cFiltro += "Empty(RECEB->DTPAGTO)"

   ELSEIF cQual == "P"
          IF !Empty( cFiltro ) ; cFiltro += " .AND. " ; END
          cFiltro += "!Empty(RECEB->DTPAGTO)"

   END

   IF !Empty( cFiltro )
      cCodCli := StrZero( nCodCli, 8, 0 )
      cCodCen := StrZero( nCodCen, 3, 0 )
      cCodGru := StrZero( nCodGru, 3, 0 )

      cFiltro := "{ || " + cFiltro + " }"
      bFiltro := &cFiltro.  // ARGH !!!

      .oRelat:skipBlock := {| nRecords | RepSkipF( nRecords, bFiltro ) }

   END

   IF cQual == "P"
      .oRelat:groupExp := { || pDOUBL + DTOC(RECEB->DTPAGTO) + pDESEN }
      .oRelat:groupHeader := pENFAT + 'Pagamento: '
      SET ORDER TO 3

   ELSE
      .oRelat:groupExp := { || pDOUBL + DTOC(RECEB->VENCTO) + pDESEN }
      .oRelat:groupHeader := pENFAT + 'Vencimento: '
      SET ORDER TO 2

   END

   IF cQuebra == "S"
      .oRelat:subExp := { || RECEB->CODCEN + " - " + AllTrim(CCUSTO->NOME) + ;
                        ' / ' + RECEB->CODGRU + " - " + pDOUBL + AllTrim(GRUPOS->NOME) }
      .oRelat:subHeader := 'Centro de Custo/Grupo: '

   END

   oCol1 := TBColumnNew ( PadR('Lancto', 6 ) ,;
            { || Right(RECEB->NUMERO,6) } )
   oCol1:picture := '@!'
//   oCol1:colSep := '   '

   oCol1A := TBColumnNew ( PadR('Grupo', 13 ) ,;
                        { || PadR( RECEB->CODGRU, 13 ) } )
   oCol1A:picture := '@!'

   oCol2 := TBColumnNew ( PadR('Cliente', 25 ) ,;
            { || PadR( CLIENTES->NOME, 25 ) } )
   oCol2:picture := '@!'
//   oCol2:colSep := ' | '

   oCol3 := TBColumnNew ( PadL('Valor',18),{ || RECEB->VALOR } )
   oCol3:picture := '@E 999,999,999,999.99'
   oCol3:cargo   := { || RECEB->VALOR }
//   oCol3:colSep := ' | '

   oCol4 := TBColumnNew ( PadR('Historico',50),{ || RECEB->DESCRICAO } )
   oCol4:picture := '@!'
   oCol4:colSep := '  '

   oCol5 := TBColumnNew ( PadL('Valor Pago',17),{ || RECEB->VLPAGTO } )
   oCol5:picture := '@E 99,999,999,999.99'
   oCol5:cargo   := { || RECEB->VLPAGTO }
//   oCol5:colSep := ' | '

   oCol6 := TBColumnNew ( '  %   ',{ || 100-(RECEB->VLPAGTO*100/RECEB->VALOR) } )
   oCol6:picture := '@E 999.99'
//   oCol6:colSep := ' | '

   oCol7 := TBColumnNew ( PadR('Documento', 15 ) ,{ || RECEB->DOCUMENTO } )
   oCol7:picture := '@!'

/*
   oCol7 := TBColumnNew ( PadL('Atual',18) ,;
            { || VLFUTURO( RECEB->VALOR, RECEB->MULTA, RECEB->TPMULTA,;
                 RECEB->JUROS, RECEB->TIPO, RECEB->VENCTO ) } )
   oCol7:picture := '@E 999,999,999,999.99'
   oCol7:cargo   := { ||VLFUTURO( RECEB->VALOR, RECEB->MULTA, RECEB->TPMULTA,;
                         RECEB->JUROS, RECEB->TIPO, RECEB->VENCTO ) }
   oCol7:colSep := ' | '
*/

   oCol8 := TBColumnNew ( Space(10),{ || "__________" } )
   oCol8:picture := '@!'
//   oCol8:colSep := ' | '

   oCol9 := TBColumnNew ( 'Situacao',;
            { || SITUACAO( RECEB->NUMERO ) } )
//            { || pDOUBL + SITUACAO( RECEB->NUMERO ) } )
   oCol9:picture := '@!'
//   oCol9:colSep := ' | '

   // Adiciona colunas ao TBrowser
   .oRelat:addColumn ( oCol1  )          // lancamento
   .oRelat:addColumn ( oCol1A )          // grupo
   .oRelat:addColumn ( oCol7 )           // documento
   .oRelat:addColumn ( oCol2  )          // cliente
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

   RECEB->(dbGoTop())
   
   IF !Empty( bFiltro )
      RepSkipperF ( 0 )
      GoTop ( bFiltro )
   END
   
   IF RECEB->(Eof())
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
             Imprime( pRESET + pCOMPR ) // Est  em REPPAGAR

      END

      WHILE ! .oRelat:stabilize()
          TERMO( 23, 50, ++nII )
      END

      EJECT

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

SELE RECEB
SET RELATION TO
SET ORDER TO 1
Fmens('')

SETCOLOR( cCor )
SETCURSOR( nCurs )
RESTSCREEN( 4, 1, MAXROW()-3, MAXCOL()-1, cTela )

RETURN

***********************************
STATIC FUNCTION SITUACAO( cNumero )
***********************************
LOCAL cRet, nParc
IF     EMPTY(RECEB->DTPAGTO)
       cRet := "NAO PAGA"

ELSE
       cRet := "PAGA"

END
RETURN PadR( cRet, 15 )

/*

  FIM - REPRECEB.PRG
  
*/
