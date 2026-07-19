---
title: JuniorCrypt2026的WP
date: 2026-07-12
lastmod: 2026-07-13
draft:
tags:
  - CTF
  - WP
cover: images/15.jpg
featured:
---
# Misc
## 1000-7
### 题目描述
![](15JuniorCrypt/img-001.png)
>有些旋律会一直留在你的**脑海里**。  
>有些旋律则会在离开后留下**别的东西**。

### 解题思路
#### 检查文件
先检查附件，其后缀为 **.mid**，所以存储的是MIDI指令/事件，它通常会记录
```txt
什么时候按下哪个音符
什么时候松开
按键力度多大
使用什么乐器
音量是多少
音高怎么变化
节拍和速度是多少
```
同时又根据题目“有些旋律会在离开后留下别的东西”，所以数据被隐藏在MIDI文件中

#### 安装读取MIDI的Python库
```bash
sudo apt update
sudo apt install python3-mido -y
```

#### 观察MIDI中有什么
新建文件
```txt
check.py
```
打开后写入
```python
from mido import MidiFile
from collections import Counter

# 打开 MIDI 文件
midi = MidiFile("chal.mid")

print("MIDI 类型：", midi.type)
print("轨道数量：", len(midi.tracks))

for number, track in enumerate(midi.tracks):
    print("\n轨道编号：", number)
    print("轨道名称：", track.name)

    # 统计每一种 MIDI 消息出现了多少次
    types = []

    for message in track:
        types.append(message.type)

    print("消息类型统计：")
    print(Counter(types))
```

保存后运行
```bash
python3 check.py
```
![](15JuniorCrypt/img-002.png)
从中我们可以看出
```txt
MIDI类型：1   ——  文件中可以包含多条轨道，各轨道分别保存不同内容，但共用同一时间轴。
轨道数量：2  ——  文件共有两条轨道，轨道0和轨道1

轨道0：
名称：Unravel - Tokyo Ghoul
包含事件：
	track_name：1  ——  曲目名称
	set_tempo：1  ——  音乐速度
	end_of_track：1  ——  轨道结束标记
因此，轨道0没有实际内容，只保存曲名和速度等全局信息

轨道1：实际演奏内容
其中：
	note_on：2015  ——  按下
	note_off：2015  ——  松开
但是
	pitchwheel：752  ——  752个弯音轮（临时升高或降低音高）事件，这里的pitchwheel事件数量过多十分可疑
其他消息：
	control_change：6  ——  控制音量、踏板等参数
	program_change：1  ——  切换乐器音色
	time_signature：1  ——  拍号，例如4/4拍
的数量都比较少，看起来比较正常
```
**所以当前最重要的是提取这752个pitchwheel，看看它们有哪些数值以及是否存在规律**

#### 查看pitchwheel具体数值
新建python文件check2.py
```python
from mido import MidiFile
from collections import Counter

midi = MidiFile("chal.mid")

pitch_values = []

# 遍历所有轨道和所有 MIDI 消息
for track in midi.tracks:
    for message in track:

        # 只提取 pitchwheel 弯音事件
        if message.type == "pitchwheel":
            pitch_values.append(message.pitch)

print("pitchwheel 总数量：", len(pitch_values))

print("不同数值及出现次数：")
print(Counter(pitch_values))

print("前 30 个 pitchwheel 数值：")
print(pitch_values[:30])
```
运行后得到
![](15JuniorCrypt/img-003.png)
从结果我们可以看出
```txt
pitchwheel总数量：752
数值有：2304  -2304且二者的出现次数都为376
```
同时也可以猜测有两种组合：
```txt
(2304, -2304)
(-2304, 2304)
```

#### 统计两种组合
新建文件check3.py
```python
from mido import MidiFile
from collections import Counter

midi = MidiFile("chal.mid")

pitch_values = []

# 提取所有 pitchwheel 数值
for track in midi.tracks:
    for message in track:
        if message.type == "pitchwheel":
            pitch_values.append(message.pitch)

pairs = []

# 每两个数值组成一组
for i in range(0, len(pitch_values), 2):
    first = pitch_values[i]
    second = pitch_values[i + 1]

    pairs.append((first, second))

print("总共有多少组：", len(pairs))

print("不同组合及出现次数：")
print(Counter(pairs))

print("前 20 组：")
print(pairs[:20])
```
![](15JuniorCrypt/img-004.png)
从输出结果可以看出：
```txt
总共有376组
只有两种组合：(2304，-2304)出现了193次；(-2304，2304)出现了183次
```
说明作者是故意让两个相反的弯音值组成一组，刚好可以表示**0**和**1**
另外，
```txt
376/8 = 47
```
也就是说，这些数据可以组成47个字节。ASCII文本通常一个字节对应一个字符，所以很可能藏有47个字符的文本

#### 将两种组合转换成文本0和1
```python
from mido import MidiFile

midi = MidiFile("chal.mid")

pitch_values = []

# 提取所有 pitchwheel 的数值
for track in midi.tracks:
    for message in track:
        if message.type == "pitchwheel":
            pitch_values.append(message.pitch)

bits = ""

# 每两个数值作为一组
for i in range(0, len(pitch_values), 2):
    pair = (pitch_values[i], pitch_values[i + 1])

    # 先上升再下降，记为 1
    if pair == (2304, -2304):
        bits += "1"

    # 先下降再上升，记为 0
    elif pair == (-2304, 2304):
        bits += "0"

    # 出现其他组合就报出来
    else:
        print("发现异常组合：", pair)

print("二进制位数：", len(bits))

print("完整二进制：")
print(bits)

print("\n每 8 位分成一组：")

for i in range(0, len(bits), 8):
    print(bits[i:i + 8], end=" ")

print()
```
![](15JuniorCrypt/img-005.png)
每8位试着转换成一个字符
```txt
11000000  → 192，干扰字符
11011110  → 222，干扰字符
00101010  → *
01100111  → g
01110010  → r
01101111  → o
01100100  → d
01101110  → n
01101111  → o
01111011  → {
```
因此后面很明显出现
```txt
grodno{
```
与flag格式相符，说明我们的解码方向正确

