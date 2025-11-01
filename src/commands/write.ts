/**
 * Write Command
 * Create newsletter content with AI assistance
 */

import { interactive } from '../utils/interactive.js';
import { bashRunner } from '../utils/bash-runner.js';
import { FileManager } from '../utils/file-manager.js';
import { WriteOptions, CreationMode } from '../types/index.js';

export async function writeCommand(options: WriteOptions): Promise<void> {
  try {
    // 确保项目已初始化
    await FileManager.ensureProjectRoot();

    interactive.title('✍️  Newsletter 创作系统');

    // 执行 write.sh 脚本检查状态
    const spinner = interactive.spinner('检查创作状态...');
    let scriptResult;

    try {
      scriptResult = await bashRunner.execute('write');
      spinner.succeed('状态检查完成');
    } catch (error: any) {
      spinner.fail('状态检查失败');
      interactive.error(error.message);
      return;
    }

    interactive.newline();

    // 检查是否有未完成的 Newsletter
    if (scriptResult.action === 'resume') {
      await handleResumeNewsletter(scriptResult.data);
    } else {
      await handleCreateNewsletter(options);
    }

  } catch (error: any) {
    interactive.error(`Newsletter 创作失败: ${error.message}`);
    throw error;
  }
}

/**
 * 处理恢复 Newsletter 创作
 */
async function handleResumeNewsletter(data: any): Promise<void> {
  const progress = data.progress;

  interactive.box(
    `Newsletter ID: ${progress.newsletter_id}\n` +
    `主题: ${progress.topic_id}\n\n` +
    `进度: ${progress.completed_sections.length}/${progress.total_sections} 章节完成\n` +
    `当前章节: ${progress.current_section}\n` +
    `字数: ${progress.word_count}`,
    { title: '检测到未完成的 Newsletter', color: 'yellow' }
  );

  interactive.newline();

  const action = await interactive.select({
    message: '选择操作:',
    choices: [
      { name: '继续创作', value: 'continue', description: `从第 ${progress.current_section} 章节继续` },
      { name: '查看已完成部分', value: 'review', description: '查看已完成的章节' },
      { name: '重新开始', value: 'restart', description: '放弃当前进度,重新创作' },
      { name: '取消', value: 'cancel', description: '退出创作' }
    ]
  });

  switch (action) {
    case 'continue':
      interactive.info('请在 AI 助手中运行 /write 命令继续创作');
      interactive.newline();
      interactive.subtitle('提示:');
      interactive.info('AI 会自动从第 ' + progress.current_section + ' 章节开始');
      break;

    case 'review':
      // 显示已完成的章节
      interactive.subtitle('已完成的章节:');
      progress.completed_sections.forEach((sectionNum: number) => {
        interactive.success(`第 ${sectionNum} 章节`);
      });
      break;

    case 'restart':
      const confirmed = await interactive.confirm(
        '确定要放弃当前进度并重新开始?',
        false
      );
      if (confirmed) {
        await FileManager.clearNewsletterProgress();
        interactive.success('已清除进度,可以重新开始创作');
        // 重新开始创作流程
        await handleCreateNewsletter({});
      }
      break;

    case 'cancel':
      interactive.info('已取消创作');
      break;
  }
}

/**
 * 处理创建新 Newsletter
 */
async function handleCreateNewsletter(options: WriteOptions): Promise<void> {
  // 选择创作模式
  const mode = options.mode || await interactive.select<CreationMode>({
    message: '选择创作模式:',
    choices: [
      {
        name: '从零创作 (Create)',
        value: 'create',
        description: 'AI 作为写作教练,逐步引导你完成创作'
      },
      {
        name: '导入现有内容 (Import)',
        value: 'import',
        description: '导入 Markdown、PDF 或 URL,转换为 Newsletter'
      },
      {
        name: 'AI 辅助创作 (Assisted)',
        value: 'assisted',
        description: '基于研究材料,AI 生成初稿,你进行审核和修改'
      }
    ]
  });

  interactive.newline();

  // 根据模式展示不同的流程
  switch (mode) {
    case 'create':
      await showCreateModeInstructions();
      break;

    case 'import':
      await showImportModeInstructions();
      break;

    case 'assisted':
      await showAssistedModeInstructions();
      break;
  }
}

