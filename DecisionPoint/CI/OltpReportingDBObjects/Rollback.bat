@ECHO OFF

REM make sure they sent in the first three parameters
if "x%1"=="x" goto SHOW_INSTRUCTIONS
if "x%2"=="x" goto SHOW_INSTRUCTIONS
if "x%3"=="x" goto NO_BLANK_PASSWORD

REM determine if they are using NT authentication or not
if "%2"=="nt" goto USING_NT_AUTH
if "%2"=="NT" goto USING_NT_AUTH


goto USING_SQL_AUTH

:USING_NT_AUTH
set unameparam_=/E
set pwdparam_=
goto CHECK_DB

:USING_SQL_AUTH
set unameparam_=/U%2
set pwdparam_=/P%3

:CHECK_DB

REM determine the database they are writing to
if "%4"=="" goto USEMMEDICAL
set database_=%4
set outfile_="%TEMP%"\mmedisql_%4.log
goto SKIPMMEDICAL
:USEMMEDICAL
set database_=mmedical
set outfile_="%TEMP%"\mmedisql_DM.log
:SKIPMMEDICAL

REM set directory locations for working schema/data
set workingpath_=_working\
REM set himworkingpathfh_=_working\Fair Health\
REM set himworkingpathmain_=_working\Main\

REM let's verify the user's login info before proceeding
ECHO Checking login credentials...
ECHO Checking login credentials... >> %outfile_%
SET verified_= 0
FOR /F "tokens=1" %%A IN ('sqlcmd -S %1 %unameparam_% %pwdparam_% -Q "SET NOCOUNT ON; SELECT 1" ^| FIND "1"' ) DO SET verified_=%%A

if NOT %verified_% == 1 (
	ECHO.
	ECHO I couldn't successfully log you into the SQL Server.  Please verify your server/login/password information and try again.
	ECHO I couldn't successfully log you into the SQL Server.  Please verify your server/login/password information and try again. >> %outfile_%
	GOTO END
)

CD Rollback 

ECHO Disable Change Tracking for those newly added tables
ECHO Disable Change Tracking for those newly added tables >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i DisableChangeTracking.sql >> %outfile_%

ECHO Dropping all foreign keys
ECHO Dropping all foreign keys >> %outfile_%
			
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i ForeignKeys\fkdropall.sql >> %outfile_%

ECHO Dropping static dev tables
ECHO Dropping static dev tables >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i Tables\tbldrop.sql >> %outfile_%

ECHO Creating static dev tables
ECHO Creating static dev tables >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i Tables\tblstat.sql >> %outfile_%

ECHO Inserting Dev Data
ECHO Inserting Dev Data >> %outfile_%

call data\data.bat data\ %1 %2 %3 %database_% %5  


ECHO Creating static dev indexes... 
ECHO Creating static dev indexes... >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i Indexes\idxstat.sql >> %outfile_%

ECHO Creating static dev foreign keys
ECHO Creating static dev foreign keys >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i ForeignKeys\fkstat.sql >> %outfile_%

ECHO Creating dynamic foreign keys 
ECHO Creating dynamic foreign keys >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i ForeignKeys\fkdyn.sql >> %outfile_%
																								 

ECHO Creating dynamic stored procedures 
ECHO Creating dynamic stored procedures  >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i StoredProcedures\spdyn.sql >> %outfile_%

ECHO Reverting all db Object changes...
ECHO Reverting all db Object Changes... >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i Revert_db_Object_Changes.sql >> %outfile_%

ECHO Reverting to old App Version
ECHO Reverting to old App Version >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i SetPriorAppVersion.sql >> %outfile_%


ECHO Installation finished.  Please check %TEMP%\data_%4.log and %outfile_% for any error messages
ECHO Installation finished. >> %outfile_%
goto END

:SHOW_INSTRUCTIONS
echo Send in the name of the server, the user name, and the password
echo as arguments.  You can optionally send in the database name as the fourth argument.
echo ...
echo Example:  install MedServer sa admin mmedical
echo ...
goto END

:NO_BLANK_PASSWORD
echo You must specify a password.  Blank passwords are not accepted
goto END

:DATABASE_NOT_EXISTS
ECHO ERROR: %database_% db creation failed!
ECHO ERROR: %database_% db creation failed! >> %outfile_%

:END