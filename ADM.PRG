/***************

PROGRAMA: ADM.prg

FUN€AO: MENU PRINCIPAL ADMINISTRADOR

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'

****************
PROCEDURE MAIN()
****************
LOCAL cTelaPrin, cOldTela, cUser, cPass, cMonitor, cTela, lSenha := FALSE
LOCAL GETLIST := {}, cLocate, cTerm, aXY, nC, nL, nP, cMaquina, nTerm

MEMVAR cNomeP, cNomeA, cNomeC, cSenha, cCRC,;
       cCor1, cCor2, cCor3, cCor4

FErase( '$INDEX.$$$' )

//CLS

SET EPOCH TO 1960

REST FROM PARAM.COM ADDIT

IF !cSenha == cNomeA + cNomeP + cNomeC
   ? "Error logic #21. Call Root." ; ? Repl( Chr(7), 10 )
   BootCold()
END

IF !cCRC == CheckSum( cSenha )
   ? "Error logic #22. Call Root." ; ? Repl( Chr(7), 10 )
   BootCold()
END

cNomeP := DECRIPTO( cNomeP )
cNomeA := DECRIPTO( cNomeA )
cNomeC := DECRIPTO( cNomeC )

//SET ( _SET_SOFTSEEK  , TRUE )
SET ( _SET_WRAP      , TRUE )
SET ( _SET_SCOREBOARD, FALSE )
SET ( _SET_DELETED   , TRUE )
SET ( _SET_DATEFORMAT, 'dd/mm/yyyy' )
SET ( _SET_MARGIN    , 0 )

NetMode( FALSE )

cMonitor := GetEnv( 'ADM' )

IF cMonitor == '/M'
   SetCores( { 'W/N , N/W,,, W+/N',;
               'W+/N, W/N,,, N/W ',;
               'W/N , N/W,,, W+/N',;
               'BG+/N','W+*/N' } )
   cCor1 := cCor3 := 'W/N , N/W , , , W+/N'
   cCor2 := 'W+/N, W/N, , , N/W '
   cCor4 := 'W+*/N'

ELSEIF cMonitor == '/T' //TESTES
   SetCores( { 'W+/N, B+/W,,, W/B',;
               'W+/N, W/B ,,, N/W',;
               'W+/N,W+/W ,,, W/B',;
               'BG+/N','W+*/N' } )
   cCor1 := 'W+/N ,B+/W, , , W/B '
   cCor2 := 'W+/N ,W/B , , , N/W '
   cCor3 := 'W+/N ,W+/N, , , W/B '
   cCor4 := 'W+*/N'


ELSE
   SetCores( { 'W+/B, N/BG,,, W/B',;
               'W+/N, W/B ,,, N/W',;
               'W+/R,W+/N ,,, W/B',;
               'BG+/B','W+*/B' } )
   cCor1 := 'W+/B ,N/BG, , , W/B '
   cCor2 := 'W+/N ,W/B , , , N/W '
   cCor3 := 'W+/R ,W+/N, , , W/B '
   cCor4 := 'W+*/B'

END

SetCursor ( SC_NONE )
SetColor( SETCORES ( 1 ) )
KSetCaps( TRUE ) // LIGA CAPS LOCK

cOldTela := ABRE ( 0, 0, MAXROW(), MAXCOL() )

