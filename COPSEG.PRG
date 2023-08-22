/***************

PROGRAMA: COPSEG.prg

FUNÄAO: COPIA DE SEGURANCA DOS ARQUIVOS
        ELIMINACAO DE DADOS INUTEIS

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'
#include "Directry.ch"

STATIC cDisco := " " 

//                 PkZip -m -bTransf -s4J7o6r0g9e6
STATIC cComan1 := 'Qm[kq".o!/cVscoug".u5L8q7t1i:g7'

******************
PROCEDURE BACKUP()
******************
LOCAL cTela, nCursor, cCor, nOpcao ,;
      aDirectory, cArq,;
      GETLIST := {}

cTela   := SaveScreen ( 0, 0, MaxRow(), MaxCol() )
nCursor := SetCursor( SC_NORMAL )
cCor    := SetColor( SETCORES(2) )

LIMPA( 4, 1, MaxRow()-3, MaxCol()-1 )

@ 5, 1 SAY PADC ( 'BACKUP DOS DADOS', 78 ) ;
       COLOR SETCORES(2)

@ 6, 1 SAY PADC ( 'ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ', 78 ) ;
       COLOR SETCORES(2)

@ 11,29 SAY '⁄ƒƒƒƒø'
@ 12,29 SAY '≥€€€€≥'
@ 13,29 SAY '¿ƒƒƒƒŸ'

@ 11,45 SAY '⁄‹‹‹ø'
@ 12,45 SAY '≥ o ≥'
@ 13,45 SAY '¿ƒ¡ƒŸ'

WHILE .T.
   SETCURSOR( SC_NORMAL )
   @ 12,47 SAY CHR(9)
   @ 12, 35 SAY "          "
   @ 18, 1 SAY SPACE( 78 )
   @ 18, 20 SAY "Em que drive est† o disquete (A ou B) ?" GET cDisco PICT "!" ;
            VALID ( cDisco $ "AB" ) ;
            WHEN FMENS( 'Digite a letra correspondente ao Drive.' )

   READ
   IF LASTKEY() == K_ESC ; EXIT ; END

   SetCursor( SC_NONE )
   @ 18, 1 SAY SPACE( 78 )

   @ 18, 14 SAY 'Insira um disco vazio no drive '+cDisco+' e tecle ENTER.'
   @ 18, 55 SAY 'ENTER' COLOR SETCORES(5)
   FMENS('')
   BEEP()

   INKEY( 0 )

   IF DISKSPACE( IF ( cDisco=="A", 1, 2 ) ) == 0
      ALERT ( "Disquete nao est† Pronto !" ,, SETCORES(1) )
      LOOP
   END

   aDirectory := DIRECTORY( cDisco+":\*.*", "D")
   IF !EMPTY( aDirectory )
      IF ALERT ( "Disquete nao est† Vazio !;;Posso apag†-lo?" ,;
                           {'NAO','SIM'}, SETCORES(1) ) == 2
         AEVAL( aDirectory,{ |aFile| FErase( cDisco+":\" + aFile[F_NAME] ) } )
      ELSE
         LOOP
      END
   END

   @ 18, 1 SAY SPACE( 78 )

   // APAGA ARQUIVOS DO DIRETORIO TRANSF
   aDirectory := DIRECTORY( "TRANSF\*.*", "D")
   IF !EMPTY( aDirectory )
      AEVAL( aDirectory,{|aFile| FErase( "TRANSF\" + aFile[F_NAME] ) } )
   END
   
   // COPIA ARQUIVOS DBF PARA DIRETORIO TRANSF
   aDirectory := DIRECTORY( "*.DBF", "D")
   IF !EMPTY( aDirectory )
      AEVAL( aDirectory,{|aFile| COPIA( aFile[F_NAME] ) } )

      @ 12, 35 SAY "          "
      FMENS( 'AGUARDE... Compactando arquivos...' )
      cArq := DECRIPTO( cComan1 ) + " " + cDisco + ":\ADM300"

      SET ( _SET_CONSOLE, FALSE )
      RUN ( cArq + " TRANSF\*.* > NUL" )
      SET ( _SET_CONSOLE, TRUE )

   END

   // PARABêNS PARA VOCE
   TONE(262,3)
   TONE(262,1)
   TONE(294,6)
   TONE(262,6)
   TONE(349,6)
   TONE(330,15)
   FMENS( 'Terminado... Tecle algo...' )

   INKEY(0)
END

RESTSCREEN ( 0, 0, MAXROW(), MAXCOL(), cTela )
SETCOLOR( cCor )
SETCURSOR( nCursor )
RETURN

****************
PROCEDURE BEEP()
****************
TONE(750,.11)
TONE(135,.2)
TONE(260,.8)
RETURN

***************
FUNCTION SETA()
***************
STATIC nCol := 35
LOCAL nRes
SetPos( 12, nCol )
DispOut( " " + CHR( 16 ) )
nCol++
IF nCol = 44 ; SetPos( 12, nCol ) ; DispOut( " " ) ; nCol := 35 ; END
SetPos( 12, 47 ) ; DispOut( IF ( MOD( nCol, 2 ) == 0, CHR(9), CHR(7) ) )
SetPos( 12, 29 ) 
nRes := MOD( nCol, 4 )
IF     nRes == 0 ; DispOut( '≥€±€€≥' )
ELSEIF nRes == 1 ; DispOut( '≥€€±€≥' )
ELSEIF nRes == 2 ; DispOut( '≥€€€±≥' )
ELSE             ; DispOut( '≥±€€€≥' )
END
RETURN TRUE

************************************
FUNCTION TERMO( LINHA, COLUNA, nII )
************************************
SetPos( LINHA, COLUNA )
DispOut( TRANSF( nII*100/RECCOUNT(), "999" )+" %" )
RETURN .T.

***********************
PROCEDURE COPIA( cArq )
***********************
LOCAL nArea
cArq := MakeAlias( cArq )
FMENS( "Transferindo arquivo: " + cArq )
nArea := Select( cArq )
IF nArea == 0
   USE (cArq) NEW
   COPY TO "TRANSF\"+cArq FOR SETA()
   dbCloseArea()
ELSE
   dbSelectArea( cArq )
   COPY TO "TRANSF\"+cArq FOR SETA()
END
RETURN
