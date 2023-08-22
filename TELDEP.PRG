PROCEDURE TELADEP()
@  6, 12  SAY "Titular:"
@  9, 12  SAY "N§   NOME                             S   P   Nascimento"
@  5, 10  TO 17, 69    DOUBLE
@  8, 10  SAY "ÇÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÂÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¶"
@  9, 15  TO 16, 15
@  9, 48  TO 16, 48
@  9, 52  TO 16, 52
@  9, 56  TO 16, 56
@ 10, 10  SAY "ÇÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄ¶"
//@ 12, 10  SAY "ÇÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄ¶"
@ 17, 10  SAY "ÈÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÏÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¼"
RETURN

/*
@  6, 21  GET  DEPENDEN->CODIGO
@  7, 12  SAY  CLIENTES->NOME
@ 11, 12  GET  DEPENDEN->ORDEM
@ 11, 17  GET  DEPENDEN->NOME
@ 11, 50  GET  DEPENDEN->SEXO
@ 11, 54  GET  DEPENDEN->PARENTESCO
@ 11, 58  GET  DEPENDEN->NASCIMENTO
*/