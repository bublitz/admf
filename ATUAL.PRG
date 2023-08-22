use caminhao
replace all marca with strzero(val(marca),3,0),;
            modelo with strzero(val(modelo),3,0),;
            cor with strzero(val(cor),3,0)

use tabela
replace all codigo with strzero(val(codigo),3,0)
            