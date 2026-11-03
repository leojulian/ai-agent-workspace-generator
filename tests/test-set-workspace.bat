@echo off
setlocal EnableExtensions
for %%I in ("%~dp0..") do set "ROOT=%%~fI"
set "CASE_DIR=%TEMP%\aawt-generator-%RANDOM%-%RANDOM%"
set "TOOL_DIR=%CASE_DIR%\tool"
set "WORKSPACE_PARENT=%CASE_DIR%\workspaces"
set "STAGE=copy tool"
mkdir "%TOOL_DIR%" || exit /b 1
copy /y "%ROOT%\set-workspace.bat" "%TOOL_DIR%\set-workspace.bat" >nul || goto :fail
xcopy /e /i /q /y "%ROOT%\templates" "%TOOL_DIR%\templates" >nul || goto :fail

set "STAGE=invoke initial generator"
call "%TOOL_DIR%\set-workspace.bat" "%WORKSPACE_PARENT%" "workspace-one" >nul || goto :fail
set "TARGET=%WORKSPACE_PARENT%\workspace-one"
set "STAGE=required generated files"
for %%F in (AGENTS.md AGENTS.local.md .env set-env.bat) do (
	if not exist "%TARGET%\%%F" goto :fail
)
set "STAGE=excluded generated files"
for %%F in (set-env.sh .gitignore README.md README.en.md CLAUDE.md GEMINI.md AGENTS.cn.md AGENTS.local.cn.md CLAUDE.cn.md GEMINI.cn.md) do (
	if exist "%TARGET%\%%F" goto :fail
)
if exist "%TARGET%\.git" goto :fail
set "STAGE=generated env content"
%SystemRoot%\System32\findstr.exe /b /c:"OPENAI_API_KEY=" "%TARGET%\.env" >nul || goto :fail
%SystemRoot%\System32\findstr.exe /b /c:"ANTHROPIC_API_KEY=" "%TARGET%\.env" >nul || goto :fail
%SystemRoot%\System32\findstr.exe /b /c:"GEMINI_API_KEY=" "%TARGET%\.env" >nul || goto :fail

set "STAGE=preserve existing files"
>"%TARGET%\AGENTS.local.md" echo LOCAL_SENTINEL
>"%TARGET%\.env" echo TEST_KEY=TEST_ONLY_SENTINEL
mkdir "%TARGET%\project-a" || goto :fail
>"%TARGET%\CLAUDE.md" echo EXISTING_CLAUDE_SENTINEL
>"%TARGET%\GEMINI.md" echo EXISTING_GEMINI_SENTINEL
call "%TOOL_DIR%\set-workspace.bat" "%WORKSPACE_PARENT%" "workspace-one" >"%CASE_DIR%\repeat-output.txt" || goto :fail
%SystemRoot%\System32\findstr.exe /x /c:"LOCAL_SENTINEL" "%TARGET%\AGENTS.local.md" >nul || goto :fail
%SystemRoot%\System32\findstr.exe /x /c:"TEST_KEY=TEST_ONLY_SENTINEL" "%TARGET%\.env" >nul || goto :fail
if not exist "%TARGET%\project-a" goto :fail
%SystemRoot%\System32\findstr.exe /x /c:"EXISTING_CLAUDE_SENTINEL" "%TARGET%\CLAUDE.md" >nul || goto :fail
%SystemRoot%\System32\findstr.exe /x /c:"EXISTING_GEMINI_SENTINEL" "%TARGET%\GEMINI.md" >nul || goto :fail
%SystemRoot%\System32\findstr.exe /c:"[notice] Existing AGENTS.md was preserved." "%CASE_DIR%\repeat-output.txt" >nul || goto :fail
%SystemRoot%\System32\findstr.exe /c:"[notice] Verify that it loads AGENTS.local.md and nearer project-level AGENTS.md files." "%CASE_DIR%\repeat-output.txt" >nul || goto :fail

set "STAGE=interactive generation"
>"%CASE_DIR%\interactive-input.txt" (
	echo %WORKSPACE_PARENT%
	echo interactive-workspace
)
call "%TOOL_DIR%\set-workspace.bat" <"%CASE_DIR%\interactive-input.txt" >nul || goto :fail
if not exist "%WORKSPACE_PARENT%\interactive-workspace\set-env.bat" goto :fail
call "%TOOL_DIR%\set-workspace.bat" "%WORKSPACE_PARENT%" "workspace with spaces" >nul || goto :fail
if not exist "%WORKSPACE_PARENT%\workspace with spaces\set-env.bat" goto :fail

set "STAGE=invalid name"
call "%TOOL_DIR%\set-workspace.bat" "%WORKSPACE_PARENT%" "..\escape" >nul 2>&1
if not errorlevel 1 goto :fail
set "STAGE=too many arguments"
call "%TOOL_DIR%\set-workspace.bat" "%WORKSPACE_PARENT%" "too-many" "en" "extra" >nul 2>&1
if not errorlevel 1 goto :fail
if exist "%WORKSPACE_PARENT%\too-many" goto :fail

