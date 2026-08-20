# AI Agent 工作区模板

简体中文 | [English](README.en.md)

如果一个目录下放了多个互相独立的项目，并且 Codex、Claude Code、Gemini CLI 或其他 Agent 需要遵守同一套工作区规则，可以用这个模板作为工作区根目录。它提供公共规则、本地定制、跨平台初始化，以及针对私有文件的基础 Git 检查；项目自己的构建系统、开发容器和凭据管理器仍由各项目负责。

这个模板适合以下场景：

- 一个工作区中同时存在多个 Git、SVN 或实验项目；
- 开发环境需要在 Windows、WSL 和 Linux 之间切换；
- 多个 Agent 需要读取同一套公共工作区规则；
- 项目路径、组织流程和机器限制只适合保存在本地。

如果你只有一个项目、一个 Agent 和一个开发环境，直接在项目根目录维护 `AGENTS.md` 通常更简单。

## 初始化

使用代码托管平台提供的 Clone 命令，把仓库克隆到你想要的工作区目录，例如 `my-workspace`。然后在工作区根目录运行对应的初始化脚本。

Windows 命令提示符：

```bat
cd my-workspace
setup-workspace.bat
```

Ubuntu、Linux 或 WSL Bash：

```bash
cd my-workspace
./setup-workspace.sh
```

初始化脚本会从 `AGENTS.local.example.md` 创建 `AGENTS.local.md`，并从 `.env.example` 创建 `.env`。如果目标文件已经存在，脚本会跳过，不会覆盖。生成的两个文件都应只在本地编辑，Git 会忽略它们。

## 加载环境变量

Windows 命令提示符：

```bat
set-env.bat
codex
```

如果从另一个批处理脚本中调用，并且调用后还要继续执行，请使用 `call set-env.bat`。

Ubuntu、Linux 或 WSL Bash：

```bash
source ./set-env.sh
codex
```

直接执行 `./set-env.sh` 无法修改父 Shell 的环境变量。当前不提供 PowerShell 环境加载入口。每次打开新终端后都要重新加载。脚本只负责加载变量；请在同一个 Shell 中自行启动 `codex`、`claude` 或 `gemini`。

## Dotenv 格式

根目录的 `.env` 支持空行、以 `#` 开头的整行注释，以及每行一个 `KEY=VALUE`。变量名必须匹配 `[A-Za-z_][A-Za-z0-9_]*`，`AAWT_INTERNAL_` 前缀保留给脚本内部使用。值可以为空，或只包含字母、数字、`.`、`_`、`~`、`:`、`/`、`?`、`@`、`+`、`,`、`-` 和 `=`。不支持引号、空格、变量展开、命令替换和行尾注释。

`.env` 和 `.env.*` 都是私有文件。Agent、检查脚本、日志和上传流程都不应读取或显示这些文件。只有用户主动调用的根目录环境加载脚本可以读取 `.env`。

## 工作区规则

`AGENTS.md` 是公共规则的唯一来源。`CLAUDE.md` 和 `GEMINI.md` 负责引导对应工具读取它。工作区特有的项目路径和流程应写入被忽略的 `AGENTS.local.md`。子项目仍是互相独立的仓库，也可以提供离目标文件更近的 `AGENTS.md`。

## 验证

Windows 命令提示符：

```bat
check-workspace.bat
tests\run-windows.bat
```

Ubuntu、Linux 或 WSL Bash：

```bash
./check-workspace.sh
bash tests/run-bash.sh
```

测试只会在临时目录中使用合成的 dotenv 数据，不会读取工作区中的 `.env`。
