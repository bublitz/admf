/***************

   PROGRAMA: CADCLI.prg

   FUN€AO:   CADASTRO DE CLIENTES

   AUTOR:    Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'InKey.ch'
#include 'SetCurs.ch'
#include "Combo.ch"

********************
PROCEDURE CLIENTES()
********************
LOCAL cTela, cTelaLimpa, cTelaRefer, cCor,;
      nII, nCursor, GetList := {}, lUpdated, ;
      lInclui, lAchou, nCodigo, cCodigo, nEscolha,;
      cNome, cCGCCPF, cIERG, ;
      cEndereco1,;
      cNumero1,;
      cBairro1,;
      cCidade1,;
      cUF1,;
      cCep1,;
      cFone1,;
      cEndereco2,;
      cNumero2,;
      cBairro2,;
      cCidade2,;
      cUF2,;
      cCep2,;
      cFone2,;
      cSexo,;
      dNascimento,;
      cEscolarida,;
      cEstadoCivi,;
      cRefB1, cRefB2, cRefB3, cRefC1, cRefC2, cRefC3

cTela   := SaveScreen ( 0, 0, MaxRow(), MaxCol() )
nCursor := SetCursor( SC_NORMAL )
cCor    := SetColor( SETCORES(2) )

LIMPA( 4, 1, MaxRow()-3, MaxCol()-1 )

TELACLI()

FMENS('')

SetColor( SETCORES(1) )

cTelaLimpa := SaveScreen ( 0, 0, MaxRow(), MaxCol() )

WHILE .T.

   UNLOCK
   COMMIT
   
   RestScreen ( 0, 0, MaxRow(), MaxCol(), cTelaLimpa )

   SetCursor ( SC_NORMAL )

   nCodigo := 0
   @  5, 11 GET nCodigo PICT '99999999' ;
            WHEN FMENS( 'Digite o C¢digo do Cliente. F2=Clientes.' )

   READ

   IF LastKey() == K_ESC ; EXIT ; END

   SELE CLIENTES

   IF nCodigo == 0
      lInclui := TRUE
      GO BOTTOM
      nCodigo := Val( CLIENTES->CODIGO ) + 1

   ELSE
      lInclui := FALSE

   END

   cCodigo := STRZERO( nCodigo, 8, 0 )

   FMENS('')
   
   @ 5, 11 SAY cCodigo COLOR SETCORES(3)

   SEEK cCodigo

   lAchou := Found()

   IF !lAchou .AND. !lInclui
      IF ATENCAO( 'Codigo Nao Cadastrado!;Deseja Incluir ?',;
                  { 'Sim','Nao' } ) == 2
         LOOP
      ELSE
         lInclui := TRUE
      END
   END

   IF lAchou
      IF Len( AllTrim( CLIENTES->CGCCPF ) ) > 11
         ATENCAO( 'Este Cliente ‚ Pessoa Jur¡dica!',{'Volta'} )
         LOOP
      END
   END
   
   IF lInclui
      IF !NetAppBlank()
         LOOP
      END
      CLIENTES->CODIGO := cCodigo
      COMMIT
   ELSE
      IF !NetRLock()
         LOOP
      END
   END

   nII := RecNo()
   
   cNome       := CLIENTES->NOME
   cEndereco1  := CLIENTES->ENDERECO1
   cNumero1    := CLIENTES->NUMERO1
   cBairro1    := CLIENTES->BAIRRO1
   cCidade1    := CLIENTES->CIDADE1
   cUF1        := CLIENTES->UF1
   cCep1       := CLIENTES->CEP1
   cFone1      := CLIENTES->FONE1
   cCGCCPF     := SubStr( CLIENTES->CGCCPF, 1, 11 )
   cIERG       := CLIENTES->IERG
   cEndereco2  := CLIENTES->ENDERECO2
   cNumero2    := CLIENTES->NUMERO2
   cBairro2    := CLIENTES->BAIRRO2
   cCidade2    := CLIENTES->CIDADE2
   cUF2        := CLIENTES->UF2
   cCep2       := CLIENTES->CEP2
   cFone2      := CLIENTES->FONE2
   cSexo       := CLIENTES->SEXO
   dNascimento := CLIENTES->NASCIMENTO
   cEscolarida := CLIENTES->ESCOLARIDA
   cEstadoCivi := CLIENTES->ESTADOCIVI
   cRefB1      := CLIENTES->REFBANCO1
   cRefB2      := CLIENTES->REFBANCO2
   cRefB3      := CLIENTES->REFBANCO3
   cRefC1      := CLIENTES->REFEMPRE1
   cRefC2      := CLIENTES->REFEMPRE2
   cRefC3      := CLIENTES->REFEMPRE3

   IF !lInclui
      @  5, 31  SAY cNome
      @  8, 16  SAY cEndereco1
      @  8, 66  SAY cNumero1
      @  9, 11  SAY cBairro1
      @ 10, 11  SAY cCidade1
      @ 10, 52  SAY cUF1
      @ 10, 61  SAY cCep1        PICT "@R 99.999-999"
      @ 11, 13  SAY cFone1       PICT "@R (999X)X999-9999"

      @ 13, 12  SAY MASCARA( cCGCCPF )
      @ 13, 56  SAY cIERG

      @ 15, 16  SAY cEndereco2
      @ 15, 65  SAY cNumero2
      @ 16, 11  SAY cBairro2
      @ 17, 11  SAY cCidade2
      @ 17, 52  SAY cUF2
      @ 17, 61  SAY cCep2        PICT "@R 99.999-999"
      @ 18, 13  SAY cFone2       PICT "@R (999X)X999-9999"

      @ 20,  9  SAY cSexo
      @ 20, 25  SAY dNascimento
      @ 20, 51  SAY cEscolarida
      @ 20, 69  SAY cEstadoCivi

      FMENS( 'Tecle Enter.' )
      Inkey(0)

      cTelaRefer := ABRE( 7, 7, 18, 60, TRUE )
      LIMPA( 8, 8, 17, 59 )
      @  8,  8  TO 12, 59
      @ 13,  8  TO 17, 59
      @  8,  9  SAY "Referˆncias Banc rias:"
      @ 13,  9  SAY "Referˆncias Comerciais:"
      @  9,  9  SAY  cRefB1
      @ 10,  9  SAY  cRefB2
      @ 11,  9  SAY  cRefB3
      @ 14,  9  SAY  cRefC1
      @ 15,  9  SAY  cRefC2
      @ 16,  9  SAY  cRefC3
      FMENS( 'Tecle Enter.' )
      Inkey(0)
      FECHA( 7, 7, 18, 60, cTelaRefer, TRUE )
      FMENS('')

      nEscolha := ATENCAO( 'Deseja fazer:; ',;
                           {'Alteracao','Exclusao','Volta' },;
                           SETCORES(1) )

      IF nEscolha == 2
         IF '3'$M->cRight
            IF ATENCAO( 'Confirma Exclusao?; ',{'Nao','Sim'}, SETCORES(2) ) == 2
               // CLIENTES->(dbDelete())
               CLIENTES->(dbGoBottom())
               CLIENTES->(dbSkip())
               cNome       := "* * * E X C L U I D O * * *"
               cEndereco1  := CLIENTES->ENDERECO1
               cNumero1    := CLIENTES->NUMERO1
               cBairro1    := CLIENTES->BAIRRO1
               cCidade1    := CLIENTES->CIDADE1
               cUF1        := CLIENTES->UF1
               cCep1       := CLIENTES->CEP1
               cFone1      := CLIENTES->FONE1
               cCGCCPF     := CLIENTES->CGCCPF
               cIERG       := CLIENTES->IERG
               cEndereco2  := CLIENTES->ENDERECO2
               cNumero2    := CLIENTES->NUMERO2
               cBairro2    := CLIENTES->BAIRRO2
               cCidade2    := CLIENTES->CIDADE2
               cUF2        := CLIENTES->UF2
               cCep2       := CLIENTES->CEP2
               cFone2      := CLIENTES->FONE2
               cSexo       := CLIENTES->SEXO
               dNascimento := CLIENTES->NASCIMENTO
               cEscolarida := CLIENTES->ESCOLARIDA
               cEstadoCivi := CLIENTES->ESTADOCIVI
               cRefB1      := CLIENTES->REFBANCO1
               cRefB2      := CLIENTES->REFBANCO2
               cRefB3      := CLIENTES->REFBANCO3       
               cRefC1      := CLIENTES->REFEMPRE1
               cRefC2      := CLIENTES->REFEMPRE2
               cRefC3      := CLIENTES->REFEMPRE3
               CLIENTES->(dbGoTo( nII ))            
               CLIENTES->NOME        :=  cNome
               CLIENTES->ENDERECO1   :=  cEndereco1
               CLIENTES->NUMERO1     :=  cNumero1
               CLIENTES->BAIRRO1     :=  cBairro1
               CLIENTES->CIDADE1     :=  cCidade1
               CLIENTES->UF1         :=  cUF1
               CLIENTES->CEP1        :=  cCep1
               CLIENTES->FONE1       :=  cFone1
               CLIENTES->CGCCPF      :=  cCGCCPF
               CLIENTES->IERG        :=  cIERG
               CLIENTES->ENDERECO2   :=  cEndereco2
               CLIENTES->NUMERO2     :=  cNumero2
               CLIENTES->BAIRRO2     :=  cBairro2
               CLIENTES->CIDADE2     :=  cCidade2
               CLIENTES->UF2         :=  cUF2
               CLIENTES->CEP2        :=  cCep2
               CLIENTES->FONE2       :=  cFone2
               CLIENTES->SEXO        :=  cSexo
               CLIENTES->NASCIMENTO  :=  dNascimento
               CLIENTES->ESCOLARIDA  :=  cEscolarida
               CLIENTES->ESTADOCIVI  :=  cEstadoCivi
               CLIENTES->REFBANCO1   :=  cRefB1
               CLIENTES->REFBANCO2   :=  cRefB2
               CLIENTES->REFBANCO3   :=  cRefB3
               CLIENTES->REFEMPRE1   :=  cRefC1
               CLIENTES->REFEMPRE2   :=  cRefC2
               CLIENTES->REFEMPRE3   :=  cRefC3

               SELE CLIENTES
               ACAO( 'EXCLUIU CLIENTE CODIGO ' + cCodigo )
            END
         ELSE
            ACAO( 'TENTOU EXCLUIR CLIENTE CODIGO ' + cCodigo )
            ATENCAO( 'Acesso nao Permitido!' )
         END
      END

      IF !nEscolha == 1 ; LOOP ; END

   END

   FMENS('')

   WHILE .T.
      @  5, 31  GET cNome        PICT "@!" VALID cNome >="A"
      @  8, 16  GET cEndereco1   PICT "@!"
      @  8, 66  GET cNumero1     PICT "@!"
      @  9, 11  GET cBairro1     PICT "@!"
      @ 10, 11  GET cCidade1     PICT "@!"
      @ 10, 52  GET cUF1         PICT "@!"
      @ 10, 61  GET cCep1        PICT "@R 99.999-999"
      @ 11, 13  GET cFone1       PICT "@R (999X)X999-9999" VALID !EMPTY( cFone1 )

      @ 13, 12  SAY SPACE(19)    COLOR SETCORES(2)
      @ 13, 12  GET cCGCCPF      PICT "@R 999.999.999-99" ;
                                 VALID CGCCPF( cCGCCPF )

      @ 13, 56  GET cIERG        PICT "@!"

      @ 15, 16  GET cEndereco2   PICT "@!"
      @ 15, 65  GET cNumero2     PICT "@!"
      @ 16, 11  GET cBairro2     PICT "@!"
      @ 17, 11  GET cCidade2     PICT "@!"
      @ 17, 52  GET cUF2         PICT "@!"
      @ 17, 61  GET cCep2        PICT "@R 99.999-999"
      @ 18, 13  GET cFone2       PICT "@R (999X)X999-9999" WHEN FMens('')

      @ 20,  9  GET cSexo       ;
                COMBO { "1=Masculino","2=Feminino" } ;
                VALID cSexo$"12"

      @ 20, 25  GET dNascimento  PICT "@!"
      @ 20, 51  GET cEscolarida  ;
                COMBO {'1=Superior Completo','2=Superior Incompleto',;
                       '3=2§ Grau Completo','4=2§ Grau Incompleto',;
                       '5=1§ Grau Completo','6=1§ Grau Incompleto',;
                       '7=Semi-Analfabeto','8=Analfabeto'} ;
                VALID cESCOLARIDA$"12345678"
                
      @ 20, 69  GET cEstadoCivi  ;
                COMBO {'1=Solteiro','2=Casado','3=Divorciado','4=Desquitado',;
                       '5=Vi£vo','9=Outros' } ;
                VALID cEstadoCivi$"123459"

      READ

      IF LastKey() == K_ESC ; EXIT ; END
      
      lUpdated := Updated()
      
      ReadExit( TRUE )
      
      cTelaRefer := ABRE( 7, 7, 18, 60, TRUE )
      LIMPA( 8, 8, 17, 59 )
      @  8,  8  TO 12, 59
      @ 13,  8  TO 17, 59
      @  8,  9  SAY "Referˆncias Banc rias:"
      @ 13,  9  SAY "Referˆncias Comerciais:"
      @  9,  9  GET  cRefB1 PICT "@!"
      @ 10,  9  GET  cRefB2 PICT "@!"
      @ 11,  9  GET  cRefB3 PICT "@!"
      @ 14,  9  GET  cRefC1 PICT "@!"
      @ 15,  9  GET  cRefC2 PICT "@!"
      @ 16,  9  GET  cRefC3 PICT "@!"

      READ
      
      FECHA( 7, 7, 18, 60, cTelaRefer, TRUE )

      ReadExit( FALSE )

      IF LastKey() == K_UP .OR. LastKey() == K_PGUP
         LOOP
      END
      
      EXIT
      
   END

   CLIENTES->(dbGoto( nII ))

   IF Lastkey() == K_ESC 
      IF lInclui ; CLIENTES->(dbDelete()) ; END
      LOOP 
   END

   IF Updated() .OR. lUpdated
      IF ATENCAO( 'Confirma '+IF(lInclui,'INCLUSAO ?','ALTERA€AO ?'), {'Sim','Nao'}, SETCORES(2) ) == 1

         FMENS( 'AGUARDE... Atualizando arquivo...' )
         
         CLIENTES->CODIGO      :=  cCodigo
         CLIENTES->NOME        :=  cNome
         CLIENTES->ENDERECO1   :=  cEndereco1
         CLIENTES->NUMERO1     :=  cNumero1
         CLIENTES->BAIRRO1     :=  cBairro1
         CLIENTES->CIDADE1     :=  cCidade1
         CLIENTES->UF1         :=  cUF1
         CLIENTES->CEP1        :=  cCep1
         CLIENTES->FONE1       :=  cFone1
         CLIENTES->CGCCPF      :=  cCGCCPF
         CLIENTES->IERG        :=  cIERG
         CLIENTES->ENDERECO2   :=  cEndereco2
         CLIENTES->NUMERO2     :=  cNumero2
         CLIENTES->BAIRRO2     :=  cBairro2
         CLIENTES->CIDADE2     :=  cCidade2
         CLIENTES->UF2         :=  cUF2
         CLIENTES->CEP2        :=  cCep2
         CLIENTES->FONE2       :=  cFone2
         CLIENTES->SEXO        :=  cSexo
         CLIENTES->NASCIMENTO  :=  dNascimento
         CLIENTES->ESCOLARIDA  :=  cEscolarida
         CLIENTES->ESTADOCIVI  :=  cEstadoCivi
         CLIENTES->REFBANCO1   :=  cRefB1
         CLIENTES->REFBANCO2   :=  cRefB2
         CLIENTES->REFBANCO3   :=  cRefB3
         CLIENTES->REFEMPRE1   :=  cRefC1
         CLIENTES->REFEMPRE2   :=  cRefC2
         CLIENTES->REFEMPRE3   :=  cRefC3

         IF lInclui
            ACAO ( 'CADASTROU CLIENTE CODIGO ' + cCodigo )
         ELSE
            ACAO ( 'ALTEROU CLIENTE CODIGO ' + cCodigo )
         END

         FMens('')

      ELSE
         IF lInclui ; CLIENTES->(dbDelete()) ; END

      END
   ELSE
      IF lInclui ; CLIENTES->(dbDelete()) ; END

   END
   
   UNLOCK
      
END

RestScreen ( 0, 0, MaxRow(), MaxCol(), cTela )
SetColor( cCor )
SetCursor( nCursor )
RETURN

**************************
FUNCTION MASCARA( CgcCpf )
**************************
LOCAL cRet
IF LEN ( ALLTRIM( CgcCpf ) ) == 11
   cRet := TRANSF( CgcCpf, "@R 999.999.999-99" )
ELSE
   cRet := TRANSF( CgcCpf, "@R 99.999.999/9999-99" )
END
RETURN cRet
