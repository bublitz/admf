@ECHO OFF
SET CLIPPER=//F:199 //DYNF:8 //SWAPK:65535
REM SET ADM=/M
IF EXIST $REL*.* DEL $REL*.*
ADM3
CLS
TYPE ADM.TXT
