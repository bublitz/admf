/***************

   PROGRAMA: CADUSU.prg

   FUN€AO:   CADASTRO DE USUARIOS DE PLANOS

   AUTOR:    Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'InKey.ch'
#include 'SetCurs.ch'
#include "Combo.ch"

**********************************
PROCEDURE CADUSUARIOS( cContrato )
**********************************
LOCAL cCor, nCursor, cTela, cMens, nKey,;
      oMyBrowser, oColumn1, oColumn2, oColumn3, oColumn4, oColumn5, oColumn6,;
      bFiltro, GETLIST := {}

cCor    := SETCOLOR( SETCORES(2) )
nCursor := SETCURSOR( SC_NONE )
cTela   := SAVESCREEN ( 3, 0, MAXROW()-2, MAXCOL() )
cMens   := SAVESCREEN( MAXROW()-1, 0, MAXROW()-1, MAXCOL() )
nLinha  := MaxRow() - 3

LIMPA( 4, 1, MAXROW()-3, MAXCOL()-1 )

SELE USUARIOS

oMyBrowser := TBrowseDB ( 4, 1, nLinha, MAXCOL()-1 )

oMyBrowser:colorSpec := 'W+/N, N/W, N/W, N/W'

oMyBrowser:headSep := 'ÄÂÄ'          // Separador de Cabecalho
oMyBrowser:colsep  := ' ³ '          // Separador de Colunas

IF     cArq == 'CLIENTES'
       SET RELATION TO CLIENTES->CODIGO INTO CONTRATO,;
                    TO CLIENTES->CODIGO INTO USUARIOS

       IF lFisica
          bFiltro := { || Len(AllTrim( CLIENTES->CGCCPF ) ) < 14 }
          FMens( 'P=Pesquisa. D=Dependentes.' )
          @ 3, 1 SAY PadC( 'Rela‡ao de Clientes - Pessoa F¡sica', 78 ) COLOR 'N/W'
          oColumn2 := TBColumnNew ( 'Nome', { || CLIENTES->NOME } )
          oColumn2:picture := '@!'

          oColumn3 := TBColumnNew ( 'C.P.F.', { || CLIENTES->CGCCPF } )
          oColumn3:picture := '@R 999.999.999.99'

       ELSE
          bFiltro := { || Len(AllTrim( CLIENTES->CGCCPF ) ) > 11 }
          FMens( 'P=Pesquisa.' )
          @ 3, 1 SAY PadC( 'Rela‡ao de Clientes - Pessoa Jur¡dica', 78 ) COLOR 'N/W'
          oColumn2 := TBColumnNew ( 'Razao Social', { || CLIENTES->NOME } )
          oColumn2:picture := '@!'

          oColumn3 := TBColumnNew ( 'C.G.C.', { || CLIENTES->CGCCPF } )
          oColumn3:picture := '@R 99.999.999/9999-99'

       END
       
       oMyBrowser:skipBlock := { | nRecords | Skipper( nRecords, bFiltro ) }
       oMyBrowser:goBottomBlock := { || GoBottom ( bFiltro ) }
       oMyBrowser:goTopBlock    := { || GoTop ( bFiltro ) }

       SET ORDER TO 2
       oColumn1 := TBColumnNew ( 'C¢digo' , { || CLIENTES->CODIGO } )
       oColumn1:picture := '@!'

ELSEIF cArq == 'VENDEDOR'
       SET ORDER TO 2
       FMens( 'P=Pesquisa.' )
       @ 3, 1 SAY PadC( 'Rela‡ao de Vendedores', 78 ) COLOR 'N/W'
       oColumn1 := TBColumnNew ( 'C¢digo' , { || VENDEDOR->CODIGO } )
       oColumn1:picture := '@!'
       oColumn2 := TBColumnNew ( 'Nome', { || VENDEDOR->NOME } )
       oColumn2:picture := '@!'

ELSEIF cArq == 'FORNEC'
       SET ORDER TO 2
       FMens( 'P=Pesquisa.' )
       @ 3, 1 SAY PadC( 'Rela‡ao de Fornecedores', 78 ) COLOR 'N/W'
       oColumn1 := TBColumnNew ( 'C¢digo' , { || FORNEC->CODIGO } )
       oColumn1:picture := '@!'
       oColumn2 := TBColumnNew ( 'Nome', { || FORNEC->NOME } )
       oColumn2:picture := '@!'

ELSEIF cArq == 'CHEQUES'
       FMens( '' )
       @ 3, 1 SAY PadC( 'Rela‡ao de Cheques', 78 ) COLOR 'N/W'
       oColumn1 := TBColumnNew ( 'Cli/For', { || CHEQUES->CLIFOR } )
       oColumn1:picture := '@!'
       oColumn2 := TBColumnNew ( 'N£mero' , { || CHEQUES->NUMERO } )
       oColumn2:picture := '@!'
       oColumn3 := TBColumnNew ( 'Banco', { || CHEQUES->BANCO } )
       oColumn3:picture := '@!'
       oColumn4 := TBColumnNew ( 'Valor', { || CHEQUES->VALOR } )
       oColumn4:picture := '@E 999,999,999,999.99'
       oColumn5 := TBColumnNew ( 'Bom P/', { || CHEQUES->DTPAGAR } )
       oColumn6 := TBColumnNew ( 'Pg ³ Im', { || IF(EMPTY(CHEQUES->DTRECEBEU),;
                        ' N',' S')+' ³ '+ CHEQUES->EMITIDO + ' ' } )
       oColumn6:picture := '@!'

ELSEIF cArq == 'BANCOS'
       FMens( '' )
       @ 3, 1 SAY PadC( 'Rela‡ao de Bancos', 78 ) COLOR 'N/W'
       oColumn1 := TBColumnNew ( 'C¢digo', { || BANCOS->CODIGO } )
       oColumn1:picture := '@!'
       oColumn2 := TBColumnNew ( 'Nome' , { || BANCOS->NOME } )
       oColumn2:picture := '@!'
       oColumn3 := TBColumnNew ( 'Saldo Total', { || BANCOS->SALDODISP+BANCOS->SALDOVINC } )
       oColumn3:picture := '@E 9 999 999 999 999.99'
       oColumn4 := TBColumnNew ( 'Dispon¡vel', { || BANCOS->SALDODISP } )
       oColumn4:picture := '@E 999,999,999,999.99'
       oColumn5 := TBColumnNew ( 'Vinculado', { || BANCOS->SALDOVINC } )
       oColumn5:picture := '@E 999,999,999,999.99'

ELSEIF cArq == 'CCUSTO'
       @ 3, 1 SAY PadC( 'Rela‡ao de Centro de Custo', 78 ) COLOR 'N/W'
       oColumn1 := TBColumnNew ( 'C¢digo' , { || CCUSTO->CODIGO } )
       oColumn1:picture := '@!'
       oColumn2 := TBColumnNew ( 'Nome', { || CCUSTO->NOME } )
       oColumn2:picture := '@!'

ELSEIF cArq == 'GRUPOS'
       @ 3, 1 SAY PadC( 'Rela‡ao de Grupos', 78 ) COLOR 'N/W'
       oColumn1 := TBColumnNew ( 'C¢digo' , { || GRUPOS->CODIGO } )
       oColumn1:picture := '@!'
       oColumn2 := TBColumnNew ( 'Nome', { || GRUPOS->NOME } )
       oColumn2:picture := '@!'

END

IF bFiltro == Nil
   GO TOP

ELSE
   GoTop( bFiltro )

END

// Adiciona colunas ao TBrowser
oMyBrowser:addColumn ( oColumn1 )
oMyBrowser:addColumn ( oColumn2 )
oMyBrowser:addColumn ( oColumn3 )
IF cArq == 'LANCTOS'
   oMyBrowser:addColumn ( oColumn4 )

ELSEIF cArq =='BANCOS'
   oMyBrowser:addColumn ( oColumn4 )
   oMyBrowser:addColumn ( oColumn5 )

ELSEIF cArq =='CHEQUES'
   oMyBrowser:addColumn ( oColumn4 )
   oMyBrowser:addColumn ( oColumn5 )
   oMyBrowser:addColumn ( oColumn6 )

END

// oMyBrowser:freeze := 1                // Congela a 1¦ Coluna

SETCURSOR( SC_NONE )
oMyBrowser:panHome()
oMyBrowser:refreshAll()

WHILE TRUE

   WHILE ( !oMyBrowser:stabilize () ) 
      IF ( nKey := INKEY() ) != 0 ; EXIT ; END
   END

   oMyBrowser:colorRect( { oMyBrowser:rowPos, 1, oMyBrowser:rowPos,; 
                           oMyBrowser:colCount }, { 3, 4 } )

   IF oMyBrowser:stable ()

      IF cArq == 'CLIENTES'
         @ nLinha+1, 2 SAY "Contrato: "
         IF !Empty( AllTrim( CONTRATO->NUMERO ) )
            @ nLinha+1, 12 SAY CONTRATO->NUMERO
         ELSE
            @ nLinha+1, 12 SAY USUARIOS->CONTRATO
         END
      END
      
      WHILE TRUE

         oMyBrowser:hilite()

         IF ( nKey := INKEY ( 0.3 ) ) != 0    // delay
            EXIT
         END

         oMyBrowser:deHilite()

         IF ( nKey := INKEY ( 0.3 ) ) != 0    // delay
            EXIT
         END

      END

   END

   IF nKey == K_ESC ; EXIT ; END

   IF     nKey == K_LEFT
          oMyBrowser:panLeft()
          
   ELSEIF nKey == K_RIGHT
          oMyBrowser:panRight()
          
   ELSEIF !Teclas( oMyBrowser, nKey )

          IF     nKey == K_F1
                 HELP( PROCNAME(), PROCLINE(), '' )

          ELSEIF nKey == K_ENTER .AND. lRet
                 KeyBoard( Repl( Chr( K_BS ), 10 ) + Eval( oColumn1:block ) )
                 EXIT
                 
          ELSEIF UPPER( CHR( nKey ) ) == 'P' .AND. lPesq
                 cMensT := SAVESCREEN( MAXROW()-1, 0, MAXROW(), MAXCOL() )
                 @ MAXROW()-1, 1 SAY SPACE( MAXCOL()-10 ) COLOR SETCORES(1)
                 cPesq := SPACE( 30 )
                 @ MAXROW()-1, 1 SAY 'Nome: '        COLOR SETCORES(1) ;
                                 GET cPesq PICT '@!' COLOR SETCORES(2)
                 SETCURSOR(3)
                 READ
                 SETCURSOR( SC_NONE )
                 IF bFiltro == NIL ; GO TOP
                 ELSE              ; GoTop( bFiltro )
                 END
                 SEEK ALLTRIM( cPesq )
                 IF !FOUND() 
                    IF bFiltro == NIL ; GO TOP
                    ELSE              ; GoTop( bFiltro )
                    END
                 ELSE
                    BEEP()
                 END
                 RESTSCREEN( MAXROW()-1, 0, MAXROW(), MAXCOL(), cMensT )
                 oMyBrowser:refreshAll()

          ELSEIF Upper( Chr( nKey ) ) == 'D' .AND. cArq == 'CLIENTES'
                 cMensT := ABRE( 5, 10, 17, 69, .T. )
                 TELADEP()
                 @  6, 21 SAY CLIENTES->CODIGO
                 @  7, 12 SAY CLIENTES->NOME COLOR SETCORES(3)
                 aDep := {}
                 cPesq := CLIENTES->CODIGO
                 SELE DEPENDEN
                 SEEK cPesq
                 IF FOUND()
                    WHILE DEPENDEN->CODIGO == cPesq .AND. !Eof()
                       AADD( aDep, ' ' + ;
                             DEPENDEN->ORDEM      + ' ³ ' +;
                             DEPENDEN->NOME       + ' ³ ' +;
                             DEPENDEN->SEXO       + ' ³ ' +;
                             DEPENDEN->PARENTESCO + ' ³ ' +;
                             DTOC(DEPENDEN->NASCIMENTO) + ' ' )
                       DEPENDEN->(dbSkip())
                    END
                    ACHOICE( 11, 11, 16, 68, aDep )
                 END
                 FECHA( 5, 10, 17, 69, cMensT, .T. )
                 SELE CLIENTES

          END
   END

   oMyBrowser:refreshCurrent()
   
END

SET RELATION TO
SET ORDER TO nOrde2
GO nRegi2

SELE USUARIOS
SET ORDER TO nOrdUsu

SELE CONTRATO
SET ORDER TO nOrdCon

SELECT( nSele1 )
SET ORDER TO nOrde1
GO nRegi1

SETCOLOR( cCor )
SETCURSOR( nCursor )
RestScreen ( 3, 0, MAXROW()-2, MAXCOL(), cTela )
RESTSCREEN( MAXROW()-1, 0, MAXROW()-1, MAXCOL(), cMens )
RETURN

/****

  FIM CADUSU.PRG

****/
