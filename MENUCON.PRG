/***************

PROGRAMA: MENUCON.prg

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'

**********************
PROCEDURE MENUCONTAS()
**********************
LOCAL cTela, nOpcao, cCor

cCor := SetColor( SETCORES( 3 ) )
cTela := ABRE2( 11, 20, 19, 39, TRUE )

WHILE TRUE
   FMENS('Use as Setas '+CHR(24)+' e '+CHR(25)+'.    F1=Help')
   @ 12, 22 PROMPT "1. Fornecedores "
   @ 14, 22 PROMPT "2. Grupos       "
   @ 16, 22 PROMPT "3. Contas Pagar "
   @ 18, 22 PROMPT "4. Ctas Receber "
   MENU TO nOpcao

   IF     nOpcao == 0
          EXIT

   ELSEIF nOpcao == 1 .AND. 'D'$M->cRight
          FORNEC()

   ELSEIF nOpcao == 2 .AND. 'B'$M->cRight
          GRUPOS()

   ELSEIF nOpcao == 3 .AND. 'e'$M->cRight
          PAGAR()

   ELSEIF nOpcao == 4 .AND. 'e'$M->cRight
          RECEBER()

   END

END

FECHA2( cTela )

SetColor ( cCor )

RETURN
              
/****

  FIM MENUCON.PRG

****/  