#### 每八位转换成字符
```python
from mido import MidiFile

midi = MidiFile("chal.mid")

pitch_values = []

# 提取所有 pitchwheel 数值
for track in midi.tracks:
    for message in track:
        if message.type == "pitchwheel":
            pitch_values.append(message.pitch)

bits = ""

# 每两个 pitchwheel 事件转换成一个二进制位
for i in range(0, len(pitch_values), 2):
    pair = (pitch_values[i], pitch_values[i + 1])

    if pair == (2304, -2304):
        bits += "1"

    elif pair == (-2304, 2304):
        bits += "0"

# 保存解码后的文本
text = ""

# 每 8 位二进制转换成一个字符
for i in range(0, len(bits), 8):
    one_byte = bits[i:i + 8]

    # 把二进制转换成十进制
    number = int(one_byte, 2)

    # 把十进制转换成字符
    character = chr(number)

    text += character

print("解码结果：")
print(repr(text))
```
![](15JuniorCrypt/img-006.png)
所以最终flag为
```txt
grodno{U1tr@_m3g@_5up3r_Gul_M1d_SF_1000-7}
```

---

## Ghost Layers
### 题目描述
![](15JuniorCrypt/img-007.png)
>What stays visible is not always what matters most.  
>一直可见的东西，并不总是最重要的。

### 解题思路
#### 检查文件
查看文件后缀为.svg文件
```txt
.svg是一种矢量图片文件，全称是：
Scalable Vector Graphics（可缩放矢量图形）
SVG通常用代码描述图形，例如线条、圆形、颜色和文字
特点：
	放大不会模糊；
	文件通常比较小；
	可用浏览器直接打开；
	可以修改颜色、大小和形状；
	本质上是一种XML文本文件，可以用VS Code、记事本打开查看代码
	可以通过CSS或JavaScript添加动画和交互
SVG内部可以包含脚本代码
```

#### 寻找隐藏数据
SVG中通常会在
```txt
mask        蒙版
clipPath    裁剪
opacity     透明度
display     是否显示
visibility  是否可见
defs        只定义、不直接显示
```
中隐藏数据
于是先用VS Code打开文件，再用CTRL+F搜索“mask”，找到名字为“mk9”的蒙版
![](15JuniorCrypt/img-008.png)
```txt
<mask id="mk9">
    <rect x="0" y="0"
          width="577"
          height="635"
          fill="black"/>

    <polyline points="..."
              stroke="white"
              .../>
</mask>
```
这里可以理解为
```txt
黑色区域：隐藏
白色区域：显示
灰色区域：部分显示
```
这里先使用黑色矩形遮住整个画布，然后指通过一些白色线条显示少量内容，因此隐藏图形很难被观察到

#### 找到使用蒙版的图层
![](15JuniorCrypt/img-009.png)
从中我们可以看到信息：
```XML
<g id="ghost-wash"
   opacity="0.72"   ——  降低透明度
   mask="url(#mk9)"  ——  使用蒙版mk9
   filter="url(#glowSoft)">  ——  使用发光、模糊效果
```
同时还有
```txt
clip-path="url(#cp4)"
```
说明真正决定图形轮廓的可能是cp4

#### 分析cp4的裁剪路径
搜索
```txt
id="cp4"
```
![](15JuniorCrypt/img-010.png)
引用id为s17的图形，并把它作为裁剪区域
于是继续搜索
```txt
id="s17"
```
找到
```XML
<g id="s17">
    <g transform="translate(62.500,454.000)
                  scale(0.009400,-0.009400)"
       fill="#f8efc9"
       stroke="#f8efc9"
       stroke-width="36"
       stroke-linejoin="round">

        <path d="..."/>
        <path d="..."/>
        ...
    </g>
</g>
```
`s17` 内部包含大量 `<path>` 标签。
这些路径不是随机数据，而是由文字转换得到的矢量轮廓。也就是说，隐藏的 Flag 已经被转换为一组路径，所以直接搜索：
```txt
grodno
```
无法找到明文

#### 隐藏原理
```txt
s17
│
│ 保存 Flag 文字的矢量路径
↓
cp4
│
│ 将 s17 作为裁剪形状
↓
ghost-wash
│
│ 只在 Flag 文字内部绘制渐变和线条
↓
mk9
│
│ 再通过蒙版遮挡绝大部分区域
↓
glowSoft + opacity
│
│ 添加发光并降低透明度
↓
Flag 变得若隐若现
```
于是试图直接显示隐藏图层

### EXP
先将原文件复制一份
用VS Code打开文件，跳转到结尾，找到
```XML
</svg>
```
在其前面加上
```XML
<rect x="0"
      y="390"
      width="577"
      height="110"
      fill="black"/>

<use href="#s17"/>
```
保存文件后用浏览器打开即可看见flag
![](15JuniorCrypt/img-011.png)