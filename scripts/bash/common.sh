#!/bin/bash
# common.sh - 公共函数库
# Viralfy v1.0.0

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
CONFIG_DIR=".viralfy"
CONFIG_FILE="$CONFIG_DIR/config.json"

# ============================================
# 项目根目录检测
# ============================================

# 查找项目根目录 (向上查找 .viralfy/config.json)
find_project_root() {
    local current_dir="$PWD"

    while [[ "$current_dir" != "/" ]]; do
        if [[ -f "$current_dir/$CONFIG_FILE" ]]; then
            echo "$current_dir"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done

    return 1
}

# 确保在项目根目录中执行
ensure_project_root() {
    local project_root
    project_root=$(find_project_root)

    if [[ -z "$project_root" ]]; then
        error "Not in a Viralfy project. Run 'viralfy init' first."
        exit 1
    fi

    # 切换到项目根目录
    cd "$project_root" || exit 1
    echo "$project_root"
}

# ============================================
# JSON 输出函数
# ============================================

# 输出 JSON 结果
output_json() {
    local status="$1"
    shift
    local json_data="$*"

    cat <<EOF
{
  "status": "$status",
  $json_data
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

# 输出成功 JSON
success() {
    output_json "success" "$@"
}

# 输出错误 JSON
error() {
    local message="$1"
    shift
    local extra_data="$*"

    if [[ -n "$extra_data" ]]; then
        output_json "error" "\"message\": \"$message\", $extra_data"
    else
        output_json "error" "\"message\": \"$message\""
    fi
    exit 1
}

# ============================================
# 文件操作函数
# ============================================

# 确保目录存在
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
    fi
}

# 检查文件是否存在
file_exists() {
    [[ -f "$1" ]]
}

# 检查目录是否存在
dir_exists() {
    [[ -d "$1" ]]
}

# 读取 JSON 字段
read_json_field() {
    local file="$1"
    local field="$2"

    if [[ -f "$file" ]]; then
        # 尝试使用 jq 如果可用,否则使用 grep/sed
        if command -v jq &> /dev/null; then
            jq -r ".${field} // empty" "$file" 2>/dev/null
        else
            # 简单的 JSON 解析
            grep "\"$field\"" "$file" | \
                head -1 | \
                sed 's/.*: *"\?\([^",]*\)"\?.*/\1/'
        fi
    fi
}

# 读取 JSON 数组
read_json_array() {
    local file="$1"
    local field="$2"

    if [[ -f "$file" ]]; then
        if command -v jq &> /dev/null; then
            jq -r ".${field}[]? // empty" "$file" 2>/dev/null
        else
            grep "\"$field\"" "$file" | \
                sed 's/.*: *\[\(.*\)\].*/\1/' | \
                tr ',' '\n' | \
                sed 's/[" ]//g'
        fi
    fi
}

# 写入 JSON 字段 (使用 jq 或手动)
write_json_field() {
    local file="$1"
    local field="$2"
    local value="$3"

    if command -v jq &> /dev/null; then
        local temp_file="${file}.tmp"
        jq ".${field} = \"${value}\"" "$file" > "$temp_file" && mv "$temp_file" "$file"
    else
        # 手动更新 (简单实现)
        local temp_file="${file}.tmp"
        sed "s/\"${field}\": *\"[^\"]*\"/\"${field}\": \"${value}\"/" "$file" > "$temp_file"
        mv "$temp_file" "$file"
    fi
}

# ============================================
# 时间戳函数
# ============================================

# 生成 ISO 8601 时间戳
timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# 生成简单的时间戳 (用于 ID)
timestamp_simple() {
    date +%s
}

# ============================================
# ID 生成函数
# ============================================

# 生成 ID
generate_id() {
    local prefix="$1"
    echo "${prefix}-$(timestamp_simple)"
}

# ============================================
# 配置读取函数
# ============================================

# 读取配置字段
read_config() {
    local field="$1"
    read_json_field "$CONFIG_FILE" "$field"
}

# 读取配置数组
read_config_array() {
    local field="$1"
    read_json_array "$CONFIG_FILE" "$field"
}

# ============================================
# 进度追踪函数
# ============================================

# 读取 Newsletter 进度
read_newsletter_progress() {
    local progress_file="$CONFIG_DIR/newsletter-progress.json"

    if file_exists "$progress_file"; then
        cat "$progress_file"
    else
        echo "{}"
    fi
}

# 检查是否有未完成的 Newsletter
has_unfinished_newsletter() {
    local progress_file="$CONFIG_DIR/newsletter-progress.json"
    file_exists "$progress_file"
}

# ============================================
# 日志函数
# ============================================

# 日志消息 (输出到 stderr,不影响 JSON 输出)
log() {
    echo -e "$@" >&2
}

log_info() {
    log "${BLUE}[INFO]${NC} $1"
}

log_success() {
    log "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    log "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    log "${RED}[ERROR]${NC} $1"
}

# ============================================
# 验证函数
# ============================================

# 验证必需字段
validate_required() {
    local field_name="$1"
    local field_value="$2"

    if [[ -z "$field_value" ]]; then
        error "Required field '$field_name' is missing"
    fi
}

# 验证目录结构
validate_project_structure() {
    local required_dirs=(
        "ideas"
        "research"
        "newsletters"
        "distribution"
        "swipe-files"
    )

    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_warning "Missing directory: $dir"
        fi
    done
}

# ============================================
# 工具函数
# ============================================

# 统计字数 (简单实现)
count_words() {
    local file="$1"
    if file_exists "$file"; then
        wc -w < "$file" | tr -d ' '
    else
        echo "0"
    fi
}

# 计算百分比
calculate_percentage() {
    local current="$1"
    local total="$2"

    if [[ "$total" -eq 0 ]]; then
        echo "0"
    else
        echo "$(( (current * 100) / total ))"
    fi
}

# 转义 JSON 字符串
escape_json() {
    local str="$1"
    # 转义双引号和反斜杠
    echo "$str" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

# ============================================
# 导出函数 (供其他脚本使用)
# ============================================

export -f find_project_root
export -f ensure_project_root
export -f output_json
export -f success
export -f error
export -f ensure_dir
export -f file_exists
export -f dir_exists
export -f timestamp
export -f generate_id
export -f read_config
export -f log
export -f log_info
export -f log_success
export -f log_warning
export -f log_error
