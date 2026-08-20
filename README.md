# AI Agent Workspace Template

A workspace-root template for Codex, Claude Code, Gemini CLI, and independent child projects. The cloned directory can use any name.

## Initialize

Use the clone command shown by the repository host and choose the workspace directory name you prefer, such as `CodeHere`. Then run one setup script from the workspace root.

Windows Command Prompt:

```bat
cd CodeHere
setup-workspace.bat
```

Ubuntu, Linux, or WSL Bash:

```bash
cd CodeHere
./setup-workspace.sh
```

Setup creates `AGENTS.local.md` from `AGENTS.local.example.md` and `.env` from `.env.example`. Existing local files are skipped and never overwritten. Edit both generated files locally; Git ignores them.

## Load environment variables

Windows Command Prompt:

```bat
set-env.bat
codex
```

When another batch file invokes the loader and continues afterward, use `call set-env.bat`.

Ubuntu, Linux, or WSL Bash:

```bash
source ./set-env.sh
codex
```

Directly executing `./set-env.sh` cannot modify its parent shell. PowerShell is not a supported environment-loading entry point. Load again in every new terminal. The scripts only load variables; start `codex`, `claude`, or `gemini` yourself in the same shell.

## Dotenv format

The root `.env` accepts blank lines, full-line `#` comments, and one `KEY=VALUE` entry per line. Names must match `[A-Za-z_][A-Za-z0-9_]*`; `AAWT_INTERNAL_` is reserved. Values may be empty or use only letters, digits, `.`, `_`, `~`, `:`, `/`, `?`, `@`, `+`, `,`, `-`, and `=`. Quotes, spaces, expansion, command substitution, and inline comments are not supported.

`.env` and `.env.*` are private. Agents, checks, logs, and upload workflows must not read or display them. Only the user-invoked root environment loader may read `.env`.

## Workspace rules

`AGENTS.md` is the public rules source of truth. `CLAUDE.md` and `GEMINI.md` direct their tools to it. Put workspace-specific project paths and workflow in ignored `AGENTS.local.md`. Child projects remain independent repositories and may provide nearer `AGENTS.md` files.

## Validate

Windows Command Prompt:

```bat
check-workspace.bat
tests\run-windows.bat
```

Ubuntu, Linux, or WSL Bash:

```bash
./check-workspace.sh
bash tests/run-bash.sh
```

The tests use synthetic dotenv files in temporary directories and do not inspect the workspace `.env`.
