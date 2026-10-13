# Clairis's Blog

Clairis 的个人博客，使用 **Astro + TypeScript + Svelte** 构建，界面基于 Fuwari 风格进行定制。文章以 Markdown 编写，网站由 GitHub Actions 自动构建并发布到 GitHub Pages。

线上地址：[https://clairis.cn](https://clairis.cn)

## 功能

- 文章归档、分类、标签、站内搜索和 RSS
- 深色模式、响应式布局、目录和回到顶部按钮
- Markdown 代码高亮、数学公式、提示块和 GitHub 卡片
- 首页侧栏组件、精选文章、友情链接，以及“空间”中的友链和碎碎念
- Waline 评论、文章阅读量和站点访问统计
- GitHub Actions 自动部署到 GitHub Pages

## 本地运行

环境要求：Node.js 22、pnpm 9.14.4。

在仓库根目录执行：

```bash
pnpm install --frozen-lockfile
pnpm dev
```

开发服务器默认地址为 `http://localhost:4321/`。常用命令：

| 命令 | 作用 |
| --- | --- |
| `pnpm dev` | 启动本地开发服务器 |
| `pnpm check` | 检查 Astro 页面与内容 |
| `pnpm type-check` | 运行 TypeScript 类型检查 |
| `pnpm build` | 构建网站并生成 Pagefind 搜索索引 |
| `pnpm preview` | 本地预览构建结果 |

## 写文章

在 `src/content/posts/` 下新建 Markdown 文件即可。需要附带图片时，可以新建文章文件夹，将 `index.md` 和文章专属图片放在一起。

文章使用 YAML Frontmatter。`title` 和 `published` 必填，其他字段按需设置：

```yaml
---
title: "文章标题"
published: 2026-10-12
updated: 2026-10-12
draft: true
featured: false
description: "文章简介"
image: "/images/post-banner.jpg"
category: "网络安全"
tags:
  - CTF
  - WP
lang: zh_CN
---

从这里开始写正文。
```

- 草稿文章设置 `draft: true`：本地开发时仍可预览，正式构建时不会发布。
- 将 `draft` 改为 `false` 后，文章会进入正式网站。
- 设置 `featured: true` 可把文章加入首页精选；首页最多展示两篇符合条件的文章，按发布时间排序。默认值为 `false`。
- `category` 是单个分类名称，`tags` 是标签列表。
- `image` 可指定文章横幅图。网站公共图片放在 `public/` 下，引用时使用以 `/` 开头的路径，例如 `/images/avatar.jpg`；文章专属图片可放在文章文件旁，并使用相对路径引用。

## 项目结构

```text
.
├── .github/workflows/       # GitHub Pages 自动部署
├── public/                  # favicon、站点图片等静态资源
├── src/
│   ├── components/          # 页面组件与侧栏组件
│   ├── content/
│   │   ├── posts/           # Markdown 文章及文章图片
│   │   └── spec/            # 站点内容
│   ├── data/space.ts        # 友情链接、碎碎念和随机语录
│   ├── layouts/             # 页面布局
│   ├── pages/               # 首页路由、归档、文章、关于和空间页面
│   ├── styles/              # 全局样式
│   └── config.ts            # 站点、导航、个人资料和功能配置
├── astro.config.mjs
└── package.json
```

## 网站配置

常用设置集中在 `src/config.ts`：

- `siteConfig`：站点标题、语言、主题色、横幅和目录
- `navBarConfig`：顶部导航
- `profileConfig`：头像、昵称、简介和个人链接
- `licenseConfig`：文章许可信息
- `siteFeatureConfig`：建站时间及 Waline 服务地址

友情链接、碎碎念和随机语录在 `src/data/space.ts` 中维护。新增友链时按现有对象格式添加名称、网址、简介和头像地址。

## 图片

- 全站复用的图片放在 `public/images/`，文章专用图片建议和文章 Markdown 放在同一文件夹。
- 公共图片在文章或配置中使用以 `/` 开头的路径，例如 `/images/avatar.jpg`；文章文件夹内的图片使用相对路径引用。

## 部署

推送到 `master` 分支会触发 `.github/workflows/deploy.yml`：安装依赖、运行 `pnpm build`，再将 `dist/` 发布到 GitHub Pages。也可以在 GitHub Actions 页面手动运行 `Deploy Astro site` 工作流。

首次配置仓库时，在 GitHub 仓库的 **Settings → Pages** 中将发布来源设置为 **GitHub Actions**。部署成功后，网站使用 `astro.config.mjs` 中配置的站点地址。
