/**********************

 Programa: MENUPRIN.prg

**********************/

#include 'MEU.CH'
#include 'BOX.CH'
#include 'INKEY.ch'
#include 'SETCURS.ch'

#define INCLUI .F.

**********************************************
PROCEDURE PRINCIPAL( cUser, cPass, cTerminal )
**********************************************
LOCAL nOpcao, cTela, nCheques, nPagar, nReceber, cTelaP, nLinha, nEscolha,;
      dDataHoje, GetList := {}, cTelaData

MEMVAR cRight, cTerm, nMens, aDataValor, cUsuario

FIELD NUMERO, CLIENTE, CONTRATO, CODIGO, NOME, ORDEM, BANCO, DATA, CLIFOR,;
      VENCTO, CODCEN, CODGRU, CODFOR, PARCELA, PROG, VARI, PROG_VARI,;
      DTPAGTO, CODCLI, CODFUNC, CODPROV, NROFATURA, TIPO, MARCA, MODELO,;
      ANO, PROPRIETAR

cRight   := cPass
cUsuario := cUser
cTerm    := cTerminal

SetCursor ( SC_NONE )

@ 1, 40 SAY PadL( "Usu rio: " + cUser, 38 )

/*******
  CONFIGURA TECLAS DE FUNCAO
*******/

IF "U"$cRight
   SET KEY K_F2 TO TBMOSTRA()
END   

IF "V"$cRight
   SET KEY K_F3 TO TBMOSTRA()
END   

IF "W"$cRight
   SET KEY K_F4 TO TBMOSTRA()
END   

IF "X"$cRight
   SET KEY K_F5 TO TBMOSTRA()
END   

IF "Y"$cRight
   SET KEY K_F6 TO TBMOSTRA()
END   

IF "Z"$cRight
   SET KEY K_F7 TO TBMOSTRA()
END

IF "a"$cRight
   SET KEY K_F8 TO TBMOSTRA()
END   

IF "b"$cRight
//   SET KEY K_F9 TO TBMOSTRA()
END   

IF "c"$cRight
   SET KEY K_F10 TO TBMOSTRA()
END   

SET KEY K_F11 TO FUNCHELP()

SET KEY K_F12 TO CALCULADORA()

// VERIFICA INTEGRIDADE


