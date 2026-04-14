# Shared Changelog — Shard × TapLog

> 此文件记录两个项目之间的共享信息，帮助 Cursor AI 和开发者了解另一个项目的最新进展。
> 每次在任一项目中做了可被另一个项目复用的改动时，请更新此文件。

---

## 2026-04-14 — 跨项目共享架构建立

### 新建共享仓库

- **NovaxKit** (`github.com/beckham23zx/NovaxKit`) — Swift Package，四个模块：
  - `NovaxMobileBridge` — `MobileBridge.parseJSON()`, `MobileResult<T>`, `novaxLog()`
  - `NovaxUI` — `FloatingTabBar`, `NovaxTapButtonStyle`, `NovaxCardButtonStyle`, `NovaxEmptyStateView`, `NovaxCard`
  - `NovaxSecurity` — `JailbreakDetector`, `AntiDebug`, `ScreenProtection`, `SecureClipboard`, `KeychainHelper`
  - `NovaxUtils` — `NovaxDate`, `NovaxDevice`, `NovaxHex`

- **novax-common** (`github.com/beckham23zx/novax-common`) — Go Module，两个包：
  - `bridge` — `OkJSON()`, `ErrJSON()`, `ParseJSON()`, `AuthedGet()`, `AuthedPost()`, `KVStore`
  - `crypto` — `GenerateID()`, `RandomBytes()`

### Shard (vault-core) 变更

- Go: `mobile/vault.go` 引入 `novax-common/bridge`，`okJSON`/`errJSON` 委托给共享实现
- Swift: `VaultManager.swift` 使用 `NovaxMobileBridge.parseJSON`，`novaxLog` 替代本地日志
- Swift: `Security.swift` 使用 `NovaxSecurity.KeychainHelper` 重构 `DeviceKeychain`/`AccountKeychain`
- Swift: `MainTabView.swift` 使用 `NovaxUI.FloatingTabBar` 替代本地浮动 TabBar
- Swift: 安全模块（越狱检测、反调试、截屏保护、安全剪贴板）全部由 NovaxSecurity 提供

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

## 模板：如何添加新条目

```
## YYYY-MM-DD — 简短描述

### [项目名] 变更
- 具体改动...

### 可复用组件
- 组件名称 + 使用方法
```
