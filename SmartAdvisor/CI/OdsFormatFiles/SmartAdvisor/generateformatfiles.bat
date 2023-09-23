REM Syntax: generateformatfiles.bat <servername> NT NT <databasename> <ODS_Version>

@echo off

REM determine if they are using NT authentication or not
if "%2"=="nt" goto USING_NT_AUTH
if "%2"=="NT" goto USING_NT_AUTH

goto USING_SQL_AUTH

:USING_NT_AUTH
set unameparm_=/T
set osqlunameparm_=-E
set pwdparm_=
goto SET_DB

:USING_SQL_AUTH
set unameparm_=/U%2
set pwdparm_=/P%3

:SET_DB
set database_=%4
set server_=%1
set formatfilespath_=%cd%^\
set odsversion_=%5
set formatfiledir_=%formatfilespath_%%5

REM If the format file directory does not exist create it.
If not exist %formatfiledir_% (md %formatfiledir_%)

REM this script is set up to use the environment variables to generate the format files
REM -h-1 removes column names and lines underneath then in sql output
sqlcmd -S %server_% -i build_bcp_scripts.sql -o output_bcp_scripts.bat -h -1

REM Execute the bcp scripts generated
output_bcp_scripts.bat

REM Delete the bcp script file
del output_bcp_scripts.bat



