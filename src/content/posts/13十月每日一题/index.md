---
title: 十月每日一题
published: 2026-10-13
draft: false
featured: false
category: 网络安全
lang: zh_CN
updated: 2026-10-13
image: /images/13.jpg
tags:
  - CTF
  - WP
---
# [陇剑杯 2021]简单日志分析（问1）

| 项目       | 内容                   |
| -------- | -------------------- |
| title    | [陇剑杯 2021]简单日志分析（问1） |
| date     | 2026-10-01           |
| category | `misc`               |
| Flag     | `NSSCTF{user}`       |

查看 `app.log`，发现多条 `GET /?user=...` 请求。对参数值进行 URL 解码和 Base64 解码，再静态分析 pickle 数据，可见其中包含 `os.system` 调用。第 89 行执行的命令是 `whoami`，后续请求还尝试读取文件，并包含反弹 shell 命令。

这些攻击请求都使用同一个查询参数名 `user`。题目问的是攻击参数名，因此答案为 `user`。

**Flag：`NSSCTF{user}`**

#  [长城杯 2021 院校组]签到


| 项目       | 内容                                 |
| -------- | ---------------------------------- |
| title    | [长城杯 2021 院校组]签到                   |
| date     | 2026-10-02                         |
| category | `misc`                             |
| Flag     | `NSSCTF{Welcome_to_changchengbe1}` |

题目给出一串16进制编码，先进行`Hex`解码得到
```txt
ZmxhZ3tXZWxjb21lX3RvX2NoYW5nY2hlbmdiZTF9
```
再进行`Base64`解码得到flag
```txt
flag{Welcome_to_changchengbe1}
```

# [GWCTF 2019]babyRSA

| 项目       | 内容                                       |
| -------- | ---------------------------------------- |
| title    | [GWCTF 2019]babyRSA                      |
| date     | 2026-10-03                               |
| category | `crypto`                                 |
| Flag     | `GWHT{f709e0e2cfe7e530ca8972959a1033b2}` |

`encrypt.py` 中设定 `q = nextprime(p)`，所以 RSA 模数 `N = p*q` 的两个素因子很接近，可以用 Fermat 分解。计算 `a = ceil(sqrt(N))` 后，`a²-N` 已经是平方数；得到因子后计算 `phi(N)` 和私钥指数 `d`，即可分别解密 `m1`、`m2`，得到：

- `S = F1 + F2`
- `T = F1³ + F2³`

利用恒等式 `F1³ + F2³ = (F1+F2)³ - 3F1F2(F1+F2)`，可算出 `F1F2 = (S³-T)/(3S)`。于是 `F1`、`F2` 是方程 `x²-Sx+F1F2=0` 的两个整数根。分别转回字节后，按 `GWHT{` 前缀确定顺序，拼出 flag。

## EXP
```python
import math
import sys
import zipfile
from pathlib import Path

archive = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("encrypt.zip")
with zipfile.ZipFile(archive) as zf:
    values = {}
    for line in zf.read("secret").decode().splitlines():
        key, value = line.split("=", 1)
        values[key] = int(value)

N, m1, m2 = values["N"], values["m1"], values["m2"]
e = 0x10001

a = math.isqrt(N)
if a * a < N:
    a += 1
while True:
    b2 = a * a - N
    b = math.isqrt(b2)
    if b * b == b2:
        p, q = a - b, a + b
        if p * q == N:
            break
    a += 1

phi = (p - 1) * (q - 1)
d = pow(e, -1, phi)
S = pow(m1, d, N)
T = pow(m2, d, N)

assert (S**3 - T) % (3 * S) == 0
product = (S**3 - T) // (3 * S)
discriminant = S * S - 4 * product
root = math.isqrt(discriminant)
assert root * root == discriminant
F1, F2 = (S + root) // 2, (S - root) // 2

def long_to_bytes(n):
    return n.to_bytes((n.bit_length() + 7) // 8, "big")

parts = [long_to_bytes(F1), long_to_bytes(F2)]
for ordered in (parts, parts[::-1]):
    candidate = b"".join(ordered)
    if candidate.startswith(b"GWHT{") and candidate.endswith(b"}"):
        print(candidate.decode())
        break
```