set "STAGE=default language after missing answer"
for %%F in (AGENTS.md AGENTS.local.md) do (
    fc /b "%WORKSPACE_PARENT%\interactive-workspace\%%F" "%TOOL_DIR%\templates\common\%%F" >nul
    if errorlevel 1 goto :fail
)
set "STAGE=zh-CN rule documents"
call "%TOOL_DIR%\set-workspace.bat" "%WORKSPACE_PARENT%" "workspace-zh" "zh-CN" >nul || goto :fail
for %%F in (AGENTS.md AGENTS.local.md) do (
    fc /b "%WORKSPACE_PARENT%\workspace-zh\%%F" "%TOOL_DIR%\templates\common\%%~nF.cn.md" >nul
    if errorlevel 1 goto :fail
    fc /b "%WORKSPACE_PARENT%\workspace-zh\%%F" "%TOOL_DIR%\templates\common\%%F" >nul
    if not errorlevel 1 goto :fail
)
%SystemRoot%\System32\findstr.exe /c:"AGENTS.local.md" "%WORKSPACE_PARENT%\workspace-zh\AGENTS.md" >nul || goto :fail
%SystemRoot%\System32\findstr.exe /c:"git rebase" "%WORKSPACE_PARENT%\workspace-zh\AGENTS.md" >nul || goto :fail
%SystemRoot%\System32\findstr.exe /c:"## 1. Scope and rule loading" "%WORKSPACE_PARENT%\workspace-zh\AGENTS.md" >nul && goto :fail
for %%F in (CLAUDE.md GEMINI.md) do (
    if exist "%WORKSPACE_PARENT%\workspace-zh\%%F" goto :fail
)
set "STAGE=zh-CN language alias"
call "%TOOL_DIR%\set-workspace.bat" "%WORKSPACE_PARENT%" "workspace-zh-alias" "zh" >nul || goto :fail
fc /b "%WORKSPACE_PARENT%\workspace-zh-alias\AGENTS.md" "%TOOL_DIR%\templates\common\AGENTS.cn.md" >nul
if errorlevel 1 goto :fail
set "STAGE=explicit English"
call "%TOOL_DIR%\set-workspace.bat" "%WORKSPACE_PARENT%" "workspace-en" "en" >nul || goto :fail
fc /b "%WORKSPACE_PARENT%\workspace-en\AGENTS.md" "%TOOL_DIR%\templates\common\AGENTS.md" >nul
if errorlevel 1 goto :fail
%SystemRoot%\System32\findstr.exe /c:"## 1. Scope and rule loading" "%WORKSPACE_PARENT%\workspace-en\AGENTS.md" >nul || goto :fail
set "STAGE=interactive zh-CN"
>"%CASE_DIR%\interactive-zh-input.txt" (
    echo %WORKSPACE_PARENT%
    echo interactive-zh
    echo zh-CN
)
call "%TOOL_DIR%\set-workspace.bat" <"%CASE_DIR%\interactive-zh-input.txt" >nul || goto :fail
fc /b "%WORKSPACE_PARENT%\interactive-zh\AGENTS.md" "%TOOL_DIR%\templates\common\AGENTS.cn.md" >nul
if errorlevel 1 goto :fail
set "STAGE=empty language defaults to English"
call "%TOOL_DIR%\set-workspace.bat" "%WORKSPACE_PARENT%" "workspace-empty-language" "" >"%CASE_DIR%\empty-language-output.txt" || goto :fail
for %%F in (AGENTS.md AGENTS.local.md) do (
    fc /b "%WORKSPACE_PARENT%\workspace-empty-language\%%F" "%TOOL_DIR%\templates\common\%%F" >nul
    if errorlevel 1 goto :fail
)
%SystemRoot%\System32\findstr.exe /c:"[language] rule documents: en" "%CASE_DIR%\empty-language-output.txt" >nul || goto :fail
set "STAGE=language metacharacters are not executed"
call "%TOOL_DIR%\set-workspace.bat" "%WORKSPACE_PARENT%" "bad-metacharacters" "invalid&echo AAWT_LANGUAGE_INJECTION&rem" >"%CASE_DIR%\metacharacters-output.txt" 2>&1
if not "%errorlevel%"=="2" goto :fail
if exist "%WORKSPACE_PARENT%\bad-metacharacters" goto :fail
%SystemRoot%\System32\findstr.exe /x /c:"AAWT_LANGUAGE_INJECTION" "%CASE_DIR%\metacharacters-output.txt" >nul
if not errorlevel 1 goto :fail
%SystemRoot%\System32\findstr.exe /c:"[failed] unsupported rule language: invalid&echo AAWT_LANGUAGE_INJECTION&rem" "%CASE_DIR%\metacharacters-output.txt" >nul || goto :fail
set "STAGE=interactive language metacharacters are not executed"
>"%CASE_DIR%\interactive-metacharacters-input.txt" (
    echo %WORKSPACE_PARENT%
    echo interactive-metacharacters
    echo invalid^&echo AAWT_LANGUAGE_INJECTION^&rem
    echo en
)
call "%TOOL_DIR%\set-workspace.bat" <"%CASE_DIR%\interactive-metacharacters-input.txt" >"%CASE_DIR%\interactive-metacharacters-output.txt" 2>&1 || goto :fail
%SystemRoot%\System32\findstr.exe /x /c:"AAWT_LANGUAGE_INJECTION" "%CASE_DIR%\interactive-metacharacters-output.txt" >nul
if not errorlevel 1 goto :fail
%SystemRoot%\System32\findstr.exe /c:"[failed] unsupported rule language: invalid&echo AAWT_LANGUAGE_INJECTION&rem" "%CASE_DIR%\interactive-metacharacters-output.txt" >nul || goto :fail
fc /b "%WORKSPACE_PARENT%\interactive-metacharacters\AGENTS.md" "%TOOL_DIR%\templates\common\AGENTS.md" >nul
if errorlevel 1 goto :fail
for %%C in (eof unterminated blank) do (
    set "STAGE=invalid language then %%C"
    >"%CASE_DIR%\invalid-%%C-input.txt" (
        echo %CASE_DIR%\invalid-parent-%%C
        echo invalid-workspace
    )
    if "%%C"=="unterminated" (
        <nul set /p "=klingon" >>"%CASE_DIR%\invalid-%%C-input.txt"
    ) else (
        >>"%CASE_DIR%\invalid-%%C-input.txt" echo klingon
    )
    if "%%C"=="blank" (
        >>"%CASE_DIR%\invalid-%%C-input.txt" echo.
        >>"%CASE_DIR%\invalid-%%C-input.txt" echo zh-CN
    )
    call "%TOOL_DIR%\set-workspace.bat" <"%CASE_DIR%\invalid-%%C-input.txt" >"%CASE_DIR%\invalid-%%C-output.txt" 2>&1
    if not errorlevel 2 goto :fail
    if errorlevel 3 goto :fail
    if exist "%CASE_DIR%\invalid-parent-%%C" goto :fail
    %SystemRoot%\System32\findstr.exe /l /c:"[ready]" /c:"[created]" "%CASE_DIR%\invalid-%%C-output.txt" >nul
    if not errorlevel 1 goto :fail
)
set "STAGE=corrected language without final newline"
>"%CASE_DIR%\corrected-input.txt" (
    echo %WORKSPACE_PARENT%
    echo corrected-language
    echo klingon
)
<nul set /p "=zh-CN" >>"%CASE_DIR%\corrected-input.txt"
call "%TOOL_DIR%\set-workspace.bat" <"%CASE_DIR%\corrected-input.txt" >nul || goto :fail
fc /b "%WORKSPACE_PARENT%\corrected-language\AGENTS.md" "%TOOL_DIR%\templates\common\AGENTS.cn.md" >nul
if errorlevel 1 goto :fail
set "STAGE=unsupported language"
call "%TOOL_DIR%\set-workspace.bat" "%WORKSPACE_PARENT%" "bad-language" "klingon" >nul 2>&1
if not errorlevel 1 goto :fail
if exist "%WORKSPACE_PARENT%\bad-language" goto :fail
set "STAGE=missing zh-CN template"
del "%TOOL_DIR%\templates\common\AGENTS.local.cn.md" || goto :fail
call "%TOOL_DIR%\set-workspace.bat" "%WORKSPACE_PARENT%" "missing-zh" "zh-CN" >nul 2>&1
if not errorlevel 1 goto :fail
if exist "%WORKSPACE_PARENT%\missing-zh" goto :fail
call "%TOOL_DIR%\set-workspace.bat" "%WORKSPACE_PARENT%" "missing-zh-en" >nul || goto :fail
if not exist "%WORKSPACE_PARENT%\missing-zh-en\AGENTS.local.md" goto :fail

set "STAGE=missing template"
del "%TOOL_DIR%\templates\common\AGENTS.md" || goto :fail
call "%TOOL_DIR%\set-workspace.bat" "%WORKSPACE_PARENT%" "missing-template" >nul 2>&1
if not errorlevel 1 goto :fail
if exist "%WORKSPACE_PARENT%\missing-template" goto :fail

rmdir /s /q "%CASE_DIR%"
echo [PASS] Windows workspace generator
exit /b 0

:fail
if exist "%CASE_DIR%" rmdir /s /q "%CASE_DIR%"
echo [FAIL] Windows workspace generator: %STAGE%
exit /b 1
