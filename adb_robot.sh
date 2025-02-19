#!/bin/bash

# ----------------------------------------------------------------------------
# meituan_main_search.sh
# 
# 【使用方式】
# 执行adb devices ，获取设备id
# 执行 ./meituan_main_search.sh <device_id> <search_input_text>
#
# 【脚本说明】
# 该脚本用于搜索美团主搜内容的爬取
#
# 【逻辑步骤】
# 1. 杀死应用。目的是确保应用处于未启动状态，不干扰接下来的步骤。
# 2. 启动应用。
# 3. 根据坐标点模拟点击搜索框。关于如何获取坐标点，可以参考README.md - 获取坐标点。
# 4. 在搜索页面，输入搜索关键词。
# 5. 模拟按下回车键。
# 6. 模拟滑动操作。
# 7. 循环执行上述操作，并截图。
# 8. 直到页面没有变化，停止滑动操作。
# 9. 结束。
#
# ----------------------------------------------------------------------------
# ----------------------------------------------------------------------------
# 【事前准备和了解】
#
# 1. 确保电脑安装了 adb
# 2. 手机别设置锁屏密码
# 3. 手机文字大小、内容大小都设置为小，保证屏幕展示的内容更多。
# 3. 在手机上安装 ADBKeyBoard.apk，其实这即是一个输入法应用，安装完后把手机输入发切换到ADBKeyBoard。详细参考 https://github.com/senzhk/ADBKeyBoard/blob/master/README.md。
# 
# 【消除被判定为自动化的风险】
# 本质上讲，以上步骤就是一个用户的实际操作。
# 在过程中，增加随机事件的间隔，可以消除被判定为自动化的风险。如何消除被判定为自动化的风险，
# 
# 【关于循环滑动操作的结束条件】
# 循环会因为两个条件中止，一是循环持续时间；二是页面没有变化（达到最底部）。
# 有时候，我们只需要翻20多页就可以拿完数据，那么可以把时间设置小一点。如果想一股脑翻到最后，就设置一个大的时间。
#
# 【中文自动化输入问题】
# 通过 adb input text 输入中文会失败。因此，需要使用 adb shell am broadcast的方式。详细参考 https://github.com/senzhk/ADBKeyBoard/blob/master/README.md
# 把包下载到电脑上，然后安装。例如：adb install ./Downloads/app-uiautomator.apk
# ----------------------------------------------------------------------------
# ----------------------------------------------------------------------------
# 【常见问题】 - 其实所有问题都可以问AI，这里只是为了方便大家快速查找
#
# Q1: 如何获取手机中的包名 
# A1: adb shell pm list packages
#
# Q2: 如何获取点击的坐标
# A2: 
#     方式一：打开手机开发者模式的“指针显示”开关，点击任何地方都会有坐标值显示。
#     方式二：
#       adb shell getevent | gawk '/0035|0036/ {if ($3 == "0035") {x = int(strtonum("0x"$4)*0.125)}; if ($3 == "0036") {y = int(strtonum("0x"$4)*0.125); print "X: " x ", Y: " y}}'
#       然后在屏幕点击一下，就会出现坐标值。注意这个指令使用了0.125这个常量，这其实是分辨率和像素的比例计算出来的。
#       例如，OppoK12x的计算方式
#         rateX = 1080/8639 = 0.1250144693
#         rateY = 2400/19199 = 0.1250065108
# 
# ----------------------------------------------------------------------------

DEVICE_ID=$1              # 设备id，通过 adb devices 命令获取
SEARCH_INPUT_TEXT=$2      # 搜索词

PACKAGE_NAME="com.sankuai.meituan"
MAIN_ACTIVITY="com.meituan.android.pt.homepage.activity.MainActivity"

# 模拟用户滑动行为的坐标，从X点滑动到Y点
SWIPE_START_X=300         # 滑动起始坐标
SWIPE_START_Y=1500        # 滑动起始坐标
SWIPE_END_X=300           # 滑动结束坐标
SWIPE_END_Y=500           # 滑动结束坐标

SWIPE_DURATION=1000       # 滑动持续时间（毫秒）
LOOP_DURATION=1800        # 循环持续时间（秒）
SLEEP_INTERVAL=2          # 滑动操作间隔时间（秒）
END_TIME=$((SECONDS + LOOP_DURATION)) # 设置结束时间

adb  -s ${DEVICE_ID} shell input keyevent 82  # 解开锁屏

echo "开始执行脚本: $(date '+%Y-%m-%d %H:%M:%S')"

# 按照 [脚本名称_搜索词_当前时间] 创建一个文件夹，用于存储截图数据
BASENAME=$(basename "$0" | cut -d. -f1)
SCREEN_IMAGE_FOLDER="${BASENAME}_${SEARCH_INPUT_TEXT}_$(date +%Y-%m-%d_%H:%M:%S)"
mkdir -p "$SCREEN_IMAGE_FOLDER"

echo "强制停止应用 $PACKAGE_NAME..."
adb  -s ${DEVICE_ID} shell am force-stop $PACKAGE_NAME
sleep 1

echo "启动应用 $PACKAGE_NAME..."
adb  -s ${DEVICE_ID} shell am start -n $PACKAGE_NAME/$MAIN_ACTIVITY || { echo "启动应用失败"; exit 1; }
sleep $((RANDOM % 3 + 5))   # 随机等待 5-7 秒

echo "点击搜索框..."
adb  -s ${DEVICE_ID} shell input tap 410 240
sleep $((RANDOM % 2 + 1))   # 随机等待 1-2 秒

echo "输入文本: $SEARCH_INPUT_TEXT..."
for ((i=0; i<${#SEARCH_INPUT_TEXT}; i++)); do
  CHAR=${SEARCH_INPUT_TEXT:$i:1}
  adb  -s ${DEVICE_ID} shell am broadcast -a ADB_INPUT_B64 --es msg `echo -n "$CHAR" | base64`
  sleep $(awk -v min=0.1 -v max=0.3 'BEGIN{srand(); print min+rand()*(max-min)}')  # 随机延迟 0.1-0.3 秒
done

echo "按下回车键..."
adb  -s ${DEVICE_ID} shell input keyevent 66
sleep $((RANDOM % 3 + 2))  # 随机等待 2-4 秒

echo "开始循环滑动操作中..."
LAST_SCREENSHOT=""
while [ $SECONDS -lt $END_TIME ]; do
  CURRENT_SCREENSHOT="${BASENAME}_screen_$(date '+%Y-%m-%d %H:%M:%S').png"
  adb -s ${DEVICE_ID} exec-out screencap -p > "${SCREEN_IMAGE_FOLDER}/${CURRENT_SCREENSHOT}"

  if [[ -n "$LAST_SCREENSHOT" ]]; then
    if diff "${SCREEN_IMAGE_FOLDER}/${LAST_SCREENSHOT}" "${SCREEN_IMAGE_FOLDER}/${CURRENT_SCREENSHOT}" > /dev/null; then
      echo "检测到页面没有变化，停止滑动操作。"
      break
    fi
  fi

  adb  -s ${DEVICE_ID} shell input swipe $SWIPE_START_X $SWIPE_START_Y $SWIPE_END_X $SWIPE_END_Y $SWIPE_DURATION
  sleep $SLEEP_INTERVAL

  LAST_SCREENSHOT="${CURRENT_SCREENSHOT}"
done

echo "脚本执行完成！${date '+%Y-%m-%d %H:%M:%S'}"
