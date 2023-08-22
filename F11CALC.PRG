***************
* Calculadora
*
PROCEDURE CALCULADORA()
MEMVAR C01, C02, X, C1, C2, C3, C4, C5, C6, A, B, R, Y
LOCAL nShadTop    := 4,;
      nShadLeft   := 1,;
      nShadBottom := 21,;
      nShadRight  := 78

C01 := savescreen( 0, 0, 24, 79 )

RESTSCREEN( nShadTop, nShadLeft, nShadBottom, nShadRight,;
            TRANSFORM( SAVESCREEN( nShadTop, nShadLeft, nShadBottom, nShadRight),;
            REPLICATE('X'+CHR(7), ( nShadRight - nShadLeft + 1 ) * ( ( nShadBottom - nShadTop + 1 ) * 2 ) ) ) )

C02 = setcolor()
SETCOLOR("W+/W")
SCROLL(1,58,18,78,0)
@ 1,58 to 18,78 double
//@ 2,59 to 4,77 double
DispBotao( 2, 59, 4, 77, "" )
@ 5,58 say "Ì"+repl("Í",19)+"¹"
@ 3,76 say "0"
a = 0
r = "789/*M456+-R123%EC0.="
//Fcor(2)
for x = 6 to 16 step 3
   for y = 59 to 76 step 3
      if y = 68
         //Fcor(10)
         @ x,y to x+3,y double
         y = 69
      endif
      //Fcor(2)
      a = a + 1
      DispBotao(X,Y,X+2,Y+2,subs(r,a,1))
      //@ x,y to x+2,y+2 double
      //Fcor(3)
      //@ x+1,y+1 say subs(r,a,1)
      //Fcor(2)
   next y
next x
//Fcor(10)
@ 18,68 say "Ê"
@ 5,68 say "Ë"
@ 15,69 to 17,77 //double
//Fcor(3)
@ 16,70 say "Esc=Fim" COLOR "W+/N"
FMENS( "CALCULADORA.              Esc=Encerra." )
for x = 1 to 6
   a = "C"+str(x,1)
   &a. = ""
next x
r = .f.

do while .t.
   b = 0
   a = inkey(0)
*   tone(400+a,1)
   if a = 27
      restscreen( 0, 0, 24, 79, C01 )
      setcolor(C02)
      return
   endif
   if a = 77 .or. a = 109
      c6 = c1
      loop
   endif
   if r = .t.
      c1=""
      r=.f.
   endif
   if (a = 82 .or. a = 114) .and. c1=''
      c1 = c6
   endif
   if a=67 .or. a =99 .or. a=69 .or. a=101
      c1=''
      if a=67 .or. a=99
         c2=''
         tone(700,5)
         c3=''
      endif
      @ 3,60 say '                0'
      loop
   endif
   if a=8 .and. len(c1)>0
      c1 = left(c1,len(c1)-1)
   endif
   if a=46 .and. at(".",c1)#0
      loop
   endif
   if b=61 .and. a>42 .and. a<48
      c2=''
   endif
   if a=37 .and. val(c1)>0 .and. val(c2)>0 .and. c5>")" .and. c5<"."
      c4=str(val(c1))+"*"+str(val(c2))+"/100"
      c4=&c4.
      if c5="+" .or. c5="-"
         c4=str(val(c2))+c5+str(c4)
         c4=&c4.
      endif
      c1=ltrim(str(c4))
      @ 3,60 say space(17-len(c1))+c1
      c2=c1
      r=.t.
      loop
   endif
   if len(c1)=0 .and. a=45 .and. b<>61 .and. b<>13 .and. b<>37 .and. left(c1,1)#"-"
      c1 = "-"+c1
      a=0
   endif
   if a=42 .or. a=43 .or. a=45 .or. a=47 .or. a=61 .or. a=13
      if a=b .and. a<>61 .and. a<>13
         c1=c3
      endif
      if val(c2)#0 .and. val(c1)#0
         c4=str(val(c2))+c5+str(val(c1))
         c4=ltrim(str(&c4.))
         c2=c4
         c1=c4
         if len(c4)>17
            c1="ERRO"
         endif
         @ 3,60 say space(17-len(c1))+c1
      endif
      r=.t.
      if len(c2)=0
         c2=c1
      endif
      if a#61 .and. a#13
         c5=chr(a)
      endif
      loop
   endif
   if a>45 .and. a<58 .and. a#47 .and. len(c1)<17
      c1=c1+chr(a)
   endif
   c3=c1
   if len(c1)>0
      @ 3,60 say space(17-len(c1))+c1
   else
      @ 3,60 say '                0'
   endif
enddo
RETURN