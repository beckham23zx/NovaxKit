# 客户端交接文档

> 发给 Shard 和 TapLog 两个客户端窗口的 Cursor AI，让它们了解新的共享架构并自检。

---

## 背景

我们有两个 iOS 应用：**Shard**（密码保险箱）和 **TapLog**（生活记录）。它们的客户端架构相同：

```
Swift UI (展示层)  →  Go Mobile Framework (逻辑层)  →  服务器
```

两个项目存在大量相同模式的代码：JSON 解析、浮动 TabBar、安全检测、HTTP 请求、KV 存储等。为避免重复开发，我们建了两个共享仓库：

- **NovaxKit** (`github.com/beckham23zx/NovaxKit`) — 共享 Swift Package
- **novax-common** (`github.com/beckham23zx/novax-common`) — 共享 Go Module

**核心原则：Shard 的代码不动。** 共享库是从 Shard 的成熟实现中复制提取出来的。TapLog 作为新项目直接引用共享库。

---

## 一、Shard 客户端

### 仓库地址

```
https://github.com/beckham23zx/Vault.git
```

### 你的状态：无改动

Shard 的所有代码保持原样，没有任何修改。你可以像之前一样正常开发。

### 你需要知道的

1. 你的 `Security.swift` 中的安全组件（越狱检测、反调试、截屏保护、安全剪贴板、Keychain）已被**复制**到 NovaxKit 的 `NovaxSecurity` 模块，供 TapLog 使用
2. 你的 `MainTabView.swift` 中的浮动 TabBar 已被**复制**到 NovaxKit 的 `NovaxUI` 模块
3. 你的 `vault.go` 中的 `okJSON`/`errJSON` 已被**复制**到 novax-common 的 `bridge` 包
4. **以上都是复制，你的代码没有被改动**

### 自检清单

请确认以下内容：

- [ ] `git status` 显示没有未预期的改动（应该干净）
- [ ] `go build ./mobile/` 编译正常
- [ ] 在 Xcode 中 Build 正常
- [ ] 在设备上运行正常

### 未来如何受益

如果未来 NovaxKit 中新增了你也想用的通用组件（比如网络状态监听、生物识别封装），你可以选择性引入：
1. Xcode → File → Add Package Dependencies → `https://github.com/beckham23zx/NovaxKit.git`
2. 只选你需要的模块
3. 逐个文件替换，充分测试

**这完全是自愿的，不强制。**

---

## 二、TapLog 客户端

### 仓库地址

```
https://github.com/beckham23zx/TapLog.git
```

### 拉取最新代码

```bash
cd /你的TapLog本地目录
git pull origin main
```

### 你的状态：已集成共享库

TapLog 的 Go 层和 Swift 层都已改为引用共享库（服务器端已提交推送）。以下是完整的改动清单。

### 改动清单

#### Go 层 (`mobile/taplog.go`)

| 改动 | 之前 | 之后 |
|------|------|------|
| import | `crypto/rand` | `novax-common/bridge` + `novax-common/crypto` |
| HTTP 客户端变量 | `httpClient = &http.Client{...}` | 删除（用 `bridge.HTTPClient`） |
| KV 存储 | 本地 `setKV()`/`getKV()` 函数 | `bridge.KVStore` 结构体 |
| Init 中加载 token | 直接 SQL 查询 | `kvStore.Get("auth_token")` |
| 保存 token | `setKV("auth_token", token)` | `kvStore.Set("auth_token", token)` |
| HTTP 请求 | 本地 `authedGet()`/`authedPost()` | `bridge.AuthedGet()`/`bridge.AuthedPost()` |
| ID 生成 | 本地 `generateID()` 用 `crypto/rand` | 本地 `generateID()` 调用 `ncrypto.GenerateID()` |
| JSON 响应 | 本地 `okJSON()`/`errJSON()` | 本地包装函数调用 `bridge.OkJSON()`/`bridge.ErrJSON()` |

**注意：** `okJSON`/`errJSON`/`generateID`/`jsonParse` 这些函数仍然存在于 taplog.go 中作为本地包装，内部委托给共享库。这是为了保持 API 不变。

#### Swift 层

| 文件 | 改动 |
|------|------|
| `TapLogApp.swift` | 新增 `import NovaxSecurity`；`onAppear` 中加入 `ScreenProtection.shared.startMonitoring()` |
| `TapLogManager.swift` | 新增 `import NovaxMobileBridge` + `import NovaxUtils`；`parseJSON` 改为调用 `MobileBridge.parseJSON`；`todayString` 改为调用 `NovaxDate.todayString()` |
| `MainTabView.swift` | 新增 `import NovaxUI`；整体重写为使用 `FloatingTabBar` + `NovaxTab`（磨砂玻璃浮动标签栏，与 Shard 同款） |
| `TodayView.swift` | 新增 `import NovaxUI` + `import NovaxUtils`；日期显示用 `NovaxDate.todayDisplayString()`；空状态用 `NovaxEmptyStateView`；按钮样式用 `NovaxTapButtonStyle`；删除了本地 `TapButtonStyle` 和 `todayDateString()` |
| `HistoryView.swift` | 无改动 |
| `ShopView.swift` | 无改动 |
| `MeView.swift` | 无改动 |

