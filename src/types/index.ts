/**
 * Viralfy - Core Type Definitions
 * @module types
 */

// ============================================
// Project Configuration
// ============================================

export interface ProjectConfig {
  project_name: string;
  field: ContentField;
  platforms: Platform[];
  language: Language;
  default_style?: string;
  created_at: string;
  updated_at: string;
}

export type ContentField =
  | '编程开发'
  | '设计创意'
  | '商业管理'
  | '个人成长'
  | '营销推广'
  | '科技创新'
  | '生活方式'
  | '其他';

export type Language = 'zh-CN' | 'en-US' | 'bilingual';

export type Platform =
  // 中文平台
  | 'wechat'
  | 'xiaohongshu'
  | 'zhihu'
  | 'bilibili'
  | 'douyin'
  // 国际平台
  | 'twitter'
  | 'linkedin'
  | 'youtube'
  | 'instagram'
  | 'tiktok'
  | 'facebook'
  | 'medium'
  | 'substack'
  | 'threads'
  | 'bluesky';

// ============================================
// Idea Validation
// ============================================

export interface ValidatedTopic {
  id: string;
  title: string;
  source: 'twitter' | 'youtube' | 'manual';
  score: number; // 0-100
  metrics: TopicMetrics;
  validated_at: string;
  status: TopicStatus;
}

export interface TopicMetrics {
  likes?: number;
  retweets?: number;
  views?: number;
  comments?: number;
  engagement_rate?: number;
}

export type TopicStatus = 'pending' | 'researching' | 'writing' | 'distributed' | 'archived';

// ============================================
// Research
// ============================================

export interface ResearchMaterial {
  id: string;
  topic_id: string;
  source_type: 'youtube' | 'pdf' | 'article' | 'manual';
  source_url?: string;
  source_file?: string;
  title: string;
  summary: string;
  key_insights: string[];
  created_at: string;
}

export interface KnowledgeBase {
  topic_id: string;
  topic_title: string;
  core_insights: string[];
  key_arguments: string[];
  examples: string[];
  unique_perspectives: string[];
  sources: string[];
  created_at: string;
  updated_at: string;
}

// ============================================
// Newsletter Creation
// ============================================

export interface Newsletter {
  id: string;
  topic_id: string;
  title: string;
  subtitle?: string;
  mode: CreationMode;
  sections: NewsletterSection[];
  metadata: NewsletterMetadata;
  status: NewsletterStatus;
}

export type CreationMode = 'create' | 'import' | 'assisted';

export interface NewsletterSection {
  number: number;
  title: string;
  content: string;
  word_count: number;
  created_at: string;
}

export interface NewsletterMetadata {
  word_count: number;
  estimated_read_time: number; // minutes
  tags: string[];
  style?: string;
  created_at: string;
  updated_at: string;
}

export type NewsletterStatus = 'drafting' | 'reviewing' | 'completed' | 'distributed';

// ============================================
// Progress Tracking
// ============================================

export interface NewsletterProgress {
  newsletter_id: string;
  topic_id: string;
  total_sections: number;
  completed_sections: number[];
  current_section: number;
  status: NewsletterStatus;
  word_count: number;
  created_at: string;
  updated_at: string;
}

// ============================================
// Distribution
// ============================================

export interface DistributionJob {
  id: string;
  newsletter_id: string;
  platforms: Platform[];
  status: 'pending' | 'processing' | 'completed' | 'failed';
  results: DistributionResult[];
  created_at: string;
  completed_at?: string;
}

export interface DistributionResult {
  platform: Platform;
  posts: PlatformPost[];
  status: 'success' | 'failed';
  error?: string;
}

export interface PlatformPost {
  post_id: string;
  platform: Platform;
  variant: number;
  title?: string;
  content: string;
  metadata: PostMetadata;
  status: 'draft' | 'scheduled' | 'published';
  created_at: string;
}

export interface PostMetadata {
  word_count: number;
  character_count: number;
  hashtags?: string[];
  mentions?: string[];
  style?: string;
  hook_type?: string;
  estimated_performance?: number;
  best_time_to_post?: string;
}

// ============================================
// Swipe File & Analysis
// ============================================

export interface SwipePost {
  id: string;
  platform: Platform;
  url?: string;
  title?: string;
  content: string;
  author?: string;
  metrics: TopicMetrics;
  collected_at: string;
  tags: string[];
}

