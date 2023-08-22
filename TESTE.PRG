CLS

cS := cC := SPACE(50)

WHILE .T.
   @  5, 5 SAY "STRING: " GET cS
   @ 10, 5 SAY "CHAVE:  " GET cC
   READ
   IF LASTKEY() = 27 ; EXIT ; END
   @ 15, 0
   @ 15, 5 SAY CRYPT( cS, cC ) COLOR "W+/B"
   INKEY(0)
   cS := Pad( CRYPT( cS, cC ), 50 )
END
