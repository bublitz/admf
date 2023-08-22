/***************

PROGRAMA: REPCAM_V.prg

FUN€AO: RELACAO DE CAMINHOES - VENDA

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'
#include 'COMBO.CH'
#include 'REPCLASS.CH'

#DEFINE  COLUNAS  91

**********************
PROCEDURE RepCamVend()
**********************
LOCAL cCor, cTela, nCurs, ;
      oRelat, oCol1, oCol2, oCol3, oCol4, oCol5, oCol6,;
      cOnde, cPrinter, bFiltro,;
      pRESET, pCOMPR, pDESCO, pDOUBL, pENFAT, pDESEN, ;
      GETLIST := {}

cCor  := SetColor( SETCORES(2) )
nCurs := SetCursor( SC_NORMAL )
cTela := TELAReport( ' RELA€AO DE CAMINHOES - VENDA ' )

cOnde := cPrinter := ' '

SELE CAMINHAO
SET ORDER TO 2
SET RELATION TO CAMINHAO->VENDEDOR   INTO FUNCIONA,;
             TO CAMINHAO->PROPRIETAR INTO CLIENTES
             
CAMINHAO->(dbGoTop())

WHILE .T.

   @ 19,10 SAY "Impressora ou Tela:" GET cOnde PICT "!" ;
           COMBO { 'Impressora','Tela' } ;
           VALID cOnde$'TI'

   @ 19,50 SAY "Impressora:" GET cPrinter ;
           COMBO A_PRINT ;
           VALID cPrinter$"123" ;
           WHEN cOnde == "I"

   READ

   IF LASTKEY() == K_ESC ; EXIT ; END

   IF cOnde == "I"
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

   oRelat := ReportNew( 56 )

   .oRelat:header := { || { pDOUBL+M->cNomeC,;
                            PADR(M->cNomeA,COLUNAS),;
                            pDOUBL+pENFAT+PADC('RELACAO DE CAMINHOES - VENDA',COLUNAS/2)+pDESEN,'',;
                            PADR('Data: ' + DTOC( DATE() ),COLUNAS/2 ) +;
                            PADL('Pagina: '+STR( .oRelat:pageCounter, 4, 0 ),COLUNAS/2 ) } }

   bFiltro := { || CAMINHAO->TIPO == 'V' }
   
   RepSkipperF ( 0 )
   GoTop ( bFiltro )

   .oRelat:skipBlock := {| nRecords | RepSkipF( nRecords, bFiltro ) }

   .oRelat:rodape   := {'','',''}

   .oRelat:groupExp := { || NOMETAB('1',CAMINHAO->MARCA)+pDESEN }
   .oRelat:groupHeader := pDOUBL + pENFAT + 'Marca: '

   .oRelat:subExp := { || NOMETAB('2',CAMINHAO->MODELO)+pDESEN }
   .oRelat:subHeader := pENFAT + 'Modelo: '

   oCol1 := TBColumnNew ( PadR( 'Modelo', 34 ) ,;
            { || NOMETAB('2',CAMINHAO->MODELO) } )
   oCol1:picture := '@!'

   oCol2 := TBColumnNew ( 'Ano ', { || CAMINHAO->ANO } )
   oCol2:picture := '9999'

   oCol3 := TBColumnNew ( 'Placa  ', { || CAMINHAO->PLACA } )
   oCol3:picture := '@R AAA-9999'

   oCol4 := TBColumnNew ( PadL('Valor', 12),{ || CAMINHAO->VENDA } )
   oCol4:picture := '@E 9,999,999.99'

   oCol5 := TBColumnNew ( 'Vendedor        ', { || FUNCIONA->APELIDO } )
   oCol5:picture := ''

   oCol6 := TBColumnNew ( PadR('Proprietario', 45 ) ,;
            { || CAMINHAO->PROPRIETAR + ' ' + ;
            SubStr( CLIENTES->NOME, 1, 30 ) + '-' + ;
            Transform( IF(Empty(CLIENTES->FONE1),CLIENTES->FONE2,CLIENTES->FONE1),; 
            "@R (999X)X999-9999" ) } )
   oCol6:picture := '@!'

   // Adiciona colunas ao TBrowser
   //.oRelat:addColumn ( oCol1 ) // SUBGRUPO MODELO
   .oRelat:addColumn ( oCol2 )
   .oRelat:addColumn ( oCol4 )
   .oRelat:addColumn ( oCol5 )
   .oRelat:addColumn ( oCol6 )

   IF cOnde == "T" .OR. FPRINTER ()
      FMENS( 'Aguarde... Emitindo Relatorio...' )
      SET DEVICE TO PRINT

      IF     cOnde == "T"
             SET ( 24, "$RELCV." + M->cTerm, FALSE )

      ELSE
             @ PRow(),PCol() SAY pRESET //+ pCOMPR

      END

      WHILE ! .oRelat:stabilize()
      END

      EJECT

      SET PRINTER TO
      SET DEVICE TO SCREEN

      FMENS('')

      IF cOnde == "T"
         REPTELA( "$RELCV." + M->cTerm )
         FErase( "$RELCV." + M->cTerm )

      ELSE
         ATENCAO( 'Emitido!' )

      END

      FMENS('')
   END


END

SELE CAMINHAO
SET RELATION TO
SET ORDER TO 1
Fmens('')

SETCOLOR( cCor )
SETCURSOR( nCurs )
RESTSCREEN( 4, 1, MAXROW()-3, MAXCOL()-1, cTela )

RETURN


******************************
FUNCTION NOMETAB( cTipo, cCod )
******************************
TABELA->(dbSeek( cTipo + cCod ))
RETURN cCod + ' ' + TABELA->NOME
