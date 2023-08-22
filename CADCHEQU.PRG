/***************

PROGRAMA: CADCHEQU.prg

FUN€AO: CADASTRO DE CHEQUES

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'
#include 'COMBO.ch'

*******************
PROCEDURE CHEQUES()
*******************
LOCAL cTela, cTelaLimpa, cCor, nEscolha,;
      nII, nCursor, GETLIST := {},;
      lInclui, nOpcao, lAchou, cCod, cHist,;
      nCliFor, cCliFor, cNumero, nBanco, cBanco, dDtRecebe, dDtPagar, nValor
      
cTela   := SAVESCREEN ( 0, 0, MAXROW(), MAXCOL() )
nCursor := SETCURSOR( SC_NORMAL )
cCor    := SETCOLOR( SETCORES(2) )

LIMPA( 4, 1, MAXROW()-3, MAXCOL()-1 )

SELE CHEQUES

@ 4, 1 SAY PADC ( 'CADASTRO DE CHEQUES', 78 ) ;
       COLOR SETCORES(2)

@ 5, 1 SAY PADC ( 'ßßßßßßßßßßßßßßßßßßß', 78 ) ;
       COLOR SETCORES(2)

@  8,  5  SAY "Cliente/Fornecedor:"
@  8, 34  SAY "-" //  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
@ 10,  5  SAY "Numero Cheque:"
@ 12,  5  SAY "Banco:"
@ 12, 19  SAY "-" //  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
@ 14,  5  SAY "Data Emissao:"
@ 14, 31  SAY "Bom Para:"
@ 16,  5  SAY "Valor:"
@ 18,  5  SAY "Historico:"
FMENS('')

SETCOLOR( SETCORES(1) )

cTelaLimpa := SAVESCREEN ( 0, 0, MAXROW(), MAXCOL() )

WHILE .T.

   UNLOCK
   COMMIT

   RESTSCREEN ( 0, 0, MAXROW(), MAXCOL(), cTelaLimpa )

   SETCURSOR ( SC_NORMAL )

   cNumero := SPACE( 10 )
   cBanco  := SPACE( 5 )
   cCod    := SPACE( 1 )
   nCliFor := 0
   
   @  8, 25 GET cCod PICT "!" ;
            COMBO { "Cliente","Fornecedor" } ;
            WHEN FMENS( 'Digite [C] para Clientes e [F] para Fornecedor' ) ;
            VALID cCod$'CF'
            
   @  8, 27 GET nCliFor PICT '99999999' ;
            WHEN FMENS( IF( cCod == 'C',;
                 'Digite o C¢digo do Cliente. F2=Clientes.' ,;
                 'Digite o C¢digo do Fornecedor. F7=Fornecedores.')) ;
            VALID CLIFOR( cCod, nCliFor )

   @ 10, 20 GET cNumero PICT "@!" ;
            WHEN FMENS( 'Digite o N£mero do Cheque.' )

   @ 12, 12 GET cBanco PICT "@!" ;
            WHEN FMENS( 'Digite o N£mero do Banco.' ) ;
            VALID CHECA( cCod, @cBanco )
   READ

   IF LASTKEY() == K_ESC ; EXIT ; END

   cCliFor := cCod + StrZero( nCliFor, 8, 0 )

   SELE CHEQUES
   SEEK cCliFor + cNumero + cBanco
   
   lAchou := FOUND()
   
   lInclui := !lAchou
      
   IF lInclui
      IF !NetAppBlank()
         LOOP
      END
      CHEQUES->NUMERO   := cNumero
      CHEQUES->BANCO    := cBanco
      CHEQUES->CLIFOR   := cCliFor
   ELSE
      IF !NetRLock()
         LOOP
      END
   END

   nII := CHEQUES->(RecNo())
   dDtRecebe := CHEQUES->DTRECEBE
   dDtPagar  := CHEQUES->DTPAGAR
   nValor    := CHEQUES->VALOR
   cHist     := CHEQUES->HISTORICO
      
   IF !lInclui

      @ 14, 19  SAY  dDtRecebe
      @ 14, 41  SAY  dDtPagar
      @ 16, 12  SAY  nValor    PICT "@E 999,999,999,999.99"
      @ 18, 16  SAY  cHist     PICT "@!"
      
      FMENS( 'Tecle [[ ENTER ]] !' )
      INKEY(0)
      FMENS('')      
      
      IF !EMPTY( CHEQUES->DTRECEBEU )
         ATENCAO( 'Cheque ja foi pago!', {'Volta'}, SETCORES(1) )
         LOOP
      END

      nEscolha := ATENCAO( 'Deseja fazer:; ', {'Alteracao','Exclusao','Confirmar','Volta' },;
                         SETCORES(1) )
      IF nEscolha == 2
         IF ATENCAO( 'Confirma Exclusao?; ',{'Nao','Sim'}, SETCORES(2) ) == 2
            IF '6'$M->cRight
               CHEQUES->(dbDelete())
               ACAO('EXCLUI CHEQUE N. '+ cNumero +', BANCO: '+ cBanco +', CLI/FOR:'+ cCliFor )
            ELSE
               ACAO('TENTOU EXCLUIR CHEQUE N. '+ cNumero +', BANCO: '+ cBanco +', CLI/FOR:'+ cCliFor )
            END
         END
         
      ELSEIF nEscolha == 3
             CONF()
             LOOP
             
      ELSEIF nEscolha != 1
             LOOP

      END

   END

   FMENS('')
   @ 14, 19  GET  dDtRecebe
   @ 14, 41  GET  dDtPagar
   @ 16, 12  GET  nValor    PICT "@E 999,999,999,999.99"
   @ 18, 16  GET  cHist     PICT "@!"
   READ
   
   CHEQUES->(dbGoto( nII ))

   IF LastKey() == K_ESC
      IF lInclui ; CHEQUES->(dbDelete()) ; END
      LOOP
   END
   
   IF Updated()
      IF ATENCAO( 'Confirma '+IF(lInclui,'INCLUSAO ?','ALTERACAO ?'),;
                {'Sim','Nao'}, SETCORES(2) ) == 1

         CHEQUES->NUMERO    := cNumero
         CHEQUES->BANCO     := cBanco
         CHEQUES->DTRECEBE  := dDtRecebe
         CHEQUES->DTPAGAR   := dDtPagar
         CHEQUES->VALOR     := nValor
         CHEQUES->CLIFOR    := cCliFor
         CHEQUES->HISTORICO := cHist
         IF lInclui
            ACAO('CADASTROU CHEQUE N. '+ cNumero +', BANCO: '+ cBanco +', CLI/FOR:'+ cCliFor )
         ELSE
            ACAO('ALTEROU CHEQUE N. '+ cNumero +', BANCO: '+ cBanco +', CLI/FOR:'+ cCliFor )
         END         
      ELSE
         IF lInclui ; CHEQUES->(dbDelete()) ; END

      END

   ELSE
      IF lInclui ; CHEQUES->(dbDelete()) ; END

   END
  
END

RESTSCREEN ( 0, 0, MAXROW(), MAXCOL(), cTela )
SETCOLOR( cCor )
SETCURSOR( nCursor )
RETURN

*****************************
static PROCEDURE LANCAIXA( lInclui )
*****************************
IF lInclui
   SELE CAIXA
   NetAppBlank( 0 )
   CAIXA->DATA := DATE()
   CAIXA->HISTORICO := "CHEQ N. " + CHEQUES->NUMERO + ", BANCO " + ;
                       CHEQUES->BANCO + ", CLI/FOR: " + CHEQUES->CLIFOR
   IF CHEQUES->CLIFOR = "C"
      CAIXA->ENTRADA := CHEQUES->VALOR
   ELSE
      CAIXA->SAIDA   := CHEQUES->VALOR
   END
   
ELSE
   SELE CAIXA
   GO TOP
   WHILE !EOF()
      IF CAIXA->HISTORICO = "CHEQ N. " + CHEQUES->NUMERO + ", BANCO " + ;
                       CHEQUES->BANCO + ", CLI/FOR: " + CHEQUES->CLIFOR
                       
         NetRLock( 0 )
         IF CHEQUES->CLIFOR = "C"
            CAIXA->ENTRADA := CHEQUES->VALOR
         ELSE
            CAIXA->SAIDA   := CHEQUES->VALOR
         END
         EXIT
      END
      SKIP
   END
END
RETURN


***************************
FUNCTION CLIFOR ( cCod, nCod )
***************************
LOCAL lRet

IF     cCod == "C"
       SELE CLIENTES

ELSEIF cCod == "F"
       SELE FORNEC

END      

SEEK StrZero( nCod, 8, 0 )
lRet := FOUND()

IF lRet
   IF     cCod == "C"
          @  8, 37  SAY CLIENTES->NOME

   ELSEIF cCod == "F"
          @  8, 37  SAY FORNEC->NOME

   END      

ELSE
          @  8, 37  SAY SPACE( 40 ) COLOR SETCORES(1)

END

RETURN lRet



****************************
FUNCTION CHECA( cCod, cBan )
****************************
LOCAL lRet := FALSE
IF cCod == "F"
   IF SubStr( cBan, 1, 1 ) == "B"
      SELE BANCOS
      cBan := "B" + STRZERO( VAL( SUBSTR( cBan, 2 ) ), 4, 0 )
      SEEK SubStr( cBan, 2 )
      lRet := FOUND()
      @ 12, 22  SAY BANCOS->NOME
   END
ELSE ; lRet := TRUE
END
RETURN lRet


****************
PROCEDURE CONF()
****************
LOCAL cBanco, cTipo, GETLIST := {}
IF ATENCAO( 'Confirma '+IF(SUBSTR(CHEQUES->CLIFOR,1,1) = "C","Recebimento?","Pagamento?"),;
            { 'Nao','Sim' }, SETCORES(1) ) == 2
   CHEQUES->DTRECEBEU := DATE()
   IF SUBSTR(CHEQUES->CLIFOR,1,1) = "C" // PEDE BANCO
      cBanco := "    "
      FMENS('')
      WHILE TRUE
         @ MAXROW()-1, 1 SAY "Banco a Creditar: " GET cBanco PICT "@K 9999" ;
                      VALID fPESQBANCO( @cBanco, MAXROW()-1, 25 )
         READ
         IF LastKey() != K_ESC ; EXIT ; END
      END
      cTipo  := "C"
   ELSE
      cBanco := STRZERO( VAL( SUBSTR( CHEQUES->BANCO, 2 )), 4, 0 )
      cTipo  := "D"
   END
   LANCTO( cBanco, cTipo, CHEQUES->VALOR, 0, CHEQUES->NUMERO,; 
           CHEQUES->BANCO, "CHEQUE COMPENSADO " + CHEQUES->CLIFOR )
END   

RETURN


*****************************************************
PROCEDURE LANCTO( cBanco, cTipo, nValor1, nValor2,;
                  cNumCheque, cNumBanco, cHistorico )
*****************************************************
LOCAL cNumero
SELE LANCTOS
SET ORDER TO 1
GO BOTTOM
cNumero := STRZERO( VAL( LANCTOS->NUMERO ) + 1, 10, 0 )
NetAppBlank( 0 )
LANCTOS->NUMERO    := cNumero
LANCTOS->BANCO     := cBanco
LANCTOS->TIPO      := cTipo
LANCTOS->DATA      := DATE()
LANCTOS->VALOR     := nValor1 + nValor2
LANCTOS->NUMCHEQUE := cNumCheque
LANCTOS->NUMBANCO  := cNumBanco
LANCTOS->HISTORICO := cHistorico
        
SELE BANCOS
SEEK cBanco
IF FOUND()
   NetRLock(0)
   BANCOS->SALDODISP += IF ( cTipo=="C", nValor1, -nValor1 )
   BANCOS->SALDOVINC += IF ( cTipo=="C", nValor2, -nValor2 )
   SALDO( cBanco, DATE(), IF ( cTipo=="C", nValor1, -nValor1 ),; 
       IF ( cTipo=="C", nValor2, -nValor2 ) )
END
UNLOCK
COMMIT
RETURN


*********************************
FUNCTION fPESQBANCO( cCodigo,L,C)
*********************************
LOCAL lRet, nSele
nSele := Select()
SELE BANCOS
cCodigo := StrZero( Val( cCodigo ), 4, 0 )
SEEK cCodigo
lRet := Found()
@ L, C SAY IF(lRet, BANCOS->NOME, Space( 35 ) )
Select( nSele )
RETURN lRet
