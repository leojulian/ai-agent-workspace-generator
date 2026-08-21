# AI Agent 工作区生成工具

简体中文 | [English](README.en.md)

为多个独立项目生成统一的 Agent 工作区。克隆本仓库后，运行 `set-workspace`，即可在指定位置创建一个不带根 Git 的工作区，集中维护跨项目规则、本地工作区信息和当前平台的环境加载入口。

工作区中的 Git、SVN、实验目录和其他项目保持独立。这个仓库负责生成工作区，不是生成后的工作区本身。

## 适用场景

适合以下情况：

- 一个目录需要承载多个独立项目；
- Codex、Claude Code、Gemini CLI 等 Agent 需要遵守同一套跨项目规则；
- 开发环境需要在 Windows、WSL 和 Linux 之间切换；
- 项目地图、组织流程和机器限制需要保存在本地。

如果只有一个项目、一个 Agent 和一个开发环境，直接在项目根目录维护 `AGENTS.md` 通常更简单。

## 快速开始

### 1. 克隆工具仓库

使用代码托管平台提供的 Clone 命令，将本仓库克隆到任意工具目录。

### 2. 生成工作区

Windows 命令提示符：

```bat
set-workspace.bat
```

Linux、WSL 或 macOS Bash：

```bash
./set-workspace.sh
```

脚本会询问：

```text
Workspace parent directory: <workspace-parent>
Workspace name: my-workspace
```

也可以直接传入两个参数：

```bat
set-workspace.bat "<workspace-parent>" my-workspace
```

```bash
./set-workspace.sh "<workspace-parent>" my-workspace
```

父目录不存在时会自动创建。工作区名称必须是单个目录名，不能包含路径分隔符，也不能是 `.` 或 `..`。

### 3. 填写本地工作区规则

生成完成后，进入目标工作区，编辑 `AGENTS.local.md`。建议记录：

- 子项目路径、版本控制类型以及主线/分支关系；
- 组织要求的构建、测试、评审和文档流程；
- 当前机器可用或缺失的工具、设备、GPU 和外部服务。

不要在本地规则文件中记录凭据或 `.env` 中的值。

### 4. 放入或创建项目

可以把已有项目直接放到工作区中：

```text
my-workspace/
  AGENTS.md
  AGENTS.local.md
  project-a/       # 独立 Git 仓库
  project-b/       # 独立 SVN 工作副本
  experiment-c/    # 实验目录
```

创建新项目时，只在项目目录中初始化版本控制：

```bash
cd my-workspace
mkdir project-a
cd project-a
git init
```

工作区根目录不会初始化 Git。生成器也不会修改项目已有的 `AGENTS.md`。

### 5. 加载环境并启动 Agent

Windows 命令提示符：

```bat
cd my-workspace
set-env.bat
codex
```

Linux、WSL 或 macOS Bash：

```bash
cd my-workspace
source ./set-env.sh
codex
```

多项目任务建议从工作区根目录启动 Agent，并在任务中明确项目，例如：

```text
请检查 project-a 的测试失败原因，并先读取该项目的 AGENTS.md。
```

每个新终端都需要重新加载环境变量。Bash 必须使用 `source`；直接执行 `./set-env.sh` 无法修改父 Shell。Windows 批处理脚本调用 loader 后还要继续执行时，请使用 `call set-env.bat`。

## 生成结果

Windows 入口生成：

```text
my-workspace/
  AGENTS.md
  AGENTS.local.md
  CLAUDE.md
  GEMINI.md
  .env
  set-env.bat
```

Bash 入口生成同样的文件，但使用 `set-env.sh` 替代 `set-env.bat`。

目标工作区不会包含工具仓库的 README、测试、另一平台的 loader，也不会初始化根 Git。已有目录和文件只会被保留；生成器只创建缺失文件，不覆盖规则、`.env`、loader 或项目内容。

如果目标工作区已经存在 `AGENTS.md`，生成器会保留它并输出提示。请人工确认该文件会继续加载 `AGENTS.local.md` 和更近的项目级 `AGENTS.md`。

## 规则层级

规则文件按作用范围分工：

| 文件 | 作用 |
| --- | --- |
| 工作区 `AGENTS.md` | 跨项目通用规则，例如目标识别、版本控制安全和交付要求 |
| 工作区 `AGENTS.local.md` | 本机路径、项目地图、组织流程和环境限制 |
| 项目 `AGENTS.md` | 项目构建、测试、架构和编码要求 |
| 模块 `AGENTS.md` | 特定模块或目录的局部约束 |
| `CLAUDE.md` / `GEMINI.md` | 引导对应工具读取共享规则，不重复保存规则正文 |

处理项目文件时，Agent 应按以下范围读取规则：

```text
工作区 AGENTS.md
  -> 工作区 AGENTS.local.md
    -> 项目 AGENTS.md
      -> 目标文件附近更深层的 AGENTS.md
```

越接近目标文件的规则越具体，但不能放宽工作区级安全边界。项目没有 `AGENTS.md` 时继承工作区规则；出现特殊构建、测试、编码或硬件要求时，再在项目根目录增加项目级规则。

## 环境变量格式

生成的 `.env` 预置以下空变量：

```dotenv
OPENAI_API_KEY=
ANTHROPIC_API_KEY=
GEMINI_API_KEY=
```

格式限制：

- 支持空行、以 `#` 开头的整行注释和每行一个 `KEY=VALUE`；
- 变量名必须匹配 `[A-Za-z_][A-Za-z0-9_]*`；
- `AAWT_INTERNAL_` 前缀保留给 loader 内部使用；
- 值可以为空，或只包含字母、数字、`.`、`_`、`~`、`:`、`/`、`?`、`@`、`+`、`,`、`-` 和 `=`；
- 不支持引号、空格、变量展开、命令替换和行尾注释。

## 验证工具仓库

Windows 命令提示符：

```bat
tests\run-windows.bat
```

Linux、WSL 或 macOS Bash：

```bash
bash tests/run-bash.sh
```

测试只会在临时目录中使用合成的 dotenv 数据，不会读取真实工作区中的 `.env`。
