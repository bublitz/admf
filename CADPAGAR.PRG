/***************

PROGRAMA: CADPAGAR.prg

FUN€AO: CADASTRO DE CONTAS A PAGAR

AUTOR: Jorge Luis Bublitz

***************/

#include 'Meu.CH'
#include 'InKey.CH'
#include 'SetCurs.CH'
#include 'ComBo.CH'

*****************
PROCEDURE PAGAR()
*****************
LOCAL cTela, cTelaLimpa, cCor, nEscolha,;
      nII, nCursor, GETLIST := {},;
      lInclui, nOpcao, lAchou, cTelaParc, nReg, ;
      nNumero, cNumero,;
      nCodFor, cCodFor,;
      nCodCen, cCodCen,;
      nCodGru, cCodGru,;
      dEmissao, dVencto, cSitua, nValor, dPagto, nPagto, cDescri,;
      nMulta, cTpMulta, nJuros, cTipo, cParc, nParc, dParcela, nParcela,;
      cTelaCheque, cCheque, cBanco, cDocto

cTela   := SaveScreen ( 0, 0, MaxRow(), MaxCol() )
nCursor := SetCursor( SC_NORMAL )
cCor    := SetColor( SETCORES(2) )

LIMPA( 4, 1, MaxRow()-3, MaxCol()-1 )

SELE PAGAR
SET ORDER TO 1

@ 4, 1 SAY PADC ( 'CADASTRO DE CONTAS A PAGAR', 78 ) ;
       COLOR SETCORES(2)

@ 5, 1 SAY PADC ( 'ßßßßßßßßßßßßßßßßßßßßßßßßßß', 78 ) ;
       COLOR SETCORES(2)

