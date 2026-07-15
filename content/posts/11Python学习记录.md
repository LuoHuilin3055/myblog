---
title: Python学习记录
date: 2026-07-14
draft: true
tags:
  - 笔记
  - Python
cover: images/11.jpg
---

```txt
常用运算符：+ - * / // % **
/ 总是得到浮点数
//  向下取整除法
```

# 数据类型基础
## 数字、布尔值与空值
```python
age = 20      # int
temperature = 36.5    # float
enabled = True    # bool
result = None    # 尚无结果
```
`None`表示“没有值”，比较时使用`is None`
```python
value = None
if value is None:
	print("暂时没有结果")
```

## 字符串
字符串不可变，支持索引、切片和常用方法
```python
text = "   Python Wiki    "
cleaned = text.strip().lower()
print(cleaned)   # python wiki
print(cleaned[0])  # p
print(cleaned[:6])  # python
python(cleaned.replace("wiki","教程"))
# 将“wiki”替换为“教程”

```
`text.strip()`——去除首尾空格
```python
print(cleaned[:6])  # 从字符串开头开始，取到下标6之前，不包括下标6
# 字符串[开始位置:结束位置]
# :6表示从头开始
```

## 类型转换
`input()`的结果始终是字符串，计算前通常需要转换
```python
raw = input("Enter a number: ")
number = int(raw)
ratio = float("3.14")
display = str(number)
```

## 真值规则与比较
空字符串、数字 0、`None` 和空容器在条件中为假。比较运算符包括 `== != < <= > >=`，逻辑运算符是 `and or not`。
```python
username = "alice"
password_length = 12
valid = bool(username) and password_length >= 8
print(valid)
```
`==`比较值是否相等，`is`比较是否为同一个对象；除`None`外，通常不要用`is`比较值

```txt
输入摄氏温度，转换为华氏温度 F = C × 9 / 5 + 32 并格式化为一位小数。
```
```python
tem = input("请输入摄氏温度:")
output = float(tem)*9/5+32
print(f"转换后的华氏温度为：{output:.1f}")
```

---

# 程序结构
## 顺序、分支、循环
```python
score = float(input("Enter your score:"))
if score>=90:
    level = "A"
elif score>=80:
    level = "B"
elif score>=70:
    level = "C"
elif score>=60:
    level = "D"
else:
    level = "F"
print(level)
```

## for循环
```python
total = 0;
for number in range(1,101):
    if number %2 ==0:
        total += number
print(total)
```

```python
names = ["Ada", "Guido", "Grace"]
for index, name in enumerate(names, start=1):
    print(index, name)
```