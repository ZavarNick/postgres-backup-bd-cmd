@echo off
setlocal enabledelayedexpansion

rem Общие параметры
set PGPASSWORD=qwerty
set PGUSER=postgres
set PGHOST=localhost
set PGPORT=5432
set PG_DUMP="C:\Program Files\PostgreSQL\XX\bin\pg_dump.exe"
set BACKUP_DIR=D:\backups_actual
set DATE=%DATE:~0,2%%DATE:~3,2%%DATE:~-4%
set LOG=%BACKUP_DIR%\log_%DATE%.txt

rem Удаление старых бекапов (старше 7 дней)
forfiles /p "%BACKUP_DIR%" /m *.backup /D -7 /C "cmd /c del /q @path"

rem Создание каталога для хранения бекапов, если его нет
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

rem Список баз данных
set DATABASES=name_base name_base2

rem Бекап баз данных
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

rem Завершение
echo All backups completed. >> "!LOG!"