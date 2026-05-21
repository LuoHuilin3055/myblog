---
title: Linux学习记录
date: 2026-04-08
draft:
tags:
  - 笔记
  - 计算机
cover: images/11.jpg
---
# 新建文件
```bash
# 创建空文件
touch my_script.py

# 然后用编辑器打开
nano my_script.py

# 完成后，Ctrl+O保存，Enter确认文件名，Ctrl+X退出
# python3 文件名  运行
```
---
# 修改文件名
```bash
mv admin.exe admin.png
```
---
# 拥有的工具
```bash
sudo apt update

sudo apt install \
binwalk \    
foremost \
steghide \
binutils \
file \
vim-common \
libimage-exiftool-perl -y
pngcheck \
```

---
# 判断文件类型
```bash
binwalk 文件
```

---
# 提取数据
```bash
binwalk -e 文件
```

---
# `GHEX`使用指南

### 一、启动 GHex 

```bash
# 命令行启动
ghex

# 直接打开文件
ghex 文件名

# 以只读模式打开（避免误修改）
ghex -r 文件名
```


### 打开/保存文件 

| 操作 | 快捷键 | 菜单路径 |
|------|--------|----------|
| 打开文件 | `Ctrl + O` | File → Open |
| 保存文件 | `Ctrl + S` | File → Save |
| 另存为 | `Ctrl + Shift + S` | File → Save As |
| 关闭文件 | `Ctrl + W` | File → Close |
| 退出程序 | `Ctrl + Q` | File → Quit |

### 2. 编辑操作

| 操作 | 快捷键 | 说明 |
|------|--------|------|
| 撤销 | `Ctrl + Z` | 撤销上一步修改 |
| 重做 | `Ctrl + Shift + Z` | 恢复撤销的操作 |
| 剪切 | `Ctrl + X` | 剪切选中内容 |
| 复制 | `Ctrl + C` | 复制选中内容 |
| 粘贴 | `Ctrl + V` | 粘贴十六进制数据 |

### 3. 查找功能

| 操作 | 快捷键 | 说明 |
|------|--------|------|
| 查找 | `Ctrl + F` | 查找十六进制值或文本 |
| 查找下一个 | `Ctrl + G` | 重复上次查找 |
| 跳转到地址 | `Ctrl + J` | 直接跳转到指定偏移位置 |

### 4. 视图调整

| 操作 | 说明 |
|------|------|
| View → 8/16/24 bytes per row | 调整每行显示的字节数 |
| View → Show ASCII view | 显示/隐藏 ASCII 区域 |
| View → Statusbar | 显示/隐藏状态栏 |

### 5. 插入与删除

| 模式 | 说明 | 激活方式 |
|------|------|----------|
| **覆盖模式**（默认） | 新数据覆盖原有数据，文件大小不变 | 按 `Insert` 键切换 |
| **插入模式** | 插入新数据，文件大小增加 | 按 `Insert` 键切换 |

状态栏会显示当前模式（OVR 或 INS）。

**注意**：在插入模式下删除会真正删除字节，改变文件大小。

### 6.选择与操作

### 选择字节范围
- **鼠标拖拽**：直接选择
- **Shift + 方向键**：扩展选择
- **Ctrl + A**：全选

### 复制选中的数据
```bash
# 选中一段数据后 Ctrl+C
# 可以粘贴到文本编辑器，格式如下：
00000000: 48 65 6c 6c 6f 20 57 6f 72 6c 64 0a  Hello World.
```

### 常见问题

| 问题 | 解决方法 |
|------|----------|
| 文件无法保存（权限不足） | `sudo ghex 文件名` 重新打开 |
| 修改后文件损坏 | 检查是否破坏了文件结构（如 ELF 头、校验和） |
| 找不到某个字节序列 | 确认搜索模式（十六进制还是文本），区分大小写 |
| 粘贴不进去 | 检查是否处于插入模式，或者先选中替换区域 |

### 快速参考卡片

```bash
# 常用快捷键
Ctrl+O     # 打开文件
Ctrl+S     # 保存
Ctrl+F     # 查找
Ctrl+G     # 查找下一个
Ctrl+J     # 跳转到地址
Ctrl+Z     # 撤销
Insert     # 切换覆盖/插入模式

# 常用命令行
ghex file.bin           # 打开文件
ghex -r file.bin        # 只读打开
ghex -n 1024 new.bin    # 创建新文件（1024字节）
```

# 