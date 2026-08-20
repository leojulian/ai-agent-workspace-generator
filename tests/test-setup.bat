@echo off
setlocal EnableExtensions
for %%I in ("%~dp0..") do set "ROOT=%%~fI"
set "CASE_DIR=%TEMP%\aawt-setup-%RANDOM%-%RANDOM%"
mkdir "%CASE_DIR%" || exit /b 1
copy /y "%ROOT%\setup-workspace.bat" "%CASE_DIR%\setup-workspace.bat" >nul || goto :fail
copy /y "%ROOT%\AGENTS.local.example.md" "%CASE_DIR%\AGENTS.local.example.md" >nul || goto :fail
copy /y "%ROOT%\.env.example" "%CASE_DIR%\.env.example" >nul || goto :fail

call "%CASE_DIR%\setup-workspace.bat" >nul || goto :fail
if not exist "%CASE_DIR%\AGENTS.local.md" goto :fail
if not exist "%CASE_DIR%\.env" goto :fail
>"%CASE_DIR%\AGENTS.local.md" echo LOCAL_SENTINEL
>"%CASE_DIR%\.env" echo TEST_KEY=TEST_ONLY_SENTINEL
call "%CASE_DIR%\setup-workspace.bat" >nul || goto :fail
%SystemRoot%\System32\findstr.exe /x /c:"LOCAL_SENTINEL" "%CASE_DIR%\AGENTS.local.md" >nul || goto :fail
%SystemRoot%\System32\findstr.exe /x /c:"TEST_KEY=TEST_ONLY_SENTINEL" "%CASE_DIR%\.env" >nul || goto :fail
del "%CASE_DIR%\.env.example"
call "%CASE_DIR%\setup-workspace.bat" >nul 2>&1 && goto :fail

rmdir /s /q "%CASE_DIR%"
echo [PASS] Workspace setup
exit /b 0

:fail
if exist "%CASE_DIR%" rmdir /s /q "%CASE_DIR%"
echo [FAIL] Workspace setup
exit /b 1
