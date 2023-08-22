/***************

PROGRAMA: REPCAM.prg

FUN€AO: RELACAO DE CAMINHOES - COMPRA X VENDA

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'
#include 'COMBO.CH'
#include 'REPCLASS.CH'

#DEFINE  COLUNAS  111

STATIC pRESET, pCOMPR, pDESCO, pDOUBL, pENFAT, pDESEN, nPag

**********************
PROCEDURE RepCaminhao()
**********************
LOCAL cCor, cTela, nCurs, ;
      cOnde, cPrinter, FLAG,;
      nLin, nRec, cMarMod, nAnoV ,;
      cModV, cMarV, cCorV, cAnoV, cPlaV, cVenV, nValV, cProp,;
      GETLIST := {}

cCor  := SetColor( SETCORES(2) )
nCurs := SetCursor( SC_NORMAL )
cTela := TELAReport( ' RELA€AO DE CAMINHOES' )

cOnde := cPrinter := ' '

SELE CAMINHAO
SET ORDER TO 2
SET RELATION TO CAMINHAO->VENDEDOR   INTO FUNCIONA,;
             TO CAMINHAO->PROPRIETAR INTO CLIENTES
             
CAMINHAO->(dbGoTop())

WHILE .T.

   @ 19,10 SAY "Impressora ou Tela:" GET cOnde PICT "!" ;
           COMBO { 'Impressora','Tela' } ;
           VALID cOnde$'TI'

   @ 19,50 SAY "Impressora:" GET cPrinter ;
           COMBO A_PRINT ;
           VALID cPrinter$"123" ;
           WHEN cOnde == "I"

   READ

   IF LASTKEY() == K_ESC ; EXIT ; END

   IF cOnde == "I"
      PRINTER->( dbGoto( Val( cPrinter ) ) )
      pRESET := PR_COMM( AllTrim( PRINTER->RESET ) )
      pCOMPR := PR_COMM( AllTrim( PRINTER->COMPR ) )
      pDESCO := PR_COMM( AllTrim( PRINTER->DESCO ) )
      pDOUBL := PR_COMM( AllTrim( PRINTER->DOUBL ) )
      pENFAT := PR_COMM( AllTrim( PRINTER->ENFAT ) )
      pDESEN := PR_COMM( AllTrim( PRINTER->DESEN ) )
   ELSE
      pRESET := pCOMPR := pDESCO := pDOUBL := pENFAT := pDESEN := ''

   END

   nLin := 100
   nPag := 0

   IF cOnde == "T" .OR. FPRINTER ()
      FMENS( 'Aguarde... Emitindo Relatorio...' )
      SET DEVICE TO PRINT

      IF     cOnde == "T"
             SET ( 24, "$RELCC." + M->cTerm, FALSE )

      ELSE
             @ PRow(),PCol() SAY pRESET + pCOMPR

      END

      CAMINHAO->(dbSeek( 'V' )) // 1§ Caminhao para Venda
      WHILE .T.
         IF nLin > 56
            Cabecalho() // Mais adiante.
            nLin := 7
         END
         nRec := CAMINHAO->(RecNo())
         cMarMod := CAMINHAO->MARCA + CAMINHAO->MODELO
         cMarV := CAMINHAO->MARCA
         cModV := CAMINHAO->MODELO
         cCorV := CAMINHAO->COR
         cAnoV := CAMINHAO->ANO
         nAnoV := Val( cAnoV )
         cPlaV := CAMINHAO->PLACA
         cVenV := CAMINHAO->VENDEDOR + ' ' + FUNCIONA->NOME
         nValV := CAMINHAO->VENDA
         cProp := CAMINHAO->PROPRIETAR + ' ' + CLIENTES->NOME + ;
                  ' ' + fFONE() // MAIS ADIANTE

         SEEK 'C' + cMarMod
         IF CAMINHAO->(FOUND())
            IF nLin > 45
            END
            FLAG := TRUE
            WHILE ( cMarMod == CAMINHAO->MARCA + CAMINHAO->MODELO .AND. ;
                  CAMINHAO->TIPO == 'C' ) .AND. !CAMINHAO->(EOF())

               /*
                  TESTA SE ESTA NA FAIXA DE ANO ñ 3 anos
                  E SE ESTA NA FAIXA DE PRECO ñ R$ 3.000,00
               */
               IF Val( CAMINHAO->ANO ) >= nAnoV-3 .AND. Val( CAMINHAO->ANO ) <= nAnoV+3 .AND. ;
                  CAMINHAO->COMPRA >= nValV-3000.00 .AND. ;
                  CAMINHAO->COMPRA <= nValV+3000.00
                  IF FLAG // Se ‚ 1¦ vez
                     @ nLin++,  0  SAY Replicate( '-', COLUNAS )
                     @ nLin++, 0 SAY pENFAT + 'CAMINHAO PARA VENDER' + pDESEN
                     @ nLin  , 0 SAY 'Marca ' + NOMETAB( '1', cMarV )
                     @ nLin++, PCol()+5 SAY 'Modelo: ' + NOMETAB( '2', cModV )
                     @ nLin++, 0 SAY 'Cor: ' + NOMETAB( '3', cCorV )
                     @ nLin  , 0 SAY 'Ano: ' + cAnoV
                     @ nLin  , PCol()+5 SAY 'Placa: ' + cPlaV
                     @ nLin++, PCol()+5 SAY 'Valor: ' + Transform( nValV, '@E 999,999,999.99' )
                     @ nLin++, 0 SAY 'Proprietario: ' + cProp
                     @ nLin++, 0 SAY 'Vendedor: ' + cVenV
                     nLin++
                     @ nLin++, 0 SAY pENFAT + 'POSSIVEL(IS) INTERESSADO(S)' + pDESEN
                     FLAG := FALSE
                  END
                  @ nLin++, 0 SAY 'Interessado: ' + CAMINHAO->PROPRIETAR + ' ' + CLIENTES->NOME + ' ' + fFONE()
                  @ nLin  , 0 SAY 'Marca ' + NOMETAB( '1', CAMINHAO->MARCA )
                  @ nLin++, PCOL()+5 SAY 'Modelo: ' + NOMETAB( '2', CAMINHAO->MODELO )
                  @ nLin  , 0 SAY 'Ano: ' + CAMINHAO->ANO
                  @ nLin  , PCol()+5 SAY 'Valor: ' + Transform( CAMINHAO->COMPRA, '@E 999,999,999.99' )
                  @ nLin++, PCol()+5 SAY 'Vendedor: ' + CAMINHAO->VENDEDOR + ' ' + FUNCIONA->NOME
                  nLin++
                  IF nLin > 45
                     Cabecalho()
                     nLin := 7
                  END
               END
               CAMINHAO->(dbSkip())
            END
         END
         CAMINHAO->(dbGoto( nRec ))
         CAMINHAO->(dbSkip())
         IF CAMINHAO->TIPO != 'V' .OR. CAMINHAO->(EOF())
            EXIT
         END
      END

      EJECT

      SET PRINTER TO
      SET DEVICE TO SCREEN

      FMENS('')

      IF cOnde == "T"
         REPTELA( "$RELCC." + M->cTerm )
         FErase( "$RELCC." + M->cTerm )

      ELSE
         ATENCAO( 'Emitido!' )

      END

      FMENS('')
   END


