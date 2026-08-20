@echo off
setlocal EnableExtensions
set "AAWT_INTERNAL_ROOT=%~dp0"
set "AAWT_INTERNAL_FAILED=0"

call :copy_if_missing "AGENTS.local.example.md" "AGENTS.local.md"
call :copy_if_missing ".env.example" ".env"
exit /b %AAWT_INTERNAL_FAILED%

:copy_if_missing
if not exist "%AAWT_INTERNAL_ROOT%%~1" (
    echo [failed] missing template: %~1
    set "AAWT_INTERNAL_FAILED=1"
    exit /b 0
)
if exist "%AAWT_INTERNAL_ROOT%%~2" (
    echo [skipped] %~2 already exists
    exit /b 0
)
copy /y "%AAWT_INTERNAL_ROOT%%~1" "%AAWT_INTERNAL_ROOT%%~2" >nul
if errorlevel 1 (
    echo [failed] could not create: %~2
    set "AAWT_INTERNAL_FAILED=1"
) else (
    echo [created] %~2
)
exit /b 0
