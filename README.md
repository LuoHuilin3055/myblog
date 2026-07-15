# NGC 2237's Blog

一个基于 [Hugo](https://gohugo.io/) 的个人博客源码仓库，包含文章、数据文件、自定义模板、写作辅助脚本，以及 GitHub Pages 自动部署配置。

## 目录

- [快速开始](#快速开始)
- [项目结构](#项目结构)
- [写作与发布流程](#写作与发布流程)
- [脚本说明](#脚本说明)
- [图片管理](#图片管理)
- [站点配置](#站点配置)
- [数据文件](#数据文件)
- [评论区](#评论区)
- [部署](#部署)
- [常见问题](#常见问题)

## 快速开始

### 环境要求

- Git
- Hugo Extended（GitHub Actions 当前使用 `0.158.0`）
- PowerShell 7（运行仓库中的辅助脚本）

克隆仓库并进入项目目录后，启动本地预览：

```powershell
hugo server -D
```

`-D` 会同时显示草稿文章。生成正式静态站点：

```powershell
hugo -t theme2 --cleanDestinationDir
```

构建产物位于 `public/`。该目录由 Hugo 自动生成，不应作为源码手动维护。

## 项目结构

```text
.
├── archetypes/             # Hugo 内容模板
├── assets/                 # 由 Hugo 管线处理的样式等资源
├── content/                # Markdown 内容
│   ├── posts/              # 文章
│   ├── logs/               # 日志
│   ├── murmur/             # 碎碎念栏目
│   ├── about.md            # 关于页
│   ├── friends.md          # 友链页
│   └── schedule.md         # 日程页
├── data/                   # 友链、碎碎念和日程数据
├── layouts/                # 自定义 Hugo 模板
├── scripts/                # 写作、图片处理和检查脚本
├── static/                 # 原样复制到站点根目录的公共资源
├── themes/theme2/          # Hugo 主题
├── .github/workflows/      # GitHub Pages 自动部署
├── config.toml             # 当前站点配置
├── config.example.toml     # 可复用的配置示例
└── deploy.sh               # 提交、推送和本地构建脚本
```

## 写作与发布流程

推荐使用 Page Bundle，即“一篇文章一个文件夹”。完整流程如下：

1. 创建文章：

   ```powershell
   .\scripts\new-post.ps1 "文章标题"
   ```

2. 编辑生成的 `content/posts/文章标题/index.md`，插入正文和图片。

3. 整理文章图片：

   ```powershell
   .\scripts\prepare-post-images.ps1 "content\posts\文章标题"
   ```

4. 发布前检查：

   ```powershell
   .\scripts\check-blog.ps1
   ```

5. 将文章 front matter 中的草稿状态改为：

   ```yaml
   draft: false
   ```

6. 提交并推送到 `master`，GitHub Actions 会自动构建和发布。

也可以使用 Hugo 创建普通 Markdown 文章：

```powershell
hugo new posts/my-new-post.md
```

## 脚本说明

所有 PowerShell 命令都应在仓库根目录执行。

### `new-post.ps1`：创建文章

创建 Page Bundle，并生成包含 `draft: true` 的 `index.md`：

```powershell
.\scripts\new-post.ps1 "我的新文章"
```

指定目录名、封面和标签：

```powershell
.\scripts\new-post.ps1 "我的新文章" "my-new-post" `
  -Cover "images/post-cover.jpg" `
  -Tags "Hugo","博客"
```

如果目标目录已经存在，脚本会停止，不会覆盖原文章。

### `prepare-post-images.ps1`：整理文章图片

接受文章目录或 Markdown 文件：

```powershell
.\scripts\prepare-post-images.ps1 "content\posts\my-post"
.\scripts\prepare-post-images.ps1 "content\posts\my-post\index.md"
```

脚本会查找文章引用的本地图片，将图片复制到文章目录，依次命名为 `img-001.png`、`img-002.jpg` 等，并更新 Markdown 引用。相对路径会从文章目录开始逐级向父目录查找。

支持标准 Markdown 图片和 Obsidian 图片语法：

```markdown
![](D:\Pictures\demo.png)
![](<../picture/屏幕截图.png>)
![[Pasted image 20260528170436.png]]
```

只预览处理结果，不写入文件：

```powershell
.\scripts\prepare-post-images.ps1 "content\posts\my-post" -WhatIf
```

如需删除已经成功复制的 Obsidian 原始粘贴图，请先预览：

```powershell
.\scripts\prepare-post-images.ps1 "content\posts\my-post" `
  -DeleteOriginalObsidianImages `
  -WhatIf
```

确认后去掉 `-WhatIf`：

```powershell
.\scripts\prepare-post-images.ps1 "content\posts\my-post" `
  -DeleteOriginalObsidianImages
```

删除操作只针对名称符合 `Pasted image 20260528170436.png` 格式、已成功复制且内容一致的原图。

### `optimize-images.ps1`：压缩图片

默认是预览模式，不会覆盖文件：

```powershell
.\scripts\optimize-images.ps1 -Path content,static
```

确认结果后正式应用：

```powershell
.\scripts\optimize-images.ps1 -Path content,static -Apply
```

脚本默认处理 Git 已跟踪、大小超过 `512KB` 的 JPG、JPEG 和 PNG；压缩结果更大时会自动跳过。常用选项：

```powershell
# 使用更保守的 JPEG 质量
.\scripts\optimize-images.ps1 -Path content,static -JpegQuality 88 -Apply

# 同时处理 Git 尚未跟踪的新图片
.\scripts\optimize-images.ps1 -Path content,static -IncludeUntracked

# 只报告超过指定阈值的大图片
.\scripts\optimize-images.ps1 -Path content,static -MinBytes 1MB -ReportLarge
```

### `check-blog.ps1`：发布前检查

```powershell
.\scripts\check-blog.ps1
```

检查内容包括：

- Hugo 是否能够成功构建
- `draft:` 是否为空
- Markdown 是否引用了不存在的图片
- 是否存在超过 2MB 的图片
- 是否硬编码了 `/myblog/` 或 `github.io` 地址

只检查内容、不运行 Hugo 构建：

```powershell
.\scripts\check-blog.ps1 -SkipBuild
```

调整大图片阈值：

```powershell
.\scripts\check-blog.ps1 -LargeImageMB 5
```

该脚本只报告问题，不修改内容；发现问题时返回退出码 `1`。

## 图片管理

### 推荐目录

文章专用图片放在 Page Bundle 中：

```text
content/posts/my-post/
├── index.md
├── img-001.png
└── img-002.jpg
```

文章内使用同目录相对路径：

```markdown
![](img-001.png)
```

头像、背景、公共封面等多处复用的资源放在 `static/images/`：

```text
static/images/avatar.jpg  -> 配置或 Markdown 中写 images/avatar.jpg
```

不要在内容中写死 `/myblog/...` 或 `https://用户名.github.io/...`。仓库改名、被 fork 或本地预览时，这类地址容易失效。

### 列表页横幅

全局横幅在 `config.toml` 中配置：

```toml
[params]
  page_header_image = "images/background.jpg"
```

单个页面可通过 front matter 覆盖：

```toml
+++
title = "文章"
header_image = "images/posts-banner.jpg"
+++
```

优先级为：页面 `header_image` > 全局 `params.page_header_image` > `images/background.jpg`。

`featured_image` 用作默认展示图和分享图，`page_header_image` 用于列表页顶部横幅，两者可以不同。

## 站点配置

主要配置位于 `config.toml`，可参考 `config.example.toml` 创建自己的配置：

```toml
baseURL = "https://yourname.github.io/your-blog/"
languageCode = "zh-cn"
title = "Your Blog"
theme = "theme2"

[params]
  site_title = "Your Name"
  description = "欢迎来到我的博客"
  author = "Your Name"
  avatar = "images/avatar.jpg"
  bio = "Hi, there ~"
  github = "https://github.com/yourname"
  featured_image = "images/background.jpg"
  page_header_image = "images/background.jpg"
  site_since = "2026-03-21"
```

可选的首页和交互功能：

```toml
[params]
  about_subtitle = "欢迎来到我的个人博客"
  random_button_text = "🎲 随机一篇"
  about_button_text = "👤 关于我"
  latest_posts_title = "📝 最新文章"
  enable_busuanzi = true
  enable_click_fireworks = true
  enable_image_lightbox = true
  enable_image_slider = true
```

模板会自动生成 description、canonical、RSS、Open Graph、Twitter Card，以及首页和文章页的 JSON-LD。单篇文章可以覆盖默认描述和分享图：

```yaml
description: "这篇文章的一句话简介"
cover: "images/post-cover.jpg"
images:
  - "images/post-share.jpg"
```

模板优先使用 `images` 的第一项，其次使用 `cover`，最后使用全局 `featured_image`。

## 数据文件

### 友链

编辑 `data/friends.yml`：

```yaml
- name: Example
  url: https://example.com/
  description: 示例站点
  avatar: https://example.com/avatar.png
```

### 碎碎念

编辑 `data/murmurs.yml`：

```yaml
- date: "2026-05-18"
  content: "今天写了一点博客。"
```

### 日程

编辑 `data/schedule.yml`：

```yaml
- date: "2026-05-23"
  start: "09:00"
  end: "10:30"
  title: "算法复习"
  category: "学习"
  summary: "刷题与整理笔记"
```

日期和时间格式分别为 `YYYY-MM-DD`、`HH:mm`。默认分类包括 `学习`、`比赛`、`博客`、`生活` 和 `休息`，其他分类会使用默认颜色。

日程显示范围在 `config.toml` 中配置：

```toml
[params.schedule]
  enable = true
  title = "日程"
  subtitle = "记录每个时间段在做什么"
  start_hour = 8
  end_hour = 24
```

## 评论区

项目使用 Waline，评论区可显示在关于页、文章详情页、碎碎念页和友链页。评论数据由 Waline 服务端和数据库保存，不在 GitHub Pages 构建产物中。

先按 [Waline 官方文档](https://waline.js.org/) 部署服务端，再修改 `config.toml`：

```toml
[params.comments]
  enable = true
  provider = "waline"
  server_url = "https://your-waline-server.vercel.app"
  placeholder = "欢迎留言，一起交流~"
  login = "enable"
```

Waline 管理后台通常位于服务地址的 `/ui` 路径。

## 部署

### GitHub Pages 自动部署

仓库中的 `.github/workflows/deploy.yml` 会在代码推送到 `master` 后：

1. 安装 Hugo Extended。
2. 构建静态站点。
3. 上传 `public/` 产物。
4. 发布到 GitHub Pages。

首次部署时，在 GitHub 仓库中打开 `Settings → Pages`，将 Source 设置为 `GitHub Actions`。

将仓库 fork 为自己的博客时，至少需要修改：

1. `config.toml` 中的 `baseURL`、站点名、作者、头像和社交链接。
2. `data/` 下的友链、碎碎念和日程等个人数据。
3. GitHub Pages 发布源，确保选择 `GitHub Actions`。

### 使用部署脚本

在 Git Bash、WSL 或其他 Bash 环境运行：

```bash
./deploy.sh
```

该脚本会暂存并提交当前改动、推送 `master`，然后执行本地 Hugo 构建。推送会触发 GitHub Actions 完成线上发布。运行前应先检查待提交内容，避免把无关文件一并提交。

## 常见问题

### 本地预览看不到文章

检查文章 front matter。草稿文章需要使用以下命令预览：

```powershell
hugo server -D
```

### 线上没有新文章或图片

依次检查：

1. GitHub Actions 是否构建成功。
2. `Settings → Pages` 是否选择了 `GitHub Actions`。
3. 文章是否仍为 `draft: true`。
4. 图片是否位于 `static/images/` 或文章 Page Bundle 中。
5. Markdown 是否包含旧仓库名、旧域名或大小写错误的路径。

也可以运行：

```powershell
.\scripts\check-blog.ps1
```

### 图片整理脚本提示 `Skipped missing local images`

这表示 Markdown 中的本地图片路径无法解析。确认文件真实存在，并从文章目录或其父目录能够找到该相对路径。可以先用 `-WhatIf` 查看处理结果：

```powershell
.\scripts\prepare-post-images.ps1 "content\posts\文章目录" -WhatIf
```

## 进一步框架化

当前仓库保留了真实博客内容。如果要发布为通用模板，建议：

1. 将个人文章和数据迁出，只保留示例内容。
2. 将 `layouts/` 中较大的内联 CSS、JavaScript 拆分到 `assets/`。
3. 将 `themes/theme2/` 与自定义模板整理成独立 Hugo Theme。
