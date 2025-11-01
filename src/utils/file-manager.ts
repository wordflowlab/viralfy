/**
 * File Manager
 * Handles file operations for Viralfy projects
 */

import * as fs from 'fs-extra';
import * as path from 'path';
import * as yaml from 'js-yaml';
import {
  ProjectConfig,
  NewsletterProgress,
  ValidatedTopic,
  KnowledgeBase,
  Newsletter,
  Persona,
  ProjectNotInitializedError,
  FileNotFoundError,
  InvalidConfigError
} from '../types/index.js';

export class FileManager {
  private static readonly CONFIG_DIR = '.viralfy';
  private static readonly CONFIG_FILE = 'config.json';

  /**
   * 查找项目根目录 (向上查找 .viralfy/config.json)
   */
  static async findProjectRoot(startDir: string = process.cwd()): Promise<string | null> {
    let currentDir = startDir;

    while (currentDir !== path.parse(currentDir).root) {
      const configPath = path.join(currentDir, this.CONFIG_DIR, this.CONFIG_FILE);
      if (await fs.pathExists(configPath)) {
        return currentDir;
      }
      currentDir = path.dirname(currentDir);
    }

    return null;
  }

  /**
   * 确保在项目根目录中执行
   */
  static async ensureProjectRoot(): Promise<string> {
    const projectRoot = await this.findProjectRoot();
    if (!projectRoot) {
      throw new ProjectNotInitializedError();
    }
    return projectRoot;
  }

  /**
   * 检查项目是否已初始化
   */
  static async isProjectInitialized(): Promise<boolean> {
    const projectRoot = await this.findProjectRoot();
    return projectRoot !== null;
  }

  /**
   * 读取项目配置
   */
  static async readConfig(): Promise<ProjectConfig> {
    const projectRoot = await this.ensureProjectRoot();
    const configPath = path.join(projectRoot, this.CONFIG_DIR, this.CONFIG_FILE);

    try {
      const data = await fs.readJSON(configPath);
      return data as ProjectConfig;
    } catch (error) {
      throw new InvalidConfigError('Failed to read config file', { error });
    }
  }

  /**
   * 写入项目配置
   */
  static async writeConfig(config: ProjectConfig): Promise<void> {
    const projectRoot = await this.ensureProjectRoot();
    const configPath = path.join(projectRoot, this.CONFIG_DIR, this.CONFIG_FILE);

    await fs.writeJSON(configPath, config, { spaces: 2 });
  }

  /**
   * 更新项目配置
   */
  static async updateConfig(updates: Partial<ProjectConfig>): Promise<void> {
    const config = await this.readConfig();
    const updatedConfig = {
      ...config,
      ...updates,
      updated_at: new Date().toISOString()
    };
    await this.writeConfig(updatedConfig);
  }

  /**
   * 读取 Newsletter 进度
   */
  static async readNewsletterProgress(): Promise<NewsletterProgress | null> {
    const projectRoot = await this.ensureProjectRoot();
    const progressPath = path.join(projectRoot, this.CONFIG_DIR, 'newsletter-progress.json');

    if (!await fs.pathExists(progressPath)) {
      return null;
    }

    try {
      return await fs.readJSON(progressPath);
    } catch {
      return null;
    }
  }

  /**
   * 写入 Newsletter 进度
   */
  static async writeNewsletterProgress(progress: NewsletterProgress): Promise<void> {
    const projectRoot = await this.ensureProjectRoot();
    const progressPath = path.join(projectRoot, this.CONFIG_DIR, 'newsletter-progress.json');

    await fs.writeJSON(progressPath, progress, { spaces: 2 });
  }

  /**
   * 清除 Newsletter 进度
   */
  static async clearNewsletterProgress(): Promise<void> {
    const projectRoot = await this.ensureProjectRoot();
    const progressPath = path.join(projectRoot, this.CONFIG_DIR, 'newsletter-progress.json');

    if (await fs.pathExists(progressPath)) {
      await fs.remove(progressPath);
    }
  }

  /**
   * 读取验证过的主题列表
   */
  static async readValidatedTopics(): Promise<ValidatedTopic[]> {
    const projectRoot = await this.ensureProjectRoot();
    const topicsPath = path.join(projectRoot, 'ideas', 'validated-topics.json');

    if (!await fs.pathExists(topicsPath)) {
      return [];
    }

    try {
      const data = await fs.readJSON(topicsPath);
      return data.topics || [];
    } catch {
      return [];
    }
  }

  /**
   * 写入验证过的主题
   */
  static async writeValidatedTopics(topics: ValidatedTopic[]): Promise<void> {
    const projectRoot = await this.ensureProjectRoot();
    const topicsPath = path.join(projectRoot, 'ideas', 'validated-topics.json');

    await fs.ensureDir(path.dirname(topicsPath));
    await fs.writeJSON(topicsPath, { topics }, { spaces: 2 });
  }

