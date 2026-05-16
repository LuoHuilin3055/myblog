---
draft: true
---


好 👍 既然你已经装好了 Kali Linux，我带你用**最实用、CTF够用的方式**学基础操作（不讲废话，直接能上手）👇

---

# 🧠 一、最核心：终端（必须会）

打开终端：

```text
Ctrl + Alt + T
```

你会看到：

```bash
kali@kali:~$
```

👉 以后大部分操作都在这里做

---

# 📁 二、文件操作（必会）

## 1️⃣ 查看当前目录

```bash
ls
```

👉 列出文件

---

## 2️⃣ 进入目录

```bash
cd 文件夹名
```

例如：

```bash
cd Downloads
```

---

## 3️⃣ 返回上一级

```bash
cd ..
```

---

## 4️⃣ 查看当前路径

```bash
pwd
```

---

## 5️⃣ 查看文件内容

```bash
cat 文件名
```

---

## 6️⃣ 复制 / 移动 / 删除

```bash
cp a.txt b.txt     # 复制
mv a.txt b.txt     # 重命名/移动
rm a.txt           # 删除
```

---

# 🔍 三、CTF常用命令（重点）

## 1️⃣ 判断文件类型

```bash
file 文件名
```

---

## 2️⃣ 提取字符串（神器）

```bash
strings 文件名
```

👉 常用于找 flag

---

## 3️⃣ 搜索关键字

```bash
grep flag 文件名
```

---

## 4️⃣ 查看文件结构（隐写常用）

```bash
binwalk 文件名
```

---

## 5️⃣ 解压文件

```bash
unzip xxx.zip
```

---

# 🌐 四、安装工具（很重要）

Kali用的是 `apt`：

```bash
sudo apt update
sudo apt install 工具名
```

例如：

```bash
sudo apt install binwalk
```

---

# 🔐 五、权限（你会经常用）

## 使用管理员权限：

```bash
sudo 命令
```

👉 比如：

```bash
sudo apt update
```

---

# 🖱 六、界面基本操作

## 打开文件管理器

👉 左侧文件夹图标

---

## 右键操作

👉 和 Windows 类似

---

## 复制粘贴

👉 如果你装了增强功能：

- Ctrl + C / Ctrl + V
    
- Windows ↔ Kali 可以互通
    

---

# ⚡ 七、非常重要的几个习惯

## 1️⃣ 多用终端

👉 CTF 基本都靠命令行

---

## 2️⃣ 不要乱删系统文件

👉 `rm -rf` 很危险

---

## 3️⃣ 文件分析第一步

拿到文件就做：

```bash
file xxx
strings xxx
binwalk xxx
```

---

# 🎯 八、一个简单实战例子

假设你拿到一个文件 `flag.bin`：

```bash
file flag.bin
strings flag.bin
binwalk flag.bin
```

👉 很多 Misc 题就这样起手

---

# 🧠 总结

你现在只要先掌握这 5 个就够了：

```bash
ls
cd
file
strings
binwalk
```

👉 已经能做 60% 的 Misc 题

---

# 🚀 下一步（我建议）

如果你想进步更快，我可以：

👉 带你做一道真实 Misc 题（一步一步带）  
👉 或教你“看到文件如何分析”的完整套路

直接说：**来一道题练练** 😎