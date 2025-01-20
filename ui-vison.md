- clickAndWait
linkText=This link@POS=3


# 定位元素（位置）
https://ui.vision/rpa/docs/selenium-ide/locators
## 在浏览器中
- id=my_id
- name=my_name
- linkText=some_text，partialLinkText=some_partial_text - 只支持link元素
- xpatch=my_x_path - 通过浏览器检查、选定选择、然后右键选择“获取xpatch”
- css=button[value="tesla"]
## 可视化图形定位
image定位，可以定位桌面应用或者canvas内容，
- test.png#3 - 选择第3个（从上到下、从左到右）
- test.png@0.85 - 选择高于0.85中的最优的
- test.png@0.85#1 - 执选择高于0.85的第1个（从上到下，从左到右）// 这条规则需要验证
- test.png@0.85#${!times} - 执行多次
- ocr=text
## 坐标定位
- x,y - 根据坐标定位
## 文本定位
- \*text to click\* - 可用\*通配符
- \*text to click\*@pos=X - 匹配第X个


- visualAssert - 如果没有找到匹配的图像，则宏会停止并报错。
- visualVerify - 如果未找到图像，则宏会记录警告，但宏的执行会继续。
- visualSearch - 匹配的数量被填入一个变量，就像 sourceSearch 命令一样。如果没有找到图像，则匹配的数量为 0。
