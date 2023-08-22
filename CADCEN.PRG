/***************

   PROGRAMA: CADCEN.prg

   FUN€AO:   CADASTRO DE CENTRO DE CUSTO

   AUTOR:    Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'InKey.ch'
#include 'SetCurs.ch'
#include "Combo.ch"

******************
PROCEDURE CCUSTO()
******************
LOCAL cTela, cTelaLimpa, cCor,;
      nII, nCursor, GetList := {}, ;
      lInclui, lAchou, nCodigo, cCodigo, nEscolha,;
      cNome

cTela   := SaveScreen ( 0, 0, MaxRow(), MaxCol() )
nCursor := SetCursor( SC_NORMAL )
cCor    := SetColor( SETCORES(2) )

ABRE( 8, 30, 12, 76, TRUE )

TELACEN()

FMENS('')

SetColor( SETCORES(1) )

cTelaLimpa := SaveScreen ( 0, 0, MaxRow(), MaxCol() )

WHILE .T.

   RestScreen ( 0, 0, MaxRow(), MaxCol(), cTelaLimpa )

   SetCursor ( SC_NORMAL )

   nCodigo := 0
   @ 10, 32 GET nCodigo PICT '999' ;
            WHEN FMENS( 'Digite o C¢digo do Centro de Custo. F6=Centros' )

   READ

   IF LastKey() == K_ESC ; EXIT ; END

   SELE CCUSTO

   IF nCodigo == 0
      lInclui := TRUE
      GO BOTTOM
      nCodigo := Val( CCUSTO->CODIGO ) + 1

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
      CCUSTO->CODIGO := cCodigo
      COMMIT
   ELSE
      IF !NetRLock()
         LOOP
      END
   END

   nII := RecNo()
   cNome       := CCUSTO->NOME

   IF !lInclui
      @ 10, 40  SAY cNome
      FMENS('')

      nEscolha := ATENCAO( 'Deseja fazer:; ',;
                           {'Alteracao','Exclusao','Volta' },;
                           SETCORES(1) )

      IF nEscolha == 2
         IF 'C'$M->cRight
            IF ATENCAO( 'Confirma Exclusao?; ',{'Nao','Sim'}, SETCORES(2) ) == 2
               CCUSTO->(dbDelete())
               ACAO( 'EXCLUIU CENTRO DE CUSTO CODIGO ' + cCodigo )
            END
         ELSE
            ATENCAO( 'Acesso nao Permitido!' )
            ACAO( 'TENTOU EXCLUIR CENTRO DE CUSTO CODIGO ' + cCodigo )
         END
      END

      IF !nEscolha == 1 ; LOOP ; END

   END

   FMENS('')

   @ 10, 40  GET cNome        PICT "@!" VALID cNome >="A"
   READ
   
   CCUSTO->(dbGoto( nII ))

   IF Lastkey() == K_ESC 
      IF lInclui ; CCUSTO->(dbDelete()) ; END
      LOOP 
   END

   IF Updated()
      IF ATENCAO( 'Confirma '+IF(lInclui,'INCLUSAO ?','ALTERA€AO ?'), {'Sim','Nao'}, SETCORES(2) ) == 1

         FMENS( 'AGUARDE... Atualizando arquivo...' )
         CCUSTO->CODIGO      :=  cCodigo
         CCUSTO->NOME        :=  cNome

         IF lInclui
            ACAO ( 'CADASTROU CENTRO DE CUSTO CODIGO ' + cCodigo )
         ELSE
            ACAO ( 'ALTEROU CENTRO DE CUSTO CODIGO ' + cCodigo )
         END
         
      ELSE
         IF lInclui ; CCUSTO->(dbDelete()) ; END
      END
   ELSE
      IF lInclui ; CCUSTO->(dbDelete()) ; END
   END
   
   UNLOCK
      
END

RestScreen ( 0, 0, MaxRow(), MaxCol(), cTela )
SetColor( cCor )
SetCursor( nCursor )
RETURN

