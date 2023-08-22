/***************

PROGRAMA: MENUBAN.prg

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'

**********************
PROCEDURE MENUBANCOS()
**********************
LOCAL cTela, nOpcao, cCor

cCor := SetColor( SETCORES( 3 ))
cTela := ABRE( 11, 20, 19, 39, TRUE )

WHILE TRUE
   FMENS('Use as Setas '+CHR(24)+' e '+CHR(25)+'.    F1=Help')
   @ 12, 22 PROMPT "1. Conta Banco  "
   @ 14, 22 PROMPT "2. Caixa        "
   @ 16, 22 PROMPT "3. Lan‡amentos  "
   @ 18, 22 PROMPT "4. Cheques Pr‚  "
   MENU TO nOpcao

   IF     nOpcao == 0
          EXIT

   ELSEIF nOpcao == 1 .AND. '8'$M->cRight
          BANCOS()

   ELSEIF nOpcao == 2 .AND. 'h'$M->cRight
          CAIXA()

   ELSEIF nOpcao == 3 .AND. 'A'$M->cRight
          LANCTOS()

   ELSEIF nOpcao == 4 .AND. '6'$M->cRight
          CHEQUES()

   END

END

FECHA( 11, 20, 19, 39, cTela, TRUE )

SetColor( cCor )

RETURN
              
/****

  FIM MENUBAN.PRG

****/  
