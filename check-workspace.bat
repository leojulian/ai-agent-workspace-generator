@echo off
setlocal EnableExtensions
for %%I in ("%~dp0.") do set "ROOT=%%~fI"
set "FAILED=0"

for %%F in (AGENTS.md AGENTS.local.example.md CLAUDE.md GEMINI.md .env.example .gitignore README.md setup-workspace.bat setup-workspace.sh set-env.bat set-env.sh check-workspace.bat check-workspace.sh) do (
    if not exist "%ROOT%\%%F" (
        echo [failed] missing required file: %%F
        set "FAILED=1"
    )
)

git -C "%ROOT%" rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
    echo [failed] workspace root is not a Git work tree
    set "FAILED=1"
    goto :finish
)

for %%P in (.env .env.production AGENTS.local.md) do (
    git -C "%ROOT%" check-ignore -q -- "%%P"
    if errorlevel 1 (
        echo [failed] path is not ignored: %%P
        set "FAILED=1"
    )
)
set "TRACKABLE_EXAMPLE="
for /f "usebackq delims=" %%F in (`git -C "%ROOT%" ls-files --cached --others --exclude-standard -- ".env.example"`) do set "TRACKABLE_EXAMPLE=%%F"
if /i not "%TRACKABLE_EXAMPLE%"==".env.example" (
    echo [failed] .env.example must remain trackable
    set "FAILED=1"
)

for /f "usebackq delims=" %%F in (`git -C "%ROOT%" ls-files -- ".env" ".env.*" "AGENTS.local.md"`) do (
    if /i not "%%F"==".env.example" (
        echo [failed] private path is tracked: %%F
        set "FAILED=1"
    )
)

:finish
if "%FAILED%"=="0" echo [pass] Workspace metadata is safe
exit /b %FAILED%
