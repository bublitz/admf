/***************

   PROGRAMA: CADTAB.prg

   FUN€AO:   CADASTRO DE TABELAS DE 
             MARCA   ==  1
             MODELO  ==  2
             COR     ==  3

   AUTOR:    Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'InKey.ch'
#include 'SetCurs.ch'
#include "Combo.ch"

******************
PROCEDURE TABELA()
******************
LOCAL cTela, cTelaLimpa, cCor,;
      nII, nCursor, GetList := {}, ;
      lInclui, lAchou, nCodigo, cCodigo, nEscolha,;
      cNome, cTipo

cTela   := SaveScreen ( 0, 0, MaxRow(), MaxCol() )
nCursor := SetCursor( SC_NORMAL )
cCor    := SetColor( SETCORES(2) )

FMENS('')

SetColor( SETCORES(1) )

ABRE( 8, 17, 13, 70, TRUE )
@  8, 18  SAY 'CADASTRO DE TABELA' COLOR 'W+/W'
@  9, 19  TO 11, 24  
@  9, 27  TO 11, 34  
@  9, 37  TO 11, 68  
@  9, 20  SAY "Tipo"
@  9, 28  SAY "Codigo"
@  9, 38  SAY "Nome"

cTelaLimpa := SaveScreen ( 0, 0, MaxRow(), MaxCol() )

WHILE .T.

   RestScreen ( 0, 0, MaxRow(), MaxCol(), cTelaLimpa )

   SetCursor ( SC_NORMAL )

   cTipo := Space ( 1 )
   
   @  10, 20 GET cTipo PICT '!' ;
             COMBO { '1. Marca','2. Modelo','3. Cor' } ;
             WHEN FMens( 'Digite o Tipo da Tabela. ' ) ;
             VALID cTipo$'123'
             
   READ
   
   IF LastKey() == K_ESC ; EXIT ; END

   @  12, 20 SAY 'Tabela ==> '
   @  12, 31 SAY IF( cTipo == '1', 'Marca ',;
                 IF( cTipo == '2', 'Modelo',;
                                   'Cor   ' ) ) COLOR SETCORES(5)
   WHILE .T.
      nCodigo := 0
      @ 10, 28 GET nCodigo PICT '999' ;
            WHEN FMENS( 'Digite o C¢digo da Tabela. F6=Tabelas' )

      READ

      IF LastKey() == K_ESC ; EXIT ; END

      SELE TABELA

      IF nCodigo == 0
         lInclui := TRUE
         TABELA->(dbSeek( cTipo ))
         IF Found()
            WHILE TABELA->TIPO == cTipo .AND. !TABELA->(EOF())
               TABELA->(dbSkip())
            END
            TABELA->(dbSkip(-1))
            nCodigo := Val( TABELA->CODIGO ) + 1
         ELSE
            nCodigo := 1
         END

      ELSE
         lInclui := FALSE

      END

      cCodigo := STRZERO( nCodigo, 3, 0 )

      FMENS('')
   
      @ 10, 28 SAY cCodigo COLOR SETCORES(3)

      SEEK cTipo + cCodigo

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
         TABELA->TIPO   := cTipo
         TABELA->CODIGO := cCodigo
         COMMIT
      ELSE
         IF !NetRLock()
            LOOP
         END
      END

      nII := RecNo()
      cNome       := TABELA->NOME

      IF !lInclui
         @ 10, 38  SAY cNome
         FMENS('')

         nEscolha := ATENCAO( 'Deseja fazer:; ',;
                           {'Alteracao','Exclusao','Volta' },;
                           SETCORES(1) )

         IF nEscolha == 2
            IF '1'$M->cRight
               IF ATENCAO( 'Confirma Exclusao?; ',{'Nao','Sim'}, SETCORES(2) ) == 2
                  TABELA->(dbDelete())
                  ACAO( 'EXCLUIU TABELA CODIGO ' + cTipo+cCodigo )
               END
            ELSE
               ATENCAO( 'Acesso nao Permitido!' )
               ACAO( 'TENTOU EXCLUIR TABELA CODIGO ' + cTipo+cCodigo )
            END
        END

        IF !nEscolha == 1 ; LOOP ; END

      END

      FMENS('')

      @ 10, 38  GET cNome        PICT "@!" VALID !Empty( cNome )
      READ
   
      TABELA->(dbGoto( nII ))

      IF Lastkey() == K_ESC 
         IF lInclui ; TABELA->(dbDelete()) ; END
         LOOP 
      END

      IF Updated()
         IF ATENCAO( 'Confirma '+IF(lInclui,'INCLUSAO ?','ALTERA€AO ?'), {'Sim','Nao'}, SETCORES(2) ) == 1

            FMENS( 'AGUARDE... Atualizando arquivo...' )
            TABELA->TIPO        :=  cTipo
            TABELA->CODIGO      :=  cCodigo
            TABELA->NOME        :=  cNome

            IF lInclui
               ACAO ( 'CADASTROU TABELA CODIGO ' + cTipo+cCodigo )
            ELSE
               ACAO ( 'ALTEROU TABELA CODIGO ' + cTipo+cCodigo )
            END
         
         ELSE
            IF lInclui ; TABELA->(dbDelete()) ; END
         END
      ELSE
         IF lInclui ; TABELA->(dbDelete()) ; END
      END
   
      UNLOCK
   END
END

RestScreen ( 0, 0, MaxRow(), MaxCol(), cTela )
SetColor( cCor )
SetCursor( nCursor )
RETURN

