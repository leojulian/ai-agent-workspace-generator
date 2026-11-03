@echo off
setlocal EnableExtensions
for %%I in ("%~dp0..") do set "ROOT=%%~fI"
for %%F in (AGENTS.md README.md README.en.md .gitignore templates\common\AGENTS.cn.md templates\common\AGENTS.local.cn.md set-workspace.bat set-workspace.sh templates\common\AGENTS.md templates\common\AGENTS.local.md templates\common\env.template templates\windows\set-env.bat templates\bash\set-env.sh) do (
    if not exist "%ROOT%\%%F" (
        echo [FAIL] Missing %%F
        exit /b 1
    )
)
for %%F in (templates\common\CLAUDE.md templates\common\GEMINI.md templates\common\CLAUDE.cn.md templates\common\GEMINI.cn.md AGENTS.cn.md AGENTS.local.cn.md CLAUDE.cn.md GEMINI.cn.md CLAUDE.md GEMINI.md AGENTS.local.example.md .env.example setup-workspace.bat setup-workspace.sh set-env.bat set-env.sh templates\common\zh-CN) do (
    if exist "%ROOT%\%%F" (
        echo [FAIL] Obsolete path remains: %%F
        exit /b 1
    )
)
%SystemRoot%\System32\findstr.exe /c:"README.en.md" "%ROOT%\README.md" >nul || exit /b 1
%SystemRoot%\System32\findstr.exe /c:"README.md" "%ROOT%\README.en.md" >nul || exit /b 1
%SystemRoot%\System32\findstr.exe /c:"AGENTS.local.md" "%ROOT%\templates\common\AGENTS.md" >nul || exit /b 1
%SystemRoot%\System32\findstr.exe /c:"AGENTS.local.md" "%ROOT%\templates\common\AGENTS.cn.md" >nul || exit /b 1
%SystemRoot%\System32\findstr.exe /c:"zh-CN" "%ROOT%\README.md" >nul || exit /b 1
%SystemRoot%\System32\findstr.exe /c:"zh-CN" "%ROOT%\README.en.md" >nul || exit /b 1
git -C "%ROOT%" check-ignore -q -- "templates\common\AGENTS.local.md"
if not errorlevel 1 exit /b 1
git -C "%ROOT%" check-ignore -q -- "templates\common\env.template"
if not errorlevel 1 exit /b 1
git -C "%ROOT%" check-ignore -q -- "templates\common\AGENTS.local.cn.md"
if not errorlevel 1 exit /b 1
for %%F in (AGENTS AGENTS.local) do (
    call :check_headings "%ROOT%\templates\common\%%F.md" "%ROOT%\templates\common\%%F.cn.md" || exit /b 1
)
echo [PASS] Public generator contract
exit /b 0

:check_headings
set "EN_HEADINGS="
set "ZH_HEADINGS="
for /f %%N in ('%SystemRoot%\System32\findstr.exe /b /c:"#" "%~1" ^| %SystemRoot%\System32\find.exe /c /v ""') do set "EN_HEADINGS=%%N"
for /f %%N in ('%SystemRoot%\System32\findstr.exe /b /c:"#" "%~2" ^| %SystemRoot%\System32\find.exe /c /v ""') do set "ZH_HEADINGS=%%N"
if not "%EN_HEADINGS%"=="%ZH_HEADINGS%" (
    echo [FAIL] Heading count differs between en and cn: %~n1
    exit /b 1
)
exit /b 0
