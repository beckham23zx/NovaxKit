# Shared Changelog — Shard × TapLog

> 此文件记录两个项目之间的共享信息，帮助 Cursor AI 和开发者了解另一个项目的最新进展。
> 每次在任一项目中做了可被另一个项目复用的改动时，请更新此文件。

---

## 2026-04-14 — 跨项目共享架构建立

### 核心原则

- **Shard 代码不动**。共享库是从 Shard 的优秀实现中复制提取出来的。
- TapLog 作为新项目，从一开始就引用共享库。
- Shard 未来可选择性、渐进地引用共享库，但不强制。

### 新建共享仓库

- **NovaxKit** (`github.com/beckham23zx/NovaxKit`) — Swift Package，四个模块：
  - `NovaxMobileBridge` — `MobileBridge.parseJSON()`, `MobileResult<T>`, `novaxLog()`
  - `NovaxUI` — `FloatingTabBar`, `NovaxTapButtonStyle`, `NovaxCardButtonStyle`, `NovaxEmptyStateView`, `NovaxCard`
  - `NovaxSecurity` — `JailbreakDetector`, `AntiDebug`, `ScreenProtection`, `SecureClipboard`, `KeychainHelper`
  - `NovaxUtils` — `NovaxDate`, `NovaxDevice`, `NovaxHex`

- **novax-common** (`github.com/beckham23zx/novax-common`) — Go Module，两个包：
  - `bridge` — `OkJSON()`, `ErrJSON()`, `ParseJSON()`, `AuthedGet()`, `AuthedPost()`, `KVStore`
  - `crypto` — `GenerateID()`, `RandomBytes()`

### Shard 状态

- **零改动**。所有代码保持原样。
- NovaxKit 的安全模块是从 Shard 的 `Security.swift` 复制提取的。
- NovaxUI 的 FloatingTabBar 是从 Shard 的 `MainTabView.swift` 复制提取的。
- novax-common 的 okJSON/errJSON 是从 Shard 的 `vault.go` 复制提取的。

### TapLog 变更

- Go: `mobile/taplog.go` 引入 `novax-common/bridge` 和 `novax-common/crypto`
  - `okJSON`/`errJSON` → `bridge.OkJSON`/`bridge.ErrJSON`
  - `authedGet`/`authedPost` → `bridge.AuthedGet`/`bridge.AuthedPost`
  - `setKV`/`getKV` → `bridge.KVStore`
  - `generateID` → `ncrypto.GenerateID`
- Swift: `TapLogManager.swift` 使用 `MobileBridge.parseJSON` 和 `NovaxDate`
- Swift: `MainTabView.swift` 使用 `NovaxUI.FloatingTabBar`
- Swift: `TodayView.swift` 使用 `NovaxTapButtonStyle`、`NovaxEmptyStateView`、`NovaxDate`
- Swift: `TapLogApp.swift` 引入 `NovaxSecurity.ScreenProtection`

---

## 2026-04-15 — NovaxUI 新增 GlassCard 和 WrappingHStack

### 新增共享组件

- **NovaxGlassCard** — 毛玻璃卡片容器（thinMaterial + 渐变描边 + 阴影），从 TapLog 的 GlassCard 提取
- **novaxGlassBackground()** — View 扩展，直接给任意 View 加毛玻璃背景
- **NovaxWrappingHStack** — 自动换行 HStack Layout，从 TapLog 的 WrappingHStack 提取

### 来源

- 从 TapLog `Components/GlassCard.swift` 和 `Views/TodayView.swift` 中提取
- Shard 零改动

---

## 模板：如何添加新条目

```
## YYYY-MM-DD — 简短描述

### [项目名] 变更
- 具体改动...

### 新增共享组件
- 组件名：一句话说明
```
