以下是在 macOS 上使用 `yt-dlp` 的完整手册，涵盖安装、基本用法、高级功能以及常见问题的解决方法。

---

## **yt-dlp 使用手册（macOS 版）**

### **1. 安装 yt-dlp**

#### 方法 1：使用 Homebrew 安装
1. 打开终端。
2. 安装 Homebrew（如果尚未安装）：
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
3. 通过 Homebrew 安装 `yt-dlp`：
   ```bash
   brew install yt-dlp
   ```

#### 方法 2：使用 pip 安装
1. 确保已安装 Python 3：
   ```bash
   python3 --version
   ```
2. 使用 `pip` 安装 `yt-dlp`：
   ```bash
   python3 -m pip install -U yt-dlp
   ```
3. 定期更新
  ```
  yt-dlp -U
  ```

#### 方法 3：手动下载
1. 下载最新的 `yt-dlp` 可执行文件：
   ```bash
   sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
   ```
2. 赋予执行权限：
   ```bash
   sudo chmod a+rx /usr/local/bin/yt-dlp
   ```

### **2. 基本用法**

#### 下载单个视频
```bash
yt-dlp https://www.youtube.com/watch?v=视频ID
```

#### 下载播放列表
```bash
yt-dlp https://www.youtube.com/playlist?list=播放列表ID
```

#### 下载指定格式
1. 列出所有可用格式：
   ```bash
   yt-dlp -F https://www.youtube.com/watch?v=视频ID
   ```
2. 根据格式编号下载：
   ```bash
   yt-dlp -f 格式编号 https://www.youtube.com/watch?v=视频ID
   ```

#### 下载最佳质量
```bash
yt-dlp -f best https://www.youtube.com/watch?v=视频ID
```

#### 下载音频
```bash
yt-dlp -x --audio-format mp3 https://www.youtube.com/watch?v=视频ID
```

### **3. 高级用法**

#### 自定义输出文件名
```bash
yt-dlp -o "%(title)s.%(ext)s" https://www.youtube.com/watch?v=视频ID
```
- `%(title)s`：视频标题
- `%(ext)s`：文件扩展名
- 更多变量请参考 `yt-dlp --help`。

#### 下载字幕
```bash
yt-dlp --write-subs https://www.youtube.com/watch?v=视频ID
```

#### 下载缩略图
```bash
yt-dlp --write-thumbnail https://www.youtube.com/watch?v=视频ID
```

#### 批量下载
将多个视频 URL 保存到 `urls.txt` 文件中，然后运行：
```bash
yt-dlp -a urls.txt
```

#### 限制下载速度
```bash
yt-dlp --limit-rate 1M https://www.youtube.com/watch?v=视频ID
```

#### 跳过已下载的视频
```bash
yt-dlp --download-archive archive.txt https://www.youtube.com/watch?v=视频ID
```

### **4. 常见问题**

#### 问题 1：`zsh: no matches found`
- **原因**：`zsh` 将 URL 中的特殊字符解释为通配符。
- **解决方法**：
  1. 用引号包裹 URL：
     ```bash
     yt-dlp 'https://www.youtube.com/watch?v=视频ID'
     ```
  2. 使用 `noglob`：
     ```bash
     noglob yt-dlp https://www.youtube.com/watch?v=视频ID
     ```

#### 问题 2：下载速度慢
- **解决方法**：
  1. 使用 `--limit-rate` 限制速度。
  2. 尝试更换网络或使用代理。

#### 问题 3：无法下载某些网站的视频
- **解决方法**：
  1. 更新 `yt-dlp`：
     ```bash
     yt-dlp -U
     ```
  2. 检查网站是否受支持：
     ```bash
     yt-dlp --list-extractors
     ```

### **5. 更新 yt-dlp**
```bash
yt-dlp -U
```

### **6. 获取帮助**
查看所有可用选项：
```bash
yt-dlp --help
```

查看支持的网站列表：
```bash
yt-dlp --list-extractors
```

### **7. 示例命令**

#### 下载视频并保存为自定义文件名
```bash
yt-dlp -o "%(title)s.%(ext)s" https://www.youtube.com/watch?v=视频ID
```

