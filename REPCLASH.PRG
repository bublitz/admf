/**************

  Programa RepClass.prg

  Define a Classe Report e os Metodos

*/

#include 'Class.ch'         // Header para Criacao das Classes
#include 'RepClass.ch'      // Header da classe Report        

#define TRUE    .T.
#define FALSE   .F.

STATIC aTotal, aGroupT, aSGroupT

/**************

  Define a classe ReportNew
  -------------------------

  Funcao da Classe Report Criadora de Objetos Report
  
*/

DEFINE CLASS ReportNew USING nLength
OBJECT LOCAL oReport                   // Declara o objeto

aTotal := NIL
aGroupT := NIL
aSGroupT := NIL

// Verifica as mensagens recebidas
nLength := IF ( VALTYPE ( nLength ) != 'N', 56, nLength )

// Cria um objeto, sendo que serao armazenados
// os seguintes valores default para as variaveis/elementos

oReport := { NIL, 0, nLength, {||{''}}, {|nToJump|RepSkipper(nToJump)},'-',{},;
             nLength, NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL,;
             {' Sub-Total','Total','Total Geral' } }

// Retorna o objeto
RETURN oReport


/**************

  Define o Metodo addColumn()
  ---------------------------
  
  Adiciona uma nova coluna ao objeto report
  
*/
DEFINE METHOD addColumn MESSAGES oReport, oColumn

// Verifica a validade das mensagens recebidas
IF VALTYPE ( oReport ) != 'A' .OR. VALTYPE ( oColumn ) != 'O'
   IF ALERT ( 'Mensagem(s) Enviada(s) Invalida(s)',;
                     {'Quit','Ignore'}) == 1
      QUIT
   ELSE
      RETURN NIL
   END
END

oColumn:colSep := IF ( oColumn:colSep == NIL, ' ', oColumn:colSep )

AADD ( .oReport:columns, oColumn )

RETURN NIL


/**************

  Define o Metodo stabilize()
  --------------------------
  
  Processa a impressao de linha da fonte de dados
  
*/
DEFINE METHOD stabilize MESSAGES oReport
LOCAL lRet, nI, aCabec, nMaxLen := 0, cPicture, cTipo

IF VALTYPE ( oReport ) != 'A'
   IF ALERT ( 'Mensagem(s) Enviada(s) Invalida(s)',;
                     {'Quit','Ignore'}) == 1
      QUIT
   ELSE
      RETURN NIL
   END
END

// Define Array de Totalizacao
IF aTotal == NIL
   // Verifica se alguma coluna e' totalizada
   FOR nI := 1 TO LEN ( .oReport:columns )
      IF .oReport:columns[ nI ]:cargo != NIL   // Totaliza esta coluna
         aTotal := ARRAY ( LEN ( .oReport:columns ), 1 )
         EXIT
      END
   NEXT

END

// Verifica o salto de Pagina
IF .oReport:lineCounter >= .oReport:reportLength

   // Imprime o cabecalho
   .oReport:cabecalho()

END

// Verifica quebra de GRUPO
IF .oReport:groupExp != NIL  // Se ha' algum Grupo Definido

   // Se e' 1¦ vez, imprime o Header, a Expressao e Atualiza Cargo
   IF aGroupT == NIL
//      .oReport:lineCounter++
      @ .oReport:lineCounter, 0 SAY .oReport:groupHeader
//      @ ++.oReport:lineCounter, 0 SAY .oReport:groupHeader
//      @ .oReport:lineCounter++, PCOL() SAY EVAL ( .oReport:groupExp )
      @ .oReport:lineCounter, PCOL() SAY EVAL ( .oReport:groupExp )
      aGroupT := ARRAY ( LEN ( .oReport:columns ), 1 )
      .oReport:groupCargo := EVAL ( .oReport:groupExp )

   ELSE
      // Se mudou o Grupo
      IF .oReport:groupCargo != EVAL ( .oReport:groupExp )

         // SE EXISTE SUB-GRUPO, IMPRIME E ZERA
         IF .oReport:subExp != NIL
            // IMPRIME SUB-TOTAIS E ZERA aSGroupT
