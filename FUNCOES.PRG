/*
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\\                                          \\
\\  PROGRAMA: FUNCOES.prg                   \\
\\                                          \\
\\  FUN€AO: Rotinas Gerais do Sistema       \\
\\                                          \\
\\  AUTOR: Jorge Luis Bublitz               \\
\\                                          \\
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
*/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'

***********************
FUNCTION FMENS( cMens )
***********************
@ MaxRow()-1,  2 SAY PadR( 'Mensagem: ', MaxCol()-11 ) COLOR SETCORES(1)
@ MaxRow()-1, 12 SAY PadR( cMens, MaxCol()-23 ) COLOR SETCORES( 4 )
IF Upper( Substr( cMens, 1, 7 ) ) == 'AGUARDE' .OR. 'ATENCAO'$cMens
   BEEP()
   @ MaxRow()-1, 12 SAY PadR( cMens, MaxCol()-23 ) COLOR SETCORES( 5 )
END
RETURN TRUE

***************************************
PROCEDURE HELP ( cProg, nLinha, cVari )
***************************************
LOCAL cTela, cCor, cLinha,;
      nCursor, nSele, lDesen := TRUE

STATIC mHelp

IF mHelp == NIL ; mHelp := 'ßßßßßßßßßßßßßßßß' ; END

IF ! 'HELP'$cProg
   cCor := SETCOLOR ( SETCORES( 1 ) )
   cTela := ABRE( 5, 15, MAXROW()-5, MAXCOL()-15, TRUE )
   @ 5, 16 SAY ' HELP ON-LINE ' COLOR 'N/W'
   nCursor := SETCURSOR ( SC_NORMAL )

   cLinha := SAVESCREEN( MAXROW()-1, 0, MAXROW()-1,MAXCOL() )
   FMENS( 'Tecle [ESC] ...' )

   cProg := UPPER( SUBSTR( cProg+SPACE(10), 1, 10) )
   cVari := UPPER( SUBSTR( cVari+SPACE(10), 1, 10) )

   nSele := SELECT ()
   NetUse( 'HELP' )
   SET INDEX TO HELP
   SEEK cProg+cVari

   IF FOUND()
      IF !lDesen
         MEMOEDIT ( HELP->MENS, 6, 18, MAXROW()-6, MAXCOL()-18, .F. )
      ELSE
         NetRLock(0)
         HELP->MENS := MEMOEDIT ( HELP->MENS, 6, 18, MAXROW()-6, MAXCOL()-18, .T. )
      END
   ELSE
      @  7, 20 SAY 'NAO EXISTE ARQUIVO DE HELP'
      @  9, 20 SAY 'PARA ESTE PONTO DO PROGRAMA'
      @ 11, 20 SAY 'CHAME O ROOT'
      INKEY(0)
      IF lDesen
         NetAppBlank()
         HELP->PROG := cProg
         HELP->VARI := cVari
         HELP->MENS := mHelp
         HELP->MENS := MEMOEDIT ( HELP->MENS, 6, 18, MAXROW()-6, MAXCOL()-18, .T. )
      END
   END

   mHelp := HELP->MENS

   dbCloseArea()
   SELECT( nSele )

   FECHA( 5, 15, MAXROW()-5, MAXCOL()-15, cTela, TRUE )
   SETCURSOR( nCursor )
   SETCOLOR ( cCor )
   RESTSCREEN( MAXROW()-1, 0, MAXROW()-1,MAXCOL(), cLinha )

END
RETURN



******************
PROCEDURE FuncHelp
******************
LOCAL cTela, cCor, cLinha,;
      nCursor, nSele

cCor := SETCOLOR ( SETCORES(1) )
cTela := ABRE( 4, 15, MAXROW()-6, MAXCOL()-15, TRUE )
@ 4, 16 SAY ' HELP FUNCOES ' COLOR 'N/W'
nCursor := SETCURSOR ( SC_NONE )

cLinha := SAVESCREEN( MAXROW()-1, 0, MAXROW()-1,MAXCOL() )
FMENS( 'Tecle ESC.' )

@  6, 17 SAY ' F1 = Help ON-LINE        F2 = Clientes  '
@  8, 17 SAY ' F3 = Funcionarios        F4 = Prov/Desc '
@ 10, 17 SAY ' F5 = Bancos              F6 = Tabelas   '
@ 12, 17 SAY ' F7 = Fornecedores        F8 = Cheques   '
@ 14, 17 SAY ' F9 =                     F10 = Grupos   '
@ 16, 17 SAY ' F12 = Calculadora        [] = Dispon¡vel'
@ 16, 17 SAY "[F12]" COLOR SETCORES( 4 )
@ 16, 43 SAY '[]' COLOR SETCORES( 4 )

