@ECHO OFF
CLS
IF NOT "%1" == "" GOTO DE
RMAKE ADM
GOTO END
:DE
RMAKE ADM /dDEBUG
:END