export interface ViralAnalysis {
  post_id: string;
  structure: ContentStructure;
  psychological_triggers: string[];
  writing_techniques: string[];
  style_features: StyleFeatures;
  reusable_template: ContentTemplate;
  created_at: string;
}

export interface ContentStructure {
  hook: string;
  hook_type: string;
  body_pattern: string;
  cta: string;
  cta_type: string;
  rhythm: string;
}

export interface StyleFeatures {
  tone: string;
  language_patterns: string[];
  signature_elements: string[];
  confidence_level: number;
  empathy_level: number;
  urgency_level: number;
}

export interface ContentTemplate {
  name: string;
  title_pattern: string;
  structure_pattern: string;
  applicable_scenarios: string[];
  example_usage: string;
}

// ============================================
// Persona (Writing Style)
// ============================================

export interface Persona {
  id: string;
  author: AuthorInfo;
  persona: PersonaProfile;
  examples: PersonaExample[];
  usage_guide: UsageGuide;
  created_at: string;
}

export interface AuthorInfo {
  name: string;
  platform: Platform;
  field: string;
  follower_count?: string;
}

export interface PersonaProfile {
  identity: string;
  teaching_philosophy: string[];
  communication_style: string;
  structure_patterns: Record<string, any>;
  signature_elements: Record<string, any>;
  psychological_triggers: Record<string, any>;
  tone: Record<string, any>;
}

export interface PersonaExample {
  title: string;
  structure: string;
  key_insights: string[];
  url?: string;
}

export interface UsageGuide {
  when_to_use: string[];
  how_to_adapt: string[];
  cautions?: string[];
}

// ============================================
// Script Responses
// ============================================

export interface ScriptResponse {
  status: 'success' | 'error';
  action?: 'create' | 'update' | 'resume';
  message?: string;
  data?: Record<string, any>;
}

// ============================================
// CLI Options
// ============================================

export interface InitOptions {
  interactive?: boolean;
}

export interface ValidateOptions {
  source?: 'twitter' | 'youtube' | 'both';
}

export interface ResearchOptions {
  topic?: string;
  sources?: string[];
}

export interface WriteOptions {
  mode?: CreationMode;
  topic?: string;
  resume?: boolean;
}

export interface DistributeOptions {
  newsletter: string;
  platforms?: string;
  all?: boolean;
}

export interface AnalyzeOptions {
  url: string;
}

export interface StyleOptions {
  author: string;
  platform?: Platform;
}

// ============================================
// Utility Types
// ============================================

export interface FileMetadata {
  path: string;
  size: number;
  created_at: string;
  updated_at: string;
}

export interface CommandMetadata {
  name: string;
  description: string;
  version: string;
  template_path: string;
  script_path: {
    sh: string;
    ps1: string;
  };
}

// ============================================
// Platform Specifications
// ============================================

export interface PlatformSpec {
  platform: Platform;
  name: string;
  constraints: {
    length?: number;
    title_length?: number;
    format: string;
  };
  content_requirements: string[];
  style: {
    tone: string;
    language: string;
    rhythm: string;
  };
  best_practices: string[];
  conversion_rules: Record<string, any>;
}

// ============================================
// Error Types
// ============================================

export class ViralfyError extends Error {
  constructor(
    message: string,
    public code: string,
    public details?: Record<string, any>
  ) {
    super(message);
    this.name = 'ViralfyError';
  }
}

export class ProjectNotInitializedError extends ViralfyError {
  constructor() {
    super(
      'Project not initialized. Run "viralfy init" first.',
      'PROJECT_NOT_INITIALIZED'
    );
  }
}

export class ScriptExecutionError extends ViralfyError {
  constructor(scriptName: string, details?: Record<string, any>) {
    super(
      `Script execution failed: ${scriptName}`,
      'SCRIPT_EXECUTION_ERROR',
      details
    );
  }
}

export class FileNotFoundError extends ViralfyError {
  constructor(filePath: string) {
    super(
      `File not found: ${filePath}`,
      'FILE_NOT_FOUND',
      { filePath }
    );
  }
}

export class InvalidConfigError extends ViralfyError {
  constructor(message: string, details?: Record<string, any>) {
    super(
      `Invalid configuration: ${message}`,
      'INVALID_CONFIG',
      details
    );
  }
}
