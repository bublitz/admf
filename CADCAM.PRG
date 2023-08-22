/***************

   PROGRAMA: CADCAM.prg

   FUN€AO:   CADASTRO DE CAMINHOES

   AUTOR:    Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'InKey.ch'
#include 'ComBo.ch'
#include 'SetCurs.ch'

***************************
PROCEDURE CAMINHAO( cTipo )
***************************
LOCAL cTela, cTelaLimpa, cCorAnt,;
      nII, nCursor, GetList := {}, nLinha,;
      lInclui, lAchou, nEscolha,;
      nMarca, cMarca, nModelo, cModelo, nAno, cAno, cPlaca, nCor, cCor,;
      cChassi, cComb, mAcesso, dCadastro, nProp, cProp, nVend, cVend,;
      nCompra, nVenda, cChave

cTela   := SaveScreen ( 0, 0, MaxRow(), MaxCol() )
nCursor := SetCursor( SC_NORMAL )
cCorAnt := SetColor( SETCORES(2) )

LIMPA( 4, 1, MaxRow()-3, MaxCol()-1 )

@  3,  1  SAY PADC ( 'CADASTRO DE CAMINHOES - '+IF(cTipo='C','COMPRA','VENDA'),;
                     78 ) COLOR 'W+/W'
@  6,  5  SAY "Marca .:"
@  7,  5  SAY "Modelo :"
@  8,  5  SAY "Ano ...:"
@ 11, 47  SAY "Combustivel:"

IF cTipo == 'C'
   @ 17,  5  SAY "Valor Compra:"
   @  5,  5  SAY "Interessado :"

ELSE
   @  9,  5  SAY "Cor ...:"
   @  9, 55  SAY "Placa:"
   @ 11,  5  SAY "Chassi:"
   @ 17, 40  SAY "Valor Venda:"
   @ 12,  5  SAY "Acessorios:"
   @  5,  5  SAY "Proprietario:"

END

@ 18,  5  SAY "Vendedor:"

@ 20,  5  SAY "Data do Cadastro:"

FMENS('')

SetColor( SETCORES(1) )

cTelaLimpa := SaveScreen ( 0, 0, MaxRow(), MaxCol() )

WHILE .T.

   UNLOCK
   COMMIT
   
   RestScreen ( 0, 0, MaxRow(), MaxCol(), cTelaLimpa )

   SetCursor ( SC_NORMAL )

   nProp := nMarca := nModelo := nAno := 0

   @  5, 19  GET  nProp PICT '99999999' ;
             WHEN FMENS( 'F2=Clientes. 0=Cadastra Cliente' ) ;
             VALID fPesqCli( nProp, 5, 29 )

   @  6, 14 GET nMarca PICT '999' ;
            WHEN FMENS( 'Digite o C¢digo da Marca. F6=Tabela.' ) ;
            VALID PESQTAB( '1', nMarca, 6, 18 )

   @  7, 14 GET nModelo PICT '999' ;
            WHEN FMENS( 'Digite o C¢digo da Modelo. F6=Tabela.' ) ;
            VALID PESQTAB( '2', nModelo, 7, 18 )

   @  8, 14 GET nAno PICT '9999' ;
            WHEN FMENS( 'Digite o Ano.' )

   READ

   IF LastKey() == K_ESC ; EXIT ; END

   IF     nAno < 60 ; nAno += 2000
   ELSEIF nAno < 99 ; nAno += 1900
   END
   
   SELE CAMINHAO

   IF nMarca + nModelo + nAno + nProp == 0
      LOOP

   ELSE
      lInclui := FALSE

   END

   cProp   := StrZero( nProp, 8, 0 )
   cMarca  := STRZERO( nMarca,  3, 0 )
   cModelo := STRZERO( nModelo, 3, 0 )
   cAno    := STRZERO( nAno,    4, 0 )

   FMENS('')
   
   @  5, 19 SAY cProp
   @  6, 14 SAY cMarca
   @  7, 14 SAY cModelo
   @  8, 14 SAY cAno

   cChave := cTipo + cProp + cMarca + cModelo + cAno

   SEEK cChave

   lAchou := Found()

   IF !lAchou .AND. !lInclui
      lInclui := TRUE
   END

   IF lInclui
      IF !NetAppBlank()
         LOOP
      END
      CAMINHAO->MARCA      := cMarca
      CAMINHAO->MODELO     := cModelo
      CAMINHAO->ANO        := cAno
      CAMINHAO->PROPRIETAR    := cProp
      COMMIT

   ELSE
      IF !NetRLock()
         LOOP
      END

   END

   nII := RecNo()
   
   cCor      := CAMINHAO->COR
   nCor      := Val( cCor )
   cPlaca    := CAMINHAO->PLACA
   cChassi   := CAMINHAO->CHASSI
   cComb     := CAMINHAO->COMB
   mAcesso   := CAMINHAO->ACESSORIOS
   dCadastro := CAMINHAO->CADASTRO
   cVend     := CAMINHAO->VENDEDOR
   nVend     := Val( cVend )
   nVenda    := CAMINHAO->VENDA
   nCompra   := CAMINHAO->COMPRA

   IF !lInclui

      @  9, 14  SAY  cCor
      PESQTAB( '3', nCor, 9, 18 )

      @  9, 62  SAY  cPlaca  PICT '@R AAA-9999' 
      @ 11, 60  SAY  cComb

      IF cTipo == 'C'
         @ 17, 19  SAY  nCompra PICT '@E 9,999,999.99'

      ELSE
         @ 11, 13  SAY  cChassi
         @ 17, 53  SAY  nVenda  PICT '@E 9,999,999.99'
         FOR nLinha := 1 TO 4
             @ 11+nLinha, 16 SAY MemoLine( mAcesso, 55, nLinha, , TRUE )
         NEXT

      END

      @ 18, 15  SAY  cVend
      PESQFUN( nVend )

      @ 20, 23  SAY  dCadastro

      FMENS( 'Tecle Enter.' )
      Inkey(0)
      FMENS('')

      nEscolha := ATENCAO( 'Deseja fazer:; ',;
                           {'Alteracao','Exclusao','Volta' },;
                           SETCORES(1) )

      IF nEscolha == 2
         IF '1'$M->cRight
            IF ATENCAO( 'Confirma Exclusao?; ',{'Nao','Sim'}, SETCORES(2) ) == 2
               CAMINHAO->(dbDelete())
               ACAO( 'EXCLUIU CAMINHAO CODIGO ' + cChave + cTipo )
            END

         ELSE
            ATENCAO( 'Acesso nao Permitido!' )
            ACAO( 'TENTOU EXCLUIR CAMINHAO CODIGO ' + cChave + cTipo )

         END

      END

      IF !nEscolha == 1 ; LOOP ; END

   END


   WHILE TRUE
      FMENS('')
      ReadExit( TRUE )
      IF cTipo == 'V'
         @  9, 14 GET nCor PICT '999' ;
            WHEN FMENS( 'Digite o C¢digo da Cor. F6=Tabela.' ) ;
            VALID PESQTAB( '3', nCor, 9, 18 )

         @  9, 62 GET cPlaca PICT '@R AAA-9999' ;
            WHEN FMENS( 'Digite a Placa do Caminhao.' )

         @ 11, 13  GET  cChassi

      END
      
      @ 11, 60  GET  cComb PICT '!' COMBO { 'Diesel','Gasolina','Alcool' } ;
                VALID cComb$'DGA'

      IF cTipo == 'V'
         READ
         IF LastKey() == K_ESC ; EXIT ; END
      
         FMENS( 'F2 = Continua.' )
         SET KEY K_F2 TO 
         SET FUNCTION 2 TO ""

         mAcesso := MemoEdit( mAcesso, 12, 16, 15, 70, TRUE )

         SET FUNCTION 2 TO
         IF "U"$M->cRight
            SET KEY K_F2 TO TBMOSTRA()
         END   

         IF LastKey() == K_ESC ; EXIT ; END

         FMENS('')
      END
      
      IF cTipo == 'C'
         @ 17, 19  GET  nCompra PICT '@E 9,999,999.99' WHEN FMENS( '' )
      ELSE
         @ 17, 53  GET  nVenda  PICT '@E 9,999,999.99' WHEN FMENS( '' )
      END

      @ 18, 15  GET  nVend PICT '999' VALID PESQFUN( nVend ) ;
                WHEN FMENS( 'F3=Funcion rios.' )

      @ 20, 23  GET  dCadastro WHEN FMENS( '' )

      READ

      IF !( LastKey() == K_UP .OR. LastKey() == K_PGUP )
         EXIT
      END
   END
   ReadExit( FALSE )

   CAMINHAO->(dbGoto( nII ))

   IF Lastkey() == K_ESC
      IF lInclui ; CAMINHAO->(dbDelete()) ; END
      LOOP
   END

   IF ATENCAO( 'Confirma '+IF(lInclui,'INCLUSAO ?','ALTERA€AO ?'), {'Sim','Nao'}, SETCORES(2) ) == 1

         FMENS( 'AGUARDE... Atualizando arquivo...' )
         CAMINHAO->PROPRIETAR    := cProp
         CAMINHAO->MARCA         := cMarca
         CAMINHAO->MODELO        := cModelo
         CAMINHAO->COR           := StrZero( nCor, 3, 0 )
         CAMINHAO->ANO           := cAno
         CAMINHAO->PLACA         := cPlaca
         CAMINHAO->CHASSI        := cChassi
         CAMINHAO->COMB          := cComb
         CAMINHAO->ACESSORIOS    := mAcesso
         CAMINHAO->COMPRA        := nCompra
         CAMINHAO->VENDA         := nVenda
         CAMINHAO->VENDEDOR      := StrZero( nVend, 3, 0 )
         CAMINHAO->CADASTRO      := dCadastro
         CAMINHAO->TIPO          := cTipo

         IF lInclui
            ACAO ( 'CADASTROU CAMINHAO CODIGO ' + cChave + cTipo )
         ELSE
            ACAO ( 'ALTEROU CAMINHAO CODIGO ' + cChave + cTipo )
         END

   ELSE
      IF lInclui ; CAMINHAO->(dbDelete()) ; END

   END
   UNLOCK
      
END

RestScreen ( 0, 0, MaxRow(), MaxCol(), cTela )
SetColor( cCorAnt )
SetCursor( nCursor )
RETURN

************************************************
FUNCTION PESQTAB( cTipo, nCod, nLinha, nColuna )
************************************************
LOCAL lRet, nSele
IF LastKey() == K_UP .OR. LastKey() == K_PGUP
   lRet := TRUE

ELSE
   nSele := Select()
   SELE TABELA
   SEEK cTipo + StrZero( nCod, 3, 0 )
   lRet := FOUND()
   IF lRet ; @ nLinha, nColuna SAY TABELA->NOME
   ELSE    ; @ nLinha, nColuna SAY SPACE( 30 )
   END
   Select( nSele )

END
RETURN lRet


*****************************************
STATIC FUNCTION fPESQCLI( nCod, nLinha, nColuna )
*****************************************
LOCAL lRet, nSele
IF LastKey() == K_UP .OR. LastKey() == K_PGUP
   lRet := TRUE

ELSEIF nCod == 0
   lRet := FALSE
   CLIENTES()
   
ELSE
   nSele := Select()
   SELE CLIENTES
   SEEK StrZero( nCod, 8, 0 )
   lRet := FOUND()
   IF lRet ; @ nLinha, nColuna SAY CLIENTES->NOME
   ELSE    ; @ nLinha, nColuna SAY SPACE( 40 )
   END
   Select( nSele )

END
RETURN lRet