IF File ( '$PANE.$$$' )

   cTela := SaveScreen( 4, 1, 22, 78 )
   ABRE( 6, 9, 20, 70, TRUE )
   FMENS( 'AGUARDE... Reorganizando arquivos...' )

   @  8, 13  SAY "Estoque           Faturas/Func.       Caixa"
   @ 10, 13  SAY "Produtos          Grupos              Contas a Pagar"
   @ 12, 13  SAY "Clientes          Bancos              Contas a Receber"
   @ 14, 13  SAY "Funcion rios      Saldos              Help"
   @ 16, 13  SAY "Movimento         Lan‡amentos         Fun‡oes"
   @ 18, 13  SAY "Proventos         Cheques             Impressoras"
   
   @  8, 11 SAY "  Estoque "   COLOR "W+/N"
   @  8, 11 SAY Chr( 7 )       COLOR "W+*/N"
   USE TABELA EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON TIPO+CODIGO TO TABELA
      dbCloseArea()
   END
   @  8, 11 SAY "û Estoque "

   @ 10, 11 SAY "  Produtos "  COLOR "W+/N"
   @ 10, 11 SAY Chr( 7 )       COLOR "W+*/N"
   USE CAMINHAO EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON TIPO+PROPRIETAR+MARCA+MODELO+ANO TO CAMINHA1
      INDEX ON TIPO+MARCA+MODELO+ANO            TO CAMINHA2
      dbCloseArea()
   END
   USE VENDAS EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON PROPRIETAR+MARCA+MODELO+ANO TO VENDA1
      INDEX ON NUMERO                      TO VENDA2
      dbCloseArea()
   END
   @ 10, 11 SAY "û Produtos "
   
   @ 12, 11 SAY "  Clientes "  COLOR "W+/N"
   @ 12, 11 SAY Chr( 7 )       COLOR "W+*/N"
   USE CLIENTES EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON CODIGO TO CLIENTE1
      INDEX ON NOME   TO CLIENTE2
      dbCloseArea()
   END
   @ 12, 11 SAY "û Clientes "

   @ 14, 11 SAY "  Funcion rios "  COLOR "W+/N"
   @ 14, 11 SAY Chr( 7 )       COLOR "W+*/N"
   USE FUNCIONA EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON CODIGO TO FUNC1
      INDEX ON NOME   TO FUNC2
      dbCloseArea()
   END
   @ 14, 11 SAY "û Funcion rios "

   @ 16, 11 SAY "  Movimento "  COLOR "W+/N"
   @ 16, 11 SAY Chr( 7 )       COLOR "W+*/N"
   USE MOVIMENT EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON CODFUNC+CODPROV+DTOS(DATA) TO MOVIMEN1
      INDEX ON NROFATURA                  TO MOVIMEN2
      dbCloseArea()
   END
   @ 16, 11 SAY "û Movimento "

   @ 18, 11 SAY "  Proventos "  COLOR "W+/N"
   @ 18, 11 SAY Chr( 7 )       COLOR "W+*/N"
   USE PRODES EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON CODIGO TO PRODES
      dbCloseArea()
   END
   @ 18, 11 SAY "û Proventos "

   @  8, 29 SAY "  Faturas/Func. " COLOR "W+/N"
   @  8, 29 SAY Chr( 7 )       COLOR "W+*/N"
   USE FATURAS EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON NUMERO TO FATUR
      dbCloseArea()
   END
   @  8, 29 SAY "û Faturas/Func. "

   @ 10, 29 SAY "  Grupos " COLOR "W+/N"
   @ 10, 29 SAY Chr( 7 )       COLOR "W+*/N"
   USE GRUPOS EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON CODIGO TO GRUPOS
      dbCloseArea()
   END
   @ 10, 29 SAY "û Grupos "

   @ 12, 29 SAY "  Bancos " COLOR "W+/N"
   @ 12, 29 SAY Chr( 7 )       COLOR "W+*/N"
   USE BANCOS EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON CODIGO TO BANCOS
      dbCloseArea()
   END
   @ 12, 29 SAY "û Bancos "

   @ 14, 29 SAY "  Saldos " COLOR "W+/N"
   @ 14, 29 SAY Chr( 7 )       COLOR "W+*/N"
   USE SALDOS EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON BANCO+DTOS(DATA) TO SALDOS
      dbCloseArea()
   END
   @ 14, 29 SAY "û Saldos "

   @ 16, 29 SAY "  Lan‡amentos " COLOR "W+/N"
   @ 16, 29 SAY Chr( 7 )       COLOR "W+*/N"
   USE LANCTOS EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON BANCO+NUMERO TO LANCTOS1
      INDEX ON BANCO+DTOS(DATA) TO LANCTOS2
      dbCloseArea()
   END
   @ 16, 29 SAY "û Lan‡amentos "

   @ 18, 29 SAY "  Cheques " COLOR "W+/N"
   @ 18, 29 SAY Chr( 7 )       COLOR "W+*/N"
   USE CHEQUES EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON CLIFOR+NUMERO+BANCO TO CHEQUE1
      INDEX ON NUMERO+BANCO        TO CHEQUE2
      dbCloseArea()
   END
   @ 18, 29 SAY "û Cheques "

   @  8, 49 SAY "  Caixa " COLOR "W+/N"
   @  8, 49 SAY Chr( 7 )       COLOR "W+*/N"
   USE CAIXA EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON DATA TO CAIXA
      dbCloseArea()
   END
   USE DETALHE EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON DATA TO DETALHE
      dbCloseArea()
   END
   @  8, 49 SAY "û Caixa "

   @ 10, 49 SAY "  Contas a Pagar " COLOR "W+/N"
   @ 10, 49 SAY Chr( 7 )       COLOR "W+*/N"
   USE PAGAR EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON NUMERO               TO PAGAR1
      INDEX ON DTOS(VENCTO)+CODGRU+CODFOR TO PAGAR2
      INDEX ON DTOS(DTPAGTO)+CODGRU+CODFOR TO PAGAR3
      dbCloseArea()
   END
   USE FORNEC EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON CODIGO TO FORNEC1
      INDEX ON NOME   TO FORNEC2
      dbCloseArea()
   END

   @ 10, 49 SAY "û Contas a Pagar "

   @ 12, 49 SAY "  Contas a Receber " COLOR "W+/N"
   @ 12, 49 SAY Chr( 7 )       COLOR "W+*/N"
   USE RECEB EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON NUMERO               TO RECEB1
      INDEX ON CODGRU+CODCLI        TO RECEB2
      dbCloseArea()
   END

   @ 12, 49 SAY "û Contas a Receber "

   @ 14, 49 SAY "  Help " COLOR "W+/N"
   @ 14, 49 SAY Chr( 7 )       COLOR "W+*/N"
   USE HELP EXCLUSIVE NEW
   IF !NetErr()
      INDEX ON PROG+VARI TO HELP
      dbCloseArea()
   END
   @ 14, 49 SAY "û Help "
      
   @ 16, 49 SAY "  Fun‡oes " COLOR "W+/N"
   @ 16, 49 SAY Chr( 7 )       COLOR "W+*/N"
   USE FUNCOES EXCLUSIVE NEW
   IF !NetErr()
      INDEX ON PROG_VARI TO FUNCOES
      dbCloseArea()
   END
   @ 16, 49 SAY "û Fun‡oes "
      
   @ 18, 49 SAY "  Impressoras " COLOR "W+/N"
   @ 18, 49 SAY Chr( 7 )       COLOR "W+*/N"
   USE AUDIT EXCLUSIVE NEW
   IF !NetErr()
      PACK
      dbCloseArea()
   END
   @ 18, 49 SAY "û Impressoras "
   
   RestScreen( 4, 1, 22, 78, cTela )