END

SELE CAMINHAO
SET RELATION TO
SET ORDER TO 1
Fmens('')

SETCOLOR( cCor )
SETCURSOR( nCurs )
RESTSCREEN( 4, 1, MAXROW()-3, MAXCOL()-1, cTela )

RETURN



FUNCTION fFONE()
LOCAL R := ''
IF !Empty( CLIENTES->FONE1 )
   R += Transform( CLIENTES->FONE1, '@R (!!!!)!!!!-!!!!' )
END
IF !Empty( CLIENTES->FONE1 )
   IF !Empty( R )
      R += '/'
   END
   R += Transform( CLIENTES->FONE1, '@R (!!!!)!!!!-!!!!' )
END
RETURN R


STATIC PROCEDURE Cabecalho()
@  0,  0  SAY pDOUBL+M->cNomeC
@  1,  0  SAY PADR(M->cNomeA,COLUNAS)
@  2,  0  SAY pDOUBL+pENFAT+PADC('RELACAO DE CAMINHOES',COLUNAS/2)+pDESEN
@  4,  0  SAY PADR( Agora(),COLUNAS/2 ) +;
PADL('Pagina: '+STR( ++nPag, 4, 0 ),COLUNAS/2 )
@  5,  0  SAY Replicate( '=', COLUNAS )
@  5,  0  SAY Replicate( '-', COLUNAS )
RETURN
