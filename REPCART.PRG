/*

Programa: REPCART.prg

Funcao: Imprimir as carteirinhas

*/

#include 'MEU.CH'
#include 'ComBo.ch'
#include 'InKey.CH'
#include 'SetCurs.CH'
#define  A_TIPOS  { 'TD Titular e Dependente','ST Somente Titular',;
                    'SD Somente Dependente' }

STATIC pRESET, pCOMPR, pDESCO, pDOUBL, pENFAT, pDESEN, nContador, nTotal
STATIC cFile

*********************
PROCEDURE CARTEIRAS()
*********************
LOCAL cTela, cPrinter, cOnde, cCor, nCurs, nI, cInterno, FLAG,;
      nCodCli, nCodCli1, nCodCli2, nContrato, lOK, cCodDep,;
      GETLIST := {}, cTecla, nRec, cTeste, cLot, cNom

cCor  := SetColor( SETCORES(2) )
nCurs := SetCursor( SC_NORMAL )
cTela := TELAReport( ' EMISSAO DE CARTEIRINHAS ' )

cInterno := cPrinter := cOnde := ' '
nContrato := nCodCli1 := nCodCli2 := 0
cCodDep := '  '
cLot    := '   '
cNom    := Space( 30 )

SELE CLIENTES
SET ORDER TO 1