ELSE
   MemoWrit( '$PANE.$$$', '$PANE.$$$' )

END

dbCloseAll()

FMENS( 'Abrindo Arquivo Geral...' )
NetUse( 'AUDIT',,0 )

FMENS( 'Abrindo Arquivo de Funcoes...' )
NetUse( 'FUNCOES',,0 )
SET INDEX TO FUNCOES

FMENS( 'Abrindo Arquivo de Usuarios...' )
NetUse( 'USER',,0 )

FMENS( 'Abrindo Arquivo de Clientes...' )
NetUse( 'CLIENTES',,0 )
SET INDEX TO CLIENTE1, CLIENTE2

FMENS( 'Abrindo Arquivo de Funcionarios...' )
NetUse( 'FUNCIONA',,0 )
SET INDEX TO FUNC1, FUNC2

FMENS( 'Abrindo Arquivo de Movimento...' )
NetUse( 'MOVIMENT',,0 )
SET INDEX TO MOVIMEN1, MOVIMEN2

FMENS( 'Abrindo Arquivo de Caminhoes...' )
NetUse( 'CAMINHAO',,0 )
SET INDEX TO CAMINHA1, CAMINHA2

NetUse( 'VENDAS',,0 )
SET INDEX TO VENDA1, VENDA2

FMENS( 'Abrindo Arquivo de Tabela...' )
NetUse( 'TABELA',,0 )
SET INDEX TO TABELA

FMENS( 'Abrindo Arquivo de Bancos...' )
NetUse( 'BANCOS',,0 )
SET INDEX TO BANCOS

FMENS( 'Abrindo Arquivo de Proventos e Descontos...' )
NetUse( 'PRODES',,0 )
SET INDEX TO PRODES