#### 下载播放列表并保存到指定目录
```bash
yt-dlp -o "~/Downloads/%(playlist_index)s - %(title)s.%(ext)s" https://www.youtube.com/playlist?list=播放列表ID
```

#### 下载音频并转换为 MP3
```bash
yt-dlp -x --audio-format mp3 https://www.youtube.com/watch?v=视频ID
```

### **8. 配置文件**
`yt-dlp` 支持配置文件，可以将常用选项保存到配置文件中：
1. 创建配置文件：
   ```bash
   nano ~/.config/yt-dlp/config
   ```
2. 添加常用选项，例如：
   ```bash
   -o "%(title)s.%(ext)s"
   --write-subs
   ```
3. 保存后，`yt-dlp` 会自动加载这些选项。

在使用 `yt-dlp` 时，某些网站（如 YouTube、Bilibili 等）可能需要登录才能访问特定内容（例如会员视频或年龄限制内容）。为了下载这些内容，你可以通过导入浏览器的 **Cookies** 来模拟登录状态。

以下是获取和使用 Cookies 的详细方法：

---

## **1. 获取 Cookies**

### **方法 1：使用浏览器扩展**
1. **安装扩展**：
   - Chrome/Firefox 用户：安装 [Get cookies.txt](https://chrome.google.com/webstore/detail/get-cookiestxt/bgaddhkoddajcdgocldbbfleckgcbcid) 扩展。
   - Edge 用户：安装 [cookies.txt](https://microsoftedge.microsoft.com/addons/detail/cookiestxt/hjbkmgciaigcjompljbiocgmonnclkfi) 扩展。

2. **导出 Cookies**：
   - 登录目标网站（如 YouTube）。
   - 点击扩展图标，选择“导出 Cookies”。
   - 保存为 `cookies.txt` 文件。

### **方法 2：手动导出 Cookies**
1. 打开浏览器的开发者工具（按 `F12` 或 `Cmd+Option+I`）。
2. 切换到 **Application** 选项卡。
3. 在左侧找到 **Cookies**，选择目标网站（如 `youtube.com`）。
4. 右键点击 Cookies，选择“Export”或手动复制内容到文本文件中。

---

## **2. 使用 Cookies**

### **方法 1：通过 `--cookies` 参数**
将导出的 `cookies.txt` 文件与 `yt-dlp` 一起使用：
```bash
yt-dlp --cookies cookies.txt https://www.youtube.com/watch?v=视频ID
```

### **方法 2：通过配置文件**
将 `cookies.txt` 路径添加到 `yt-dlp` 的配置文件中：
1. 打开配置文件：
   ```bash
   nano ~/.config/yt-dlp/config
   ```
2. 添加以下内容：
   ```bash
   --cookies /path/to/cookies.txt
   ```
3. 保存并退出。

---

## **3. 注意事项**
1. **Cookies 的安全性**：
   - Cookies 包含你的登录信息，请勿分享或泄露。
   - 定期更新 Cookies 文件，因为 Cookies 可能会过期。

2. **Cookies 的路径**：
   - 确保 `cookies.txt` 文件的路径正确。
   - 如果文件路径包含空格，请用引号包裹路径：
     ```bash
     yt-dlp --cookies "/path/with spaces/cookies.txt" https://www.youtube.com/watch?v=视频ID
     ```

3. **多网站支持**：
   - 如果你需要下载多个网站的内容，可以为每个网站单独导出 Cookies 文件，并在使用时指定。

---

## **4. 示例**

### 下载 YouTube 会员视频
1. 登录 YouTube 并导出 Cookies 为 `youtube_cookies.txt`。
2. 使用以下命令下载：
   ```bash
   yt-dlp --cookies youtube_cookies.txt https://www.youtube.com/watch?v=会员视频ID
   ```

### 下载 Bilibili 大会员视频
1. 登录 Bilibili 并导出 Cookies 为 `bilibili_cookies.txt`。
2. 使用以下命令下载：
   ```bash
   yt-dlp --cookies bilibili_cookies.txt https://www.bilibili.com/v
 
