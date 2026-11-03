# Workspace Generator Agent Instructions

## Rule precedence

1. Follow the user's current instructions first.
2. Follow this repository file as the only root-level development instruction document.
3. Load nearer rules before working below a directory that provides its own `AGENTS.md`.

## Repository model

- This repository is a workspace generator, not a generated workspace.
- `set-workspace.bat` and `set-workspace.sh` create or complete a separate workspace directory.
- Files under `templates/common`, `templates/windows`, and `templates/bash` are copied into generated workspaces.
- Both English and Chinese workspace rule templates live in `templates/common`. English templates use canonical names; Chinese templates use a `.cn.md` suffix. `env.template` and both platform loaders are shared by every language.
- The root `AGENTS.md` is the only development instruction document for this repository. Do not place workspace rule templates or separate Claude/Gemini instruction files in the repository root. README files explain the repository's purpose and usage.
- The generators copy exactly one rule-document language into a workspace: `en` (default, no prompt) or `zh-CN`, always under the canonical file names. Interactive runs ask for the language; non-interactive runs take an optional third argument. An unsupported value fails without creating the workspace.
- Keep tool-repository rules separate from generated workspace rules.

## Rule-document languages

- Both language versions of `AGENTS.md` and `AGENTS.local.md` under `templates/common` express the same rules: matching heading structure, matching constraint strength, matching safety boundaries.
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

## General implementation and testing rules

- Do not add complexity for imagined race conditions or security edge cases that are almost certain not to occur. If you believe it is necessary, first explain exactly what could go wrong, how likely it is, and how much additional code it would require. Proceed only after I approve. Do not silently expand the scope of the changes.
- Validate data coming from outside only once, at the entry boundary. Pass values whose types are already established into the internal logic; do not repeat defensive checks internally.
- Do not prematurely extract functions that are used only once. Extract them only if they will be reused, encapsulate genuinely complex logic, or represent a concept that can be given a clear name.
- Keep only the happy path in the main function; put validation and details in small functions below it.
- Write comments only for non-obvious constraints and counterintuitive behavior. Do not comment on obvious code.
- Follow the repository's existing workflows. Do not introduce tools or workflows that the repository does not already use.

## Template and secret safety

- Never read, search, summarize, copy, hash, print, or upload a real `.env` or `.env.*` file.
- Tests may use only synthetic dotenv data in validated temporary directories.
- `templates/common/env.template` is public template data and must contain empty values only.
- Do not add real credentials, private data, machine paths, or organization-specific information to templates.

## Verification

- Test the real implementation. Do not copy the business logic into the tests. Use mocks as little as possible.
- Keep Windows cmd.exe and Bash behavior aligned where their platform contracts overlap.
- Run the focused generator and loader tests after script changes.
- Run both complete platform suites before delivery when Windows and WSL are available.
- After changing either rule-document language, run the contract test to confirm both versions still have the same heading structure, and exercise the language prompt, the optional language argument, and the rejection of an unsupported value on both platforms.
- Report exact files, commands, results, and any platform checks that could not be executed.
