@echo off
setlocal enabledelayedexpansion

rem General parameters
set PGPASSWORD=qwerty
set PGUSER=postgres
set PGHOST=localhost
set PGPORT=5432
set PG_DUMP="C:\Program Files\PostgreSQL\XX\bin\pg_dump.exe"
set BACKUP_DIR=D:\backups_actual
set DATE=%DATE:~0,2%%DATE:~3,2%%DATE:~-4%
set LOG=%BACKUP_DIR%\log_%DATE%.txt

rem Deleting old backups (older than 7 days)
forfiles /p "%BACKUP_DIR%" /m *.backup /D -7 /C "cmd /c del /q @path"

rem Creating a directory for storing backups, if there is none
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

rem List of databases
set DATABASES=name_base name_base2

rem Database backup
for %%D in (%DATABASES%) do (
    set "PGDATABASE=%%D"
    set "FILENAME=%BACKUP_DIR%\backup_%%D_%DATE%.backup"
    %PG_DUMP% -U %PGUSER% -h %PGHOST% -p %PGPORT% -F c -b -v -f "!FILENAME!" "!PGDATABASE!"
    if !errorlevel! == 0 (
        echo Backup of !PGDATABASE! completed successfully on %DATE%. >> "!LOG!"
    ) else (
        echo Backup of !PGDATABASE! failed on %DATE%. >> "!LOG!"
    )
)

rem Completion
echo All backups completed. >> "!LOG!"