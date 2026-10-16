# AI Agent Workspace Generator

[简体中文](README.md) | English

Generate a shared agent workspace for multiple independent projects. Clone this repository and run `set-workspace` to create a workspace at a location you choose. The generated workspace centralizes cross-project rules, local workspace information, and the environment loader for the current platform without creating a Git repository at the workspace root.

Git repositories, SVN working copies, experiments, and other projects inside the workspace remain independent. This repository generates the workspace; it is not the generated workspace itself.

## When to use it

This tool is a good fit when:

- one directory needs to contain multiple independent projects;
- Codex, Claude Code, Gemini CLI, or other agents need the same cross-project rules;
- development moves between Windows, WSL, and Linux; or
- the project map, organization workflows, and machine constraints must stay local.

For one project, one agent, and one development environment, a project-level `AGENTS.md` is usually simpler.

## Quick start

### 1. Clone the tool repository

Use the clone command provided by your code host and place this repository in any tools directory.

### 2. Generate a workspace

Windows Command Prompt:

```bat
set-workspace.bat
```

Bash on Linux, WSL, or macOS:

```bash
./set-workspace.sh
```

The script asks for:

```text
Workspace parent directory: <workspace-parent>
Workspace name: my-workspace
Rule documents language [en/zh-CN] (en):
```

At the first language prompt, pressing Enter or providing no answer uses the default English rule documents. An unsupported language triggers another prompt, and a retry must explicitly provide a supported language. An empty retry or EOF exits with code `2` without creating a workspace.

You can also pass the values directly:

```bat
set-workspace.bat "<workspace-parent>" my-workspace
set-workspace.bat "<workspace-parent>" my-workspace zh-CN
```

```bash
./set-workspace.sh "<workspace-parent>" my-workspace
./set-workspace.sh "<workspace-parent>" my-workspace zh-CN
```

The parent directory is created when necessary. The workspace name must be a single directory name; it cannot contain path separators or equal `.` or `..`. When the third argument is omitted or empty, the script does not prompt and uses the English rule documents, so scripts and automated calls keep their previous behavior.

The rule-document language accepts these values, case-insensitively:

| Value | Result |
| --- | --- |
| `en`, `en-US`, `english` | English rule documents (default) |
| `zh-CN`, `zh`, `zh-Hans`, `chinese` | Simplified Chinese rule documents |
| anything else | Error exit in argument mode; retry as described above in interactive mode |

### 3. Fill in local workspace rules

Enter the generated workspace and edit `AGENTS.local.md`. Record information such as:

- child-project paths, version-control types, and mainline or branch relationships;
- organization-specific build, test, review, and documentation workflows; and
- tools, devices, GPUs, and external services that are available or missing on the current machine.

Do not place credentials or `.env` values in the local rules file.

### 4. Add or create projects

Place existing projects directly inside the workspace:

```text
my-workspace/
  AGENTS.md
  AGENTS.local.md
  project-a/       # independent Git repository
  project-b/       # independent SVN working copy
  experiment-c/    # experiment directory
```

For a new project, initialize version control in that project directory only:

```bash
cd my-workspace
mkdir project-a
cd project-a
git init
```

The workspace root is not initialized as a Git repository. The generator also leaves an existing project-level `AGENTS.md` unchanged.

### 5. Load the environment and start an agent

Windows Command Prompt:

```bat
cd my-workspace
set-env.bat
codex
```

Bash on Linux, WSL, or macOS:

```bash
cd my-workspace
source ./set-env.sh
codex
```

For multi-project work, start the agent from the workspace root and name the target project in the task. For example:

```text
Investigate the test failure in project-a. Read that project's AGENTS.md first.
```

Load the environment again in every new terminal. Bash must use `source`; directly executing `./set-env.sh` cannot modify the parent shell. When another Windows batch script invokes the loader and continues afterward, use `call set-env.bat`.

## Generated workspace

The Windows entry point creates:

```text
my-workspace/
  AGENTS.md
  AGENTS.local.md
  CLAUDE.md
  GEMINI.md
  .env
  set-env.bat
```

The Bash entry point creates the same files but uses `set-env.sh` instead of `set-env.bat`.

The four rule documents `AGENTS.md`, `AGENTS.local.md`, `CLAUDE.md`, and `GEMINI.md` come from the selected language version but always keep the canonical file names. `.env` and the `set-env` loader are language-independent.

