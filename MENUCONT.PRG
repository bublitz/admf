/***************

PROGRAMA: MENUCONT.prg

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'InKey.ch'
#include 'SetCurs.ch'
#include "Combo.ch"

**********************
PROCEDURE MENUCONTRA()
**********************
LOCAL cTela, nOpcao, cCor

cCor := SetColor( SETCORES( 3 ) )
cTela := ABRE( 09, 20, 13, 39, TRUE )

WHILE TRUE
   FMENS('Use as Setas '+CHR(24)+' e '+CHR(25)+'.    F1=Help')
   @ 10, 22 PROMPT "1. Cadastro     "
   @ 12, 22 PROMPT "2. Usu rios     "

   MENU TO nOpcao

   IF     nOpcao == 0
          EXIT

   ELSEIF nOpcao == 1
          CONTRATOS()

   ELSEIF nOpcao == 2
          USUARIOS() // MAIS ADIANTE

   END

END

FECHA(  9, 20, 13, 39, cTela, TRUE )

SetColor ( cCor )

RETURN

********************
PROCEDURE USUARIOS()
********************
LOCAL cTela, cTelaLimpa, cCor,;
      nCursor, GetList := {}, ;
      nNumero, cNumero, cTipo, nCliente, aTipo,;
      oMyBrowser, oCol1, oCol2, oCol3, oCol4, oCol5, nKey, bFiltro

cTela   := SaveScreen ( 0, 0, MaxRow(), MaxCol() )
nCursor := SetCursor( SC_NORMAL )
cCor    := SetColor( SETCORES(2) )
aTipo   := A_CONTR

LIMPA( 4, 1, MaxRow()-3, MaxCol()-1 )

@  3,  1  SAY PadC( 'CADASTRO DE USUARIOS DE CONTRATOS', 78 ) COLOR 'N/W'

@  4,  2  SAY 'N£mero do Contrato:'
@  4, 34  SAY 'Tipo:'
@  6,  2  SAY 'Cliente:'

FMENS('')

SetColor( SETCORES(1) )

cTelaLimpa := SaveScreen ( 0, 0, MaxRow(), MaxCol() )

/***

  Cria Objeto TBrowse

***/

// TBrowseDB ( nLinha, nColuna, nLinha, nColuna ) -> object
oMyBrowser := TBrowseDB ( 9, 1, MAXROW()-3, MAXCOL()-1 )

// Cores Default         1     2    3    4
oMyBrowser:colorSpec := "W+/N, N/W, N/W, N/W"

oMyBrowser:headSep := "ÄÂÄ"          // Separador de Cabecalho
oMyBrowser:colsep  := " ³ "          // Separador de Colunas

bFiltro := { || USUARIOS->CONTRATO == cNumero }
oMyBrowser:skipBlock := { | nRecords | Skipper( nRecords, bFiltro ) }
oMyBrowser:goBottomBlock := { || GoBottom ( bFiltro ) }
oMyBrowser:goTopBlock    := { || GoTop ( bFiltro ) }

// TBColumnNew ( oCabecalho, bBlocoDeRecuperacaoDeDados ) -> object
oCol1 := TBColumnNew ( "Usu rio " , { || USUARIOS->CLIENTE } )

oCol2 := TBColumnNew ( PADR("Nome", 35),{ || CLIENTES->NOME } )
oCol2:picture := "@!"

// Adiciona colunas ao TBrowser
oMyBrowser:addColumn ( oCol1 )
oMyBrowser:addColumn ( oCol2 )