WHILE .T.

   @  7,  7 SAY 'Contrato:' GET nContrato PICT '99999999' ;
            WHEN FMENS( 'Digite o Numero do Contrato.' ) ;
            VALID nContrato >= 0 .OR. PESQCON( nContrato, 9, 29, ' ' )

   @  9,  7 SAY '       ÚInicial:' GET nCodCli1 PICT '99999999' ;
            WHEN nContrato == 0 .AND. ;
            FMENS( 'Digite o C¢digo do Cliente Inicial. 0=Nenhum. F2=Clientes.' ) ;
            VALID PESQCLI( nCodCli1, 9, 35 ) .OR. nCodCli1 >= 0

   @ 10, 7 SAY 'Cliente´'
   @ 11, 7 SAY '       ÀFinal:' GET nCodCli2 PICT '99999999' ;
            WHEN nContrato == 0 .AND. ;
            FMENS( 'Digite o C¢digo do Cliente Final. 0=Nenhum. F2=Clientes.' ) ;
            VALID PESQCLI( nCodCli2, 11, 35 ) .OR. nCodCli2 >= 0

   @ 13,  7 SAY 'Dependente:' GET cCodDep PICT '@K !!' ;
            COMBO A_TIPOS ;
            VALID ( PESQDEP(nCodCli1,cCodDep,13,27)) ;
            WHEN ( nContrato == 0 .AND. nCodCli2 == 0 .AND. ;
                   FMENS('Digite o N£mero do Dependente.'))

   @ 15,  7 SAY 'Codigo Interno? ' GET cInterno PICT '!' ;
            VALID cInterno$'SN' WHEN nContrato > 0


   @ 15, 30 SAY 'Lotacao: ' GET cLot PICT '999' WHEN cInterno == 'S'
   @ 15, 45 GET cNom PICT '@!'  WHEN cInterno == 'S'

   @ 17,  7 SAY "Impressora ou Tela:" GET cOnde PICT "!" ;
            COMBO { 'Impressora','Tela' } ;
            VALID cOnde$'TI' .OR. (LastKey() == K_UP);
            WHEN FMENS( "" )

   @ 17, 40 SAY "Impressora:" GET cPrinter ;
            COMBO A_PRINT ;
            WHEN cOnde == 'I' ;
            VALID cPrinter$"1234" .OR. (LastKey() == K_UP)

   READ

   IF LASTKEY() == K_ESC ; EXIT ; END

   IF nContrato+nCodCli1 == 0 ; LOOP ; END

   IF nContrato > 0
      nCodCli1 := nCodCli2 := 0
   END

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

   SELE LIBERA
   lOK := FALSE

   ALTD()
   
   IF nCodCli1 > 0 .AND. nCodCli2 == 0 // SOMENTE UM CLIENTE
      nContador := nTotal := 0
      SEEK StrZero( nCodCli1, 8, 0 )
      FMens( 'AGUARDE... Verificando Liberacao...' )
      IF Found()
         WHILE LIBERA->CODIGO == StrZero( nCodCli1, 8, 0 ) .AND. !EOF()
            IF NetRLock( 0 )
               IF Empty( LIBERA->DTEMISS ) // CARTEIRINHA NAO IMPRESSA
                  IF cOnde == 'I'
                     LIBERA->DTEMISS := Date()
                     LIBERA->WHOEMISS := PadR( M->cUsuario, 15 )
                     UNLOCK
                     ACAO( 'IMPRIMIU CARTEIRINHA CLIENTE '+StrZero( nCodCli1, 8, 0 ))
                  END
                  lOK := TRUE
                  EXIT
               END
            ELSE
               LOOP
            END
            LIBERA->(dbSkip())
         END
      END
      IF !lOK
         Alert( 'Esta Carteirinha Nao Est  Liberada !', {'Volta'} )
         LOOP
      END

      IF cOnde == "T" .OR. FPRINTER ()
         FMENS( 'Emite Carteirinha Teste ?' )

         SET DEVICE TO PRINT

         IF     cOnde == "T"
                SET ( 24, "$REL." + M->cTerm, FALSE )

         ELSE
                @ PRow(),PCol() SAY pRESET + pCOMPR

         END

         cTeste := 'S'
         WHILE cTeste == 'S' .AND. cOnde = 'I'
            @ 23, 40 GET cTeste PICT '!'
            READ
            IF cTeste == 'S'
               @ PRow(),PCol() SAY pRESET + pCOMPR
               IMPTESTE()
               @ Prow()+9, 0 SAY ''
            END
         END
         
         SET DEVICE TO SCREEN
         FMENS( 'Aguarde... Emitindo Carteirinhas...' )
         SET DEVICE TO PRINT

         IF     cOnde == "T"
                SET ( 24, "$REL." + M->cTerm, FALSE )

         ELSE
                @ PRow(),PCol() SAY pRESET + pCOMPR

         END

         /*
          IIIIII MMM    MMM PPPPPP  RRRRRR  IIIIII MMM    MMM EEEEEE
            II   MMMM  MMMM PP   PP RR   RR   II   MMMM  MMMM EE
            II   MM MMMM MM PP   PP RR   RR   II   MM MMMM MM EEEE
            II   MM  MM  MM PPPPPP  RRRRRR    II   MM  MM  MM EEEE
            II   MM      MM PP      RR   RR   II   MM      MM EE
          IIIIII MM      MM PP      RR   RR IIIIII MM      MM EEEEEE
         */
         
         IF cCodDep == "ST" //SOMENTE TITULAR
            IMPCART( nCodCli1, 00 )

         ELSE
            IF cCodDep == "TD" // TITULAR E DEPENDENTE
               IMPCART( nCodCli1, 00 )
               @ Prow()+9, 0 SAY ''
            END
            IF cCodDep$"SDþTD"
               SELE DEPENDEN
               SEEK StrZero( nCodCli1, 8, 0 )
               WHILE DEPENDEN->CODIGO == StrZero( nCodCli1, 8, 0 ) .AND. !EOF()
                  nI := DEPENDEN->(RecNo())
                  IMPCART( nCodCli1, Val( DEPENDEN->ORDEM ) )
                  @ Prow()+9, 0 SAY ''
                  DEPENDEN->(dbGoTo( nI ))
                  DEPENDEN->(dbSkip())
               END
            END   
            IF Val( cCodDep ) > 0
               IMPCART( nCodCli1, Val( cCodDep ) )
            END
         END
