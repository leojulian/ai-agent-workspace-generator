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
```

You can also pass both values directly:

```bat
set-workspace.bat "<workspace-parent>" my-workspace
```

```bash
./set-workspace.sh "<workspace-parent>" my-workspace
```

The parent directory is created when necessary. The workspace name must be a single directory name; it cannot contain path separators or equal `.` or `..`.

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

The target workspace does not include this repository's README files, tests, or loader for the other platform, and it does not initialize a Git repository at the workspace root. Existing directories and files are preserved. The generator creates missing files only and does not overwrite rules, `.env`, loader scripts, or project content.

When the target workspace already contains `AGENTS.md`, the generator preserves it and prints a notice. Verify manually that the existing file loads `AGENTS.local.md` and nearer project-level `AGENTS.md` files.

## Rule hierarchy

Rule files have separate scopes:

| File | Responsibility |
| --- | --- |
| Workspace `AGENTS.md` | Cross-project rules such as target selection, version-control safety, and delivery requirements |
| Workspace `AGENTS.local.md` | Machine paths, the project map, organization workflows, and environment constraints |
| Project `AGENTS.md` | Project build, test, architecture, and coding requirements |
| Module `AGENTS.md` | Local constraints for a specific module or directory |
| `CLAUDE.md` / `GEMINI.md` | Direct their tools to shared rules without duplicating policy text |

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
