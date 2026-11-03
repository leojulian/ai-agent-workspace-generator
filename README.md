# AI Agent 工作区生成工具

简体中文 | [English](README.en.md)

为多个独立项目生成统一的 Agent 工作区。克隆本仓库后，运行 `set-workspace`，即可在指定位置创建一个不带根 Git 的工作区，集中维护跨项目规则、本地工作区信息和当前平台的环境加载入口。

工作区中的 Git、SVN、实验目录和其他项目保持独立。这个仓库负责生成工作区，不是生成后的工作区本身。

## 适用场景

适合以下情况：

- 一个目录需要承载多个独立项目；
- 支持读取 `AGENTS.md` 的 Agent 需要遵守同一套跨项目规则；
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
Rule documents language [en/zh-CN] (en):
```

首次语言提示直接回车或未提供答案时，使用默认的英文规则文档。输入不支持的语言后会重新提示，重试必须明确输入有效语言；空行或 EOF 会以退出码 `2` 结束，且不创建工作区。

也可以直接传入参数：

```bat
set-workspace.bat "<workspace-parent>" my-workspace
set-workspace.bat "<workspace-parent>" my-workspace zh-CN
```

```bash
./set-workspace.sh "<workspace-parent>" my-workspace
./set-workspace.sh "<workspace-parent>" my-workspace zh-CN
```

父目录不存在时会自动创建。工作区名称必须是单个目录名，不能包含路径分隔符，也不能是 `.` 或 `..`。省略第三个参数或传入空字符串时不会提示，直接使用英文规则文档，因此脚本和自动化调用保持原有行为。

规则文档语言接受以下取值（不区分大小写）：

| 取值 | 结果 |
| --- | --- |
| `en`、`en-US`、`english` | 英文规则文档（默认） |
| `zh-CN`、`zh`、`zh-Hans`、`chinese` | 简体中文规则文档 |
| 其他取值 | 参数模式报错退出；交互模式按上述规则重试 |

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
  .env
  set-env.bat
```

Bash 入口生成同样的文件，但使用 `set-env.sh` 替代 `set-env.bat`。

`AGENTS.md` 和 `AGENTS.local.md` 这两份规则文档来自所选语言版本，但始终使用标准文件名；`.env` 和 `set-env` 与语言无关。

目标工作区不会包含工具仓库的 README、测试、另一平台的 loader，也不会初始化根 Git。已有目录和文件只会被保留；生成器只创建缺失文件，不覆盖规则、`.env`、loader 或项目内容。

如果目标工作区已经存在 `AGENTS.md`，生成器会保留它并输出提示。请人工确认该文件会继续加载 `AGENTS.local.md` 和更近的项目级 `AGENTS.md`。

## 规则文档语言

所有工作区规则模板统一存放在 `templates/common`。英文模板使用标准文件名，中文模板使用 `.cn.md` 后缀：

| 英文模板 | 中文模板 |
| --- | --- |
| `templates/common/AGENTS.md` | `templates/common/AGENTS.cn.md` |
| `templates/common/AGENTS.local.md` | `templates/common/AGENTS.local.cn.md` |

`set-workspace` 默认选择英文；选择 `zh-CN` 时使用同目录中的中文模板。两种语言生成后的文件都使用标准名称，工作区内不会出现 `.cn.md` 文件。`env.template` 和平台 loader 由两种语言共用。

仓库根目录只保留一个开发规则文件 `AGENTS.md`，用于约束 Agent 如何维护本工具；README 介绍仓库用途、使用方法和验证命令。修改生成后的工作区规则时，应同步维护 `templates/common` 中的中英文模板。

两个语言版本表达同一套规则，标题结构、约束强度和边界对应一致。测试会检查模板位置和标题数量，并验证两种语言的生成结果。

生成器在成功时输出 `[language] rule documents: <取值>`。已有工作区文件不会被覆盖；需要切换语言时，应手动替换规则文件，或在另一个目录重新生成工作区。

## 规则层级

规则文件按作用范围分工：

| 文件 | 作用 |
| --- | --- |
| 工作区 `AGENTS.md` | 跨项目通用规则，例如目标识别、版本控制安全和交付要求 |
| 工作区 `AGENTS.local.md` | 本机路径、项目地图、组织流程和环境限制 |
| 项目 `AGENTS.md` | 项目构建、测试、架构和编码要求 |
| 模块 `AGENTS.md` | 特定模块或目录的局部约束 |

以上文件在英文和简体中文两个版本中层级完全一致，工作区只会包含所选语言的一套文档。

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
