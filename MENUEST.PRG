/***************

PROGRAMA: MENUEST.prg

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'

*******************
PROCEDURE ESTOQUE()
*******************
LOCAL cTela, nOpcao, cCor

cCor := SetColor( SETCORES(3) )
cTela := ABRE2( 8, 20, 18, 45, TRUE )

WHILE TRUE
   FMENS('Use as Setas '+CHR(24)+' e '+CHR(25)+'.    F1=Help')
   @  9, 22 PROMPT "1. Tabelas           "
   @ 11, 22 PROMPT "2. Caminhoes - Venda "
   @ 13, 22 PROMPT "3. Caminhoes - Compra"
   @ 15, 22 PROMPT "4. Vendas            "
   @ 17, 22 PROMPT "5. Relatorios        "
   MENU TO nOpcao

   IF     nOpcao == 0 ; EXIT
   ELSEIF nOpcao == 1 ; TABELA()
   ELSEIF nOpcao == 2 ; CAMINHAO( 'V' )
   ELSEIF nOpcao == 3 ; CAMINHAO( 'C' )
   ELSEIF nOpcao == 4 ; CADVENDA()
   ELSEIF nOpcao == 5  .AND. 'S'$M->cRight 
          RelEstoque()
   END

END

FECHA2( cTela )

SetColor( cCor )

RETURN
              
/****

  FIM MENUEST.PRG

****/  
