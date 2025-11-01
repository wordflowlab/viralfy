#!/bin/bash
# distribute.sh - 多平台分发脚本
# Viralfy v1.0.0

# 导入公共函数
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 配置
NEWSLETTERS_DIR="newsletters"
DISTRIBUTION_DIR="distribution"

# ============================================
# 主函数
# ============================================

main() {
    # 确保在项目根目录
    local project_root
    project_root=$(ensure_project_root)

    local newsletter_id="$1"

    if [[ -z "$newsletter_id" ]]; then
        error "Newsletter ID is required"
        return 1
    fi

    log_info "Starting distribution for newsletter: $newsletter_id"

    # 检查 Newsletter 是否存在
    local newsletter_file="$NEWSLETTERS_DIR/$newsletter_id/newsletter.md"
    if [[ ! -f "$newsletter_file" ]]; then
        error "Newsletter not found: $newsletter_file"
        return 1
    fi

    # 确保分发目录存在
    local dist_dir="$DISTRIBUTION_DIR/$newsletter_id"
    ensure_dir "$dist_dir"

    # 读取项目配置获取目标平台
    local config_file="$CONFIG_DIR/config.json"
    local platforms=""

    if [[ -f "$config_file" ]]; then
        if command -v jq &> /dev/null; then
            platforms=$(jq -r '.platforms | join(",")' "$config_file")
        fi
    fi

    success \
        '"action": "init_distribution",' \
        '"data": {' \
        '  "newsletter_id": "'"$newsletter_id"'",' \
        '  "newsletter_file": "'"$newsletter_file"'",' \
        '  "distribution_dir": "'"$dist_dir"'",' \
        '  "platforms": "'"$platforms"'"' \
        '}'
}

# ============================================
# 初始化平台分发目录
# ============================================

init_platform() {
    local newsletter_id="$1"
    local platform="$2"

    log_info "Initializing distribution for platform: $platform"

    local platform_dir="$DISTRIBUTION_DIR/$newsletter_id/$platform"
    ensure_dir "$platform_dir"

    success \
        '"action": "platform_initialized",' \
        '"data": {' \
        '  "newsletter_id": "'"$newsletter_id"'",' \
        '  "platform": "'"$platform"'",' \
        '  "platform_dir": "'"$platform_dir"'"' \
        '}'
}

# ============================================
# 保存分发内容
# ============================================

save_post() {
    local newsletter_id="$1"
    local platform="$2"
    local variant="$3"
    local content="$4"

    log_info "Saving post: $newsletter_id / $platform / variant $variant"

    local platform_dir="$DISTRIBUTION_DIR/$newsletter_id/$platform"
    ensure_dir "$platform_dir"

    # 生成帖子文件
    local post_file="$platform_dir/post-$(printf '%03d' "$variant").md"
    echo "$content" > "$post_file"

    # 生成元数据
    local metadata_file="$platform_dir/post-$(printf '%03d' "$variant").json"
    cat > "$metadata_file" <<EOF
{
  "platform": "$platform",
  "newsletter_id": "$newsletter_id",
  "variant": $variant,
  "created_at": "$(timestamp)",
  "status": "draft"
}
EOF

    log_success "Post saved: $post_file"

    success \
        '"action": "post_saved",' \
        '"data": {' \
        '  "newsletter_id": "'"$newsletter_id"'",' \
        '  "platform": "'"$platform"'",' \
        '  "variant": '"$variant"',' \
        '  "post_file": "'"$post_file"'",' \
        '  "metadata_file": "'"$metadata_file"'"' \
        '}'
}

# ============================================
# 列出分发内容
# ============================================

list_posts() {
    local newsletter_id="$1"

    log_info "Listing posts for newsletter: $newsletter_id"

    local dist_dir="$DISTRIBUTION_DIR/$newsletter_id"

    if [[ ! -d "$dist_dir" ]]; then
        success \
            '"action": "list_posts",' \
            '"data": {' \
            '  "posts": [],' \
            '  "count": 0' \
            '}'
        return
    fi

    # 收集所有平台的帖子
    local posts_json="["
    local first=true
    local count=0

    for platform_dir in "$dist_dir"/*; do
        if [[ -d "$platform_dir" ]]; then
            local platform=$(basename "$platform_dir")
            for post_file in "$platform_dir"/post-*.md; do
                if [[ -f "$post_file" ]]; then
                    if [[ "$first" == true ]]; then
                        first=false
                    else
                        posts_json+=","
                    fi

                    local metadata_file="${post_file%.md}.json"
                    if [[ -f "$metadata_file" ]]; then
                        posts_json+=$(cat "$metadata_file")
                    fi

                    count=$((count + 1))
                fi
            done
        fi
    done

    posts_json+="]"

    echo "{\"status\": \"success\", \"action\": \"list_posts\", \"data\": {\"posts\": $posts_json, \"count\": $count}}"
}

# ============================================
# 完成分发
# ============================================

complete_distribution() {
    local newsletter_id="$1"

    log_info "Completing distribution for newsletter: $newsletter_id"

    local dist_dir="$DISTRIBUTION_DIR/$newsletter_id"

    # 创建分发摘要
    local summary_file="$dist_dir/distribution-summary.json"

    local timestamp
    timestamp=$(timestamp)

    # 统计帖子数量
    local total_posts=0
    if [[ -d "$dist_dir" ]]; then
        total_posts=$(find "$dist_dir" -name "post-*.md" | wc -l | tr -d ' ')
    fi

    cat > "$summary_file" <<EOF
{
  "newsletter_id": "$newsletter_id",
  "total_posts": $total_posts,
  "status": "completed",
  "completed_at": "$timestamp"
}
EOF

    log_success "Distribution completed: $summary_file"

    success \
        '"action": "distribution_completed",' \
        '"data": {' \
        '  "newsletter_id": "'"$newsletter_id"'",' \
        '  "summary_file": "'"$summary_file"'",' \
        '  "total_posts": '"$total_posts"'' \
        '}'
}

# ============================================
# 执行主函数或子命令
# ============================================

# 检查是否有参数 (用于特殊操作)
if [[ $# -gt 1 ]]; then
    case "$1" in
        init-platform)
            init_platform "$2" "$3"
            ;;
        save-post)
            save_post "$2" "$3" "$4" "$5"
            ;;
        list-posts)
            list_posts "$2"
            ;;
        complete)
            complete_distribution "$2"
            ;;
        *)
            main "$@"
            ;;
    esac
else
    main "$@"
fi
