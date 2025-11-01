/**
 * Interactive UI Utilities
 * Provides interactive command-line interface helpers
 */

import inquirer from 'inquirer';
import chalk from 'chalk';
import ora, { Ora } from 'ora';

export class Interactive {
  /**
   * 显示加载动画
   */
  spinner(text: string): Ora {
    return ora(text).start();
  }

  /**
   * 单选问题
   */
  async select<T = string>(options: {
    message: string;
    choices: Array<{ name: string; value: T; description?: string }>;
    default?: T;
  }): Promise<T> {
    const { answer } = await inquirer.prompt([
      {
        type: 'list',
        name: 'answer',
        message: options.message,
        choices: options.choices.map(choice => ({
          name: choice.description
            ? `${choice.name} - ${chalk.gray(choice.description)}`
            : choice.name,
          value: choice.value,
          short: choice.name
        })),
        default: options.default
      }
    ]);
    return answer;
  }

  /**
   * 多选问题
   */
  async multiSelect<T = string>(options: {
    message: string;
    choices: Array<{ name: string; value: T; checked?: boolean; description?: string }>;
  }): Promise<T[]> {
    const { answers } = await inquirer.prompt([
      {
        type: 'checkbox',
        name: 'answers',
        message: options.message,
        choices: options.choices.map(choice => ({
          name: choice.description
            ? `${choice.name} - ${chalk.gray(choice.description)}`
            : choice.name,
          value: choice.value,
          checked: choice.checked || false,
          short: choice.name
        }))
      }
    ]);
    return answers;
  }

  /**
   * 文本输入
   */
  async input(options: {
    message: string;
    default?: string;
    validate?: (input: string) => boolean | string;
  }): Promise<string> {
    const { answer } = await inquirer.prompt([
      {
        type: 'input',
        name: 'answer',
        message: options.message,
        default: options.default,
        validate: options.validate
      }
    ]);
    return answer;
  }

  /**
   * 确认问题
   */
  async confirm(message: string, defaultValue = false): Promise<boolean> {
    const { answer } = await inquirer.prompt([
      {
        type: 'confirm',
        name: 'answer',
        message: message,
        default: defaultValue
      }
    ]);
    return answer;
  }

  /**
   * 密码输入
   */
  async password(message: string): Promise<string> {
    const { answer } = await inquirer.prompt([
      {
        type: 'password',
        name: 'answer',
        message: message,
        mask: '*'
      }
    ]);
    return answer;
  }

  /**
   * 编辑器输入 (多行文本)
   */
  async editor(options: {
    message: string;
    default?: string;
  }): Promise<string> {
    const { answer } = await inquirer.prompt([
      {
        type: 'editor',
        name: 'answer',
        message: options.message,
        default: options.default
      }
    ]);
    return answer;
  }

  /**
   * 成功消息
   */
  success(message: string): void {
    console.log(chalk.green('✓'), message);
  }

  /**
   * 错误消息
   */
  error(message: string): void {
    console.log(chalk.red('✗'), message);
  }

  /**
   * 警告消息
   */
  warning(message: string): void {
    console.log(chalk.yellow('⚠'), message);
  }

  /**
   * 信息消息
   */
  info(message: string): void {
    console.log(chalk.blue('ℹ'), message);
  }

  /**
   * 标题
   */
  title(message: string): void {
    console.log();
    console.log(chalk.bold.cyan(message));
    console.log(chalk.gray('─'.repeat(message.length)));
  }

  /**
   * 子标题
   */
  subtitle(message: string): void {
    console.log();
    console.log(chalk.bold(message));
  }

  /**
   * 分隔线
   */
  divider(): void {
    console.log(chalk.gray('─'.repeat(50)));
  }

  /**
   * 空行
   */
  newline(count = 1): void {
    for (let i = 0; i < count; i++) {
      console.log();
    }
  }

  /**
   * 表格显示
   */
  table(headers: string[], rows: string[][]): void {
    // 计算每列的最大宽度
    const columnWidths = headers.map((header, i) => {
      const maxRowWidth = Math.max(...rows.map(row => (row[i] || '').length));
      return Math.max(header.length, maxRowWidth);
    });

    // 绘制表头
    const headerRow = headers
      .map((header, i) => header.padEnd(columnWidths[i]))
      .join(' │ ');
    console.log(chalk.bold(headerRow));

    // 绘制分隔线
    const separator = columnWidths.map(width => '─'.repeat(width)).join('─┼─');
    console.log(chalk.gray(separator));

    // 绘制数据行
    rows.forEach(row => {
      const dataRow = row
        .map((cell, i) => (cell || '').padEnd(columnWidths[i]))
        .join(' │ ');
      console.log(dataRow);
    });
  }

  /**
   * 列表显示
   */
  list(items: string[]): void {
    items.forEach((item, index) => {
      console.log(chalk.gray(`${index + 1}.`), item);
    });
  }

  /**
   * 进度条 (简单实现)
   */
  progress(current: number, total: number, label?: string): void {
    const percentage = Math.round((current / total) * 100);
    const filled = Math.round((current / total) * 20);
    const empty = 20 - filled;

    const bar = chalk.green('█'.repeat(filled)) + chalk.gray('░'.repeat(empty));
    const text = label
      ? `${label} ${bar} ${percentage}% (${current}/${total})`
      : `${bar} ${percentage}% (${current}/${total})`;

    process.stdout.write(`\r${text}`);

    if (current === total) {
      process.stdout.write('\n');
    }
  }

  /**
   * 代码块显示
   */
  code(code: string, language?: string): void {
    const languageLabel = language ? chalk.gray(`[${language}]`) : '';
    console.log(languageLabel);
    console.log(chalk.dim('┌' + '─'.repeat(48) + '┐'));
    code.split('\n').forEach(line => {
      console.log(chalk.dim('│'), chalk.cyan(line));
    });
    console.log(chalk.dim('└' + '─'.repeat(48) + '┘'));
  }

  /**
   * JSON 显示
   */
  json(data: any): void {
    console.log(chalk.gray(JSON.stringify(data, null, 2)));
  }

  /**
   * Box 包裹的消息
   */
  box(message: string, options?: { title?: string; color?: 'green' | 'red' | 'yellow' | 'blue' }): void {
    const lines = message.split('\n');
    const maxLength = Math.max(...lines.map(line => line.length));
    const width = maxLength + 4;

    const colorFn = options?.color
      ? chalk[options.color]
      : (text: string) => text;

    if (options?.title) {
      console.log(colorFn('┌─ ' + options.title + ' ' + '─'.repeat(width - options.title.length - 4) + '┐'));
    } else {
      console.log(colorFn('┌' + '─'.repeat(width) + '┐'));
    }

    lines.forEach(line => {
      const padding = ' '.repeat(maxLength - line.length);
      console.log(colorFn('│  ' + line + padding + '  │'));
    });

    console.log(colorFn('└' + '─'.repeat(width) + '┘'));
  }
}

/**
 * 导出单例实例
 */
export const interactive = new Interactive();