@  6, 17 SAY "[F1]" COLOR SETCORES( 4 )
IF "U"$M->cRight ; @  6, 42 SAY "[F2]" COLOR SETCORES( 4 ) ; END
IF "V"$M->cRight ; @  8, 17 SAY "[F3]" COLOR SETCORES( 4 ) ; END
IF "W"$M->cRight ; @  8, 42 SAY "[F4]" COLOR SETCORES( 4 ) ; END
IF "X"$M->cRight ; @ 10, 17 SAY "[F5]" COLOR SETCORES( 4 ) ; END
IF "Y"$M->cRight ; @ 10, 42 SAY "[F6]" COLOR SETCORES( 4 ) ; END
IF "Z"$M->cRight ; @ 12, 17 SAY "[F7]" COLOR SETCORES( 4 ) ; END
IF "a"$M->cRight ; @ 12, 42 SAY "[F8]" COLOR SETCORES( 4 ) ; END
IF "b"$M->cRight ; @ 14, 17 SAY "[F9]" COLOR SETCORES( 4 ) ; END
IF "c"$M->cRight ; @ 14, 42 SAY "[F10]" COLOR SETCORES( 4 ) ; END

INKEY(0)
FECHA( 4, 15, MAXROW()-6, MAXCOL()-15, cTela, TRUE )
SETCURSOR( nCursor )
SETCOLOR ( cCor )
RESTSCREEN( MAXROW()-1, 0, MAXROW()-1,MAXCOL(), cLinha )

RETURN

**************************
FUNCTION SetCores( Param )
**************************
STATIC aCores
LOCAL Ret

IF VALTYPE( Param ) == 'A'
   aCores := Param
ELSE
   Ret := aCores[ Param ]
END
RETURN Ret


*******************************************************************
*******************************************************************
*******************************************************************
*******************************************************************
FUNCTION ABRE2 ( nTop, nLeft, nBottom, nRight, lShad )
RETURN { nTop, nLeft, nBottom, nRight, lShad, ;
         ABRE ( nTop, nLeft, nBottom, nRight, lShad ) }

PROCEDURE FECHA2( aTela )
FECHA( aTela[1], aTela[2], aTela[3], aTela[4], aTela[6], aTela[5] )
RETURN          
*******************************************************************
*******************************************************************

*****************************************************
FUNCTION ABRE ( nTop, nLeft, nBottom, nRight, lShad )
*****************************************************
LOCAL cTela, nIncL, nIncC, nII, nConta, nL1, nC1, nL2, nC2

IF lShad == Nil ; lShad := FALSE ; END

IF lShad ; cTela := SAVESCREEN( nTop, nLeft, nBottom+1, nRight+2 )
ELSE     ; cTela := SAVESCREEN( nTop, nLeft, nBottom, nRight )
END

nL1 := nL2 := ( nBottom - nTop ) / 2 + nTop
nC1 := nC2 := ( nRight - nLeft ) / 2 + nLeft

IF ( nBottom-nTop ) > ( nRight - nLeft )
   nIncC := 1
   nIncL := ( nBottom - nTop ) / ( nRight - nLeft )
   nConta := ( nRight - nLeft ) / 2

ELSE
   nIncL := 1
   nIncC := ( nRight - nLeft ) / ( nBottom - nTop )
   nConta := ( nBottom - nTop ) / 2

END

FOR nII := 1 TO nConta - 1
    nL1 -= nIncL
    nC1 -= nIncC
    nL2 += nIncL
    nC2 += nIncC
    DispBox ( nL1, nC1, nL2, nC2, BORDA )
    INKEY( B_DELAY )
NEXT

DispBox ( nTop, nLeft, nBottom, nRight, BORDA )

IF lShad ; SOMBRA ( nTop, nLeft, nBottom, nRight ) ; END

RETURN cTela

*************************************************************
FUNCTION FECHA ( nTop, nLeft, nBottom, nRight, cTela, lShad )
*************************************************************
IF lShad == Nil ; lShad := FALSE ; END
IF lShad ; nBottom++ ; nRight+=2 ; END
RESTSCREEN( nTop, nLeft, nBottom, nRight, cTela )
RETURN NIL