FMENS( 'Abrindo Arquivo de Faturas...' )
NetUse( 'FATURAS',,0 )
SET INDEX TO FATUR

FMENS( 'Abrindo Arquivo de Lan‡amentos...' )
NetUse( 'LANCTOS',,0 )
SET INDEX TO LANCTOS1,LANCTOS2

FMENS( 'Abrindo Arquivo de Cheques...' )
NetUse( 'CHEQUES',,0 )
SET INDEX TO CHEQUE1,CHEQUE2

FMENS( 'Abrindo Arquivo de Grupos...' )
NetUse( 'GRUPOS',,0 )
SET INDEX TO GRUPOS

FMENS( 'Abrindo Arquivo de Caixa...' )
NetUse( 'CAIXA',,0 )
SET INDEX TO CAIXA
NetUse( 'DETALHE',,0 )
SET INDEX TO DETALHE

FMENS( 'Abrindo Arquivo de Contas a Pagar...' )
NetUse( 'PAGAR',,0 )
SET INDEX TO PAGAR1,PAGAR2,PAGAR3

FMENS( 'Abrindo Arquivo de Fornecedores...' )
NetUse( 'FORNEC',,0 )
SET INDEX TO FORNEC1,FORNEC2

FMENS( 'Abrindo Arquivo de Contas a Receber...' )
NetUse( 'RECEB',,0 )
SET INDEX TO RECEB1,RECEB2

FMENS( 'Abrindo Arquivo de Saldos...' )
NetUse( 'SALDOS',,0 )
SET INDEX TO SALDOS
      
FMENS( 'Abrindo Arquivo de Impressoras...' )
NetUse( 'PRINTER',,0 )

dDataHoje := Date()
cTelaData := ABRE2( 11, 31, 13, 48, TRUE )
@ 12, 33 SAY Chr(16)
@ 12, 46 SAY Chr(17)
FMens( 'Digite a Data Atual' )
SetCursor ( SC_NORMAL )
@ 12, 35 GET dDataHoje
READ
IF dDataHoje != Date()
   SetDate( dDataHoje, IsAT() )
END
@  2, 62 SAY 'Data: ' + DTOC ( DATE () )
FECHA2( cTelaData )

SetCursor ( SC_NONE )
FMENS( "AGUARDE... Verificando pendˆncias..." )

ACAO( 'ACESSOU O SISTEMA' )

/**********




            BUSCA CONTAS E CHEQUES PRE-DATADOS QUE VENCEM HOJE




**********/

cTelaP := ABRE( 6, 10, 20, 69, TRUE )

nCheques := nPagar := nReceber := 0

IF 'P'$cRight
   @ 7, 12 SAY Chr( 7 ) COLOR SETCORES(5)
   @ 7, 14 SAY "Cheques Pr‚-Datados"
   SELE CHEQUES
   CHEQUES->(dbGoTop())
   DO WHILE !CHEQUES->(EOF())
      IF CHEQUES->DTPAGAR <= DATE() .AND. Empty( CHEQUES->DTRECEBEU )
         nCheques++
         EXIT
      END
      CHEQUES->(dbSkip())
   END
   @ 7, 12 SAY Chr( 251 )
   IF nCheques > 0
      @  9, 14 SAY 'H  Cheques Pr‚-Datados para hoje ou j  vencidos.' ;
               COLOR SETCORES( 3 )
   ELSE
      @  9, 14 SAY 'Nao h  Cheques para hoje ou j  vencidos.'
   END
END   

