/*

 Programa: TELVENDA.prg

 Funcao: Desenha Tela Vendas

*/

PROCEDURE TelaVenda()
LOCAL cCor

@  8,  1  TO  8, 78
@ 11,  1  TO 11, 78

@  5,  2  SAY "Proprietario:"
@  6,  2  SAY "Marca:"
@  7,  2  SAY "Modelo:"
@  7, 69  SAY "Ano:"
@  9,  2  SAY "Comprador:"
@ 10,  2  SAY "Vendedor:"
@ 10, 49  SAY "Comissao:"
@ 10, 64  SAY "%"
@ 12, 24  SAY "ÚDinheiro:"
@ 13,  2  SAY "Venda:                ´Cheque:"
@ 14, 24  SAY "ÀOutros:"
cCor := SetColor( 'W+/B' )
Scroll( 15, 1, 17, 78 )
@ 15, 24  SAY "ÚDinheiro:"
@ 16,  2  SAY "Custo:                ´Cheque:"
@ 17, 24  SAY "ÀOutros:"
SetColor( 'W+/R' )
Scroll( 18, 1, 20, 78 )
@ 18, 24  SAY "ÚDinheiro:"
@ 19,  2  SAY "Saldo:                ´Cheque:"
@ 20, 24  SAY "ÀOutros:"
SetColor( cCor )

RETURN

/*
//                     1         2         3         4         5         6         7
//             23456789 123456789 123456789 123456789 123456789 123456789 123456789 12345678
@ 13,  2  SAY "Venda:  9.999.999.99  ´Cheque:"
@  5, 16  GET  VENDAS->PROPRIETAR
@  6,  9  GET  VENDAS->MARCA
@  7, 10  GET  VENDAS->MODELO
@  7, 74  GET  VENDAS->ANO
@  9, 13  GET  VENDAS->COMPRADOR
@ 10, 12  GET  VENDAS->VENDEDOR
@ 10, 61  GET  VENDAS->COMISSAO_P
@ 10, 68  GET  VENDAS->COMISSAO_V
@ 12, 35  GET  VENDAS->VEN_DIN
@ 13, 35  GET  VENDAS->VEN_CHE
@ 13, 48  GET  VENDAS->VEN_NUMCHE
@ 14, 35  GET  VENDAS->VEN_OUT
@ 14, 48  GET  VENDAS->VEN_OUTHIS
@ 15, 35  GET  VENDAS->CUS_DIN
@ 16, 35  GET  VENDAS->CUS_CHE
@ 16, 48  GET  VENDAS->CUS_NUMCHE
@ 17, 35  GET  VENDAS->CUS_OUT
@ 17, 48  GET  VENDAS->CUS_OUTHIS
@ 18, 35  GET  VENDAS->SAL_DIN
@ 19, 35  GET  VENDAS->SAL_CHE
@ 19, 48  GET  VENDAS->SAL_NUMCHE
@ 20, 35  GET  VENDAS->SAL_OUT
@ 20, 48  GET  VENDAS->SAL_OUTHIS
*/

