#!/bin/bash
# research.sh - 深度研究脚本
# Viralfy v1.0.0

# 导入公共函数
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 配置
RESEARCH_DIR="research"
IDEAS_DIR="ideas"

# ============================================
# 主函数
# ============================================

main() {
    # 确保在项目根目录
    local project_root
    project_root=$(ensure_project_root)

    log_info "Starting research process..."

    # 确保目录存在
    ensure_dir "$RESEARCH_DIR"

    # 如果没有指定 topic,显示可用主题列表
    success \
        '"action": "select_topic",' \
        '"data": {' \
        '  "research_dir": "'"$RESEARCH_DIR"'"' \
        '}'
}

# ============================================
# 初始化研究 (为指定主题创建知识库)
# ============================================

init_research() {
    local topic_id="$1"
    local topic_title="$2"

    log_info "Initializing research for topic: $topic_id"

    # 创建知识库文件
    local kb_file="$RESEARCH_DIR/${topic_id}-knowledge-base.md"

    if [[ -f "$kb_file" ]]; then
        log_info "Knowledge base already exists: $kb_file"
    else
        # 创建初始知识库
        cat > "$kb_file" <<EOF
# $topic_title

> 主题 ID: $topic_id
> 创建时间: $(timestamp)

---

## 核心观点

(待补充...)

## 关键论据

(待补充...)

## 实战案例

(待补充...)

## 独特视角

(待补充...)

## 研究来源

(待补充...)

---

**最后更新**: $(timestamp)
EOF
        log_success "Created knowledge base: $kb_file"
    fi

    # 创建研究材料目录
    local materials_dir="$RESEARCH_DIR/${topic_id}-materials"
    ensure_dir "$materials_dir"

    success \
        '"action": "research_initialized",' \
        '"data": {' \
        '  "topic_id": "'"$topic_id"'",' \
        '  "knowledge_base": "'"$kb_file"'",' \
        '  "materials_dir": "'"$materials_dir"'"' \
        '}'
}

# ============================================
# 添加研究材料
# ============================================

add_material() {
    local topic_id="$1"
    local source_type="$2"  # youtube, pdf, article, manual
    local source="$3"       # URL or file path

    log_info "Adding research material: $source_type - $source"

    local materials_dir="$RESEARCH_DIR/${topic_id}-materials"
    ensure_dir "$materials_dir"

    # 生成材料 ID
    local material_id
    material_id=$(generate_id "material")

    # 创建材料元数据文件
    local metadata_file="$materials_dir/${material_id}-metadata.json"

    cat > "$metadata_file" <<EOF
{
  "id": "$material_id",
  "topic_id": "$topic_id",
  "source_type": "$source_type",
  "source": "$source",
  "added_at": "$(timestamp)",
  "status": "pending"
}
EOF

    log_success "Material added: $material_id"

    success \
        '"action": "material_added",' \
        '"data": {' \
        '  "material_id": "'"$material_id"'",' \
        '  "topic_id": "'"$topic_id"'",' \
        '  "source_type": "'"$source_type"'",' \
        '  "source": "'"$source"'"' \
        '}'
}

# ============================================
# 保存研究笔记
# ============================================

save_notes() {
    local topic_id="$1"
    local section="$2"  # core_insights, key_arguments, examples, perspectives
    local content="$3"

    log_info "Saving notes for topic: $topic_id, section: $section"

    local kb_file="$RESEARCH_DIR/${topic_id}-knowledge-base.md"

    if [[ ! -f "$kb_file" ]]; then
        error "Knowledge base not found: $kb_file. Run init_research first."
        return 1
    fi

    # 创建临时笔记文件
    local notes_file="$RESEARCH_DIR/${topic_id}-notes-${section}.md"
    echo "$content" > "$notes_file"

    log_success "Notes saved: $notes_file"

    success \
        '"action": "notes_saved",' \
        '"data": {' \
        '  "topic_id": "'"$topic_id"'",' \
        '  "section": "'"$section"'",' \
        '  "notes_file": "'"$notes_file"'"' \
        '}'
}

# ============================================
# 完成研究
# ============================================

complete_research() {
    local topic_id="$1"

    log_info "Completing research for topic: $topic_id"

    local kb_file="$RESEARCH_DIR/${topic_id}-knowledge-base.md"

    if [[ ! -f "$kb_file" ]]; then
        error "Knowledge base not found: $kb_file"
        return 1
    fi

    # 更新知识库的最后更新时间
    local temp_file="${kb_file}.tmp"
    sed "s/\*\*最后更新\*\*: .*/\*\*最后更新\*\*: $(timestamp)/" \
        "$kb_file" > "$temp_file"
    mv "$temp_file" "$kb_file"

    # 更新 validated-topics.json 中的状态
    local topics_file="$IDEAS_DIR/validated-topics.json"
    if [[ -f "$topics_file" ]]; then
        if command -v jq &> /dev/null; then
            local temp_file="${topics_file}.tmp"
            jq --arg id "$topic_id" \
                '(.topics[] | select(.id == $id) | .status) = "researching"' \
                "$topics_file" > "$temp_file"
            mv "$temp_file" "$topics_file"
        fi
    fi

    log_success "Research completed for topic: $topic_id"

    success \
        '"action": "research_completed",' \
        '"data": {' \
        '  "topic_id": "'"$topic_id"'",' \
        '  "knowledge_base": "'"$kb_file"'"' \
        '}'
}

# ============================================
# 列出研究材料
# ============================================

list_materials() {
    local topic_id="$1"

    log_info "Listing materials for topic: $topic_id"

    local materials_dir="$RESEARCH_DIR/${topic_id}-materials"

    if [[ ! -d "$materials_dir" ]]; then
        success \
            '"action": "list_materials",' \
            '"data": {' \
            '  "materials": [],' \
            '  "count": 0' \
            '}'
        return
    fi

    # 收集所有材料元数据
    local materials_json="["
    local first=true

    for metadata_file in "$materials_dir"/*-metadata.json; do
        if [[ -f "$metadata_file" ]]; then
            if [[ "$first" == true ]]; then
                first=false
            else
                materials_json+=","
            fi
            materials_json+=$(cat "$metadata_file")
        fi
    done

    materials_json+="]"

    # 计算数量
    local count
    if command -v jq &> /dev/null; then
        count=$(echo "$materials_json" | jq 'length')
    else
        count=$(ls -1 "$materials_dir"/*-metadata.json 2>/dev/null | wc -l | tr -d ' ')
    fi

    echo "{\"status\": \"success\", \"action\": \"list_materials\", \"data\": {\"materials\": $materials_json, \"count\": $count}}"
}

# ============================================
# 执行主函数或子命令
# ============================================

# 检查是否有参数 (用于特殊操作)
if [[ $# -gt 0 ]]; then
    case "$1" in
        init)
            init_research "$2" "$3"
            ;;
        add-material)
            add_material "$2" "$3" "$4"
            ;;
        save-notes)
            save_notes "$2" "$3" "$4"
            ;;
        complete)
            complete_research "$2"
            ;;
        list-materials)
            list_materials "$2"
            ;;
        *)
            error "Unknown operation: $1"
            ;;
    esac
else
    main
fi
