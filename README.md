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
│   ├── schedule.md          # 日程页
│   └── murmur/              # 碎碎念栏目
├── data/                    # YAML 数据
│   ├── friends.yml          # 友链数据
│   ├── murmurs.yml          # 碎碎念数据
│   └── schedule.yml         # 日程数据
├── layouts/                 # 自定义 Hugo 模板
├── assets/css/              # 可由 Hugo 管线处理的站点样式
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
  featured_image = "images/background.jpg"
  page_header_image = "images/background.jpg"
  site_since = "2026-03-21"
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

评论区使用 Waline，可在 `params.comments` 中配置。默认关闭；需要评论区时，把 `enable` 改为 `true`，再填写 `server_url`：

```toml
[params.comments]
  enable = false
  provider = "waline"
  server_url = ""
  placeholder = "欢迎留言，一起交流~"
  login = "enable"
```

日程板块使用静态数据文件渲染，可在 `params.schedule` 中调整标题和显示时间范围：

```toml
[params.schedule]
  enable = true
  title = "日程"
  subtitle = "记录每个时间段在做什么"
  start_hour = 8
  end_hour = 24
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

推荐使用脚本创建 Page Bundle，新文章会默认是草稿：

```powershell
.\scripts\new-post.ps1 "我的新文章"
```

生成结构如下：

```text
content/posts/我的新文章/
└── index.md
```

生成的 `index.md` 会包含明确的 `draft: true`。写完并确认要发布时，再手动改成：

```yaml
draft: false
```

文章内容属于个人数据。如果要把本仓库改造成通用模板，建议把真实文章替换为示例文章，或者将主题部分抽成独立仓库。

### 推荐写作流程

1. 新建文章：

```powershell
.\scripts\new-post.ps1 "文章标题"
```

2. 写正文，并临时插入本地图片路径。
3. 整理文章图片：

```powershell
.\scripts\prepare-post-images.ps1 content\posts\文章标题
```

也可以直接传入 Markdown 文件：

```powershell
.\scripts\prepare-post-images.ps1 content\posts\文章标题\index.md
```

4. 发布前检查：

```powershell
.\scripts\check-blog.ps1
```

5. 确认要发布时，把文章 front matter 中的 `draft: true` 改为 `draft: false`，再提交推送。

## 图片路径

为了避免 GitHub Pages 子路径部署时图片 404，建议统一使用下面两种方式：

```text
static/images/avatar.jpg          -> Markdown 或配置中写 images/avatar.jpg
content/posts/my-post/image.png   -> 同目录文章中写 ![](image.png)
```

不建议在文章里写死 `/myblog/...` 或 `https://xxx.github.io/...`。仓库名变更、fork 到别人账号、或本地预览时，这类绝对路径最容易失效。

### 图片写作简化

推荐新文章使用 Page Bundle，也就是“一篇文章一个文件夹”：

```text
content/posts/my-post/
├── index.md
├── img-001.png
└── img-002.jpg
```

写文章时可以先直接插入本地图片路径，例如：

```markdown
![](D:\Pictures\截图 2026-05-28.png)
![](..\临时图片\demo.jpg)
```

写完后在仓库根目录运行：

```powershell
.\scripts\prepare-post-images.ps1 content\posts\my-post\index.md
```

如果传入的是文章文件夹，脚本会优先处理文件夹里的 `index.md`：

```powershell
.\scripts\prepare-post-images.ps1 content\posts\my-post
```

脚本会把本地图片复制到文章所在文件夹，并把 Markdown 自动改成稳定的同目录相对路径：

```markdown
![](img-001.png)
![](img-002.jpg)
```

脚本默认只复制不移动原图；会跳过 `http/https` 网络图片、`images/...` 公共资源，以及已经整理好的 `img-001.png` 这类图片。`static/images/` 仍然适合放头像、背景图、封面图和多篇文章共用的素材。

## 列表页横幅图片

文章列表、标签页、归档页、碎碎念、日程等页面顶部的横向大背景横幅由 `config.toml` 中的 `page_header_image` 控制：

```toml
[params]
  page_header_image = "images/background.jpg"
```

图片建议放在 `static/images/` 目录下。例如放入 `static/images/page-banner.jpg` 后，配置写成：

```toml
[params]
  page_header_image = "images/page-banner.jpg"
```

