/***************

PROGRAMA: REPEMISS.prg

FUN€AO: EMISSAO DE CHEQUES

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'
#include 'ComBo.ch'
#include 'RepClass.CH'

**********************
PROCEDURE RepEMISSAO()
**********************
LOCAL cCor, cTela, nCurs, ;
      oRelat, oCol1, oCol2, oCol3, oCol4, oCol5, oCol6, oCol7, oCol8, ;
      oMyBrowser, oColumn1, oColumn2, oColumn3, oColumn4, oColumn5, oColumn6,;
      nKey, bFiltro, cPrinter, cArq, cExt, cLi1, cLi2,;
      pRESET, pCOMPR, pDESCO, pDOUBL, pENFAT, pDESEN, ;
      GETLIST := {}

cCor  := SetColor( SETCORES(2) )
nCurs := SetCursor( SC_NORMAL )
cTela := TELAReport( ' EMISSAO DE CHEQUES ' )

FMENS( 'AGUARDE... Gerando arquivo auxiliar...' )

cPrinter := '1'
cArq     := "$ARQ" + M->cTerm + ".dbf"

dbCreate( cArq, { { 'EMITIR   ', 'C',  1, 0 } ,;
                  { 'NUMERO   ', 'C', 10, 0 } ,;
                  { 'BANCO    ', 'C',  5, 0 } ,;
                  { 'FORNEC   ', 'C',  8, 0 } } )

USE ( cArq ) ALIAS AUXILIAR NEW EXCLUSIVE
INDEX ON AUXILIAR->NUMERO+AUXILIAR->BANCO TO AUXILIAR
SET RELATION TO AUXILIAR->NUMERO+AUXILIAR->BANCO INTO CHEQUES ,;
             TO AUXILIAR->FORNEC                 INTO FORNEC

SELE CHEQUES
SET ORDER TO 2
GO TOP
WHILE !CHEQUES->(EOF())
   IF SubStr( CHEQUES->CLIFOR, 1, 1 ) == "F" .AND. Empty( CHEQUES->DTRECEBEU )
      SELE AUXILIAR
      APPEND BLANK
      AUXILIAR->NUMERO := CHEQUES->NUMERO
      AUXILIAR->BANCO  := CHEQUES->BANCO
      AUXILIAR->FORNEC := SubStr( CHEQUES->CLIFOR, 2 )
      COMMIT
      SELE CHEQUES
   END
   CHEQUES->(dbSkip())
END

SELE AUXILIAR
GO TOP

oMyBrowser := TBrowseDB ( 8, 5, MAXROW()-4, MAXCOL()-5 )

oMyBrowser:colorSpec := 'W+/N, N/W, N/W, N/W'

oMyBrowser:headSep := 'Ä'          // Separador de Cabecalho
oMyBrowser:colsep  := '³'          // Separador de Colunas

oColumn1 := TBColumnNew ( 'Fornecedor', { || SubStr(FORNEC->NOME,1,25) } )
oColumn1:picture := '@!'
oColumn2 := TBColumnNew ( 'Cheque - Banco' , { || AUXILIAR->NUMERO+'-'+CHEQUES->BANCO } )
oColumn2:picture := '@!'
oColumn3 := TBColumnNew ( 'Valor', { || CHEQUES->VALOR } )
oColumn3:picture := '@E 999,999,999,999.99'
oColumn4 := TBColumnNew ( ' ', { || AUXILIAR->EMITIR+' '+CHEQUES->EMITIDO } )

oMyBrowser:addColumn ( oColumn4 )
oMyBrowser:addColumn ( oColumn1 )
oMyBrowser:addColumn ( oColumn2 )
oMyBrowser:addColumn ( oColumn3 )

FMENS( 'Marque os Cheques que serao emitidos. Use a Barra de Espa‡os.' )

WHILE TRUE

   WHILE ( !oMyBrowser:stabilize () ) 
      IF ( nKey := INKEY() ) != 0 ; EXIT ; END
   END

   oMyBrowser:colorRect( { oMyBrowser:rowPos, 1, oMyBrowser:rowPos,; 
                           oMyBrowser:colCount }, { 3, 4 } )

   IF oMyBrowser:stable ()

      @ MaxRow()-3, 5     SAY "Historico: "
      @ MaxRow()-3, Col() SAY CHEQUES->HISTORICO COLOR SETCORES(3)
      
      @ MaxRow()-3, Col()+4 SAY "Cheque "+IF(CHEQUES->EMITIDO="S",'JA','NAO')+;
                                " emitido. " COLOR SETCORES(2)
      
      WHILE TRUE

         oMyBrowser:hilite()

         IF ( nKey := INKEY ( 0.3 ) ) != 0    // delay
            EXIT
         END

         oMyBrowser:deHilite()

         IF ( nKey := INKEY ( 0.3 ) ) != 0    // delay
            EXIT
         END

      END

   END

   IF nKey == K_ESC ; EXIT ; END

   IF     nKey == K_LEFT
          
   ELSEIF nKey == K_RIGHT
          
   ELSEIF !Teclas( oMyBrowser, nKey )

          IF     nKey == K_F1
                 HELP( PROCNAME(), PROCLINE(), '' )

          ELSEIF nKey == K_SPACE
                 IF AUXILIAR->EMITIR == " " ; AUXILIAR->EMITIR := "X"
                 ELSE                       ; AUXILIAR->EMITIR := " "
                 END
          END
   END

   oMyBrowser:refreshCurrent()
   
END

IF ATENCAO( 'Confirma Emissao dos Cheques?', {'Nao','SIM'}, SETCORES(2) ) == 2

   /* EMITE CHEQUES */
   IF FPRINTER()
      SET DEVICE TO PRINTER