/**
 * 显示"从零创作"模式的说明
 */
async function showCreateModeInstructions(): Promise<void> {
  interactive.subtitle('从零创作模式');
  interactive.newline();

  interactive.info('在这个模式下,AI 会:');
  interactive.list([
    '基于你的研究材料提供大纲建议',
    '逐章节引导你创作',
    '提供写作建议和技巧',
    '自动保存进度,支持中断续写'
  ]);

  interactive.newline();
  interactive.subtitle('下一步:');
  interactive.info('1. 在 AI 助手中运行: /write');
  interactive.info('2. 选择要创作的主题 (从已验证的创意中选择)');
  interactive.info('3. 加载研究材料 (从知识库中选择)');
  interactive.info('4. AI 会提供大纲建议,你可以修改或接受');
  interactive.info('5. 开始逐章节创作');

  interactive.newline();
  interactive.box(
    '提示: AI 命令已配置在 .claude/commands/write.md\n' +
    '你可以直接在 Claude Code 中使用 /write 命令',
    { color: 'blue' }
  );
}

/**
 * 显示"导入现有内容"模式的说明
 */
async function showImportModeInstructions(): Promise<void> {
  interactive.subtitle('导入现有内容模式');
  interactive.newline();

  const sourceType = await interactive.select({
    message: '选择导入源:',
    choices: [
      { name: 'Markdown 文件', value: 'markdown' },
      { name: 'PDF 文档', value: 'pdf' },
      { name: '网页 URL', value: 'url' }
    ]
  });

  interactive.newline();

  switch (sourceType) {
    case 'markdown':
      const mdFile = await interactive.input({
        message: 'Markdown 文件路径:',
        validate: (input) => input.trim().length > 0 || '请输入文件路径'
      });
      interactive.info(`将导入: ${mdFile}`);
      break;

    case 'pdf':
      const pdfFile = await interactive.input({
        message: 'PDF 文件路径:',
        validate: (input) => input.trim().length > 0 || '请输入文件路径'
      });
      interactive.info(`将导入: ${pdfFile}`);
      break;

    case 'url':
      const url = await interactive.input({
        message: '网页 URL:',
        validate: (input) => {
          try {
            new URL(input);
            return true;
          } catch {
            return '请输入有效的 URL';
          }
        }
      });
      interactive.info(`将导入: ${url}`);
      break;
  }

  interactive.newline();
  interactive.subtitle('下一步:');
  interactive.info('在 AI 助手中运行 /write,选择"导入模式"');
  interactive.info('AI 会自动解析和转换内容');
}

/**
 * 显示"AI 辅助创作"模式的说明
 */
async function showAssistedModeInstructions(): Promise<void> {
  interactive.subtitle('AI 辅助创作模式');
  interactive.newline();

  interactive.info('在这个模式下,AI 会:');
  interactive.list([
    '基于你的主题和研究材料生成完整初稿',
    '包括大纲和各章节内容',
    '你可以逐章节审核和修改',
    '支持多轮迭代优化'
  ]);

  interactive.newline();
  interactive.warning('注意: 这个模式需要充足的研究材料作为基础');

  // 检查是否有研究材料
  const hasResearch = await checkResearchMaterials();

  if (!hasResearch) {
    interactive.newline();
    interactive.box(
      '建议先运行 viralfy research 进行深度研究\n' +
      '有充足的研究材料,AI 生成的内容质量会更高',
      { color: 'yellow' }
    );
  }

  interactive.newline();
  interactive.subtitle('下一步:');
  interactive.info('在 AI 助手中运行 /write,选择"AI 辅助"模式');
}

/**
 * 检查是否有研究材料
 */
async function checkResearchMaterials(): Promise<boolean> {
  try {
    const projectRoot = await FileManager.ensureProjectRoot();
    const researchDir = `${projectRoot}/research`;
    const exists = await FileManager.exists(researchDir);

    if (!exists) {
      return false;
    }

    // 简单检查是否有文件 (实际项目中可以更详细)
    return true;
  } catch {
    return false;
  }
}
