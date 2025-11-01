#!/bin/bash
# validate.sh - 创意验证脚本
# Viralfy v1.0.0

# 导入公共函数
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 配置
IDEAS_DIR="ideas"
VALIDATED_TOPICS_FILE="$IDEAS_DIR/validated-topics.json"

# ============================================
# 主函数
# ============================================

main() {
    # 确保在项目根目录
    local project_root
    project_root=$(ensure_project_root)

    log_info "Starting idea validation..."

    # 确保目录存在
    ensure_dir "$IDEAS_DIR"

    # 确保 validated-topics.json 存在
    ensure_validated_topics_file

    # 返回验证源选项
    success \
        '"action": "select_source",' \
        '"data": {' \
        '  "sources": [' \
        '    {"id": "twitter", "name": "Twitter 爆款分析", "description": "分析 Twitter 上的高互动内容"},' \
        '    {"id": "youtube", "name": "YouTube 热门采集", "description": "提取高观看量视频标题"},' \
        '    {"id": "manual", "name": "手动输入", "description": "手动输入创意主题"}' \
        '  ],' \
        '  "validated_topics_file": "'"$VALIDATED_TOPICS_FILE"'"' \
        '}'
}

# ============================================
# 确保 validated-topics.json 存在
# ============================================

ensure_validated_topics_file() {
    if [[ ! -f "$VALIDATED_TOPICS_FILE" ]]; then
        cat > "$VALIDATED_TOPICS_FILE" <<'EOF'
{
  "topics": []
}
EOF
        log_success "Created $VALIDATED_TOPICS_FILE"
    fi
}

# ============================================
# 添加手动创意
# ============================================

add_manual_topic() {
    local title="$1"
    local topic_id
    topic_id=$(generate_id "topic")

    local timestamp
    timestamp=$(timestamp)

    # 读取现有主题
    local topics_json
    topics_json=$(cat "$VALIDATED_TOPICS_FILE")

    # 创建新主题
    local new_topic
    new_topic=$(cat <<EOF
    {
      "id": "$topic_id",
      "title": "$title",
      "source": "manual",
      "score": 0,
      "metrics": {},
      "validated_at": "$timestamp",
      "status": "pending"
    }
EOF
)

    # 如果有 jq,使用 jq 添加
    if command -v jq &> /dev/null; then
        local temp_file="${VALIDATED_TOPICS_FILE}.tmp"
        echo "$new_topic" | jq -s '.' > "$temp_file.new"
        jq --argjson new_topic "$(cat "$temp_file.new")" '.topics += $new_topic' \
            "$VALIDATED_TOPICS_FILE" > "$temp_file"
        mv "$temp_file" "$VALIDATED_TOPICS_FILE"
        rm -f "$temp_file.new"
    else
        # 简单实现: 手动添加到数组
        local temp_file="${VALIDATED_TOPICS_FILE}.tmp"
        if grep -q '"topics": \[\]' "$VALIDATED_TOPICS_FILE"; then
            # 空数组
            sed "s/\"topics\": \[\]/\"topics\": [$new_topic]/" "$VALIDATED_TOPICS_FILE" > "$temp_file"
        else
            # 非空数组
            sed "s/\"topics\": \[/\"topics\": [$new_topic,/" "$VALIDATED_TOPICS_FILE" > "$temp_file"
        fi
        mv "$temp_file" "$VALIDATED_TOPICS_FILE"
    fi

    log_success "Topic added: $title (ID: $topic_id)"

    success \
        '"action": "topic_added",' \
        '"data": {' \
        '  "topic_id": "'"$topic_id"'",' \
        '  "title": "'"$title"'",' \
        '  "status": "pending"' \
        '}'
}

# ============================================
# 验证 Twitter 创意 (占位符实现)
# ============================================

validate_twitter() {
    local input="$1"  # 账号或话题

    log_info "Analyzing Twitter content for: $input"

    # TODO: 实现 Twitter API 集成
    # 目前返回模拟数据

    error "Twitter API integration not yet implemented. Use manual mode for now."
}

# ============================================
# 验证 YouTube 创意 (占位符实现)
# ============================================

validate_youtube() {
    local input="$1"  # 频道或关键词

    log_info "Analyzing YouTube content for: $input"

    # TODO: 实现 YouTube API 集成
    # 目前返回模拟数据

    error "YouTube API integration not yet implemented. Use manual mode for now."
}

# ============================================
# 列出所有验证的创意
# ============================================

list_topics() {
    if [[ ! -f "$VALIDATED_TOPICS_FILE" ]]; then
        success \
            '"action": "list",' \
            '"data": {' \
            '  "topics": [],' \
            '  "count": 0' \
            '}'
        return
    fi

    # 读取并返回主题列表
    local topics_json
    topics_json=$(cat "$VALIDATED_TOPICS_FILE")

    if command -v jq &> /dev/null; then
        local count
        count=$(echo "$topics_json" | jq '.topics | length')
        echo "{\"status\": \"success\", \"action\": \"list\", \"data\": {\"topics\": $(echo "$topics_json" | jq '.topics'), \"count\": $count}}"
    else
        # 简单实现
        success \
            '"action": "list",' \
            '"data": ' "$(cat "$VALIDATED_TOPICS_FILE")"
    fi
}

# ============================================
# 更新创意状态
# ============================================

update_topic_status() {
    local topic_id="$1"
    local new_status="$2"

    log_info "Updating topic $topic_id status to $new_status"

    if command -v jq &> /dev/null; then
        local temp_file="${VALIDATED_TOPICS_FILE}.tmp"
        jq --arg id "$topic_id" --arg status "$new_status" \
            '(.topics[] | select(.id == $id) | .status) = $status' \
            "$VALIDATED_TOPICS_FILE" > "$temp_file"
        mv "$temp_file" "$VALIDATED_TOPICS_FILE"
    else
        # 简单实现: 使用 sed
        local temp_file="${VALIDATED_TOPICS_FILE}.tmp"
        # 这是一个简化版本,实际应该更复杂
        sed "s/\"id\": \"$topic_id\".*\"status\": \"[^\"]*\"/\"id\": \"$topic_id\", \"status\": \"$new_status\"/" \
            "$VALIDATED_TOPICS_FILE" > "$temp_file"
        mv "$temp_file" "$VALIDATED_TOPICS_FILE"
    fi

    log_success "Topic status updated"

    success \
        '"action": "status_updated",' \
        '"data": {' \
        '  "topic_id": "'"$topic_id"'",' \
        '  "status": "'"$new_status"'"' \
        '}'
}

# ============================================
# 执行主函数或子命令
# ============================================

# 检查是否有参数 (用于特殊操作)
if [[ $# -gt 0 ]]; then
    case "$1" in
        add-manual)
            add_manual_topic "$2"
            ;;
        twitter)
            validate_twitter "$2"
            ;;
        youtube)
            validate_youtube "$2"
            ;;
        list)
            list_topics
            ;;
        update-status)
            update_topic_status "$2" "$3"
            ;;
        *)
            error "Unknown operation: $1"
            ;;
    esac
else
    main
fi