//      SET PRINTER TO $REL.001

      @ PRow(),0 SAY ''
      SELE AUXILIAR
      GO TOP
      WHILE !AUXILIAR->(EOF())
         IF !Empty( AUXILIAR->EMITIR )
            cExt := EXTENSO( CHEQUES->VALOR )
            cLi1 := MemoLine( cExt, 58, 1, .T. )
            cLi2 := MemoLine( cExt, 58, 2, .T. )
            @ PRow()  , 48 SAY CHEQUES->VALOR PICT "@E ***,***,***.**"
            @ PRow(), PCol() SAY "**"
            @ PRow()+2,  7 SAY PadR( AllTrim(cLi1)+ ' ', 58, '*' )
            @ PRow()+2,  0 SAY PadR( AllTrim(cLi2)+ ' ', 62, '*' )
            @ PRow()+2,  0 SAY FORNEC->NOME
            @ PRow()+2, 28 SAY "CUIABA"+CHR(8)+"'"
            @ PRow()  , 44 SAY Day( Date() ) PICT "99"
            @ PRow()  , 50 SAY MES( Date() ) 
            @ PRow()  , 64 SAY SubStr( Str( Year( Date() ), 4 ), 3 )
            @ Prow()+11, 0 SAY ''
         END
         AUXILIAR->(dbSkip())
      END
      EJECT
      SET PRINTER TO
      SET DEVICE TO SCREEN

//      REPTELA( '$REL.001' )

      GO TOP
      WHILE !AUXILIAR->(EOF())
         IF !Empty( AUXILIAR->EMITIR )
            SELE CHEQUES
            IF NetRLock(0) ; CHEQUES->EMITIDO := "S" ; END
            SELE AUXILIAR
         END
         AUXILIAR->(dbSkip())
      END
   END

END

SELE AUXILIAR
dbCloseArea()
FErase( cArq )

SELE CHEQUES
SET ORDER TO 1

SETCOLOR( cCor )
SETCURSOR( nCurs )
RESTSCREEN( 4, 1, MAXROW()-3, MAXCOL()-1, cTela )

RETURN

********************
FUNCTION MES( DATA )
********************
LOCAL MESES := { "JANEIRO","FEVEREIRO","MARC"+CHR(8)+",O","ABRIL","MAIO","JUNHO",;
                 "JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO" }

RETURN MESES[ MONTH( DATA ) ]
                 