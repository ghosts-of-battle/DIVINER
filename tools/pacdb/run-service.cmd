@echo off
rem Starts the pacdb service on http://127.0.0.1:8085 - the HTTP front for the
rem database that pac_sync.py and push_config.py talk to. The game never does;
rem see README.md. Build first:  dotnet publish -c Release -o out  (in tools\pacdb\service)
rem
rem NOTHING SECRET IS IN A FILE. The machine's environment carries it:
rem   GHOSTD_MONGO       the MongoDB connection string
rem   GHOSTD_PACDB_KEY   the API key the tools must present (may be empty on loopback)
rem Set them once with:  setx GHOSTD_MONGO "mongodb+srv://..."   setx GHOSTD_PACDB_KEY "..."
if "%GHOSTD_MONGO%"=="" (echo GHOSTD_MONGO is not set - see the comment in this file & exit /b 1)
set Mongo__ConnectionString=%GHOSTD_MONGO%
set ApiKey=%GHOSTD_PACDB_KEY%
set Store=mongo
cd /d "%~dp0service\out" || (echo service not built - see README.md & exit /b 1)
dotnet pacdb-service.dll
