#!/bin/bash

# 配置变量
CONTAINER_NAME="blog_amsf_docker-amsf-1"
SOURCE_DIR="/app/_site"
TEMP_DIR="../dists"
TARGET_DIR="/var/www/html"
LOG_FILE="deploy.log"

# 初始化日志
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 开始部署" | tee -a $LOG_FILE

# 检查Docker服务状态
if ! docker ps &>/dev/null; then
    echo "错误: Docker服务未运行" | tee -a $LOG_FILE
    exit 1
fi

# 执行部署流程
{
    echo "1. 启动Docker容器..."
    docker compose up || exit 1

    echo "2. 复制生成内容到临时目录..."
    docker cp $CONTAINER_NAME:$SOURCE_DIR/. $TEMP_DIR || exit 1

    echo "3. 同步到生产环境..."
    rsync -av --delete $TEMP_DIR/. $TARGET_DIR || exit 1

    echo "4. 验证部署结果..."
    echo "目标目录: $TARGET_DIR"
    echo ""
    echo "博客文章内容:"
    find $TARGET_DIR -type f \( -name "*.html" -o -name "*.md" \)

    echo "5. 重新加载Nginx..."
    nginx -s reload || exit 1

    echo "6. 清理临时文件..."
    rm -rf $TEMP_DIR
} | tee -a $LOG_FILE

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 部署完成" | tee -a $LOG_FILE

# 日志文件处理，考虑到日志不会太大，单个128KiB文件应该足够。
LOG_SIZE=$(du -k "$LOG_FILE" | cut -f1)
if [ "$LOG_SIZE" -gt 128 ]; then
    echo "日志文件大于128KiB，正在压缩..."
    gzip -c "$LOG_FILE" > "$LOG_FILE.gz" && rm "$LOG_FILE"
fi