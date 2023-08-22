/*

  Programa: TELCLI.PRG

*/

PROCEDURE TELACLI()

@  3,  1  SAY PadC("Cadastro de Clientes", 78 ) COLOR "N/W"

DispBox( 7,  2, 12, 71 )
DispBox(14,  2, 19, 71 )
@ 19,  2  TO 21, 11
@ 19, 13  TO 21, 35
@ 19, 36  TO 21, 53
@ 19, 54  TO 21, 71
@  4,  2  TO  6, 19
@  4, 24  TO  6, 71

@  5,  3  SAY "C줰igo:"
@  5, 25  SAY "Nome:"
@  7,  3  SAY "Endere뇇 Residencial:"
@  8,  3  SAY "Rua/Avenida:"
@  8, 63  SAY "n�"
@  9,  3  SAY "Bairro:"
@ 10,  3  SAY "Cidade:"
@ 10, 48  SAY "UF:"
@ 10, 56  SAY "CEP:"
@ 11,  3  SAY "Telefone:"
@ 13,  3  SAY " C.P.F.:                                       R.G.:"
@ 14,  3  SAY "Endere뇇 Comercial:"
@ 15,  3  SAY "Rua/Avenida:"
@ 15, 62  SAY "n�"
@ 16,  3  SAY "Bairro:"
@ 17,  3  SAY "Cidade:"
@ 17, 48  SAY "UF:"
@ 17, 56  SAY "CEP:"
@ 18,  3  SAY "Telefone:"
@ 19,  2  SAY "쳐컴컴컴컫컫컴컴컴컴컴컴컴컴컴컴컫쩡컴컴컴컴컴컴컴컫쩡컴컴컴컴컴컴컴캑"
@ 20,  3  SAY "Sexo:"
@ 20, 14  SAY "Data Nasc:"
@ 20, 37  SAY "Escolaridade:"
@ 20, 55  SAY "Estado Civil:"

RETURN