@  6,  5  SAY "N£mero Lan‡amento:"
@  8,  5  SAY "Fornecedor:"
@ 10,  5  SAY "          Grupo:"
@ 13,  5  SAY "Emissao:"
@ 13, 27  SAY "Vencimento:"
@ 14, 41  SAY "Documento:"
@ 15,  5  SAY "Situa‡ao:"
@ 15, 43  SAY "Valor:"
@ 17,  5  SAY "Multa:"
//@ 17,  5  SAY "Multa:       %"
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

   SELE PAGAR

   IF nNumero == 0
      lInclui := TRUE
      GO BOTTOM
      nNumero := Val( PAGAR->NUMERO ) + 1

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
      PAGAR->NUMERO := cNumero
      COMMIT
   ELSE
      IF !NetRLock()
         LOOP
      END
   END

   nII := PAGAR->(RecNo())
   nCodFor  := Val( PAGAR->CODFOR )
   nCodGru  := Val( PAGAR->CODGRU )
   cCodFor  := PAGAR->CODFOR
   cCodGru  := PAGAR->CODGRU
   dEmissao := PAGAR->EMISSAO
   dVencto  := PAGAR->VENCTO
   cSitua   := PAGAR->SITUACAO
   nValor   := PAGAR->VALOR
   dPagto   := PAGAR->DTPAGTO
   nPagto   := PAGAR->VLPAGTO
   nMulta   := PAGAR->MULTA
   cTpMulta := PAGAR->TPMULTA
   nJuros   := PAGAR->JUROS
   cTipo    := PAGAR->TIPO
   cDescri  := PAGAR->DESCRICAO
   cDocto   := PAGAR->DOCUMENTO

   IF !lInclui
      @  8, 17  SAY  cCodFor  PICT "99999999"
      PESQFOR( nCodFor, 8, 27 )
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
                           {'Altera‡ao','Exclusao','Baixar','Cheque','Volta' },;
                           SETCORES(1) )
      IF nEscolha == 2
         IF 'f'$M->cRight
            IF ATENCAO( 'Confirma Exclusao?; ',{'Nao','Sim'}, SETCORES(2) ) == 2
               FMENS( 'AGUARDE... Excluindo Conta...' )
               SELE PAGAR
               NetRLock( 0 )
               PAGAR->(dbDelete())
               ACAO( 'EXCLUIU CONTA / PAGAR N. ' + cNumero )
            END
         ELSE
            ACAO( 'TENTOU EXCLUIR CONTA / PAGAR N. ' + cNumero )
            ATENCAO( 'ACESSO NEGADO!' )
         END

      ELSEIF nEscolha == 4   // CHEQUE
             IF !Empty( PAGAR->CHEQUE ) .AND. ;
                ALERT( 'Cheque ja cadastrado!;Deseja renovar ?',;
                          { 'Nao','Sim' }, SETCORES(3) ) != 2
                LOOP
             END
             
             cTelaCheque := ABRE( 15, 20, 21, 74, TRUE )
             @ 15, 21 SAY "CHEQUE" COLOR "W+/W"
             cCheque := PAGAR->CHEQUE
             cBanco  := PAGAR->BANCO
             @ 16, 22 SAY "Cheque:" GET cCheque PICT "9999999999"
             @ 18, 22 SAY "Banco:"  GET cBanco  PICT "@K 9999" ;
                      VALID fPESQBANCO( @cBanco, 18, 35)
             @ 20, 22 say "Valor:"  GET nValor PICT "@E 999,999,999,999.99"
             READ
             SELE CHEQUES
             SET ORDER TO 2
             SEEK cCheque + "B" + cBanco

             IF FOUND()
                ALERT( 'Cheque ja cadastrado!', {'VOLTA'} )
                LOOP
             END
             
             SET ORDER TO 1
             SELE PAGAR
             IF ATENCAO( "Confirma Cadastramento do Cheque?", ;
                          { 'Nao','Sim' }, SETCORES(3) ) == 2

                // CADASTRA CHEQUE
                PAGAR->CHEQUE := cCheque
                PAGAR->BANCO := cBanco 
                
                SELE CHEQUES
                NetAppBlank( 0 )
                CHEQUES->NUMERO    := cCheque
                CHEQUES->BANCO     := "B" + cBanco
                CHEQUES->DTRECEBE  := CHEQUES->DTPAGAR := DATE()
                CHEQUES->VALOR     := nValor
                CHEQUES->CLIFOR    := "F" + cCodFor
                CHEQUES->HISTORICO := "PAGTO CONTA PAGAR " + cNumero
                ACAO('CADASTROU CHEQUE N. '+ cCheque +', BANCO: '+ cBanco +', Fornec '+ cCodFor )
                COMMIT
                
             END
             
             SELE PAGAR
             
             FECHA( 15, 20, 21, 74, cTelaCheque, TRUE )
             LOOP
             
      ELSEIF nEscolha == 3   // BAIXAR
         IF 'g'$M->cRight
            IF ATENCAO ( 'Confirma Baixa ?', {'Nao','Sim'}, SETCORES(2) ) == 2
               dPagto := Date()

               IF DATE() > dVencto  // SE JA VENCEU
                   nPagto := VLFUTURO( nValor, nMulta, cTpMulta, nJuros, cTipo, dVencto )

               ELSE
                  nPagto := nValor

               END

               SELE PAGAR
