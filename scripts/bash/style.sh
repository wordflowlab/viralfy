#!/bin/bash
# style.sh - 写作风格训练脚本
# Viralfy v1.0.0

# 导入公共函数
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 配置
PERSONAS_DIR="swipe-files/personas"
SAMPLES_DIR="swipe-files/samples"

# ============================================
# 主函数
# ============================================

main() {
    # 确保在项目根目录
    local project_root
    project_root=$(ensure_project_root)

    local author="$1"
    local platform="$2"

    if [[ -z "$author" ]]; then
        error "Author name is required"
        return 1
    fi

    log_info "Starting style training for author: $author"

    # 确保目录存在
    ensure_dir "$PERSONAS_DIR"
    ensure_dir "$SAMPLES_DIR"

    # 生成 persona ID
    local persona_id
    persona_id=$(echo "$author" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

    success \
        '"action": "init_training",' \
        '"data": {' \
        '  "persona_id": "'"$persona_id"'",' \
        '  "author": "'"$author"'",' \
        '  "platform": "'"$platform"'",' \
        '  "personas_dir": "'"$PERSONAS_DIR"'"' \
        '}'
}

# ============================================
# 保存样本内容
# ============================================

save_sample() {
    local persona_id="$1"
    local sample_title="$2"
    local content="$3"
    local url="$4"

    log_info "Saving sample content for persona: $persona_id"

    local samples_dir="$SAMPLES_DIR/$persona_id"
    ensure_dir "$samples_dir"

    # 生成样本 ID
    local sample_id
    sample_id=$(generate_id "sample")

    local sample_file="$samples_dir/${sample_id}.md"
    cat > "$sample_file" <<EOF
# $sample_title

**作者**: $persona_id
**采集时间**: $(timestamp)
**来源**: $url

---

$content
EOF

    log_success "Sample saved: $sample_file"

    success \
        '"action": "sample_saved",' \
        '"data": {' \
        '  "persona_id": "'"$persona_id"'",' \
        '  "sample_id": "'"$sample_id"'",' \
        '  "sample_file": "'"$sample_file"'"' \
        '}'
}

# ============================================
# 保存 Persona 配置
# ============================================

save_persona() {
    local persona_id="$1"
    local persona_content="$2"

    log_info "Saving persona configuration: $persona_id"

    local persona_file="$PERSONAS_DIR/${persona_id}.yaml"
    echo "$persona_content" > "$persona_file"

    log_success "Persona saved: $persona_file"

    success \
        '"action": "persona_saved",' \
        '"data": {' \
        '  "persona_id": "'"$persona_id"'",' \
        '  "persona_file": "'"$persona_file"'"' \
        '}'
}

# ============================================
# 列出所有 Personas
# ============================================

list_personas() {
    log_info "Listing all personas"

    if [[ ! -d "$PERSONAS_DIR" ]]; then
        success \
            '"action": "list",' \
            '"data": {' \
            '  "personas": [],' \
            '  "count": 0' \
            '}'
        return
    fi

    # 收集所有 persona 文件
    local personas_json="["
    local first=true
    local count=0

    for persona_file in "$PERSONAS_DIR"/*.yaml; do
        if [[ -f "$persona_file" ]]; then
            if [[ "$first" == true ]]; then
                first=false
            else
                personas_json+=","
            fi

            local persona_id
            persona_id=$(basename "$persona_file" .yaml)

            # 尝试提取作者名称(简化实现)
            local author_name
            if grep -q "^  name:" "$persona_file"; then
                author_name=$(grep "^  name:" "$persona_file" | sed 's/.*: *//')
            else
                author_name="$persona_id"
            fi

            personas_json+="{\"id\": \"$persona_id\", \"name\": \"$author_name\", \"file\": \"$persona_file\"}"
            count=$((count + 1))
        fi
    done

    personas_json+="]"

    echo "{\"status\": \"success\", \"action\": \"list\", \"data\": {\"personas\": $personas_json, \"count\": $count}}"
}

# ============================================
# 获取 Persona 详情
# ============================================

get_persona() {
    local persona_id="$1"

    log_info "Getting persona: $persona_id"

    local persona_file="$PERSONAS_DIR/${persona_id}.yaml"

    if [[ ! -f "$persona_file" ]]; then
        error "Persona not found: $persona_id"
        return 1
    fi

    # 返回 persona 文件内容
    success \
        '"action": "get_persona",' \
        '"data": {' \
        '  "persona_id": "'"$persona_id"'",' \
        '  "persona_file": "'"$persona_file"'",' \
        '  "content": "' "$(cat "$persona_file" | sed 's/"/\\"/g' | tr '\n' ' ')" '"' \
        '}'
}

# ============================================
# 列出样本内容
# ============================================

list_samples() {
    local persona_id="$1"

    log_info "Listing samples for persona: $persona_id"

    local samples_dir="$SAMPLES_DIR/$persona_id"

    if [[ ! -d "$samples_dir" ]]; then
        success \
            '"action": "list_samples",' \
            '"data": {' \
            '  "samples": [],' \
            '  "count": 0' \
            '}'
        return
    fi

    local count
    count=$(ls -1 "$samples_dir"/*.md 2>/dev/null | wc -l | tr -d ' ')

    local samples_json="["
    local first=true

    for sample_file in "$samples_dir"/*.md; do
        if [[ -f "$sample_file" ]]; then
            if [[ "$first" == true ]]; then
                first=false
            else
                samples_json+=","
            fi

            local sample_id
            sample_id=$(basename "$sample_file" .md)

            samples_json+="{\"id\": \"$sample_id\", \"file\": \"$sample_file\"}"
        fi
    done

    samples_json+="]"

    echo "{\"status\": \"success\", \"action\": \"list_samples\", \"data\": {\"samples\": $samples_json, \"count\": $count}}"
}

# ============================================
# 执行主函数或子命令
# ============================================

# 检查是否有参数 (用于特殊操作)
if [[ $# -gt 1 ]]; then
    case "$1" in
        save-sample)
            save_sample "$2" "$3" "$4" "$5"
            ;;
        save-persona)
            save_persona "$2" "$3"
            ;;
        list)
            list_personas
            ;;
        get)
            get_persona "$2"
            ;;
        list-samples)
            list_samples "$2"
            ;;
        *)
            main "$@"
            ;;
    esac
else
    main "$@"
fi
