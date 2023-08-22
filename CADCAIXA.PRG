/***************

PROGRAMA: CADCAIXA.prg

FUN€AO: CADASTRO DE CAIXA

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'

STATIC sSaldo

***************
PROCEDURE CAIXA
***************
LOCAL cTela, cTelaLimpa, cCor, nEscolha,;
      nII, nCursor, GETLIST := {}, dData, cHistorico,;
      oMyBrowser, oCol1, oCol2, oCol3, oCol4, oCol5, nKey, bFiltro,;
      nTela, nTelaEntrada, nCurEnt

cTela   := SAVESCREEN ( 0, 0, MAXROW(), MAXCOL() )
nCursor := SETCURSOR( SC_NORMAL )
cCor    := SETCOLOR( SETCORES(2) )

FOR nII := 1 TO MAXROW()-7
   SCROLL( 4, 1, MAXROW()-3, MAXCOL()-1, 0, -nII )
   INKEY( .01 )
NEXT
SCROLL( 4, 1, MAXROW()-3, MAXCOL()-1 )

SELE CAIXA

@ 4, 1 SAY PADC ( 'LAN€AMENTOS CAIXA', 78 ) ;
       COLOR SETCORES(2)

@ 5, 1 SAY PADC ( 'ßßßßßßßßßßßßßßßßß', 78 ) ;
       COLOR SETCORES(2)

@  7,  5  SAY "Data:"

/***

  Cria Objeto TBrowse

***/

// TBrowseDB ( nLinha, nColuna, nLinha, nColuna ) -> object
oMyBrowser := TBrowseDB ( 9, 1, MAXROW()-3, MAXCOL()-1 )

// Cores Default         1     2    3    4
oMyBrowser:colorSpec := "W+/N, N/W, N/W, N/W"

oMyBrowser:headSep := "ÄÂÄ"          // Separador de Cabecalho
oMyBrowser:colsep  := " ³ "          // Separador de Colunas

bFiltro := { || CAIXA->DATA == dData }
oMyBrowser:skipBlock := { | nRecords | Skipper( nRecords, bFiltro ) }
oMyBrowser:goBottomBlock := { || GoBottom ( bFiltro ) }
oMyBrowser:goTopBlock    := { || GoTop ( bFiltro ) }

Skipper( 0 )

// TBColumnNew ( oCabecalho, bBlocoDeRecuperacaoDeDados ) -> object
oCol1 := TBColumnNew ( PADC( "Hist¢rico", 25 ) ,;
            { |x| IF ( x == NIL, CAIXA->HISTORICO,;
                                 CAIXA->HISTORICO := x ) } )
oCol1:picture := "@!S25"

oCol2 := TBColumnNew ( PADL("Entrada", 18) ,;
            { |x| IF ( x == NIL, CAIXA->ENTRADA,;
                                 CAIXA->ENTRADA := x ) } )
oCol2:picture := "@E 999,999,999,999.99"

oCol3 := TBColumnNew ( PADL("Sa¡da",18) ,;
            { |x| IF ( x == NIL, CAIXA->SAIDA,;
                                 CAIXA->SAIDA := x ) } )
oCol3:picture := "@E 999,999,999,999.99"

oCol4 := TBColumnNew ( PADL( "Saldo", 18 ) ,;
            { || fSALDO( dData, bFiltro ) } )
oCol4:picture := "@E 999,999,999,999.99"

oCol5 := TBColumnNew ( PADC( "Observa‡ao", 25 ) ,;
            { |x| IF ( x == NIL, CAIXA->OBSERVACAO,;
                                 CAIXA->OBSERVACAO := x ) } )
oCol5:picture := "@!S25"


// Cria os Data Retrieval Blocks
oCol1:cargo := FIELDBLOCK ( "HISTORICO" )
oCol2:cargo := FIELDBLOCK ( "ENTRADA" )
oCol3:cargo := FIELDBLOCK ( "SAIDA" )
oCol5:cargo := FIELDBLOCK ( "OBSERVACAO" )

// Adiciona colunas ao TBrowser
oMyBrowser:addColumn ( oCol1 )
oMyBrowser:addColumn ( oCol2 )
oMyBrowser:addColumn ( oCol3 )
oMyBrowser:addColumn ( oCol4 )
//oMyBrowser:addColumn ( oCol5 )

// oMyBrowser:freeze := 1                // Congela a 1¦ Coluna

cTelaLimpa := SAVESCREEN ( 0, 0, MAXROW(), MAXCOL() )

WHILE .T.
   RESTSCREEN ( 0, 0, MAXROW(), MAXCOL(), cTelaLimpa )
   dData := DATE()
   SETCURSOR ( SC_NORMAL )
   
   @  7, 11 GET dData ;
               WHEN FMENS( 'Digite a Data.' )

   READ

   IF LASTKEY() == K_ESC ; EXIT ; END

   SELE CAIXA
   SEEK dData
   IF !FOUND()
      cHistorico := fSALDOH( dData )
      NetAppBlank( 0 )
      CAIXA->DATA := dData
