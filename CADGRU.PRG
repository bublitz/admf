/***************

   PROGRAMA: CADCEN.prg

   FUN€AO:   CADASTRO DE GRUPO

   AUTOR:    Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'InKey.ch'
#include 'SetCurs.ch'
#include "Combo.ch"

******************
PROCEDURE GRUPOS()
******************
LOCAL cTela, cTelaLimpa, cCor,;
      nII, nCursor, GetList := {}, ;
      lInclui, lAchou, nCodigo, cCodigo, nEscolha,;
      cNome

cTela   := SaveScreen ( 0, 0, MaxRow(), MaxCol() )
nCursor := SetCursor( SC_NORMAL )
cCor    := SetColor( SETCORES(2) )

ABRE( 8, 30, 12, 76, TRUE )

@  8, 30  SAY " CADASTRO DE GRUPOS " COLOR "N/W"
@  9, 31  TO 11, 38  
@  9, 39  TO 11, 75  
@  9, 32  SAY "C¢digo"
@  9, 40  SAY "Nome"

FMENS('')

SetColor( SETCORES(1) )

cTelaLimpa := SaveScreen ( 0, 0, MaxRow(), MaxCol() )

WHILE .T.

   RestScreen ( 0, 0, MaxRow(), MaxCol(), cTelaLimpa )

   SetCursor ( SC_NORMAL )

   nCodigo := 0
   @ 10, 32 GET nCodigo PICT '999' ;
            WHEN FMENS( 'Digite o C¢digo do Grupo. F10=Grupos.' )

   READ

   IF LastKey() == K_ESC ; EXIT ; END

   SELE GRUPOS

   IF nCodigo == 0
      lInclui := TRUE
      GO BOTTOM
      nCodigo := Val( GRUPOS->CODIGO ) + 1

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
      GRUPOS->CODIGO := cCodigo
      COMMIT
   ELSE
      IF !NetRLock()
         LOOP
      END
   END

   nII := RecNo()
   cNome       := GRUPOS->NOME

   IF !lInclui
      @ 10, 40  SAY cNome
      FMENS('')

      nEscolha := ATENCAO( 'Deseja fazer:; ',;
                           {'Alteracao','Exclusao','Volta' },;
                           SETCORES(1) )

      IF nEscolha == 2
         IF 'C'$M->cRight
            IF ATENCAO( 'Confirma Exclusao?; ',{'Nao','Sim'}, SETCORES(2) ) == 2
               GRUPOS->(dbDelete())
               ACAO( 'EXCLUIU GRUPO CODIGO ' + cCodigo )
            END
         ELSE
            ATENCAO( 'Acesso nao Permitido!' )
            ACAO( 'TENTOU EXCLUIR GRUPO CODIGO ' + cCodigo )
         END
      END

      IF !nEscolha == 1 ; LOOP ; END

   END

   FMENS('')

   @ 10, 40  GET cNome        PICT "@!" VALID cNome >="A"
   READ
   
   GRUPOS->(dbGoto( nII ))

   IF Lastkey() == K_ESC 
      IF lInclui ; GRUPOS->(dbDelete()) ; END
      LOOP 
   END

   IF Updated()
      IF ATENCAO( 'Confirma '+IF(lInclui,'INCLUSAO ?','ALTERA€AO ?'), {'Sim','Nao'}, SETCORES(2) ) == 1

         FMENS( 'AGUARDE... Atualizando arquivo...' )
         GRUPOS->CODIGO      :=  cCodigo
         GRUPOS->NOME        :=  cNome

         IF lInclui
            ACAO ( 'CADASTROU GRUPO CODIGO ' + cCodigo )
         ELSE
            ACAO ( 'ALTEROU GRUPO CODIGO ' + cCodigo )
         END
         
      ELSE
         IF lInclui ; GRUPOS->(dbDelete()) ; END
      END
   ELSE
      IF lInclui ; GRUPOS->(dbDelete()) ; END
   END
   
   UNLOCK
      
END

RestScreen ( 0, 0, MaxRow(), MaxCol(), cTela )
SetColor( cCor )
SetCursor( nCursor )
RETURN

