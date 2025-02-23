# adb_robot.sh 说明

https://github.com/xugy0926/files/blob/main/adb_robot.sh

adb_robot.sh 实现了自动化进入美团APP、输入搜索词、进入搜索页、滚动页面，并对页面进行截图。目的是以截图的方式，收集美团APP主搜结果页的数据。有了截图数据后，可以通过AI方式分析图片提炼截图的 JSON 数据。最终得到所有的商品数据。

本片文档主要是介绍收集数据的自动化操作，不涉及截图的AI分析过程。

adb_robot.sh 里面只使用了 adb 指令和通用的shell指令，如 diff、sleep。adb 主要是操作手机应用，包括连接设备，启动应用，模拟输入、点击和滚动等。 diff 用于比较图片，sleep 是用于模仿真人间隔操作。

### 为什么要这么做？

市面上有很多自动化收集应用数据的工具。我也看到团队为了追求规模化，开发很庞大的工程，使用难度特别大，维护成本很高。

其实 adb 功能特别强大，技术很成熟，案例也很多。我们应该在一些场景回归到更便利的手段。主要考虑3个原因。

1. 成本问题：
   - 类似收集某个关键词的结果数据是非常小的需求，用那么复杂的工程去做，学习和使用成本高。有的项目还需要用android环境编译脚本。。。
   - 庞大的采集项目需要很多设备，在实际使用中要刻意注意使用时间和周期，很容易被封。
2. adb 操作更稳定：我用 adb_robot.sh 让 AI 帮我完善了更模拟人类操作的间隔时间，在两天时间内进行多次采集截图，没有被封。
3. 规模化假象：为了规模化把采集和分析放在一起，使得功能特别复杂。本质上采集和分析是两件事，不要混为一谈。以前通过分析图片得到结构化数据不仅难也不准，但是现在有了AI，本地就可以使用非常简单的方式解析数据。

其实 adb 来操作手机的功能非常强大。

### 事前准备和了解

1. **确保电脑安装了 ADB**  
   确保你的电脑上已正确安装 `adb` 工具。
   ```bash
   brew cask install android-platform-tools
   ```
3. **手机设置**  
   - 不要设置锁屏密码。
   - 将手机的文字大小、内容大小设置为最小，以便屏幕展示更多内容。
   - 打开“开发者模式”
4. **安装 ADBKeyBoard.apk**  
   这是一个输入法应用，用于支持自动化输入中文。
   - 下载地址：[ADBKeyBoard](https://github.com/senzhk/ADBKeyBoard)
   - 安装命令：
     ```bash
     adb install ./Downloads/ADBKeyBoard.apk
     ```
   - 安装完成后，将手机输入法切换为 ADBKeyBoard。

### 脚本使用方式

1. 下载 `adb_robot.sh` 到本地某个目录

1. 执行以下命令获取设备ID：
   ```bash
   adb devices
   ```
2. 执行脚本：
   ```bash
   ./adb_robot.sh <device_id> <search_input_text>
   ```

### 脚本的逻辑步骤

该脚本用于搜索美团主搜内容并进行爬取。

1. **杀死应用**  
   确保应用处于未启动状态，避免干扰后续操作。
2. **启动应用**  
   启动美团主应用。
3. **点击搜索框**  
   根据坐标点模拟点击搜索框。关于如何获取坐标点，参考 [如何获取点击的坐标](#如何获取点击的坐标)。
4. **输入搜索关键词**  
   在搜索页面输入搜索关键词。
5. **模拟回车键**  
   模拟按下回车键，触发搜索。
6. **模拟滑动操作**  
   模拟用户滑动屏幕查看内容。
7. **循环操作并截图**  
   循环执行滑动操作，定期截图保存内容。
8. **停止滑动**  
   当页面没有变化（达到底部）或达到循环时间限制时，停止操作。
9. **脚本结束**

# 使用 adb_robot.sh 心得

## 消除被判定为自动化采集的风险

我让 AI 帮我完善了 adb_robot.sh 中每个步骤的间隔时间和变化时间。使用了2天都没有被封号。

## 关于循环滑动操作的结束条件

有时候一个关键词搜索出来的结果，假如有效页面的数据为20多页，20页之后就是一些相关性不强的内容，就没必要收集了。

你对有效内容的业务有了判断之后，我们来计算一下操作的时间。

1. 进入到搜索页面消耗约：10秒
2. 滚动一次约：2S
3. 模拟阅读停留约：1S
4. 因为我们不可能恰好滚动一次就是一个全新的页面，可能只滚约1/3 ～ 1/3的区域。20页我可能需要滚30～40次。
 
整体消耗的时间约为 10 + 40 * (2+1) = 130秒。

因为我们不需要那么准确，这个公式可以简化为：`翻页时间(3秒) * 滚动页数 * 2`。

利用公式，粗略得到的结束时间为 240 秒。基本可以覆盖你想要的内容。

如果你想滚到滚不动位置。可以把这个时间设置为大一些。比如1个小时。脚本会自动比较截图来决定是否结束。

循环滑动结束的两个条件：
1. **循环时间达到限制**：可以通过设置时间限制来控制操作时长。
2. **页面没有变化**：当页面滑动到底部时，内容不再变化，操作会自动停止。

## 中文自动化输入问题

- 使用 `adb input text` 输入中文会失败。
- 需要使用以下方式进行中文输入：
  ```bash
  adb shell am broadcast -a ADB_INPUT_B64 --es msg <base64_encoded_text>
  ```
- 详细参考 [ADBKeyBoard 文档](https://github.com/senzhk/ADBKeyBoard/blob/master/README.md)。

## 如何获取手机中的包名

1. 执行以下命令查看手机中已安装的应用包名：
   ```bash
   adb shell pm list packages
   ```
2. 找到目标应用的包名，例如美团的包名为 `com.sankuai.meituan`。

## 如何获取点击的坐标

1. 打开手机开发者选项中的 **“指针显示”** 开关。
2. 点击手机屏幕任意位置，屏幕上会显示当前的坐标值。
3. 记录需要点击的坐标后，关闭该选项（开启会影响截图效果）。

## 注意翻页的位置

比如，搜索结果页面本质上是列表，每个列表项目的高度不一样。我们想通过一次恰到好处的滑动翻到新的一页是不现实的。所以，我们只能翻1/3～2/3，这就会导致前后两张的数据可能有重复。利用ai分析数据也可能重复，但是重复没关系，我们可以把数据过滤一下即可。

在脚本里，模拟滑动时从坐标A滑到B。这个是我提前模拟滑动2/3区域获得的坐标点。如果有需要，你可以调整这两个坐标。