//               IF ATENCAO( 'Pagamento',{' TOTAL ',' PARCIAL '}, SETCORES(2) ) == 1
               IF .T. // PAGAMENTO TOTAL

                  WHILE .T.
                     @ 19, 24  GET dPagto VALID !Empty( dPagto )
                     @ 19, 50  GET nPagto PICT "@E 999,999,999,999.99" ;
                               VALID !Empty( nPagto )
                     READ

                     IF LastKey() == K_ESC ; EXIT ; END

                     @ 20, 50  SAY 100*(nPagto-nValor)/nValor PICT "@E( 999.99"
                     PAGAR->(dbGoto( nII ))
                     PAGAR->DTPAGTO  := dPagto
                     PAGAR->VLPAGTO  := nPagto

                     LANCAIXA( dPagto, PAGAR->DESCRICAO, 0, nPagto )

                     ACAO( 'BAIXOU CONTA / PAGAR N. ' + cNumero )
                     IF !Empty( PAGAR->CHEQUE )
                        ALERT( 'NAO SE ESQUECA DE;BAIXAR O CHEQUE;N. '+;
                               PAGAR->CHEQUE+";BANCO: "+PAGAR->BANCO )

                     ELSE
                        cBanco := "    "
                        FMENS('')
                        WHILE TRUE
                           @ MAXROW()-1, 1 SAY "Banco a Debitar: ";
                                           GET cBanco PICT "@K 9999" ;
                                           VALID Val( cBanco ) == 0 .OR. ;
                                           fPESQBANCO( @cBanco, MAXROW()-1, 25 )
                           READ
                           IF LastKey() != K_ESC ; EXIT ; END
                        END

//                        LANCTO( cBanco, "D", nPagto, 0, "", "", "PAGTO CONTA "+cNumero )
                        IF Val( cBanco ) != 0
                           LANCTO( cBanco, "D", nPagto, 0, "", "", PAGAR->DESCRICAO )
                        END

                     END
                     EXIT
                  END

               ELSE
                  IF ATENCAO( 'Confirma Pagamento PARCIAL ?' , { 'Nao','Sim' }, SETCORES(1) ) == 2
                        // CONFIRMOU PAGAMENTO PARCIAL
                        // MOSTRAR PARCELAS EM UM JANELA
                        // PEDIR O NOVO VALOR DA CONTA

                        cParc := PAPARCIAL( cNumero, @nValor, @dPagto, @nPagto )
                        IF !Empty( cParc )
                           PAGAR->VALOR    := nValor
                           // PAGAR->DTPAGTO  := dPagto
                           // PAGAR->VLPAGTO  := nPagto
                           ACAO( 'PARCELAMENTO DA CONTA / PAGAR N. ' + cNumero )
                        END

                  END

               END
            END
         ELSE
            ACAO( 'TENTOU BAIXAR CONTA / PAGAR N. ' + cNumero )
            ATENCAO( 'ACESSO NEGADO!' )
         END
      END

      IF nEscolha != 1 ; LOOP ;  END

   END

   @  8, 17  GET nCodFor   PICT "99999999" VALID PESQFOR( nCodFor, 8, 27 ) ;
             WHEN FMENS( 'Digite o C¢digo do Fornecedor. F7=Fornecedores.' )

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

   PAGAR->(dbGoto( nII ))

   IF LastKey() == K_ESC
      IF lInclui 
         SELE PAGAR
         NetRLock(0)
         PAGAR->(dbDelete()) 
      END
      LOOP
   END

   IF UPDATED()
      IF ATENCAO( 'Confirma '+IF(lInclui,'Inclusao ?','Altera‡ao ?'),;
                {'Sim','Nao'}, SETCORES(2) ) == 1

         PAGAR->NUMERO   := cNumero
         PAGAR->CODFOR   := StrZero( nCodFor, 8, 0 )
         PAGAR->CODGRU   := StrZero( nCodGru, 3, 0 )
         PAGAR->EMISSAO  := dEmissao
         PAGAR->VENCTO   := dVencto
         PAGAR->SITUACAO := cSitua
         PAGAR->VALOR    := nValor
         PAGAR->MULTA    := nMulta
         PAGAR->TPMULTA  := cTpMulta
         PAGAR->JUROS    := nJuros
         PAGAR->TIPO     := cTipo
         PAGAR->DESCRICAO := cDescri
         PAGAR->DOCUMENTO := cDocto

         IF lInclui
            ACAO( 'CADASTROU CONTA / PAGAR N. ' + cNumero )
         ELSE
            ACAO( 'ALTEROU CONTA / PAGAR N. ' + cNumero )
         END

      ELSE
         IF lInclui 
            SELE PAGAR
            NetRLock(0)
            PAGAR->(dbDelete()) 
         END

      END

   ELSE
      IF lInclui 
         SELE PAGAR
         NetRLock(0)
         PAGAR->(dbDelete()) 
      END

   END

