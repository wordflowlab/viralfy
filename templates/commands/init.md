---
description: Initialize a new Viralfy content project
scripts:
  sh: ../../scripts/bash/init.sh
  ps1: ../../scripts/powershell/Init.ps1
version: 1.0.0
---

# /init - Viralfy 项目初始化

## 概述

这个命令会初始化一个新的 Viralfy 内容项目,创建必要的目录结构和配置文件。

## 第一步: 执行初始化脚本

执行以下命令来创建项目结构:

```bash
bash scripts/bash/init.sh
```

脚本会返回一个 JSON 对象,包含初始化状态。

## 第二步: 解析返回结果

脚本返回的 JSON 格式:

```json
{
  "status": "success",
  "action": "create" | "update",
  "config_file": ".viralfy/config.json",
  "directories": ["ideas", "research", "newsletters", "distribution", "swipe-files"],
  "message": "Project structure created successfully."
}
```

根据 `action` 字段展示不同的界面。

## 第三步: 配置项目

### 如果 action === "create" (新建项目)

引导用户完成以下配置:

#### 1. 项目名称

```
项目名称: _
```

默认值: 当前目录名

#### 2. 内容领域

```
选择内容领域:

1. 编程开发 - 技术教程、编程实践
2. 设计创意 - UI/UX、平面设计
3. 商业管理 - 创业、管理、商业分析
4. 个人成长 - 自我提升、生产力
5. 营销推广 - 数字营销、增长黑客
6. 科技创新 - AI、Web3、前沿科技
7. 生活方式 - 健康、旅行、生活
8. 其他 - 自定义领域

请选择 (1-8): _
```

#### 3. 目标平台 (可多选)

```
选择目标平台 (可多选,空格选择,回车确认):

中文平台:
[ ] 微信公众号  - 长文深度内容
[ ] 小红书      - 生活化图文
[ ] 知乎        - 问答式深度
[ ] B站         - 视频脚本
[ ] 抖音        - 短视频脚本

国际平台:
[ ] Twitter/X   - 短文/Thread
[ ] LinkedIn    - 专业长文
[ ] YouTube     - 视频脚本
[ ] Instagram   - 图文卡片
[ ] TikTok      - 短视频脚本

已选择: _
```

#### 4. 内容语言

```
内容语言:

1. 中文 - 简体中文内容
2. 英文 - English content
3. 双语 - 中英文双语

请选择 (1-3): _
```

### 如果 action === "update" (更新配置)

显示当前配置,询问是否要修改:

```
当前项目配置:

项目名称: 我的内容项目
内容领域: 编程开发
目标平台: 微信公众号, 小红书, Twitter/X
内容语言: 中文

是否要修改配置? (y/n): _
```

## 第四步: 保存配置

将用户输入的配置保存到 `.viralfy/config.json`:

```json
{
  "project_name": "我的内容项目",
  "field": "编程开发",
  "platforms": ["wechat", "xiaohongshu", "twitter"],
  "language": "zh-CN",
  "created_at": "2025-11-01T10:00:00Z",
  "updated_at": "2025-11-01T10:00:00Z"
}
```

## 第五步: 显示完成信息

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ 项目初始化完成!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

项目配置:
  项目名称: 我的内容项目
  内容领域: 编程开发
  目标平台: 微信公众号, 小红书, Twitter/X
  内容语言: 中文

已创建目录:
  ✓ .viralfy/          - 配置目录
  ✓ ideas/             - 验证过的创意
  ✓ research/          - 研究材料
  ✓ newsletters/       - Newsletter 源文件
  ✓ distribution/      - 各平台内容
  ✓ swipe-files/       - 爆款素材库

下一步操作:
  1. viralfy validate   - 验证创意 (从 Twitter/YouTube 分析)
  2. viralfy research   - 深度研究 (AI 辅助知识提炼)
  3. viralfy write      - 创作 Newsletter
  4. viralfy distribute - 多平台分发

开始创作吧! 🚀
```

## 最佳实践

1. **选择合适的领域**: 根据你的专业领域和兴趣选择,这会影响后续的创意验证和内容创作
2. **精选平台**: 不要贪多,选择 3-5 个你最了解和最想发力的平台
3. **语言一致性**: 如果选择双语,需要投入更多精力维护两套内容
4. **目录结构**: 保持默认的目录结构,有助于工具的正常运行

## 故障排除

### 问题 1: 脚本执行失败

**症状**: 脚本返回错误状态

**解决方案**:
- 检查是否有写入权限
- 确保当前目录不是系统目录
- 查看错误消息获取详细信息

### 问题 2: 配置文件已存在

**症状**: 提示项目已初始化

**解决方案**:
- 如果想重新配置,删除 `.viralfy/config.json` 后重试
- 或者使用 update 模式修改配置

## 相关命令

- `viralfy status` - 查看项目状态
- `viralfy help` - 查看帮助信息