//            .oReport:lineCounter++
            @ ++.oReport:lineCounter, 0 SAY .oReport:rodape[ 1 ]

            @ .oReport:lineCounter, 0 SAY ''
            FOR nI := 1 TO LEN ( .oReport:columns )
               @ .oReport:lineCounter, PCOL() SAY .oReport:columns[ nI ]:colSep

               IF .oReport:columns[ nI ]:cargo != NIL   // Totaliza esta coluna
                  @ .oReport:lineCounter, PCOL() SAY aSGroupT[ nI,1 ] ;
                       PICT .oReport:columns[ nI ]:picture
                  aSGroupT [ nI, 1 ] := 0

               ELSE
                    cTipo := VALTYPE( EVAL(.oReport:columns[ nI ]:block ))
                    IF     cTipo == 'C'
                           @ .oReport:lineCounter, PCOL() SAY ;
                           SPACE( LEN( EVAL(.oReport:columns[ nI ]:block )))
                    ELSEIF cTipo == 'N'
                           @ .oReport:lineCounter, PCOL() SAY ;
                           SPACE( LEN( TRANSF( EVAL(.oReport:columns[ nI ]:block),;
                           .oReport:columns[ nI ]:picture )))
                    ELSEIF cTipo == 'D'
                           @ .oReport:lineCounter, PCOL() SAY ;
                           SPACE( LEN( DTOC( EVAL(.oReport:columns[ nI ]:block ))))
                    END
               END
            NEXT
            @ .oReport:lineCounter, PCOL() SAY .oReport:columns[ nI-1 ]:colSep

            IF .oReport:subEject == TRUE ; .oReport:cabecalho() ; END

         END

         // IMPRIME TOTAIS E ZERA aGroupT
//         .oReport:lineCounter++
         @ ++.oReport:lineCounter, 0 SAY .oReport:rodape[ 2 ]
         @ .oReport:lineCounter, 0 SAY ''
         FOR nI := 1 TO LEN ( .oReport:columns )
             @ .oReport:lineCounter, PCOL() SAY .oReport:columns[ nI ]:colSep

             IF .oReport:columns[ nI ]:cargo != NIL   // Totaliza esta coluna
                 @ .oReport:lineCounter, PCOL() SAY aGroupT[ nI,1 ] ;
                       PICT .oReport:columns[ nI ]:picture
                 aGroupT [ nI, 1 ] := 0

             ELSE
                   cTipo := VALTYPE( EVAL(.oReport:columns[ nI ]:block ))
                   IF     cTipo == 'C'
                          @ .oReport:lineCounter, PCOL() SAY ;
                          SPACE( LEN( EVAL(.oReport:columns[ nI ]:block )))
                   ELSEIF cTipo == 'N'
                          @ .oReport:lineCounter, PCOL() SAY ;
                          SPACE( LEN( TRANSF( EVAL(.oReport:columns[ nI ]:block),;
                          .oReport:columns[ nI ]:picture )))
                   ELSEIF cTipo == 'D'
                          @ .oReport:lineCounter, PCOL() SAY ;
                          SPACE( LEN( DTOC( EVAL(.oReport:columns[ nI ]:block ))))
                   END
             END
         NEXT
         @ ++.oReport:lineCounter, PCOL() SAY .oReport:columns[ nI-1 ]:colSep

         IF .oReport:groupEject == TRUE 
            .oReport:cabecalho() 
         ELSE
            IF .oReport:lineCounter >= .oReport:reportLength
               .oReport:cabecalho()
            END
         END

//         .oReport:lineCounter++
         @ ++.oReport:lineCounter, 0 SAY .oReport:groupHeader
//         @ .oReport:lineCounter++, PCOL()   SAY EVAL ( .oReport:groupExp )
         @ .oReport:lineCounter, PCOL()   SAY EVAL ( .oReport:groupExp )
         .oReport:groupCargo := EVAL ( .oReport:groupExp )

         // verifica sub-grupo
         IF .oReport:subExp != NIL
            @ ++.oReport:lineCounter, 0 SAY .oReport:subHeader
//            @ .oReport:lineCounter++, PCOL()   SAY EVAL ( .oReport:subExp )
            @ .oReport:lineCounter, PCOL()   SAY EVAL ( .oReport:subExp )
            .oReport:subCargo := EVAL ( .oReport:subExp )
         END
      END
   END
END

// Verifica quebra de SUB-GRUPO
IF .oReport:subExp != NIL

   // Se e' 1¦ vez, imprime o Header, a Expressao e Atualiza Cargo
   IF aSGroupT == NIL
      @ ++.oReport:lineCounter, 0 SAY .oReport:subHeader
