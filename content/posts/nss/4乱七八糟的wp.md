---
title: 乱七八糟的WP
date: 2026-05-15
draft:
lastmod: 2026-05-20
featured: true
tags:
  - CTF
  - WP
cover: images/4.jpg
---
# `Misc`
## [[SEETF 2023]1337 Word Search - NSSCTF](https://www.nssctf.cn/problem/4207)

### 思路
- 先看题目描述：**这是一个大型的字谜游戏。在网格中找到隐藏的`flag`，可以在八个方向中的任何一个方向（水平、垂直或对角线）找到。**——可以猜测是一道单词搜索题
- 再看附件：文件解压后看见一大堆乱字符，于是我们看：
	- 有没有图片？——没有，所以不是图片隐写
	- 有没有压缩包？——没有，所以不是压缩密码
	- 是不是编码？不像，因为没有规律且有`{}`与`_`，不像`base64`
	- 同时也结合题目强调的`grid`（网格），说明：这些字符不是一整串，而应该按照二维矩阵理解
- 而`flag`格式给了：
```text
SEE{}
```
- 所以核心思路就是：
	1. 把整个文本按照“矩阵”处理
	2. 从所有 `S` 开始搜索
	3. 朝 8 个方向尝试读取字符串
	4. 找到完整 `SEE{...}`

### `EXP`
```python
dirs = [
    (0,1),   # →
    (0,-1),  # ←
    (1,0),   # ↓
    (-1,0),  # ↑
    (1,1),   # ↘
    (-1,-1), # ↖
    (1,-1),  # ↙
    (-1,1)   # ↗
]

with open("wordsearch1.txt","r",encoding="utf-8") as f:
    grid = [line.strip() for line in f if line.strip()]

n = len(grid)
m = len(grid[0])

for i in range(n):
    for j in range(m):

        if grid[i][j] != 'S':
            continue

        for dx,dy in dirs:

            s = ""
            x,y = i,j

            for _ in range(100):

                if not (0 <= x < n and 0 <= y < m):
                    break

                s += grid[x][y]

                if s.startswith("SEE{") and s.endswith("}"):
                    print(s)

                x += dx
                y += dy
```
运行脚本后得到`flag`
```text
SEE{you_found_me_now_try_the_1337er_one}
```

---

# `Web`
## [[LitCTF 2023]我Flag呢？ - NSSCTF](https://www.nssctf.cn/problem/3861)

### 前置知识
- 为什么要做元素审查？
	- 因为网页显示出来的内容 不等于 网页的真实内容
- 元素审查看什么
	- | 内容         | 作用            |
| ---------- | ------------- |
| HTML       | 页面结构、隐藏内容     |
| CSS        | 隐藏元素、图片路径     |
| JavaScript | 密码、逻辑、接口      |
| Network 请求 | API、参数、Cookie |
| Storage    | Token、Session |
| Cookie     | 身份验证          |
| Source     | 前端源码          |
- [有关工具列表 - Microsoft Edge Developer documentation | Microsoft Learn](https://learn.microsoft.com/zh-cn/microsoft-edge/devtools/about-tools)

### 思路
- 打开网站发现没有可交互的点，于是`F12`控制台审查元素
- 打开控制台后看到： ![](../nssctf/1.png)
	> **控制台（Console）** 会输出页面资源报错信息/`js`的执行信息，同时也可以在这个交互式终端中执行`js`指令
- 彩蛋提示运行`giveMeEgg()`函数即可拿到彩蛋，所以：  ![](../nssctf/2.png)
- 但提交后发现不对😭,`CTRL+U`查看源码，`CTRL+F`进行搜索`flag`，在最下面的注释找到`flag`

---

## [[LitCTF 2023]导弹迷踪 - NSSCTF](https://www.nssctf.cn/problem/3863)
### 思路
- 这是一个小游戏，而针对这种逻辑是基于`js`的页面游戏，要么采用按照题目要求玩到第六关得到`flag`，要么就修改或者查看源码寻找`flag`
- `F12`查看源码，在搜索框搜索`"level"`，找到`flag`  ![](../nssctf/3.png)

---

## [[LitCTF 2023]就当无事发生 - NSSCTF](https://www.nssctf.cn/problem/3862)
### 思路
- 题目提示：“差点数据没脱敏就发出去了”，同时结合博客网址于是去`Github`上搜索`ProbiusOfficial`
- 出现两条结果，查看后博客的源码应该在第二个  ![](../nssctf/4.png)
- 进入仓库后找到`Commits`（提交记录），因为在题目的版本数据中找到题目的上传时间为`2023-05-02`，于是将仓库的查询时间改为`5`月`2`日之前。  ![](../nssctf/5.png)![](../nssctf/6.png)
- 从查询结果我们发现，`4`月`29`日有两个提交记录，点进后一个提交记录可以看见修改  ![](../nssctf/7.png)

---

## [[LitCTF 2023]Follow me and hack me - NSSCTF](https://www.nssctf.cn/problem/3864)
### 思路
- 使用`HackBar`插件来在浏览器里面进行发送/接收`http`报文  ![](../nssctf/8.png)