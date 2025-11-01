# Viralfy 🚀

> AI 驱动的病毒式内容生态系统 - 从创意验证到多平台病毒式传播

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node Version](https://img.shields.io/badge/node-%3E%3D18.0.0-brightgreen)](https://nodejs.org)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.3-blue)](https://www.typescriptlang.org/)

## 📖 项目简介

Viralfy 是基于 **Dan Koe 的 AI 内容生态系统理念**打造的完整内容创作和分发系统,通过"单一内容源,多平台分发"的策略,结合 AI 的放大能力,帮助创作者实现内容影响力的指数级增长。

### 核心理念

```
传统方式: 为每个平台单独创作内容
结果: 效率低下,质量难保证,影响力分散

Viralfy 方式: 一篇深度 Newsletter → AI 智能分发 → 15+ 平台内容
结果: 效率提升 10 倍,质量一致,影响力叠加
```

### 四步内容创作流程

```
第一步: 创意验证 (Idea Validation)
├─ Twitter/YouTube 爆款分析
├─ 数据驱动的创意评分
└─ 低成本测试,高确定性投入

第二步: 深度研究 (Deep Research)
├─ AI 辅助知识提炼
├─ 多源信息整合
└─ 构建扎实知识基础

第三步: Newsletter 创作 (Writing)
├─ 三种创作模式
├─ 增量生成,断点续传
└─ AI 作为写作教练

第四步: 多平台分发 (Distribution)
├─ 元提示工程 (Meta-Prompting)
├─ 智能内容拆解
└─ 15+ 平台一键生成
```

## ✨ 核心特性

### 🎯 创意验证优先

- **内部验证**: 分析你的 Twitter 历史数据,识别高表现帖子
- **外部借鉴**: 提取 YouTube 热门视频标题,学习已验证的话题
- **数据驱动**: 基于互动数据评分,推荐 Top 5 高潜力主题

### 📚 深度研究赋能

- **多源信息**: 支持 YouTube 视频、PDF 书籍、长文章
- **AI 提炼**: Gemini 2.5 将 6 小时视频浓缩成 5000 字核心摘要
- **知识库**: 结构化保存研究成果,随时调用

### ✍️ 高效内容创作

- **三种模式**: 从零创作 / 导入现有 / AI 辅助
- **增量生成**: 分章节保存,中断不丢失
- **断点续传**: 随时恢复,继续创作

### 🚀 智能多平台分发

- **元提示工程**: AI 分析爆款结构 → 生成创作指南 → 产出病毒式内容
- **15+ 平台**: 中文(微信、小红书、知乎、B站、抖音) + 英文(Twitter、LinkedIn、YouTube等)
- **智能适配**: 自动适配字数、格式、风格

### 🧬 病毒式 DNA 复制

- **爆款分析**: 拆解病毒式内容的底层结构
- **风格训练**: 学习顶级创作者的写作 Persona
- **模板复用**: 建立个人 Swipe File 素材库

## 🚀 快速开始

### 安装

```bash
# 克隆仓库
git clone https://github.com/your-org/viralfy.git
cd viralfy

# 安装依赖
npm install

# 构建项目
npm run build

# 全局安装(可选)
npm link
```

### 第一个项目

```bash
# 1. 初始化项目
viralfy init

# 2. 创意验证
viralfy validate

# 3. 深度研究
viralfy research --topic topic-001

# 4. Newsletter 创作
viralfy write --mode create

# 5. 多平台分发
viralfy distribute --newsletter issue-001
```

### 5 分钟体验

```bash
# 创建示例项目
mkdir my-content && cd my-content

# 初始化
viralfy init
# 选择: 编程开发 → Twitter + 小红书 → 中文

# 导入现有文章(演示模式)
viralfy write --mode import --file ~/my-blog-post.md

# 一键分发
viralfy distribute --newsletter issue-001 --platforms all

# 查看生成的内容
ls distribution/
# distribution/
#   ├── twitter/     (3 个推文变体)
#   ├── xiaohongshu/ (1 篇图文笔记)
#   └── ...
```

## 📚 核心命令

| 命令 | 功能 | 说明 |
|------|------|------|
| `viralfy init` | 初始化项目 | 配置平台、语言、创建目录结构 |
| `viralfy validate` | 创意验证 | 分析 Twitter/YouTube,识别高潜力主题 |
| `viralfy research` | 深度研究 | AI 辅助知识提炼,构建知识库 |
| `viralfy write` | Newsletter 创作 | 三种模式,增量生成,断点续传 |
| `viralfy distribute` | 多平台分发 | 元提示工程,一键生成 15+ 平台内容 |
| `viralfy analyze` | 爆款分析 | 拆解病毒式内容结构,提取创作模板 |
| `viralfy style` | 风格训练 | 学习顶级创作者,生成 Persona 配置 |

## 🎨 使用场景

### 场景 1: 个人创作者

**用户**: 程序员小李,想建立技术品牌

**流程**:
```bash
# Week 1: 验证创意
viralfy validate
# → 发现 "AI 提升开发效率" 是高分主题

# Week 2: 深度研究
viralfy research --topic ai-dev-efficiency
# → AI 提炼 3 个视频 + 2 篇文章的核心观点

# Week 3: 创作 Newsletter
viralfy write --mode assisted
# → 3 小时完成 3000 字深度文章

# Week 4: 多平台分发
viralfy distribute --newsletter issue-001
# → 30 分钟生成 10+ 平台内容

# 结果:
# - 1 篇高质量 Newsletter
# - 10+ 篇平台内容
# - 总耗时: 约 5 小时 (传统方式需 20+ 小时)
```

### 场景 2: 内容团队

**用户**: 3 人内容团队,需要规模化产出

**流程**:
```bash
# 设置阶段: 训练风格
viralfy style --author "Dan Koe"
viralfy style --author "Justin Welsh"

# 每周流程:
# 周一: 验证 20 个创意 → 筛选 Top 5
# 周二-周四: 研究 + 创作 4 篇 Newsletter
# 周五: 分发 → 60+ 条社交内容

# 结果:
# - 每周 4 篇 Newsletter + 60 条社交内容
# - 覆盖 10 个平台
# - 效率提升 8 倍
```

### 场景 3: 已有内容重新分发

**用户**: 已写 50 篇博客,想扩大影响力

**流程**:
```bash
# 批量导入
for blog in blogs/*.md; do
  viralfy write --mode import --file $blog
done

# 批量分发
for newsletter in newsletters/*; do
  viralfy distribute --newsletter $newsletter
done

# 结果:
# - 50 篇博客 → 750 条社交内容
# - 扩展到 10 个新平台
# - 总耗时: 20 小时 (手动需 200+ 小时)
```

## 🌟 支持的平台

### 中文平台

| 平台 | 字数限制 | 格式特点 | 支持状态 |
|------|---------|---------|---------|
| 微信公众号 | 3000+ 字 | 长文、深度 | ✅ |
| 小红书 | 800-1000 字 | 生活化图文 | ✅ |
| 知乎 | 无限制 | 问答式深度 | ✅ |
| B站 | 视频脚本 | 年轻化、梗文化 | ✅ |
| 抖音 | 15-60秒 | 短视频脚本 | ✅ |

### 国际平台

| 平台 | 字数限制 | 格式特点 | 支持状态 |
|------|---------|---------|---------|
| Twitter/X | 280 字 | 短文/Thread | ✅ |
| LinkedIn | 1300 字 | 专业长文 | ✅ |
| YouTube | 视频脚本 | 10-20 分钟 | ✅ |
| Instagram | 2200 字 | 图文卡片 | ✅ |
| TikTok | 15-60秒 | 短视频脚本 | ✅ |

## 🤖 支持的 AI 平台

Viralfy 支持 13+ AI 助手,你可以使用任何一个:

- ⭐⭐⭐ **Claude Code** (推荐)
- ⭐⭐⭐ **Cursor** (推荐)
- ⭐⭐ **Gemini CLI**
- ⭐⭐ **Windsurf**
- ⭐ Roo Code、GitHub Copilot、Qwen Code、OpenCode、Codex CLI、Kilo Code、Auggie CLI、CodeBuddy、Amazon Q

## 📁 项目结构

```
viralfy/                        # 工具项目
├── src/                        # 源代码
│   ├── cli.ts                  # CLI 主程序
│   ├── types/                  # 类型定义
│   ├── utils/                  # 工具函数
│   └── commands/               # 命令处理器
├── scripts/                    # 脚本层
│   ├── bash/                   # POSIX Shell
│   └── powershell/             # Windows
├── templates/                  # AI 提示词模板
│   ├── commands/               # 命令模板
│   └── platforms/              # 平台配置
├── docs/                       # 文档
├── .claude/                    # Claude Code 配置
└── README.md

用户项目结构:
MyContent/                      # 你的内容项目
├── .viralfy/                   # 配置目录
│   ├── config.json             # 项目配置
│   ├── newsletter-progress.json# 创作进度
│   └── active-style.yaml       # 激活的风格
├── ideas/                      # 验证过的创意
│   └── validated-topics.json
├── research/                   # 研究材料
│   └── topic-001-knowledge-base.md
├── newsletters/                # Newsletter 源文件
│   └── issue-001/
│       ├── sections/           # 章节文件
│       └── newsletter.md       # 完整版本
├── distribution/               # 各平台内容
│   ├── twitter/
│   ├── xiaohongshu/
│   ├── linkedin/
│   └── ...
└── swipe-files/                # 爆款素材库
    ├── twitter/
    ├── analysis/
    └── personas/
```

## 🛠️ 技术架构

Viralfy 采用**三层架构 + AI 友好设计**:

```
┌─────────────────────────────────────────────────────┐
│                   CLI 层                             │
│        (TypeScript + Commander.js)                   │
│  命令路由、参数解析、脚本调度                           │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│                 脚本层                                │
│         (Bash + PowerShell)                          │
│  项目管理、文件操作、进度追踪                           │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│                模板层                                 │
│         (Markdown + YAML)                            │
│  AI 提示词、工作流定义、交互设计                        │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│                 AI 层                                 │
│         (13+ AI 平台集成)                             │
│  读取模板、执行工作流、与用户交互                        │
└─────────────────────────────────────────────────────┘
```

**核心特点**:
- ✅ **AI 友好**: Markdown + JSON + YAML,AI 易理解
- ✅ **模板驱动**: 修改工作流无需重新编译
- ✅ **跨平台**: Mac/Linux/Windows 全支持
- ✅ **增量生成**: 分段保存,断点续传
- ✅ **可扩展**: 插件化设计,易于扩展

## 📖 文档

- [PRD - 产品需求文档](docs/PRD.md) - 完整的产品设计和功能说明
- [ARCHITECTURE - 技术架构](docs/ARCHITECTURE.md) - 详细的技术架构设计
- [API - 接口设计](docs/API.md) - 命令接口和数据结构
- [IMPLEMENTATION_PLAN - 实施计划](docs/IMPLEMENTATION_PLAN.md) - 开发路线图
- [PLATFORM_SPECS - 平台规范](docs/PLATFORM_SPECS.md) - 各平台适配规范

## 🤝 贡献

欢迎贡献代码、报告问题或提出建议!

```bash
# Fork 项目
# 创建特性分支
git checkout -b feature/amazing-feature

# 提交更改
git commit -m 'Add amazing feature'

# 推送到分支
git push origin feature/amazing-feature

# 创建 Pull Request
```

## 📄 开源协议

[MIT License](LICENSE)

## 🙏 致谢

- **Dan Koe** - 提供了革命性的 AI 内容生态系统理念
- **courseify** - 提供了成熟的 AI 友好架构设计
- 所有开源贡献者

## 💬 联系我们

- **问题反馈**: [GitHub Issues](https://github.com/your-org/viralfy/issues)
- **功能建议**: [GitHub Discussions](https://github.com/your-org/viralfy/discussions)
- **Twitter**: [@viralfy](https://twitter.com/viralfy)

---

**让我们一起,用 AI 重新定义内容创作** 🚀

---

Made with ❤️ by Viralfy Team
