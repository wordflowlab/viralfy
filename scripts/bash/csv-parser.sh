#!/bin/bash
# csv-parser.sh - CSV 解析工具库
# Viralfy v1.0.0

# ============================================
# CSV 解析函数
# ============================================

# 解析 CSV 文件并转换为 JSON 数组
# 参数:
#   $1 - CSV 文件路径
#   $2 - 分隔符 (默认: ,)
parse_csv() {
    local csv_file="$1"
    local delimiter="${2:-,}"

    if [[ ! -f "$csv_file" ]]; then
        echo "[]"
        return 1
    fi

    # 检查文件是否为空
    if [[ ! -s "$csv_file" ]]; then
        echo "[]"
        return 1
    fi

    # 使用 awk 解析 CSV
    awk -F"$delimiter" '
    BEGIN {
        OFS = ","
        print "["
        first_row = 1
    }
    NR == 1 {
        # 保存表头
        header_count = NF
        for (i = 1; i <= NF; i++) {
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", $i)  # 去除空格
            headers[i] = $i
        }
        next
    }
    NR > 1 {
        if (!first_row) print ","
        first_row = 0

        print "  {"
        for (i = 1; i <= header_count; i++) {
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", $i)  # 去除空格
            gsub(/"/, "\\\"", $i)  # 转义引号

            if (i > 1) print ","
            printf "    \"%s\": \"%s\"", headers[i], $i
        }
        print ""
        printf "  }"
    }
    END {
        print ""
        print "]"
    }
    ' "$csv_file"
}

# ============================================
# CSV 数据验证
# ============================================

# 验证 CSV 文件格式
# 参数:
#   $1 - CSV 文件路径
#   $2 - 必需的列名数组 (逗号分隔)
validate_csv_format() {
    local csv_file="$1"
    local required_columns="$2"

    if [[ ! -f "$csv_file" ]]; then
        echo "error: File not found: $csv_file"
        return 1
    fi

    # 读取表头
    local header
    header=$(head -n 1 "$csv_file")

    # 检查必需的列
    IFS=',' read -ra REQUIRED <<< "$required_columns"
    for col in "${REQUIRED[@]}"; do
        if ! echo "$header" | grep -qi "$col"; then
            echo "error: Missing required column: $col"
            return 1
        fi
    done

    echo "success"
    return 0
}

# ============================================
# 数据提取函数
# ============================================

