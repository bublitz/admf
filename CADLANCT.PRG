/***************

PROGRAMA: CADLANCT.prg

FUN€AO: CADASTRO DE LAN€AMENTOS FINANCEIROS

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'

*******************
PROCEDURE LANCTOS()
*******************
LOCAL cTela, cTelaLimpa, cCor, nEscolha,;
      nII, nCursor, GETLIST := {},;
      cTipoVal, nBanco, nReg, nNumero, dData,;
      cNumero, cBanco, cTipo, nValor, cNumCheque, cNumBanco, cHistorico
      
cTela   := SAVESCREEN ( 0, 0, MAXROW(), MAXCOL() )
nCursor := SETCURSOR( SC_NORMAL )
cCor    := SETCOLOR( SETCORES(2) )

LIMPA( 4, 1, MAXROW()-3, MAXCOL()-1 )

@ 4, 1 SAY PADC ( 'LAN€AMENTOS FINANCEIROS', 78 ) ;
       COLOR SETCORES(2)

@ 5, 1 SAY PADC ( 'ßßßßßßßßßßßßßßßßßßßßßßß', 78 ) ;
       COLOR SETCORES(2)

@  7,  5  SAY "Numero Controle:"
@  8,  5  SAY "Data:"
@  9,  5  SAY "Codigo Banco:"
@  9, 25  SAY "-"              //  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
@ 11,  5  SAY "Tipo:"
@ 11, 42  SAY "Valor:"
@ 13,  5  SAY "Cheque/Dinheiro:    N£mero Cheque:"
@ 13, 53  SAY "Banco:"
@ 15,  5  SAY "Hist¢rico:"

FMENS('')

SETCOLOR( SETCORES(1) )

dData := Date()
@  8, 11 GET dData
READ

cTelaLimpa := SAVESCREEN ( 0, 0, MAXROW(), MAXCOL() )

WHILE TRUE

   UNLOCK
   COMMIT
   
   RESTSCREEN ( 0, 0, MAXROW(), MAXCOL(), cTelaLimpa )

   SELE LANCTOS
   SET ORDER TO 1
   GO BOTTOM
/*
   cNumero := STRZERO( VAL( LANCTOS->NUMERO ) + 1, 10, 0 )
   NetAppBlank(0)
   LANCTOS->NUMERO := cNumero
   nReg := RecNo()
*/
      
   SETCURSOR ( SC_NORMAL )
   
//   @  7, 22 SAY cNumero
   
   nBanco := 0
   @  9, 19 GET nBanco PICT '9999' ;
            WHEN FMENS( 'Digite o C¢digo do Banco.' )

   READ

   IF LASTKEY() == K_ESC 
//      LANCTOS->(dbDelete())
      EXIT 
   END

   cBanco := STRZERO( nBanco, 4, 0 )

   @ 9, 19 SAY cBanco COLOR SETCORES(3)

   SELE BANCOS
   SEEK cBanco
   
   IF !FOUND()
