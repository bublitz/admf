/*

 Programa: MENUAUD.prg

*/

#include "MEU.CH"
#include "INKEY.CH"
#include "ACHOICE.CH"
#include "SETCURS.CH"
#include "BOX.CH"
#include "COMBO.CH"

#define COLUNAS  50
STATIC aRec

*********************
PROCEDURE AUDITORIA()
*********************
LOCAL cTela, nOpcao, cCor

cCor := SetColor( SETCORES( 3 ) )
cTela := ABRE( 10, 40, 18, 66, TRUE )

WHILE TRUE
   FMENS('Use as Setas '+CHR(24)+' e '+CHR(25)+'.    F1=Help')
   @ 11, 42 PROMPT "1. Usu rios            "
   @ 13, 42 PROMPT "2. Auditoria Tela      "
   @ 15, 42 PROMPT "3. Auditoria Impressora"
   @ 17, 42 PROMPT "4. Backup Arquivos     "
   MENU TO nOpcao

   IF     nOpcao == 0 ; EXIT
   ELSEIF nOpcao == 1 ; CADUSER() 
   ELSEIF nOpcao == 2 ; AUDITELA()
   ELSEIF nOpcao == 3 ; AUDIMPRE()
   ELSEIF nOpcao == 4 ; BACKUP()  // NO COPSEG.PRG
   END

END

FECHA( 10, 40, 18, 66, cTela, TRUE )
SetColor( cCor )

RETURN


*******************
PROCEDURE CADUSER()
*******************
LOCAL cTela, cCor, cUser, nOpcao, aDireitos := {}, aUser,;
      nI, cT, nCursor, nKey, cNew, cTela2, cPass1, cPass2, ;
      nL := { 05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19 },;
      nC := { 24,27,24,27,24,27,24,27,24,27,27,24,27,24,27,43,46,46,46,46,46,46,46,46,46,46,46,46,44,44,59,59,59,59,59,59,59,59,59,59,59,62,62,59,59 }

cCor  := SETCOLOR( B_NO_PUSH )
cTela := SAVESCREEN( 4, 2, 24, 78 )

LIMPA( 5, 2, 20, 20 )

@ 5, 3 SAY "Usu rios:" COLOR B_NO_PUSH

DispBotao( 6, 3, 19, 19 )

WHILE TRUE

   aUser := {}
   aRec  := {}
   SELE USER
   GO TOP
   WHILE !EOF()
      cUser := DECRIPTO( USER->USERLIST )
      AADD( aUser, PADR( SUBSTR( cUser, 1, AT( " ", cUser ) -1 ), 15 ) )
      AADD( aRec, USER->(RecNo()) )
      USER->(dbSkip())
   END

   SCROLL( 7, 4, 18, 18 )
   nOpcao := ACHOICE( 7, 4, 18, 18, aUser, TRUE, "F_CAD", nOpcao )

   IF LASTKEY() == K_ESC ; EXIT ; END

   IF nOpcao == 0 ; LOOP ; END

   @ Row(), 4 SAY aUser[ nOpcao ] COLOR SETCORES( 4 )
   
   cTela2 := SaveScreen( 4, 22, 21, 78 )
   LIMPA( 4, 22, 21, 78 )
   DispBotao( 4, 22, 21, 78 )

   TELADIR()

   dbGoTo( aRec[ nOpcao ] )

   FMens( "" )

   cNew := PadR( DECRIPTO( ALLTRIM( USER->LOGIN ) ), 81 )
   FOR nI := 1 TO 81
       AADD ( aDireitos, SUBSTR( cNew, nI, 1 ) )
   NEXT

   FOR nI := 1 TO 45
       cT := SUBSTR("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghi", nI, 1 )
       IF cT$cNew
          @ nL[nI], nC[nI] SAY 'X' COLOR B_PUSH
       END
   NEXT

   nCursor := SETCURSOR(3)
   nI := 1
   WHILE TRUE

      @ nL[nI], nC[nI]-1 SAY "["
      nKey := INKEY(0)
      IF     nKey == K_ESC
             NetRLock(0)
             USER->LOGIN := CRIPTO( ALLTRIM(cNew) )
             UNLOCK
             EXIT

      ELSEIF nKey == K_UP
             IF nI > 1 ; nI-- ; ELSE ; nI := 45 ; END

      ELSEIF nKey == K_DOWN
             IF nI < 45 ; nI++ ; ELSE ; nI := 1 ; END

      ELSEIF nKey == K_LEFT
             IF nI > 15 ; nI -= 15 ; END

      ELSEIF nKey == K_RIGHT
             IF nI < 31 ; nI += 15 ; END

      ELSEIF nKey == K_ALT_S
             FMens( 'Digite a senha:' )
             cPass1 := ALLTRIM( UPPER( PASSWORD( 23, 28, 17 ) ) )
             FMens( 'Re-Digite a senha:' )
             cPass2 := ALLTRIM( UPPER( PASSWORD( 23, 31, 17 ) ) )
             IF cPass1 == cPass2
                NetRLock(0)
                USER->USERLIST := CRIPTO( ALLTRIM( aUser[ nOpcao ] ) + ' ' + cPass1 )
                UNLOCK

             ELSE
                FMens( 'Senhas diferentes. Tecle Enter' )
                INKEY(0)

             END
             FMens( "" )

      ELSEIF nKey == K_SPACE
             cT := SUBSTR("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghi", nI, 1 )
             IF cT$cNew // TIRA
                @ nL[nI], nC[nI] SAY " "
                @ nL[nI], nC[nI]-1 SAY "["
                cNew := SUBSTR( cNew, 1, AT(cT,cNew)-1 ) + SUBSTR( cNew, AT(cT,cNew)+1 ) + " "

             ELSE
                @ nL[nI], nC[nI] SAY "X" COLOR B_PUSH
                @ nL[nI], nC[nI]-1 SAY "["
                cNew := PADR( ALLTRIM( SUBSTR( cNew, 1, 80 ) )+cT, 81 )

             END

      ELSEIF nKey == K_F1
             HELP( PROCNAME(), PROCLINE(), "nKey" )

      END
   END
   RestScreen( 4, 22, 21, 78, cTela2 )
   SetCursor( nCursor )

