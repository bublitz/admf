/***************

PROGRAMA: CADLIBE.prg

FUN€AO: LIBERACAO DE CARTEIRINHAS

AUTOR: Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'

******************
PROCEDURE LIBERA()
******************
LOCAL cTela, cTelaLimpa, cCor, nEscolha,;
      nII, nCursor, GETLIST := {},;
      lInclui, nOpcao, lAchou,;
      cCodCli, nCodCli,;
      nContrato, cContrato, cTipo,;
      dLibera, cWhoLibera, nLinha, lLiberada,;
      cConf, nCart, mError, i

cTela   := SAVESCREEN ( 0, 0, MAXROW(), MAXCOL() )
nCursor := SETCURSOR( SC_NORMAL )
cCor    := SETCOLOR( SETCORES(1) )

LIMPA( 4, 1, MAXROW()-3, MAXCOL()-1 )

SELE LIBERA

@ 4, 1 SAY PADC ( 'LIBERA€AO DE CARTEIRINHAS', 78 )
@ 5, 1 SAY PADC ( 'ßßßßßßßßßßßßßßßßßßßßßßßßß', 78 )

//            1         2
//       56789 123456789 123456789
@  7, 10 SAY 'Numero do Contrato:'
@  9, 10 SAY 'Cliente:'
//@ 11, 10 SAY 'Dependente:'
FMENS('')

cTelaLimpa := SAVESCREEN ( 0, 0, MAXROW(), MAXCOL() )

WHILE TRUE

   UNLOCK
   COMMIT

   RESTSCREEN ( 0, 0, MAXROW(), MAXCOL(), cTelaLimpa )

   nCodCli := nContrato := 0
   cTipo   := " "

   SETCURSOR ( SC_NORMAL )

   @  7, 30 GET nContrato PICT '99999999' ;
            WHEN FMENS( 'Digite o Numero do Contrato.' ) ;
            VALID nContrato == 0 .OR. PESQCON( nContrato, 9, 29, @cTipo )

   @  9, 19 GET nCodCli PICT '99999999' ;
            WHEN nContrato == 0 .AND. ;
            FMENS( 'Digite o C¢digo do Cliente. 0=Nenhum. F2=Clientes.' ) ;
            VALID nCodCli == 0 .OR. PESQCLI( nCodCli, 9, 29 )

   READ

   IF LASTKEY() == K_ESC ; EXIT ; END

   IF nCodCli + nContrato == 0 ; LOOP ; END

   SELE LIBERA

   IF nContrato == 0 // Clientes
      cCodCli := StrZero ( nCodCli, 8, 0 )

      lLiberada := FALSE
      SEEK cCodCli

      nLinha := 13
      IF Found() // Achou, entao pode estar liberada
         @ nLinha++, 5 SAY 'Liberada   Pelo Usuario    ³ Impressa   Pelo Usuario   '
         @ nLinha++, 5 SAY 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
         //                 99/99/9999 123456789012345   99/99/9999 123456789012345
         WHILE LIBERA->CODIGO == cCodCli .AND. !LIBERA->(EOF())
            @ nLinha++, 5 SAY DTOC(LIBERA->DTLIBERA) + ' ' + LIBERA->WHOLIBERA + ' ³ ' +;
                          IF(!Empty(LIBERA->DTEMISS),;
                          DTOC(LIBERA->DTEMISS) + ' ' + LIBERA->WHOEMISS,;
                          Space(24) )

            IF Empty( LIBERA->DTEMISS ) // Data de Emissao vazia
               lLiberada := TRUE        // J  est  liberada
            END                         // mas nÆo foi impressa
            IF nLinha > 19
               nLinha := 19
               Scroll( 15, 5, 19, 77, 1 )
            END
            LIBERA->(dbSkip())
         END

         IF lLiberada
            FMENS( '** ATENCAO ** !!! Esta carteirinha j  est  liberada!' )
            INKEY(0)
            LOOP
         END

      END

      IF !lLiberada       // NAO ACHOU
         cConf := ' '
         @ nLinha+1, 10 SAY 'Confirma libera‡ao da Carteirinha ?' ;
                  GET cConf PICT '!' ;
                  VALID cConf$'SN'
         READ
         IF cConf == 'S'
            NetAppBlank(0)
            LIBERA->CODIGO    := cCodCli
            LIBERA->DTLIBERA  := Date()
            LIBERA->WHOLIBERA := PadR( M->cUsuario, 15 )
            UNLOCK
            SELE CLIENTES
            SET ORDER TO 1
            SEEK cCodCli
            IF Found()
               NetRLock(0)
               nCart := Val( CLIENTES->CARTEIRA )
               IF nCart == 9 ; nCart := 0 ; END
               CLIENTES->CARTEIRA := Str( ++nCart, 1, 0 )

            ELSE
               ShowTime()
               CLS
               ? 'Ocorreu ERRO L¢gico no Sistema.;Chame o ROOT.' + CR
               IF File( 'ADMF.ERR' )
                  mError := MemoRead( 'ADMF.ERR' )

               ELSE
                  mError := ''

               END

               mError += " " + CR + Repl( "-" , 79 ) + CR
               mError += "Data: " + DTOC( DATE() ) + "      Hora: " + TIME() + CR
               mError += "Mensagem: Nao encontrou o Cliente." + CR
               i := 2
               WHILE ( !Empty(ProcName(i)) )
                   mError += "Proc: " + AllTrim(ProcName(i)) + ;
                                  "(" + AllTRIM(ProcLine(i)) + ")" + CR
                   i++
               END

               MemoWrit( 'ADMF.ERR' , mError )
               QUIT

            END
            COMMIT

         END

      END

   ELSE              // CONTRATOS
      cContrato := StrZero( nContrato, 8, 0 )
      SELE USUARIOS
      SET ORDER TO 1
      SEEK cContrato
      IF Found() // Tem usu rios
         cConf := ' '
         @ 13, 10 SAY 'Confirma libera‡ao da(s) Carteirinha(s) ?' ;
                  GET cConf PICT '!' ;
                  VALID cConf$'SN'
         READ
         IF cConf == 'S'
            WHILE USUARIOS->CONTRATO == cContrato .AND. !CONTRATO->(EOF())
               cCodCli := USUARIOS->CLIENTE

               lLiberada := FALSE
               SELE LIBERA
               SEEK cCodCli

               IF Found() // Achou, entao pode estar liberada
                  WHILE LIBERA->CODIGO == cCodCli .AND. !LIBERA->(EOF())
                     IF Empty( LIBERA->DTEMISS ) // Data de Emissao vazia
                        lLiberada := TRUE        // J  est  liberada
                     END                         // mas nÆo foi impressa

                     LIBERA->(dbSkip())
                  END

               END

               IF !lLiberada       // NAO ACHOU
                  NetAppBlank(0)
                  LIBERA->CODIGO    := cCodCli
                  LIBERA->DTLIBERA  := Date()
                  LIBERA->WHOLIBERA := PadR( M->cUsuario, 15 )
                  UNLOCK
                  SELE CLIENTES
                  SET ORDER TO 1
                  SEEK cCodCli
                  IF Found()
                     NetRLock(0)
                     nCart := Val( CLIENTES->CARTEIRA )
                     IF nCart == 9 ; nCart := 0 ; END
                     CLIENTES->CARTEIRA := Str( ++nCart, 1, 0 )

                  ELSE
                     ShowTime()
                     CLS
                     ? 'Ocorreu ERRO L¢gico no Sistema.'
                     ? 'Chame o ROOT.' + CR
                     IF File( 'ADMF.ERR' )
                        mError := MemoRead( 'ADMF.ERR' )

                     ELSE
                        mError := ''

                     END

                     mError += " " + CR + Repl( "-" , 79 ) + CR
                     mError += "Data: " + DTOC( DATE() ) + "      Hora: " + TIME() + CR
                     mError += "Mensagem: Nao encontrou o Cliente." + CR
                     i := 2
                     WHILE ( !Empty(ProcName(i)) )
                         mError += "Proc: " + AllTrim(ProcName(i)) + ;
                                     "(" + AllTRIM(ProcLine(i)) + ")" + CR
                         i++
                     END

                     MemoWrit( 'ADMF.ERR' , mError )
                     QUIT

                  END
                  COMMIT

               END  // SE LIBERADA

               USUARIOS->(dbSkip())

            END   // CONTRATO !EOF()
         END
      END  // CONTRATO TEM USUARIOS

   END

   CLEAR TYPE
   FMENS( 'ATENCAO! Tecle <C> para continuar.' )
   WHILE UPPER(CHR(INKEY(0))) != "C" ; END

END

RestScreen ( 0, 0, MaxRow(), MaxCol(), cTela )
SetColor( cCor )
SetCursor( nCursor )
RETURN
