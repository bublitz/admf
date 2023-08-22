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
PROCEDURE EMPRESAS()
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
      cRefB1, cRefB2, cRefB3, cRefC1, cRefC2, cRefC3, mObs

cTela   := SaveScreen ( 0, 0, MaxRow(), MaxCol() )
nCursor := SetCursor( SC_NORMAL )
cCor    := SetColor( SETCORES(2) )

LIMPA( 4, 1, MaxRow()-3, MaxCol()-1 )

TELAEMP()

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
            WHEN FMENS( 'Digite o C¢digo do Cliente. F3=Clientes.' )

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
      IF Len( AllTrim( CLIENTES->CGCCPF ) ) < 14
         ATENCAO( 'Este Cliente ‚ Pessoa F¡sica!',{'Volta'} )
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
   mObs        := CLIENTES->OBSERVACAO
   
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

      @ 15, 17  SAY  cEndereco2 PICT "@!"
      @ 16, 27  SAY  cRefB1     PICT "@!"
      @ 17, 27  SAY  cRefB2     PICT "@!"
      @ 18, 27  SAY  cRefB3     PICT "@!"
      @ 19, 27  SAY  cRefC1     PICT "@!"
      @ 20, 27  SAY  cRefC2     PICT "@!"
      @ 21, 27  SAY  cRefC3     PICT "@!"

      FMENS( 'Tecle Enter.' )
      Inkey(0)

      FMENS('')

      nEscolha := ATENCAO( 'Deseja fazer:; ',;
                           {'Alteracao','Exclusao','Volta' },;
                           SETCORES(1) )

      IF nEscolha == 2
         IF '3'$M->cRight
            IF ATENCAO( 'Confirma Exclusao?; ',{'Nao','Sim'}, SETCORES(2) ) == 2
//               CLIENTES->(dbDelete())
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
               ACAO( 'EXCLUIU EMPRESA CODIGO ' + cCodigo )
            END
         ELSE
            ACAO( 'TENTOU EXCLUIR CLIENTE CODIGO ' + cCodigo )
            ATENCAO( 'Acesso nao Permitido!' )
         END
      END

      IF !nEscolha == 1 ; LOOP ; END

   END

   FMENS('')

   @  5, 31  GET cNome        PICT "@!" VALID !Empty( cNome )
   @  8, 16  GET cEndereco1   PICT "@!"
   @  8, 66  GET cNumero1     PICT "@!"
   @  9, 11  GET cBairro1     PICT "@!"
   @ 10, 11  GET cCidade1     PICT "@!"
   @ 10, 52  GET cUF1         PICT "@!"
   @ 10, 61  GET cCep1        PICT "@R 99.999-999"
   @ 11, 13  GET cFone1       PICT "@R (999X)X999-9999"
   @ 13, 12  SAY SPACE(19)    COLOR SETCORES(2)
   @ 13, 12  GET cCGCCPF      PICT "@R 99.999.999/9999-99" ;
             VALID Len( AllTrim( cCGCCPF ) ) > 11 .AND. CGCCPF( cCGCCPF )

   @ 13, 56  GET cIERG        PICT "@!"

   @ 15, 17  GET  cEndereco2 PICT "@!"
   @ 16, 27  GET  cRefB1 PICT "@!"
   @ 17, 27  GET  cRefB2 PICT "@!"
   @ 18, 27  GET  cRefB3 PICT "@!"
   @ 19, 27  GET  cRefC1 PICT "@!"
   @ 20, 27  GET  cRefC2 PICT "@!"
   @ 21, 27  GET  cRefC3 PICT "@!"

   READ
      
   mObs := OBS( mObs, @lUpdated )
   
   CLIENTES->(dbGoto( nII ))

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
         CLIENTES->CGCCPF      :=  StrZero( Val( cCGCCPF ), 14, 0 )
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
         CLIENTES->OBSERVACAO  :=  mObs

         IF lInclui
            ACAO ( 'CADASTROU CLIENTE CODIGO ' + cCodigo )
         ELSE
            ACAO ( 'ALTEROU CLIENTE CODIGO ' + cCodigo )
         END

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

*****************************
FUNCTION OBS( MEMO, ALTEROU )
*****************************
LOCAL ANT := MEMO
ABRE( 5, 10, 20, 70, TRUE )
FMENS( 'Digite as informa‡oes adicionais. [Ctrl W]=Grava' )
MEMO := MemoEdit( MEMO, 6, 11, 19, 69, TRUE )
IF ANT == MEMO
   ALTEROU := FALSE
ELSE
   ALTEROU := TRUE
END

RETURN MEMO
