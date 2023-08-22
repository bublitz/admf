/***
* Combo.prg
*
* Implementation of combo box.
*
* Compile with:
*
*   Clipper Combo /m /n /w
*
* Link with Combotst for test version.
*/

#include "Getexit.ch"
#include "InKey.ch"
#include "Combodef.ch"

// Create Get object with reader implementing Combo box. aChoices
// has the elements to choose from.
FUNCTION ComboGetNew(bVar, cVar, aChoices, bValid, cPic, bWhen, cColor )

LOCAL nTop
LOCAL nLeft
LOCAL nBottom
LOCAL nRight
LOCAL i
LOCAL nLongest
LOCAL oGet

  oGet := GetNew(Row(), Col(), bVar, cVar, cPic, cColor )
  oGet:cargo := Array(COMBO_NUM_IVARS)

  IF !bValid = Nil
     oGet:postBlock := bValid
  END
  
  IF !bWhen = Nil
     oGet:preBlock := bWhen
  END
  
  nTop    := oGet:row + 1
  nLeft   := oGet:col + 1
  nBottom := Min(MaxRow(), nTop + Len(aChoices) + 1)

  IF nBottom - nTop < 2
    nTop := nBottom - 2
  ENDIF

  nLongest := 0
  FOR i := 1 TO Len(aChoices)
    IF Len(aChoices[i]) > nLongest
      nLongest := Len(aChoices[i])
    ENDIF
  NEXT
  nRight := Min(MaxCol(), nLeft + nLongest + 1)

  IF (nRight - nLeft - 1) < nLongest
    nLeft := nRight - nLongest - 1
  ENDIF

  oGet:comboItems  := aChoices
  oGet:comboTop    := nTop
  oGet:comboLeft   := nLeft
  oGet:comboBottom := nBottom
  oGet:comboRight  := nRight
  oGet:reader     := {|o| ComboReader(o) }

//  oGet:varPut(Pad(oGet:varGet(), nLongest))
  oGet:varPut(Pad(oGet:varGet(), Len(oGet:varGet())))
  oGet:display()

  @ oGet:row, oGet:col + Len(oGet:varGet()) SAY Chr(25)

RETURN oGet


// The reader for the combo box
Proc ComboReader( oGet )

  // read the GET if the WHEN condition is satisfied
  IF ( GetPreValidate(oGet) )
    // activate the GET for reading
    oGet:SetFocus()

    DO WHILE ( oGet:exitState == GE_NOEXIT )
      // check for initial typeout (no editable positions)
      IF ( oGet:typeOut )
        oGet:exitState := GE_ENTER
      ENDIF

      // apply keystrokes until exit
      DO WHILE ( oGet:exitState == GE_NOEXIT )
        ComboApplyKey(oGet, InKey(0))
      ENDDO

      // disallow exit if the VALID condition is not satisfied
      IF ( !GetPostValidate(oGet) )
        oGet:exitState := GE_NOEXIT
      ENDIF
    ENDDO

    // de-activate the GET
    oGet:KillFocus()
  ENDIF

RETURN


PROC ComboApplyKey(oGet, nKey)

  IF nKey == K_DOWN
    comboBox(oGet)
  ELSE
    GetApplyKey(oGet, nKey)
  ENDIF

RETURN


FUNCTION comboBox(oGet)

LOCAL nTop    := oGet:comboTop, nLeft   := oGet:comboLeft
LOCAL nBottom := oGet:comboBottom, nRight  := oGet:comboRight
LOCAL cSaveScr, cChoice, nChoice
LOCAL cCurrentChoice := oGet:buffer

// N.B. Inexact comparison here ...
LOCAL nStartChoice := Ascan(oGet:comboItems, ;
                      {|c| Upper(c) = upper(Trim(cCurrentChoice)) } )
LOCAL nSaveRow := Row(), nSaveCol := Col()

  cSaveScr := SaveScreen(nTop, nLeft, nBottom, nRight)
  @ nTop, nLeft CLEAR TO nBottom, nRight
  @ nTop, nLeft TO nBottom, nRight
  nChoice := Achoice(nTop + 1, nLeft + 1, nBottom - 1, nRight - 1, ;
                     oGet:comboItems, NIL, NIL, nStartChoice)

  RestScreen(nTop, nLeft, nBottom, nRight, cSaveScr)
  DevPos(nSaveRow, nSaveCol)

  IF nChoice > 0
    // Item was selected, update real variable
    cChoice := oGet:comboItems[nChoice]
//    oGet:varPut(Pad(cChoice, Len(cCurrentChoice)))
    oGet:varPut(Pad(cChoice, Len(oGet:varGet()) ))
    oGet:updateBuffer()
    oGet:changed := .T.
  ENDIF

RETURN NIL