//      @ .oReport:lineCounter++, PCOL() SAY EVAL ( .oReport:subExp )
      @ .oReport:lineCounter, PCOL() SAY EVAL ( .oReport:subExp )
      aSGroupT := ARRAY ( LEN ( .oReport:columns ), 1 )
      .oReport:subCargo := EVAL ( .oReport:subExp )

   ELSE
      // Se mudou o SUB-Grupo
      IF .oReport:subCargo != EVAL ( .oReport:subExp )

         // IMPRIME SUB-TOTAIS E ZERA aSGroupT
//         .oReport:lineCounter++
         @ ++.oReport:lineCounter, 0 SAY .oReport:rodape[ 1 ]
         @ .oReport:lineCounter, 0 SAY ''
         FOR nI := 1 TO LEN ( .oReport:columns )
             @ .oReport:lineCounter, PCOL() SAY .oReport:columns[ nI ]:colSep

             IF .oReport:columns[ nI ]:cargo != NIL   // Totaliza esta coluna
                 @ .oReport:lineCounter, PCOL() SAY aSGroupT[ nI,1 ] ;
                       PICT .oReport:columns[ nI ]:picture
                 aSGroupT [ nI, 1 ] := 0

             ELSE
                   cTipo := VALTYPE( EVAL(.oReport:columns[ nI ]:block ))
                   IF     cTipo == 'C'
                          @ .oReport:lineCounter, PCOL() SAY ;
                          SPACE( LEN( EVAL(.oReport:columns[ nI ]:block )))
                   ELSEIF cTipo == 'N'
                          @ .oReport:lineCounter, PCOL() SAY ;
                          SPACE( LEN( TRANSF( EVAL(.oReport:columns[ nI ]:block),;
                          .oReport:columns[ nI ]:picture )))
                   ELSEIF cTipo == 'D'
                          @ .oReport:lineCounter, PCOL() SAY ;
                          SPACE( LEN( DTOC( EVAL(.oReport:columns[ nI ]:block ))))
                   END
             END
         NEXT
         @ .oReport:lineCounter, PCOL() SAY .oReport:columns[ nI-1 ]:colSep

         IF .oReport:subEject == TRUE 
            .oReport:cabecalho() 
         ELSE
            IF .oReport:lineCounter >= .oReport:reportLength
               .oReport:cabecalho()
            END
         END

//         .oReport:lineCounter++
         @ ++.oReport:lineCounter, 0 SAY .oReport:subHeader
//         @ .oReport:lineCounter++, PCOL()   SAY EVAL ( .oReport:subExp )
         @ .oReport:lineCounter, PCOL()   SAY EVAL ( .oReport:subExp )
         .oReport:subCargo := EVAL ( .oReport:subExp )

      END
   END
END

@ .oReport:lineCounter++, 0 SAY ''

IF .oReport:lineCounter >= .oReport:reportLength
   .oReport:cabecalho()
END

IF !EOF()
   // *** Imprime as Colunas
   FOR nI := 1 TO LEN ( .oReport:columns )

      @ .oReport:lineCounter, PCOL() SAY .oReport:columns[ nI ]:colSep
 
      cPicture := IF ( .oReport:columns[ nI ]:picture != NIL, .oReport:columns[ nI ]:picture, '' )
      @ .oReport:lineCounter, PCOL() SAY EVAL(.oReport:columns[ nI ]:block ) PICT cPicture

      IF .oReport:columns[ nI ]:cargo != NIL   // Totaliza esta coluna
         // *** TOTALIZACAO FINAL
         aTotal[ nI,1 ] := IF( aTotal[ nI,1 ] != NIL,;
                         aTotal[ nI,1 ] + EVAL( .oReport:columns[ nI ]:cargo ),;
                         EVAL( .oReport:columns[ nI ]:cargo ) )
         // *** TOTALIZACAO GRUPO                      
         IF aGroupT != NIL
            aGroupT[ nI,1 ] := IF( aGroupT[ nI,1 ] != NIL,;
                         aGroupT[ nI,1 ] + EVAL( .oReport:columns[ nI ]:cargo ),;
                         EVAL( .oReport:columns[ nI ]:cargo ) )
         END
         // *** TOTALIZACAO SUB-GRUPO
         IF aSGroupT != NIL
            aSGroupT[ nI,1 ] := IF( aSGroupT[ nI,1 ] != NIL,;
                         aSGroupT[ nI,1 ] + EVAL( .oReport:columns[ nI ]:cargo ),;
                         EVAL( .oReport:columns[ nI ]:cargo ) )
         END
      END
 
   NEXT
  
   @ .oReport:lineCounter, PCOL() SAY .oReport:columns[ nI-1 ]:colSep

