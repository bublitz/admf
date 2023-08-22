/***************

PROGRAMA: CADFUN.prg

FUN€AO: CADASTRO DE FUNCIONARIOS

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'

#define l_s    5
#define c_s    1

**********************
PROCEDURE FUNCIONARI()
**********************
LOCAL cTela, cTelaLimpa, cCor, nEscolha,;
      nII, nCursor, GETLIST := {},;
      lInclui, nOpcao, lAchou,;
      nCodigo, cCodigo, cNome, cApelido, cAtividade, nSalario,;
      dContrato, dRecisao
      
cTela   := SAVESCREEN ( 0, 0, MAXROW(), MAXCOL() )
nCursor := SETCURSOR( SC_NORMAL )
cCor    := SETCOLOR( M->cCor2 )

FOR nII := 1 TO MAXROW()-7
   SCROLL( 4, 1, MAXROW()-3, MAXCOL()-1, 0, -nII )
   INKEY( .01 )
NEXT
SCROLL( 4, 1, MAXROW()-3, MAXCOL()-1 )

SELE FUNCIONA
SET ORDER TO 1

@ 4, 1 SAY PADC ( 'CADASTRO DE FUNCIONARIOS', 78 ) ;
       COLOR M->cCor2

@ 5, 1 SAY PADC ( 'ßßßßßßßßßßßßßßßßßßßßßßßß', 78 ) ;
       COLOR M->cCor2

@ l_s+02,c_s+1 SAY "C¢digo:"
@ l_s+04,c_s+1 SAY "Nome:                                            Apelido:"
@ l_s+06,c_s+1 SAY "Atividade:                                          Sal rio:"
@ l_s+08,c_s+1 SAY "Data Contrata‡„o:                                Data Recis„o:"


FMENS('')

SETCOLOR( M->cCor1 )

cTelaLimpa := SAVESCREEN ( 0, 0, MAXROW(), MAXCOL() )

WHILE TRUE

   RESTSCREEN ( 0, 0, MAXROW(), MAXCOL(), cTelaLimpa )

   nCodigo := 0
   
   SETCURSOR ( SC_NORMAL )
   
   @ l_s+02 ,c_s+09 GET  nCodigo PICT "999" ;
            WHEN FMENS( 'Digite o C¢digo do Funcionario. F3=Funcionarios.' )

   READ

   IF LASTKEY() == K_ESC ; EXIT ; END

   IF nCodigo == 0
      GO BOTTOM
      nCodigo := Val( FUNCIONA->CODIGO ) + 1
      lInclui := TRUE

   ELSE
      lInclui := FALSE

   END

   cCodigo := STRZERO( nCodigo, 3, 0 )

   @ l_s+02 ,c_s+09 SAY cCodigo COLOR M->cCor3

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

   cNome       := FUNCIONA->NOME
   cApelido    := FUNCIONA->APELIDO
   cAtividade  := FUNCIONA->ATIVIDADE
   nSalario    := FUNCIONA->SALARIO
   dContrato   := FUNCIONA->CONTRATO
   dRecisao    := FUNCIONA->RECISAO

   IF !lInclui
      @ l_s+04 ,c_s+07 SAY  cNome       PICT "@!"
      @ l_s+04 ,c_s+59 SAY  cApelido    PICT "@!"
      @ l_s+06 ,c_s+12 SAY  cAtividade  PICT "@!"
      @ l_s+06 ,c_s+62 SAY  nSalario    PICT "@E 9,999,999.99"
      @ l_s+08 ,c_s+19 SAY  dContrato
      @ l_s+08 ,c_s+64 SAY  dRecisao

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

   @ l_s+04 ,c_s+07 GET  cNome      PICT "@!" VALID cNome >= "A"
   @ l_s+04 ,c_s+59 GET  cApelido   PICT "@!"
   @ l_s+06 ,c_s+12 GET  cAtividade PICT "@!"
   @ l_s+06 ,c_s+62 GET  nSalario   PICT "@E 9,999,999.99" VALID nSalario > 0
   @ l_s+08 ,c_s+19 GET  dContrato
   @ l_s+08 ,c_s+64 GET  dRecisao

   READ
   
   IF LASTKEY() == K_ESC ; LOOP ; END

   IF UPDATED()
      IF ATENCAO( 'Confirma '+IF(lInclui,'INCLUSAO ?','ALTERACAO ?'),;
                {'Sim','Nao'}, M->cCor2 ) == 1
         SELE FUNCIONA
         IF lInclui
            APPEND BLANK
         END
         FUNCIONA->CODIGO     := cCodigo
         FUNCIONA->NOME       := cNome
         FUNCIONA->APELIDO    := cApelido
         FUNCIONA->ATIVIDADE  := cAtividade
         FUNCIONA->SALARIO    := nSalario
         FUNCIONA->CONTRATO   := dContrato
         FUNCIONA->RECISAO    := dRecisao
      END
   END
  
END

RESTSCREEN ( 0, 0, MAXROW(), MAXCOL(), cTela )
SETCOLOR( cCor )
SETCURSOR( nCursor )
RETURN
