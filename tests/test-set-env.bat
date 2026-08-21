@echo off
setlocal EnableExtensions
for %%I in ("%~dp0..") do set "ROOT=%%~fI"
set "CASE_DIR=%TEMP%\aawt-set-env-%RANDOM%-%RANDOM%"
mkdir "%CASE_DIR%" || exit /b 1
copy /y "%ROOT%\templates\windows\set-env.bat" "%CASE_DIR%\set-env.bat" >nul || goto :fail
>"%CASE_DIR%\.env" (
    echo # synthetic test data
    echo TEST_API_KEY=test-only-value
    echo TEST_VALUE_WITH_EQUALS=left=right==
    echo TEST_EMPTY=
)

pushd "%TEMP%"
call "%CASE_DIR%\set-env.bat" >"%CASE_DIR%\output.txt" 2>&1
set "RESULT=%ERRORLEVEL%"
popd
if not "%RESULT%"=="0" goto :fail
if not "%TEST_API_KEY%"=="test-only-value" goto :fail
if not "%TEST_VALUE_WITH_EQUALS%"=="left=right==" goto :fail
%SystemRoot%\System32\findstr.exe /c:"test-only-value" "%CASE_DIR%\output.txt" >nul && goto :fail

>"%CASE_DIR%\.env" echo BAD-NAME=DO_NOT_PRINT_TEST_VALUE
call "%CASE_DIR%\set-env.bat" >"%CASE_DIR%\invalid-output.txt" 2>&1
if not "%ERRORLEVEL%"=="2" goto :fail
%SystemRoot%\System32\findstr.exe /c:"DO_NOT_PRINT_TEST_VALUE" "%CASE_DIR%\invalid-output.txt" >nul && goto :fail
call "%CASE_DIR%\set-env.bat" unexpected-argument >nul 2>&1
if not "%ERRORLEVEL%"=="2" goto :fail

rmdir /s /q "%CASE_DIR%"
echo [PASS] Windows environment loader template
exit /b 0

:fail
if exist "%CASE_DIR%" rmdir /s /q "%CASE_DIR%"
echo [FAIL] Windows environment loader template
exit /b 1
