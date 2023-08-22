/***************

PROGRAMA: MENUREL.prg

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'

*********************
PROCEDURE MENURELAT()
*********************
LOCAL cTela, nOpcao, cCor

cCor := SetColor( SETCORES( 3 ))
cTela := ABRE2(  5, 15, 17, 39, TRUE )

WHILE TRUE

   FMENS('Use as Setas '+CHR(24)+' e '+CHR(25)+'.    F1=Help')

   @  6, 17 PROMPT "1. Contas a Pagar    "
   @  7, 17 PROMPT "2. Contas a Receber  "
   @  8, 17 PROMPT "3. Extrato Banco     "
   @  9, 17 PROMPT "4. Movimento Caixa   "
   @ 10, 17 PROMPT "5. Caixa Mensal      "
   @ 11, 17 PROMPT "6. ...............   "
   @ 12, 17 PROMPT "7. .............     "
   @ 13, 17 PROMPT "8. ..............    "
   @ 14, 17 PROMPT "9. .............     "
   @ 15, 17 PROMPT "A. ..............    "
   @ 16, 17 PROMPT "B. ..............    "
   MENU TO nOpcao

   IF     nOpcao == 0 ; EXIT

   ELSEIF nOpcao == 1 .AND. 'G'$M->cRight
          ReportPAGAR()

   ELSEIF nOpcao == 2 .AND. 'h'$M->cRight
          ReportRECEB()

   ELSEIF nOpcao == 3 .AND. 'I'$M->cRight
          ReportEXTRATO()

   ELSEIF nOpcao == 4 .AND. 'J'$M->cRight
          ReportCAIXA()

   ELSEIF nOpcao == 5 .AND. 'K'$M->cRight
          ReportCAMEN()

   ELSEIF nOpcao == 7 .AND. 'O'$M->cRight
//          ReportPAGAR()

   ELSEIF nOpcao == 8 .AND. 'O'$M->cRight
//          ReportRECEB()

   ELSEIF nOpcao == 10 .AND. 'Q'$M->cRight
//          ReportEXTRATO()

   ELSEIF nOpcao == 11 .AND. 'R'$M->cRight
//          ReportCAIXA()

   ELSEIF nOpcao == 12 .AND. 'S'$M->cRight
//          RepEMISSAO()

   END

END

FECHA2(  cTela )

SetColor( cCor )

RETURN
              
/****

  FIM MENUREL.PRG

****/  
