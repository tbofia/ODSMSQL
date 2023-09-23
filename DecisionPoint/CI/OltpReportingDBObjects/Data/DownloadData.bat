@echo off

REM determine if they are using NT authentication or not
if "%3"=="nt" goto USING_NT_AUTH
if "%3"=="NT" goto USING_NT_AUTH

goto USING_SQL_AUTH

:USING_NT_AUTH
set unameparm_=/T
set pwdparm_=
goto SET_DB

:USING_SQL_AUTH
set unameparm_=/U%3
set pwdparm_=/P%4

:SET_DB
set database_=%5

ECHO Creating rpt.DataExtractType.txt
bcp %database_%.rpt.DataExtractType out %1rpt.DataExtractType.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating rpt.PostingGroup.txt
bcp %database_%.rpt.PostingGroup out %1rpt.PostingGroup.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating rpt.PostingGroupProcess.txt
bcp %database_%.rpt.PostingGroupProcess out %1rpt.PostingGroupProcess.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating rpt.Process.txt
bcp %database_%.rpt.Process out %1rpt.Process.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating rpt.ProcessStep.txt
bcp %database_%.rpt.ProcessStep out %1rpt.ProcessStep.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating rpt.Product.txt
bcp %database_%.rpt.Product out %1rpt.Product.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating rpt.StatusCode.txt
bcp %database_%.rpt.StatusCode out %1rpt.StatusCode.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating rpt.TargetPlatformDropLocation.txt
bcp %database_%.rpt.TargetPlatformDropLocation out %1rpt.TargetPlatformDropLocation.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