END

lRet := ( EVAL ( .oReport:skipBlock, 1 ) != 1 )

IF lRet .AND. aSGroupT != NIL  // Imprime Sub-Totais, se existirem
//   .oReport:lineCounter++
   @ ++.oReport:lineCounter, 0 SAY .oReport:rodape[ 1 ]
   @ .oReport:lineCounter, 0 SAY ''

   FOR nI := 1 TO LEN ( .oReport:columns )

       @ .oReport:lineCounter, PCOL() SAY .oReport:columns[ nI ]:colSep

       IF .oReport:columns[ nI ]:cargo != NIL   // Totaliza esta coluna
          @ .oReport:lineCounter, PCOL() SAY aSGroupT[ nI,1 ] ;
            PICT .oReport:columns[ nI ]:picture

       ELSE
          cTipo := VALTYPE( EVAL(.oReport:columns[ nI ]:block ))
          IF     cTipo == 'C'
                 @ .oReport:lineCounter, PCOL() SAY ;
                   SPACE( LEN( EVAL(.oReport:columns[ nI ]:block )))
          ELSEIF cTipo == 'N'
                 @ .oReport:lineCounter, PCOL() SAY ;
                   SPACE( LEN( TRANSF( EVAL(.oReport:columns[ nI ]:block),;
                   .oReport:columns[ nI ]:picture )))
          ELSEIF cTipo == 'D'
                 @ .oReport:lineCounter, PCOL() SAY ;
                   SPACE( LEN( DTOC( EVAL(.oReport:columns[ nI ]:block ))))
          END
       END
   
   NEXT

   @ .oReport:lineCounter, PCOL() SAY .oReport:columns[ nI-1 ]:colSep

END

IF lRet .AND. aGroupT != NIL  // Imprime Totais, se existirem
//   .oReport:lineCounter++
   @ ++.oReport:lineCounter, 0 SAY .oReport:rodape[ 2 ]
   @ .oReport:lineCounter, 0 SAY ''
   
   FOR nI := 1 TO LEN ( .oReport:columns )

       @ .oReport:lineCounter, PCOL() SAY .oReport:columns[ nI ]:colSep

       IF .oReport:columns[ nI ]:cargo != NIL   // Totaliza esta coluna
          @ .oReport:lineCounter, PCOL() SAY aGroupT[ nI,1 ] ;
            PICT .oReport:columns[ nI ]:picture
                 
       ELSE
          cTipo := VALTYPE( EVAL(.oReport:columns[ nI ]:block ))
          IF     cTipo == 'C'
                 @ .oReport:lineCounter, PCOL() SAY ;
                 SPACE( LEN( EVAL(.oReport:columns[ nI ]:block )))
          ELSEIF cTipo == 'N'
                 @ .oReport:lineCounter, PCOL() SAY ;
                 SPACE( LEN( TRANSF( EVAL(.oReport:columns[ nI ]:block),;
                 .oReport:columns[ nI ]:picture )))
          ELSEIF cTipo == 'D'
                 @ .oReport:lineCounter, PCOL() SAY ;
                 SPACE( LEN( DTOC( EVAL(.oReport:columns[ nI ]:block ))))
          END
       END
   
   NEXT

   @ .oReport:lineCounter, PCOL() SAY .oReport:columns[ nI-1 ]:colSep

END

IF lRet .AND. VALTYPE ( aTotal ) == 'A'   // Imprime Totais

//   .oReport:lineCounter++
   .oReport:lineCounter++
   @ ++.oReport:lineCounter, 0 SAY .oReport:rodape[ 3 ]
   @ .oReport:lineCounter, 0 SAY ''
   
   FOR nI := 1 TO LEN ( .oReport:columns )

      @ .oReport:lineCounter, PCOL() SAY .oReport:columns[ nI ]:colSep

      IF .oReport:columns[ nI ]:cargo != NIL   // Totaliza esta coluna
          @ .oReport:lineCounter, PCOL() SAY aTotal[ nI,1 ] ;
                       PICT .oReport:columns[ nI ]:picture
      ELSE
          cTipo := VALTYPE( EVAL(.oReport:columns[ nI ]:block ))
          IF     cTipo == 'C'
                 @ .oReport:lineCounter, PCOL() SAY ;
                 SPACE( LEN( EVAL(.oReport:columns[ nI ]:block )))
          ELSEIF cTipo == 'N'
                 @ .oReport:lineCounter, PCOL() SAY ;
                 SPACE( LEN( TRANSF( EVAL(.oReport:columns[ nI ]:block),;
                 .oReport:columns[ nI ]:picture )))
          ELSEIF cTipo == 'D'
                 @ .oReport:lineCounter, PCOL() SAY ;
                 SPACE( LEN( DTOC( EVAL(.oReport:columns[ nI ]:block ))))
          END
      END

   NEXT

   @ .oReport:lineCounter, PCOL() SAY .oReport:columns[ nI-1 ]:colSep

