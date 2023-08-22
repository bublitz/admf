/***************

PROGRAMA: REPCON.prg

FUN€AO: RELATàRIO DE CONTRATOS

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'
#include 'ComBo.ch'
#include 'RepClass.CH'

STATIC aTipo := A_CONTR
STATIC aTpPg := { "Vista","1 Cheque Pr‚","2 Banco",;
                  "3 Desc Folha","4 Outros" }
STATIC aSexo := { "Masculino","Feminino" }
STATIC aPare := { 'Esposa','Marido','Filho(a)','Pai','Mae','Outros' }

*********************
PROCEDURE ReportCON()
*********************
LOCAL cCor, cTela, nCurs, ;
      nNumero, cNumero, cDados, cUsuarios, cTipo,;
      cOnde, cPrinter, nLin, nPag, nTpPg, cCli, nPare, nSexo,;
      nUsua, nDepe, nI, nT, cL,;
      pRESET, pCOMPR, pDESCO, pDOUBL, pENFAT, pDESEN, ;
      GETLIST := {}

cCor  := SetColor( SETCORES(2) )
nCurs := SetCursor( SC_NORMAL )
cTela := TELAReport( ' RELATORIO DE CONTRATO ' )

nNumero := 0
cDados := cUsuarios := cTipo := cOnde := cPrinter := ' '

WHILE .T.

   @ 7, 10 SAY 'N£mero do Contrato:' ;
           GET nNumero PICT '99999999' ;
           WHEN FMENS( 'Digite o N£mero do Contrato.' ) ;
           VALID PESQCON( nNumero, 9, 19, @cTipo )

   @ 9, 10 SAY 'Cliente:'

   @ 11,10 SAY 'Imprime Dados Gerais do Relat¢rio:' ;
           GET cDados PICT "!" VALID cDados$"SN" .OR. (LastKey() == K_UP);
           WHEN FMENS( "Digite 'S' ou 'N'." ) .AND. cTipo$'235'

   @ 13,10 SAY 'Imprime Usu rios do Plano:' ;
           GET cUsuarios PICT "!" VALID cUsuarios$"SN" .OR. (LastKey() == K_UP);
           WHEN FMENS( "Digite 'S' ou 'N'." ) .AND. cTipo$'235'

   @ 17,10 SAY "Impressora ou Tela:" GET cOnde PICT "!" ;
           COMBO { 'Impressora','Tela' } ;
           VALID cOnde$'TI'.OR. (LastKey() == K_UP);
           WHEN FMENS( "" )

   @ 19,10 SAY "Impressora:" GET cPrinter ;
           COMBO A_PRINT ;
           VALID cPrinter$"1234".OR. (LastKey() == K_UP);
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
   
   SELE VENDEDOR
   SET ORDER TO 1
   SELE CCUSTO
   SET ORDER TO 1   
   SELE CLIENTES
   SET ORDER TO 1
   SELE USUARIOS
   SET ORDER TO 1

   SELE CONTRATO
   SET ORDER TO 1
   SET RELATION TO CONTRATO->CLIENTE  INTO CLIENTES,;
                TO CONTRATO->NUMERO   INTO USUARIOS,;
                TO CONTRATO->VENDEDOR INTO VENDEDOR,;
                TO CONTRATO->CCUSTO   INTO CCUSTO

   IF cOnde == "T" .OR. FPRINTER ()
      FMENS( 'Aguarde... Emitindo Relatorio...' )
      SET DEVICE TO PRINT

      IF     cOnde == "T"
             SET ( 24, "$REL." + M->cTerm, FALSE )

      ELSE
             @ PRow(), PCol() SAY pRESET + pCOMPR

      END

      cNumero := StrZero( nNumero, 8, 0 )
      nLin := 100
      nPag := 0
      
      IF cDados == "S" .OR. cTipo$'14'
         SELE CONTRATO
         SEEK cNumero
         @  0,  0 SAY pDOUBL+M->cNomeC
         @  1,  0 SAY M->cNomeA
         @  3,  0 SAY pDOUBL+pENFAT+PADC('CONTRATO',40)+pDESEN
         @  5,  0 SAY 'Data: ' + DTOC( DATE() )
         @  5, 50 SAY 'Pagina: '+STR( ++nPag, 4, 0 )
         @  6,  0 SAY Replicate( "=", 80 )
         @  8,  1 SAY "Numero do Contrato: " + CONTRATO->NUMERO
         @  8, 65 SAY "Tipo: " + aTipo[ Val( cTipo ) ]

         cCli := CONTRATO->CLIENTE
         @ 10,  1 SAY "Cliente : " + cCli + "  " + CLIENTES->NOME
         
         nTpPg := Val( CONTRATO->PARCELADO )
         @ 10, 65 SAY "Tipo Pagamento: " + IF( nTpPg > 0, aTpPg[ nTpPg+1 ], "A VISTA" )
         
         @ 12,  1 SAY "Valor do Contrato ..: " + Transf( CONTRATO->VLTOTAL, "@E 9,999,999.99")
         @ 13,  1 SAY "(-) Desconto .......: " + Transf( CONTRATO->VLDESCTO, "@E 9,999,999.99")
         @ 14,  1 SAY "(=) Valor Liquido ..: " + Transf( CONTRATO->VLPAGO, "@E 9,999,999.99")
         @ 15,  1 SAY "(+) Despesas Gerais : " + Transf( CONTRATO->VLDESP, "@E 9,999,999.99")
         @ 16,  1 SAY "(=) Valor Total ....: " + Transf( CONTRATO->VLPAGO+CONTRATO->VLDESP, "@E 9,999,999.99")
         
         @ 18,  1 SAY "Vendedor: " + CONTRATO->VENDEDOR + "  " + VENDEDOR->NOME
         
         @ 20,  1 SAY "Centro de Custo: " + CONTRATO->CCUSTO + "  " + CCUSTO->NOME
         
         @ 22,  1 SAY "Data Assinatura: " + DTOC( CONTRATO->ASSINA )
         @ 22, 40 SAY "Data Vencimento: " + DTOC( CONTRATO->VENCTO )
         
         IF cTipo$'235' //PODE TER USUµRIOS
            nUsua := nDepe := 0
            SELE USUARIOS
            SEEK cNumero
            IF FOUND() // Hµ USUµRIOS
               WHILE USUARIOS->CONTRATO == cNumero .AND. !USUARIOS->(EOF())
                  nUsua++
                  cCli := USUARIOS->CLIENTE
                  SELE DEPENDEN
                  SEEK cCli
                  IF Found()
                     WHILE DEPENDEN->CODIGO == cCli .AND. !DEPENDEN->(EOF())
                         nDepe++
                         DEPENDEN->(dbSkip())
                     END
                  END
                  SELE USUARIOS
                  USUARIOS->(dbSkip())
               END
            END
            @ 24, 1 SAY "Numero de Usuarios...: " + TRANSFORM( nUsua, '@E 9,999,999' )
            @ 25, 1 SAY "Numero de Dependentes: " + TRANSFOR( nDepe, '@E 9,999,999' )
            @ 27, 1 SAY "          Total......: " + TRANSFOR( nDepe+nUsua, '@E 9,999,999' )
            
         ELSE           // PODE TER DEPENDENTES
            SELE DEPENDEN
            SEEK cCli
            IF Found() // TEM DEPENDENTES
               @ 22, 1 SAY "DEPENDENTES"
               @ 23, 12  SAY "N.   NOME                             Sexo      Parentesco Nascimento"
               //                                                   FEMININOO FILHO(A)
               //                     2         3         4         5         6         7
               //             23456789 123456789 123456789 123456789 123456789 123456789 123456789
               nLin := 24
               WHILE DEPENDEN->CODIGO == cCli .AND. !DEPENDEN->(EOF())
                   @ nLin,   12  SAY  DEPENDEN->ORDEM
                   @ nLin,   17  SAY  DEPENDEN->NOME
                   nSexo := Val(DEPENDEN->SEXO)
                   IF nSexo < 1 .OR. nSexo > 2
                      nSexo := 1
                   END
                   @ nLin,   50  SAY  aSexo[ nSexo ]
                   nPare := Val(DEPENDEN->PARENTESCO)
                   IF nPare < 1 .OR. nPare > 6
                      nPare := 6
                   END
                   @ nLin,   60  SAY  aPare[ nPare ]
                   @ nLin++, 71  SAY  DEPENDEN->NASCIMENTO
                   DEPENDEN->(dbSkip())
               END
            ELSE
               @ 22, 1 SAY "*** NAO HA' DEPENDENTES CADASTRADOS ***"
            END
         END
         
      END

      /*********************************************************************
                          /---------------------\
                          | IMPRIME OS USUµRIOS |
                          \---------------------/
      *********************************************************************/
      
      IF cUsuarios == "S" .AND. cTipo$'235' // IMPRIME OS USUµRIOS DO CONTRATO

         ALTD()

         nLin := 100
         nUsua := nDepe := 0
         SELE USUARIOS
         SEEK cNumero
         IF FOUND() // Hµ USUµRIOS
            WHILE USUARIOS->CONTRATO == cNumero .AND. !USUARIOS->(EOF())
               IF nLin > 56
                  @  0,  0 SAY pDOUBL+M->cNomeC
                  @  1,  0 SAY M->cNomeA
                  @  3,  0 SAY pDOUBL+pENFAT+PADC('RELACAO DE USUARIOS',40)+pDESEN
                  @  5,  0 SAY 'Data: ' + DTOC( DATE() )
                  @  5, 50 SAY 'Pagina: '+STR( ++nPag, 4, 0 )
                  @  6,  0 SAY Replicate( "=", 80 )
                  @  7, 12  SAY "N.   NOME                             Sexo      Parentesco Nascimento"
                  @  8,  0 SAY Replicate( "=", 80 )
                  @ 10,  1 SAY pDOUBL+"Numero do Contrato: " + CONTRATO->NUMERO
                  nLin  := 12
               END
               nUsua++
               cCli := USUARIOS->CLIENTE
               SELE CLIENTES
               SEEK cCli
               cL := pDOUBL+"Usuario: " + cCli + "  " + CLIENTES->NOME
               SELE DEPENDEN
               SEEK cCli
               IF FOUND()
                  nI := RecNo()
                  nT := 0
                  WHILE DEPENDEN->CODIGO == cCli .AND. !DEPENDEN->(EOF())
                     nT++
                     DEPENDEN->(dbSkip())
                  END
                  DEPENDEN->(dbGoTo(nI))
                  IF nLin+nT > 56
                     nLin := 100
                     LOOP
                  END
               END
               @ nLin++, 1 SAY cL
               WHILE DEPENDEN->CODIGO == cCli .AND. !DEPENDEN->(EOF())
                   nDepe++
                   @ nLin,   12  SAY  DEPENDEN->ORDEM
                   @ nLin,   17  SAY  DEPENDEN->NOME
                   nSexo := Val(DEPENDEN->SEXO)
                   IF nSexo < 1 .OR. nSexo > 2
                      nSexo := 1
                   END
                   @ nLin,   50  SAY  aSexo[ nSexo ]
                   nPare := Val(DEPENDEN->PARENTESCO)
                   IF nPare < 1 .OR. nPare > 6
                      nPare := 6
                   END
                   @ nLin,   60  SAY  aPare[ nPare ]
                   @ nLin++, 71  SAY  DEPENDEN->NASCIMENTO
                   DEPENDEN->(dbSkip())
               END
               SELE USUARIOS
               USUARIOS->(dbSkip())
               nLin += 2
            END
         END

      END
      EJECT

      SET PRINTER TO
      SET DEVICE TO SCREEN

      IF cOnde == "T"
         REPTELA( "$REL." + M->cTerm )
