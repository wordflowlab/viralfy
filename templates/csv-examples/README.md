# CSV 示例文件

本目录包含 CSV 导入功能的示例文件,帮助您理解正确的数据格式。

## 文件列表

### twitter-sample.csv
Twitter Analytics 导出数据的示例格式。

**包含的列**:
- `Tweet id`: 推文唯一标识符
- `Tweet text`: 推文完整内容
- `time`: 发布时间
- `impressions`: 展示量
- `engagements`: 总互动数
- `engagement rate`: 互动率
- `retweets`: 转发数
- `replies`: 回复数
- `likes`: 点赞数

**使用方法**:
```bash
viralfy validate
# 选择 "2. 导入 Twitter CSV"
# 输入: templates/csv-examples/twitter-sample.csv
```

### youtube-sample.csv
YouTube Studio 导出数据的示例格式。

**包含的列**:
- `Video title`: 视频标题
- `Views`: 观看量
- `Watch time (hours)`: 观看时长(小时)
- `Subscribers`: 新增订阅者
- `Likes`: 点赞数
- `Comments`: 评论数

**使用方法**:
```bash
viralfy validate
# 选择 "3. 导入 YouTube CSV"
# 输入: templates/csv-examples/youtube-sample.csv
```

## 测试导入

您可以使用这些示例文件测试 CSV 导入功能:

```bash
# 1. 初始化测试项目
mkdir test-project && cd test-project
viralfy init

# 2. 测试 Twitter CSV 导入
viralfy validate
# 选择 "2. 导入 Twitter CSV"
# 输入: ../templates/csv-examples/twitter-sample.csv

# 3. 查看导入结果
cat ideas/validated-topics.json

# 4. 测试 YouTube CSV 导入
viralfy validate
# 选择 "3. 导入 YouTube CSV"
# 输入: ../templates/csv-examples/youtube-sample.csv

# 5. 查看完整列表
viralfy validate list
```

## 自定义您的 CSV

### Twitter CSV
从您自己的 Twitter Analytics 导出数据:
1. 访问 https://analytics.twitter.com
2. 点击 "Tweets" → "Export data"
3. 下载 CSV 文件
4. 确保包含上述必需的列

### YouTube CSV
从 YouTube Studio 导出数据:
1. 访问 https://studio.youtube.com
2. Analytics → Advanced mode → Content
3. 点击 "Export" → CSV
4. 下载文件

## 注意事项

- **编码**: 确保 CSV 文件使用 UTF-8 编码
- **分隔符**: 必须使用逗号(,)作为分隔符
- **引号**: 包含逗号的文本需要用双引号包裹
- **空行**: 不要包含空行
- **最小数据量**: 建议至少 20 行数据以获得准确的统计结果

## 相关文档

- [CSV 导入完整指南](../../docs/CSV_IMPORT_GUIDE.md)
- [评分系统说明](../../docs/CSV_IMPORT_GUIDE.md#评分系统说明)
- [常见问题](../../docs/CSV_IMPORT_GUIDE.md#常见问题)