# 从 CSV 中提取指定列
# 参数:
#   $1 - CSV 文件路径
#   $2 - 列名
#   $3 - 行号 (可选,默认全部)
extract_column() {
    local csv_file="$1"
    local column_name="$2"
    local row_num="${3:-0}"

    if [[ ! -f "$csv_file" ]]; then
        return 1
    fi

    # 查找列索引
    local header
    header=$(head -n 1 "$csv_file")
    local col_index=0
    local i=1

    IFS=',' read -ra COLS <<< "$header"
    for col in "${COLS[@]}"; do
        col=$(echo "$col" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        if [[ "$col" == "$column_name" ]]; then
            col_index=$i
            break
        fi
        ((i++))
    done

    if [[ $col_index -eq 0 ]]; then
        return 1
    fi

    # 提取数据
    if [[ $row_num -eq 0 ]]; then
        # 提取所有行
        tail -n +2 "$csv_file" | cut -d',' -f"$col_index"
    else
        # 提取指定行
        sed -n "${row_num}p" "$csv_file" | cut -d',' -f"$col_index"
    fi
}

# ============================================
# 统计分析函数
# ============================================

# 计算数组平均值
# 输入: 通过 stdin 传入数字列表 (每行一个)
calculate_average() {
    awk '{sum += $1; count++} END {if (count > 0) print sum/count; else print 0}'
}

# 计算数组中位数
# 输入: 通过 stdin 传入数字列表 (每行一个)
calculate_median() {
    sort -n | awk '
    BEGIN {
        count = 0
    }
    {
        values[count++] = $1
    }
    END {
        if (count == 0) {
            print 0
        } else if (count % 2 == 1) {
            print values[int(count/2)]
        } else {
            print (values[count/2-1] + values[count/2]) / 2
        }
    }
    '
}

# 计算标准差
# 输入: 通过 stdin 传入数字列表 (每行一个)
calculate_stddev() {
    awk '
    BEGIN {
        count = 0
        sum = 0
    }
    {
        values[count++] = $1
        sum += $1
    }
    END {
        if (count == 0) {
            print 0
        } else {
            avg = sum / count
            sum_sq = 0
            for (i = 0; i < count; i++) {
                sum_sq += (values[i] - avg) ^ 2
            }
            print sqrt(sum_sq / count)
        }
    }
    '
}

# 计算列的统计摘要
# 参数:
#   $1 - CSV 文件路径
#   $2 - 列名
calculate_column_stats() {
    local csv_file="$1"
    local column_name="$2"

    local values
    values=$(extract_column "$csv_file" "$column_name")

    if [[ -z "$values" ]]; then
        cat <<EOF
{
  "average": 0,
  "median": 0,
  "stddev": 0,
  "min": 0,
  "max": 0,
  "count": 0
}
EOF
        return
    fi

    local average median stddev min max count
    average=$(echo "$values" | grep -E '^[0-9]+(\.[0-9]+)?$' | calculate_average)
    median=$(echo "$values" | grep -E '^[0-9]+(\.[0-9]+)?$' | calculate_median)
    stddev=$(echo "$values" | grep -E '^[0-9]+(\.[0-9]+)?$' | calculate_stddev)
    min=$(echo "$values" | grep -E '^[0-9]+(\.[0-9]+)?$' | sort -n | head -1)
    max=$(echo "$values" | grep -E '^[0-9]+(\.[0-9]+)?$' | sort -n | tail -1)
    count=$(echo "$values" | grep -E '^[0-9]+(\.[0-9]+)?$' | wc -l | tr -d ' ')

    cat <<EOF
{
  "average": ${average:-0},
  "median": ${median:-0},
  "stddev": ${stddev:-0},
  "min": ${min:-0},
  "max": ${max:-0},
  "count": ${count:-0}
}
EOF
}

# ============================================
# 数据清洗函数
# ============================================

# 清理 CSV 数据中的特殊字符
clean_csv_value() {
    local value="$1"

    # 移除引号
    value=$(echo "$value" | sed 's/^"//;s/"$//')

    # 转义特殊字符
    value=$(echo "$value" | sed 's/\\/\\\\/g; s/"/\\"/g')

    # 移除换行符
    value=$(echo "$value" | tr -d '\n\r')

    echo "$value"
}

# 将 CSV 数值转换为数字
# 处理: 1,234 → 1234, 12.5K → 12500
normalize_number() {
    local value="$1"

    # 移除逗号
    value=$(echo "$value" | tr -d ',')

    # 处理 K (千)
    if echo "$value" | grep -qi 'k$'; then
        value=$(echo "$value" | sed 's/[kK]$//')
        value=$(echo "$value * 1000" | bc)
    fi

    # 处理 M (百万)
    if echo "$value" | grep -qi 'm$'; then
        value=$(echo "$value" | sed 's/[mM]$//')
        value=$(echo "$value * 1000000" | bc)
    fi

    # 保留整数部分
    echo "$value" | cut -d'.' -f1
}

# ============================================
# CSV 行数统计
# ============================================

# 获取 CSV 数据行数 (不包括表头)
get_csv_row_count() {
    local csv_file="$1"

    if [[ ! -f "$csv_file" ]]; then
        echo "0"
        return
    fi

    local count
    count=$(tail -n +2 "$csv_file" | wc -l | tr -d ' ')
    echo "$count"
}

# ============================================
# 导出函数 (供其他脚本使用)
# ============================================

export -f parse_csv
export -f validate_csv_format
export -f extract_column
export -f calculate_average
export -f calculate_median
export -f calculate_stddev
export -f calculate_column_stats
export -f clean_csv_value
export -f normalize_number
export -f get_csv_row_count