WHILE TRUE

   UNLOCK
   COMMIT

   SELE USUARIOS
   SET RELATION TO

   RestScreen ( 0, 0, MaxRow(), MaxCol(), cTelaLimpa )

   SetCursor ( SC_NORMAL )

   nNumero := 0
   @  4, 22 GET nNumero PICT '99999999' ;
            WHEN FMENS( 'Digite o N£mero do Contrato.' )

   READ

   IF LastKey() == K_ESC ; EXIT ; END

   SELE CONTRATO
   SET ORDER TO 1

   cNumero := STRZERO( nNumero, 8, 0 )

   FMENS('')

   @  4, 22 SAY cNumero COLOR SETCORES(3)

   SEEK cNumero

   IF !Found()
      ATENCAO( 'Contrato Nao Cadastrado!', { 'Volta' } )
      LOOP
   END

   cTipo        :=  CONTRATO->TIPO
   nCliente     :=  Val( CONTRATO->CLIENTE )

   @  4, 40  SAY  aTipo[ Val( cTipo ) ]
   @  6, 11  SAY  StrZero( nCliente, 8, 0 )
   PESQCLI( nCliente, 6, 20 )

   IF cTipo$'14'
      ATENCAO( 'ESTE TIPO DE CONTRATO;NAO PERMITE USUARIOS!!',{'Volta'} )
      LOOP
   END
   
   SETCURSOR ( SC_NONE )

   SELE USUARIOS
   SET RELATION TO USUARIOS->CLIENTE INTO CLIENTES
   USUARIOS->(dbGoTop())

   Skipper( 0 )
   oMyBrowser:panHome()
   oMyBrowser:refreshAll()

   WHILE TRUE

      UNLOCK
      COMMIT
      
      WHILE ( !oMyBrowser:stabilize () )  
         IF ( nKey := INKEY() ) != 0 ; EXIT ; END
      END

      oMyBrowser:colorRect( { oMyBrowser:rowPos, 1, oMyBrowser:rowPos,; 
                              oMyBrowser:colCount }, { 3, 4 } )

      IF oMyBrowser:stable ()

         WHILE TRUE
            IF ( nKey := INKEY () ) != 0
               EXIT
            END
         END

      END

      IF     nKey == K_ESC 
             EXIT
      
      ELSEIF nKey == K_F1
             HELP( PROCNAME(), PROCLINE(), ;
                   ALLTRIM( oMyBrowser:getColumn( oMyBrowser:colPos ):heading ) )

      ELSEIF nKey == K_UP   ; oMyBrowser:up ()
      ELSEIF nKey == K_DOWN ; oMyBrowser:down ()
      ELSEIF nKey == K_HOME ; oMyBrowser:goTop ()
      ELSEIF nKey == K_END  ; oMyBrowser:goBottom ()
      ELSEIF nKey == K_PGUP ; oMyBrowser:pageUp ()
      ELSEIF nKey == K_PGDN ; oMyBrowser:pageDown ()

      ELSEIF nKey == K_DEL
             IF ATENCAO ( "Confirma exclus„o ?",;
                           {'Nao','Sim'}, SETCORES(1) ) = 2
                NetRLock ( 0 )
                USUARIOS->(dbDelete())
                Skipper(0)
                oMyBrowser:goTop()
                oMyBrowser:refreshAll()
             END

      ELSEIF nKey == K_INS
             NetAppBlank( 0 )
             USUARIOS->CONTRATO := cNumero
             Skipper(0)
             oMyBrowser:refreshAll()
             oMyBrowser:goTop()

      ELSEIF nKey == K_ENTER
             EntryCli ( cTipo, cNumero ) 
             Skipper(0)
             oMyBrowser:refreshAll()

      END
      
      oMyBrowser:refreshCurrent()
      
   END
  
   SELE USUARIOS
   SET RELATION TO
END

SELE USUARIOS
SET RELATION TO

RestScreen ( 0, 0, MaxRow(), MaxCol(), cTela )
SetColor( cCor )
SetCursor( nCursor )

RETURN
              
*****************************
PROCEDURE EntryCli( cNumero )
*****************************
LOCAL cTela, nCli, GETLIST := {}, nCursor, lNovo

cTela := ABRE2( 10, 20, 15, 65, .T. )
nCursor := SetCursor( SC_NORMAL )
nCli := VAL( USUARIOS->CLIENTE )
lNovo := IF( nCli == 0, TRUE, FALSE )

SELE USUARIOS
SET ORDER TO 1
SET RELATION TO

@ 11, 22 SAY "Cliente:"
@ 13, 22 GET nCli PICT "99999999" VALID fPESQCLI( nCli, cNumero, 14, 22, lNovo ) ;
         WHEN FMENS( 'Digite o Codigo do Cliente (Pessoa F¡sica). F2=Clientes.')

READ
IF LastKey() != K_ESC
   SELE USUARIOS
   NetRLock(0)
   USUARIOS->CLIENTE := StrZero( nCli, 8, 0 )
   UNLOCK
END

SELE USUARIOS
SET RELATION TO USUARIOS->CLIENTE INTO CLIENTES

FECHA2( cTela ) 
SetCursor( nCursor )
RETURN




*****************************************************************
STATIC FUNCTION fPESQCLI( nCod, cNumCon, nLinha, nColuna, lNovo )
*****************************************************************
LOCAL lRet, nSele, nReg
   ALTD()
   nSele := Select()
   nReg  := RecNo()

   SELE CLIENTES
   SET ORDER TO 1
   SEEK StrZero( nCod, 8, 0 )
   lRet := FOUND()
   IF lRet ; @ nLinha, nColuna SAY CLIENTES->NOME
   ELSE    ; @ nLinha, nColuna SAY SPACE( 40 )
   END

   IF lRet
      IF Len( AllTrim( CLIENTES->CGCCPF ) ) > 11 // CGC
         lRet := .F.
         ALERT( 'Pessoa Jur¡dica nao pode ser;USUARIO de um Contrato !!',;
             { 'Volta' } )

      END

      IF lRet
         SELE CONTRATO
         SET ORDER TO 2
         SEEK StrZero( nCod, 8, 0 )
         IF Found() .AND. CONTRATO->NUMERO != cNumCon // ACHOU, JA TEM CONTRATO
            ALERT( 'Este Cliente J  Tem Contrato!; ;Contrato N§ '+CONTRATO->NUMERO,;
                { 'Volta' } )
            lRet := FALSE
         END
         SET ORDER TO 1
      END
      
      IF lRet
         SELE USUARIOS
         SET ORDER TO 2
         SEEK StrZero( nCod, 8, 0 )
         IF Found() .AND. USUARIOS->CONTRATO != cNumCon // ACHOU, JA  USUµRIO
            ALERT( 'Este Cliente J  ‚ Usu rio!; ;Contrato N§ '+USUARIOS->CONTRATO,;
                      { 'Volta' } )
            lRet := FALSE
         END
         SET ORDER TO 1
      END
      
   END
         
   Select( nSele )
   dbGoTo( nReg )

RETURN lRet

/****

  FIM MENUCON.PRG

****/  
