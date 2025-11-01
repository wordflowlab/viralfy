#!/bin/bash
# write.sh - Newsletter 创作脚本
# Viralfy v1.0.0

# 导入公共函数
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 配置
PROGRESS_FILE="$CONFIG_DIR/newsletter-progress.json"
NEWSLETTERS_DIR="newsletters"

# ============================================
# 主函数
# ============================================

main() {
    # 确保在项目根目录
    local project_root
    project_root=$(ensure_project_root)

    log_info "Checking newsletter status..."

    # 检查是否有未完成的 Newsletter
    if has_unfinished_newsletter; then
        handle_resume_mode
    else
        handle_create_mode
    fi
}

# ============================================
# 处理恢复模式
# ============================================

handle_resume_mode() {
    log_info "Found unfinished newsletter"

    local progress
    progress=$(read_newsletter_progress)

    # 提取进度信息
    local newsletter_id
    local topic_id
    local total_sections
    local completed_count
    local current_section
    local word_count

    newsletter_id=$(echo "$progress" | grep '"newsletter_id"' | sed 's/.*: *"\([^"]*\)".*/\1/')
    topic_id=$(echo "$progress" | grep '"topic_id"' | sed 's/.*: *"\([^"]*\)".*/\1/')
    total_sections=$(echo "$progress" | grep '"total_sections"' | sed 's/.*: *\([0-9]*\).*/\1/')
    current_section=$(echo "$progress" | grep '"current_section"' | sed 's/.*: *\([0-9]*\).*/\1/')
    word_count=$(echo "$progress" | grep '"word_count"' | sed 's/.*: *\([0-9]*\).*/\1/')

    # 计算已完成章节数 (简化实现)
    completed_count=$((current_section - 1))

    success \
        '"action": "resume",' \
        '"data": {' \
        '  "progress": {' \
        '    "newsletter_id": "'"$newsletter_id"'",' \
        '    "topic_id": "'"$topic_id"'",' \
        '    "total_sections": '"$total_sections"',' \
        '    "completed_sections": [],' \
        '    "current_section": '"$current_section"',' \
        '    "word_count": '"$word_count"'' \
        '  }' \
        '}'
}

# ============================================
# 处理创建模式
# ============================================

handle_create_mode() {
    log_info "Ready to create new newsletter"

    # 生成新的 Newsletter ID
    local newsletter_id
    newsletter_id=$(generate_id "issue")

    success \
        '"action": "create",' \
        '"data": {' \
        '  "newsletter_id": "'"$newsletter_id"'",' \
        '  "available_modes": ["create", "import", "assisted"]' \
        '}'
}

# ============================================
# 保存章节 (供 AI 调用)
# ============================================

save_section() {
    local newsletter_id="$1"
    local section_number="$2"
    local content="$3"

    local section_dir="$NEWSLETTERS_DIR/$newsletter_id/sections"
    ensure_dir "$section_dir"

    local section_file="$section_dir/$(printf '%02d' "$section_number")-section.md"

    # 保存内容
    echo "$content" > "$section_file"

    # 更新进度
    update_progress "$newsletter_id" "$section_number"

    log_success "Section $section_number saved: $section_file"
}

# ============================================
# 更新进度
# ============================================

update_progress() {
    local newsletter_id="$1"
    local section_number="$2"

    # 读取现有进度
    local progress
    progress=$(read_newsletter_progress)

    # 计算字数
    local word_count=0
    local section_dir="$NEWSLETTERS_DIR/$newsletter_id/sections"
    if dir_exists "$section_dir"; then
        for section_file in "$section_dir"/*.md; do
            if file_exists "$section_file"; then
                word_count=$((word_count + $(count_words "$section_file")))
            fi
        done
    fi

    # 如果是新 Newsletter,创建进度文件
    if [[ "$progress" == "{}" ]]; then
        cat > "$PROGRESS_FILE" <<EOF
{
  "newsletter_id": "$newsletter_id",
  "topic_id": "topic-001",
  "total_sections": 6,
  "completed_sections": [$section_number],
  "current_section": $((section_number + 1)),
  "status": "drafting",
  "word_count": $word_count,
  "created_at": "$(timestamp)",
  "updated_at": "$(timestamp)"
}
EOF
    else
        # 使用 jq 或 sed 更新现有进度
        if command -v jq &> /dev/null; then
            local temp_file="${PROGRESS_FILE}.tmp"
            jq ".current_section = $((section_number + 1)) | .word_count = $word_count | .updated_at = \"$(timestamp)\"" \
                "$PROGRESS_FILE" > "$temp_file"
            mv "$temp_file" "$PROGRESS_FILE"
        else
            # 简化实现
            local temp_file="${PROGRESS_FILE}.tmp"
            sed -e "s/\"current_section\": [0-9]*/\"current_section\": $((section_number + 1))/" \
                -e "s/\"word_count\": [0-9]*/\"word_count\": $word_count/" \
                -e "s/\"updated_at\": \"[^\"]*\"/\"updated_at\": \"$(timestamp)\"/" \
                "$PROGRESS_FILE" > "$temp_file"
            mv "$temp_file" "$PROGRESS_FILE"
        fi
    fi

    log_info "Progress updated: section $section_number completed (total words: $word_count)"
}

# ============================================
# 完成 Newsletter
# ============================================

complete_newsletter() {
    local newsletter_id="$1"

    # 合并所有章节为完整 Newsletter
    local sections_dir="$NEWSLETTERS_DIR/$newsletter_id/sections"
    local newsletter_file="$NEWSLETTERS_DIR/$newsletter_id/newsletter.md"
    local metadata_file="$NEWSLETTERS_DIR/$newsletter_id/metadata.json"

    if dir_exists "$sections_dir"; then
        # 合并所有章节
        cat "$sections_dir"/*.md > "$newsletter_file"

        # 计算总字数
        local word_count
        word_count=$(count_words "$newsletter_file")

        # 生成元数据
        cat > "$metadata_file" <<EOF
{
  "newsletter_id": "$newsletter_id",
  "title": "",
  "topic_id": "topic-001",
  "status": "completed",
  "word_count": $word_count,
  "sections_count": $(ls -1 "$sections_dir"/*.md 2>/dev/null | wc -l | tr -d ' '),
  "created_at": "$(read_json_field "$PROGRESS_FILE" "created_at")",
  "completed_at": "$(timestamp)"
}
EOF

        log_success "Newsletter completed: $newsletter_file (${word_count} words)"

        # 清除进度文件
        rm -f "$PROGRESS_FILE"

        success \
            '"action": "complete",' \
            '"data": {' \
            '  "newsletter_id": "'"$newsletter_id"'",' \
            '  "newsletter_file": "'"$newsletter_file"'",' \
            '  "metadata_file": "'"$metadata_file"'",' \
            '  "word_count": '"$word_count"'' \
            '}'
    else
        error "Sections directory not found: $sections_dir"
    fi
}

# ============================================
# 执行主函数
# ============================================

# 检查是否有参数 (用于特殊操作)
if [[ $# -gt 0 ]]; then
    case "$1" in
        save)
            save_section "$2" "$3" "$4"
            ;;
        complete)
            complete_newsletter "$2"
            ;;
        *)
            error "Unknown operation: $1"
            ;;
    esac
else
    main
fi