****************************************************
PROCEDURE SOMBRA ( nTop , nLeft , nBottom , nRight )
****************************************************
LOCAL nShadTop := MIN(nBottom + 1 , MAXROW()) ,;
      nShadBottom := MIN(nBottom + 1 , MAXROW()) ,;
      nShadLeft := nLeft + 2 ,;
      nShadRight := MIN(nRight + 2 , MAXCOL())

RESTSCREEN( nShadTop, nShadLeft, nShadBottom, nShadRight,;
            TRANSFORM( SAVESCREEN( nShadTop, nShadLeft, nShadBottom, nShadRight),;
            REPLICATE('X'+CHR(7), nShadRight - nShadLeft + 1 ) ) )

nShadTop    := nTop + 1
nShadLeft   := MIN(nRight + 1 , MAXCOL())
nShadBottom := nBottom

RESTSCREEN( nShadTop, nShadLeft, nShadBottom, nShadRight,;
            TRANSFORM( SAVESCREEN( nShadTop, nShadLeft, nShadBottom, nShadRight),;
            REPLICATE('X'+CHR(7), ( nShadBottom - nShadTop + 1 ) * 2 ) ) )
RETURN

***************
FUNCTION fNTX()
***************
LOCAL lRet := TRUE, nII, ;
      aArq := { 'BANCOS','HELP','LANCTOS1','LANCTOS2','CHEQUES','CLIFOR1',;
                'CLIFOR2','SALDOS','CAIXA' }

FOR nII := 1 TO LEN( aArq )
    IF !FILE( aArq[ nII ]+'.NTX' )
       lRet := FALSE
       EXIT
    END
NEXT
RETURN lRet



**************************
FUNCTION CGCCPF( cNumero )
**************************
LOCAL lRet := FALSE, nII, nTT, nSoma
LOCAL cNum, nResto, ;
      aPeso := { '543298765432','6543298765432' }

cNumero := ALLTRIM( cNumero )

IF LEN ( cNumero ) == 11    // CPF = 11 D¡gitos
   cNum := SUBSTR( cNumero, 1, 9 )
   FOR nTT := 0 TO 1
      nSoma := 0
      FOR nII := 1 TO 11
          nSoma += VAL( SUBSTR( cNum, nII+nTT, 1 ) )  *  ( 11 - nII )
      END
      nResto := 11 - MOD( nSoma, 11 )
      cNum += STR( IF ( nResto < 10, nResto, 0 ), 1, 0 )
   END
   @ 20, 10 say cnum
   @ 20, 40 say cnumero
   IF cNum == cNumero
      lRet := TRUE
   END

ELSE                     // CGC = 14 D¡gitos
   cNum := SUBSTR( cNumero, 1, 12 )
   FOR nTT := 1 TO 2
      nSoma := 0
      FOR nII := 1 TO 11+nTT
         nSoma += VAL(SUBSTR( cNum, nII, 1))*VAL(SUBSTR( aPeso[nTT], nII, 1))
      END
      nResto := 11 - MOD( nSoma, 11 )
      cNum += STR( IF ( nResto < 10, nResto, 0 ), 1, 0 )
   END
   IF cNum == cNumero
      lRet := TRUE
   END

END
RETURN lRet

*******************
FUNCTION FPRINTER()
*******************
LOCAL lRet
WHILE TRUE
   FMENS( 'Esc=Cancela Impressao' )
   IF ATENCAO( 'Impressora pronta tecle',{' ENTER '}, SETCORES(3) ) == 0
      lRet := FALSE
      EXIT
   END
   IF ISPRINTER()
      lRet := TRUE
      EXIT
   END
END
RETURN lRet


**************************
FUNCTION DECRIPTO( cMens )
**************************
LOCAL cRet := '', nII, nCar
FOR nII := 1 TO LEN( cMens )

    nCar := ASC( SUBSTR( cMens, nII, 1 ) )

    IF nII/2 == INT( nII/2 )
       nCar -= 2

    ELSE
       nCar--

    END

    cRet += CHR( nCar )

NEXT
RETURN cRet

************************
FUNCTION CRIPTO( cMens )
************************
LOCAL cRet := '', nII, nCar

FOR nII := 1 TO LEN( cMens )

    nCar := ASC( SUBSTR( cMens, nII, 1 ) )

    IF nII/2 == INT( nII/2 )
       nCar += 2

    ELSE
       nCar++

    END

    cRet += CHR( nCar )

NEXT
RETURN cRet


