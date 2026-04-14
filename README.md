# Hourglass

> 使用前请先准备好你的升降桌，以及一个方便翻转与固定手机的手机支架。

一个面向 iPhone 的坐姿 / 站立循环计时器。  
它把“番茄钟”和“翻转沙漏”的交互结合在一起：每个阶段结束后，用户翻转手机，应用自动进入下一阶段。

## 项目功能

- 支持坐姿与站立两个阶段的循环计时
- 支持开始、暂停、继续、跳过阶段和重置
- 阶段结束后通过手机翻转手势进入下一阶段
- 支持历史记录与按天统计
- 支持保存本地设置与历史会话
- 支持 Live Activity / Dynamic Island 展示当前阶段和倒计时
- 支持声音提示与震动反馈

## 适用场景

- 久坐办公时的坐站交替提醒
- 简单的专注节奏控制
- 需要低打扰、抬手即用的个人计时工具

## 简要实现方式

项目使用 SwiftUI 构建界面，整体结构是 `View + ViewModel + Service`：

- `TimerViewModel` 负责核心状态流转，包括开始、暂停、恢复、阶段完成、翻转后切换到下一阶段
- `MotionManager` 基于 `CoreMotion` 检测设备翻转，在阶段完成后触发下一轮计时
- `PersistenceManager` 使用 `UserDefaults + Codable` 持久化设置和历史会话
- `LiveActivityManager` 基于 `ActivityKit` 同步锁屏和灵动岛状态
- `HistoryViewModel` 负责按天聚合坐姿时长、站立时长和完整循环数
- Widget Target 使用 `ActivityConfiguration` 实现 Live Activity UI

当前主界面已经具备完整的计时交互，阶段、时间和状态流转是可运行的。  
项目中还预留了更完整的沙漏动画实现，包括：

- `Lottie` 动画封装
- 自定义沙漏玻璃、沙粒和高光资源

不过这部分视觉实现目前还没有接入主界面，主页面暂时仍使用简化的沙漏符号 / Emoji 表现。

## 当前开发情况

截至 2026-04-14，这个项目已经完成了一个可运行的第一版，核心功能基本齐全：

- 计时主流程已完成
- 阶段切换与翻转交互已完成
- 设置页与历史页已完成
- Live Activity / Dynamic Island 已完成
- 本地数据持久化已完成
- Xcode 工程可以在 iOS Simulator 上成功构建

我在当前代码里也看到一些还可以继续完善的地方：

- `soundEnabled` 设置项已经存在，但声音播放目前没有根据这个开关做条件控制
- `flipSensitivity` 已写入设置模型，但当前翻转检测逻辑还没有实际使用它
- 自定义沙漏视觉组件和 Lottie 封装尚未接入主界面
- 仓库里暂时没有自动化测试
- 仓库首页此前没有 README，目前这份文档是根据现有代码补充的第一版说明

## 项目结构

```text
Hourglass/
├── Hourglass/                # App 主工程
│   ├── Models/               # 状态模型、设置、会话记录
│   ├── Services/             # 动作感应、声音、持久化、Live Activity
│   ├── ViewModels/           # 计时与历史的状态管理
│   └── Views/                # 主界面、设置页、历史页、沙漏视觉组件
├── HourglassShared/          # App 与 Widget 共享的 Activity Attributes
├── HourglassWidget/          # Live Activity / Dynamic Island Widget
└── Hourglass.xcodeproj       # Xcode 工程
```

## 运行方式

1. 使用 Xcode 打开 `Hourglass.xcodeproj`
2. 选择 `Hourglass` Scheme
3. 在 iPhone 模拟器或真机上运行

命令行构建示例：

```bash
xcodebuild -scheme Hourglass -project Hourglass.xcodeproj -configuration Debug -sdk iphonesimulator build
```

## 开源协议

本项目使用 [The Unlicense](LICENSE)，属于非常开放的协议，基本等同于将代码释放到公有领域。
