warning: in the working copy of 'content/posts/17buuctf/index.md', LF will be replaced by CRLF the next time Git touches it
[1mdiff --git a/content/posts/17buuctf/index.md b/content/posts/17buuctf/index.md[m
[1mindex 48ba3b3..6c5bbd4 100644[m
[1m--- a/content/posts/17buuctf/index.md[m
[1m+++ b/content/posts/17buuctf/index.md[m
[36m@@ -16,28 +16,28 @@[m [mcover: images/17.jpg[m
 sudo apt install imagemagick[m
 convert aaa.gif frame_%03d.png[m
 ```[m
[31m-![](17buuctf/img-001.png)![](17buuctf/img-002.png)![](17buuctf/img-003.png)[m
[32m+[m[32m![](img-001.png)![](img-002.png)![](img-003.png)[m
 得到flag[m
 [m
 ----[m
 ## 02二维码[m
 [CTF²](https://ctf2.dasctf.com/dashboard/practice/b9bbb32f-f186-458f-b90b-12440c0f6aea?tab=challenges&challenge=7a44e5a1-beea-4663-9b23-ebe1baf38765)[m
 先用QRCode扫码得到[m
[31m-![](17buuctf/img-004.png)[m
[32m+[m[32m![](img-004.png)[m
 直接扫描并没有得到flag[m
 ```Bash[m
  strings QR_code.png[m
 ```[m
[31m-![](17buuctf/img-005.png)[m
[32m+[m[32m![](img-005.png)[m
 于是binwalk提取得到`1D7`压缩包，尝试解压但是需要密码[m
[31m-![](17buuctf/img-006.png)[m
[32m+[m[32m![](img-006.png)[m
 压缩包中的文件为`4number.txt`，所以密码很可能是4位纯数字，用fcrackzip爆破[m
 ```Bash[m
 fcrackzip -b -c 1 -l 4-4 -u 1D7.zip[m
 ```[m
[31m-![](17buuctf/img-007.png)[m
[32m+[m[32m![](img-007.png)[m
 接下来继续解压缩得到txt文件，进而得到flag[m
[31m-![](17buuctf/img-008.png)[m
[32m+[m[32m![](img-008.png)[m
 [m
 ---[m
 ## 03N种方法解决[m
[36m@@ -51,7 +51,7 @@[m [mfile KEY.exe[m
 ```Bash[m
 head -c 100 KEY.exe[m
 ```[m
[31m-![](17buuctf/img-009.png)[m
[32m+[m[32m![](img-009.png)[m
 >文件类型：jpg图片  +   Base64编码的图片数据[m
 ```Bash[m
 sed 's/^data:image\/[^;]*;base64,//' KEY.exe | base64 -d > key.png[m
[36m@@ -62,13 +62,13 @@[m [msed 's/^data:image\/[^;]*;base64,//' KEY.exe | base64 -d > key.png[m
 agick key.png -filter point -resize 800% \[m
 ```[m
 再用扫码工具扫码[m
[31m-![](17buuctf/img-010.png)[m
[32m+[m[32m![](img-010.png)[m
 [m
 ---[m
 ## 04大白[m
 [CTF²](https://ctf2.dasctf.com/dashboard/practice/b9bbb32f-f186-458f-b90b-12440c0f6aea?tab=challenges&challenge=c99d060f-ba8b-4803-a23e-52b4b8a34b68)[m
 打开图片发现只有上半截，于是修改宽高[m
[31m-![](17buuctf/img-011.png)[m
[32m+[m[32m![](img-011.png)[m
 [m
 ---[m
 ## 05你竟然赶我走[m
[36m@@ -84,13 +84,13 @@[m [mstrings biubiu.jpg[m
 # Web[m
 ## 06[极客大挑战 2019]Havefun[m
 [CTF²](https://ctf2.dasctf.com/dashboard/practice/b9bbb32f-f186-458f-b90b-12440c0f6aea?tab=challenges&challenge=cb1461de-6e25-4bee-b0d4-12bc6106cb47)[m
[31m-![](17buuctf/img-012.png)[m
[32m+[m[32m![](img-012.png)[m
 网页会读取URL中名为`cat`的参数，当参数值等于dog时输出flag[m
 于是在URL后面加上[m
 ```txt[m
 ?cat=dog[m
 ```[m
[31m-![](17buuctf/img-013.png)[m
[32m+[m[32m![](img-013.png)[m
 [m
 ---[m
 ## 07[极客大挑战 2019]EasySQL[m
[36m@@ -108,7 +108,7 @@[m [mSELECT * FROM users WHERE username='$username' AND password='$password';[m
 ![](img-014.png)[m
 页面出现SQL语法错误，说明输入的单引号被拼接进了SQL语句，因此存在SQL注入漏洞[m
 ### 构造Payload[m
[31m-![](17buuctf/img-015.png)![](17buuctf/img-016.png)[m
[32m+[m[32m![](img-015.png)![](img-016.png)[m
 [m
 ### 原理分析[m
 将输入内容带入后，SQL语句变成[m
[36m@@ -141,9 +141,9 @@[m [mor 1=1[m
 ## 08[HCTF 2018]WarmUp[m
 [CTF²](https://ctf2.dasctf.com/dashboard/practice/b9bbb32f-f186-458f-b90b-12440c0f6aea?tab=challenges&challenge=0b1c4df1-92df-4818-b564-76bda414acfd)[m
 查看源码，看到有文件`source.php`[m
[31m-![](17buuctf/img-017.png)[m
[32m+[m[32m![](img-017.png)[m
 于是访问source.php[m
[31m-![](17buuctf/img-018.png)[m
[32m+[m[32m![](img-018.png)[m
 代码中存在白名单[m
 ```PHP[m
 $whitelist = [[m
[36m@@ -164,9 +164,9 @@[m [minclude $_REQUEST['file'];[m
 ```txt[m
 /index.php?file=hint.php[m
 ```[m
[31m-![](17buuctf/img-019.png)[m
[32m+[m[32m![](img-019.png)[m
 尝试直接访问[m
[31m-![](17buuctf/img-020.png)[m
[32m+[m[32m![](img-020.png)[m
 因为ffffllllaaaagggg不在白名单中，所以无法访问[m
 分析白名单检查漏洞[m
 ```PHP[m
[36m@@ -187,13 +187,13 @@[m [mif (in_array($_page, $whitelist)) {[m
 ```[m
 程序检查时读取?前面的hint.php，读取通过[m
 后面的`/../../../../../../`返回上级目录，最后读取`ffffllllaaaagggg`文件[m
[31m-![](17buuctf/img-021.png)[m
[32m+[m[32m![](img-021.png)[m
 [m
 ---[m
 ## 09[ACTF2020 新生赛]Include[m
 [CTF²](https://ctf2.dasctf.com/dashboard/practice/b9bbb32f-f186-458f-b90b-12440c0f6aea?tab=challenges&challenge=e5d73d5f-5971-46ad-8816-3aea17085aa3)[m
 打开靶机地址，看到有个`tips`，点击进去[m
[31m-![](17buuctf/img-022.png)[m
[32m+[m[32m![](img-022.png)[m
 地址栏中看到[m
 ```txt[m
 ?file=flag.php[m
[36m@@ -206,9 +206,9 @@[m [mif (in_array($_page, $whitelist)) {[m
 ```txt[m
 php://filter/read=convert.base64-encode/resource=flag.php[m
 ```[m
[31m-![](17buuctf/img-023.png)[m
[32m+[m[32m![](img-023.png)[m
 将显示出来的字符用Base64解密[m
[31m-![](17buuctf/img-024.png)[m
[32m+[m[32m![](img-024.png)[m
 ### Payload含义[m
 ```txt[m
 php://filter[m
[36m@@ -230,18 +230,18 @@[m [mresource=flag.php[m
 ```txt[m
 127.0.0.1[m
 ```[m
[31m-![](17buuctf/img-025.png)[m
[32m+[m[32m![](img-025.png)[m
 这一步确认网页确实在调用ping[m
 在输入框中输入[m
 ```txt[m
 127.0.0.1;ls[m
 ```[m
[31m-![](17buuctf/img-026.png)[m
[32m+[m[32m![](img-026.png)[m
 查看根目录[m
 ```txt[m
 127.0.0.1;ls /[m
 ```[m
[31m-![](17buuctf/img-027.png)[m
[32m+[m[32m![](img-027.png)[m
 于是读取flag[m
 ```txt[m
 127.0.0.1;cat /flag[m
[36m@@ -256,13 +256,13 @@[m [mresource=flag.php[m
 ```Bash[m
 file easyre.exe[m
 ```[m
[31m-![](17buuctf/img-028.png)[m
[32m+[m[32m![](img-028.png)[m
 说明是一个Windows可执行程序[m
 检查可读字符串[m
 ```Bash[m
 strings easyre.php | grep -i flag[m
 ```[m
[31m-![](17buuctf/img-029.png)[m
[32m+[m[32m![](img-029.png)[m
 找到了flag[m
 [m
 ---[m
[36m@@ -285,10 +285,10 @@[m [mstrings reverse_1.exe | grep -Ei "flag|input|right|wrong"[m
 ```[m
 输出中并没有直接出线最终flag，所以要继续查看程序的判断逻辑[m
 用**IDA**打开程序[m
[31m-![](17buuctf/img-030.png)[m
[31m-![](17buuctf/img-031.png)[m
[32m+[m[32m![](img-030.png)[m
[32m+[m[32m![](img-031.png)[m
 双击main_0，进去后点击F5[m
[31m-![](17buuctf/img-032.png)[m
[32m+[m[32m![](img-032.png)[m
 看程序，程序会把字符串中的所有字母`o`替换成数字`0`[m
 ```txt[m
 {hello_world}[m
