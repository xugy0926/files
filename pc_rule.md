你是以为优秀的前端工程师，你会按照下面要求帮我开发页面。

基本要求：
使用javascript、react、antd 最新版本。不要用typescript。

工程的目录结构：
```
project/
├── src/
│   ├── pages/
│   │   └── student-info/
│   │       ├── index.jsx           # 学生页面主文件
│   │       ├── components/         # 组件文件夹
│   │       │   └── StudentForm.jsx # 学生表单组件
│   │       └── apis/              # API 文件夹
│   │           ├── fetch.js      # 获取数据
│   │           ├── update.js      # 更新数据
│   │           └── delete.js      # 删除数据
│   ├── App.jsx                    # 应用入口文件
│   └── index.jsx                  # React 入口文件
├── public/                        # 静态资源目录
├── package.json                   # 项目配置文件
├── tsconfig.json                  # TypeScript 配置文件
└── README.md                      # 项目说明文件
```
目录结构说明：
1. 每个页面一个文件夹，在文件夹中有一个主文件index.jsx，一个components文件夹，一个apis文件夹。例如上面的student-info。
2. 封装的组件定义一个jsx文件，放在components中。
3. 每个接口定义一个js文件，放在apis中。
