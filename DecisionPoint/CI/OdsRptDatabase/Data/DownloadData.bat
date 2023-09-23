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

ECHO Creating adm.Process.txt
bcp %database_%.adm.Process out %1adm.Process.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating adm.ReportCommand.txt
bcp %database_%.adm.ReportCommand out %1adm.ReportCommand.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating adm.ReportJob.txt
bcp %database_%.adm.ReportJob out %1adm.ReportJob.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating adm.ReportParameters.txt
bcp %database_%.adm.ReportParameters out %1adm.ReportParameters.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating rpt.ProviderDataExplorerETLParameters.txt
bcp %database_%.rpt.ProviderDataExplorerETLParameters out %1ProviderDataExplorer\rpt.ProviderDataExplorerETLParameters.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating rpt.ProviderDataExplorerCodeHierarchy.txt
bcp %database_%.rpt.ProviderDataExplorerCodeHierarchy out %1ProviderDataExplorer\rpt.ProviderDataExplorerCodeHierarchy.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating rpt.ProviderDataExplorerCodeMapping.txt
bcp %database_%.rpt.ProviderDataExplorerCodeMapping out %1ProviderDataExplorer\rpt.ProviderDataExplorerCodeMapping.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating rpt.ProviderDataExplorerPRCodeDataQuality.txt
bcp %database_%.rpt.ProviderDataExplorerPRCodeDataQuality out %1ProviderDataExplorer\rpt.ProviderDataExplorerPRCodeDataQuality.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating rpt.ProviderDataExplorerZipCode.txt
bcp %database_%.rpt.ProviderDataExplorerZipCode out %1ProviderDataExplorer\rpt.ProviderDataExplorerZipCode.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating rpt.ProviderDataExplorerZipCodeMSAvCBSA.txt
bcp %database_%.rpt.ProviderDataExplorerZipCodeMSAvCBSA out %1ProviderDataExplorer\rpt.ProviderDataExplorerZipCodeMSAvCBSA.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating rpt.CustomerReportSubscription.txt
bcp %database_%.rpt.CustomerReportSubscription out %1rpt.CustomerReportSubscription.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 
