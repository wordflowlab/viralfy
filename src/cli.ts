#!/usr/bin/env node

/**
 * Viralfy CLI
 * AI-powered viral content ecosystem
 * @version 1.0.0
 */

import { Command } from '@commander-js/extra-typings';
import chalk from 'chalk';
import { initCommand } from './commands/init.js';
import { writeCommand } from './commands/write.js';
import {
  InitOptions,
  WriteOptions
} from './types/index.js';

const program = new Command();

// 版本和描述
program
  .name('viralfy')
  .version('1.0.0')
  .description(
    chalk.cyan('AI 驱动的病毒式内容生态系统') +
    '\n' +
    chalk.gray('从创意验证到多平台分发的完整解决方案')
  );

// ============================================
// init 命令 - 初始化项目
// ============================================
program
  .command('init')
  .description('初始化新的 Viralfy 内容项目')
  .option('-i, --interactive', '交互式模式 (默认)', true)
  .action(async (options: InitOptions) => {
    try {
      await initCommand();
    } catch (error: any) {
      console.error(chalk.red('错误:'), error.message);
      process.exit(1);
    }
  });

// ============================================
// validate 命令 - 通过 AI 助手执行
// ============================================
program
  .command('validate')
  .description('验证 Twitter/YouTube 内容创意 (使用 AI 助手执行 /validate)')
  .action(async () => {
    console.log(chalk.cyan('💡 使用 AI 助手执行:'));
    console.log(chalk.gray('在 AI 助手中输入: /validate'));
    console.log();
    console.log(chalk.gray('AI 助手会:'));
    console.log(chalk.gray('  1. 运行脚本获取状态'));
    console.log(chalk.gray('  2. 展示交互界面'));
    console.log(chalk.gray('  3. 执行创意验证流程'));
  });

// ============================================
// research 命令 - 通过 AI 助手执行
// ============================================
program
  .command('research')
  .description('使用 AI 进行深度研究 (使用 AI 助手执行 /research)')
  .action(async () => {
    console.log(chalk.cyan('💡 使用 AI 助手执行:'));
    console.log(chalk.gray('在 AI 助手中输入: /research'));
    console.log();
    console.log(chalk.gray('AI 助手会:'));
    console.log(chalk.gray('  1. 运行脚本获取状态'));
    console.log(chalk.gray('  2. 展示主题选择界面'));
    console.log(chalk.gray('  3. 执行深度研究流程'));
  });

// ============================================
// write 命令 - Newsletter 创作
// ============================================
program
  .command('write')
  .description('创作 Newsletter 内容')
  .option(
    '-m, --mode <mode>',
    '创作模式: create, import, assisted'
  )
  .option('-t, --topic <id>', '要写作的主题 ID')
  .option('-r, --resume', '从之前的进度继续', false)
  .action(async (options: any) => {
    try {
      await writeCommand(options);
    } catch (error: any) {
      console.error(chalk.red('错误:'), error.message);
      process.exit(1);
    }
  });

// ============================================
// distribute 命令 - 通过 AI 助手执行
// ============================================
program
  .command('distribute')
  .description('将 Newsletter 分发到多个平台 (使用 AI 助手执行 /distribute)')
  .action(async () => {
    console.log(chalk.cyan('💡 使用 AI 助手执行:'));
    console.log(chalk.gray('在 AI 助手中输入: /distribute'));
    console.log();
    console.log(chalk.gray('AI 助手会:'));
    console.log(chalk.gray('  1. 运行脚本获取 Newsletter 列表'));
    console.log(chalk.gray('  2. 展示平台选择界面'));
    console.log(chalk.gray('  3. 执行多平台分发流程'));
  });

// ============================================
// analyze 命令 - 通过 AI 助手执行
// ============================================
program
  .command('analyze')
  .description('分析爆款内容结构 (使用 AI 助手执行 /analyze)')
  .action(async () => {
    console.log(chalk.cyan('💡 使用 AI 助手执行:'));
    console.log(chalk.gray('在 AI 助手中输入: /analyze'));
    console.log();
    console.log(chalk.gray('AI 助手会:'));
    console.log(chalk.gray('  1. 获取要分析的 URL'));
    console.log(chalk.gray('  2. 多维度分析内容结构'));
    console.log(chalk.gray('  3. 生成可复用模板'));
  });

