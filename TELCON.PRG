/*

  PROGRAMA: TELCON.PRG
  
*/
#INCLUDE "MEU.CH"

PROCEDURE TelaCon()  

@  3,  1  SAY PadC( 'CADASTRO DE CONTRATOS', 78 ) COLOR 'N/W'

@  4,  2  SAY 'N£mero do Contrato:'
@  4, 34  SAY 'Tipo:'
@  6,  2  SAY 'Cliente:'
//@  6, 20  SAY 'XXX-----NOME DO CLIENTE---------------XXXX'
@  6, 63  SAY 'Tipo Pagto:'
@  8,  2  SAY 'Valor:'
@  8, 22  SAY '- Desconto:'
@  8, 47  SAY '= Valor L¡quido:'
@ 10,  2  SAY 'Valor Despesas Gerais:'
@ 10, 39  SAY 'Valor Total do Contrato:' // 99,999,999,99
@ 12,  2  SAY 'Cheque:'
@ 12, 21  SAY 'Banco:'
@ 12, 39  SAY 'Agˆncia:'
@ 12, 59  SAY 'Pra‡a:'
@ 14,  2  SAY 'Vendedor:'
@ 15,  2  SAY 'C. de Custo:'
//@ 14, 16  SAY 'XXX-------NOME DO VENDEDOR--------XXX'
@ 16,  2  SAY 'Data Assinatura:'
@ 16, 30  SAY 'Data Vencto:'
@ 16, 57  SAY 'Tipo de Cobran‡a:'
@ 18,  2  SAY 'Valores Í'+C_SETA+' Manuten‡ao:'
@ 18, 40  SAY 'Datas Í'+C_SETA+' Apres. Fatura:'
@ 19, 13  SAY 'Titular:'
@ 19, 49  SAY 'Vencto Fatura:'
@ 20, 13  SAY 'Dep. Direto:'
@ 20, 49  SAY 'Inicial Inc/Exc:'
@ 21, 13  SAY 'Dep. Indir.:'
@ 21, 49  SAY 'Final Inc/Exc:'

@  7,  1  TO 11, 77
@  5,  1  TO  7, 62
@  5, 62  TO  7, 77
@  9, 37  TO 11, 77
@ 11,  1  TO 13, 77
@ 15, 56  TO 17, 77
@  7,  1  SAY Chr( 195 )
@  5, 62  SAY Chr( 194 )
@  7, 62  SAY Chr( 193 )
@  7, 77  SAY Chr( 180 )
@  9, 77  SAY Chr( 180 )
@ 11,  1  SAY Chr( 195 )
@ 11, 37  SAY Chr( 193 )
@ 11, 77  SAY Chr( 180 )

/*
@  4, 22  GET  CONTRATO->NUMERO
@  4, 40  GET  CONTRATO->TIPO
@  6, 11  GET  CONTRATO->CLIENTE
@  6, 75  GET  CONTRATO->PARCELADO
@  8,  9  GET  CONTRATO->VLTOTAL
@  8, 34  GET  CONTRATO->VLDESCTO
@  8, 64  GET  CONTRATO->VLPAGO
@ 10, 25  GET  CONTRATO->VLDESP
@ 12, 10  GET  CONTRATO->CHEQUE
@ 12, 28  GET  CONTRATO->BANCO
@ 12, 48  GET  CONTRATO->AGENCIA
@ 12, 66  GET  CONTRATO->PRACA
@ 14, 12  GET  CONTRATO->VENDEDOR
@ 16, 19  GET  CONTRATO->ASSINA
@ 16, 43  GET  CONTRATO->VENCTO
@ 16, 75  GET  CONTRATO->TIPOCOBRA
@ 18, 25  GET  CONTRATO->VLMANUT
@ 19, 22  GET  CONTRATO->VLTITUL
@ 20, 26  GET  CONTRATO->VLDEPDI
@ 21, 26  GET  CONTRATO->VLDEPIN
@ 18, 64  GET  CONTRATO->APRFATU
@ 19, 64  GET  CONTRATO->VECFATU
@ 20, 66  GET  CONTRATO->DT1INC
@ 21, 64  GET  CONTRATO->DT2INC
*/
