/***************

   PROGRAMA: CADVENDA.prg

   FUN€AO:   CADASTRO DE VENDA DE CAMINHOES

   AUTOR:    Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'InKey.ch'
#include 'ComBo.ch'
#include 'SetCurs.ch'

STATIC nVenDin, nVenChe, nVenOut, ;
       nCusDin, nCusChe, nCusOut, ;
       nSalDin, nSalChe, nSalOut
       
********************
PROCEDURE CadVenda()
********************
LOCAL cTela, cTelaLimpa, cCorAnt,;
      nII, nCursor, GetList := {}, nLinha,;
      lInclui, lAchou, nEscolha, cChave,;
      nMarca, cMarca, nModelo, cModelo, nAno, cAno,;
      cNumero, cProp, nProp, cComp, nComp, cVend, nVend,;
      nComiV, nComiP, cVenNumChe, cVenHis,;
      cCusNumChe, cCusHis, cSalNumChe, cSalHis,;
      cVenDin, cVenChe, cVenOut, cCusDin, cCusChe, cCusOut,;
      cSalDin, cSalChe, cSalOut

cTela   := SaveScreen ( 0, 0, MaxRow(), MaxCol() )
nCursor := SetCursor( SC_NORMAL )
cCorAnt := SetColor( SETCORES(2) )

LIMPA( 4, 1, MaxRow()-3, MaxCol()-1 )

@  3,  1  SAY PADC ( 'VENDA DE CAMINHOES - Negocios Realizados', 78 ) COLOR 'W+/W'

TelaVenda()

FMENS('')

SetColor( SETCORES(1) )

cTelaLimpa := SaveScreen ( 0, 0, MaxRow(), MaxCol() )

WHILE .T.

   UNLOCK
   COMMIT
   
   RestScreen ( 0, 0, MaxRow(), MaxCol(), cTelaLimpa )

   SetCursor ( SC_NORMAL )

   nProp := nMarca := nModelo := nAno := 0

   @  5, 16  GET  nProp PICT '99999999' ;
             WHEN FMENS( 'F2=Clientes.' ) ;
             VALID PesqCli( nProp, 5, 25 )

   @  6,  9 GET nMarca PICT '999' ;
            WHEN FMENS( 'Digite o C¢digo da Marca. F6=Tabela.' ) ;
            VALID PESQTAB( '1', nMarca, 6, 13 )

   @  7, 10 GET nModelo PICT '999' ;
            WHEN FMENS( 'Digite o C¢digo da Modelo. F6=Tabela.' ) ;
            VALID PESQTAB( '2', nModelo, 7, 14 )

   @  7, 74 GET nAno PICT '9999' ;
            WHEN FMENS( 'Digite o Ano.' )

   READ

   IF LastKey() == K_ESC ; EXIT ; END

   IF     nAno < 60 ; nAno += 2000
   ELSEIF nAno < 99 ; nAno += 1900
   END
   
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
   
   @  5, 16  SAY cProp
   @  6,  9  SAY cMarca
   @  7, 10  SAY cModelo
   @  7, 74  SAY cAno

   cChave := cProp + cMarca + cModelo + cAno
   
   SELE CAMINHAO
   SET ORDER TO 1

   CAMINHAO->(dbSeek ( 'V' + cChave ) )

   IF !CAMINHAO->(Found())
      ATENCAO( 'Caminhao nao Cadastrado !!', { 'Volta' } )
      LOOP
   END

   SELE VENDAS   
   VENDAS->(dbSeek ( 'V' + cChave ) )
   
   IF VENDAS->(Found())
      ATENCAO( 'Caminhao ja Vendido !!', { 'Volta' } )
      LOOP
   END

   VENDAS->(dbGoBottom())
   cNumero := StrZero( Val( VENDAS->NUMERO ) + 1, 10, 0 )

   IF !VENDAS->(NetAppBlank())
      LOOP
   END

   VENDAS->NUMERO     := cNumero
   VENDAS->MARCA      := cMarca
   VENDAS->MODELO     := cModelo
   VENDAS->ANO        := cAno
   VENDAS->PROPRIETAR := cProp
   dbCommit()

   cComp        := VENDAS->COMPRADOR
   nComp        := Val( cComp )
   cVend        := VENDAS->VENDEDOR
   nVend        := Val( cVend )
   nComiV       := VENDAS->COMISSAO_V
   nComiP       := VENDAS->COMISSAO_P
   nVenDin      := VENDAS->VEN_DIN
   nVenChe      := VENDAS->VEN_CHE
   nVenOut      := VENDAS->VEN_OUT
   cVenNumChe   := VENDAS->VEN_NUMCHE
   cVenHis      := VENDAS->VEN_OUTHIS
   nCusDin      := VENDAS->CUS_DIN
   nCusChe      := VENDAS->CUS_CHE
   nCusOut      := VENDAS->CUS_OUT
   cCusNumChe   := VENDAS->CUS_NUMCHE
   cCusHis      := VENDAS->CUS_OUTHIS
   nSalDin      := VENDAS->SAL_DIN
   nSalChe      := VENDAS->SAL_CHE
   nSalOut      := VENDAS->SAL_OUT
   cSalNumChe   := VENDAS->SAL_NUMCHE
   cSalHis      := VENDAS->SAL_OUTHIS

   cVenDin := cVenChe := cVenOut := cCusDin := cCusChe := ' '
   cCusOut := cSalDin := cSalChe := cSalOut := ' '

   @  9, 13  GET  nComp PICT '99999999' ;
             WHEN FMENS( 'F2=Clientes.' ) ;
             VALID PesqCli( nComp, 9, 22 )

   @ 10, 12  GET  nVend PICT '999' VALID fPESQFUN( nVend ) ;
             WHEN FMENS( 'F3=Funcion rios.' )
   
   @ 10, 59  GET  nComiP PICT '@E 99.99' ;
             WHEN FMENS( 'Comissao do Vendedor em Porcentagem.' )
             
   @ 10, 66  GET  nComiV PICT '@E 9,999,999.99' ;
             WHEN FMENS( 'Comissao do Vendedor em Reais.' )
             
   /* 

                ======>>>>      V A L O R E S     <<<<=======

   */

   @ 12, 35  GET  nVenDin PICT '@E 9,999,999.99' COLOR 'W/N,N/BG';
             VALID SOMA() ;
             WHEN FMENS( '' )

   @ 12, 47  GET  cVenDin PICT '!' ;
             COMBO { ' Nenhum','Caixa','Banco' } ;
             COLOR 'W/N,N/BG'
             
   @ 13, 35  GET  nVenChe PICT '@E 9,999,999.99' COLOR 'W/N,N/BG';
             VALID SOMA() ;
             WHEN FMENS( '' )

   @ 13, 47  GET  cVenChe PICT '!' ;
             COMBO { ' Nenhum','Cheque','Banco' } ;
             COLOR 'W/N,N/BG'

   @ 13, 50  GET  cVenNumChe PICT '@!' COLOR 'W/N,N/BG';
             WHEN FMENS( '' )

   @ 14, 35  GET  nVenOut PICT '@E 9,999,999.99' COLOR 'W/N,N/BG';
             VALID SOMA() ;
             WHEN FMENS( '' )

   @ 14, 50  GET  cVenHis PICT '@!S25' COLOR 'W/N,N/BG';
             WHEN FMENS( '' )

   @ 15, 35  GET  nCusDin PICT '@E 9,999,999.99' COLOR 'W/B,N/BG';
             VALID SOMA() ;
             WHEN FMENS( '' )

   @ 15, 47  GET  cCusDin PICT '!' ;
             COMBO { ' Nenhum','Caixa','Banco' } ;
             COLOR 'W/B,N/BG'

   @ 16, 35  GET  nCusChe PICT '@E 9,999,999.99' COLOR 'W/B,N/BG' ;
             VALID SOMA() ;
             WHEN FMENS( '' )

   @ 16, 47  GET  cCusChe PICT '!';
             COMBO { ' Nenhum','Caixa','Banco' } ;
             COLOR 'W/B,N/BG'

   @ 16, 50  GET  cCusNumChe PICT '@!' COLOR 'W/B,N/BG';
             WHEN FMENS( '' )

   @ 17, 35  GET  nCusOut PICT '@E 9,999,999.99' COLOR 'W/B,N/BG';
             VALID SOMA() ;
             WHEN FMENS( '' )

   @ 17, 50  GET  cCusHis PICT '@!S25' COLOR 'W/B,N/BG';
             WHEN FMENS( '' )

   @ 18, 35  GET  nSalDin PICT '@E 9,999,999.99' COLOR 'W/R,N/BG';
             VALID SOMA() ;
             WHEN FMENS( '' )

   @ 18, 47  GET  cSalDin PICT '!';
             COMBO { ' Nenhum','Caixa','Banco' } ;
             COLOR 'W/R,N/BG'

   @ 19, 35  GET  nSalChe PICT '@E 9,999,999.99' COLOR 'W/R,N/BG';
             VALID SOMA() ;
             WHEN FMENS( '' )

   @ 19, 47  GET  cSalChe PICT '!';
             COMBO { ' Nenhum','Cheque','Banco' };
             COLOR 'W/R,N/BG'

   @ 19, 50  GET  cSalNumChe PICT '@!'  COLOR 'W/R,N/BG';
             WHEN FMENS( '' )

   @ 20, 35  GET  nSalOut PICT '@E 9,999,999.99'  COLOR 'W/R,N/BG';
             VALID SOMA() ;
             WHEN FMENS( '' )

   @ 20, 50  GET  cSalHis PICT '@!S25'  COLOR 'W/R,N/BG';
             WHEN FMENS( '' )

   READ

   IF Lastkey() == K_ESC .OR. LastKey() == K_PGUP
      VENDAS->(dbDelete())
      LOOP
   END

   IF ATENCAO( 'Confirma Inclusao ?', {'Sim','Nao'} ) == 1
      FMENS( 'Aguarde... Atualizando Arquivo...' )
      cComp := StrZero( nComp, 8, 0 )
      cVend := StrZero( nVend, 3, 0 )

      VENDAS->COMPRADOR    :=  cComp
      VENDAS->VENDEDOR     :=  cVend
      VENDAS->COMISSAO_V   :=  nComiV
      VENDAS->COMISSAO_P   :=  nComiP
      VENDAS->VEN_DIN      :=  nVenDin
      VENDAS->VEN_CHE      :=  nVenChe
      VENDAS->VEN_OUT      :=  nVenOut
      VENDAS->VEN_NUMCHE   :=  cVenNumChe
      VENDAS->VEN_OUTHIS   :=  cVenHis
      VENDAS->CUS_DIN      :=  nCusDin
      VENDAS->CUS_CHE      :=  nCusChe
      VENDAS->CUS_OUT      :=  nCusOut
      VENDAS->CUS_NUMCHE   :=  cCusNumChe
      VENDAS->CUS_OUTHIS   :=  cCusHis
      VENDAS->SAL_DIN      :=  nSalDin
      VENDAS->SAL_CHE      :=  nSalChe
      VENDAS->SAL_OUT      :=  nSalOut
      VENDAS->SAL_NUMCHE   :=  cSalNumChe
      VENDAS->SAL_OUTHIS   :=  cSalHis

      SELE CAMINHAO
      SET ORDER TO 1
      CAMINHAO->(dbSeek ( 'V' + cChave ) )
      IF Found()
         CAMINHAO->(NetRLock(0))
         CAMINHAO->TIPO := 'N'
      END

      ACAO( 'NEGOCIO REALIZADO ==> ' + cChave )

      SELE VENDAS

      FMENS( '' )
   END

END

RestScreen ( 0, 0, MaxRow(), MaxCol(), cTela )
SetColor( cCorAnt )
SetCursor( nCursor )
RETURN

************************
STATIC FUNCTION fPESQFUN( nCod )
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
   IF lRet ; @ Row(), Col()+1 SAY SubStr( FUNCIONA->NOME, 1, 25 )
   ELSE    ; @ Row(), Col()+1 SAY SPACE( 25 )
   END
   Select( nSele )

END
RETURN lRet

**********************
STATIC FUNCTION SOMA()
**********************
@ 13,  9 SAY nVenDin + nVenChe + nVenOut PICT '@E 99,999,999.99' COLOR 'GR+/N'
@ 16,  9 SAY nCusDin + nCusChe + nCusOut PICT '@E 99,999,999.99' COLOR 'GR+/B'
@ 19,  9 SAY nSalDin + nSalChe + nSalOut PICT '@E 99,999,999.99' COLOR 'GR+/R'
RETURN TRUE

