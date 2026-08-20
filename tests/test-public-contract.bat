@echo off
setlocal
set "ROOT=%~dp0..\"
for %%F in (AGENTS.md AGENTS.local.example.md CLAUDE.md GEMINI.md .env.example .gitignore) do (
    if not exist "%ROOT%%%F" (
        echo [FAIL] Missing %%F
        exit /b 1
    )
)
%SystemRoot%\System32\findstr.exe /c:"AGENTS.local.md" "%ROOT%AGENTS.md" >nul || exit /b 1
%SystemRoot%\System32\findstr.exe /c:"AGENTS.md" "%ROOT%CLAUDE.md" >nul || exit /b 1
%SystemRoot%\System32\findstr.exe /c:"AGENTS.md" "%ROOT%GEMINI.md" >nul || exit /b 1
echo [PASS] Public workspace contract
exit /b 0