END

RestScreen( 4, 2, 24, 78, cTela )

SetColor( cCor )

RETURN




*********************************************
FUNCTION F_CAD( nMode, nCurElement, nRowPos )
*********************************************
LOCAL nRetVal := AC_CONT ,;
      nKey := LASTKEY() ,;
      cNome, GETLIST := {} ,;
      nCursor

IF     nMode == AC_HITTOP .OR. nMode == AC_HITBOTTOM
       TONE( 100, 3 )

ELSEIF nMode == AC_EXCEPT
       IF     nKey == K_RETURN
              nRetVal := AC_SELECT

       ELSEIF nKey == K_ESC
              nRetVal := AC_ABORT

       ELSEIF nKey == K_INS
              FMENS('')
              cNome := SPACE( 15 )
              nCursor := SetCursor( 3 )
              @ 23, 1 SAY " Nome:      " COLOR SETCORES(1) 
              @ 23, 8 GET cNome PICT "@!"
              READ
              SetCursor( nCursor )
              IF !LASTKEY() == K_ESC
                 SELE USER
                 IF NetAppBlank()
                    USER->USERLIST := CRIPTO( ALLTRIM( cNome ) + ' ' )
                 END
                 nRetVal := AC_ABORT
              END
              FMens('')

       ELSEIF nKey == K_DEL
              dbGoTo( aRec[ nCurElement ] )
              IF SubStr( DECRIPTO( USER->USERLIST ), 1, 4 ) != "ROOT"
                 IF ATENCAO( 'Confirma Exclusao do Usu rio ?',;
                                            {'Nao','Sim'}) == 2
                    SELE USER
                    dbGoTo( aRec[ nCurElement ] )
                    IF NetRLock(0)
                       USER->(dbDelete())
                    END
                 END
              END
              nRetVal := AC_ABORT

       ELSE
              nRetVal := AC_GOTO

       END
END

RETURN nRetVal


/*

  PROCEDIMENTO AUDITELA
  
  FUNCAO: IMPRIME ARQUIVO AUDITORIA NA TELA

*/
  
********************
PROCEDURE AUDITELA()
********************
LOCAL mTexto, dData1, dData2, cTela, nCursor, cLinha, GETLIST := {}

dData1 := DATE()-7
dData2 := DATE()

cTela := ABRE( 4, 14, 21, 66, TRUE )
//@ 6, 15 TO 6, 65 DOUBLE
nCursor := SetCursor( SC_NORMAL )

