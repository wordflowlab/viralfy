#!/bin/bash
# analyze.sh - 爆款内容分析脚本
# Viralfy v1.0.0

# 导入公共函数
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 配置
SWIPE_FILES_DIR="swipe-files"
ANALYSIS_DIR="$SWIPE_FILES_DIR/analysis"
POSTS_DIR="$SWIPE_FILES_DIR/posts"

# ============================================
# 主函数
# ============================================

main() {
    # 确保在项目根目录
    local project_root
    project_root=$(ensure_project_root)

    local url="$1"

    if [[ -z "$url" ]]; then
        error "URL is required"
        return 1
    fi

    log_info "Starting analysis for URL: $url"

    # 确保目录存在
    ensure_dir "$ANALYSIS_DIR"
    ensure_dir "$POSTS_DIR"

    # 生成分析 ID
    local analysis_id
    analysis_id=$(generate_id "analysis")

    success \
        '"action": "init_analysis",' \
        '"data": {' \
        '  "analysis_id": "'"$analysis_id"'",' \
        '  "url": "'"$url"'",' \
        '  "analysis_dir": "'"$ANALYSIS_DIR"'"' \
        '}'
}

# ============================================
# 保存原始内容
# ============================================

save_original_content() {
    local analysis_id="$1"
    local url="$2"
    local content="$3"
    local platform="$4"

    log_info "Saving original content for analysis: $analysis_id"

    # 保存原始内容
    local content_file="$POSTS_DIR/${analysis_id}-original.md"
    cat > "$content_file" <<EOF
# 原始内容

**URL**: $url
**平台**: $platform
**采集时间**: $(timestamp)

---

$content
EOF

    log_success "Original content saved: $content_file"

    success \
        '"action": "content_saved",' \
        '"data": {' \
        '  "analysis_id": "'"$analysis_id"'",' \
        '  "content_file": "'"$content_file"'"' \
        '}'
}

# ============================================
# 保存分析报告
# ============================================

save_analysis_report() {
    local analysis_id="$1"
    local report_content="$2"

    log_info "Saving analysis report: $analysis_id"

    local report_file="$ANALYSIS_DIR/${analysis_id}-report.md"
    echo "$report_content" > "$report_file"

    log_success "Analysis report saved: $report_file"

    success \
        '"action": "report_saved",' \
        '"data": {' \
        '  "analysis_id": "'"$analysis_id"'",' \
        '  "report_file": "'"$report_file"'"' \
        '}'
}

# ============================================
# 保存内容模板
# ============================================

save_template() {
    local analysis_id="$1"
    local template_name="$2"
    local template_content="$3"

    log_info "Saving content template: $template_name"

    local templates_dir="$SWIPE_FILES_DIR/templates"
    ensure_dir "$templates_dir"

    local template_file="$templates_dir/${analysis_id}-${template_name}.md"
    cat > "$template_file" <<EOF
# 内容模板: $template_name

**来源分析**: $analysis_id
**创建时间**: $(timestamp)

---

$template_content
EOF

    log_success "Template saved: $template_file"

    success \
        '"action": "template_saved",' \
        '"data": {' \
        '  "analysis_id": "'"$analysis_id"'",' \
        '  "template_name": "'"$template_name"'",' \
        '  "template_file": "'"$template_file"'"' \
        '}'
}

# ============================================
# 添加到 Swipe File 收藏
# ============================================

add_to_swipe_collection() {
    local analysis_id="$1"
    local platform="$2"
    local title="$3"
    local url="$4"

    log_info "Adding to swipe file collection: $analysis_id"

    # 创建/更新 swipe-files 索引
    local index_file="$SWIPE_FILES_DIR/index.json"

    # 如果索引不存在,创建空索引
    if [[ ! -f "$index_file" ]]; then
        echo '{"posts": []}' > "$index_file"
    fi

    # 创建新条目
    local new_entry
    new_entry=$(cat <<EOF
{
  "id": "$analysis_id",
  "platform": "$platform",
  "title": "$title",
  "url": "$url",
  "analysis_file": "$ANALYSIS_DIR/${analysis_id}-report.md",
  "added_at": "$(timestamp)"
}
EOF
)

    # 添加到索引
    if command -v jq &> /dev/null; then
        local temp_file="${index_file}.tmp"
        echo "$new_entry" | jq -s '.' > "$temp_file.new"
        jq --argjson new_entry "$(cat "$temp_file.new")" '.posts += $new_entry' \
            "$index_file" > "$temp_file"
        mv "$temp_file" "$index_file"
        rm -f "$temp_file.new"
    fi

    log_success "Added to swipe file collection"

    success \
        '"action": "added_to_collection",' \
        '"data": {' \
        '  "analysis_id": "'"$analysis_id"'",' \
        '  "index_file": "'"$index_file"'"' \
        '}'
}

# ============================================
# 列出所有分析
# ============================================

list_analyses() {
    log_info "Listing all analyses"

    local index_file="$SWIPE_FILES_DIR/index.json"

    if [[ ! -f "$index_file" ]]; then
        success \
            '"action": "list",' \
            '"data": {' \
            '  "analyses": [],' \
            '  "count": 0' \
            '}'
        return
    fi

    # 读取并返回分析列表
    if command -v jq &> /dev/null; then
        local count
        count=$(jq '.posts | length' "$index_file")
        echo "{\"status\": \"success\", \"action\": \"list\", \"data\": {\"analyses\": $(jq '.posts' "$index_file"), \"count\": $count}}"
    else
        success \
            '"action": "list",' \
            '"data": ' "$(cat "$index_file")"
    fi
}

# ============================================
# 获取平台特征
# ============================================

get_platform_from_url() {
    local url="$1"

    if [[ "$url" =~ twitter\.com|x\.com ]]; then
        echo "twitter"
    elif [[ "$url" =~ youtube\.com|youtu\.be ]]; then
        echo "youtube"
    elif [[ "$url" =~ linkedin\.com ]]; then
        echo "linkedin"
    elif [[ "$url" =~ xiaohongshu\.com|xhs\.com ]]; then
        echo "xiaohongshu"
    elif [[ "$url" =~ zhihu\.com ]]; then
        echo "zhihu"
    elif [[ "$url" =~ medium\.com ]]; then
        echo "medium"
    else
        echo "unknown"
    fi
}

# ============================================
# 执行主函数或子命令
# ============================================

# 检查是否有参数 (用于特殊操作)
if [[ $# -gt 1 ]]; then
    case "$1" in
        save-content)
            save_original_content "$2" "$3" "$4" "$5"
            ;;
        save-report)
            save_analysis_report "$2" "$3"
            ;;
        save-template)
            save_template "$2" "$3" "$4"
            ;;
        add-to-collection)
            add_to_swipe_collection "$2" "$3" "$4" "$5"
            ;;
        list)
            list_analyses
            ;;
        get-platform)
            platform=$(get_platform_from_url "$2")
            echo "{\"status\": \"success\", \"data\": {\"platform\": \"$platform\"}}"
            ;;
        *)
            main "$@"
            ;;
    esac
else
    main "$@"
fi
