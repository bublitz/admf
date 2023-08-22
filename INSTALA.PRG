/**************************

 Programa: INSTALA.PRG

 Armazena em dados do Sistema em PARAM.COM
 
***************************/

PROCEDURE MAIN()
LOCAL GETLIST := {},;
      aStru := { { 'USERLIST','C',35,0 }, ;
                 { 'LOGIN'   ,'C',80,0 } }

MEMVAR cSenha,; 
       cNomeP,;    // Nome do Sistema
       cNomeA,;    // Nome do Autor
       cNomeC,;    // Nome do Usuario
       cCRC

CLS

cNomeA := CRIPTO ( 'DRACHE ADMINISTRADOR 3.0' )
cNomeP := CRIPTO ( 'DRACHE INFORMATICA' )
cNomeC := CRIPTO ( 'ALVORADA CAMINHOES' )
//cNomeC := CRIPTO ( '' )

cSenha := cNomeA + cNomeP + cNomeC

cCRC := CHECKSUM( cSenha )

SAVE TO PARAM.COM ALL LIKE c*

DBCREATE( 'USER', aStru )
USE USER
APPEND BLANK
USER->USERLIST := CRIPTO( 'ROOT ALVORADA' )
USER->LOGIN := CRIPTO("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghi") //jklmnopqrstuvwxyz~!@#$%^&*()_+-=*/>"
CLOSE DATABASE

? DECRIPTO(cNomeP)
? DECRIPTO(cNomeA)
? DECRIPTO(cNomeC)
? cCRC
?
? 'OK!'
? 'Arquivo PARAM.COM gerado...'

RETURN 

************************
FUNCTION CRIPTO( cMens )
************************
LOCAL cRet := '', nII, nCar

FOR nII := 1 TO LEN( cMens )

    nCar := ASC( SUBSTR( cMens, nII, 1 ) )

    IF nII/2 == INT( nII/2 )
       nCar += 2

    ELSE
       nCar++

    END

    cRet += CHR( nCar )

NEXT
RETURN cRet


**************************
FUNCTION DECRIPTO( cMens )
**************************
LOCAL cRet := '', nII, nCar
FOR nII := 1 TO LEN( cMens )

    nCar := ASC( SUBSTR( cMens, nII, 1 ) )

    IF nII/2 == INT( nII/2 )
       nCar -= 2

    ELSE
       nCar--

    END

    cRet += CHR( nCar )

NEXT
RETURN cRet
