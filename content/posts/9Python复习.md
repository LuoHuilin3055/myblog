---
title: Python复习
date: 2026-04-23
lastmod: 2026-04-23
draft: true
tags:
  - 计算机
  - 笔记
  - 大一下
  - Python
cover: images/9.jpg
---

---

# 📘 Python期中复习讲义（零基础版）

## 一、Python到底是什么（先建立概念）

Python就是一种“写给电脑看的语言”，用来做三件事：

- 计算（比如算土地面积）
    
- 判断（是否符合条件）
    
- 处理数据（比如一堆地块信息）
    

👉 你考试就是：**让电脑帮你处理数据**

---

# 二、最基础：输入 + 输出

## 1️⃣ 输出（print）

```python
print("你好")
```

👉 作用：把内容显示出来

---

## 2️⃣ 输入（input）

```python
name = input("请输入名字：")
```

👉 作用：让用户输入内容

---

## ⚠️ 注意（必考坑）

```python
age = int(input("请输入年龄："))
```

👉 input 默认是“字符串”，要用 `int()` 变成数字！

---

# 三、变量（就是“存东西的盒子”）

```python
area = 100
```

👉 意思：把 100 存进变量 area

---

可以随便改：

```python
area = 200
```

---

# 四、判断（if）

## 基本结构：

```python
if 条件:
    做事情
else:
    做另一件事
```

---

## 示例：

```python
area = 120

if area > 100:
    print("大地块")
else:
    print("小地块")
```

---

## 常用比较符号（必须记）

|符号|意义|
|---|---|
|>|大于|
|<|小于|
|>=|大于等于|
|==|等于|

---

# 五、循环（for）——让代码重复执行

## 1️⃣ 基本循环

```python
for i in range(5):
    print(i)
```

👉 输出：0 1 2 3 4

---

## 2️⃣ 遍历数据（考试重点）

```python
areas = [100, 200, 150]

for a in areas:
    print(a)
```

👉 一个一个取出来

---

# 六、列表（最重要！！）

👉 列表 = 一堆数据

```python
areas = [100, 200, 150]
```

---

## 常见操作

### 1️⃣ 求和

```python
sum(areas)
```

---

### 2️⃣ 最大值

```python
max(areas)
```

---

### 3️⃣ 个数

```python
len(areas)
```

---

## ⭐ 综合例子（很像考试题）

```python
areas = [100, 200, 150, 80]

total = sum(areas)
avg = total / len(areas)

print("平均值：", avg)
```

---

# 七、条件筛选（重点中的重点）

```python
areas = [100, 200, 150, 80]

for a in areas:
    if a > 120:
        print(a)
```

👉 输出：大于120的地块

---

# 八、字典（稍微进阶，但常考）

👉 用来存“名称 + 数据”

```python
land = {
    "A地块": 100,
    "B地块": 200
}
```

---

## 取值

```python
print(land["A地块"])
```

---

# 九、文件读取（很可能考）

```python
file = open("data.txt", "r")

for line in file:
    print(line)

file.close()
```

👉 一行一行读

---

# 十、考试最常见题型（直接练这个）

## ⭐题型1：求平均值

```python
areas = [100, 200, 150]

avg = sum(areas) / len(areas)

print(avg)
```

---

## ⭐题型2：找最大值

```python
areas = [100, 200, 150]

print(max(areas))
```

---

## ⭐题型3：筛选数据

```python
areas = [100, 200, 150, 80]

for a in areas:
    if a > 120:
        print(a)
```

---

## ⭐题型4：统计数量

```python
areas = [100, 200, 150, 80]

count = 0

for a in areas:
    if a > 120:
        count += 1

print(count)
```

---

# 十一、超级保命模板（考前背这个）

直接背👇

```python
data = [100, 200, 150, 80]

total = sum(data)
avg = total / len(data)

count = 0

for x in data:
    if x > avg:
        print(x)
        count += 1

print("平均值：", avg)
print("数量：", count)
```

👉 能覆盖：

- 循环
    
- 判断
    
- 平均值
    
- 统计
    

---