/************
*
*      Function DataEntry
*
*      Edita 'celula' corrente do TBrowse
*
*      Parametros: oTB     = objeto TBrowser sendo utilizado
*/

FUNCTION DataEntry ( oTB )

LOCAL oColumn := oTB:GetColumn ( oTB:colPos ) ,;
      oGet, nOldCursor := SETCURSOR ( SC_NORMAL )

NetRLock( 0 )
oGet := GETNEW ( ROW () , COL () , oColumn:cargo, , oColumn:picture )

READEXIT( TRUE )
READMODAL ( { oGet } )
READEXIT( FALSE )
COMMIT
UNLOCK
SETCURSOR ( nOldCursor )

oTB:refreshCurrent()

oTB:right()

RETURN Nil

**********************************
FUNCTION TECLAS( oMyBrowser, nKey )
**********************************
LOCAL lRet := TRUE

   IF nKey == K_UP
      oMyBrowser:up ()

   ELSEIF nKey == K_DOWN
      oMyBrowser:down ()
   
   ELSEIF nKey == K_LEFT
      oMyBrowser:left ()

   ELSEIF nKey == K_RIGHT
      oMyBrowser:right ()
   
   ELSEIF nKey == K_HOME
      oMyBrowser:goTop ()
   
   ELSEIF nKey == K_END
      oMyBrowser:goBottom ()

   ELSEIF nKey == K_PGUP
      oMyBrowser:pageUp ()

   ELSEIF nKey == K_PGDN
      oMyBrowser:pageDown ()

   ELSE
      lRet := FALSE
      
   END


RETURN lRet

      
*************************
FUNCTION GoTop( bFilter )
*************************
GO TOP
WHILE !EVAL( bFilter ) .AND. !EOF() ; SKIP ; END
RETURN NIL

****************************
FUNCTION GoBottom( bFilter )
****************************
GO BOTTOM
WHILE !EVAL( bFilter ) .AND. !BOF() ; SKIP -1 ; END
RETURN NIL

************************************
FUNCTION Skipper( nToJump, bFilter )
************************************
STATIC lStartUp := TRUE
STATIC nRecNumTop, nRecNumBot

LOCAL nJumped := 0, nLastRec

IF bFilter == NIL
   lStartUp := TRUE
   RETURN 0
END

IF LASTREC() != 0
   IF lStartUp
      lStartUp := FALSE
      GoBottom( bFilter )
      nRecNumBot := RECNO()
      GoTop( bFilter )
      nRecNumTop := RECNO()
   END 
     
   IF nToJump > 0
      WHILE nJumped < nToJump .AND. RECNO() != nRecNumBot
         IF ( nLastRec := RECNO() ) != nRecNumBot
            SKIP
            WHILE !EVAL( bFilter ) .AND. !EOF()
               SKIP
            END
         END
         IF !EVAL( bFilter ) .OR. EOF()
            GO nLastRec
            EXIT
         END
         nJumped++
      END
      
   ELSEIF nToJump < 0
      WHILE nJumped > nToJump .AND. RECNO() != nRecNumTop
         IF ( nLastRec := RECNO() ) != nRecNumTop
            SKIP -1
            WHILE !EVAL( bFilter ) .AND. !BOF()
               SKIP -1
            END
         END
         IF !EVAL( bFilter ) .OR. BOF()
            GO nLastRec
            EXIT
         END
         nJumped--
      END
   ELSE
      COMMIT
   END
END

RETURN nJumped

***************************************
FUNCTION ATENCAO( cMens, aOpcao, cCor )
***************************************
LOCAL cOldCor, cTela, aMens := {},;
      nII, nPos, nMaior, nLin, nCol, nTecla, nCursor,;
      aPos := {}, CARGO

IF aOpcao == Nil
   aOpcao := {'Ok'}
END

IF cCor == Nil
   cCor := "W+/N"
END

cOldCor := SETCOLOR ( cCor )
cTela   := SAVESCREEN( 0, 0, MAXROW(), MAXCOL() )
nCursor := SETCURSOR( SC_NONE )

nPos := 1
FOR nII := 2 TO LEN( cMens )
    IF SUBSTR( cMens, nII, 1 ) = ';'
       AADD ( aMens, SUBSTR( cMens, nPos, nII-nPos ) )
       nPos := nII  + 1
    END
NEXT    
AADD ( aMens, SUBSTR( cMens, nPos ) )