IF 'O'$cRight
   @ 12, 12 SAY Chr( 7 ) COLOR SETCORES(5)
   @ 12, 14 SAY "Contas a Pagar"
   SELE PAGAR
   PAGAR->(dbGoTop())
   DO WHILE !PAGAR->(EOF())
      IF PAGAR->VENCTO <= DATE() .AND. Empty( PAGAR->DTPAGTO )
         nPagar++
         EXIT
      END
      PAGAR->(dbSkip())
   END
   @ 12, 12 SAY Chr( 251 )
   IF nPagar > 0
      @ 14, 14 SAY 'H  Contas a Pagar para hoje ou j  vencidas.' ;
               COLOR SETCORES( 3 )
   ELSE
      @ 14, 14 SAY 'Nao h  Contas a Pagar para hoje ou j  vencidas.'
   END

   @ 17, 12 SAY Chr( 7 ) COLOR SETCORES(5)
   @ 17, 14 SAY "Contas a Receber"

   SELE RECEB
   RECEB->(dbGoTop())
   DO WHILE !RECEB->(EOF())
      IF RECEB->VENCTO <= DATE() .AND. Empty( RECEB->DTPAGTO )
         nReceber++
         EXIT
      END
      RECEB->(dbSkip())
   END
   @ 17, 12 SAY Chr( 251 )
   IF nReceber > 0
      @ 19, 14 SAY 'H  Contas a Receber para hoje ou j  vencidas.' ;
               COLOR SETCORES( 3 )
   ELSE
      @ 19, 14 SAY 'Nao h  Contas a Receber para hoje ou j  vencidas.'
   END

END   

IF nCheques+nPagar+nReceber > 0
   FMENS( 'Tecle algo...' )
   InKey( 0 )
END
   
FECHA( 6, 10, 20, 69, cTelaP, TRUE )

SetColor( SETCORES( 1 ))

IF MOD(Day( Date() ),3) = 1
   SAVE SCREEN TO cTelaP
   FMENS( 'Tecle Enter.' )
   DIREITOS()
   CLEAR TYPE
   WHILE INKEY(0) # K_ENTER ; END
   REST SCREEN FROM cTelaP
END
    

ABRE( 6, 10, 16, 29, TRUE )

WHILE TRUE
   FMENS('Use as Setas '+CHR(24)+' e '+CHR(25)+'.   F1=Help.   F11=Fun‡oes.')
   @  7, 12 PROMPT '1. Estoque      '
   @  8, 12 PROMPT '2. Clientes     '
   @  9, 12 PROMPT '3. Funcion rios '
   @ 10, 12 PROMPT '4. Contas       '
   @ 11, 12 PROMPT '5. Bancos       '
   @ 12, 11 TO 12, 28
   @ 13, 12 PROMPT '6. Relat¢rios   '
   @ 14, 11 TO 14, 28
   IF cUser == "ROOT"
      @ 15, 12 PROMPT '7. Auditoria    '
   ELSE
      @ 15, 12 PROMPT '7. Senha        '
   END
   MENU TO nOpcao

   IF     nOpcao == 0 .AND. ATENCAO( 'Confirma sa¡da ?', {'Sim','Nao'},;
                                   SETCORES(2) ) == 1
          ACAO( 'ENCERROU O SISTEMA' )
          EXIT

   ELSEIF nOpcao == 1 .AND. "0"$cRight
          Estoque()
          
   ELSEIF nOpcao == 2 .AND. "2"$cRight
          CLIENTES()

   ELSEIF nOpcao == 3 .AND. "4"$cRight
          MenuFuncio() // MENUFUN.PRG

   ELSEIF nOpcao == 4
          MenuContas()

   ELSEIF nOpcao == 5
          MenuBancos()

   ELSEIF nOpcao == 6 .AND. "F"$cRight
          MenuRelat()

   ELSEIF nOpcao == 7
          IF cUser == "ROOT"
             AUDITORIA()
          ELSE
             SENHA( cUser )
          END
          
   END

END

SET KEY K_F2  TO
SET KEY K_F3  TO
SET KEY K_F4  TO
SET KEY K_F5  TO
SET KEY K_F6  TO
SET KEY K_F7  TO
SET KEY K_F8  TO
SET KEY K_F9  TO
SET KEY K_F10 TO
SET KEY K_F11 TO
SET KEY K_F12 TO

dbCloseAll()
FErase ( '$PANE.$$$' )
RETURN

