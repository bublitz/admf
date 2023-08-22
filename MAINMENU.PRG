#include "box.ch"

FUNCTION MAIN()

LOCAL aMenue := { 'Administrativo e Financeiro 3.0',; 
                  'Administra‡ao de Or‡amentos 1.0','Encerra' }

LOCAL nChoice:=1, c

SET SCOREBOARD OFF
SETCOLOR('W/N')
SET CURSOR OFF

?
? 'Drache Main Menu for CA-Clipper 5.2d'
? 'Copyright (c) 1995-96 Drache Inform tica.'
? 'All Rights Reserved'
?
?
MILLISEC(2000)
SET CURSOR ON

SETCOLOR('W+/B,B/W')
CLEARWIN(0,0,MAXROW(),MAXCOL(),'BG/B','±')
@ 0,0,3,MAXCOL() BOX B_SINGLE+' ' COLOR 'B/BG'

@ 1,2 SAY 'Drache Main Menu CA-Clipper, 1996' COLOR 'B/BG'
c=CDOW(DATE())+STR(DAY(DATE()),3)+' '+CMONTH(DATE())+STR(YEAR(DATE()),5)
@ 1,MAXCOL()-LEN(c)-8 SAY c COLOR 'B/BG'
@ 2,2 SAY 'Copyright (c) 1995-96 Drache Inform tica. All Rights Reserved' COLOR 'B/BG'

WHILE nChoice!=0

  frame(10,25,16,55,'Main Menu','RG+/B',.T.,.F.)
  nChoice:=achoice(13,28,15,54,aMenue)
  frame(10,25,16,55,'Main Menu','W+/B',.F.,.F.)

  IF     nChoice == 1
         ErrorLevel(1)
         QUIT
  
  ELSEIF nChoice == 2
         ErrorLevel(2)
         QUIT
  
  ELSE
         ErrorLevel(0)             
         QUIT

  END
  
END

RETURN(NIL)



FUNCTION frame(nTop,nLeft,nBottom,nRight,cText,cColor,lClear,lSec)
  @ nTop,nLeft,nBottom,nRight BOX B_DOUBLE+if(lClear,' ','') COLOR cColor
  @ nTop+2,nLeft SAY CHR(204) COLOR cColor
  @ nTop+2,nRight SAY CHR(185) COLOR cColor
  @ nTop+2,nLeft+1 TO nTop+2,nRight-1 DOUBLE COLOR cColor
  @ nTop+3,nLeft+2 TO nBottom-1,nLeft+2
  @ nTop+1,nLeft+1 SAY PADC(cText,nRight-nLeft-1) COLOR cColor
  IF lSec
    @ nTop+3,nRight-2 TO nBottom-1,nRight-2
  ENDIF
RETURN(NIL)