nMaior := LEN ( aMens[ 1 ] )
FOR nII := 2 TO LEN( aMens )
    IF LEN ( aMens[ nII ] ) > nMaior
       nMaior := LEN ( aMens[ nII ] )
    END
NEXT

nII := 0
FOR nPos := 1 TO LEN ( aOpcao )
   nII += ( LEN( aOpcao[ nPos ] ) + 2 )
NEXT

nMaior := Max( nII, nMaior )

nLin := MaxRow() - Len( aMens ) - 8
nCol := MaxCol() - nMaior - 2

nPos := nCol + 1 + (nMaior-nII)/2

CARGO := SETCOLOR( B_NO_PUSH )
SCROLL ( nLin, nCol, MAXROW() - 3, MAXCOL() - 1 )

SETCOLOR( CARGO )
DispBotao( nLin, nCol, MAXROW() - 3, MAXCOL() - 1,'' )

FOR nII := 1 TO LEN( aMens )
    @ nLin+nII, nCol+1 SAY PADC( aMens[ nII ], nMaior ) COLOR B_NO_PUSH
NEXT

FOR nII := 1 TO LEN ( aOpcao )
    DispBotao ( MAXROW()-6, nPos, MAXROW()-4, nPos+LEN( aOpcao[ nII ] )+1 ,;
                aOpcao[ nII ] )
    AADD( aPos, { MAXROW()-6, nPos, MAXROW()-4, nPos+LEN( aOpcao[ nII ] )+1 } )
    nPos += ( LEN( aOpcao[ nII ] ) + 2 )
NEXT

nPos := 1
WHILE TRUE
    nLin := aPos[ nPos ][ 1 ]
    nCol := aPos[ nPos ][ 2 ]
    @ nLin+1, nCol+1 SAY aOpcao[ nPos ]

    nTecla := INKEY(0)

    IF     nTecla == K_ESC
           nPos := 0
           EXIT

    ELSEIF nTecla == K_F1
           HELP ( PROCNAME(), PROCLINE(), 'nTecla' )

    ELSEIF nTecla == K_ENTER
           DispAperto( aPos[ nPos ][ 1 ], aPos[ nPos ][ 2 ],;
                       aPos[ nPos ][ 3 ], aPos[ nPos ][ 4 ] )
           EXIT

    ELSEIF nTecla == K_RIGHT
           @ nLin+1, nCol+1 SAY aOpcao[ nPos ]  COLOR B_NO_PUSH
           nPos++
           IF nPos > LEN ( aOpcao ) ; nPos := 1 ; END

    ELSEIF nTecla == K_LEFT
           @ nLin+1, nCol+1 SAY aOpcao[ nPos ]  COLOR B_NO_PUSH
           nPos--
           IF nPos < 1 ; nPos := LEN ( aOpcao ) ; END

    END
END

SETCOLOR ( cOldCor )
RESTSCREEN( 0, 0, MAXROW(), MAXCOL(), cTela )
SETCURSOR( nCursor )
RETURN nPos



**********************************************************
PROCEDURE DispBotao( nTop, nLeft, nBottom, nRight, cNome )
**********************************************************
LOCAL nLin, nCol
@ nTop+1, nLeft+1 SAY cNome    COLOR B_NO_PUSH
DispBox( nTop, nLeft, nBottom, nRight, 'ÚÄ¿³ÙÄÀ³', B_PUSH )

@ nTop, nRight SAY '¿'         COLOR B_NO_PUSH
@ nBottom, nRight SAY 'Ù'      COLOR B_NO_PUSH
FOR nLin := nTop+1 TO nBottom-1
    @ nLin, nRight SAY '³'     COLOR B_NO_PUSH
NEXT
FOR nCol := nLeft+1 TO nRight-1
    @ nBottom, nCol SAY 'Ä'    COLOR B_NO_PUSH
NEXT

RETURN

**********************************************************
STATIC PROCEDURE DispAperto( nTop, nLeft, nBottom, nRight )
***********************************************************
LOCAL nLin, nCol, cTela, nII

DispBox( nTop, nLeft, nBottom, nRight, 'ÚÄ¿³ÙÄÀ³', B_NO_PUSH )

@ nTop, nRight SAY '¿'         COLOR B_PUSH
@ nBottom, nRight SAY 'Ù'      COLOR B_PUSH
FOR nLin := nTop+1 TO nBottom-1
    @ nLin, nRight SAY '³'     COLOR B_PUSH
NEXT
FOR nCol := nLeft+1 TO nRight-1
    @ nBottom, nCol SAY 'Ä'    COLOR B_PUSH
