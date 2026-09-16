---
title: ClubShare靶机
draft: true
date: 2026-09-10
lastmod: 2026-09-10
cover: images/9.jpg
tags:
  - WP
  - 靶机
---
# 前言
一个很简单的靶机。  
之前试过好多但是都没 用agent梭出来，这个是同学做来给小白演示的（所以很简单）。第一次做到直接用agent梭成功的靶机，深受鼓舞，于是写一篇笔记记录一下

# AI Agent System Prompt处的flag
```txt
flag4{Pr0mpt_1nj3ct10n_m3m0}
```

## 原理分析
AI Agent后端会读取内部system prompt，然后拼接用户消息
```JSON
{
  "messages": [
    {
      "role": "system",
      "content": "内部 system prompt"
    },
    {
      "role": "user",
      "content": "用户问题"
    }
  ]
}
```
