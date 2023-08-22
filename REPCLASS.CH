/**************

  Header:  RepClass.CH
  
           Header para Criacao de Classes Report
  
*/

/**************

  #defines das variaveis particulares a classe Report

*/

#define _CARGO               1
#define _PAGE_COUNTER        2
#define _REPORT_LENGTH       3
#define _HEADER              4
#define _SKIP_BLOCK          5
#define _HEAD_SEP            6
#define _COLUMNS             7
#define _LINE_COUNTER        8
#define _GROUP_EXP           9
#define _GROUP_HEADER       10
#define _GROUP_EJECT        11
#define _GROUP_CARGO        12
#define _SUB_GROUP_EXP      13
#define _SUB_GROUP_HEADER   14
#define _SUB_GROUP_EJECT    15
#define _SUB_GROUP_CARGO    16
#define _FOOTING            17

/**************

  Define as variaveis particulares

*/

#xtranslate .<Object>:cargo        => <Object>\[ _CARGO            ]
#xtranslate .<Object>:pageCounter  => <Object>\[ _PAGE_COUNTER     ]
#xtranslate .<Object>:lineCounter  => <Object>\[ _LINE_COUNTER     ]
#xtranslate .<Object>:reportLength => <Object>\[ _REPORT_LENGTH    ]
#xtranslate .<Object>:headSep      => <Object>\[ _HEAD_SEP         ]
#xtranslate .<Object>:header       => <Object>\[ _HEADER           ]
#xtranslate .<Object>:skipBlock    => <Object>\[ _SKIP_BLOCK       ]
#xtranslate .<Object>:columns      => <Object>\[ _COLUMNS          ]
#xtranslate .<Object>:groupExp     => <Object>\[ _GROUP_EXP        ]
#xtranslate .<Object>:groupHeader  => <Object>\[ _GROUP_HEADER     ]
#xtranslate .<Object>:groupEject   => <Object>\[ _GROUP_EJECT      ]
#xtranslate .<Object>:groupCargo   => <Object>\[ _GROUP_CARGO      ]
#xtranslate .<Object>:subExp       => <Object>\[ _SUB_GROUP_EXP    ]
#xtranslate .<Object>:subHeader    => <Object>\[ _SUB_GROUP_HEADER ]
#xtranslate .<Object>:subEject     => <Object>\[ _SUB_GROUP_EJECT  ]
#xtranslate .<Object>:subCargo     => <Object>\[ _SUB_GROUP_CARGO  ]
#xtranslate .<Object>:rodape       => <Object>\[ _FOOTING          ]

/**************

  Define os Metodos da classe Report

*/

#xtranslate .<Object>:addColumn( <oColumn> )   => ;
           addColumn( <Object>, <oColumn> )

#xtranslate .<Object>:stabilize()  => stabilize ( <Object> )

#xtranslate .<Object>:cabecalho()  => cabecalho ( <Object> )

/**************

  END RepClass.CH

*/
