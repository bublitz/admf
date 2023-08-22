/***************

   PROGRAMA: CADFOR.prg

   FUN€AO:   CADASTRO DE FORNECEDORES

   AUTOR:    Jorge Luis Bublitz

***************/

#include 'MEU.ch'
#include 'InKey.ch'
#include 'SetCurs.ch'

********************
PROCEDURE FORNEC()
********************
LOCAL cTela, cTelaLimpa,cCor,;
      nII, nCursor, GetList := {},;
      lInclui, lAchou, nCodigo, cCodigo, nEscolha,;
      cNome, cCGCCPF, cIERG, ;
      cEndereco,;
      cNumero,;
      cBairro,;
      cCidade,;
      cUF,;
      cCep,;
      cFone

cTela   := SaveScreen ( 0, 0, MaxRow(), MaxCol() )
nCursor := SetCursor( SC_NORMAL )
cCor    := SetColor( SETCORES(2) )

LIMPA( 4, 1, MaxRow()-3, MaxCol()-1 )

TELAFOR()

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
            WHEN FMENS( 'Digite o C¢digo do Fornecedor. F7=Fornecedores.' )

   READ

   IF LastKey() == K_ESC ; EXIT ; END

   SELE FORNEC

   IF nCodigo == 0
      lInclui := TRUE
      GO BOTTOM
      nCodigo := Val( FORNEC->CODIGO ) + 1

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

   IF lInclui
      IF !NetAppBlank()
         LOOP
      END
      FORNEC->CODIGO := cCodigo
      COMMIT
   ELSE
      IF !NetRLock()
         LOOP
      END
   END

   nII := RecNo()
   
   cNome       := FORNEC->NOME
   cEndereco   := FORNEC->ENDERECO 
   cNumero     := FORNEC->NUMERO 
   cBairro     := FORNEC->BAIRRO 
   cCidade     := FORNEC->CIDADE 
   cUF         := FORNEC->UF 
   cCep        := FORNEC->CEP 
   cFone       := FORNEC->FONE 
   cCGCCPF     := FORNEC->CGCCPF
   cIERG       := FORNEC->IERG

   IF !lInclui
      @  5, 31  SAY cNome
      @  8, 16  SAY cEndereco 
      @  8, 66  SAY cNumero 
      @  9, 11  SAY cBairro 
      @ 10, 11  SAY cCidade 
      @ 10, 52  SAY cUF 
      @ 10, 61  SAY cCep         PICT "@R 99.999-999"
      @ 11, 13  SAY cFone        PICT "@R (999X)X999-9999"

      @ 13, 12  SAY MASCARA( cCGCCPF )
      @ 13, 56  SAY cIERG

      FMENS( 'Tecle Enter.' )
      Inkey(0)
      FMENS('')

      nEscolha := ATENCAO( 'Deseja fazer:; ',;
                           {'Alteracao','Exclusao','Volta' },;
                           SETCORES(1) )

      IF nEscolha == 2
         IF 'E'$M->cRight
            IF ATENCAO( 'Confirma Exclusao?; ',{'Nao','Sim'}, SETCORES(2) ) == 2
               FORNEC->(dbDelete())
               ACAO( 'EXCLUIU FORNECEDOR CODIGO ' + cCodigo )
            END
         ELSE
            ATENCAO( 'Acesso nao Permitido!' )
            ACAO( 'TENTOU EXCLUIR FORNECEDOR CODIGO ' + cCodigo )
         END
      END

      IF !nEscolha == 1 ; LOOP ; END

   END

   FMENS('')

   @  5, 31  GET cNome        PICT "@!" VALID cNome >="A"
   @  8, 16  GET cEndereco    PICT "@!"
   @  8, 66  GET cNumero      PICT "@!"
   @  9, 11  GET cBairro      PICT "@!"
   @ 10, 11  GET cCidade      PICT "@!"
   @ 10, 52  GET cUF          PICT "@!"
   @ 10, 61  GET cCep         PICT "@R 99.999-999"
   @ 11, 13  GET cFone        PICT "@R (999X)X999-9999"
   @ 13, 12  SAY SPACE(19)    COLOR SETCORES(2)
   @ 13, 12  GET cCGCCPF      VALID CGCCPF( cCGCCPF )
   @ 13, 56  GET cIERG        PICT "@!"

   READ

   FORNEC->(dbGoto( nII ))

   IF Lastkey() == K_ESC 
      IF lInclui ; FORNEC->(dbDelete()) ; END
      LOOP 
   END

   IF Updated()
      IF ATENCAO( 'Confirma '+IF(lInclui,'INCLUSAO ?','ALTERA€AO ?'), {'Sim','Nao'}, SETCORES(2) ) == 1

         FMENS( 'AGUARDE... Atualizando arquivo...' )
         FORNEC->CODIGO      :=  cCodigo
         FORNEC->NOME        :=  cNome
         FORNEC->ENDERECO    :=  cEndereco 
         FORNEC->NUMERO      :=  cNumero 
         FORNEC->BAIRRO      :=  cBairro 
         FORNEC->CIDADE      :=  cCidade 
         FORNEC->UF          :=  cUF 
         FORNEC->CEP         :=  cCep 
         FORNEC->FONE        :=  cFone 
         FORNEC->CGCCPF      :=  cCGCCPF
         FORNEC->IERG        :=  cIERG

         IF lInclui
            ACAO ( 'CADASTROU FORNECEDOR CODIGO ' + cCodigo )
         ELSE
            ACAO ( 'ALTEROU FORNECEDOR CODIGO ' + cCodigo )
         END

      ELSE
         IF lInclui ; FORNEC->(dbDelete()) ; END

      END
   ELSE
      IF lInclui ; FORNEC->(dbDelete()) ; END

   END
   
   UNLOCK
      
END

RestScreen ( 0, 0, MaxRow(), MaxCol(), cTela )
SetColor( cCor )
SetCursor( nCursor )
RETURN
