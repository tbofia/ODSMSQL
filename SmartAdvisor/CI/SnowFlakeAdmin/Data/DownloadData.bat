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

ECHO Creating rpt.ProviderAnalyticsETLParameters.txt
bcp %database_%.rpt.ProviderAnalyticsETLParameters out %1ProviderAnalysisReport\rpt.ProviderAnalyticsETLParameters.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating rpt.ProviderAnalyticsCodeHierarchy.txt
bcp %database_%.rpt.ProviderAnalyticsCodeHierarchy out %1ProviderAnalysisReport\rpt.ProviderAnalyticsCodeHierarchy.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating rpt.ProviderAnalyticsCodeMapping.txt
bcp %database_%.rpt.ProviderAnalyticsCodeMapping out %1ProviderAnalysisReport\rpt.ProviderAnalyticsCodeMapping.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating rpt.ProviderAnalyticsPRCodeDataQuality.txt
bcp %database_%.rpt.ProviderAnalyticsPRCodeDataQuality out %1ProviderAnalysisReport\rpt.ProviderAnalyticsPRCodeDataQuality.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating rpt.ProviderAnalyticsZipCode.txt
bcp %database_%.rpt.ProviderAnalyticsZipCode out %1ProviderAnalysisReport\rpt.ProviderAnalyticsZipCode.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating rpt.ProviderAnalyticsZipCodeMSAvCBSA.txt
bcp %database_%.rpt.ProviderAnalyticsZipCodeMSAvCBSA out %1ProviderAnalysisReport\rpt.ProviderAnalyticsZipCodeMSAvCBSA.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating rpt.CustomerReportSubscription.txt
bcp %database_%.rpt.CustomerReportSubscription out %1rpt.CustomerReportSubscription.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 
