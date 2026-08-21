@echo off
setlocal EnableExtensions
set "AAWT_INTERNAL_ROOT=%~dp0"
set "AAWT_INTERNAL_FAILED=0"

if "%~1"=="" goto :interactive
if "%~2"=="" goto :usage
if not "%~3"=="" goto :usage
set "AAWT_INTERNAL_PARENT=%~1"
set "AAWT_INTERNAL_NAME=%~2"
goto :validate

:interactive
if not "%~2"=="" goto :usage
set /p "AAWT_INTERNAL_PARENT=Workspace parent directory: "
set /p "AAWT_INTERNAL_NAME=Workspace name: "

:validate
if not defined AAWT_INTERNAL_PARENT (
    echo [failed] workspace parent directory must not be empty
    exit /b 2
)
if not defined AAWT_INTERNAL_NAME goto :invalid_name
if "%AAWT_INTERNAL_NAME%"=="." goto :invalid_name
if "%AAWT_INTERNAL_NAME%"==".." goto :invalid_name
if not "%AAWT_INTERNAL_NAME:\=%"=="%AAWT_INTERNAL_NAME%" goto :invalid_name
if not "%AAWT_INTERNAL_NAME:/=%"=="%AAWT_INTERNAL_NAME%" goto :invalid_name

call :require_template "templates\common\AGENTS.md"
call :require_template "templates\common\AGENTS.local.md"
call :require_template "templates\common\CLAUDE.md"
call :require_template "templates\common\GEMINI.md"
call :require_template "templates\common\env.template"
call :require_template "templates\windows\set-env.bat"
if not "%AAWT_INTERNAL_FAILED%"=="0" exit /b 1

set "AAWT_INTERNAL_TARGET=%AAWT_INTERNAL_PARENT%\%AAWT_INTERNAL_NAME%"
set "AAWT_INTERNAL_EXISTING_AGENTS=0"
if exist "%AAWT_INTERNAL_TARGET%\AGENTS.md" set "AAWT_INTERNAL_EXISTING_AGENTS=1"
if not exist "%AAWT_INTERNAL_TARGET%" mkdir "%AAWT_INTERNAL_TARGET%"
if not exist "%AAWT_INTERNAL_TARGET%" (
    echo [failed] could not create workspace: %AAWT_INTERNAL_TARGET%
    exit /b 1
)

call :copy_if_missing "templates\common\AGENTS.md" "AGENTS.md"
call :copy_if_missing "templates\common\AGENTS.local.md" "AGENTS.local.md"
call :copy_if_missing "templates\common\CLAUDE.md" "CLAUDE.md"
call :copy_if_missing "templates\common\GEMINI.md" "GEMINI.md"
call :copy_if_missing "templates\common\env.template" ".env"
call :copy_if_missing "templates\windows\set-env.bat" "set-env.bat"
if "%AAWT_INTERNAL_FAILED%"=="0" (
    if "%AAWT_INTERNAL_EXISTING_AGENTS%"=="1" (
        echo [notice] Existing AGENTS.md was preserved.
        echo [notice] Verify that it loads AGENTS.local.md and nearer project-level AGENTS.md files.
    )
    echo [ready] workspace: %AAWT_INTERNAL_TARGET%
)
exit /b %AAWT_INTERNAL_FAILED%

:require_template
if not exist "%AAWT_INTERNAL_ROOT%%~1" (
    echo [failed] missing template: %~1
    set "AAWT_INTERNAL_FAILED=1"
)
exit /b 0

:copy_if_missing
if exist "%AAWT_INTERNAL_TARGET%\%~2" (
    echo [skipped] %~2 already exists
    exit /b 0
)
copy /y "%AAWT_INTERNAL_ROOT%%~1" "%AAWT_INTERNAL_TARGET%\%~2" >nul
if errorlevel 1 (
    echo [failed] could not create: %~2
    set "AAWT_INTERNAL_FAILED=1"
) else (
    echo [created] %~2
)
exit /b 0

:invalid_name
echo [failed] workspace name must be a single directory name
exit /b 2

:usage
echo Usage: %~nx0 [workspace-parent workspace-name]
exit /b 2
