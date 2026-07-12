---
title: Java字符串操作
date: 2026-07-12
draft:
lastmod: 2026-07-12
featured:
tags:
  - Java
  - 笔记
---
Java考试前的补天

# String
## 判断字符串相等
```Java
//判断字符串相等
String s = "abc";
if(s.equals("abc")){
	System.out.println("字符串相等");
}
```

## 取某个位置的字符
**常用于遍历字符串**
```Java
String str = "hello";
char ch = str.charAt(0);  //'h'
```

## 长度
```Java
str.length()  //字符串长度
arr.length  //数组长度
list.size()  //集合长度
```

## 判断是否包含
```Java
String str = "hello world";
if(str.contains("world")){
	System.out.println("包含world");
}
```

## 判断开头结尾
```Java
String str = "Hello world";

str.startWith("Hello");  //是否以Hello开头
str.endWith("world");  //是否以world结尾
```

## 截取字符串
```Java
String str = "abcdef";
String s1 = str.substring(2);  //cdef
String s2 = str.substring(1,4);  //bcd
```

## 查找位置——indexOf
```Java
String str = "hello";

int index = str.indexOf("e");
//返回下标1；找不到返回-1
```

## 替换字符串——replace()
```Java
String str = "hello";
String newstr = str.replace("l","x"); 
System.out.println(newstr);  //hexxo
```

## 去掉首尾空格——trim()
```Java
String str = " hello";
str = str.trim();  //"hello"
```

## 大小写转换
```Java
String str = "Hello";
System.out.println(str.toUpperCase());  //HELLO
System.out.println(str.toLowerCase());  //hello
```

# char
## 判断是否是数字
```Java
char ch = '5';
if(Character.isDigit(ch)){
	System.out.println("是数字");
}
```

## 判断是否是字母
```Java
char ch = 'A';
if(Character.isLetter(ch)){
	System.out.println("是字母");
}
```

## 判断大小写字母
```Java
Character.isUpperCade(ch);  //是否大写
Character.isLowerCase(ch);  //是否小写
```

## 大小写转换
```Java
char ch = 'a';
char upper = Character.toUpperCase(ch);
```

## 字符转整数
```Java
char ch = 'a';
int num = ch - '0';
```

# StringBuilder
## 创建StringBuilder
```Java
StringBuilder sb = new StringBuilder()'
```

## 追加内容
```Java
result.append("hello");
System.out.println(result.toString());
```

## 反转字符串——判断回文
```Java
StringBuilder sb = new StringBuilder("abc");
sb.reverse();
System.out.println(sb);  //cba
```

```Java
//判断回文
String str = "aba";

String str2 = new StringBuilder(str).reverse().toString();

if(str.equals(str2)){
	System.out.println("是回文");
}
```

## 删除——deleteCharAt()
```Java
StringBuilder sb = new StringBuilder("abc");
sb.deleteCharAt(1);  //ac
```

## 插入——insert()
```Java
StringBuilder sb = new StringBuilder("hllo");
sb.insert(1,"e");//hello
```

## 修改——secCharAt()
```Java
StringBuilder sb = new StringBuilder("abc");
sb.setCharAt(1,"x");  //axc
```

## 最后要转String
```Java
StringBuilder sb = new StringBuilder();

sb.append("abc");

String result = sb.toString();
```