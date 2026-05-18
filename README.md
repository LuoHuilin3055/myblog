# NGC 2237's Blog

这是一个基于 Hugo 的个人博客源码仓库。当前仓库保留了完整博客内容，同时已经按“可复用框架”的方向整理了配置、模板入口和部署方式。

## 快速开始

安装 Hugo Extended 后，在仓库根目录运行：

```powershell
hugo server -D
```

生成静态站点：

```powershell
hugo -t theme2 --cleanDestinationDir
```

构建结果会输出到 `public/`，不建议把生成后的 HTML 当作源码维护。

## 目录结构

```text
.
├── config.toml              # 站点配置和主题参数
├── content/                 # Markdown 内容源文件
│   ├── posts/               # 文章
│   ├── logs/                # 日志
│   ├── about.md             # 关于页
│   ├── friends.md           # 友链页
│   └── murmur/              # 碎碎念栏目
├── data/                    # YAML 数据
│   ├── friends.yml          # 友链数据
│   └── murmurs.yml          # 碎碎念数据
├── layouts/                 # 自定义 Hugo 模板
├── static/                  # 静态资源源文件
├── themes/theme2/           # 主题依赖
├── archetypes/              # 新文章模板
└── .github/workflows/       # GitHub Pages 自动部署
```

## 常用配置

主要配置集中在 `config.toml`：

```toml
baseURL = "https://yourname.github.io/your-repo/"
title = "Your Blog"

[params]
  site_title = "Your Name"
  description = "站点描述"
  author = "Your Name"
  avatar = "images/avatar.jpg"
  bio = "Hi, there ~"
  github = "https://github.com/yourname"
  featured_image = "/images/background.jpg"
```

首页按钮、关于页副标题、统计和交互功能也可以在 `params` 中配置：

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

关于页社交链接使用数组配置：

```toml
[[params.social_links]]
  name = "GitHub"
  url = "https://github.com/yourname"
```

## 写文章

文章放在 `content/posts/` 下，普通 Markdown 文件和带图片资源的 Page Bundle 都可以使用：

```powershell
hugo new posts/my-new-post.md
```

文章内容属于个人数据。如果要把本仓库改造成通用模板，建议把真实文章替换为示例文章，或者将主题部分抽成独立仓库。

## 数据文件

友链维护在 `data/friends.yml`：

```yaml
- name: Example
  url: https://example.com/
  description: 示例站点
  avatar: https://example.com/avatar.png
```

碎碎念维护在 `data/murmurs.yml`：

```yaml
- date: "2026-05-18"
  content: "今天写了一点博客。"
```

## 部署

仓库已配置 GitHub Actions：推送到 `master` 后会自动构建 Hugo，并通过 GitHub Pages 发布 `public/` 产物。

首次使用时，请在 GitHub 仓库设置中进入 `Settings -> Pages`，将 Source 设置为 `GitHub Actions`。

也可以手动运行：

```bash
./deploy.sh
```

脚本会先本地构建检查，再把源码推送到 `master`，由 GitHub Actions 负责发布，避免用生成产物覆盖源码分支。

## 框架化建议

当前版本保持你的显示效果和文章内容不变。若后续要发布成别人可直接套用的框架，建议继续做三步：

1. 将真实文章迁出，仅保留示例内容。
2. 把 `layouts` 中的大段内联 CSS/JS 拆到 `assets/css` 和 `assets/js`。
3. 将 `themes/theme2` 与当前自定义模板整理成独立 Hugo theme。
