@echo off
setlocal
call "%~dp0test-public-contract.bat" || exit /b 1
call "%~dp0test-set-workspace.bat" || exit /b 1
call "%~dp0test-set-env.bat" || exit /b 1
echo [PASS] All Windows tests
exit /b 0
