---
title: BYU CTF的WriteUp
draft: false
tags:
  - WP
  - CTF
  - BYUCTF
lastmod: 2026-06-03
date: 2026-06-01
cover: images/14.jpg
featured:
---
# `Misc`
## `1.Inception`
### 题目描述
```txt
I found this weird file on my computer. I tried opening it, but there were some problems.
```

### 解题思路
1‍⃣首先对附件进行检查
附件为`png`图片，所以复制附件并添上后缀，得到第一部分的`flag`
```txt
byuctf{wh4t_
```
2‍⃣同时用`binwalk`检查并提取隐藏内容
提取出来的有：
```txt
4F3 4F3.zlib
29 29.zlib
337.zip data.bin
```
分别读取各附件得到`flag`
```txt
从data.bin得到flag的第二部分
	th3
从4F3中得到第三部分
	_fr3ak}
```
最终`flag`为
```txt
byuctf{wh4t_th3_fr3ak}
```

---
## `2.Easy`
### 题目描述
```txt
Okay, easy mode is turned on. You know how to use bash, right?

chals.cyberjousting.com:1370
```

### 解题思路
1‍⃣首先使用`nc`连接题目服务
输入`pwd`测试当前目录
![](14byuctf/img-001.png)
根据返回结果得知当前工作目录在`/app`
2‍⃣发现过滤规则
尝试查看当前目录文件，但根据返回的报错可以看出：题目服务会删除命令中的空格
![](14byuctf/img-002.png)
3‍⃣绕过空格过滤
用`${IFS}`代替空格使用
![](14byuctf/img-003.png)
但还是会报错：说明不能直接使用普通外部命令
4‍⃣使用 `bash` 内置功能列目录
![](14byuctf/img-004.png)
![](14byuctf/img-005.png)

---
## `3.Chromatic`
### 题目描述
```txt
（一份mp4文件）
```

### 解题思路
先检查`mp4`文件
![](14byuctf/img-006.png)
根据
```txt
30 fps
54 秒
```
可以看出是一秒一张图片，同时看视频内容可以猜测：每一秒的红色数值，正好能转成一个字符。
#### `EXP`
```python
import subprocess
import collections

video = "chromatic.mp4"

# 取视频左上角 1x1 像素，每帧输出 RGB
cmd = [
    "ffmpeg",
    "-v", "error",
    "-i", video,
    "-vf", "crop=1:1:0:0,format=rgb24",
    "-f", "rawvideo",
    "-"
]

data = subprocess.check_output(cmd)

# 每帧 3 个字节：R G B
r_values = [data[i] for i in range(0, len(data), 3)]

fps = 30
flag = ""

# 每 30 帧，也就是每 1 秒取一次
for i in range(0, len(r_values), fps):
    block = r_values[i:i+fps]

    # 取这一秒出现最多的红色值
    r = collections.Counter(block).most_common(1)[0][0]

    # 红色值转 ASCII 字符
    flag += chr(r)

print(flag)
```

---