---
title: CTF学习记录
date: 2026-04-02
tags:
  - CTF
  - 笔记
  - 大一下
lastmod: 2026-04-02
draft: true
cover: images/8.jpg
featured: false
---
# 2018 DEFCON Quals ghettohackers: Throwback
## 题目描述
```
Anyo!e!howouldsacrificepo!icyforexecu!!onspeedthink!securityisacomm!ditytop!urintoasy!tem!
```
## 思路
- 一种方法是补全叹号内容得到flag
	- `flag{Anyone who would sacrifice policy for execution speed thinks security is a commodity to pour into a system}`
	- 或者`flag{nwltisoos}`
	- 但都是错的
- 另一种则是以`!`为分割点将字符分开，字符串长度对应字母表中字母的顺序，同时假设0个字符为空格
## EXP
```python
ori = 'Anyo!e!howouldsacrificepo!icyforexecu!!onspeedthink!securityisacomm!ditytop!urintoasy!tem!'
sp = ori.split('!')
result = ''.join(chr(97 + len(s) - 1) for s in sp)
print(result)
```
`flag{dark logic}`

---

# 判断图片类型
- 给出了一个`admin.exe`文件，我们需要先判断其文件类型
	- 先用`binwalk`判断`binwalk admin.exe`得出为`png`文件
	- 再使用`GHEX`来进行十六进制验证`ghex admin.exe`,得到`89 50 4E 47 0D 0A 1A 0A`的`PNG`文件头
- 于是我们将后缀改为`PNG`，得到一张二维码，用`QRCode`扫描即可得到flag
	- `mv admin.exe admin.png`
---
# 倒转文件byte
- 用`binwalk`判断文件类型为`jpg`，于是用`GHEX`打开
- 打开后并没有在开头看见`PNG`文件头，翻到最下面看见有倒转过来的`PNG`与`IHDR`，于是使用脚本将其翻转，得到flag
### EXP
```python
  a = open('flag.jpg','rb')  #读取flag.jpg图片的byte数据
  b = open('png.png','wb')  #新建一个名为png.png的图片，写入byte数据
  b = b.write(a.read()[::-1])  #将flag.jpg图片的byte数据，倒着写入png.png图片里
```
---

# 添加文件头
- 先用`binwalk`判断文件类型为`PNG`，用`GHEX`打开
```bash
binwalk no_hex
ghex no_hex
```
- 打开后发现文件头缺失，`INS` -> 添加`89 50 4E 47`
- 另存为`CTRL + SHIFT + S`
---

# 修改宽高
```python
python Deformed-Image-Restorer.py -i demo.png
```

# `LSB`图片隐写
## 前言：
作为一个不是十分勤奋的仍在入门苦苦挣扎的`CTFer`，之前做了几道`Misc`的图片题（因为简单），我的操作仅限于“打开随波逐流 --> 图片及文件隐写 --> `binwalk`文件提取”，最多延伸到用`010`打开修改文件头，这学期决定真的真的真的要入门`CTF`了，现在准备学一下之前看见就跑的`LSB`隐写题  
另外，本来是想下载`Stegsolve`的，但我的能力有限，下载的全是精简版，`ChatGPT`教我的很多功能都找不到，放弃后又去询问`ChatGPT`，决定试试`zsteg → StegoVeritas → StegOnline（最后确认）`这样的流程  
~~我总觉得我记性不是很好，所以我总是写的比较哆嗦~~
## 