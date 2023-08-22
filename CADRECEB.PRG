/***************

PROGRAMA: CADRECEB.prg

FUN€AO: CADASTRO DE CONTAS A RECEBER

AUTOR: Jorge Luis Bublitz

***************/

#include 'Meu.CH'
#include 'InKey.CH'
#include 'SetCurs.CH'
#include 'ComBo.CH'

*****************
PROCEDURE RECEBER()
*****************
LOCAL cTela, cTelaLimpa, cCor, nEscolha,;
      nII, nCursor, GETLIST := {},;
      lInclui, nOpcao, lAchou, cTelaParc, nReg, ;
      nNumero, cNumero,;
      nCodCli, cCodCli,;
      nCodCen, cCodCen,;
      nCodGru, cCodGru,;
      dEmissao, dVencto, cSitua, nValor, dPagto, nPagto, cDescri,;
      cDocto, cBanco,;
      nMulta, cTpMulta, nJuros, cTipo, cParc, nParc, dParcela, nParcela

cTela   := SaveScreen ( 0, 0, MaxRow(), MaxCol() )
nCursor := SetCursor( SC_NORMAL )
cCor    := SetColor( SETCORES(2) )

LIMPA( 4, 1, MaxRow()-3, MaxCol()-1 )

SELE RECEB
SET ORDER TO 1

@ 4, 1 SAY PADC ( 'CADASTRO DE CONTAS A RECEBER', 78 ) ;
       COLOR SETCORES(2)

@ 5, 1 SAY PADC ( 'ßßßßßßßßßßßßßßßßßßßßßßßßßßßß', 78 ) ;
       COLOR SETCORES(2)

@  6,  5  SAY "N£mero Lan‡amento:"
@  8,  5  SAY "   Cliente:"
@ 10,  5  SAY "          Grupo:"
@ 13,  5  SAY "Emissao:"
@ 13, 27  SAY "Vencimento:"
@ 14, 41  SAY "Documento:"
@ 15,  5  SAY "Situa‡ao:"
@ 15, 43  SAY "Valor:"
@ 17,  5  SAY "Multa:"
@ 17, 38  SAY "Juros:       %"
@ 17, 55  SAY "Per¡odo:"
@ 19,  5  SAY "Data de Pagamento:"
@ 19, 38  SAY "Valor Pago:"
@ 20, 47  SAY "%:"

FMENS('')

SETCOLOR( SETCORES(1) )

cTelaLimpa := SAVESCREEN ( 0, 0, MAXROW(), MAXCOL() )

