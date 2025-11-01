/**
 * Init Command
 * Initialize a new Viralfy project
 */

import * as path from 'path';
import { interactive } from '../utils/interactive.js';
import { bashRunner } from '../utils/bash-runner.js';
import { FileManager } from '../utils/file-manager.js';
import { ProjectConfig, ContentField, Platform, Language } from '../types/index.js';

export async function initCommand(): Promise<void> {
  try {
    interactive.title('🚀 Viralfy 项目初始化');

    // 检查是否已经初始化
    const isInitialized = await FileManager.isProjectInitialized();
    if (isInitialized) {
      const shouldContinue = await interactive.confirm(
        '项目已经初始化,是否要重新配置?',
        false
      );
      if (!shouldContinue) {
        interactive.info('初始化已取消');
        return;
      }
    }

    interactive.newline();

    // 1. 项目名称
    const projectName = await interactive.input({
      message: '项目名称:',
      default: path.basename(process.cwd()),
      validate: (input) => input.trim().length > 0 || '项目名称不能为空'
    });

    // 2. 内容领域
    const field = await interactive.select<ContentField>({
      message: '选择内容领域:',
      choices: [
        { name: '编程开发', value: '编程开发', description: '技术教程、编程实践' },
        { name: '设计创意', value: '设计创意', description: 'UI/UX、平面设计' },
        { name: '商业管理', value: '商业管理', description: '创业、管理、商业分析' },
        { name: '个人成长', value: '个人成长', description: '自我提升、生产力' },
        { name: '营销推广', value: '营销推广', description: '数字营销、增长黑客' },
        { name: '科技创新', value: '科技创新', description: 'AI、Web3、前沿科技' },
        { name: '生活方式', value: '生活方式', description: '健康、旅行、生活' },
        { name: '其他', value: '其他', description: '自定义领域' }
      ]
    });

    // 3. 目标平台
    interactive.subtitle('选择目标平台 (可多选):');
    const platforms = await interactive.multiSelect<Platform>({
      message: '目标平台:',
      choices: [
        { name: '✓ 微信公众号', value: 'wechat', description: '长文深度内容', checked: true },
        { name: '✓ 小红书', value: 'xiaohongshu', description: '生活化图文', checked: true },
        { name: '✓ 知乎', value: 'zhihu', description: '问答式深度', checked: false },
        { name: '  B站', value: 'bilibili', description: '视频脚本' },
        { name: '  抖音', value: 'douyin', description: '短视频脚本' },
        { name: '✓ Twitter/X', value: 'twitter', description: '短文/Thread', checked: true },
        { name: '✓ LinkedIn', value: 'linkedin', description: '专业长文', checked: false },
        { name: '  YouTube', value: 'youtube', description: '视频脚本' },
        { name: '  Instagram', value: 'instagram', description: '图文卡片' },
        { name: '  TikTok', value: 'tiktok', description: '短视频脚本' }
      ]
    });

    if (platforms.length === 0) {
      interactive.warning('至少选择一个平台');
      return;
    }

    // 4. 内容语言
    const language = await interactive.select<Language>({
      message: '内容语言:',
      choices: [
        { name: '中文', value: 'zh-CN', description: '简体中文内容' },
        { name: '英文', value: 'en-US', description: 'English content' },
        { name: '双语', value: 'bilingual', description: '中英文双语' }
      ],
      default: 'zh-CN'
    });

    interactive.newline();

    // 执行初始化脚本
    const spinner = interactive.spinner('正在创建项目结构...');

    try {
      // 调用 init.sh 脚本
      const result = await bashRunner.execute('init');

      if (result.status === 'success') {
        // 创建配置文件
        const config: ProjectConfig = {
          project_name: projectName,
          field,
          platforms,
          language,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        };

        await FileManager.writeConfig(config);

        spinner.succeed('项目结构创建成功!');
      } else {
        spinner.fail('项目结构创建失败');
        interactive.error(result.message || '未知错误');
        return;
      }
    } catch (error: any) {
      spinner.fail('项目结构创建失败');
      interactive.error(error.message);
      return;
    }

    // 显示项目信息
    interactive.newline();
    interactive.box(
      `项目名称: ${projectName}\n` +
      `内容领域: ${field}\n` +
      `目标平台: ${platforms.join(', ')}\n` +
      `内容语言: ${language}`,
      { title: '项目配置', color: 'green' }
    );

    // 显示目录结构
    interactive.newline();
    interactive.subtitle('已创建目录结构:');
    interactive.list([
      '.viralfy/          - 配置目录',
      'ideas/             - 验证过的创意',
      'research/          - 研究材料',
      'newsletters/       - Newsletter 源文件',
      'distribution/      - 各平台内容',
      'swipe-files/       - 爆款素材库'
    ]);

    interactive.newline();
    interactive.subtitle('已创建示例文件:');
    interactive.list([
      '.gitignore         - Git 忽略规则',
      'README.md          - 项目说明文档',
      'ideas/validated-topics.json - 创意列表'
    ]);

    // 显示下一步操作
    interactive.newline();
    interactive.subtitle('下一步操作:');
    interactive.list([
      'viralfy validate   - 验证创意 (从 Twitter/YouTube 分析)',
      'viralfy research   - 深度研究 (AI 辅助知识提炼)',
      'viralfy write      - 创作 Newsletter',
      'viralfy distribute - 多平台分发'
    ]);

    interactive.newline();
    interactive.success('初始化完成! 🎉');

  } catch (error: any) {
    interactive.error(`初始化失败: ${error.message}`);
    throw error;
  }
}