### 自检清单

请逐项确认：

**Go 层**

- [ ] `go mod tidy` 无错误
- [ ] `go build ./mobile/` 编译通过
- [ ] `go.mod` 中包含 `github.com/beckham23zx/novax-common`
- [ ] `taplog.go` 顶部 import 包含 `bridge` 和 `ncrypto`
- [ ] `taplog.go` 中不再有 `crand "crypto/rand"` 的 import
- [ ] `taplog.go` 中不再有 `httpClient` 变量
- [ ] `taplog.go` 中不再有 `authedGet`/`authedPost`/`setKV`/`getKV` 函数的完整实现（应该已删除）
- [ ] `taplog.go` 底部的 `okJSON`/`errJSON` 是单行包装（调用 `bridge.OkJSON`/`bridge.ErrJSON`）
- [ ] `taplog.go` 的 `generateID` 是单行包装（调用 `ncrypto.GenerateID()`）

**Swift 层**

- [ ] `TapLogApp.swift` 第 3 行：`import NovaxSecurity`
- [ ] `TapLogApp.swift` `.onAppear` 中：`ScreenProtection.shared.startMonitoring()` 在 `manager.initialize()` 之前
- [ ] `TapLogManager.swift` 第 4-5 行：`import NovaxMobileBridge` + `import NovaxUtils`
- [ ] `TapLogManager.swift` 的 `parseJSON` 方法体：`return MobileBridge.parseJSON(str)`
- [ ] `TapLogManager.swift` 的 `todayString` 方法体：`return NovaxDate.todayString()`
- [ ] `MainTabView.swift` 第 2 行：`import NovaxUI`
- [ ] `MainTabView.swift` 使用 `[NovaxTab]` 数组和 `FloatingTabBar` 组件
- [ ] `MainTabView.swift` 隐藏了系统 TabBar：`.toolbar(.hidden, for: .tabBar)`
- [ ] `TodayView.swift` 第 2-3 行：`import NovaxUI` + `import NovaxUtils`
- [ ] `TodayView.swift` 日期显示：`NovaxDate.todayDisplayString()`
- [ ] `TodayView.swift` 空状态：`NovaxEmptyStateView(systemImage:title:subtitle:)`
- [ ] `TodayView.swift` 按钮样式：`.buttonStyle(NovaxTapButtonStyle())`
- [ ] `TodayView.swift` 中**没有**本地 `TapButtonStyle` struct 和 `todayDateString()` func

**Xcode 集成**

- [ ] Xcode 中已添加 SPM 依赖：`https://github.com/beckham23zx/NovaxKit.git` (Branch: main)
- [ ] 勾选了 4 个库：`NovaxMobileBridge`、`NovaxUI`、`NovaxSecurity`、`NovaxUtils`
- [ ] Build 成功无错误
- [ ] 在模拟器或设备上运行正常

### 如果 Xcode 报 "No such module"

SPM 依赖需要在本地 Xcode 中手动添加（服务器上无法做这一步）：
1. 打开 `ios/TapLog/TapLog.xcodeproj`
2. File → Add Package Dependencies
3. 搜索框输入 `https://github.com/beckham23zx/NovaxKit.git`
4. Dependency Rule 选 **Branch** → `main`
5. 勾选全部 4 个产品
6. Add Package
7. Clean Build → Build

---

## 三、所有仓库汇总

| 仓库 | 地址 | 作用 |
|------|------|------|
| **Shard** | `https://github.com/beckham23zx/Vault.git` | Shard/Vault 客户端（不动） |
| **TapLog** | `https://github.com/beckham23zx/TapLog.git` | TapLog 客户端（已集成共享库） |
| **NovaxKit** | `https://github.com/beckham23zx/NovaxKit.git` | Swift 共享包（SPM 依赖） |
| **novax-common** | `https://github.com/beckham23zx/novax-common.git` | Go 共享模块（go get 依赖） |

### 文档索引

| 文件 | 位置 | 内容 |
|------|------|------|
| `GUIDE.md` | NovaxKit 仓库 | 架构全景、共享清单、共享流程、判断标准 |
| `SHARED_CHANGELOG.md` | NovaxKit 仓库 | 两个项目的变更记录、互通信息 |
| `CLIENT_HANDOFF.md` | NovaxKit 仓库 | 本文档（交接 + 自检清单） |
| `README.md` | novax-common 仓库 | Go 模块用法 |

今后开发新的通用功能时，请遵循 `GUIDE.md` 中的共享流程。
