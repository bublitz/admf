#INCLUDE "MEU.CH"

SETCOLOR( "W+/B" )
CLS

   MemoWrit( '$INDEX.$$$','$INDEX.$$$' )

   cTela := SaveScreen( 4, 1, 22, 78 )
   DispBox( 6, 9, 20, 70, BORDA )
   @ 24, 0 SAY 'AGUARDE... Reorganizando arquivos...' COLOR "GR+*/B"

   @  8, 13  SAY "Contratos         Centro de Custo     Caixa"
   @ 10, 13  SAY "Usuarios          Grupos              Contas a Pagar"
   @ 12, 13  SAY "Clientes          Bancos              Contas a Receber"
   @ 14, 13  SAY "Fornecedores      Saldos              Help"
   @ 16, 13  SAY "Dependentes       Lan‡amentos         Fun‡oes"
   @ 18, 13  SAY "Vendedores        Cheques             Impressoras"
   
   @  8, 11 SAY "  Contratos " COLOR "W+/N"
   @  8, 11 SAY Chr( 7 )       COLOR "W+*/N"
   USE CONTRATO EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON NUMERO TO CONTRAT1
      INDEX ON CLIENTE TO CONTRAT2
      dbCloseArea()
   END
   @  8, 11 SAY "û Contratos "
   
   @ 10, 11 SAY "  Usuarios "  COLOR "W+/N"
   @ 10, 11 SAY Chr( 7 )       COLOR "W+*/N"
   USE USUARIOS EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON CONTRATO+CLIENTE TO USUARIO1
      INDEX ON CLIENTE+CONTRATO TO USUARIO2
      dbCloseArea()
   END
   @ 10, 11 SAY "û Usuarios "
   
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
   
   @ 14, 11 SAY "  Fornecedores "  COLOR "W+/N"
   @ 14, 11 SAY Chr( 7 )       COLOR "W+*/N"
   USE FORNEC EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON CODIGO TO FORNEC1
      INDEX ON NOME   TO FORNEC2
      dbCloseArea()
   END
   @ 14, 11 SAY "û Fornecedores "

   @ 16, 11 SAY "  Dependentes "  COLOR "W+/N"
   @ 16, 11 SAY Chr( 7 )       COLOR "W+*/N"
   USE DEPENDEN EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON CODIGO+ORDEM TO DEPENDEN
      dbCloseArea()
   END
   @ 16, 11 SAY "û Dependentes "
   
   @ 18, 11 SAY "  Vendedores "  COLOR "W+/N"
   @ 18, 11 SAY Chr( 7 )       COLOR "W+*/N"
   USE VENDEDOR EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON CODIGO TO VEND1   
      INDEX ON NOME   TO VEND2
      dbCloseArea()
   END
   @ 18, 11 SAY "û Vendedores "

   @  8, 29 SAY "  Centro de Custo " COLOR "W+/N"
   @  8, 29 SAY Chr( 7 )       COLOR "W+*/N"
   USE CCUSTO EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON CODIGO TO CCUSTO
      dbCloseArea()
   END
   @  8, 29 SAY "û Centro de Custo "

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
   @  8, 49 SAY "û Caixa "

   @ 10, 49 SAY "  Contas a Pagar " COLOR "W+/N"
   @ 10, 49 SAY Chr( 7 )       COLOR "W+*/N"
   USE PAGAR EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON NUMERO               TO PAGAR1
      INDEX ON DTOS(VENCTO)+CODCEN+CODGRU+CODFOR TO PAGAR2
      INDEX ON DTOS(DTPAGTO)+CODCEN+CODGRU+CODFOR TO PAGAR3
      dbCloseArea()
   END

   USE PARPAGAR EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON NUMERO+PARCELA TO PARPAGAR
      dbCloseArea()
   END
   @ 10, 49 SAY "û Contas a Pagar "

   @ 12, 49 SAY "  Contas a Receber " COLOR "W+/N"
   @ 12, 49 SAY Chr( 7 )       COLOR "W+*/N"
   USE RECEB EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON NUMERO               TO RECEB1
      INDEX ON CODCEN+CODGRU+CODCLI TO RECEB2
      dbCloseArea()
   END

   USE PARRECEB EXCLUSIVE NEW
   IF !NetErr()
      PACK
      INDEX ON NUMERO+PARCELA TO PARRECEB
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
   INKEY(1)
   @ 18, 49 SAY "û Impressoras "
   FErase( '$INDEX.$$$' )
   RestScreen( 4, 1, 22, 78, cTela )

SETCOLOR("W/N")
CLS
COMMIT
