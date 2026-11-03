@echo off
setlocal EnableExtensions DisableDelayedExpansion
set "AAWT_INTERNAL_ROOT=%~dp0"
set "AAWT_INTERNAL_FAILED=0"
set "AAWT_INTERNAL_RULES_PREFIX=templates\common\"

if "%~1"=="" goto :interactive
if "%~2"=="" goto :usage
if not "%~4"=="" goto :usage
set "AAWT_INTERNAL_PARENT=%~1"
set "AAWT_INTERNAL_NAME=%~2"
set "AAWT_INTERNAL_LANGUAGE=%~3"
if not defined AAWT_INTERNAL_LANGUAGE set "AAWT_INTERNAL_LANGUAGE=en"
call :normalize_language
if errorlevel 1 exit /b 2
goto :validate

:interactive
if not "%~2"=="" goto :usage
set /p "AAWT_INTERNAL_PARENT=Workspace parent directory: "
set /p "AAWT_INTERNAL_NAME=Workspace name: "
set "AAWT_INTERNAL_LANGUAGE_REQUIRED=0"

:prompt_language
set "AAWT_INTERNAL_LANGUAGE="
if "%AAWT_INTERNAL_LANGUAGE_REQUIRED%"=="1" (
    set /p "AAWT_INTERNAL_LANGUAGE=Rule documents language [en/zh-CN]: "
) else (
    set /p "AAWT_INTERNAL_LANGUAGE=Rule documents language [en/zh-CN] (en): "
)
if not defined AAWT_INTERNAL_LANGUAGE (
    if "%AAWT_INTERNAL_LANGUAGE_REQUIRED%"=="1" (
        echo [failed] rule language is required after an unsupported value
        exit /b 2
    )
    set "AAWT_INTERNAL_LANGUAGE=en"
)
call :normalize_language
if not errorlevel 1 goto :validate
set "AAWT_INTERNAL_LANGUAGE_REQUIRED=1"
goto :prompt_language

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

call :require_template "%AAWT_INTERNAL_RULES_PREFIX%AGENTS%AAWT_INTERNAL_RULES_SUFFIX%.md"
call :require_template "%AAWT_INTERNAL_RULES_PREFIX%AGENTS.local%AAWT_INTERNAL_RULES_SUFFIX%.md"
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

call :copy_if_missing "%AAWT_INTERNAL_RULES_PREFIX%AGENTS%AAWT_INTERNAL_RULES_SUFFIX%.md" "AGENTS.md"
call :copy_if_missing "%AAWT_INTERNAL_RULES_PREFIX%AGENTS.local%AAWT_INTERNAL_RULES_SUFFIX%.md" "AGENTS.local.md"
call :copy_if_missing "templates\common\env.template" ".env"
call :copy_if_missing "templates\windows\set-env.bat" "set-env.bat"
if "%AAWT_INTERNAL_FAILED%"=="0" (
    if "%AAWT_INTERNAL_EXISTING_AGENTS%"=="1" (
        echo [notice] Existing AGENTS.md was preserved.
        echo [notice] Verify that it loads AGENTS.local.md and nearer project-level AGENTS.md files.
    )
    echo [language] rule documents: %AAWT_INTERNAL_LANGUAGE%
    echo [ready] workspace: %AAWT_INTERNAL_TARGET%
)
exit /b %AAWT_INTERNAL_FAILED%

:normalize_language
rem Delayed expansion keeps language input from being parsed as cmd syntax.
setlocal EnableDelayedExpansion
if /i "!AAWT_INTERNAL_LANGUAGE!"=="en" goto :normalize_language_en
if /i "!AAWT_INTERNAL_LANGUAGE!"=="en-us" goto :normalize_language_en
if /i "!AAWT_INTERNAL_LANGUAGE!"=="english" goto :normalize_language_en
if /i "!AAWT_INTERNAL_LANGUAGE!"=="zh" goto :normalize_language_zh
if /i "!AAWT_INTERNAL_LANGUAGE!"=="zh-cn" goto :normalize_language_zh
if /i "!AAWT_INTERNAL_LANGUAGE!"=="zh-hans" goto :normalize_language_zh
if /i "!AAWT_INTERNAL_LANGUAGE!"=="chinese" goto :normalize_language_zh
echo [failed] unsupported rule language: !AAWT_INTERNAL_LANGUAGE! (expected en or zh-CN)
endlocal
exit /b 2

:normalize_language_en
endlocal
set "AAWT_INTERNAL_LANGUAGE=en"
set "AAWT_INTERNAL_RULES_SUFFIX="
exit /b 0

:normalize_language_zh
endlocal
set "AAWT_INTERNAL_LANGUAGE=zh-CN"
set "AAWT_INTERNAL_RULES_SUFFIX=.cn"
exit /b 0

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
echo Usage: %~nx0 [workspace-parent workspace-name [rule-language]]
echo Rule language: en (default) or zh-CN
exit /b 2