  /**
   * 读取知识库
   */
  static async readKnowledgeBase(topicId: string): Promise<KnowledgeBase | null> {
    const projectRoot = await this.ensureProjectRoot();
    const kbPath = path.join(projectRoot, 'research', `${topicId}-knowledge-base.md`);

    if (!await fs.pathExists(kbPath)) {
      return null;
    }

    // 简单实现: 读取 Markdown 内容
    // 实际项目中可以解析 frontmatter
    const content = await fs.readFile(kbPath, 'utf-8');
    return {
      topic_id: topicId,
      topic_title: '',
      core_insights: [],
      key_arguments: [],
      examples: [],
      unique_perspectives: [],
      sources: [],
      created_at: '',
      updated_at: ''
    };
  }

  /**
   * 写入知识库
   */
  static async writeKnowledgeBase(topicId: string, content: string): Promise<void> {
    const projectRoot = await this.ensureProjectRoot();
    const kbPath = path.join(projectRoot, 'research', `${topicId}-knowledge-base.md`);

    await fs.ensureDir(path.dirname(kbPath));
    await fs.writeFile(kbPath, content, 'utf-8');
  }

  /**
   * 读取 Newsletter
   */
  static async readNewsletter(newsletterId: string): Promise<Newsletter | null> {
    const projectRoot = await this.ensureProjectRoot();
    const newsletterPath = path.join(projectRoot, 'newsletters', newsletterId, 'newsletter.md');

    if (!await fs.pathExists(newsletterPath)) {
      return null;
    }

    // 简化实现
    return null;
  }

  /**
   * 保存 Newsletter 章节
   */
  static async saveNewsletterSection(
    newsletterId: string,
    sectionNumber: number,
    content: string
  ): Promise<void> {
    const projectRoot = await this.ensureProjectRoot();
    const sectionDir = path.join(projectRoot, 'newsletters', newsletterId, 'sections');
    const sectionFile = path.join(sectionDir, `${String(sectionNumber).padStart(2, '0')}-section.md`);

    await fs.ensureDir(sectionDir);
    await fs.writeFile(sectionFile, content, 'utf-8');
  }

  /**
   * 读取 Persona
   */
  static async readPersona(personaId: string): Promise<Persona | null> {
    const projectRoot = await this.ensureProjectRoot();
    const personaPath = path.join(projectRoot, 'swipe-files', 'personas', `${personaId}.yaml`);

    if (!await fs.pathExists(personaPath)) {
      return null;
    }

    try {
      const content = await fs.readFile(personaPath, 'utf-8');
      const data = yaml.load(content) as any;
      return data as Persona;
    } catch (error) {
      throw new FileNotFoundError(personaPath);
    }
  }

  /**
   * 列出所有 Personas
   */
  static async listPersonas(): Promise<string[]> {
    const projectRoot = await this.ensureProjectRoot();
    const personasDir = path.join(projectRoot, 'swipe-files', 'personas');

    if (!await fs.pathExists(personasDir)) {
      return [];
    }

    const files = await fs.readdir(personasDir);
    return files
      .filter(file => file.endsWith('.yaml') || file.endsWith('.yml'))
      .map(file => path.basename(file, path.extname(file)));
  }

  /**
   * 确保目录存在
   */
  static async ensureDir(dirPath: string): Promise<void> {
    await fs.ensureDir(dirPath);
  }

  /**
   * 读取 JSON 文件
   */
  static async readJSON<T>(filePath: string): Promise<T> {
    try {
      return await fs.readJSON(filePath);
    } catch (error) {
      throw new FileNotFoundError(filePath);
    }
  }

  /**
   * 写入 JSON 文件
   */
  static async writeJSON(filePath: string, data: any): Promise<void> {
    await fs.ensureDir(path.dirname(filePath));
    await fs.writeJSON(filePath, data, { spaces: 2 });
  }

  /**
   * 读取文本文件
   */
  static async readText(filePath: string): Promise<string> {
    try {
      return await fs.readFile(filePath, 'utf-8');
    } catch (error) {
      throw new FileNotFoundError(filePath);
    }
  }

  /**
   * 写入文本文件
   */
  static async writeText(filePath: string, content: string): Promise<void> {
    await fs.ensureDir(path.dirname(filePath));
    await fs.writeFile(filePath, content, 'utf-8');
  }

  /**
   * 检查文件是否存在
   */
  static async exists(filePath: string): Promise<boolean> {
    return fs.pathExists(filePath);
  }

  /**
   * 删除文件
   */
  static async remove(filePath: string): Promise<void> {
    await fs.remove(filePath);
  }

  /**
   * 复制文件
   */
  static async copy(src: string, dest: string): Promise<void> {
    await fs.ensureDir(path.dirname(dest));
    await fs.copy(src, dest);
  }

  /**
   * 获取文件统计信息
   */
  static async stat(filePath: string): Promise<fs.Stats> {
    return fs.stat(filePath);
  }
}