*****************************************
PROCEDURE TBMOSTRA( cProg, nLin, cVar )
*****************************************
LOCAL cCor, nCursor, cTela, cArq, cMens, lPesq := FALSE, cPesq, cMensT,;
      oMyBrowser, oColumn1, oColumn2, oColumn3, oColumn4, oColumn5, oColumn6,;
      nKey, bFiltro, nSele1, nOrde1, nOrde2, nRegi1, nRegi2, nLinha,;
      GETLIST := {}, aDep, lFisica, lRet := FALSE, nOrdCon, nOrdUsu,;
      nL, nC, nQ, nP, nCodi, aSenha, nII

nKey    := LastKey()
cCor    := SETCOLOR( SETCORES(2) )
nCursor := SETCURSOR( SC_NONE )
cTela   := SAVESCREEN ( 3, 0, MAXROW()-2, MAXCOL() )
cMens   := SAVESCREEN( MAXROW()-1, 0, MAXROW()-1, MAXCOL() )
nLinha  := MaxRow() - 3

LIMPA( 4, 1, MAXROW()-3, MAXCOL()-1 )

nSele1 := Select()
nOrde1 := IndexOrd()
nRegi1 := RecNo()

SELE FUNCOES
SEEK STR(nKey, 5, 0 ) + cProg + cVar
IF !FOUND() .AND. INCLUI
   IF ATENCAO( 'CADASTRA?',{'SIM','NAO'} ) == 1
      APPEND BLANK
      FUNCOES->PROG_VARI := STR(nKey, 5, 0 ) + cProg + cVar
      lRet := TRUE
   END

ELSEIF FOUND()
   lRet := TRUE

END

IF     nKey == K_F2
       SELE CLIENTES
       lPesq := TRUE

ELSEIF nKey == K_F3
       SELE FUNCIONA
       lPesq := TRUE

ELSEIF nKey == K_F4
       SELE PRODES
       lPesq := TRUE

ELSEIF nKey == K_F5
       SELE BANCOS

ELSEIF nKey == K_F6
       SELE TABELA
       
ELSEIF nKey == K_F7
       SELE FORNEC
       lPesq := TRUE

ELSEIF nKey == K_F8
       SELE CHEQUES
       lPesq := TRUE

ELSEIF nKey == K_F10
       SELE GRUPOS
       
ELSE
       SELE CLIENTES
       lFisica := TRUE
       lPesq := TRUE

END

nOrde2 := IndexOrd()
nRegi2 := RecNo()
SET ORDER TO 1
cArq := Alias()

oMyBrowser := TBrowseDB ( 5, 1, nLinha, MAXCOL()-1 )

oMyBrowser:colorSpec := 'W+/N, N/W, N/W, N/W'

oMyBrowser:headSep := 'ÄÂÄ'          // Separador de Cabecalho
oMyBrowser:colsep  := ' ³ '          // Separador de Colunas

IF     cArq == 'CLIENTES'
       FMens( 'P=Pesquisa.' )
       @ 4, 1 SAY PadC( 'Rela‡ao de Clientes', 78 ) COLOR 'N/W'
       oColumn2 := TBColumnNew ( 'Nome', { || CLIENTES->NOME } )
       oColumn2:picture := '@!'

       oColumn3 := TBColumnNew ( 'C.P.F.', { || MASCARA(CLIENTES->CGCCPF) } )
       oColumn3:picture := '@!'
          
       SET ORDER TO 2
       oColumn1 := TBColumnNew ( 'C¢digo' , { || CLIENTES->CODIGO } )
       oColumn1:picture := '@!'

ELSEIF cArq == 'FUNCIONA'
       SET ORDER TO 2
       FMens( 'P=Pesquisa.' )
       @ 4, 1 SAY PadC( 'Rela‡ao de Funcionarios', 78 ) COLOR 'N/W'
       oColumn1 := TBColumnNew ( 'C¢d' , { || FUNCIONA->CODIGO } )
       oColumn1:picture := '@!' 
       oColumn2 := TBColumnNew ( 'Nome', { || FUNCIONA->NOME } )
       oColumn2:picture := '@!'
       oColumn3 := TBColumnNew ( 'Apelido', { || FUNCIONA->APELIDO } )
       oColumn3:picture := '@!'

