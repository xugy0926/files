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
