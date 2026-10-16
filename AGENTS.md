# Workspace Generator Agent Instructions

## Rule precedence

1. Follow the user's current instructions first.
2. Follow this repository file and `AGENTS.local.md` when it exists.
3. Load nearer rules before working below a directory that provides its own `AGENTS.md`.

## Repository model

- This repository is a workspace generator, not a generated workspace.
- `set-workspace.bat` and `set-workspace.sh` create or complete a separate workspace directory.
- Files under `templates/common`, `templates/windows`, and `templates/bash` are copied into generated workspaces.
- English rule documents live in `templates/common`. Chinese rule documents live in the repository root with a `cn` suffix: `AGENTS.cn.md`, `AGENTS.local.cn.md`, `CLAUDE.cn.md`, `GEMINI.cn.md`. `env.template` and both platform loaders are shared by every language.
- The root `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md` are this repository's own rules. Only the `.cn.md` root files are rule-document templates.
- The generators copy exactly one rule-document language into a workspace: `en` (default, no prompt) or `zh-CN`, always under the canonical file names. Interactive runs ask for the language; non-interactive runs take an optional third argument. An unsupported value fails without creating the workspace.
- Keep tool-repository rules separate from generated workspace rules.

## Rule-document languages

- Both language versions of `AGENTS.md`, `AGENTS.local.md`, `CLAUDE.md`, and `GEMINI.md` express the same rules: matching heading structure, matching constraint strength, matching safety boundaries.
- Change both versions in the same task. Never let one language carry a rule the other lacks.
- A workspace never receives `.cn.md` files; the language choice selects the content of the canonical names only.
- Keep Windows cmd.exe and Bash language handling identical: the same accepted values, the same `en` default, the same `[failed] unsupported rule language:` message, the same exit code, and the same `[language] rule documents:` report.
- Preserve the existing non-interactive contract: two positional arguments stay prompt-free and produce the English rule documents.

## Safe workflow

- Inspect Git status before modifying files; existing changes belong to the user.
- Do not overwrite, revert, clean, or reformat unrelated changes.
- Do not commit, push, merge, switch branches, or update remotes without explicit authorization.
- Never run any form of `git rebase`.
- Preserve existing files in generated workspaces. The generator may only create missing files.

## Template and secret safety

- Never read, search, summarize, copy, hash, print, or upload a real `.env` or `.env.*` file.
- Tests may use only synthetic dotenv data in validated temporary directories.
- `templates/common/env.template` is public template data and must contain empty values only.
- Do not add real credentials, private data, machine paths, or organization-specific information to templates.

## Verification

- Keep Windows cmd.exe and Bash behavior aligned where their platform contracts overlap.
- Run the focused generator and loader tests after script changes.
- Run both complete platform suites before delivery when Windows and WSL are available.
- After changing either rule-document language, run the contract test to confirm both versions still have the same heading structure, and exercise the language prompt, the optional language argument, and the rejection of an unsupported value on both platforms.
- Report exact files, commands, results, and any platform checks that could not be executed.