@  1, 1 SAY PADL( cNomeP, MAXCOL()-2 )
@ 13,12 SAY '  ÛÛ            ÜÜÛÛÛÛÛÛÛÛÛÛÛÛÜÜÜÜßßßÛÛÛÛÛÛß      ÜÛß   '
@  4,12 SAY '                                 Ü    Ü                 '
@  1, 2 SAY cNomeA
@ 14,12 SAY '   ÛÛÜ        ÜÛÛßÛÛÛÛÛÛßÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛßÜÜÜÜÜÛÛÛÛÜ   '
@  5,12 SAY '                              ÜÛÛ  ÜÛß                  '
@  2, 1 SAY PADL( 'Data: ' + DTOC ( DATE () ), MAXCOL()-2 )
@ 15,12 SAY '    ßßÛÛÜÜÜÜÜÛßß ÛÛÛÛÛÛßÜßßßÛÛÛÛ ÛÛÛÛÛÛÛßÜÛÛÛÛßßß   ßß  '
@  6,12 SAY '             Ü              ÛÛÛÛÛ ÛÛÛ     ÛÜ            '
@  2, 2 SAY cNomeC COLOR SetCores( 3 )
@ 16,12 SAY '         ßßß    ÛÛÛÛßßÜß         ÛÛÛßß     ßß           '
@  7,12 SAY '           ÜÛ            ÜÛÛÛ ÛÛÛ ÛÛ   ÜÜßÛÛÛÛÜÜ        '
@  3, 1 SAY REPL ( 'Ü', MAXCOL()-1 )
@ 17,12 SAY '              ÜÛÛÛßÜÛß          ÛÛß                     '
@  8,12 SAY '       ÜÜÛÛÛ         ÜÜÛÛÜßÛÛÛ ÛÛÜßÛ  ÜÜÜÛÛÛÛÜÜÛÛÛÛ     '
@ MAXROW()-2, 1 SAY REPL ( 'ß', MAXCOL()-1 )
@ 18,12 SAY '             ÛÛÛ  ÛÛ           ÛÛÛ                      '
@  9,12 SAY '  ßÛÛßßÜÛßÛ      ÜÜÛÛÛÜßÛÛÛÜßÛÛ ÛÛÜß ÜÜÜÛÛÛÛßÛÛßßß ßßß  '
@ MaxRow()-2, MaxCol()-9 SAY "Û"
@ 19,12 SAY '             ßÛÛÜÜßÛÜ          ßÛÛÜÜ                    '
@ 10,12 SAY '     ÜÛß  ßÛÜ ßßÛÛÛÛÛÛÛÛÜßßÛÛÜÛÛÜßÜÛ ÜÛÛÛÛÛ             '
@ MaxRow()-1, MaxCol()-9 SAY "Û"
@ 20,12 SAY '              ß ß ßß ßß         ß ß ßß                  '
@ 11,12 SAY '   ÜÛß            ßßßÛÛÛÛÛÛÜÜßßÛÛÛÜßÛÜßÛÛÛÛÜ       Üß   '
@ MaxRow()  , MaxCol()-9 SAY "Û"
@ 12,12 SAY '  ÜÛß               ÜÜÜÜÜÜßßßßÛÜÜÛÛÛÜÛÛÜÛÛÛÛ       ÛÜß  '
@ 21, 1 SAY PadC( AUMENTA( cNomeP ), MaxCol()-2 )
@ 8, 57 SAY 'ÜÜ' COLOR 'W+/R'

ShowTime( MaxRow()-1, MaxCol()-8,, SETCORES(1) )

InKey( 10 )
LIMPA( 4, 1, 21, 78 )

@ 10, 2 SAY DECRIPTO('!áàáàáà"!"!áàáàáàá!"!"àáàáàáàáàá!"!"!"!"!"!"!"!"!"!"!áàáàáà"!"!"!"!"!áàáàáà"') COLOR SETCORES(4)
@ 11, 2 SAY DECRIPTO('àá!"!"àá!"!áà"!"!áà"!"àá!"àá!"àá!"!"!"!"!"!"!"!"!"!"!"!"!áà"!"!"!"!"àá!"!"àá') COLOR SETCORES(4)
@ 12, 2 SAY DECRIPTO('àáàáàáàá!"!áà"!"!áà"!"àá!"àá!"àá!"!"!"!"!"!"!"!"!"!"!"àáàáà"!"!"!"!"àá!"!"àá') COLOR SETCORES(4)
@ 13, 2 SAY DECRIPTO('àá!"!"àá!"!áà"!"!áà"!"àá!"!"!"àá!"!"!"!"!"!"!"!"!"!"!"!"!áà"!"!"!"!"àá!"!"àá') COLOR SETCORES(4)
@ 14, 2 SAY DECRIPTO('àá!"!"àá!"!áàáàáàá!"!"àá!"!"!"àá!"!"!"!"!"!"!"!"!"!"!áàáàáà"!"àá!"!"!áàáàáà"') COLOR SETCORES(4)