The target workspace does not include this repository's README files, tests, or loader for the other platform, and it does not initialize a Git repository at the workspace root. Existing directories and files are preserved. The generator creates missing files only and does not overwrite rules, `.env`, loader scripts, or project content.

When the target workspace already contains `AGENTS.md`, the generator preserves it and prints a notice. Verify manually that the existing file loads `AGENTS.local.md` and nearer project-level `AGENTS.md` files.

## Rule document language

This repository provides the four rule documents in both English and Simplified Chinese:

| Language | Value | Template location |
| --- | --- | --- |
| English | `en` (default) | `templates/common/AGENTS.md` and the other three |
| Simplified Chinese | `zh-CN` | Repository root: `AGENTS.cn.md`, `AGENTS.local.cn.md`, `CLAUDE.cn.md`, `GEMINI.cn.md` |

The Chinese versions live in the repository root with a `cn` suffix and map one-to-one to the English templates:

| English template | Chinese template |
| --- | --- |
| `templates/common/AGENTS.md` | `AGENTS.cn.md` |
| `templates/common/AGENTS.local.md` | `AGENTS.local.cn.md` |
| `templates/common/CLAUDE.md` | `CLAUDE.cn.md` |
| `templates/common/GEMINI.md` | `GEMINI.cn.md` |

`AGENTS.md`, `CLAUDE.md`, and `GEMINI.md` in the repository root are this tool repository's own agent rules, not templates for generated workspaces; only the `.cn.md` files are templates.

Both versions express the same rules: heading structure, constraint strength, and boundaries correspond exactly; only the language differs. A generated workspace receives one language set only, always under the canonical file names (`AGENTS.md`, `AGENTS.local.md`, `CLAUDE.md`, `GEMINI.md`); `.cn.md` files never appear in a generated workspace.

On success the generator prints `[language] rule documents: <value>` so the version in use is explicit. To change the language of an existing workspace, replace the four documents manually or generate a new workspace elsewhere; the generator does not overwrite existing files.

Whenever one language version changes, update the other one in the same change and keep the heading structure identical. `tests/test-public-contract.sh` verifies that both sides have the same number of headings.

## Rule hierarchy

Rule files have separate scopes:

| File | Responsibility |
| --- | --- |
| Workspace `AGENTS.md` | Cross-project rules such as target selection, version-control safety, and delivery requirements |
| Workspace `AGENTS.local.md` | Machine paths, the project map, organization workflows, and environment constraints |
| Project `AGENTS.md` | Project build, test, architecture, and coding requirements |
| Module `AGENTS.md` | Local constraints for a specific module or directory |
| `CLAUDE.md` / `GEMINI.md` | Direct their tools to shared rules without duplicating policy text |

Both language versions provide the identical hierarchy; a workspace contains the documents of one language only.

When working on a project file, an agent should load rules in this order:

```text
Workspace AGENTS.md
  -> Workspace AGENTS.local.md
    -> Project AGENTS.md
      -> Deeper AGENTS.md files near the target
```

Nearer rules may specialize the workflow but cannot weaken workspace-level safety boundaries. A project without `AGENTS.md` inherits workspace rules. Add project-level rules when the project has specific build, test, encoding, or hardware requirements.

## Environment file format

The generated `.env` contains these empty entries:

```dotenv
OPENAI_API_KEY=
ANTHROPIC_API_KEY=
GEMINI_API_KEY=
```

Format constraints:

- blank lines, full-line `#` comments, and one `KEY=VALUE` entry per line are supported;
- names must match `[A-Za-z_][A-Za-z0-9_]*`;
- the `AAWT_INTERNAL_` prefix is reserved for loader internals;
- values may be empty or use only letters, digits, `.`, `_`, `~`, `:`, `/`, `?`, `@`, `+`, `,`, `-`, and `=`; and
- quotes, spaces, expansion, command substitution, and inline comments are not supported.

## Validate the tool repository

Windows Command Prompt:

```bat
tests\run-windows.bat
```

Bash on Linux, WSL, or macOS:

```bash
bash tests/run-bash.sh
```

Tests use synthetic dotenv data in temporary directories and do not inspect a real workspace `.env`.
