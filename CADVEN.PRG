/***************

   PROGRAMA: CADVEN.prg

   FUN€AO:   CADASTRO DE VENDEDORES

   AUTOR:    Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'InKey.ch'
#include 'SetCurs.ch'
#include "Combo.ch"

**********************
PROCEDURE VENDEDORES()
**********************
LOCAL cTela, cTelaLimpa, cCor,;
      nII, nCursor, GetList := {}, ;
      lInclui, lAchou, nCodigo, cCodigo, nEscolha,;
      cNome

cTela   := SaveScreen ( 0, 0, MaxRow(), MaxCol() )
nCursor := SetCursor( SC_NORMAL )
cCor    := SetColor( SETCORES(2) )

ABRE( 8, 30, 12, 76, TRUE )

TELAVEN()

FMENS('')

SetColor( SETCORES(1) )

cTelaLimpa := SaveScreen ( 0, 0, MaxRow(), MaxCol() )

WHILE .T.

   UNLOCK
   COMMIT
   
   RestScreen ( 0, 0, MaxRow(), MaxCol(), cTelaLimpa )

   SetCursor ( SC_NORMAL )

   nCodigo := 0
   @ 10, 32 GET nCodigo PICT '999' ;
            WHEN FMENS( 'Digite o C¢digo do Vendedor. F4=Vendedores.' )

   READ

   IF LastKey() == K_ESC ; EXIT ; END

   SELE VENDEDOR

   IF nCodigo == 0
      lInclui := TRUE
      GO BOTTOM
      nCodigo := Val( VENDEDOR->CODIGO ) + 1

   ELSE
      lInclui := FALSE

   END

   cCodigo := STRZERO( nCodigo, 3, 0 )

   FMENS('')
   
   @ 10, 32 SAY cCodigo COLOR SETCORES(3)

   SEEK cCodigo

   lAchou := Found()

   IF !lAchou .AND. !lInclui
      IF ATENCAO( 'Codigo Nao Cadastrado!;Deseja Incluir ?',;
                  { 'Sim','Nao' } ) == 2
         LOOP
      ELSE
         lInclui := TRUE
      END
   END

   IF lInclui
      IF !NetAppBlank()
         LOOP
      END
      VENDEDOR->CODIGO := cCodigo
      COMMIT
   ELSE
      IF !NetRLock()
         LOOP
      END
   END

   nII := RecNo()
   cNome       := VENDEDOR->NOME

   IF !lInclui
      @ 10, 40  SAY cNome
      FMENS('')

      nEscolha := ATENCAO( 'Deseja fazer:; ',;
                           {'Alteracao','Exclusao','Volta' },;
                           SETCORES(1) )

      IF nEscolha == 2
         IF '5'$M->cRight
            IF ATENCAO( 'Confirma Exclusao?; ',{'Nao','Sim'}, SETCORES(2) ) == 2
               VENDEDOR->(dbDelete())
               ACAO( 'EXCLUIU VENDEDOR CODIGO ' + cCodigo )
            END
         ELSE
            ATENCAO( 'Acesso nao Permitido!' )
            ACAO( 'TENTOU EXCLUIR VENDEDOR CODIGO ' + cCodigo )
         END
      END

      IF !nEscolha == 1 ; LOOP ; END

   END

   FMENS('')

   @ 10, 40  GET cNome        PICT "@!" VALID cNome >="A"
   READ
   
   VENDEDOR->(dbGoto( nII ))

   IF Lastkey() == K_ESC 
      IF lInclui ; VENDEDOR->(dbDelete()) ; END
      LOOP 
   END

   IF Updated()
      IF ATENCAO( 'Confirma '+IF(lInclui,'INCLUSAO ?','ALTERA€AO ?'), {'Sim','Nao'}, SETCORES(2) ) == 1

         FMENS( 'AGUARDE... Atualizando arquivo...' )
         VENDEDOR->CODIGO      :=  cCodigo
         VENDEDOR->NOME        :=  cNome

         IF lInclui
            ACAO ( 'CADASTROU VENDEDOR CODIGO ' + cCodigo )
         ELSE
            ACAO ( 'ALTEROU VENDEDOR CODIGO ' + cCodigo )
         END
         
      ELSE
         IF lInclui ; VENDEDOR->(dbDelete()) ; END
      END
   ELSE
      IF lInclui ; VENDEDOR->(dbDelete()) ; END
   END
   
END

RestScreen ( 0, 0, MaxRow(), MaxCol(), cTela )
SetColor( cCor )
SetCursor( nCursor )
RETURN