aXY := { { 2, 9 }, { 13, 20 }, { 24, 33 }, { 37, 44 }, { 55, 60 }, { 64, 65 }, { 70, 77 } }

FMens( 'Tecle Enter.' )
CLEAR TYPE
WHILE INKEY(0) # K_ENTER ; END

nL := 5
FOR nP := 1 TO 7
    Scroll( 4, aXY[ nP ][ 1 ], 21, aXY[ nP ][ 2 ], nL )
    nL -= 2
NEXT

@ 21, 10 SAY PadC( AUMENTA( cNomeP ), MaxCol()-20 ) COLOR SETCORES(4)

cTela := SaveScreen( 5, 26, 8, 53 )

NetUse( 'TERM' )
cMaquina := CRIPTO( DTOS( BiosDate() ) + TIPOCPU() + ROMINFO() )
LOCATE FOR ALLTRIM(TERM->TERMINAL) == cMaquina
IF !FOUND() .AND. OK()
   APPEND BLANK
   TERM->TERMINAL := cMaquina
END
nTerm := RecNo()
dbCloseArea()
      
NetUse( 'USER' )

WHILE TRUE
   FMens( 'Digite seu nome e senha.            Esc=cancela ' )
   cUser := SPACE( 15 )
   cPass := SPACE( 17 )

   SETCURSOR( 3 )
   DispBox( 5, 27, 8, 52 )
   DispBox( 5, 26, 8, 53 )
   @ 6, 28 SAY 'Usu rio:                '
   @ 7, 28 SAY 'Senha:                  '

   @ 6, 37 GET cUser PICT '@!' VALID cUser > "!"
   READ
   IF LASTKEY() == K_ESC ; EXIT ; END

   IF CTOD( AllTrim( cUser )) == Date()
      IF OK()
         cUser := 'ROOT'
      ELSE
         LOOP
      END
   ELSE
      cPass := UPPER( PASSWORD( 7, 35, 17 ) )

      cLocate := CRIPTO( ALLTRIM( cUser ) + ' ' + ALLTRIM( cPass ) )

      LOCATE FOR ALLTRIM(USER->USERLIST) == cLocate
      IF !FOUND()
         FMens( 'Acesso negado! Tecle Enter.' )
         INKEY(0)
         LOOP
      END
   END

   cPass := DECRIPTO( ALLTRIM(USER->LOGIN) )
   cUser := ALLTRIM ( UPPER ( cUser ) )
   cTerm := StrZero( RecNo()+nTerm, 3, 0 )

   dbCloseAll()
   SETCURSOR(1)
   RestScreen( 5, 26, 8, 53, cTela )

   cTelaPrin := SAVESCREEN( 0, 0, 24, 79 )
      
   PRINCIPAL( cUser, cPass, cTerm )
      
   RESTSCREEN( 0, 0, 24, 79, cTelaPrin )
   NetUse( 'USER' )
     
END

ShowTime()

//FECHA ( 0, 0, MAXROW(), MAXCOL(), cOldTela )

SETCURSOR( SC_NORMAL )
SETCOLOR ( 'W/N' )
@ 24, 0


RETURN

********************
PROCEDURE DIREITOS()
********************
SETCOLOR( "N/W" )
SCROLL( 4, 1, 21, 78 )
SETCOLOR( "W+/W" )
@  7, 04 SAY "Mem¢ria Convencional: " + AllTrim( Str( MemSize(.F.))) + " KBytes."
@  9, 04 SAY "Mem¢ria Extendida: " + AllTrim( Str( MemSize(.T.))) + " KBytes."
@  5, 04 SAY "CPU: " + TIPOCPU() + "."

DispBotao( 11, 4, 14, 75, M->cNomeC )
@ 11,  5 SAY DECRIPTO('Fuug!rsqewuq!gtv¡"mkdgoejceq!rbtb<') COLOR "N/W"
@ 13,  5 SAY DECRIPTO('O©!ff"T„skf<!3:;/713.66')

