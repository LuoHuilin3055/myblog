---
title: BYU CTF的WriteUp
draft: true
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
## 