//         IF cOnde == "I" ; @ PRow()+9, 0 SAY CHR(27)+'@' ; END

         SET PRINTER TO
         SET DEVICE TO SCREEN

         FMENS('')

         IF cOnde == "T"
            REPTELA( "$REL." + M->cTerm )
            FErase( "$REL." + M->cTerm )

         ELSE
            ATENCAO( 'Emitido!' )

         END

         FMENS('')
      END
      LOOP
   END // SOMENTE UM CLIENTE

   IF nCodCli1 > 0 .AND. nCodCli2 > 0 // LISTA DE CLIENTES
      nContador := nTotal := 0
      IF cOnde == "T" .OR. FPRINTER ()
         FMENS( 'Emite Carteirinha Teste ?' )

         SET DEVICE TO PRINT

         IF     cOnde == "T"
                SET ( 24, "$REL." + M->cTerm, FALSE )

         ELSE
                @ PRow(),PCol() SAY pRESET + pCOMPR

         END

         cTeste := 'S'
         WHILE cTeste == 'S' .AND. cOnde = 'I'
            @ 23, 40 GET cTeste PICT '!'
            READ
            IF cTeste == 'S'
               @ PRow(),PCol() SAY pRESET + pCOMPR
               IMPTESTE()
               @ Prow()+9, 0 SAY ''
            END
         END
         
         SET DEVICE TO SCREEN

         FMENS( 'Aguarde... Emitindo Carteirinhas...' )
         SET DEVICE TO PRINT

         IF     cOnde == "T"
                SET ( 24, "$REL." + M->cTerm, FALSE )

         ELSE
                @ PRow(),PCol() SAY pRESET + pCOMPR

         END

         FOR nCodCli := nCodCli1 TO nCodCli2
             SEEK StrZero( nCodCli, 8, 0 )
             IF Found()
                WHILE LIBERA->CODIGO == StrZero( nCodCli, 8, 0 ) .AND. !EOF()
                      IF NetRLock( 0 )
                         IF Empty( LIBERA->DTEMISS ) // CARTEIRINHA NAO IMPRESSA
                            IF cOnde == 'I'
                               LIBERA->DTEMISS := Date()
                               LIBERA->WHOEMISS := PadR( M->cUsuario, 15 )
                               UNLOCK
                               ACAO( 'IMPRIMIU CARTEIRINHA CLIENTE '+StrZero( nCodCli, 8, 0 ))
                            END
                            lOK := TRUE
                            EXIT
                         END
                      ELSE
                         LOOP
                      END
                      LIBERA->(dbSkip())
                END
             END
             IF lOK
         /*
          IIIIII MMM    MMM PPPPPP  RRRRRR  IIIIII MMM    MMM EEEEEE
            II   MMMM  MMMM PP   PP RR   RR   II   MMMM  MMMM EE
            II   MM MMMM MM PP   PP RR   RR   II   MM MMMM MM EEEE
            II   MM  MM  MM PPPPPP  RRRRRR    II   MM  MM  MM EEEE
            II   MM      MM PP      RR   RR   II   MM      MM EE
          IIIIII MM      MM PP      RR   RR IIIIII MM      MM EEEEEE
         */
         
     

                IMPCART( nCodCli, 00 )
                @ Prow()+9, 0 SAY ''
                SELE DEPENDEN
                SEEK StrZero( nCodCli, 8, 0 )
                WHILE DEPENDEN->CODIGO == StrZero( nCodCli, 8, 0 ) .AND. !EOF()
                   nI := DEPENDEN->(RecNo())
                   IMPCART( nCodCli, Val( DEPENDEN->ORDEM ) )
                   @ Prow()+9, 0 SAY ''
                   DEPENDEN->(dbGoTo( nI ))
                   DEPENDEN->(dbSkip())
                END
             END   

         NEXT
//         IF cOnde == "I" ; @ PRow()+9, 0 SAY CHR(27)+'@' ; END

         SET PRINTER TO
         SET DEVICE TO SCREEN

         FMENS('')

         IF cOnde == "T"
            REPTELA( "$REL." + M->cTerm )
            FErase( "$REL." + M->cTerm )

         ELSE
            ATENCAO( 'Emitido!' )

         END

         FMENS('')
      END
      LOOP
   END // LISTA DE CLIENTES
   
