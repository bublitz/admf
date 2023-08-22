/***************

PROGRAMA: CADLAN.prg

FUN€AO: CADASTRO DE LANCAMENTOS

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'

#define l_s    5
#define c_s    1

**********************
PROCEDURE LANCTOSFUN()
**********************
LOCAL cTela, cTelaLimpa, cCor, nEscolha,;
      nII, nCursor, GETLIST := {},;
      lInclui, nOpcao, lAchou,;
      nCodFunc, nCodProv, dData, cHistorico, nValor,;
      cCodFunc, cCodProv
      
cTela   := SAVESCREEN ( 0, 0, MAXROW(), MAXCOL() )
nCursor := SETCURSOR( SC_NORMAL )
cCor    := SETCOLOR( SETCORES(2) )

LIMPA( 4, 1, MAXROW()-3, MAXCOL()-1 )

SELE MOVIMENT
SET ORDER TO 1

@ 4, 1 SAY PADC ( 'LAN€AMENTOS', 78 ) ;
       COLOR M->cCor2

@ 5, 1 SAY PADC ( 'ßßßßßßßßßßß', 78 ) ;
       COLOR M->cCor2

@ l_s+03,c_s+1 SAY "C¢digo do Funcion rio:"
@ l_s+05,c_s+1 SAY "Provento / Desconto:"
@ l_s+07,c_s+1 SAY "Data:"
@ l_s+09,c_s+1 SAY "Hist¢rico Complementar:"
@ l_s+11,c_s+1 SAY "Valor:"

FMENS('')

SETCOLOR( M->cCor1 )

cTelaLimpa := SAVESCREEN ( 0, 0, MAXROW(), MAXCOL() )

nCodFunc := nCodProv := 0
dData   := Date()

WHILE TRUE

   RESTSCREEN ( 0, 0, MAXROW(), MAXCOL(), cTelaLimpa )

   SETCURSOR ( SC_NORMAL )

   @ l_s+03 ,c_s+24 GET  nCodFunc PICT "999" VALID PESQFUN( nCodFunc ) ;
                    WHEN FMENS( 'F3=Funcion rios.' )
   @ l_s+05 ,c_s+22 GET  nCodProv PICT "999" VALID PESQPRO( nCodProv ) ;
                    WHEN FMENS( 'F4=Proventos e Descontos' )
   @ l_s+07 ,c_s+07 GET  dData WHEN FMENS('')

   READ

   IF LASTKEY() == K_ESC ; EXIT ; END

   cCodFunc := STRZERO( nCodFunc, 3, 0 )
   cCodProv := STRZERO( nCodProv, 3, 0 )

   SEEK cCodFunc+cCodProv+DTOS(dData)

   lAchou := FOUND()

   IF lAchou
      lInclui := FALSE
   ELSE
      lInclui := TRUE
      GO BOTTOM
      SKIP
   END

   cHistorico  := MOVIMENT->HISTORICO
   nValor      := MOVIMENT->VALOR

   IF !lInclui
      @ l_s+09 ,c_s+25 SAY  cHistorico PICT "@!"
      @ l_s+11 ,c_s+08 SAY  nValor     PICT "@E 9,999,999.99"

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

   @ l_s+09 ,c_s+25 GET  cHistorico PICT "@!"
   @ l_s+11 ,c_s+08 GET  nValor     PICT "@E 9,999,999.99"
   READ
   
   IF LASTKEY() == K_ESC ; LOOP ; END

   IF UPDATED()
      IF ATENCAO( 'Confirma '+IF(lInclui,'INCLUSAO ?','ALTERACAO ?'),;
                {'Sim','Nao'}, M->cCor2 ) == 1
         SELE MOVIMENT
         IF lInclui
            APPEND BLANK
         END
         MOVIMENT->CODFUNC    := cCodFunc
         MOVIMENT->CODPROV    := cCodProv
         MOVIMENT->DATA       := dData   
         MOVIMENT->HISTORICO  := cHistorico
         MOVIMENT->VALOR      := nValor
      END
   END
  
END

RESTSCREEN ( 0, 0, MAXROW(), MAXCOL(), cTela )
SETCOLOR( cCor )
SETCURSOR( nCursor )
RETURN




************************
FUNCTION PESQFUN( nCod )
************************
LOCAL lRet, nSele
IF LastKey() == K_UP .OR. LastKey() == K_PGUP
   lRet := TRUE

ELSE
   nSele := Select()
   SELE FUNCIONA
   SET ORDER TO 1
   SEEK StrZero( nCod, 3, 0 )
   lRet := FOUND()
   IF lRet ; @ Row(), Col()+2 SAY FUNCIONA->NOME
   ELSE    ; @ Row(), Col()+2 SAY SPACE( 35 )
   END
   Select( nSele )

END
RETURN lRet

************************
FUNCTION PESQPRO( nCod )
************************
LOCAL lRet, nSele
IF LastKey() == K_UP .OR. LastKey() == K_PGUP
   lRet := TRUE

ELSE
   nSele := Select()
   SELE PRODES
   SET ORDER TO 1
   SEEK StrZero( nCod, 3, 0 )
   lRet := FOUND()
   IF lRet ; @ Row(), Col()+2 SAY PRODES->DESCRICAO
   ELSE    ; @ Row(), Col()+2 SAY SPACE( 35 )
   END
   Select( nSele )

END
RETURN lRet

