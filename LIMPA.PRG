MemoWrit( '$PANE.$$$', '$PANE.$$$' )
aArq := {   'AUDIT',;
            'BANCOS',;
            'CAIXA',;
            'CCUSTO','GRUPOS',;
            'CHEQUES',;
            'CLIENTES',;
            'DEPENDEN',;
            'FORNEC',;
            'LANCTOS',;
            'PAGAR',;
            'PARPAGAR',;
            'PARRECEB',;
            'RECEB',;
            'SALDOS',;
            'TERM',;
            'USER',;
            'VENDEDOR' }

CLS
FOR I := 1 TO LEN( aArq )
    USE( aArq[ I ] )
    ? 'Apagando ' + aArq[ I ] + '...'
    ZAP
NEXT
    