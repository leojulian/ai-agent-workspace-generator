@echo off
rem Do not use setlocal: loaded variables must remain in the current cmd.exe.
if not "%~1"=="" (
    echo [failed] set-env.bat does not accept arguments
    exit /b 2
)

set "AAWT_INTERNAL_ROOT=%~dp0"
set "AAWT_INTERNAL_FILE=%~dp0.env"
set "AAWT_INTERNAL_INVALID_LINE="
set "AAWT_INTERNAL_COUNT=0"

if not exist "%AAWT_INTERNAL_FILE%" goto :missing

for /f "tokens=1 delims=:" %%N in ('%SystemRoot%\System32\findstr.exe /n /v /r /c:"^$" /c:"^#.*$" /c:"^[A-Za-z_][A-Za-z0-9_]*=[A-Za-z0-9._~:/?@+,=-]*$" "%AAWT_INTERNAL_FILE%"') do (
    if not defined AAWT_INTERNAL_INVALID_LINE set "AAWT_INTERNAL_INVALID_LINE=%%N"
)
if defined AAWT_INTERNAL_INVALID_LINE goto :invalid

for /f "tokens=1 delims=:" %%N in ('%SystemRoot%\System32\findstr.exe /n /b /c:"AAWT_INTERNAL_" "%AAWT_INTERNAL_FILE%"') do (
    if not defined AAWT_INTERNAL_INVALID_LINE set "AAWT_INTERNAL_INVALID_LINE=%%N"
)
if defined AAWT_INTERNAL_INVALID_LINE goto :invalid

for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%AAWT_INTERNAL_FILE%") do (
    set "%%A=%%B"
    set /a AAWT_INTERNAL_COUNT+=1 >nul
)

echo [loaded] %AAWT_INTERNAL_COUNT% environment variables
set "AAWT_INTERNAL_ROOT="
set "AAWT_INTERNAL_FILE="
set "AAWT_INTERNAL_INVALID_LINE="
set "AAWT_INTERNAL_COUNT="
exit /b 0

:missing
echo [failed] .env not found; run setup-workspace.bat first
set "AAWT_INTERNAL_ROOT="
set "AAWT_INTERNAL_FILE="
set "AAWT_INTERNAL_INVALID_LINE="
set "AAWT_INTERNAL_COUNT="
exit /b 1

:invalid
echo [failed] invalid dotenv syntax at line %AAWT_INTERNAL_INVALID_LINE%
set "AAWT_INTERNAL_ROOT="
set "AAWT_INTERNAL_FILE="
set "AAWT_INTERNAL_INVALID_LINE="
set "AAWT_INTERNAL_COUNT="
exit /b 2