/*

          CCCCCC OOOOOO NN   NN TTTTTT RRRRRR    AAAA   TTTTTT OOOOOO
          CC     OO  OO NNN  NN   TT   RR   RR  AA  AA    TT   OO  OO
          CC     OO  OO NNNN NN   TT   RR   RR AA    AA   TT   OO  OO
          CC     OO  OO NN NNNN   TT   RRRRRR  AAAAAAAA   TT   OO  OO
          CC     OO  OO NN  NNN   TT   RR   RR AA    AA   TT   OO  OO
          CCCCCC OOOOOO NN   NN   TT   RR   RR AA    AA   TT   OOOOOO


*/


   IF nContrato > 0 // CONTRATO

      cFile := 'IMP' + M->cTerm + '.' + cLot
      
      nContador := nTotal := 0
      @ 19, 29 TO 21, 40 DOUBLE

      SELE USUARIOS

      IF cInterno == 'S' ; SET ORDER TO 3
      ELSE               ; SET ORDER TO 1
      END

      IF cInterno == 'S'
         SEEK StrZero( nContrato, 8, 0 ) + cLot
         IF !Found()
            Alert( 'Nao Existe Usuarios;Nessa Lotacao ==> ' + cLot,{'Volta'})
            @ 19, 29 CLEAR TO 21, 40
            LOOP
         END

      ELSE
         SEEK StrZero( nContrato, 8, 0 )
         IF !Found()
            Alert( 'Nao Existe Usuarios;deste Contrato! ',{'Volta'})
            @ 19, 29 CLEAR TO 21, 40
            LOOP
         END
         
      END
         
      IF cOnde == "T" .OR. FPRINTER ()
         FMENS( 'Emite Carteirinha Teste ?' )

         SET DEVICE TO PRINT

         IF     cOnde == "T"
                SET ( 24, "$REL." + M->cTerm, FALSE )

         ELSE
                @ PRow(),PCol() SAY pRESET + pCOMPR

         END

         cTeste := 'S'
         WHILE cTeste == 'S' .AND. cOnde = 'I'
            @ 23, 40 GET cTeste PICT '!'
            READ
            IF cTeste == 'S'
               @ PRow(),PCol() SAY pRESET + pCOMPR
               IMPTESTE()
               @ Prow()+9, 0 SAY ''
            END
         END
         
         IF cInterno == 'S'
            FLAG := 'INICIAL'
         END
         
         SET DEVICE TO SCREEN
         FMENS( 'Aguarde... Emitindo Carteirinhas...' )
         SET DEVICE TO PRINTER
         
         WHILE USUARIOS->CONTRATO == StrZero( nContrato, 8, 0 ) .AND. !USUARIOS->(EOF())
           IF cLot == SubStr( USUARIOS->INTERNO, 1, 3 ) .OR. cInterno == 'N'
             nCodCli := Val( USUARIOS->CLIENTE )

             lOk := FALSE

             SELE LIBERA
             SEEK StrZero( nCodCli, 8, 0 )
             IF Found()
                WHILE LIBERA->CODIGO == StrZero( nCodCli, 8, 0 ) .AND. !EOF()
                      
                      IF LIBERA->(RLock())
                         IF Empty( LIBERA->DTEMISS ) // CARTEIRINHA NAO IMPRESSA
                            IF cOnde == 'I'
                               LIBERA->DTEMISS := Date()
                               LIBERA->WHOEMISS := PadR( M->cUsuario, 15 )
                               UNLOCK
                               ACAO( 'IMPRIMIU CARTEIRINHA CLIENTE '+StrZero( nCodCli, 8, 0 ))
                            END
                            lOK := TRUE
                            EXIT
                         END

                      END
                      LIBERA->(dbSkip())
                END
             END
             IF lOK
         /*
          IIIIII MMM    MMM PPPPPP  RRRRRR  IIIIII MMM    MMM EEEEEE
            II   MMMM  MMMM PP   PP RR   RR   II   MMMM  MMMM EE
            II   MM MMMM MM PP   PP RR   RR   II   MM MMMM MM EEEE
            II   MM  MM  MM PPPPPP  RRRRRR    II   MM  MM  MM EEEE
            II   MM      MM PP      RR   RR   II   MM      MM EE
          IIIIII MM      MM PP      RR   RR IIIIII MM      MM EEEEEE
         */
                
                
                IF cInterno == 'S'
                   
                   IF FLAG != SubStr( USUARIOS->INTERNO, 1, 3 )
                      // IMPRIME CARTEIRINHA DE SEPARACAO
                      FLAG := SubStr( USUARIOS->INTERNO, 1, 3 )
                      IMPSEPARA( FLAG, cNom )
                      @ Prow()+9, 0 SAY ''
                   END
                END
                nRec := USUARIOS->(RecNo())
                IMPCART( nCodCli, 00 )
                @ Prow()+9, 0 SAY ''
                SELE DEPENDEN
                SEEK StrZero( nCodCli, 8, 0 )
                WHILE DEPENDEN->CODIGO == StrZero( nCodCli, 8, 0 ) .AND. !EOF()
                   nI := DEPENDEN->(RecNo())
                   IMPCART( nCodCli, Val( DEPENDEN->ORDEM ))
                   @ Prow()+9, 0 SAY ''
                   DEPENDEN->(dbGoTo( nI ))
                   DEPENDEN->(dbSkip())
                END

                SELE USUARIOS
                IF cInterno == 'S' ; SET ORDER TO 3
                ELSE               ; SET ORDER TO 2
                END
                USUARIOS->(dbGoTo( nRec ))

             END   

             SetPos( 20, 30 )
             DispOut( Transform(nContador,'@E 99,999,999') )

             IF nContador >= 100
                SET DEVICE TO SCREEN
                FMENS('Pausa... <C> para Continuar. <K> para Cancelar')
                BEEP()
                CLEAR TYPE
                cTecla := Upper( Chr( InKey( 200 ) ) )
                IF cTecla == "K"
                   EXIT
                END
                FMENS( 'Aguarde... Emitindo Carteirinhas...' )
                SET DEVICE TO PRINT
                nContador := 0
             END
           END // LOTACAO
           
           USUARIOS->(dbSkip())
             
         END