WHILE .T.
//   @ 5, 16 SAY "Data Inicial:" GET dData1
//   @ 5, 43 SAY "Data Final:"   GET dData2 VALID dData2 >= dData1
//   READ
   IF LASTKEY() == K_ESC ; EXIT ; END

   mTexto := ''

   SELE AUDIT

   GO TOP

   FMENS( 'AGUARDE...' )
   WHILE !EOF()
      cLinha := DECRIPTO( AUDIT->MAKE )
      IF DTOS( dData1 ) <= SUBSTR( cLinha, 1, 8 ) .AND.;
                DTOS( dData2 ) >= SUBSTR( cLinha, 1, 8 )
         mTexto += SUBSTR(cLinha,7,2) + "/" + SUBSTR(cLinha,5,2) + "/" + ;
                   SUBSTR(cLinha,1,4)+" - " + SUBSTR(cLinha,9,8) + ;
                   " - " + SUBSTR(cLinha,17,15) + CHR(13) + CHR(10)
         mTexto += SUBSTR(cLinha,32) + CHR(13) + CHR(10)
         mTexto += "--------------------------------------------------" + CHR(13) + CHR(10)

      END
      AUDIT->(dbSkip())
   END

   mTexto += CHR(13) + CHR(10 ) + "-------------<® FINAL DOS DADOS ¯>----------------"

   FMENS( 'Use as Setas. ' )
   MemoEdit( mTexto, 5, 15, 20, 65, .F. )
   LIMPA( 5, 15, 20, 65 )

END

FECHA( 4, 14, 21, 66, cTela, TRUE )
SetCursor( nCursor )

RETURN


/*

  PROCEDIMENTO AUDIMPRE
  
  FUNCAO: IMPRIME ARQUIVO AUDITORIA NA IMPRESSORA

          LIMPA ARQUIVO DE AUDITORIA

*/
********************
PROCEDURE AUDIMPRE()
********************
LOCAL mTexto, dData1, dData2, cTela, nCursor, cLinha,;
      pRESET, pCOMPR, pDESCO, pDOUBL, pENFAT, pDESEN, aUser, cUser, cNome,;
      GETLIST := {}, cPri:=' ', nLinha, nLinImp, nLinTot, nPag, cLimpa

dData1 := DATE()-7
dData2 := DATE()
cLimpa := "S"
aUser := {}
AADD( aUser, "000 Todos" )
SELE USER
GO TOP
WHILE !EOF()
   cUser := DECRIPTO( USER->USERLIST )
   AADD( aUser, StrZero( RECNO(), 3, 0 ) + " " + PADR( SUBSTR( cUser, 1, AT( " ", cUser ) -1 ), 15 ) )
   USER->(dbSkip())
END

cUser  := "   "
cTela := ABRE( 4, 14, 10, 66, TRUE )

nCursor := SetCursor( SC_NORMAL )

WHILE .T.
   @ 5, 16 SAY "Data Inicial:" GET dData1 ;
           WHEN FMENS( 'Data INICIAL.' )

   @ 5, 43 SAY "Data Final:"   GET dData2 VALID dData2 >= dData1 ;
           WHEN FMENS( 'Data FINAL.' )

   @ 7, 16 SAY "Impressora:" GET cPri ;
           COMBO A_PRINT ;
           VALID cPri$"123" ;
           WHEN FMENS( 'Escolha a Impressora.' )

   @ 7, 40 SAY "Usuario:" GET cUser ;
           COMBO aUser ;
           WHEN FMENS( 'Escolha o Usuario.' )

   @ 9, 16 SAY "Deseja limpar dados impressos?" ;
           GET cLimpa ;
           COMBO { "Sim","Nao" } ;
           VALID cLimpa$"SN"
           
   READ
   
   IF Val( cUser ) > 0
      cNome := AllTrim(SubStr( aUser[ Val( cUser )+1 ], 5 ))
   END
   
   FMENS('')
   IF LASTKEY() == K_ESC ; EXIT ; END

   PRINTER->( dbGoto( Val( cPri ) ) )
   pRESET := PR_COMM( AllTrim( PRINTER->RESET ) )
   pCOMPR := PR_COMM( AllTrim( PRINTER->COMPR ) )
   pDESCO := PR_COMM( AllTrim( PRINTER->DESCO ) )
   pDOUBL := PR_COMM( AllTrim( PRINTER->DOUBL ) )
   pENFAT := PR_COMM( AllTrim( PRINTER->ENFAT ) )
   pDESEN := PR_COMM( AllTrim( PRINTER->DESEN ) )

   mTexto := ''

   SELE AUDIT

   AUDIT->(dbGOTOP())

   IF FPRINTER()
      FMENS( 'AGUARDE... Emitindo Relatorio... ' )
      SET DEVICE TO PRINTER
