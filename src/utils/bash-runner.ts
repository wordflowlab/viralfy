/**
 * Bash Script Runner
 * Executes bash/powershell scripts and parses their JSON output
 */

import { exec } from 'child_process';
import { promisify } from 'util';
import * as path from 'path';
import * as fs from 'fs-extra';
import { ScriptResponse, ScriptExecutionError } from '../types/index.js';
import { fileURLToPath } from 'url';

const execAsync = promisify(exec);

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export class BashRunner {
  private scriptsDir: string;
  private scriptType: 'bash' | 'powershell';

  constructor() {
    // 定位到项目根目录的 scripts 目录
    this.scriptsDir = path.join(__dirname, '../../scripts');
    this.scriptType = this.detectScriptType();
  }

  /**
   * 检测操作系统,决定使用 Bash 还是 PowerShell
   */
  private detectScriptType(): 'bash' | 'powershell' {
    return process.platform === 'win32' ? 'powershell' : 'bash';
  }

  /**
   * 执行脚本并返回 JSON 结果
   * @param scriptName 脚本名称 (不含扩展名)
   * @param args 脚本参数
   * @returns 解析后的 JSON 对象
   */
  async execute(scriptName: string, args: string[] = []): Promise<ScriptResponse> {
    const ext = this.scriptType === 'bash' ? 'sh' : 'ps1';
    const scriptPath = path.join(
      this.scriptsDir,
      this.scriptType,
      `${scriptName}.${ext}`
    );

    // 检查脚本是否存在
    if (!await fs.pathExists(scriptPath)) {
      throw new ScriptExecutionError(scriptName, {
        reason: 'Script file not found',
        path: scriptPath
      });
    }

    // 构建执行命令
    const command = this.buildCommand(scriptPath, args);

    try {
      // 执行脚本
      const { stdout, stderr } = await execAsync(command, {
        cwd: process.cwd(),
        maxBuffer: 10 * 1024 * 1024, // 10MB
        env: {
          ...process.env,
          VIRALFY_VERSION: '1.0.0'
        }
      });

      // 如果有错误输出,记录但不抛出 (脚本可能只是警告)
      if (stderr && stderr.trim()) {
        console.warn(`Script warning: ${stderr.trim()}`);
      }

      // 解析 JSON 输出
      if (stdout.trim()) {
        try {
          const result = JSON.parse(stdout.trim());
          return result as ScriptResponse;
        } catch (parseError) {
          // 如果不是有效的 JSON,返回原始输出
          return {
            status: 'success',
            message: stdout.trim()
          };
        }
      }

      return { status: 'success' };
    } catch (error: any) {
      // 尝试解析错误输出中的 JSON
      if (error.stdout) {
        try {
          const errorResult = JSON.parse(error.stdout);
          if (errorResult.status === 'error') {
            return errorResult as ScriptResponse;
          }
        } catch {
          // 忽略解析错误,继续抛出原始错误
        }
      }

      throw new ScriptExecutionError(scriptName, {
        exitCode: error.code,
        stdout: error.stdout,
        stderr: error.stderr,
        message: error.message
      });
    }
  }

  /**
   * 构建执行命令
   */
  private buildCommand(scriptPath: string, args: string[]): string {
    const quotedPath = this.quotePath(scriptPath);
    const quotedArgs = args.map(arg => this.quotePath(arg)).join(' ');

    if (this.scriptType === 'bash') {
      return `bash ${quotedPath} ${quotedArgs}`.trim();
    } else {
      return `powershell -ExecutionPolicy Bypass -File ${quotedPath} ${quotedArgs}`.trim();
    }
  }

  /**
   * 为路径添加引号 (处理空格)
   */
  private quotePath(p: string): string {
    if (p.includes(' ')) {
      return `"${p}"`;
    }
    return p;
  }

  /**
   * 检查脚本是否存在
   */
  async scriptExists(scriptName: string): Promise<boolean> {
    const ext = this.scriptType === 'bash' ? 'sh' : 'ps1';
    const scriptPath = path.join(
      this.scriptsDir,
      this.scriptType,
      `${scriptName}.${ext}`
    );
    return fs.pathExists(scriptPath);
  }

  /**
   * 获取脚本路径
   */
  getScriptPath(scriptName: string): string {
    const ext = this.scriptType === 'bash' ? 'sh' : 'ps1';
    return path.join(
      this.scriptsDir,
      this.scriptType,
      `${scriptName}.${ext}`
    );
  }

  /**
   * 获取当前使用的脚本类型
   */
  getScriptType(): 'bash' | 'powershell' {
    return this.scriptType;
  }
}

/**
 * 导出单例实例
 */
export const bashRunner = new BashRunner();
