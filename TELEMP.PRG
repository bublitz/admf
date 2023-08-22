/*

  Programa: TELEMP.PRG

*/

PROCEDURE TELAEMP()

@  3,  1  SAY PadC("Cadastro de Clientes - Pessoa Jur¡dica", 78 ) COLOR "N/W"

DispBox( 7,  2, 12, 71 )
@  4,  2  TO  6, 19
@  4, 24  TO  6, 71

@  5,  3  SAY "C¢digo:"
@  5, 25  SAY "Nome:"
@  7,  3  SAY "Endere‡o:"
@  8,  3  SAY "Rua/Avenida:"
@  8, 63  SAY "n§"
@  9,  3  SAY "Bairro:"
@ 10,  3  SAY "Cidade:"
@ 10, 48  SAY "UF:"
@ 10, 56  SAY "CEP:"
@ 11,  3  SAY "Telefone:"
@ 13,  3  SAY " C.G.C.:                                       I.E.:"
@ 15,  3  SAY "Contato (RH): "
@ 16,  3  SAY "Referˆncias Banc rias:"
@ 19,  3  SAY "Referˆncias Comerciais:"

RETURN
