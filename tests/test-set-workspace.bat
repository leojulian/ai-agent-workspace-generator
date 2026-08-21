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
for %%F in (AGENTS.md AGENTS.local.md CLAUDE.md GEMINI.md .env set-env.bat) do (
	if not exist "%TARGET%\%%F" goto :fail
)
set "STAGE=excluded generated files"
for %%F in (set-env.sh .gitignore README.md README.en.md) do (
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
call "%TOOL_DIR%\set-workspace.bat" "%WORKSPACE_PARENT%" "workspace-one" >"%CASE_DIR%\repeat-output.txt" || goto :fail
%SystemRoot%\System32\findstr.exe /x /c:"LOCAL_SENTINEL" "%TARGET%\AGENTS.local.md" >nul || goto :fail
%SystemRoot%\System32\findstr.exe /x /c:"TEST_KEY=TEST_ONLY_SENTINEL" "%TARGET%\.env" >nul || goto :fail
if not exist "%TARGET%\project-a" goto :fail
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
