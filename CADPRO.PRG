/***************

PROGRAMA: CADPRO.prg

FUN€AO: CADASTRO DE PROVENTOS E DESCONTOS

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'
#include 'ComBo.ch'

********************
PROCEDURE PROVDESC()
********************
LOCAL cTela, cTelaLimpa, cCor, nEscolha,;
      nII, nCursor, GETLIST := {},;
      lInclui, nOpcao, lAchou,;
      nCodigo, cCodigo, cDescricao, cTipo

cTela   := SAVESCREEN ( 0, 0, MAXROW(), MAXCOL() )
nCursor := SETCURSOR( SC_NORMAL )
cCor    := SETCOLOR( M->cCor2 )

FOR nII := 1 TO MAXROW()-7
   SCROLL( 4, 1, MAXROW()-3, MAXCOL()-1, 0, -nII )
   INKEY( .01 )
NEXT
SCROLL( 4, 1, MAXROW()-3, MAXCOL()-1 )

SELE PRODES

@ 4, 1 SAY PADC ( 'CADASTRO DE PROVENTOS & DESCONTOS', 78 ) ;
       COLOR M->cCor2

@ 5, 1 SAY PADC ( 'ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß', 78 ) ;
       COLOR M->cCor2

@  7, 2 SAY "C¢digo:"
@  9, 2 SAY "Descricao:"
@ 11, 2 SAY "Tipo (P/D):"

FMENS('')

SETCOLOR( M->cCor1 )

cTelaLimpa := SAVESCREEN ( 0, 0, MAXROW(), MAXCOL() )

WHILE TRUE

   RESTSCREEN ( 0, 0, MAXROW(), MAXCOL(), cTelaLimpa )

   nCodigo := 0
   
   SETCURSOR ( SC_NORMAL )
   
   @  7, 10 GET nCodigo PICT "999" ;
            WHEN FMENS( 'Digite o C¢digo do Provento/Desconto. F4=Prov/Desc.' )

   READ

   IF LASTKEY() == K_ESC ; EXIT ; END

   IF nCodigo == 0
      GO BOTTOM
      nCodigo := Val( PRODES->CODIGO ) + 1
      lInclui := TRUE

   ELSE
      lInclui := FALSE

   END

   cCodigo := STRZERO( nCodigo, 3, 0 )

   @ 7,10 SAY cCodigo COLOR M->cCor3

   SEEK cCodigo
   
   lAchou := FOUND()
   
   IF lAchou .AND. lInclui
      ATENCAO( 'Codigo Ja Cadastrado', { 'VOLTA' } )
      LOOP
   END
   
   IF !lAchou .AND. !lInclui
      ATENCAO( 'Codigo Nao Cadastrado', { 'VOLTA' } )
      LOOP
   END
   
   IF lInclui
      GO BOTTOM
      SKIP
   END

   cDescricao  := PRODES->DESCRICAO
   cTipo       := PRODES->TIPO

   IF !lInclui
      @  9, 13 SAY cDescricao PICT "@!"
      @ 11, 14 SAY cTipo      PICT "!"
      
      FMENS( 'Tecle Enter.' )
      INKEY(0)
      FMENS('')      
      
      nEscolha := ATENCAO( 'Deseja fazer:; ', {'Alteracao','Exclusao','Volta' },;
                         M->cCor1 )
      IF nEscolha == 2
         IF ATENCAO( 'Confirma Exclusao?; ',{'Nao','Sim'}, M->cCor2 ) == 2
            DELETE
         END
      END
      IF nEscolha != 1
         LOOP
      END

   END

   FMENS('')

   @  9, 13 GET cDescricao PICT "@!"
   @ 11, 14 GET cTipo PICT "!" COMBO { "Provento","Desconto" } ;
                      VALID cTipo$"PD"
                           
      
   READ
   
   IF LASTKEY() == K_ESC ; LOOP ; END

   IF UPDATED()
      IF ATENCAO( 'Confirma '+IF(lInclui,'INCLUSAO ?','ALTERACAO ?'),;
                {'Sim','Nao'}, M->cCor2 ) == 1
         SELE PRODES
         IF lInclui
            APPEND BLANK
         END
         PRODES->CODIGO     := cCodigo
         PRODES->DESCRICAO  := cDescricao
         PRODES->TIPO       := cTipo

      END
   END
  
END

RESTSCREEN ( 0, 0, MAXROW(), MAXCOL(), cTela )
SETCOLOR( cCor )
SETCURSOR( nCursor )
RETURN