WHILE TRUE

   UNLOCK
   COMMIT

   RESTSCREEN ( 0, 0, MAXROW(), MAXCOL(), cTelaLimpa )

   nNumero := 0

   SETCURSOR ( SC_NORMAL )

   @  6, 24 GET nNumero PICT '999999999999999' ;
            WHEN FMENS( 'Digite o C¢digo da Conta.' )

   READ

   IF LASTKEY() == K_ESC ; EXIT ; END

   SELE RECEB

   IF nNumero == 0
      lInclui := TRUE
      GO BOTTOM
      nNumero := Val( RECEB->NUMERO ) + 1

   ELSE
      lInclui := FALSE

   END

   cNumero := STRZERO( nNumero, 15, 0 )

   FMENS('')
   @ 6, 24 SAY cNumero COLOR SETCORES(3)

   SEEK cNumero

   lAchou := FOUND()

   IF !lAchou .AND. !lInclui
      IF ATENCAO( 'Lan‡amento Nao Cadastrado!;Deseja Incluir?',;
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
      RECEB->NUMERO := cNumero
      COMMIT
   ELSE
      IF !NetRLock()
         LOOP
      END
   END

   nII := RECEB->(RecNo())
   nCodCli  := Val( RECEB->CODCLI )
   nCodGru  := Val( RECEB->CODGRU )
   cCodCli  := RECEB->CODCLI
   cCodGru  := PAGAR->CODGRU
   dEmissao := RECEB->EMISSAO
   dVencto  := RECEB->VENCTO
   cSitua   := RECEB->SITUACAO
   nValor   := RECEB->VALOR
   dPagto   := RECEB->DTPAGTO
   nPagto   := RECEB->VLPAGTO
   nMulta   := RECEB->MULTA
   cTpMulta := RECEB->TPMULTA
   nJuros   := RECEB->JUROS
   cTipo    := RECEB->TIPO
   cDescri  := RECEB->DESCRICAO
   cDocto   := RECEB->DOCUMENTO

   IF !lInclui
      @  8, 17  SAY  cCodCli  PICT "99999999"
      PESQCLI( nCodCli, 8, 27 )
      @ 10, 22  SAY  cCodGru  PICT "999"
      PESQGRU( nCodGru, 10, 27 )
      @ 13, 14  SAY  dEmissao
      @ 13, 39  SAY  dVencto
      @ 13, 52  SAY  SubStr( cDescri, 1, 25 )
      @ 14, 52  SAY  cDocto    PICT "@!"
      @ 15, 15  SAY  cSitua
      PESQSIT( cSitua, 15, 18, "1234569" )
      @ 15, 50  SAY  nValor   PICT "@E 999,999,999,999.99"
      @ 17, 12  SAY  nMulta   PICT "@E 9,999,999.99"
      @ 17, 25  SAY  cTpMulta
      @ 17, 45  SAY  nJuros   PICT "@E 999.99"
      @ 17, 64  SAY  cTipo    PICT "!"

      IF ( !Empty( dPagto ) .AND. !Empty( nPagto ) )

         @ 19, 24  SAY  dPagto
         @ 19, 50  SAY  nPagto   PICT "@E 999,999,999,999.99"
         @ 20, 50  SAY 100*(nPagto-nValor)/nValor PICT "@E( 999.99"

         FMENS( 'Conta j  Baixada. Tecle Esc.' )
         InKey( 0 )
         LOOP
      END

      FMENS( 'Tecle Enter.' )
      InKey( 0 )
      FMENS('')

      nEscolha := ATENCAO( 'Deseja fazer:; ',;
                           {'Altera‡ao','Exclusao','Baixar','Volta' },;
                           SETCORES(1) )
      IF nEscolha == 2
         IF 'f'$M->cRight
            IF ATENCAO( 'Confirma Exclusao?; ',{'Nao','Sim'}, SETCORES(2) ) == 2
               FMENS( 'AGUARDE... Excluindo Conta...' )
               RECEB->(dbDelete())
               ACAO( 'EXCLUIU CONTA / RECEB N. ' + cNumero )
            END
         ELSE
            ACAO( 'TENTOU EXCLUIR CONTA / RECEB N. ' + cNumero )
            ATENCAO( 'ACESSO NEGADO!' )
         END

      ELSEIF nEscolha == 3   // BAIXAR
         IF 'g'$M->cRight
            IF ATENCAO ( 'Confirma Baixa ?', {'Nao','Sim'}, SETCORES(2) ) == 2
               dPagto := Date()

               IF DATE() > dVencto  // SE JA VENCEU
                  nPagto := nValor*( 1+nMulta/100 ) // MULTA
                  IF     cTipo == '1' // JUROS AO DIA
                         nPagto += nPagto*Exp( (DATE()-dVencto) * Log( nJuros ) )

                  ELSEIF cTipo == '2' // JUROS AO MES
                         nPagto += nPagto*Exp( (Month( DATE())-Month(dVencto)) * Log( nJuros ) )

                  ELSEIF cTipo == '3' // JUROS AO MES
                         nPagto += nPagto*Exp( (Year( DATE())-Year(dVencto)) * Log( nJuros ) )

                  END

               ELSE
                  nPagto := nValor

               END


               SELE RECEB
//               IF ATENCAO( 'Pagamento',{' TOTAL ',' PARCIAL '}, SETCORES(2) ) == 1
               IF .T. // PAGAMENTO TOTAL

                  WHILE .T.
                     @ 19, 24  GET dPagto VALID !Empty( dPagto )
                     @ 19, 50  GET nPagto PICT "@E 999,999,999,999.99" ;
                               VALID !Empty( nPagto )
                     READ

                     IF LastKey() == K_ESC ; EXIT ; END

                     @ 20, 50  SAY 100*(nPagto-nValor)/nValor PICT "@E( 999.99"
                     RECEB->(dbGoto( nII ))
                     RECEB->DTPAGTO  := dPagto
                     RECEB->VLPAGTO  := nPagto

                     LANCAIXA( dPagto, RECEB->DESCRICAO, nPagto, 0 )

                     ACAO( 'BAIXOU CONTA / RECEB N. ' + cNumero )
                     EXIT
                  END
                  cBanco := "    "
                  FMENS('')
                  WHILE TRUE
                     @ MAXROW()-1, 1 SAY "Banco a Creditar: ";
                                     GET cBanco PICT "@K 9999" ;
                                     VALID Val( cBanco ) == 0 .OR. ;
                                     fPESQBANCO( @cBanco, MAXROW()-1, 25 )
                     READ
                     IF LastKey() != K_ESC ; EXIT ; END
                  END

//                LANCTO( cBanco, "D", nPagto, 0, "", "", "PAGTO CONTA "+cNumero )
                  IF Val( cBanco ) != 0
                     LANCTO( cBanco, "C", nPagto, 0, "", "", PAGAR->DESCRICAO )
                  END


               ELSE
                  IF ATENCAO( 'Confirma Pagamento PARCIAL ?' , { 'Nao','Sim' }, SETCORES(1) ) == 2
                        // CONFIRMOU PAGAMENTO PARCIAL
                        // MOSTRAR PARCELAS EM UM JANELA
                        // PEDIR O NOVO VALOR DA CONTA

                        cParc := REPARCIAL( cNumero, @nValor, @dPagto, @nPagto )
                        IF !Empty( cParc )
                           RECEB->VALOR    := nValor
                           // RECEB->DTPAGTO  := dPagto
                           // RECEB->VLPAGTO  := nPagto
                           ACAO( 'PARCELAMENTO DA CONTA / RECEB N. ' + cNumero )
                        END

                  END

               END
            END
         ELSE
            ACAO( 'TENTOU BAIXAR CONTA / RECEB N. ' + cNumero )
            ATENCAO( 'ACESSO NEGADO!' )
         END
      END

      IF nEscolha != 1 ; LOOP ;  END

   END

   FMENS('')

   @  8, 17  GET nCodCli   PICT "99999999" VALID PESQCLI( nCodCli, 8, 27 ) ;
             WHEN FMENS( 'Digite o C¢digo do Cliente. F2=Clientes.' )

   @ 10, 22  GET nCodGru   PICT "999"      VALID PESQGRU( nCodGru, 10, 27 ) ;
             WHEN FMENS( 'Digite o C¢digo do Grupo de Contas. F10=Grupos.' )

   @ 13, 14  GET dEmissao  VALID !Empty( dEmissao ) WHEN FMENS('')
   @ 13, 39  GET dVencto   VALID dVencto >= dEmissao
   @ 13, 52  GET cDescri   PICT "@!S25"
   @ 14, 52  GET cDocto    PICT "@!"
   @ 15, 15  GET cSitua    PICT "!" COMBO A_SITUA ;
             VALID PESQSIT( cSitua, 15, 18, "1234569" )
   @ 15, 50  GET nValor    PICT "@E 999,999,999,999.99" VALID !Empty( nValor )
   @ 17, 12  GET  nMulta   PICT "@E 9,999,999.99"
   @ 17, 25  GET  cTpMulta COMBO { "% Porcentagem","$ Valor" } ;
                  VALID cTpMulta$"%$"
   @ 17, 45  GET  nJuros   PICT "@E 999.99"
   @ 17, 64  GET  cTipo    PICT "!" COMBO { '1. Ao Dia','2. Ao Mˆs','3. Ao Ano' }
   READ

   RECEB->(dbGoto( nII ))

   IF LastKey() == K_ESC
      IF lInclui ; RECEB->(dbDelete()) ; END
      LOOP
   END

   IF UPDATED()
      IF ATENCAO( 'Confirma '+IF(lInclui,'Inclusao ?','Altera‡ao ?'),;
                {'Sim','Nao'}, SETCORES(2) ) == 1

         RECEB->NUMERO   := cNumero
         RECEB->CODCLI   := StrZero( nCodCli, 8, 0 )
         RECEB->CODGRU   := StrZero( nCodGru, 3, 0 )
         RECEB->EMISSAO  := dEmissao
         RECEB->VENCTO   := dVencto
         RECEB->SITUACAO := cSitua
         RECEB->VALOR    := nValor
         RECEB->MULTA    := nMulta
         RECEB->TPMULTA  := cTpMulta
         RECEB->JUROS    := nJuros
         RECEB->TIPO     := cTipo
         RECEB->DESCRICAO := cDescri
         RECEB->DOCUMENTO := cDocto

         IF lInclui
            ACAO( 'CADASTROU CONTA / RECEB N. ' + cNumero )
         ELSE
            ACAO( 'ALTEROU CONTA / RECEB N. ' + cNumero )
         END

      ELSE
         IF lInclui ; RECEB->(dbDelete()) ; END

      END

   ELSE
      IF lInclui ; RECEB->(dbDelete()) ; END

   END

END

RESTSCREEN ( 0, 0, MAXROW(), MAXCOL(), cTela )
SETCOLOR( cCor )
SETCURSOR( nCursor )
RETURN

*****************************************
FUNCTION PESQCLI( nCod, nLinha, nColuna )
*****************************************
LOCAL lRet, nSele
IF LastKey() == K_UP .OR. LastKey() == K_PGUP
   lRet := TRUE

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