END

RESTSCREEN ( 0, 0, MAXROW(), MAXCOL(), cTela )
SETCOLOR( cCor )
SETCURSOR( nCursor )
RETURN

*****************************************
FUNCTION PESQFOR( nCod, nLinha, nColuna )
*****************************************
LOCAL lRet, nSele
IF LastKey() == K_UP .OR. LastKey() == K_PGUP
   lRet := TRUE

ELSE
   nSele := Select()
   SELE FORNEC
   SEEK StrZero( nCod, 8, 0 )
   lRet := FOUND()
   IF lRet ; @ nLinha, nColuna SAY FORNEC->NOME
   ELSE    ; @ nLinha, nColuna SAY SPACE( 40 )
   END
   Select( nSele )

END
RETURN lRet

*****************************************
FUNCTION PESQCEN( nCod, nLinha, nColuna )
*****************************************
LOCAL lRet, nSele
IF LastKey() == K_UP .OR. LastKey() == K_PGUP
   lRet := TRUE

ELSE
   nSele := Select()
   SELE CCUSTO
   SEEK StrZero( nCod, 3, 0 )
   lRet := FOUND()
   IF lRet ; @ nLinha, nColuna SAY CCUSTO->NOME
   ELSE    ; @ nLinha, nColuna SAY SPACE( 35 )
   END
   Select( nSele )

END
RETURN lRet

*****************************************
FUNCTION PESQGRU( nCod, nLinha, nColuna )
*****************************************
LOCAL lRet, nSele
IF LastKey() == K_UP .OR. LastKey() == K_PGUP
   lRet := TRUE

ELSE
   nSele := Select()
   SELE GRUPOS
   SEEK StrZero( nCod, 3, 0 )
   lRet := FOUND()
   IF lRet ; @ nLinha, nColuna SAY GRUPOS->NOME
   ELSE    ; @ nLinha, nColuna SAY SPACE( 35 )
   END
   Select( nSele )

END
RETURN lRet

***************************************************
FUNCTION PESQSIT( cSitua, nLinha, nColuna, cValid )
***************************************************
IF cSitua $ cValid
   @ nLinha, nColuna SAY Pad( SubStr( A_SITUA [ Val( cSitua ) ], 3 ), 20 )
ELSE
   @ nLinha, nColuna SAY Space( 20 )
END
RETURN TRUE

*********************************************************************
FUNCTION VLFUTURO( nValor, nMulta, cTpMulta, nJuros, cTipo, dVencto )
*********************************************************************
LOCAL nPagto, nPeriodos := 0
ALTD()
IF cTpMulta == "$"
   nPagto := nValor + nMulta
ELSE
   nPagto := nValor*( 1+nMulta/100 ) // MULTA
END

IF     cTipo == '1' // JUROS AO DIA
       nPeriodos := DATE()-dVencto
//       nPagto := nPagto*Exp( ( DATE()-dVencto ) * Log( nJuros ) )

ELSEIF cTipo == '2' // JUROS AO MES
       nPeriodos := Month( DATE())-Month(dVencto)
//       nPagto := nPagto*Exp( (Month( DATE())-Month(dVencto)) * Log( nJuros ) )

ELSEIF cTipo == '3' // JUROS AO MES
       nPeriodos := Year( DATE()) - Year(dVencto)
//       nPagto := nPagto*Exp( (Year( DATE())-Year(dVencto)) * Log( nJuros ) )

END

IF nPeriodos > 0
   nPagto := nPagto*Exp( ( nPeriodos ) * Log( 1+nJuros/100 ) )
END

RETURN nPagto