//      LANCTOS->(dbDelete())
      ATENCAO( 'Banco Nao Cadastrado', { 'VOLTA' } )
      LOOP
   END
   
   @ 9, 28 SAY BANCOS->NOME COLOR SETCORES(3)
   
   SELE LANCTOS
   SET ORDER TO 1
   SEEK cBanco
   
   IF !FOUND()  // EH O 1§ LANCTO
      nNumero := 0
         
   ELSE
      WHILE LANCTOS->BANCO == cBanco .AND. !EOF()
         nNumero := Val( LANCTOS->NUMERO )
         LANCTOS->(dbSkip())
      END
   END
   
   cNumero := STRZERO( nNumero+1, 10, 0 )
   NetAppBlank(0)
   LANCTOS->NUMERO := cNumero
   nReg := RecNo()
   @  7, 22 SAY cNumero
   
   cTipo      := " "
   nValor     := 0
   cTipoVal   := " "
   cNumCheque := SPACE( 10 )
   cNumBanco  := "     "
   cHistorico := SPACE( 35 )
   
   FMENS('')

   @ 11, 11  GET  cTipo       PICT "!" VALID cTipo $ "DCVI" .AND. COMPLETA( cTipo )
   @ 11, 49  GET  nValor      PICT "999,999,999,999.99" VALID nValor > 0
   @ 13, 22  GET  cTipoVal    PICT "!" VALID cTipoVal $ "CD" WHEN cTipo $ "CD"
   @ 13, 40  GET  cNumCheque  PICT "@!" WHEN cTipoVal == "C"
   @ 13, 60  GET  cNumBanco   PICT "@!" WHEN cTipoVal == "C" .AND. cTipo =="C"
   @ 15, 16  GET  cHistorico  PICT "@!" WHEN cTipo $ "CD"

   READ
   
   IF LastKey() == K_ESC 
      LANCTOS->(dbDelete())
      LOOP 
   END
   
   IF cTipoVal == "D"
      cNumCheque := "DINHEIRO"
      cNumBanco  := " "
      nII := 1

   ELSEIF cTipoVal == "C"
      IF cTipo == "C"
         nII := 0
         WHILE nII == 0
            nII := ALERT( "Este cheque est ;", { "Dispon¡vel","Vinculado" }, SETCORES(1) )
         END
      ELSE
         nII := 1
      END

   END
   
   IF     cTipo == "I"
          cHistorico := "Transf DISPONIVEL -> VINCULADO"

   ELSEIF cTipo == "V"
          cHistorico := "Transf VINCULADO -> DISPONIVEL"

   END

   LANCTOS->(dbGoto( nReg ))

   IF Updated()
      IF ATENCAO( 'Confirma INCLUSAO ?', {'Sim','Nao'}, SETCORES(2) ) == 1
         LANCTOS->BANCO     := cBanco
         LANCTOS->TIPO      := cTipo
         LANCTOS->DATA      := dData
         LANCTOS->VALOR     := nValor
         LANCTOS->NUMCHEQUE := cNumCheque
         LANCTOS->NUMBANCO  := cNumBanco
         LANCTOS->HISTORICO := cHistorico
        
         ACAO ( 'LANCAMENTO CONTROLE N. ' + cNumero )
         
         SELE BANCOS
         SEEK cBanco
         NetRLock(0)
         IF     cTipo $ "CD"
                IF nII = 1
                   BANCOS->SALDODISP += IF ( cTipo=="C", nValor, -nValor )
                ELSE
                   BANCOS->SALDOVINC += IF ( cTipo=="C", nValor, -nValor )
                END
                IF nII = 1
                   SALDO( cBanco, dData, IF ( cTipo=="C", nValor, -nValor ), 0 )
                ELSE
                   SALDO( cBanco, dData, 0, IF ( cTipo=="C", nValor, -nValor ) )
                END
                
         ELSEIF cTipo == "V"
                BANCOS->SALDOVINC -= nValor
                BANCOS->SALDODISP += nValor
                SALDO( cBanco, dData, nValor, -nValor )

         ELSEIF cTipo == "I"
                BANCOS->SALDOVINC += nValor
                BANCOS->SALDODISP -= nValor
                SALDO( cBanco, dData, -nValor, nValor )

         END
         
      ELSE
         LANCTOS->(dbDelete())

      END

   ELSE
      LANCTOS->(dbDelete())

   END
  
END

RESTSCREEN ( 0, 0, MAXROW(), MAXCOL(), cTela )
SETCOLOR( cCor )
SETCURSOR( nCursor )
RETURN


FUNCTION COMPLETA( cTipo )
LOCAL  cRet := "                       "
IF     cTipo == "D"
       cRet := "‚dito                  "
       
ELSEIF cTipo == "C"
       cRet := "r‚dito                 "
       
ELSEIF cTipo == "V"
       cReT := "inculado -> Dispon¡vel "
       
ELSEIF cTipo == "I"
       cReT := "Dispon¡vel -> Vinculado"
       
END
@ 11, 12 SAY cRet
RETURN TRUE
         