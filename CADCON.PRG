/***************

   PROGRAMA: CADCON.prg

   FUN€AO:   CADASTRO DE CONTRATOS

   AUTOR:    Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'InKey.ch'
#include 'SetCurs.ch'
#include "Combo.ch"

*********************
PROCEDURE CONTRATOS()
*********************
LOCAL cTela, cTelaLimpa, cCor,;
      nII, nCursor, GetList := {}, ;
      lInclui, lAchou, nNumero, cNumero, nEscolha,;
      cTipo, nCliente, cParcelado, nTotal, nDescto, nPago, nDesp,;
      cCheque, cBanco, cAgencia, cPraca, nVendedor, dAssina, dVencto, nCusto,;
      nManut, nTitul, nDepDi, nDepIn, dApFat, dVeFat, cTipoCobra, dInc1, dInc2

cTela   := SaveScreen ( 0, 0, MaxRow(), MaxCol() )
nCursor := SetCursor( SC_NORMAL )
cCor    := SetColor( SETCORES(2) )

LIMPA( 4, 1, MaxRow()-3, MaxCol()-1 )

TELACON()

FMENS('')

SetColor( SETCORES(1) )

cTelaLimpa := SaveScreen ( 0, 0, MaxRow(), MaxCol() )

WHILE TRUE

   UNLOCK
   COMMIT

   RestScreen ( 0, 0, MaxRow(), MaxCol(), cTelaLimpa )

   SetCursor ( SC_NORMAL )

   nNumero := 0
   @  4, 22 GET nNumero PICT '99999999' ;
            WHEN FMENS( 'Digite o N£mero do Contrato.' )

   READ

   IF LastKey() == K_ESC ; EXIT ; END

   SELE CONTRATO
   SET ORDER TO 1

   IF nNumero == 0
      lInclui := TRUE
      GO BOTTOM
      nNumero := Val( CONTRATO->NUMERO ) + 1

   ELSE
      lInclui := FALSE

   END

   cNumero := STRZERO( nNumero, 8, 0 )

   FMENS('')

   @  4, 22 SAY cNumero COLOR SETCORES(3)

   SEEK cNumero

   lAchou := Found()

   IF !lAchou .AND. !lInclui
      IF ATENCAO( 'Contrato Nao Cadastrado!;Deseja Incluir ?',;
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
      CONTRATO->NUMERO := cNumero
      COMMIT
   ELSE
      IF !NetRLock()
         LOOP
      END
   END

   nII := RecNo()
   cTipo        :=  CONTRATO->TIPO
   nCliente     :=  Val( CONTRATO->CLIENTE )
   cParcelado   :=  CONTRATO->PARCELADO
   nTotal       :=  CONTRATO->VLTOTAL
   nDescto      :=  CONTRATO->VLDESCTO
   nPago        :=  CONTRATO->VLPAGO
   nDesp        :=  CONTRATO->VLDESP
   cCheque      :=  CONTRATO->CHEQUE
   cBanco       :=  CONTRATO->BANCO
   cAgencia     :=  CONTRATO->AGENCIA
   cPraca       :=  CONTRATO->PRACA
   nVendedor    :=  Val( CONTRATO->VENDEDOR )
   nCusto       :=  Val( CONTRATO->CCUSTO )
   dAssina      :=  CONTRATO->ASSINA
   dVencto      :=  CONTRATO->VENCTO
   cTipoCobra   :=  CONTRATO->TIPOCOBRA
   nManut       :=  CONTRATO->VLMANUT
   nTitul       :=  CONTRATO->VLTITUL
   nDepDi       :=  CONTRATO->VLDEPDI
   nDepIn       :=  CONTRATO->VLDEPIN
   dApFat       :=  CONTRATO->APRFATU
   dVeFat       :=  CONTRATO->VECFATU
   dInc1        :=  CONTRATO->DT1INC
   dInc2        :=  CONTRATO->DT2INC

   IF !lInclui
      @  4, 40  SAY  cTipo
      @  6, 11  SAY  StrZero( nCliente, 8, 0 )
      PESQCLI( nCliente, 6, 20 )
      @  6, 75  SAY  cParcelado
      @  8,  9  SAY  nTotal  PICT "@E 9,999,999.99"
      @  8, 34  SAY  nDescto  PICT "@E 9,999,999.99"
      @  8, 64  SAY  nPago  PICT "@E 9,999,999.99"
      @ 10, 25  SAY  nDesp  PICT "@E 9,999,999.99"
      VLGERAL( nPago+nDesp )
      @ 12, 10  SAY  cCheque
      @ 12, 28  SAY  cBanco
      @ 12, 48  SAY  cAgencia
      @ 12, 66  SAY  cPraca
      @ 14, 12  SAY  StrZero( nVendedor, 3, 0 )
      PESQVEN( nVendedor, 14, 16 )
      @ 15, 15  SAY  StrZero( nCusto, 3, 0 )
      PESQCEN( nCusto, 15, 19 )
      @ 16, 19  SAY  dAssina
      @ 16, 43  SAY  dVencto
      @ 16, 75  SAY  cTipoCobra
      @ 18, 25  SAY  nManut  PICT "@E 9,999,999.99"
      @ 19, 22  SAY  nTitul  PICT "@E 9,999,999.99"
      @ 20, 26  SAY  nDepDi  PICT "@E 9,999,999.99"
      @ 21, 26  SAY  nDepIn  PICT "@E 9,999,999.99"
      @ 18, 64  SAY  dApFat
      @ 19, 64  SAY  dVeFat
      @ 20, 66  SAY  dInc1
      @ 21, 64  SAY  dInc2

      FMENS('Tecle Enter.')
      InKey( 0 )
      FMENS('')

      nEscolha := ATENCAO( 'Deseja fazer:; ',;
                           {'Altera‡ao','Exclusao','Volta' },;
                           SETCORES(1) )

      IF nEscolha == 2
         IF '1'$M->cRight
            IF ATENCAO( 'Confirma Exclusao?; ',{'Nao','Sim'}, SETCORES(2) ) == 2
               CONTRATO->(dbDelete())
               ACAO( 'EXCLUIU CONTRATO NUMERO ' + cNumero )
            END
         ELSE
            ATENCAO( 'Acesso nao Permitido!' )
            ACAO( 'TENTOU EXCLUIR CONTRATO NUMERO ' + cNumero )
         END

      END
         
      IF !nEscolha == 1 ; LOOP ; END

   END

   FMENS('')

   VLGERAL( nPago+nDesp )
   @  4, 40  GET  cTipo PICT "9" ;
             COMBO A_CONTR ;
             VALID cTipo$"12345" WHEN FMENS('')

   @  6, 11  GET  nCliente PICT "99999999" VALID fPESQCLI( nCliente, cTipo,;
                                                           cNumero, 6, 20 ) ;
             WHEN FMENS( 'Digite o Codigo do Cliente. F2 e F3=Clientes.' )

   IF lInclui
      @  6, 75  GET  cParcelado PICT "!" ;
                COMBO { "Vista","1 Cheque Pr‚","2 Banco",;
                        "3 Desc Folha","4 Outros" } ;
                VALID cParcelado$"V1234"  WHEN FMENS('')
   END

   @  8,  9  GET  nTotal  PICT "@E 9,999,999.99" ;
             VALID VLGERAL( nTotal-nDescto )  WHEN FMENS('')
   @  8, 34  GET  nDescto PICT "@E 9,999,999.99" VALID VLGERAL( nTotal-nDescto )
   @  8, 64  GET  nPago   PICT "@E 9,999,999.99";
             VALID VLGERAL( nPago+nDesp ) .AND. nPago==nTotal-nDescto
   @ 10, 25  GET  nDesp   PICT "@E 9,999,999.99" VALID VLGERAL( nPago+nDesp )  WHEN FMENS('')

   IF lInclui
      @ 12, 10  GET  cCheque PICT "@!" COMBO { "DINHEIRO" } WHEN cParcelado == "V"
      @ 12, 28  GET  cBanco   WHEN cParcelado == "V" .AND. cCheque != "DINHEIRO"
      @ 12, 48  GET  cAgencia WHEN cParcelado == "V" .AND. cCheque != "DINHEIRO"
      @ 12, 66  GET  cPraca   WHEN FMENS('') .AND. cParcelado == "V" .AND. cCheque != "DINHEIRO"
      dAssina := Date()
      dVencto := dAssina + 364
   END

   @ 14, 12  GET  nVendedor PICT "999" VALID PESQVEN( nVendedor, 14, 16 ) ;
             WHEN FMENS( 'Digite o Codigo do Vendedor. F4=Vendedores.' )

   @ 15, 15  GET  nCusto    PICT "999" VALID PESQCEN( nCusto, 15, 19 ) ;
             WHEN FMENS( 'Digite o Codigo do Centro de Custo. F6=Centro de Custo.' )

   @ 16, 19  GET  dAssina  WHEN FMENS('')
   @ 16, 43  GET  dVencto
   @ 16, 75  GET  cTipoCobra  PICT "9" ;
             COMBO { '1. Carteira','2. Banco','3. D‚bito em Conta','5. Encontro de Contas/Permuta','9. Outros' } ;
             VALID cTipoCobra$'12359'
   @ 18, 25  GET  nManut  PICT "@E 9,999,999.99"
   @ 19, 22  GET  nTitul  PICT "@E 9,999,999.99"
   @ 20, 26  GET  nDepDi  PICT "@E 9,999,999.99"
   @ 21, 26  GET  nDepIn  PICT "@E 9,999,999.99"
   @ 18, 64  GET  dApFat
   @ 19, 64  GET  dVeFat
   @ 20, 66  GET  dInc1
   @ 21, 64  GET  dInc2

   READ

   CONTRATO->(dbGoto( nII ))

   IF Lastkey() == K_ESC
      IF lInclui ; CONTRATO->(dbDelete()) ; END
      LOOP
   END

   IF Updated()
      IF ATENCAO( 'Confirma '+IF(lInclui,'INCLUSAO ?','ALTERA€AO ?'), {'Sim','Nao'}, SETCORES(2) ) == 1

         FMENS( 'AGUARDE... Atualizando arquivo...' )

         IF lInclui
            ACAO ( 'CADASTROU CONTRATO NUMERO ' + cNumero )
         ELSE
            ACAO ( 'ALTEROU CONTRATO NUMERO ' + cNumero )
         END

         CONTRATO->NUMERO      :=  cNumero
         CONTRATO->TIPO        :=  cTipo
         CONTRATO->CLIENTE     :=  StrZero( nCliente, 8, 0 )
         CONTRATO->PARCELADO   :=  cParcelado
         CONTRATO->VLTOTAL     :=  nTotal
         CONTRATO->VLDESCTO    :=  nDescto
         CONTRATO->VLPAGO      :=  nPago
         CONTRATO->VLDESP      :=  nDesp
         CONTRATO->CHEQUE      :=  cCheque
         CONTRATO->BANCO       :=  cBanco
         CONTRATO->AGENCIA     :=  cAgencia
         CONTRATO->PRACA       :=  cPraca
         CONTRATO->VENDEDOR    :=  StrZero( nVendedor, 3, 0 )
         CONTRATO->CCUSTO      :=  StrZero( nCusto, 3, 0 )
         CONTRATO->ASSINA      :=  dAssina
         CONTRATO->VENCTO      :=  dVencto
         CONTRATO->TIPOCOBRA   :=  cTipoCobra
         CONTRATO->VLMANUT     :=  nManut
         CONTRATO->VLTITUL     :=  nTitul
         CONTRATO->VLDEPDI     :=  nDepDi
         CONTRATO->VLDEPIN     :=  nDepIn
         CONTRATO->APRFATU     :=  dApFat
         CONTRATO->VECFATU     :=  dVeFat
         CONTRATO->DT1INC      :=  dInc1
         CONTRATO->DT2INC      :=  dInc2

         IF lInclui
            IF     cParcelado == "V"  // PAGAMENTO A VISTA
                   PAGVISTA( nPago+nDesp, cCheque, cBanco, cNumero )

            ELSEIF cParcelado == "1"  // CHEQUES PRE'
                   PAGCHEQU( nPago+nDesp, StrZero( nCliente, 8, 0 ),; 
                             dAssina, cNumero )

            ELSE  // OUTROS

            END
         END

      ELSE
         IF lInclui ; CONTRATO->(dbDelete()) ; END

      END

   ELSE
      IF lInclui ; CONTRATO->(dbDelete()) ; END

   END
   
END

RestScreen ( 0, 0, MaxRow(), MaxCol(), cTela )
SetColor( cCor )
SetCursor( nCursor )
RETURN

*****************************************
FUNCTION PESQVEN( nCod, nLinha, nColuna )
*****************************************
LOCAL lRet, nSele
IF LastKey() == K_UP .OR. LastKey() == K_PGUP
   lRet := TRUE

ELSE
   nSele := Select()
   SELE VENDEDOR
   SEEK StrZero( nCod, 3, 0 )
   lRet := FOUND()
   IF lRet ; @ nLinha, nColuna SAY VENDEDOR->NOME
   ELSE    ; @ nLinha, nColuna SAY SPACE( 35 )
   END
   Select( nSele )

END
RETURN lRet

**************************
FUNCTION VLGERAL( nValor )
**************************
@ 10, 64 SAY nValor PICT "@E 99,999,999.99" COLOR SETCORES(3)
RETURN TRUE

********************************************************
PROCEDURE PAGVISTA( nValor, cNumero, cBanCheq, cNumCon )
********************************************************
LOCAL cBanco := "    ", GETLIST := {}
FMENS('')
@ MAXROW()-1, 1 SAY SPACE(60)
WHILE TRUE
   @ MAXROW()-1, 1 SAY "Banco a Creditar: " GET cBanco PICT "@K 9999" ;
                      VALID fPESQBANCO( @cBanco, MAXROW()-1, 35 )
   READ
   IF LastKey() != K_ESC ; EXIT ; END
END   
LANCTO( cBanco, "C", nValor, 0, cNumero, cBanCheq,; 
        "PAGTO CONTRATO " + cNumCon )

RETURN

*********************************************************
PROCEDURE PAGCHEQU( nValor, cCodCli, dRecebe, cContrato )
*********************************************************
LOCAL cTela, aChequ := {}, nI, GETLIST := {}

cTela := ABRE( 8, 19, 19, 75 )

@  9, 25  SAY          "N§ Cheque   Banco               Valor  Data"
@ 11, 21  SAY "1" //    1234567890  xxxxx  999,999,999,999.99  99/99/9999"
@ 12, 21  SAY "2"
@ 13, 21  SAY "3"
@ 14, 21  SAY "4"
@ 15, 21  SAY "5"
@ 17, 37  SAY "Total:"
@ 18, 25  SAY nValor PICT "@E Valor do Contrato: 999,999,999,999.99"
@ 10, 20  TO 10, 74
@ 16, 20  TO 16, 74  

FOR nI := 1 TO 5
    AADD( aChequ, { Space(10), Space(5), 0, CTOD('') } )
NEXT

WHILE .T.
   FOR nI := 1 TO 5
       @ 10+nI, 25 GET aChequ[ nI ][ 1 ]
       @ 10+nI, 37 GET aChequ[ nI ][ 2 ]
       @ 10+nI, 44 GET aChequ[ nI ][ 3 ] PICT "@E 999,999,999,999.99";
                VALID SOMA( aChequ )
       @ 10+nI, 64 GET aChequ[ nI ][ 4 ]
   NEXT
   READ
   IF LastKey() != K_ESC
      SELE CHEQUES
      FOR nI := 1 TO 5
         IF !Empty( aChequ[ nI ][ 1 ] )
            NetAppBlank(0)
            CHEQUES->NUMERO   := aChequ[ nI ][ 1 ]
            CHEQUES->BANCO    := aChequ[ nI ][ 2 ]
            CHEQUES->VALOR    := aChequ[ nI ][ 3 ]
            CHEQUES->CLIFOR   := "C" + cCodCli
            CHEQUES->DTRECEBE := dRecebe
            CHEQUES->DTPAGAR  := aChequ[ nI ][ 4 ]
         END
      NEXT
      COMMIT
      UNLOCK
      EXIT
   END
END
FECHA( 8, 19, 19, 75, cTela )

*********************
FUNCTION SOMA( aMat )
*********************
LOCAL nSoma := 0, nI
FOR nI := 1 TO 5
    nSoma += aMat[ nI ][ 3 ]
NEXT
@ 17, 44 SAY nSoma  PICT "@E 999,999,999,999.99"
RETURN TRUE

*****************************************************************
STATIC FUNCTION fPESQCLI( nCod, cTipo, cNumCon, nLinha, nColuna )
*****************************************************************
LOCAL lRet, nSele, nReg
IF LastKey() == K_UP .OR. LastKey() == K_PGUP
   lRet := TRUE

ELSE
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
         lRet := IF( cTipo$"235", .T., .F. )
      ELSE    
         lRet := IF( cTipo$"14", .T., .F. )
      END

      IF !lRet
         ALERT( 'Este tipo de Contrato ‚ Incompat¡vel com o Cliente',;
             { 'Volta' } )

      ELSE
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

END
RETURN lRet

