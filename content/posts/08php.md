---
title: php笔记
date: 2026-08-07
lastmod: 2026-08-07
tags:
  - 笔记
  - php
draft:
cover: images/8.jpg
---
# PHP基本格式
```php
<?php
echo "Hello";
?>
```
但在CTF中经常不写最后?>
**php每条语句用`;`结尾**

---
# 变量$
php变量前面必须有`$`
```php
$name = "Clairis";
$age = 18;
```

---
# 常见数据类型
## 字符串
```php
$a = "hello";
$b = "Clairis";
```

## 整数
```php
$a = 123;
```

## 浮点数
```php
$a = 12.03;
```

## 布尔值
```php
$a = true;
$b = false;
```

## 数组
```php
$a = array("Clairis","user");
$a = ["Clairis","users"];

# 访问
echo $a[0];
```

---
# 输出echo
```php
 $name = "Clairis";
 echo $name;
```

```php
echo "hello","Clairis";
```

---
# 字符串拼接`.`
php的字符串拼接不用+而是`.`
```php
$a = "hello";
$b = "Clairis";
echo $a . $b;

#输出“helloClairis"
```

---
# isset()：变量存在
```php
if(isset($_GET['name'])){
	echo $_GET['name'];
}
```

>如果GET参数name存在，就输出name的值

</br>

```php
if(!isset($_GET['user']){
	exit;
}
```
>如果没有传user参数，直接结束程序

---
# if/else
```php
#多个条件
if($a == 1 && $b == 2){
	echo "success";
}
```
> && 并且
>  || 或者

---
# \==和\===
```php
$a == $b
```
>弱比较

PHP可能自动转换数据类型
比如：
"1" ==  1
返回true；因为PHP会进行类型转换

</br>

```php
$a === $b
```
>强比较

**不仅值必须一样，类型也必须一样**

比如：
"1" === 1  
返回false

---
# strcmp()
用于比较字符串
```php
strcmp("abc","abc")
# 相等时返回0
```

---
# empty(
判断一个变量是不是“空”
```php
if(empty($_GET['name'])){
	echo "empty"
}
```
下面很多值都会被PHP认为是空
```txt
""
0 
"0" 
NULL 
false 
[]
```

---
# strlen()
计算字符串长度
strlen("admin");
返回5
```php
is(strlen($_GET['password'])>10){
	exit();
}
```
>password长度大于10就结束

---
# strpos()
查找字符串的位置
```php
strpos("hello world","world");
```
返回world出现的位置

</br>

```php
if(strops($file,"../")!=false){
	die("hacker");
}
```
>如果文件名里面出现../，就拦截