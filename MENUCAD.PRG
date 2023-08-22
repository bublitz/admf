/***************

PROGRAMA: MENUCAD.prg

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'

*********************
PROCEDURE CADASTROS()
*********************
LOCAL cTela, nOpcao, cCor

cCor := SetColor( M->cCor3 )
cTela := ABRE( 11, 20, 15, 39, TRUE )

WHILE TRUE
   FMENS('Use as Setas '+CHR(24)+' e '+CHR(25)+'.    F1=Help')
   @ 12, 22 PROMPT "1. Funcionarios "
   @ 14, 22 PROMPT "2. Prov/Desc    "
   MENU TO nOpcao

   IF     nOpcao == 0 ; EXIT
   ELSEIF nOpcao == 1 ; FUNCIONARI()
   ELSEIF nOpcao == 2 ; PROVDESC()
   END

END

FECHA( 11, 20, 15, 39, cTela, TRUE )

SetColor( cCor )

RETURN
              
/****

  FIM MENUCAD.PRG

****/  