NEXT

cTela := SAVESCREEN ( nTop+1, nLeft+1, nBottom-1, nRight-1 )

FOR nII := 1 TO B_DELAY*500
    RESTSCREEN( nTop+1, nLeft+1, nBottom-1, nRight-1,;
            TRANSFORM( SAVESCREEN( nTop+1, nLeft+1, nBottom-1, nRight-1 ),;
            REPLICATE('X'+CHR( 7*7+15 ), (nRight+1) - (nLeft+1) + 1 ) ) )
    INKEY( B_DELAY )
    RESTSCREEN ( nTop+1, nLeft+1, nBottom-1, nRight-1, cTela )
    INKEY( B_DELAY )
NEXT

RETURN

*********************************
FUNCTION LIMPA( L1, C1, L2, C2 )
*********************************
LOCAL L, C, A, B, W, D, T
T := SAVESCREEN( L1, C1, L2, C2 )
A := L1
B := C1
W := L2
D := C2

WHILE .T.
   L := L1
   FOR C := C1 TO C2
       @ L, C SAY ' '
   NEXT

   C := C2
   FOR L := L1 TO L2
       @ L, C SAY ' '
   NEXT

   L := L2
   FOR C := C2 TO C1 STEP -1
       @ L, C SAY ' '
   NEXT

   C :=  C1
   FOR L := L2 TO L1 STEP -1
       @ L, C SAY ' '
   NEXT

   L1++
   C1++
   L2--
   C2--
   IF L2 <= L1 .OR. C2 <= C1
      EXIT
   END
END

SCROLL( A, B, W, D )

RETURN T

*******************************
FUNCTION PASSWORD( nL, nC, nQ )
*******************************
LOCAL nP, nCodi, aSenha := {}, nII, cRet, nCurs

nCurs := SETCURSOR( 3 )
FOR nII := 1 TO nQ
    AADD( aSenha, ' ' )
NEXT

@ nL, nC SAY SPACE( nQ )
nP := 1
nC--
WHILE .T.
   @ nL,nC+nP SAY ''
   nCodi := INKEY( 0 )

   IF     nCodi == 0
          LOOP

   ELSEIF nCodi == K_BS .AND. nP > 1
      nP--
      aSenha[ nP ] := ' '
      @ nL, nC+nP SAY ' '
      LOOP

   ELSEIF nCodi == K_BS .AND. nP == 1
      LOOP

   ELSEIF nCodi == K_ENTER
      EXIT

   ELSEIF nCodi > 32 .AND. nCodi < 127
      aSenha[ nP ] := CHR( nCodi )
      @ nL, nC+nP SAY 'þ'
      nP++
      IF nP > nQ ; EXIT ; END

   END
END
cRet := ''
FOR nII = 1 TO nP-1
   cRet += aSenha[ nII ]
NEXT
SETCURSOR( nCurs )
RETURN cRet



*************************
PROCEDURE REPTELA( cArq )
*************************
LOCAL cTela, nCursor

cTela := SaveScreen( 0, 0, MaxRow(), MaxCol() )
nCursor := SetCursor( 3 )

//MemoEdit( MemoRead( cArq ), 4, 1, MaxRow()-3, MaxCol()-1, FALSE,,200 )
ShowTime()
RUN( 'LIST ' + cArq )
ShowTime( MaxRow()-1, MaxCol()-8,, SETCORES(1) )

RestScreen( 0, 0, MaxRow(), MaxCol(), cTela )
SetCursor( nCursor )

RETURN















**************************
FUNCTION EXTENSO( nValor )
**************************
LOCAL cExt := '', cMilhao, cMilhar, cCentena, cCentavo, cValor,;
      cBls := { 'Real','Mil','Milhao' } ,;
      cBlp := { 'Reais','Mil','Milhoes' }
      
cValor   := StrZero( nValor, 12, 2 )
cMilhao  := SubStr(  cValor,  1, 3 )
cMilhar  := SubStr(  cValor,  4, 3 )
cCentena := SubStr(  cValor,  7, 3 )
cCentavo := "0"+SubStr(  cValor, 11, 2 )

IF Val( cMilhao ) > 0
   cExt := EXTE( cMilhao ) + If( Val( cMilhao ) > 1, cBlp[ 3 ], cBls[ 3 ] )
END
   
IF Val( cMilhar ) > 0
   IF Val( cMilhao ) > 0 ; cExt += ", " ; END
   cExt += EXTE( cMilhar ) + If( Val( cMilhar ) > 1, cBlp[ 2 ], cBls[ 2 ] )