//      set printer to rel.001

      nLinImp := 100
      nPag    := 0
      @ 0,0 SAY pRESET

      WHILE !AUDIT->(EOF())
         IF nLinImp > 50
            @  0, 0 SAY pDOUBL+M->cNomeC
            @  1, 0 SAY M->cNomeA
            @  2, 0 SAY pDOUBL+pENFAT+PADC('AUDITORIA',COLUNAS/2)+pDESEN
            @  4, 0 SAY PADR('Data: ' + DTOC( DATE() ),COLUNAS/2 ) +;
                        PADL('Pagina: '+STR( ++nPag, 4, 0 ),COLUNAS/2 )
            @  5, 0 SAY Replicate("=", COLUNAS )
            @  5, 0 SAY Replicate("-", COLUNAS )
            nLinImp := 7
         END
         cLinha := DECRIPTO( AUDIT->MAKE )
         IF DTOS( dData1 ) <= SUBSTR( cLinha, 1, 8 ) .AND.;
                DTOS( dData2 ) >= SUBSTR( cLinha, 1, 8 )
            IF Val( cUser ) == 0 .OR. cNome = AllTrim(SubStr(cLinha,17,15))
   
              @ nLinImp++, 0 SAY SUBSTR(cLinha,7,2) + "/" + SUBSTR(cLinha,5,2) + "/" + ;
                   SUBSTR(cLinha,1,4)+" - " + SUBSTR(cLinha,9,8) + ;
                   " - " + SUBSTR(cLinha,17,15)
              @ nLinImp++, 0 SAY SUBSTR(cLinha,32)
              @ nLinImp++, 0 SAY "--------------------------------------------------"

              IF cLimpa == "S"
                 NetRLock(0)
                 AUDIT->(dbDelete())
              END
            END
         END
         AUDIT->(dbSkip())
      END
   END

   EJECT

   SET PRINTER TO
   SET DEVICE TO SCREEN
//   reptela('rel.001')
   FMENS('Tecle Enter.')
   ATENCAO( 'EMITIDO' )
   
END

FECHA( 4, 14, 10, 66, cTela, TRUE )
SetCursor( nCursor )

RETURN

*************************
PROCEDURE SENHA( cUser )
*************************
LOCAL cPass1, cPass2, cPass, cTela, cLocate, cCor

cTela := SaveScreen( 0, 0, MaxRow(), MaxCol() )

cCor := SetColor( SETCORES(3) )
DispBox( 10, 22, 14, 55, B_DOUBLE_SINGLE + ' ', "GR+/R" )
Sombra( 10, 22, 14, 55 )
DispBox( 11, 24, 13, 24 )

@ 11, 25 SAY "Senha Atual:"
@ 12, 25 SAY "Nova Senha:"
@ 13, 25 SAY "Confirme:"

FMens( 'Digite a Senha ATUAL.' )
cPass := ALLTRIM( UPPER( PASSWORD( 11, 38, 17 ) ) )

cLocate := CRIPTO( ALLTRIM( cUser ) + ' ' + ALLTRIM( cPass ) )

SELE USER
LOCATE FOR ALLTRIM(USER->USERLIST) == cLocate

IF FOUND()
   FMens( 'Digite a NOVA Senha.' )
   cPass1 := ALLTRIM( UPPER( PASSWORD( 12, 37, 17 ) ) )
   FMens( 'Re-Digite a NOVA Senha.' )
   cPass2 := ALLTRIM( UPPER( PASSWORD( 13, 35, 17 ) ) )
   IF cPass1 == cPass2
      NetRLock(0)
      USER->USERLIST := CRIPTO( AllTrim( cUser ) + ' ' + cPass1 )
      UNLOCK

   ELSE
      FMens( 'Senhas diferentes. Tecle Enter' )
      INKEY(0)
      
   END

ELSE
   FMens( 'Senha inv lida. Tecle Enter' )
   INKEY(0)
      
END

RestScreen( 0, 0, MaxRow(), MaxCol(), cTela )
SetColor( cCor )

RETURN