//         IF cOnde == "I" ; @ PRow()+9, 0 SAY CHR(27)+'@' ; END

         SET PRINTER TO
         SET DEVICE TO SCREEN

         FMENS('')

         SetPos( 20, 30 )
         DispOut( Transform(nTotal,'@E 99,999,999') )
         FMENS('Total Impressas. Tecle Enter.')
         CLEAR TYPE
         WHILE !INKEY(0) == K_ENTER ; END
         @ 19, 29 CLEAR TO 21, 40
         
         IF cOnde == "T"
            REPTELA( "$REL." + M->cTerm )
            FErase( "$REL." + M->cTerm )

         ELSE
            ATENCAO( 'Emitido!' )

         END

      END

      LOOP

   END // CONTRATO
   

END

SETCOLOR( cCor )
SETCURSOR( nCurs )
RESTSCREEN( 4, 1, MAXROW()-3, MAXCOL()-1, cTela )

RETURN

***********************************************
STATIC FUNCTION PESQDEP( nCli, cCod, nLinha, nColuna )
***********************************************
LOCAL lRet, nSele
IF LastKey() == K_UP .OR. LastKey() == K_PGUP
   lRet := TRUE

ELSEIF cCod == 'SD'
   @ nLinha, nColuna SAY PadR( "Somente Dependente.", 35 )
   lRet := TRUE

ELSEIF cCod == 'ST'
   @ nLinha, nColuna SAY PadR( "Somente Titular.", 35 )
   lRet := TRUE

ELSEIF cCod == 'TD'
   @ nLinha, nColuna SAY PadR( "Titular e Dependente.", 35 )
   lRet := TRUE

ELSE
   nSele := Select()
   SELE DEPENDEN
   cCod := StrZero( Val( cCod ), 2, 0 )
   SEEK StrZero( nCli, 8, 0 ) + cCod
   lRet := FOUND()
   IF lRet ; @ nLinha, nColuna SAY DEPENDEN->NOME
   ELSE    ; @ nLinha, nColuna SAY SPACE( 35 )
   END
   Select( nSele )

END
RETURN lRet


************************************
PROCEDURE IMPCART( nCodCli, nCodDep )
************************************
LOCAL cCodCli, cCodDep, cNome, cCPF, cNumCon, cAno, cVal, cEmi, cPla, lAchou,;
      cTitular, nSele, mCart, cEmp, cCodEmp

