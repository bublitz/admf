/***
* Combo.ch
*
* Defini‡ao  @ ... GET COMBO.
*/

#command @ <row>, <col> GET <var>                                   ;
                        [PICT <picture>]                            ;
                        COMBO <drops>                               ;
                        [VALID <valid>]                             ;
                        [WHEN  <when>]                              ;
                        [COLOR <color>]                             ;
      =>                                                            ;
         SetPos(<row>, <col>)                                       ;
         ; Aadd(GetList,                                            ;
              ComboGetNew({|x| iif(x == NIL, <var>, <var> := x) },  ;
                          <(var)>, <drops>, <{valid}>,              ; 
                          <picture>, <{when}>, <color> ))