// ============================================
// style 命令 - 通过 AI 助手执行
// ============================================
program
  .command('style')
  .description('训练写作风格人设 (使用 AI 助手执行 /style)')
  .action(async () => {
    console.log(chalk.cyan('💡 使用 AI 助手执行:'));
    console.log(chalk.gray('在 AI 助手中输入: /style'));
    console.log();
    console.log(chalk.gray('AI 助手会:'));
    console.log(chalk.gray('  1. 获取作者信息'));
    console.log(chalk.gray('  2. 收集代表作品'));
    console.log(chalk.gray('  3. 生成 Persona 配置'));
  });

// ============================================
// status 命令 - 项目状态
// ============================================
program
  .command('status')
  .description('显示项目状态和进度')
  .action(async () => {
    try {
      const { FileManager } = await import('./utils/file-manager.js');

      const isInitialized = await FileManager.isProjectInitialized();

      if (!isInitialized) {
        console.log(chalk.red('✗'), '项目未初始化');
        console.log();
        console.log(chalk.gray('运行'), chalk.cyan('viralfy init'), chalk.gray('开始使用'));
        return;
      }

      const config = await FileManager.readConfig();
      const progress = await FileManager.readNewsletterProgress();

      console.log();
      console.log(chalk.bold.cyan('📊 项目状态'));
      console.log(chalk.gray('─'.repeat(50)));
      console.log();

      console.log(chalk.bold('项目:'), config.project_name);
      console.log(chalk.bold('领域:'), config.field);
      console.log(chalk.bold('平台:'), config.platforms.join(', '));
      console.log(chalk.bold('语言:'), config.language);

      console.log();

      if (progress) {
        console.log(chalk.bold('当前 Newsletter:'), progress.newsletter_id);
        console.log(chalk.bold('进度:'), `${progress.completed_sections.length}/${progress.total_sections} 章节`);
        console.log(chalk.bold('状态:'), progress.status);
        console.log(chalk.bold('字数:'), progress.word_count);
      } else {
        console.log(chalk.gray('暂无进行中的 Newsletter'));
      }

      console.log();
    } catch (error: any) {
      console.error(chalk.red('错误:'), error.message);
      process.exit(1);
    }
  });

// ============================================
// help 命令 - 显示帮助信息
// ============================================
program
  .command('help [command]')
  .description('显示命令帮助信息')
  .action((command?: string) => {
    showWelcome();
    program.help();
  });

// ============================================
// 默认行为
// ============================================
program.on('--help', () => {
  console.log();
  console.log(chalk.bold('示例:'));
  console.log();
  console.log('  $ viralfy init                           ', chalk.gray('# 初始化项目'));
  console.log('  $ viralfy validate                       ', chalk.gray('# 验证创意'));
  console.log('  $ viralfy research --topic topic-001     ', chalk.gray('# 研究主题'));
  console.log('  $ viralfy write --mode create            ', chalk.gray('# 创作 Newsletter'));
  console.log('  $ viralfy distribute -n issue-001 --all  ', chalk.gray('# 分发到所有平台'));
  console.log();
  console.log(chalk.bold('了解更多:'));
  console.log('  文档: ', chalk.cyan('https://github.com/your-org/viralfy'));
  console.log('  报告问题: ', chalk.cyan('https://github.com/your-org/viralfy/issues'));
  console.log();
});

// ============================================
// 欢迎信息
// ============================================
function showWelcome(): void {
  console.log();
  console.log(chalk.bold.cyan('╔════════════════════════════════════════════════╗'));
  console.log(chalk.bold.cyan('║                                                ║'));
  console.log(chalk.bold.cyan('║  ') + chalk.bold.white('Viralfy') + chalk.bold.cyan('  🚀                                ║'));
  console.log(chalk.bold.cyan('║  ') + chalk.gray('AI 驱动的病毒式内容生态系统') + chalk.bold.cyan('           ║'));
  console.log(chalk.bold.cyan('║                                                ║'));
  console.log(chalk.bold.cyan('╚════════════════════════════════════════════════╝'));
  console.log();
}

// ============================================
// 错误处理
// ============================================
process.on('unhandledRejection', (error: any) => {
  console.error(chalk.red('未处理的错误:'), error.message);
  process.exit(1);
});

// 如果没有参数,显示欢迎和帮助
if (process.argv.length === 2) {
  showWelcome();
}

// ============================================
// 解析命令
// ============================================
program.parse(process.argv);
