#!/bin/bash
# validate.sh - 创意验证脚本
# Viralfy v1.0.0

# 导入公共函数
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
source "$SCRIPT_DIR/csv-parser.sh"

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
# 从 CSV 添加创意 (内部函数)
# ============================================

add_topic_from_csv() {
    local topic_id="$1"
    local title="$2"
    local source="$3"
    local score="$4"
    local impressions="$5"
    local engagements="$6"
    local engagement_rate="$7"

    local timestamp
    timestamp=$(timestamp)

    # 转义标题中的特殊字符
    title=$(escape_json "$title")

    # 创建新主题
    local new_topic
    new_topic=$(cat <<EOF
    {
      "id": "$topic_id",
      "title": "$title",
      "source": "$source",
      "score": $score,
      "metrics": {
        "views": $impressions,
        "engagements": $engagements,
        "engagement_rate": $engagement_rate
      },
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
# 导入 Twitter CSV
# ============================================

import_twitter_csv() {
    local csv_file="$1"

    log_info "Importing Twitter CSV: $csv_file"

    # 验证文件存在
    if [[ ! -f "$csv_file" ]]; then
        error "CSV file not found: $csv_file"
    fi

    # 验证 CSV 格式 - Twitter Analytics 可能的列名
    # 支持多种格式变体
    local validation_result
    validation_result=$(validate_csv_format "$csv_file" "Tweet")

    if [[ "$validation_result" != "success" ]]; then
        error "Invalid Twitter CSV format. Expected columns: Tweet text, impressions, engagements"
    fi

    # 统计数据行数
    local row_count
    row_count=$(get_csv_row_count "$csv_file")

    if [[ $row_count -eq 0 ]]; then
        error "CSV file is empty or contains only header"
    fi

    log_info "Found $row_count tweets in CSV"

    # 解析 CSV (简化处理)
    local line_num=0
    local imported_count=0
    local high_performance_count=0

    # 读取 CSV 并计算基准指标
    local temp_metrics_file="/tmp/twitter_metrics_$$.txt"
    tail -n +2 "$csv_file" | while IFS=, read -r tweet_id tweet_text time impressions engagements engagement_rate rest; do
        # 清理数据
        impressions=$(normalize_number "$impressions")
        engagements=$(normalize_number "$engagements")

        # 保存到临时文件用于计算平均值
        echo "$impressions,$engagements,$engagement_rate" >> "$temp_metrics_file"
    done

    # 计算平均值
    local avg_impressions avg_engagements avg_engagement_rate
    avg_impressions=$(cut -d',' -f1 "$temp_metrics_file" | calculate_average)
    avg_engagements=$(cut -d',' -f2 "$temp_metrics_file" | calculate_average)
    avg_engagement_rate=$(cut -d',' -f3 "$temp_metrics_file" | calculate_average)

    log_info "Average impressions: $avg_impressions"
    log_info "Average engagements: $avg_engagements"

    # 阈值: 3 倍平均值
    local threshold_impressions threshold_engagements
    threshold_impressions=$(echo "$avg_impressions * 3" | bc | cut -d'.' -f1)
    threshold_engagements=$(echo "$avg_engagements * 3" | bc | cut -d'.' -f1)

    log_info "High performance threshold - Impressions: $threshold_impressions, Engagements: $threshold_engagements"

    # 第二遍读取,提取高表现推文
    tail -n +2 "$csv_file" | while IFS=, read -r tweet_id tweet_text time impressions engagements engagement_rate rest; do
        # 清理数据
        tweet_text=$(clean_csv_value "$tweet_text")
        impressions=$(normalize_number "$impressions")
        engagements=$(normalize_number "$engagements")

        # 移除引号
        engagement_rate=$(echo "$engagement_rate" | sed 's/["%]//g')

        # 判断是否高表现
        if [[ $engagements -ge $threshold_engagements ]] || [[ $impressions -ge $threshold_impressions ]]; then
            # 计算评分 (0-100)
            local score
            score=$(calculate_twitter_score "$impressions" "$engagements" "$engagement_rate" "$avg_impressions" "$avg_engagements")

            # 生成 topic ID
            local topic_id
            topic_id=$(generate_id "topic")

            # 添加到 validated-topics.json
            add_topic_from_csv "$topic_id" "$tweet_text" "twitter" "$score" "$impressions" "$engagements" "$engagement_rate"

            ((high_performance_count++))
            log_success "Added high-performance tweet (score: $score): ${tweet_text:0:50}..."
        fi

        ((imported_count++))
    done

    # 清理临时文件
    rm -f "$temp_metrics_file"

    log_success "Import completed: $imported_count tweets analyzed, $high_performance_count high-performance topics added"

    success \
        '"action": "csv_imported",' \
        '"data": {' \
        '  "source": "twitter",' \
        '  "total_rows": '"$imported_count"',' \
        '  "topics_added": '"$high_performance_count"',' \
        '  "threshold_multiplier": 3' \
        '}'
}

# 计算 Twitter 评分
calculate_twitter_score() {
    local impressions="$1"
    local engagements="$2"
    local engagement_rate="$3"
    local avg_impressions="$4"
    local avg_engagements="$5"

    # 多维度评分
    # 1. 互动数据 (40%): 相对于平均值
    local engagement_score
    if [[ $(echo "$avg_engagements > 0" | bc) -eq 1 ]]; then
        engagement_score=$(echo "scale=2; ($engagements / $avg_engagements) * 40" | bc)
    else
        engagement_score=0
    fi

    # 2. 传播速度 (30%): 展示量相对于平均值
    local spread_score
    if [[ $(echo "$avg_impressions > 0" | bc) -eq 1 ]]; then
        spread_score=$(echo "scale=2; ($impressions / $avg_impressions) * 30" | bc)
    else
        spread_score=0
    fi

    # 3. 受众质量 (20%): 互动率
    local quality_score
    quality_score=$(echo "scale=2; $engagement_rate * 200" | bc)

    # 4. 绝对数值 (10%): 基于互动数
    local absolute_score
    if [[ $engagements -gt 1000 ]]; then
        absolute_score=10
    elif [[ $engagements -gt 500 ]]; then
        absolute_score=8
    elif [[ $engagements -gt 100 ]]; then
        absolute_score=5
    else
        absolute_score=2
    fi

    # 总分
    local total_score
    total_score=$(echo "scale=2; $engagement_score + $spread_score + $quality_score + $absolute_score" | bc)

    # 归一化到 0-100
    if [[ $(echo "$total_score > 100" | bc) -eq 1 ]]; then
        total_score=100
    fi

    # 转换为整数
    printf "%.0f" "$total_score"
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
# 导入 YouTube CSV
# ============================================

import_youtube_csv() {
    local csv_file="$1"

    log_info "Importing YouTube CSV: $csv_file"

    # 验证文件存在
    if [[ ! -f "$csv_file" ]]; then
        error "CSV file not found: $csv_file"
    fi

    # 验证 CSV 格式 - YouTube Studio 可能的列名
    local validation_result
    validation_result=$(validate_csv_format "$csv_file" "Video")

    if [[ "$validation_result" != "success" ]]; then
        error "Invalid YouTube CSV format. Expected columns: Video title, Views, Likes, Comments"
    fi

    # 统计数据行数
    local row_count
    row_count=$(get_csv_row_count "$csv_file")

    if [[ $row_count -eq 0 ]]; then
        error "CSV file is empty or contains only header"
    fi

    log_info "Found $row_count videos in CSV"

    # 解析 CSV
    local imported_count=0
    local high_performance_count=0

    # 读取 CSV 并计算基准指标
    local temp_metrics_file="/tmp/youtube_metrics_$$.txt"
    tail -n +2 "$csv_file" | while IFS=, read -r video_title views watch_time subscribers likes comments rest; do
        # 清理数据
        views=$(normalize_number "$views")
        likes=$(normalize_number "$likes")
        comments=$(normalize_number "$comments")

        # 保存到临时文件用于计算平均值
        echo "$views,$likes,$comments" >> "$temp_metrics_file"
    done

    # 计算平均值和阈值
    local avg_views avg_likes avg_comments
    avg_views=$(cut -d',' -f1 "$temp_metrics_file" | calculate_average)
    avg_likes=$(cut -d',' -f2 "$temp_metrics_file" | calculate_average)
    avg_comments=$(cut -d',' -f3 "$temp_metrics_file" | calculate_average)

    log_info "Average views: $avg_views"
    log_info "Average likes: $avg_likes"

    # YouTube 阈值: 观看量 > 100k 或 > 3x 平均值
    local view_threshold=100000
    local threshold_views threshold_likes
    threshold_views=$(echo "$avg_views * 3" | bc | cut -d'.' -f1)
    threshold_likes=$(echo "$avg_likes * 3" | bc | cut -d'.' -f1)

    # 使用较高的阈值
    if [[ $threshold_views -lt $view_threshold ]]; then
        threshold_views=$view_threshold
    fi

    log_info "High performance threshold - Views: $threshold_views, Likes: $threshold_likes"

    # 第二遍读取,提取高表现视频
    tail -n +2 "$csv_file" | while IFS=, read -r video_title views watch_time subscribers likes comments rest; do
        # 清理数据
        video_title=$(clean_csv_value "$video_title")
        views=$(normalize_number "$views")
        likes=$(normalize_number "$likes")
        comments=$(normalize_number "$comments")

        # 计算点赞率
        local like_rate
        if [[ $views -gt 0 ]]; then
            like_rate=$(echo "scale=4; $likes / $views" | bc)
        else
            like_rate=0
        fi

        # 判断是否高表现
        if [[ $views -ge $threshold_views ]] || [[ $likes -ge $threshold_likes ]]; then
            # 计算评分 (0-100)
            local score
            score=$(calculate_youtube_score "$views" "$likes" "$comments" "$like_rate" "$avg_views" "$avg_likes")

            # 生成 topic ID
            local topic_id
            topic_id=$(generate_id "topic")

            # 添加到 validated-topics.json
            add_topic_from_csv "$topic_id" "$video_title" "youtube" "$score" "$views" "$likes" "$like_rate"

            ((high_performance_count++))
            log_success "Added high-performance video (score: $score): ${video_title:0:50}..."
        fi

        ((imported_count++))
    done

    # 清理临时文件
    rm -f "$temp_metrics_file"

    log_success "Import completed: $imported_count videos analyzed, $high_performance_count high-performance topics added"

    success \
        '"action": "csv_imported",' \
        '"data": {' \
        '  "source": "youtube",' \
        '  "total_rows": '"$imported_count"',' \
        '  "topics_added": '"$high_performance_count"',' \
        '  "view_threshold": '"$view_threshold"'' \
        '}'
}

# 计算 YouTube 评分
calculate_youtube_score() {
    local views="$1"
    local likes="$2"
    local comments="$3"
    local like_rate="$4"
    local avg_views="$5"
    local avg_likes="$6"

    # 多维度评分
    # 1. 互动数据 (40%): 点赞数相对于平均值
    local engagement_score
    if [[ $(echo "$avg_likes > 0" | bc) -eq 1 ]]; then
        engagement_score=$(echo "scale=2; ($likes / $avg_likes) * 40" | bc)
    else
        engagement_score=0
    fi

    # 2. 传播速度 (30%): 观看量相对于平均值
    local spread_score
    if [[ $(echo "$avg_views > 0" | bc) -eq 1 ]]; then
        spread_score=$(echo "scale=2; ($views / $avg_views) * 30" | bc)
    else
        spread_score=0
    fi

    # 3. 受众质量 (20%): 点赞率
    local quality_score
    quality_score=$(echo "scale=2; $like_rate * 2000" | bc)

    # 4. 绝对数值 (10%): 基于观看量
    local absolute_score
    if [[ $views -gt 1000000 ]]; then
        absolute_score=10
    elif [[ $views -gt 500000 ]]; then
        absolute_score=8
    elif [[ $views -gt 100000 ]]; then
        absolute_score=6
    else
        absolute_score=3
    fi

    # 总分
    local total_score
    total_score=$(echo "scale=2; $engagement_score + $spread_score + $quality_score + $absolute_score" | bc)

    # 归一化到 0-100
    if [[ $(echo "$total_score > 100" | bc) -eq 1 ]]; then
        total_score=100
    fi

    # 转换为整数
    printf "%.0f" "$total_score"
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
        import-twitter-csv)
            import_twitter_csv "$2"
            ;;
        youtube)
            validate_youtube "$2"
            ;;
        import-youtube-csv)
            import_youtube_csv "$2"
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
