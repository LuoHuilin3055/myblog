#!/bin/bash
set -euo pipefail

SOURCE_BRANCH="${SOURCE_BRANCH:-master}"
REMOTE="${REMOTE:-origin}"

echo -e "\033[0;32m🚀 开始部署...\033[0m"

echo "📦 推送源码到 ${REMOTE}/${SOURCE_BRANCH}..."
git add .
if git diff --cached --quiet; then
  echo "没有需要提交的源码改动。"
else
  git commit -m "更新源文件: $(date '+%Y-%m-%d %H:%M:%S')"
fi
git push "${REMOTE}" "${SOURCE_BRANCH}"

echo "🏗️ 生成静态文件..."
hugo -t theme2 --cleanDestinationDir

echo "☁️ 已推送源码。GitHub Actions 会自动构建并发布 public/。"

echo -e "\033[0;32m✅ 部署完成！\033[0m"
echo "🌐 请在 GitHub Pages 页面查看 Actions 发布后的站点地址。"