//      CAIXA->HISTORICO := cHistorico
//      CAIXA->ENTRADA   := sSaldo
   END
   FMENS('')

   ACAO( 'ACESSOU CONTROLE DE CAIXA DATA ' + DTOC( dData ) )
   
   SETCURSOR ( SC_NONE )
   oMyBrowser:panHome()
   oMyBrowser:refreshAll()

   WHILE TRUE

      UNLOCK
      COMMIT
      
      WHILE ( !oMyBrowser:stabilize () ) ; END

      IF oMyBrowser:stable ()

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
      
      IF !Teclas( oMyBrowser, nKey )

         IF     nKey == K_F1
                HELP( PROCNAME(), PROCLINE(), ;
                      ALLTRIM( oMyBrowser:getColumn( oMyBrowser:colPos ):heading ) )

         ELSEIF nKey == K_DEL

                NetRLock ( 0 )
                CAIXA->(dbDelete())
                Skipper(0)
                oMyBrowser:goTop()
                oMyBrowser:refreshAll()

         ELSEIF nKey == K_ENTER
                /*
                IF oMyBrowser:colPos != 4   // *saldo*
                   DataEntry ( oMyBrowser ) 
                END
                */
                nTelaEntrada := WOpen( 8, 10, 13, 61, TRUE )
                ABRE( 0, 0, MaxRow()-1, MaxCol()-2, TRUE )
                IF NetRLock()
                   @  1,  2 SAY 'Historico:' GET CAIXA->HISTORICO PICT '@!S35' 
                   @  2,  2 SAY 'Entrada:' GET CAIXA->ENTRADA PICT "@E 999,999,999,999.99"
                   @  3,  2 SAY 'Entrada:' GET CAIXA->SAIDA PICT "@E 999,999,999,999.99"
                   nCurEnt := SetCursor( SC_NORMAL )
                   READ
                   SetCursor( nCurEnt )
                END
                WClose( nTelaEntrada )
                oMyBrowser:refreshAll()

         ELSEIF nKey == K_INS
                NetAppBlank( 0 )
                CAIXA->DATA := dData
                Skipper(0)
                oMyBrowser:refreshAll()
                oMyBrowser:goBottom()
                KEYBOARD CHR( K_ENTER )

         ELSE
                KEYBOARD( CHR ( nKey ) )
                IF oMyBrowser:colPos != 4  // *saldo*
                   DataEntry ( oMyBrowser )
                ELSE
                   CLEAR TYPEAHEAD
                END
                oMyBrowser:refreshAll()

         END
      END
   END
   
   nTela := WOpen( 10, 15, 16, 51, TRUE )
   DispBox( 0, 0, MaxRow(), MaxCol(), BORDA )
   SELE DETALHE
   SEEK dData
   IF !FOUND()
      NetAppBlank( 0 )
      DETALHE->DATA := dData
   ELSE
      NetRLock(0)
   END

   @ 0,  1 SAY "DETALHES DO SALDO" COLOR "N/W"
   @ 1,  2 SAY "Dinheiro...........:" GET DETALHE->DINHEIRO PICT '@E 9,999,999.99'
   @ 2,  2 SAY "Cheques............:" GET DETALHE->CHEQUES  PICT '@E 9,999,999.99'
   @ 3,  2 GET DETALHE->DESC1         PICT '@!'
   @ 3, 23 GET DETALHE->VALO1         PICT '@E 9,999,999.99'
   @ 4,  2 GET DETALHE->DESC2         PICT '@!'
   @ 4, 23 GET DETALHE->VALO2         PICT '@E 9,999,999.99'
   @ 5,  2 GET DETALHE->DESC3         PICT '@!'
   @ 5, 23 GET DETALHE->VALO3         PICT '@E 9,999,999.99'
   SETCURSOR ( SC_NORMAL )
   READ
   
   WClose( nTela )
END

RESTSCREEN ( 0, 0, MAXROW(), MAXCOL(), cTela )
SETCOLOR( cCor )
SETCURSOR( nCursor )
RETURN



*************************
FUNCTION fSALDOH( dData )
*************************
LOCAL cRet := "", nRec
ALTD()
sSaldo := 0
nRec := RECNO()
CAIXA->(dbGoTop())
WHILE CAIXA->DATA < dData .AND. !CAIXA->(EOF())
   cRet   := "SALDO ANTERIOR (" +DTOC( CAIXA->DATA )+ ")"
   IF CAIXA->HISTORICO != "SALDO ANTERIOR"
      sSaldo += ( CAIXA->ENTRADA-CAIXA->SAIDA)
   END
   CAIXA->(dbSkip())
END
GO nRec
RETURN cRet


**********************************
FUNCTION fSALDO ( dData, bFiltro )
**********************************
LOCAL nRet := CAIXA->ENTRADA - CAIXA->SAIDA
IF RECCOUNT() > 1 .AND. !BOF()
   IF Skipper( -1, bFiltro ) == -1
      IF !BOF() .AND. CAIXA->DATA == dData
         nRet += fSALDO( dData, bFiltro )
      END
      Skipper( +1, bFiltro )
   END
END
RETURN nRet   

*********************************************************
PROCEDURE LANCAIXA( dData, cHistorico, nEntrada, nSaida )
*********************************************************
LOCAL nSele
nSele := Select()
   SELE CAIXA
   CAIXA->(NetAppBlank( 0 ))
   CAIXA->DATA      := dData
   CAIXA->HISTORICO := cHistorico
   CAIXA->ENTRADA   := nEntrada
   CAIXA->ENTRADA   := nSaida
Select( nSele )
RETURN
