/***************

PROGRAMA: MENUMOV.prg

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'

*******************
PROCEDURE MOVIMEN()
*******************
LOCAL cTela, nOpcao, cCor

cCor := SetColor( M->cCor3 )
cTela := ABRE( 11, 20, 17, 39, TRUE )

WHILE TRUE
   FMENS('Use as Setas '+CHR(24)+' e '+CHR(25)+'.    F1=Help')
   @ 12, 22 PROMPT "1. Lan‡amentos  "
   @ 14, 22 PROMPT "2. Gera Faturas "
   @ 16, 22 PROMPT "3. Baixa Faturas"
   MENU TO nOpcao

   IF     nOpcao == 0 ; EXIT
   ELSEIF nOpcao == 1 ; LANCTOSFUN()
   ELSEIF nOpcao == 2 ; FATURAS()
   ELSEIF nOpcao == 3 ; BAIXA()
   END

END

FECHA( 11, 20, 17, 39, cTela, TRUE )

SetColor( cCor )

RETURN
              
/****

  FIM MENUMOV.PRG

****/  