STATIC aTipos := { "Particular ",;
                   "Empresarial",;
                   "Permuta    ",;
                   "Cortesia   ",;
                   "Cooperativo" }


nSele   := Select()
cCodCli := StrZero( nCodCli, 8, 0 )
cCodDep := StrZero( nCodDep, 2, 0 )
cEmi    := DTOC( Date())

SELE CLIENTES
SEEK cCodCli
IF Found()
   cTitular := CLIENTES->NOME
   cCPF  := CLIENTES->CGCCPF
   SELE USUARIOS
   SET ORDER TO 2
   SEEK cCodCli
   IF Found()
      cNumCon := USUARIOS->CONTRATO
      lAchou := TRUE

   ELSE
      SELE CONTRATO
      SET ORDER TO 2
      SEEK cCodCli
      IF Found()
         cNumCon := CONTRATO->NUMERO
         lAchou := TRUE
      ELSE
         lAchou := FALSE
      END
   END
   IF lAchou   
      SELE CONTRATO
      SET ORDER TO 1
      SEEK cNumCon
      IF Found()
         cAno := Str( Year( CONTRATO->ASSINA ), 4, 0 )
         cVal := DTOC( CONTRATO->VENCTO )
         cPla := aTipos[ Val(CONTRATO->TIPO) ]

         IF Val(CONTRATO->TIPO) == 2 // EMPRESARIAL
            cCodEmp := CONTRATO->CLIENTE
            IF cCodEmp == cCodCli
               Select( nSele )
               RETURN
            END
            SELE CLIENTES
            SEEK cCodEmp
            cEmp := CLIENTES->NOME

         ELSE
            cEmp := ''

         END
         
         IF cCodDep != '00' // CARTEIRA DE DEPENDENTE
            SELE DEPENDEN
            SEEK cCodCli + cCodDep
            IF Found()
               cNome := DEPENDEN->NOME
               lAchou := TRUE
            END

         ELSE
            cNome := cTitular
            lAchou := TRUE

         END

         IF lAchou
            nContador++
            nTotal++
            @ PRow()+ 1,  20 SAY 'Titular'
            @ PRow()+ 1,  20 SAY cTitular
            @ PRow()+ 4,  99 SAY cNumCon + '/' + cAno + ' ' + cEmp
            @ PRow()+ 1, 100 SAY cCodCli + '.' + cCodDep + '-' + cNome
            @ PRow()+ 1,  94 SAY cCPF PICT '@R 999.999.999-99'
            @ PRow()   , 133 SAY cPla
            @ PRow()+ 1,  20 SAY nTotal PICT '@E 9,999,999'
            @ PRow()   ,  98 SAY cEmi
            @ PRow()   , 133 SAY cVal

         END
      END
   END

END

Select( nSele )
RETURN

**********************************
PROCEDURE IMPSEPARA( FLAG, cNome )
**********************************
@ PRow()+ 1,  20 SAY '**************************************************************************'
@ PRow()+ 1,  20 SAY '**************************************************************************'
@ PRow()+ 3,  29 SAY 'LOTACAO ===> ' + pDOUBL + FLAG + ' ' + cNome
@ PRow()+ 2,  20 SAY ''
@ PRow()+ 1,  20 SAY '**************************************************************************'
@ PRow()+ 1,  20 SAY '**************************************************************************'
RETURN

********************
PROCEDURE IMPTESTE()
********************
@ PRow()+ 1,  20 SAY '********** Carteirinha Teste **************'
@ PRow()+ 1,  20 SAY 'UM DOIS TRES QUATRO CINCO ***** N U L A ***'
@ PRow()+ 4,  99 SAY '12345678/9999'
@ PRow()+ 1, 100 SAY '12345678.99-UM DOIS TRES QUATRO CINCO'
@ PRow()+ 1,  94 SAY 'XXX.XXX.XXX-XX'
@ PRow()   , 133 SAY '** N U L A **'
@ PRow()+ 1,  20 SAY '** N U L A **'
@ PRow()   ,  98 SAY '99/99/9999'
@ PRow()   , 133 SAY '99/99/9999'
RETURN
