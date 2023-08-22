USE BANCOS NEW
SET INDEX TO BANCOS  // CODIGO

USE LANCTOS NEW
SET INDEX TO LANCTOS1  // BANCO+NUMERO

USE SALDOS NEW
SET INDEX TO SALDOS  // BANCO + DTOS(DATA)
ZAP

SELE BANCOS
GO TOP
nII := 0
CLS
WHILE !BANCOS->(EOF())
   BANCOS->SALDOVINC := BANCOS->SALDODISP := 0
   cBanco := BANCOS->CODIGO
   SELE LANCTOS
   SEEK cBanco
   WHILE LANCTOS->BANCO == cBanco .AND. !LANCTOS->(EOF())
      @ 5, 5 SAY +nII*100/RECCOUNT() PICT "@E EXECUTADO 999.99 %"
      cTipo := LANCTOS->TIPO
      dData := LANCTOS->DATA
      nValor := LANCTOS->VALOR
      IF     cTipo $ "CD"
             SALDO( cBanco, dData, IF ( cTipo=="C", nValor, -nValor ), 0 )
             BANCOS->SALDODISP += IF ( cTipo=="C", nValor, -nValor )
      END

      LANCTOS->(dbSkip())
   END
   SELE BANCOS
   BANCOS->(dbSkip())
END




***********************************************
PROCEDURE SALDO ( cBanco, dData, nDisp, nVinc )
***********************************************
LOCAL nSele, nInde, nVal1 := 0 , nVal2 := 0, nReg

nSele := SELECT()
nInde := INDEXORD()
SELE SALDOS
SEEK cBanco+DTOS( dData )
IF !FOUND()
   APPEND BLANK
   SALDOS->BANCO      := cBanco
   SALDOS->DATA       := dData
   nReg := RecNo()
   SKIP -1
   IF SALDOS->BANCO == cBanco .AND. SALDOS->DATA != dData
      nVal1 := SALDOS->DISPONIVEL
      nVal2 := SALDOS->VINCULADO
   END
   dbGoto( nReg )
   SALDOS->DISPONIVEL := nDisp + nVal1
   SALDOS->VINCULADO  := nVinc + nVal2
   SKIP
END
WHILE SALDOS->BANCO == cBanco .AND. !EOF()
   SALDOS->DISPONIVEL += nDisp
   SALDOS->VINCULADO  += nVinc
   SKIP
END   
SELECT( nSele )
SET ORDER TO nInde
RETURN