END

RETURN lRet

/**************

  Define o Metodo cabecalho()
  --------------------------

  Imprime o Cabecalho do Relatorio

*/
DEFINE METHOD cabecalho MESSAGES oReport
LOCAL nI, aCabec, nMaxLen := 1

.oReport:lineCounter := 0
.oReport:pageCounter++

aCabec := EVAL ( .oReport:header )

FOR nI := 1 TO LEN ( aCabec )
       @ .oReport:lineCounter++, 0 SAY aCabec[ nI ]
NEXT

AEVAL ( aCabec, { |aElem| ;
                  nMaxLen := IF ( LEN ( aElem ) > nMaxLen ,;
                                  LEN ( aElem ), nMaxLen ) } )

nMaxLen := 0
FOR nI := 1 TO LEN ( .oReport:columns )
    nMaxLen += LEN ( .oReport:columns[ nI ]:colSep )
    nMaxLen += LEN ( .oReport:columns[ nI ]:heading )
NEXT
@ .oReport:lineCounter, 0 SAY REPL ( .oReport:headSep, nMaxLen )

@ ++.oReport:lineCounter, 0 SAY ''

FOR nI := 1 TO LEN ( .oReport:columns )
    @ .oReport:lineCounter, PCOL() SAY .oReport:columns[ nI ]:colSep
    @ .oReport:lineCounter, PCOL() SAY ( .oReport:columns[ nI ]:heading )
NEXT
@ .oReport:lineCounter, PCOL() SAY .oReport:columns[ nI-1 ]:colSep
@ ++.oReport:lineCounter, 0 SAY REPL ( .oReport:headSep, nMaxLen )

@ ++.oReport:lineCounter, 0 SAY ''

RETURN NIL

/**************

  Define a funcao RepSkipper()
  --------------------------

  Funcao responsavel pelo salto nos dados na fonte

*/
*******************************
FUNCTION RepSkipper ( nToJump )
*******************************
LOCAL nJumped := 0

IF LASTREC() != 0
   IF nToJump > 0
      WHILE nJumped < nToJump .AND. !EOF()
         SKIP
         IF EOF() ; SKIP -1 ; EXIT ; END
         nJumped++
      END
   ELSEIF nToJump < 0
      WHILE nJumped > nToJump .AND. !EOF()
         SKIP -1
         IF BOF() ; EXIT ; END
         nJumped++
      END
   ELSE
      SKIP 0
   END
END

RETURN nJumped


/**************

  Define a funcao RepSkipF()
  --------------------------

  Funcao responsavel pelo salto nos dados na fonte com filtragem

*/
FUNCTION RepSkipF ( nToJump, bFilter )

STATIC lStartUp := TRUE

LOCAL nJumped := 0, nLastRec

IF bFilter == Nil
   lStartUp := TRUE
   RETURN Nil
END

IF lStartUp
   lStartUp := FALSE
   WHILE !EVAL ( bFilter ) .AND. !EOF()
       SKIP
   END
END

IF LASTREC() != 0
   IF nToJump > 0
      WHILE nJumped < nToJump .AND. !EOF()
         nLastRec := RECNO()
         SKIP
         WHILE !EVAL ( bFilter ) .AND. !EOF()
            SKIP
         END
         IF !EVAL( bFilter ) .OR. EOF() 
            GO nLastRec
            EXIT
         END
         nJumped++
      END
   ELSEIF nToJump < 0
      WHILE nJumped > nToJump
         nLastRec := RECNO()
         SKIP -1
         WHILE !EVAL ( bFilter ) 
             SKIP -1
             IF BOF() ; EXIT ; END
         END
         IF !EVAL( bFilter ) .OR. BOF() 
            GO nLastRec
            EXIT
         END
         nJumped--
      END
   ELSE
      SKIP 0
   END
END

RETURN nJumped      


/**************

  END WinClass.prg
  
*/  
