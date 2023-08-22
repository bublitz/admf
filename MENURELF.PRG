/***************

PROGRAMA: MENUREL.prg

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'

*********************
PROCEDURE RELATORIO()
*********************
LOCAL cTela, nOpcao, cCor

cCor := SetColor( M->cCor3 )
cTela := ABRE( 11, 20, 19, 39, TRUE )

WHILE TRUE
   FMENS('Use as Setas '+CHR(24)+' e '+CHR(25)+'.    F1=Help')
   @ 12, 22 PROMPT "1. Funcionarios "
   @ 14, 22 PROMPT "2. Prov/Desctos "
   @ 16, 22 PROMPT "3. Faturas      "
   @ 18, 22 PROMPT "4. Ctas Pagar   "
   MENU TO nOpcao

   IF     nOpcao == 0
          EXIT

   ELSEIF nOpcao == 1 ; RepFUNCIO()
   ELSEIF nOpcao == 2 ; RepPRODES()
   ELSEIF nOpcao == 3 ; RepFATURA()
   ELSEIF nOpcao == 4  .AND. 'T'$M->cRight ; RepPAGAR()
   END

END

FECHA( 11, 20, 19, 39, cTela, TRUE )

SetColor( cCor )

RETURN
              
/****

  FIM MENUREL.PRG

****/  
