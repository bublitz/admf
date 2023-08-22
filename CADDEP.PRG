#include 'MEU.ch'
#include 'INKEY.ch'
#include 'SETCURS.ch'
#include 'combo.ch'

********************************
PROCEDURE DEPENDENTES( cCodCli )
********************************
LOCAL cTela, cCor, nLinha, nOrde, cNome, cSexo, cPare, dNasc, lInclui, nReg,;
      GETLIST := {}, nOpcao

cCor  := SetColor( SETCORES( 1 ) )
cTela := ABRE( 5, 10, 17, 69, .T. )

TELADEP()

SELE CLIENTES
SEEK cCodCli

@  6, 21 SAY cCodCli
@  7, 12 SAY CLIENTES->NOME COLOR SETCORES(3)

WHILE .T.

   UNLOCK
   COMMIT
   
   FOR nLinha := 11 TO 16
      @ nLinha, 10 SAY "º    ³                                ³   ³   ³            º"
   NEXT

   SELE DEPENDEN
   SEEK cCodCli

   nLinha := 12
   WHILE DEPENDEN->CODIGO == cCodCli .AND. !EOF()
       @ nLinha,   12  SAY  DEPENDEN->ORDEM
       @ nLinha,   17  SAY  DEPENDEN->NOME
       @ nLinha,   50  SAY  DEPENDEN->SEXO
       @ nLinha,   54  SAY  DEPENDEN->PARENTESCO
       @ nLinha++, 58  SAY  DEPENDEN->NASCIMENTO
       IF nLinha > 16
          EXIT
       END
       DEPENDEN->(dbSkip())
   END

   nOrde := 0

   @ 11, 12 GET nOrde PICT '99'
   READ

   IF LASTKEY() == K_ESC ; EXIT ; END

   @ 11, 12 SAY STRZERO(nOrde,2,0) PICT '99' COLOR SETCORES(3)
   SEEK cCodCli + STRZERO( nOrde, 2, 0 )

   IF FOUND()
      lInclui := FALSE
      nReg := RECNO()

      TELADEP()
      SELE CLIENTES
      SEEK cCodCli
      @  6, 21 SAY cCodCli
      @  7, 12 SAY CLIENTES->NOME COLOR SETCORES(3)

      SELE DEPENDEN

      FOR nLinha := 12 TO 16
         @ nLinha, 10 SAY "º    ³                                ³   ³   ³            º"
      NEXT

      nLinha := 12
      WHILE DEPENDEN->CODIGO == cCodCli .AND. !EOF()
         @ nLinha,   12  SAY  DEPENDEN->ORDEM
         @ nLinha,   17  SAY  DEPENDEN->NOME
         @ nLinha,   50  SAY  DEPENDEN->SEXO
         @ nLinha,   54  SAY  DEPENDEN->PARENTESCO
         @ nLinha++, 58  SAY  DEPENDEN->NASCIMENTO
         IF nLinha > 16
            EXIT
         END
         DEPENDEN->(dbSkip())
      END

      GO nReg

      nOpcao := ATENCAO( 'Deseja:' , { 'Alterar','Excluir','Voltar' } , SETCORES(1))

      IF nOpcao == 3 ; LOOP
      ELSEIF nOpcao == 2
             IF '3'$M->cRight
                IF ATENCAO( 'Confirma Exclusao?; ',{'Nao','Sim'}, SETCORES(2) ) == 2
                   IF NetRLock()
                      DEPENDEN->(dbDelete())
                      ACAO( 'EXCLUIU DEPENDENTE CODIGO ' + cCodCli + '.' + STRZERO(nOrde,2,0) )
                   END
                END
             ELSE
                ATENCAO( 'Acesso nao Permitido!' )
                ACAO( 'TENTOU EXCLUIR DEPENDENTE CODIGO ' + cCodCli + '.' + STRZERO(nOrde,2,0) )
             END
             LOOP
      END

   ELSE  // nao achou e digitou 0, procura £ltimo da lista
      IF nOrde == 0
         SELE DEPENDEN
         SEEK cCodCli
         IF FOUND()
            WHILE DEPENDEN->CODIGO == cCodCli .AND. !EOF()
               DEPENDEN->(dbSkip())
            END
            DEPENDEN->(dbSkip(-1))
            nOrde := VAL( DEPENDEN->ORDEM ) + 1

         ELSE
            nOrde := 1

         END
      END

      @ 11, 12 SAY STRZERO(nOrde,2,0) PICT '99' COLOR SETCORES(3)
      lInclui := TRUE
      GO BOTTOM
      SKIP

   END

   cNome := DEPENDEN->NOME
   cSexo := DEPENDEN->SEXO
   cPare := DEPENDEN->PARENTESCO
   dNasc := DEPENDEN->NASCIMENTO

   @ 11, 17  GET  cNome
   @ 11, 50  GET  cSexo ;
             COMBO { "1=Masculino","2=Feminino" } ;
             VALID cSexo$'12'

   @ 11, 54  GET  cPare ;
             COMBO { '1=Esposa','2=Marido','3=Filho(a)','4=Pai','5=Mae','9=Outros' } ;
             VALID cPare$'123459'

   @ 11, 58  GET  dNasc
   READ

   IF LASTKEY() == K_ESC ; LOOP ; END

   IF lInclui
      IF !NetAppBlank()
         LOOP
      END
   ELSE
      IF !NetRLock()
         LOOP
      END
   END

   DEPENDEN->CODIGO      :=  cCodCli
   DEPENDEN->ORDEM       :=  STRZERO( nOrde, 2, 0 )
   DEPENDEN->NOME        :=  cNome
   DEPENDEN->SEXO        :=  cSexo
   DEPENDEN->PARENTESCO  :=  cPare
   DEPENDEN->NASCIMENTO  :=  dNasc

   IF lInclui
      ACAO( 'CADASTROU DEPENDENTE CODIGO ' + cCodCli + '.' + STRZERO(nOrde,2,0) )
   ELSE
      ACAO( 'ALTEROU DEPENDENTE CODIGO ' + cCodCli + '.' + STRZERO(nOrde,2,0) )
   END

END

FECHA( 5, 10, 17, 69, cTela, .T. )
SetColor( cCor )

RETURN