END

IF Val( cMilhao ) > 0 .OR. Val( cMilhar ) > 0
   IF Val( cCentena ) == 0
      IF Val( cMilhar ) == 0
         cExt += " de Reais"
      ELSE
         cExt += " Reais"
      END
   END
END

IF Val( cCentena ) > 0
   IF Val( cMilhao ) > 0 .OR. Val( cMilhar ) > 0 ; cExt += ", " ; END
   cExt += EXTE( cCentena ) + If( Val( cCentena ) > 1, cBlp[ 1 ] , cBls[ 1 ]  )
END

IF Val( cCentavo ) > 0
   IF Val( cMilhao ) > 0 .OR. Val( cMilhar ) > 0  .OR. Val( cCentena ) > 0 
      cExt += " e " 
   END
   cExt += EXTE( cCentavo ) + If( Val( cCentavo ) > 1,"Centavos", "Centavo" )
END

RETURN cExt



***********************
FUNCTION EXTE( cValor )
***********************
LOCAL cRet := '', nValor,;
cCen := { 'Cento','Duzentos','Trezentos','Quatrocentos','Quinhentos',;
          'Seiscentos','Setecentos','Oitocentos','Novecentos' } ,;
cDzt := { 'Dez','Onze','Doze','Treze','Quatorze','Quinze','Dezesseis' ,;
          'Dezessete','Dezoito','Dezenove' } ,;
cDez := { 'Dez','Vinte','Trinta','Quarenta','Cinquenta','Sessenta',;
          'Setenta','Oitenta','Noventa' } ,;
cUni := { 'Um','Dois','Tres','Quatro','Cinco','Seis','Sete','Oito',;
          'Nove','Dez' }

nValor := Val( SubStr( cValor, 1, 1 ) )
IF nValor > 0
   IF nValor == 1
      cRet += If( Val( SubStr( cValor, 2, 2 ) ) == 0, "Cem", cCen[ nValor ] )
   ELSE
      cRet += cCen[ nValor ]
   END
END

nValor := Val( SubStr( cValor, 2, 2 ) )
IF nValor > 9 .AND. nValor < 20
   nValor -= 9
   IF Val( SubStr( cValor, 1, 1 ) ) > 0
      cRet += " e "
   END
   cRet += cDzt[ nValor ]
ELSE
   nValor := Val( SubStr( cValor, 2, 1 ) )
   IF nValor > 0
      IF Val( SubStr( cValor, 1, 1 ) ) > 0
         cRet += " e "
      END
      cRet += cDez[ nValor ]
   END
   nValor := Val( SubStr( cValor, 3, 1 ) )
   IF nValor > 0
      IF Val( SubStr( cValor, 1, 1 ) ) > 0 .OR. Val( SubStr( cValor, 2, 1 ) ) > 0
         cRet += " e "
      END
      cRet += cUni[ nValor ]
   END
END
RETURN cRet + " "


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



PROCEDURE ScreenSaver()
LOCAL cTela, nLinha, nColuna, cCor, nCur,;
      cScreen, nL, nC, nLin, nCol

STATIC aMat
IF aMat == Nil
   aMat := { '                                                        ' ,;
             '                                 Ü    Ü                 ' ,;
             '                              ÜÛÛ  ÜÛß                  ' ,;
             '             Ü              ÛÛÛÛÛ ÛÛÛ     ÛÜ            ' ,;
             '           ÜÛ            ÜÛÛÛ ÛÛÛ ÛÛ   ÜÜßÛÛÛÛÜÜ        ' ,;
             '       ÜÜÛÛÛ         ÜÜÛÛÜßÛÛÛ ÛÛÜßÛ  ÜÜÜÛÛÛÛÜÜÛÛÛÛ     ' ,;
             '  ßÛÛßßÜÛßÛ      ÜÜÛÛÛÜßÛÛÛÜßÛÛ ÛÛÜß ÜÜÜÛÛÛÛßÛÛßßß ßßß  ' ,;
             '     ÜÛß  ßÛÜ ßßÛÛÛÛÛÛÛÛÜßßÛÛÜÛÛÜßÜÛ ÜÛÛÛÛÛ             ' ,;
             '   ÜÛß            ßßßÛÛÛÛÛÛÜÜßßÛÛÛÜßÛÜßÛÛÛÛÜ       Üß   ' ,;
             '  ÜÛß               ÜÜÜÜÜÜßßßßÛÜÜÛÛÛÜÛÛÜÛÛÛÛ       ÛÜß  ' ,;
             '  ÛÛ            ÜÜÛÛÛÛÛÛÛÛÛÛÛÛÜÜÜÜßßßÛÛÛÛÛÛß      ÜÛß   ' ,;
             '   ÛÛÜ        ÜÛÛßÛÛÛÛÛÛßÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛßÜÜÜÜÜÛÛÛÛÜ   ' ,;
             '    ßßÛÛÜÜÜÜÜÛßß ÛÛÛÛÛÛßÜßßßÛÛÛÛ ÛÛÛÛÛÛÛßÜÛÛÛÛßßß   ßß  ' ,;
             '         ßßß    ÛÛÛÛßßÜß         ÛÛÛßß     ßß           ' ,;
             '              ÜÛÛÛßÜÛß          ÛÛß                     ' ,;
             '             ÛÛÛ  ÛÛ           ÛÛÛ                      ' ,;
             '             ßÛÛÜÜßÛÜ          ßÛÛÜÜ                    ' ,;
             '              ß ß ßß ßß         ß ß ßß                  ' ,;
             PadC( AUMENTA( M->cNomeP ), 56 ) }

