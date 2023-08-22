/***************

PROGRAMA: CADBANCO.prg

FUN€AO: CADASTRO DE BANCOS

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'

******************
PROCEDURE BANCOS()
******************
LOCAL cTela, cTelaLimpa, cCor, nEscolha,;
      nII, nCursor, GETLIST := {},;
      lInclui, nOpcao, lAchou,;
      cCodigo, nCodigo, cNome, cNumAgencia, cNomAgencia,;
      cNumConta, nSaldoDisp, nSaldoVinc
      
cTela   := SAVESCREEN ( 0, 0, MAXROW(), MAXCOL() )
nCursor := SETCURSOR( SC_NORMAL )
cCor    := SETCOLOR( SETCORES(2) )

LIMPA( 4, 1, MAXROW()-3, MAXCOL()-1 )

SELE BANCOS

@ 4, 1 SAY PADC ( 'CADASTRO DE BANCOS', 78 ) ;
       COLOR SETCORES(2)

@ 5, 1 SAY PADC ( 'ßßßßßßßßßßßßßßßßßß', 78 ) ;
       COLOR SETCORES(2)

@ 13,  5  TO 17, 36  
@  7,  5  SAY "Codigo:"
@  7, 19  SAY "-"
@  9,  5  SAY "Agencia N§:"
@  9, 24  SAY "-"
@ 11,  5  SAY "N§ Conta:"
@ 13,  6  SAY "Saldos"
@ 14,  6  SAY "Disponivel:"
@ 16,  6  SAY "Vinculado :"

FMENS('')

SETCOLOR( SETCORES(1) )

cTelaLimpa := SAVESCREEN ( 0, 0, MAXROW(), MAXCOL() )

WHILE TRUE

   UNLOCK
   COMMIT
   
   RESTSCREEN ( 0, 0, MAXROW(), MAXCOL(), cTelaLimpa )

   nCodigo := 0
   
   SETCURSOR ( SC_NORMAL )
   
   @  7, 13 GET nCodigo PICT '9999' ;
            WHEN FMENS( 'Digite o C¢digo do Banco.        F5=Bancos.' )

   READ

   IF LASTKEY() == K_ESC ; EXIT ; END

   SELE BANCOS
   
   IF nCodigo == 0
      lInclui := TRUE
      GO BOTTOM
      nCodigo := Val( BANCOS->CODIGO ) + 1

   ELSE
      lInclui := FALSE

   END

   cCodigo := STRZERO( nCodigo, 4, 0 )

   FMENS('')
   @ 7, 13 SAY cCodigo COLOR SETCORES(3)

   SEEK cCodigo
   
   lAchou := FOUND()
   
   IF !lAchou .AND. !lInclui
      IF ATENCAO( 'Codigo Nao Cadastrado!;Deseja Incluir?',;
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
      BANCOS->CODIGO := cCodigo
      COMMIT
   ELSE
      IF !NetRLock()
         LOOP
      END
   END
   
   nII := RecNo()
   cNome       := BANCOS->NOME
   cNumAgencia := BANCOS->NUMAGENCIA
   cNomAgencia := BANCOS->NOMAGENCIA
   cNumConta   := BANCOS->NUMCONTA
   nSaldoDisp  := BANCOS->SALDODISP
   nSaldoVinc  := BANCOS->SALDOVINC
   
   IF !lInclui

      @  7, 13  SAY  cCodigo
      @  7, 22  SAY  cNome
      @  9, 17  SAY  cNumAgencia
      @  9, 27  SAY  cNomAgencia
      @ 11, 15  SAY  cNumConta
      @ 14, 18  SAY  nSaldoDisp
      @ 16, 18  SAY  nSaldoVinc

      FMENS( 'Tecle Enter.' )
      INKEY(0)
      FMENS('')      
      
      nEscolha := ATENCAO( 'Deseja fazer:; ', {'Alteracao','Exclusao','Volta' },;
                         SETCORES(1) )
      IF nEscolha == 2
         IF '9'$M->cRight
            IF ATENCAO( 'Confirma Exclusao?; ',{'Nao','Sim'}, SETCORES(2) ) == 2
               FMENS( 'AGUARDE... Excluindo Banco e Lan‡amentos...' )
               BANCOS->(dbDelete())
               ACAO( 'EXCLUI BANCO CODIGO ' + cCodigo )
               SELE LANCTOS
               GO TOP
               WHILE !LANCTOS->(EOF())
                   IF LANCTOS->BANCO == cCodigo
                      NetRLock(0)
                      LANCTOS->(dbDelete())
                   END
                   LANCTOS->(dbSkip())
               END
            END
         ELSE
            ACAO( 'TENTOU EXCLUIR BANCO CODIGO ' + cCodigo )
            ATENCAO( 'Acesso Negado' )
         END
      END

      IF nEscolha != 1 ; LOOP ;  END

   END

   FMENS('')
   @  7, 22  GET  cNome        PICT "@!"
   @  9, 17  GET  cNumAgencia  PICT "99999"
   @  9, 27  GET  cNomAgencia  PICT "@!"
   @ 11, 15  GET  cNumConta    PICT "@!"
   IF lInclui
      @ 14, 18  GET  nSaldoDisp   PICT "@E 999,999,999,999.99"
      @ 16, 18  GET  nSaldoVinc   PICT "@E 999,999,999,999.99"
   ELSE
      @ 14, 18  SAY  nSaldoDisp   PICT "@E 999,999,999,999.99"
      @ 16, 18  SAY  nSaldoVinc   PICT "@E 999,999,999,999.99"
   END
   READ
   
   BANCOS->(dbGoto( nII ))

   IF LastKey() == K_ESC
      IF lInclui ; LANCTOS->(dbDelete()) ; END
      LOOP
   END
   
   IF Updated()
      IF ATENCAO( 'Confirma '+If(lInclui,'INCLUSAO ?','ALTERACAO ?'),;
                {'Sim','Nao'}, SETCORES(2) ) == 1
         BANCOS->CODIGO     := cCodigo
         BANCOS->NOME       := cNome
         BANCOS->NUMAGENCIA := cNumAgencia
         BANCOS->NOMAGENCIA := cNomAgencia
         BANCOS->NUMCONTA   := cNumConta

         IF lInclui
            LANCTO( cCodigo, "C", nSaldoDisp, nSaldoVinc, "", "","SALDO INICIAL" )
            ACAO( 'CADASTROU BANCO CODIGO ' + cCodigo )

         ELSE
            ACAO( 'ALTEROU BANCO CODIGO ' + cCodigo )

         END
   
      ELSE
         IF lInclui ; BANCOS->(dbDelete()) ; END
         
      END

   ELSE
      IF lInclui ; BANCOS->(dbDelete()) ; END

   END
  
END

RestScreen ( 0, 0, MaxRow(), MaxCol(), cTela )
SetColor( cCor )
SetCursor( nCursor )
RETURN


***********************************************
PROCEDURE SALDO ( cBanco, dData, nDisp, nVinc )
***********************************************
LOCAL nSele, nInde, nVal1 := 0 , nVal2 := 0, nReg

nSele := SELECT()
nInde := INDEXORD()
SELE SALDOS
SEEK cBanco+DTOS( dData )
IF !FOUND()
   NetAppBlank( 0 )
   SALDOS->BANCO      := cBanco
   SALDOS->DATA       := dData
   nReg := RecNo()
   SKIP -1
   IF SALDOS->BANCO == cBanco .AND. SALDOS->DATA != dData
      nVal1 := SALDOS->DISPONIVEL
      nVal2 := SALDOS->VINCULADO
   END
   dbGoto( nReg )
   NetRLock(0)
   SALDOS->DISPONIVEL := nDisp + nVal1
   SALDOS->VINCULADO  := nVinc + nVal2
   SKIP
END
WHILE SALDOS->BANCO == cBanco .AND. !EOF()
   NetRLock(0)
   SALDOS->DISPONIVEL += nDisp
   SALDOS->VINCULADO  += nVinc
   SKIP
END   
UNLOCK
SELECT( nSele )
SET ORDER TO nInde
RETURN
