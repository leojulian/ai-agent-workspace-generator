@echo off
setlocal EnableExtensions
for %%I in ("%~dp0..") do set "ROOT=%%~fI"
set "CASE_DIR=%TEMP%\aawt-check-%RANDOM%-%RANDOM%"
mkdir "%CASE_DIR%" || exit /b 1
for %%F in (AGENTS.md AGENTS.local.example.md CLAUDE.md GEMINI.md .env.example .gitignore setup-workspace.bat setup-workspace.sh set-env.bat set-env.sh check-workspace.bat check-workspace.sh) do (
    copy /y "%ROOT%\%%F" "%CASE_DIR%\%%F" >nul || goto :fail
)
>"%CASE_DIR%\README.md" echo # Synthetic test repository
git -C "%CASE_DIR%" init -q || goto :fail
call "%CASE_DIR%\check-workspace.bat" >nul || goto :fail
>"%CASE_DIR%\.env.production" echo TEST_KEY=test-only-value
git -C "%CASE_DIR%" add -f -- .env.production || goto :fail
call "%CASE_DIR%\check-workspace.bat" >nul 2>&1 && goto :fail
git -C "%CASE_DIR%" rm --cached -q -- .env.production || goto :fail
call "%CASE_DIR%\check-workspace.bat" >nul || goto :fail
>>"%CASE_DIR%\.gitignore" echo .env.example
set "TRACKABLE_EXAMPLE=.env.example"
call "%CASE_DIR%\check-workspace.bat" >nul 2>&1 && goto :fail
rmdir /s /q "%CASE_DIR%"
echo [PASS] Windows workspace checker
exit /b 0

:fail
if exist "%CASE_DIR%" rmdir /s /q "%CASE_DIR%"
echo [FAIL] Windows workspace checker
exit /b 1
