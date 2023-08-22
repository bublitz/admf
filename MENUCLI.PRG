/***************

PROGRAMA: MENUCLI.prg

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'InKey.ch'
#include 'SetCurs.ch'
#include "Combo.ch"

**********************
PROCEDURE MENUCLIENT()
**********************
LOCAL cTela, nOpcao, cCor

cCor := SetColor( SETCORES( 3 ) )
cTela := ABRE2( 10, 20, 14, 35, TRUE )

WHILE TRUE
   FMENS('Use as Setas '+CHR(24)+' e '+CHR(25)+'.    F1=Help')
   @ 11, 22 PROMPT "1. F¡sica   "
   @ 13, 22 PROMPT "2. Jur¡dica "

   MENU TO nOpcao

   IF     nOpcao == 0
          EXIT

   ELSEIF nOpcao == 1
          Clientes()

   ELSEIF nOpcao == 2
          Empresas()

   END

END

FECHA2( cTela )

SetColor ( cCor )

RETURN