END
SAVE SCREEN TO cTela
cCor := SetColor( "W+/N" )
nCur := SetCursor( SC_NONE )
nLin := Row()
nCol := Col()
CLS

FOR nLinha := 1 TO 19
    @ nLinha-1, 0 SAY aMat[ nLinha ]
NEXT
@ nLinha-1, 0 SAY aMat[ 1 ]

nLinha := nColuna := 0
nL := nC := 1
cScreen := SaveScreen( 0, 0, 20, 56 )

WHILE InKey(.1) == 0
   RestScreen( nLinha, nColuna, nLinha+20, nColuna+56, cScreen )
   nLinha  += nL
   nColuna += nC
   IF nLinha > 4 ; nL := -1 ; END
   IF nLinha < 1 ; nL :=  1 ; END
   IF nColuna < 1 ; nC :=  1 ; END
   IF nColuna > 22 ; nC := -1 ; END
END

REST SCREEN FROM cTela
SetColor( cCor )
SetCursor( nCur )
SetPos( nLin, nCol )
RETURN





********************
PROCEDURE ScrSaver()
********************
LOCAL cTela, nLin, nCol, cCor, nCur,;
      aMat, aCar, nII, nL, nC
      
SAVE SCREEN TO cTela
cCor := SetColor( "R+/N" )
nCur := SetCursor( SC_NONE )
nLin := Row()
nCol := Col()
Scroll( 0, 0, 24, 0 )
Scroll( 0, 79, 24, 79 )

aMat := { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 },; 
          { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } }
aCar := { ' A ', ' L ', ' V ', ' O ', ' R ', ' A ', ' D ', ' A ', '   ' }

nL := nC := 1

WHILE InKey(.1) == 0
   FOR nII := 1 TO 9
       @ aMat[ nII, 1 ], aMat[ nII, 2 ] SAY aCar[ nII ]
   NEXT
   FOR nII := 9 TO 2 STEP -1
       aMat[ nII, 1 ] := aMat[ nII-1, 1 ]
       aMat[ nII, 2 ] := aMat[ nII-1, 2 ]
   NEXT
   aMat[ 1, 1 ] += nL
   aMat[ 1, 2 ] += nC
   IF aMat[ 1, 1 ] > 23 ; nL := -1 ; END
   IF aMat[ 1, 1 ] < 1 ; nL :=  1 ; END
   IF aMat[ 1, 2 ] < 1 ; nC :=  1 ; END
   IF aMat[ 1, 2 ] > 76 ; nC := -1 ; END

   IF aMat[ 1, 1 ] > 10 .AND. aMat[ 1, 1 ] < 20 .AND. aMat[ 1, 2 ] = 40
      nC *= -1
   END
   
   IF aMat[ 1, 1 ] = 10 .AND. aMat[ 1, 2 ] > 20 .AND. aMat[ 1, 2 ] < 40
      nL *= -1
   END
   
END
REST SCREEN FROM cTela
SetColor( cCor )
SetCursor( nCur )
SetPos( nLin, nCol )
RETURN

FUNCTION AGORA()
RETURN 'Data: ' + DTOC( DATE() ) + ' - Hora: ' + TIME()

/***

   End FUNCOES.prg

***/