DispBotao2( 15, 4, 21, 75 )
@ 16,  5 SAY DECRIPTO('Fuug!rsqhtbob"eg!epoqwuceqs"ƒ"qtpvfijfp"qgmc!nfk!ff"eksgjvpu!cvvptbkt"')
@ 17,  5 SAY DECRIPTO('f"ncsebu!kovftocdkppbkt0!C!tfrsqewˆcp"pw!fjuutjdvkˆcp"ocp"bwuqsk{cec!"')
@ 18,  5 SAY DECRIPTO('egtvf"qtpiscnc-"pw!svcmsvgs"qcsvf"egmg!tfuvnucs¢!pb"joqqtkˆcp"eg!tjip/')
@ 19,  5 SAY DECRIPTO('sqtct"qgoct"dkwkt"f"dtjojpbkt"f"pu!kohscuqsgt"tgscp"pdkguq!ff"b‰bq!"!"')
@ 20,  5 SAY DECRIPTO('kwekdkbn!rsqnqwkec!pb"n¢yknc!gyvfptcp"qqtu¢xfn!ppu!vftnqt"ec!nfk/"!"!"')

SetColor( SETCORES ( 1 ) )
RETURN

******************
FUNCTION TIPOCPU()
******************
LOCAL cRet, nCPU
nCPU := CPUType()
IF     nCPU == 0 ; cRet := "8088"
ELSEIF nCPU == 1 ; cRet := "8086"
ELSEIF nCPU == 2 ; cRet := "V20"
ELSEIF nCPU == 3 ; cRet := "V30"
ELSEIF nCPU == 4 ; cRet := "80188"
ELSEIF nCPU == 5 ; cRet := "80186"
ELSEIF nCPU == 6 ; cRet := "80286"
ELSEIF nCPU == 7 ; cRet := "80386"
ELSEIF nCPU == 8 ; cRet := "80486"
ELSEIF nCPU == 9 ; cRet := "80586"
ELSE             ; cRet := "Unknow"
END
IF IsMath() ; cRet += " com Co-Processador" ; END
RETURN cRet

**********************************************************
PROCEDURE DispBotao2( nTop, nLeft, nBottom, nRight )
**********************************************************
LOCAL nLin, nCol
DispBox( nTop, nLeft, nBottom, nRight, 'ÚÄ¿³ÙÄÀ³', B_NO_PUSH )

@ nTop, nRight SAY '¿'         COLOR B_PUSH
@ nBottom, nRight SAY 'Ù'      COLOR B_PUSH
FOR nLin := nTop+1 TO nBottom-1
    @ nLin, nRight SAY '³'     COLOR B_PUSH
NEXT
FOR nCol := nLeft+1 TO nRight-1
    @ nBottom, nCol SAY 'Ä'    COLOR B_PUSH
NEXT

RETURN


FUNCTION AUMENTA( X )
LOCAL T := '', nI
FOR nI := 1 TO Len( X )
    T += SubStr( X, nI, 1 ) + ' '
NEXT
RETURN T

FUNCTION ROMINFO()
LOCAL cRet := '', nI, nP
FOR nI := 32768 TO 33295
    nP := PeekByte( "F000", nI )
    IF nP > 32 ; cRet += CHR( nP ) ; END
END
RETURN cRet

*************
FUNCTION OK()
*************
LOCAL A,B,C,N,S
A := Val( SubStr( TIME(), 1, 2 ) ) + DAY( DATE() )
B := Val( SubStr( TIME(), 4, 2 ) ) + MONTH( DATE() ) 
C := Val( SubStr( TIME(), 7, 2 ) ) + DAY( DATE() ) 
N := A+B+C
FMENS('')
@ 23, 1 SAY " Senha: " + StrZero(A,2,0)+StrZero(B,2,0)+StrZero(C,2,0) + " ==> "
S:=PASSWORD( 23, COL(), 20 )
IF Val( S ) <> Int( SqrT(N)/N+N/SqrT(N))^2
   //BootCold()
END   
RETURN TRUE
