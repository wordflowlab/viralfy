# Changelog

All notable changes to Viralfy will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2025-11-02

### ✨ Added

#### CSV Import Feature
- **CSV Parser Infrastructure** (`scripts/bash/csv-parser.sh`)
  - Generic CSV parsing functions
  - Data validation and cleaning utilities
  - Statistical analysis functions (average, median, standard deviation)
  - Number normalization (handles K/M suffixes, commas)
  - Column extraction and data transformation

- **Twitter CSV Import** (`viralfy validate`)
  - Import Twitter Analytics CSV data
  - Automatic baseline calculation (averages)
  - High-performance detection (> 3x average)
  - Multi-dimensional scoring algorithm (0-100)
  - Batch processing of tweet history

- **YouTube CSV Import** (`viralfy validate`)
  - Import YouTube Studio CSV data
  - View threshold (100k+ or 3x average)
  - Like rate and engagement calculation
  - Multi-dimensional scoring algorithm (0-100)
  - Batch processing of video analytics

#### Scoring System
- **Twitter Scoring Algorithm**
  - Engagement data (40%): relative to average
  - Spread speed (30%): impressions vs average
  - Audience quality (20%): engagement rate
  - Absolute value (10%): engagement tiers

- **YouTube Scoring Algorithm**
  - Engagement data (40%): likes vs average
  - Spread speed (30%): views vs average
  - Audience quality (20%): like rate
  - Absolute value (10%): view count tiers

#### Documentation
- **CSV Import Guide** (`docs/CSV_IMPORT_GUIDE.md`)
  - Complete Twitter Analytics export tutorial
  - Complete YouTube Studio export tutorial
  - Scoring system explanation
  - Troubleshooting and FAQ
  - 6,000+ words comprehensive guide

- **CSV Examples** (`templates/csv-examples/`)
  - Twitter sample CSV with 10 entries
  - YouTube sample CSV with 10 entries
  - Format documentation and usage instructions

#### User Interface
- **Updated Validation Flow** (`templates/commands/validate.md`)
  - New option: Import Twitter CSV
  - New option: Import YouTube CSV
  - Detailed success/error messages
  - Export instructions and help links

### 🎯 Enhanced

- **Idea Validation Module**
  - From manual-only to CSV batch import
  - Data-driven topic validation
  - Automatic scoring (was 0 for all)
  - Better metrics tracking

- **validate.sh Script**
  - Added `import-twitter-csv` command
  - Added `import-youtube-csv` command
  - Added `add_topic_from_csv` helper function
  - Added `calculate_twitter_score` function
  - Added `calculate_youtube_score` function

### 📊 Impact

- **Zero-cost solution**: No API fees required
- **Batch processing**: Analyze hundreds of posts at once
- **Data-driven**: Based on real performance metrics
- **Immediate availability**: Works with official platform exports

---

## [0.1.0] - 2025-11-02

### 🎉 Initial Release - Beta

#### Added

##### Core Features
- **Project Initialization** (`viralfy init`)
  - Interactive configuration wizard
  - Multi-field support (8 content fields)
  - Multi-platform selection (15+ platforms)
  - Multi-language support (Chinese, English, Bilingual)
  - Automatic directory structure creation

- **Newsletter Creation** (`viralfy write`)
  - Three creation modes:
    - Create: AI-guided step-by-step writing
    - Import: Convert existing content (Markdown/PDF/URL)
    - Assisted: AI-generated draft with user review
  - Incremental saving mechanism
  - Resume from interruption
  - Progress tracking
  - Section-by-section creation

- **Project Status** (`viralfy status`)
  - Display project configuration
  - Show creation progress
  - Track newsletter status

##### Technical Infrastructure
- **CLI Layer**
  - TypeScript implementation
  - Commander.js for command routing
  - 7 core commands registered
  - Rich interactive UI (Inquirer, Chalk, Ora)
  - Cross-platform support

- **Script Layer**
  - Bash scripts for Unix/Linux/Mac
  - PowerShell scripts planned for Windows
  - JSON-based communication
  - Project root detection
  - Progress tracking system

- **Template Layer**
  - Markdown-based AI command templates
  - YAML frontmatter for metadata
  - Detailed workflow instructions
  - Best practices and troubleshooting

- **Type System**
  - Comprehensive TypeScript types
  - 15+ data models
  - Custom error classes
  - Full IDE support

##### Documentation
- **Product Documentation** (25,000+ words)
  - Complete PRD with Dan Koe's 4-step system
  - 7 core feature modules
  - 15+ platform specifications
  - User flows and scenarios

- **Technical Documentation** (15,000+ words)
  - Three-layer architecture design
  - CLI, Script, Template layer details
  - Data flow mechanisms
  - AI integration guide

- **User Guides**
  - Quick start guide
  - Getting started tutorial
  - Command reference
  - Troubleshooting guide

##### Platform Support
- **Chinese Platforms**
  - WeChat Official Account (微信公众号)
  - Xiaohongshu (小红书)
  - Zhihu (知乎)
  - Bilibili (B站)
  - Douyin (抖音)

- **International Platforms**
  - Twitter/X
  - LinkedIn
  - YouTube
  - Instagram
  - TikTok
  - and 5+ more platforms

##### AI Integration
- **Supported AI Assistants** (13+)
  - Claude Code (Recommended)
  - Cursor (Recommended)
  - Gemini CLI
  - Windsurf
  - Roo Code
  - GitHub Copilot
  - and 7+ more

### 📋 Planned Features

#### [1.1.0] - Idea Validation
- Twitter viral post analysis
- YouTube trending video collection
- Topic scoring system
- Top 5 recommendations
- Swipe file management

#### [1.2.0] - Deep Research
- AI-assisted knowledge extraction
- YouTube video transcription
- PDF document parsing
- Web article scraping
- Knowledge base construction

#### [1.3.0] - Multi-Platform Distribution
- Meta-prompting system
- 15+ platform content generation
- Format conversion
- Batch processing
- Distribution tracking

#### [1.4.0] - Viral Analysis
- Content structure breakdown
- Psychological trigger identification
- Template extraction
- Best practices database

#### [1.5.0] - Style Training
- Author persona training
- Feature extraction from samples
- YAML persona configuration
- Style activation system

### 🔧 Technical Details

#### Dependencies
- @commander-js/extra-typings: ^12.0.0
- chalk: ^5.3.0
- fs-extra: ^11.2.0
- inquirer: ^9.2.12
- js-yaml: ^4.1.0
- marked: ^16.4.1
- ora: ^8.0.1
- axios: ^1.6.0

#### Development
- TypeScript: ^5.3.3
- tsx: ^4.7.0
- Node.js: >=18.0.0

### 📊 Statistics

- Total Files: 20 core files
- Code Lines: ~15,000 lines
- Documentation: 50,000+ words
- Type Definitions: 400+ lines
- Bash Scripts: 600+ lines
- Templates: 1,100+ lines

### 🙏 Acknowledgments

- **Dan Koe** - For the revolutionary AI content ecosystem concept
- **courseify** - For the mature AI-friendly architecture pattern
- All open source contributors

---

## Legend

- 🎉 Initial release
- ✨ New feature
- 🐛 Bug fix
- 📚 Documentation
- ♻️ Refactor
- ⚡ Performance
- 🔧 Configuration
- 🗑️ Deprecation
- 🚨 Breaking change

---

**Note**: This is the initial beta release (v0.1.0). The project implements AI-First architecture with complete AI command templates. Core features (init, write) are fully functional. Additional features (validate, research, distribute, analyze, style) are available as AI assistant commands.
