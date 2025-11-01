#!/bin/bash
# init.sh - 项目初始化脚本
# Viralfy v1.0.0

# 导入公共函数
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 配置
CONFIG_DIR=".viralfy"
CONFIG_FILE="$CONFIG_DIR/config.json"

# ============================================
# 主函数
# ============================================

main() {
    log_info "Starting project initialization..."

    # 检查是否已经初始化
    if file_exists "$CONFIG_FILE"; then
        log_info "Project already initialized"
        success \
            '"action": "update",' \
            '"config_file": "'"$CONFIG_FILE"'",' \
            '"message": "Project already initialized. Use update mode."'
        exit 0
    fi

    # 创建项目目录结构
    create_project_structure

    # 生成默认配置
    generate_default_config

    # 创建示例文件
    create_example_files

    log_success "Project structure created successfully"

    success \
        '"action": "create",' \
        '"config_file": "'"$CONFIG_FILE"'",' \
        '"directories": ["ideas", "research", "newsletters", "distribution", "swipe-files"],' \
        '"example_files": [".gitignore", "README.md", "ideas/validated-topics.json"],' \
        '"message": "Project structure created successfully."'
}

# ============================================
# 创建项目目录结构
# ============================================

create_project_structure() {
    log_info "Creating project directories..."

    # 配置目录
    ensure_dir "$CONFIG_DIR"

    # 核心目录
    ensure_dir "ideas"
    ensure_dir "research"
    ensure_dir "newsletters"
    ensure_dir "distribution"

    # Swipe File 目录
    ensure_dir "swipe-files/twitter"
    ensure_dir "swipe-files/youtube"
    ensure_dir "swipe-files/xiaohongshu"
    ensure_dir "swipe-files/analysis"
    ensure_dir "swipe-files/personas"
    ensure_dir "swipe-files/templates"

    log_success "Directories created"
}

# ============================================
# 生成默认配置
# ============================================

generate_default_config() {
    log_info "Generating default configuration..."

    cat > "$CONFIG_FILE" <<EOF
{
  "project_name": "",
  "field": "",
  "platforms": [],
  "language": "zh-CN",
  "created_at": "$(timestamp)",
  "updated_at": "$(timestamp)"
}
EOF

    log_success "Configuration file created: $CONFIG_FILE"
}

# ============================================
# 创建示例文件
# ============================================

create_example_files() {
    log_info "Creating example files..."

    # 创建 .gitignore
    if [[ ! -f ".gitignore" ]]; then
        cat > ".gitignore" <<'EOF'
# Viralfy
.viralfy/newsletter-progress.json

# Node
node_modules/
npm-debug.log*

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo

# Temporary
*.tmp
temp/
EOF
        log_success ".gitignore created"
    fi

    # 创建项目 README
    if [[ ! -f "README.md" ]]; then
        cat > "README.md" <<'EOF'
# Viralfy 内容项目

这是一个使用 Viralfy 创建的内容项目。

## 目录结构

- `.viralfy/` - 配置文件
- `ideas/` - 验证过的创意主题
- `research/` - 研究材料和知识库
- `newsletters/` - Newsletter 源文件
- `distribution/` - 多平台分发内容
- `swipe-files/` - 爆款素材库

## 快速开始

1. 验证创意: `viralfy validate`
2. 深度研究: `viralfy research`
3. 创作内容: `viralfy write`
4. 多平台分发: `viralfy distribute`

## 更多信息

查看 [Viralfy 文档](https://github.com/your-org/viralfy) 了解更多。
EOF
        log_success "README.md created"
    fi

    # 创建示例 ideas 文件
    ensure_dir "ideas"
    if [[ ! -f "ideas/validated-topics.json" ]]; then
        cat > "ideas/validated-topics.json" <<'EOF'
{
  "topics": []
}
EOF
        log_success "ideas/validated-topics.json created"
    fi
}

# ============================================
# 执行主函数
# ============================================

main "$@"
