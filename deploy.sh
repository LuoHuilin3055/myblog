#!/bin/bash

echo -e "\033[0;32m🚀 开始部署...\033[0m"

# 1. 推送源文件
echo "📦 推送源文件..."
git add .
git commit -m "更新源文件: $(date '+%Y-%m-%d %H:%M:%S')"
git push origin master

# 2. 生成网站
echo "🏗️ 生成静态文件..."
hugo -t theme2

# 3. 部署到 GitHub Pages
echo "☁️ 部署到 GitHub Pages..."
cd public

if [ ! -d ".git" ]; then
    git init
    git remote add origin git@github.com:LuoHuilin3055/myblog.git
else
    git remote set-url origin git@github.com:LuoHuilin3055/myblog.git
fi

git add .
git commit -m "部署博客: $(date '+%Y-%m-%d %H:%M:%S')"
git push -f origin master

cd ..

echo -e "\033[0;32m✅ 部署完成！\033[0m"
echo "🌐 访问: https://LuoHuilin3055.github.io/myblog/"
