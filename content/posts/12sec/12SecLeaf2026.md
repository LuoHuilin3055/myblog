---
title: SecLeaf2026的WP
tags:
  - WP
  - CTF
date: 2026-05-23
draft:
cover: images/12.jpg
featured: true
lastmod: 2026-05-23
---
# Misc
## 1.`SanityCheck`（合理性检查）
### 题目描述
`Find the flag on our YT Channel` [https://www.youtube.com/@SecLeaf](https://www.youtube.com/@SecLeaf)

### 解题思路
打开链接发现是赛事通知，展开文章即可看到`flag`  ![](12sec/1.png)

---

## 2.`vaultcore`
### 题目描述
```text
We recovered a protected vault executable from an abandoned workstation.

Initial analysis suggests:

anti-debugging routines
payload decryption
integrity verification
Can you recover the secure access token?

Flag format: SecLeaf{}

我们从一台废弃的工作站中恢复了一个受保护的保险库可执行文件。

初步分析表明：

反调试例程  
载荷解密  
完整性校验  

你能恢复安全访问令牌吗？
```

## 解题思路
附件下载后发现无法直接看出文件类型，于是用`010Editor`打开，在开头也没看出文件类型，拉到最后发现了`flag`~~瞎猫碰上死耗子~~  ![](12sec/2.png)

也可以用
```bash
strings -a vaultcore | grep -i "SecLeaf"
```
输出得到`flag` 
![](12sec/3.png)

---

# `Cryptography`
## 1.`military_grade_encryption`
### 题目描述
附件下载后为`txt`文本，内容：
```txt
U2VjTGVhZntiNDUzNjRfMXNfbjB0XzNuY3J5cHQxMG59
```

### 解题思路
看起来比较像`Base64`编码，解码后得到`flag`
```bash
cat encrypted.txt | base64 -d
```
![](12sec/4.png)

---

# `OSINT`
## `Can_you_Find_Cafe`
### 题目描述
![](12sec/whereami.jpeg)
```txt
A single image holds all the clues you need. Study the surroundings carefully and identify the exact location where it was taken. Accuracy matters.

Use "_" instead of spaces.

Flag Format: SecLeaf{Name_of_the_place+Location_name}
```

### 解题思路
用谷歌识图，选择 **“外观匹配”** 
![](12sec/5.png)
第一篇文章打开后得到这间咖啡店的简介
![](12sec/6.png)
根据内容即可得到`flag`
```txt
SecLeaf{Cafe_Goodluck+Deccan_Gymkhana}
```