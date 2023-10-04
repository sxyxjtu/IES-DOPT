## 本项目所使用使用前端框架

[![license](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE) 

* [Soybean Admin](https://github.com/honghuangdc/soybean-admin) 是一个基于 Vue3、Vite3、TypeScript、NaiveUI、Pinia 和 UnoCSS 的清新优雅的中后台模版，它使用了最新流行的前端技术栈，内置丰富的主题配置，有着极高的代码规范，基于文件的路由系统以及基于 Mock 的动态权限路由，开箱即用的中后台前端解决方案，也可用于学习参考。

## 部署服务器

前端docke镜像生成，-f指定了Dockerfile文件的路径。

```powershell
docker build -t cnpc -f .\docker\Dockerfile .
```

## 使用说明

### 前端

前端需要下载node.js使用 npm 库安装相关库以及运行相关代码

```
npm install ——————配置环境以及安装相关包（在IES-DOPT文件下的环境运行即可）
```

```
npm run dev ——————运行程序
```

### 后端

初次运行时间可能会有些长，请耐心等待

```
直接运行main.jl文件即可 文件路径：  /julia-simulation-back-end/main.jl
```