//         FErase( "$REL." + M->cTerm )

      ELSE
         ATENCAO( 'Emitido!' )

      END

      FMENS('')
   END

   SELE CLIENTES
   SET RELATION TO

   SELE CONTRATO
   SET RELATION TO

END

SELE CLIENTES
SET RELATION TO
SET ORDER TO 1
Fmens('')

SETCOLOR( cCor )
SETCURSOR( nCurs )
RESTSCREEN( 4, 1, MAXROW()-3, MAXCOL()-1, cTela )

RETURN

************************************************
FUNCTION PESQCON( nCod, nLinha, nColuna, cTipo )
************************************************
LOCAL lRet, nSele, cCli
IF LastKey() == K_UP .OR. LastKey() == K_PGUP
   lRet := TRUE

ELSE
   nSele := Select()
   SELE CONTRATO
   SEEK StrZero( nCod, 8, 0 )
   lRet := FOUND()
   IF lRet ; cCli := CONTRATO->CLIENTE
             SELE CLIENTES
             SEEK cCli
             @ nLinha, nColuna SAY CLIENTES->NOME
             SELE CONTRATO
             cTipo := CONTRATO->TIPO
             @ nLinha-2, 40 SAY "Tipo: " + aTipo[ Val( cTipo ) ]
   ELSE    ; @ nLinha, nColuna SAY SPACE( 35 )
             @ nLinha-2, 40 SAY SPACE( 20 )
   END
   Select( nSele )

END
RETURN lRet