如果只想给某一个列表页单独换图，可以在对应页面的 front matter 中使用 `header_image` 覆盖全局配置：

```toml
+++
title = "文章"
header_image = "images/posts-banner.jpg"
+++
```

优先级是：页面 `header_image` > 全局 `params.page_header_image` > 默认 `images/background.jpg`。

日程页入口是 `content/schedule.md`。如果这个文件里写了 `header_image`，日程页会优先使用它；如果希望日程页跟随全局 `page_header_image`，不要在 `content/schedule.md` 中单独设置 `header_image`。

注意：`featured_image` 主要用于站点原有背景/展示图，`page_header_image` 专门用于列表页顶部横幅；两者可以使用不同图片。

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

日程维护在 `data/schedule.yml`，用于 `/schedule/` 周视图页面。每条记录需要写日期、开始时间、结束时间、公开标题和分类，`summary` 可选：

```yaml
- date: "2026-05-23"
  start: "09:00"
  end: "10:30"
  title: "算法复习"
  category: "学习"
  summary: "刷题与整理笔记"
```

默认分类为 `学习`、`比赛`、`博客`、`生活`、`休息`；写其它分类也能显示，只是会使用默认颜色。时间格式统一使用 `YYYY-MM-DD` 和 `HH:mm`，页面会按周自动分组，并根据 `start_hour` / `end_hour` 控制每天展示的时间范围。

## 评论区部署

当前模板已经把评论区插入到关于页、文章详情页、碎碎念页和友链页。评论系统使用 Waline，博客仓库只负责前端展示；评论数据不会保存在 GitHub Pages 生成产物里，而是由你部署的 Waline 服务端和数据库保存。

推荐按 Waline 官方文档使用 Vercel 部署服务端。流程大致是：

1. 在 Waline 文档中点击 Vercel 部署按钮，用 GitHub 登录 Vercel。
2. 创建 Waline 服务端项目，并按文档创建或绑定数据库。
3. 部署完成后打开 Vercel 项目的访问地址，这个地址就是 Waline 的 `serverURL`。
4. 回到博客仓库，把地址填入 `config.toml`：

```toml
[params.comments]
  enable = true
  provider = "waline"
  server_url = "https://your-waline-server.vercel.app"
  placeholder = "欢迎留言，一起交流~"
  login = "enable"
```

Waline 默认支持昵称、邮箱、网址等访客信息；如果后续需要评论审核、通知、头像、社交登录或管理后台，请在 Waline 服务端侧继续配置。管理后台通常位于你的 Waline 服务地址后加 `/ui`。

## 部署

仓库已配置 GitHub Actions：推送到 `master` 后会自动构建 Hugo，并通过 GitHub Pages 发布 `public/` 产物。

首次使用时，请在 GitHub 仓库设置中进入 `Settings -> Pages`，将 Source 设置为 `GitHub Actions`。

如果 fork 成自己的博客，至少需要改三处：

1. `config.toml` 中的 `baseURL`、站点名、作者和头像。
2. `data/friends.yml`、`data/murmurs.yml` 中的个人数据。
3. GitHub Pages 的发布源必须选择 `GitHub Actions`，不要选择 `Deploy from a branch`。

也可以手动运行：

```bash
./deploy.sh
```

脚本会先本地构建检查，再把源码推送到 `master`，由 GitHub Actions 负责发布，避免用生成产物覆盖源码分支。

如果线上看不到新文章或图片，优先检查：

1. Actions 是否构建成功。
2. `Settings -> Pages` 是否选择了 `GitHub Actions`。
3. 图片是否位于 `static/images/` 或文章同目录资源中。
4. Markdown 里是否写死了旧仓库名、旧域名或大小写不一致的路径。

提交前也可以先运行：

```powershell
.\scripts\check-blog.ps1
```

它会检查 Hugo 构建、空 `draft:`、失效图片路径、超过 2MB 的图片，以及文章里硬编码的 `/myblog/` 或 `github.io` 链接。这个脚本只报告问题，不会修改文章内容。

## 框架化建议

当前版本保持你的显示效果和文章内容不变。若后续要发布成别人可直接套用的框架，建议继续做三步：

1. 将真实文章迁出，仅保留示例内容。
2. 把 `layouts` 中的大段内联 CSS/JS 拆到 `assets/css` 和 `assets/js`。
3. 将 `themes/theme2` 与当前自定义模板整理成独立 Hugo theme。