ELSEIF cArq == 'FORNEC'
       SET ORDER TO 2
       FMens( 'P=Pesquisa.' )
       @ 4, 1 SAY PadC( 'Rela‡ao de Fornecedores', 78 ) COLOR 'N/W'
       oColumn1 := TBColumnNew ( 'C¢digo' , { || FORNEC->CODIGO } )
       oColumn1:picture := '@!'
       oColumn2 := TBColumnNew ( 'Nome', { || FORNEC->NOME } )
       oColumn2:picture := '@!'

ELSEIF cArq == 'CHEQUES'
       FMens( '' )
       @ 4, 1 SAY PadC( 'Rela‡ao de Cheques', 78 ) COLOR 'N/W'
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
       @ 4, 1 SAY PadC( 'Rela‡ao de Bancos', 78 ) COLOR 'N/W'
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

ELSEIF cArq == 'TABELA'
       @ 4, 1 SAY PadC( 'TABELA', 78 ) COLOR 'N/W'
       oColumn1 := TBColumnNew ( 'Tabela' , { || Desc( TABELA->TIPO ) } )
       oColumn2 := TBColumnNew ( 'C¢digo' , { || TABELA->CODIGO } )
       oColumn2:picture := '@!' 
       oColumn3 := TBColumnNew ( 'Nome', { || TABELA->NOME } )
       oColumn3:picture := '@!'

ELSEIF cArq == 'PRODES'
       @ 4, 1 SAY PadC( 'Rela‡ao de Proventos e Descontos', 78 ) COLOR 'N/W'
       oColumn1 := TBColumnNew ( 'C¢d' , { || PRODES->CODIGO } )
       oColumn1:picture := '@!' 
       oColumn2 := TBColumnNew ( 'Descricao', { || PRODES->DESCRICAO } )
       oColumn2:picture := '@!'
       oColumn3 := TBColumnNew ( 'Tipo', { || FTIPO(PRODES->TIPO) } )
       oColumn3:picture := '@!'

ELSEIF cArq == 'GRUPOS'
       @ 4, 1 SAY PadC( 'Rela‡ao de Grupos', 78 ) COLOR 'N/W'
       oColumn1 := TBColumnNew ( 'C¢digo' , { || GRUPOS->CODIGO } )
       oColumn1:picture := '@!'
       oColumn2 := TBColumnNew ( 'Nome', { || GRUPOS->NOME } )
       oColumn2:picture := '@!'

END

IF bFiltro == Nil
   GO TOP

ELSE
   Skipper(0)
   GoTop( bFiltro )

END

