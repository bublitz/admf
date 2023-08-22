/***************

PROGRAMA: MENURELE.prg

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'

**********************
PROCEDURE RELESTOQUE()
**********************
LOCAL cTela, nOpcao, cCor

cCor := SetColor( SETCORES(3) )
cTela := ABRE2( 11, 30, 19, 55, TRUE )

WHILE TRUE
   FMENS('Use as Setas '+CHR(24)+' e '+CHR(25)+'.    F1=Help')
   @ 12, 32  PROMPT "1. Caminhoes - Venda  "
   @ 14, 32  PROMPT "2. Caminhoes - Compra "
   @ 16, 32  PROMPT "3. Venda X Compra     "
   @ 18, 32  PROMPT "4. Vendas             "
   MENU TO nOpcao

   IF     nOpcao == 0
          EXIT

   ELSEIF nOpcao == 1 ; RepCamVend()
   ELSEIF nOpcao == 2 ; RepCamComp()
   ELSEIF nOpcao == 3 ; RepCaminhao()
   ELSEIF nOpcao == 4 
   END

END

FECHA2( cTela )

SetColor( cCor )

RETURN
              
/****

  FIM MENUREL.PRG

****/  
