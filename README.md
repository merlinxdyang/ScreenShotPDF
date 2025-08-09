# M的电子书制作工具

一个高效的 macOS 电子书制作工具，支持智能截屏、自动翻页和批量生成 PDF。

[GitHub release](https://img.shields.io/github/v/release/username/ScreenshotTool)
[Platform](https://img.shields.io/badge/platform-macOS-blue)
[Swift](https://img.shields.io/badge/swift-5.0+-orange)
[License](https://img.shields.io/badge/license-MIT-green)

## 🎬 演示视频

<div align="center">

[![M的电子书制作工具演示](https://img.youtube.com/vi/qS2MCh3Sc5g/0.jpg)](https://www.youtube.com/watch?v=qS2MCh3Sc5g "点击观看演示视频")

*点击上方图片观看完整功能演示*

</div>

> **💡 提示**：视频展示了从截屏设置到PDF生成的完整流程，建议先观看以快速了解工具使用方法。

---


## 📖 项目简介

这是 Merlin 同学在 AI 指导下开发的第一个 macOS 应用程序。该工具专为电子书制作而设计，能够帮助用户快速将网页、PDF 或任何屏幕内容转换为高质量的 PDF 电子书。

## ✨ 主要功能

### 🎯 精确区域截屏
- 自定义截屏区域选择
- 实时预览截屏区域
- 高分辨率图像捕获

### 🔄 智能自动翻页
- 支持多种翻页方式（键盘快捷键、鼠标滚轮等）
- 可配置翻页间隔时间
- 智能等待页面加载

### ⚡ 多种速度模式
- **慢速模式**：3秒间隔，适合复杂页面
- **中速模式**：2秒间隔，平衡速度与稳定性
- **快速模式**：1秒间隔，快速批量处理

### 📁 批量文件管理
- 自动创建时间戳文件夹
- 批量重命名功能
- 支持文件预览和删除

### 📄 PDF 自动生成
- 一键将所有截图合并为 PDF
- 保持图片原始分辨率
- 自动优化文件大小

## 🚀 快速开始

### 系统要求
- macOS 12.0 或更高版本
- Xcode 14.0 或更高版本（如需编译）

### 安装方法

#### 方法一：下载预编译版本
1. 前往 [Releases](https://github.com/username/ScreenshotTool/releases) 页面
2. 下载最新版本的 `.dmg` 文件
3. 双击安装包并将应用拖拽到应用程序文件夹

#### 方法二：从源码编译
```bash
# 克隆仓库
git clone https://github.com/username/ScreenshotTool.git

# 进入项目目录
cd ScreenshotTool

# 使用 Xcode 打开项目
open ScreenshotTool.xcodeproj
```

## 📱 使用方法

### 1. 设置截屏区域
1. 点击"选择区域"按钮
2. 拖拽鼠标选择需要截屏的区域
3. 确认选择区域

### 2. 配置翻页设置
1. 选择翻页速度（慢速/中速/快速）
2. 设置翻页总数
3. 选择翻页方式（支持空格键、方向键等）

### 3. 开始自动截屏
1. 点击"开始截屏"按钮
2. 工具会自动执行以下操作：
   - 截取当前页面
   - 执行翻页操作
   - 等待页面加载
   - 重复直到完成

### 4. 生成 PDF
1. 截屏完成后，点击"生成PDF"
2. 选择保存位置
3. 等待 PDF 生成完成

## 🎮 键盘快捷键

| 快捷键 | 功能 |
|--------|------|
| `⌘ + S` | 开始/停止截屏 |
| `⌘ + R` | 重置区域选择 |
| `⌘ + P` | 生成 PDF |
| `⌘ + D` | 删除所有截图 |
| `⌘ + ,` | 打开设置 |

## 🛠️ 技术架构

### 开发环境
- **语言**：Swift 5.0+
- **框架**：SwiftUI
- **平台**：macOS 12.0+
- **工具**：Xcode 14.0+

### 核心功能模块
```
ScreenshotTool/
├── Views/
│   ├── ContentView.swift          # 主界面
│   ├── AboutView.swift            # 关于页面
│   └── SettingsView.swift         # 设置页面
├── Models/
│   ├── ScreenshotManager.swift    # 截屏管理
│   ├── PDFGenerator.swift         # PDF生成
│   └── FileManager.swift          # 文件管理
├── Utilities/
│   ├── KeyboardSimulator.swift    # 键盘模拟
│   └── RegionSelector.swift       # 区域选择
└── Resources/
    └── Assets.xcassets            # 应用资源
```

### 主要依赖
- **Quartz**：用于截屏功能
- **PDFKit**：用于 PDF 生成
- **Carbon**：用于键盘事件模拟

## 📊 功能特性

| 功能 | 状态 | 描述 |
|------|------|------|
| ✅ 区域截屏 | 已完成 | 支持精确的矩形区域选择 |
| ✅ 自动翻页 | 已完成 | 支持多种翻页方式 |
| ✅ 批量处理 | 已完成 | 支持批量截屏和文件管理 |
| ✅ PDF 生成 | 已完成 | 一键生成高质量 PDF |
| ✅ 多速度模式 | 已完成 | 三种不同的截屏速度 |
| 🚧 云端同步 | 开发中 | 支持 iCloud 同步 |
| 📋 文本识别 | 计划中 | OCR 文本识别功能 |

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

### 开发环境设置
1. Fork 这个仓库
2. 创建你的功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交你的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开一个 Pull Request

### 代码规范
- 遵循 Swift 官方代码规范
- 使用有意义的变量和函数名
- 添加适当的注释
- 确保代码通过所有测试

## 📝 更新日志

### v1.2 (2025-01-09)
- ✅ 增加了关于页面
- ✅ 优化了用户界面
- ✅ 修复了截屏区域选择的问题
- ✅ 改进了 PDF 生成速度

### v1.1 (2025-01-05)
- ✅ 添加了多速度模式
- ✅ 改进了文件管理功能
- ✅ 优化了内存使用

### v1.0 (2025-01-01)
- 🎉 首次发布
- ✅ 基本截屏功能
- ✅ PDF 生成功能

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 👨‍💻 作者

**Merlin** - *初学者开发者* 

- 这是我在 AI 指导下完成的第一个 macOS 应用
- 如有问题或建议，欢迎提交 Issue

## 🙏 致谢

- 感谢 AI 助手在开发过程中的指导
- 感谢 SwiftUI 社区的支持和资源
- 感谢所有测试用户的反馈

## 📞 支持

如果你喜欢这个项目，请给它一个 ⭐️！

有问题？欢迎：
- 提交 [Issue](https://github.com/username/ScreenshotTool/issues)
- 发送邮件至：merlinyang【AT】gmail.com
- 关注项目获取最新更新

---

<p align="center">
  <strong>使用 SwiftUI 和 ❤️ 制作</strong>
</p>