// Adiciona colunas ao TBrowser
oMyBrowser:addColumn ( oColumn1 )
oMyBrowser:addColumn ( oColumn2 )
oMyBrowser:addColumn ( oColumn3 )
IF cArq == 'LANCTOS' .OR. cArq == 'CLIENTES'
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
      IF cArq == 'TABELA'
         IF     TABELA->TIPO == '1'
                oMyBrowser:colorRect( { oMyBrowser:rowPos, 1,; 
                           oMyBrowser:rowPos, oMyBrowser:colCount }, { 1, 2 } )

         ELSEIF TABELA->TIPO == '2'
                oMyBrowser:colorRect( { oMyBrowser:rowPos, 1,; 
                           oMyBrowser:rowPos, oMyBrowser:colCount }, { 2, 3 } )

         ELSE
                oMyBrowser:colorRect( { oMyBrowser:rowPos, 1,; 
                           oMyBrowser:rowPos, oMyBrowser:colCount }, { 3, 1 } )

         END
      END
   END

   oMyBrowser:colorRect( { oMyBrowser:rowPos, 1, oMyBrowser:rowPos,; 
                           oMyBrowser:colCount }, { 3, 4 } )

   IF oMyBrowser:stable ()

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
                 IF cArq != 'TABELA'
                    KeyBoard( Repl( Chr( K_BS ), 10 ) + Eval( oColumn1:block ) )
                 ELSE
                    KeyBoard( Repl( Chr( K_BS ), 10 ) + Eval( oColumn2:block ) )
                 END
                 EXIT
                 
          ELSEIF UPPER( CHR( nKey ) ) == 'P' .AND. lPesq
                 cMensT := SAVESCREEN( MAXROW()-1, 0, MAXROW(), MAXCOL() )
                 @ MAXROW()-1, 1 SAY SPACE( MAXCOL()-10 ) COLOR SETCORES(1)
                 @ MAXROW()-1, 1 SAY 'Nome: '        COLOR SETCORES(1)
                 nL := 23
                 nC := Col()
                 nQ := 30
                 aSenha := {}
                 FOR nII := 1 TO nQ
                     AADD( aSenha, ' ' )
                 NEXT
                 nP := 1
                 nC--
                 nCodi := 0
                 WHILE .T.
                    @ nL,nC+nP SAY '_ ' COLOR SETCORES(1)
                    WHILE ( !oMyBrowser:stabilize () ) 
                       IF ( nCodi := INKEY() ) != 0 ; EXIT ; END
                    END
                    IF oMyBrowser:stable ()
                       nCodi := InKey(0)
                    END
            
                    IF     nCodi == 0
                           LOOP

                    ELSEIF nCodi == K_BS .AND. nP > 1
                       nP--
                       aSenha[ nP ] := ' '
                       @ nL, nC+nP SAY '_ ' COLOR SETCORES(1)
                       cPesq := ''
                       FOR nII := 1 TO nP-1
                          cPesq += aSenha[ nII ]
                       NEXT
                       SEEK cPesq
                       oMyBrowser:refreshAll()
                       LOOP

                    ELSEIF nCodi == K_BS .AND. nP == 1
                       LOOP

                    ELSEIF nCodi == K_ENTER .OR. nCodi == K_ESC
                       EXIT

                    ELSEIF nCodi >= 32 .AND. nCodi < 127
                       aSenha[ nP ] := Upper(CHR( nCodi ))
                       @ nL, nC+nP SAY aSenha[ nP ] + '_ ' COLOR SETCORES(1)
                       cPesq := ''
                       FOR nII := 1 TO nP
                          cPesq += aSenha[ nII ]
                       NEXT
                       SEEK AllTrim( cPesq )
                       oMyBrowser:refreshAll()
                       nP++
                       IF nP > nQ ; EXIT ; END
                       
                    END
                 END
                 SETCURSOR( SC_NONE )
                 RESTSCREEN( MAXROW()-1, 0, MAXROW(), MAXCOL(), cMensT )
                 oMyBrowser:refreshAll()

          END
   END

   oMyBrowser:refreshCurrent()
   
END

SET RELATION TO
SET ORDER TO nOrde2
GO nRegi2

SELECT( nSele1 )
SET ORDER TO nOrde1
GO nRegi1

SETCOLOR( cCor )
SETCURSOR( nCursor )
RestScreen ( 3, 0, MAXROW()-2, MAXCOL(), cTela )
RESTSCREEN( MAXROW()-1, 0, MAXROW()-1, MAXCOL(), cMens )
RETURN

***********************
PROCEDURE ACAO( cMens )
***********************
LOCAL nSele
nSele := Select()
SELE AUDIT
NetAppBlank(0)
AUDIT->MAKE := CRIPTO(DTOS(Date()) + Time() + PADR(M->cUsuario,15) + PADR(cMens,50))
UNLOCK
COMMIT
SELECT( nSele )
RETURN

STATIC FUNCTION DESC( X )
LOCAL R := '      '
IF     X == '1' ; R := 'Marca '
ELSEIF X == '2' ; R := 'Modelo'
ELSEIF X == '3' ; R := 'Cor   '
END
RETURN R

/****

  FIM MENUPRIN.PRG

****/  
