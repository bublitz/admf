/*


       TELREP.PRG


*/

******************************
FUNCTION TELAReport( cTitulo )
******************************
LOCAL cTela, nI

cTela := LIMPA( 4, 1, MaxRow()-3, MaxCol()-1 )

@ 5, (MaxCol()-Len(cTitulo))/2 SAY cTitulo COLOR SETCORES(3)

@ 4, 4           TO  MaxRow()-3, 4
@ 4, MaxCol()-4  TO  MaxRow()-3, MaxCol()-4

FOR nI := 4 TO MaxRow()-3 STEP 2
    @ nI, 2           SAY 'o'
    @ nI, MaxCol()-2  SAY 'o'
NEXT

RETURN cTela
