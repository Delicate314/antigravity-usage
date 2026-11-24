# Antigravity Usage

macOS 桌面悬浮球，按所选开始时间统计 Antigravity 的本机 token 用量和美元估值。按住球体可以拖动，单击可以修改开始时间。悬浮球每 5 秒更新一次。

## 安装

从 [Releases](https://github.com/QianqiuerQS/antigravity-usage/releases/latest) 按芯片下载 macOS DMG（Apple Silicon 选 arm64，Intel 选 x86_64），双击 DMG，将 Antigravity Usage.app 拖入应用程序。支持 macOS 13 及以上版本的 Apple Silicon 和 Intel Mac。应用内置 Python 运行时，使用发布包无需安装开发者工具。发布包使用临时签名，未经 Apple 公证。

## 查看用量

单击悬浮球，选择「展开用量排行」，可以按模型或会话标题查看 USD 和 token 排行。拖动标题区域可独立移动面板。

应用运行时，打开 [本机用量面板](http://127.0.0.1:18742/) 即可按北京时间筛选并查看各模型明细。程序只读本机 Antigravity 会话库中的用量元数据。多账号共用同一套本地记录，切换账号时可以在悬浮球设置新的统计起点。金额为按模型价格换算的参考值，实际扣款请查阅账号账单。

## 从源码运行

在项目目录运行 `python3 app.py` 打开网页面板。构建需要 Xcode Command Line Tools 和装有 PyInstaller 6.16.0 的 Python 3.12 环境。运行 `./build.sh`，生成的本机架构 DMG 位于 dist 目录。
