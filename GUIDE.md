# Novax 跨项目共享指引

> 本文档面向开发者和 Cursor AI，是 Shard 和 TapLog 两个项目之间代码共享与协作的完整指南。

---

## 核心原则

> **Shard 是成熟项目，不动它的代码。**
> NovaxKit / novax-common 是从 Shard 的优秀模式中**复制提取**出来的共享库。
> TapLog 是新项目，从一开始就基于共享库构建，直接复用 Shard 的成果。
> Shard 未来**可选择性地、渐进地**引用共享库，但绝不强制改动。

---

## 1. 全局架构图

```
┌─────────────────────────────────────────────────────┐
│                    共享层 (GitHub)                    │
│                                                     │
│  NovaxKit (Swift Package)    novax-common (Go Mod)  │
│  ├─ NovaxMobileBridge        ├─ bridge/json.go      │
│  ├─ NovaxUI                  ├─ bridge/http.go      │
│  ├─ NovaxSecurity            ├─ bridge/kvstore.go   │
│  └─ NovaxUtils               └─ crypto/rand.go      │
└──────────┬──────────────────────────┬───────────────┘
           │                          │
           │ 提取自 Shard（复制，不改 Shard）   │
           │                          │
    ┌──────┴──────┐            ┌──────┴──────┐
    │   Shard     │            │   TapLog    │
    │  (不动)      │            │ (直接引用)   │
    ├─────────────┤            ├─────────────┤
    │ Swift UI    │            │ Swift UI    │
    │ 保持原样     │←── 模式复制 ──→│ import NovaxKit │
    ├─────────────┤            ├─────────────┤
    │ Go Mobile   │            │ Go Mobile   │
    │ 保持原样     │←── 模式复制 ──→│ import novax-common │
    ├─────────────┤            ├─────────────┤
    │ P2P Seeds   │            │ FastAPI     │
    │ (服务器3-8,10)│           │ (服务器9)    │
    └─────────────┘            └─────────────┘
```

---

## 2. 共享库组件清单（全部来源于 Shard 的实现）

### 2.1 NovaxKit (Swift)

| 模块 | 组件 | 来源于 Shard 的哪里 | TapLog 如何用 |
|------|------|-------------------|-------------|
| **NovaxMobileBridge** | `MobileBridge.parseJSON(_:)` | `VaultManager.parseJSON` | `TapLogManager.parseJSON` 直接调用 |
| | `MobileResult<T>` | Shard 的 JSON 解析模式 | 可选，泛型解析 Go 返回 |
| | `novaxLog` / `novaxLogv` | `VaultManager.vaultLog` | TapLog 日志输出 |
| **NovaxUI** | `FloatingTabBar` + `NovaxTab` | `MainTabView.floatingTabBar` | TapLog 的 `MainTabView` |
| | `NovaxTapButtonStyle` | TapLog `TapButtonStyle` | TapLog 按钮样式 |
| | `NovaxCardButtonStyle` | 通用卡片效果 | 两项目通用 |
| | `NovaxEmptyStateView` | 通用空状态模式 | TapLog 空状态占位 |
| | `NovaxCard` | 卡片容器 | 两项目通用 |
| **NovaxSecurity** | `JailbreakDetector` | `Security.swift` 完整复制 | TapLog 越狱检测 |
| | `AntiDebug` | `Security.swift` 完整复制 | TapLog 反调试 |
| | `ScreenProtection` | `Security.swift` 完整复制 | TapLog 截屏保护 |
| | `SecureClipboard` | `Security.swift` 完整复制 | TapLog 安全剪贴板 |
| | `KeychainHelper` | `Security.swift` 通用化封装 | TapLog Keychain 存取 |
| **NovaxUtils** | `NovaxDate` | `TapLogManager.todayString` 等 | TapLog 日期工具 |
| | `NovaxDevice` | 设备信息获取 | TapLog 设备 ID |
| | `NovaxHex` | `VaultManager.hexToData` | TapLog hex 工具 |

### 2.2 novax-common (Go)

| 包 | 函数 | 来源于 Shard 的哪里 | TapLog 如何用 |
|----|------|-------------------|-------------|
| **bridge** | `OkJSON(data)` | `vault.go:okJSON` 完整复制 | `taplog.go` 直接调用 |
| | `ErrJSON(msg)` | `vault.go:errJSON` 完整复制 | `taplog.go` 直接调用 |
| | `ParseJSON(s)` | Go JSON 解析 | `taplog.go` 可用 |
| | `AuthedGet/AuthedPost` | TapLog HTTP 模式提取 | `taplog.go` 直接调用 |
| | `KVStore` | TapLog `setKV/getKV` 提取 | `taplog.go` 直接调用 |
| **crypto** | `GenerateID()` | TapLog `generateID` 提取 | `taplog.go` 直接调用 |
| | `RandomBytes(n)` | 通用随机字节 | 两项目可用 |

---

## 3. Shard 保持不变的理由

- Shard **已上线运行**，代码经过测试和用户验证
- Shard 的 `Security.swift` 包含硬编码的 service name（`com.novax.vault.*`），这些是它私有的
- Shard 的 `VaultManager` 有复杂的 P2P/加密逻辑，牵一发动全身
- **如果未来 Shard 想引用 NovaxKit**，可以渐进地替换，每次只改一小块，充分测试后再合并

---

## 4. TapLog 客户端如何基于共享库工作

TapLog 已经完成了共享库集成，当前状态：

### Go 层 (`mobile/taplog.go`)
```go
import (
    "github.com/beckham23zx/novax-common/bridge"
    ncrypto "github.com/beckham23zx/novax-common/crypto"
)

// 用 bridge.OkJSON / bridge.ErrJSON 替代本地实现
// 用 bridge.AuthedGet / bridge.AuthedPost 替代本地 HTTP 函数
// 用 bridge.KVStore 替代本地 setKV/getKV
// 用 ncrypto.GenerateID() 替代本地 generateID
```

### Swift 层
```swift
// TapLogApp.swift
import NovaxSecurity        // ScreenProtection

// TapLogManager.swift
import NovaxMobileBridge    // MobileBridge.parseJSON
import NovaxUtils           // NovaxDate.todayString()

// MainTabView.swift
import NovaxUI              // FloatingTabBar, NovaxTab

// TodayView.swift
import NovaxUI              // NovaxTapButtonStyle, NovaxEmptyStateView
import NovaxUtils           // NovaxDate.todayDisplayString()
```

---

## 5. 新功能共享流程

### 场景 A：Shard 做了个好功能，TapLog 也想用

```
1. 从 Shard 的代码中【复制】通用部分
2. 放入 NovaxKit 或 novax-common（通用化处理，去掉硬编码）
3. 推送共享库
4. TapLog 更新依赖后直接 import 使用
5. Shard 的代码不动
```

### 场景 B：TapLog 做了个好功能，Shard 也想用

```
1. 判断是否通用（与 TapLog 业务无关）
2. 如果通用 → 提取到 NovaxKit 或 novax-common
3. 推送共享库
4. Shard 可以在未来版本中选择性引入
```

### 场景 C：直接在共享库中开发新通用功能

```
1. 在 NovaxKit 或 novax-common 中直接写
2. 推送
3. TapLog 立即可用
4. Shard 有空时再考虑用
```

### 每次共享后：更新 SHARED_CHANGELOG.md

---

## 6. 各项目独有的部分（不共享）

### Shard 独有
- P2P 网络层 (libp2p)、Shamir 分片加密、VaultEngine
- 种子节点管理、身份解析、恢复密钥
- EntryCategory / FieldDef 数据体系
- AccountManager（Firebase 登录流程）
- PrettyUI 主题配置

### TapLog 独有
- 图标系统 (31 icons)、时间段逻辑
- 星星奖励 / 商店系统
- 体重/睡眠记录
- FastAPI 服务端 (服务器 9)

---

## 7. 判断标准：该不该共享

```
与具体业务无关的工具代码？
  → 必须共享（日期、网络、加密、JSON、UI 基础组件）

两个项目结构相似的模式？
  → 建议共享（Manager 状态机、TabBar、空状态、按钮样式）

与具体业务强相关的逻辑？
  → 不共享（Shard P2P、TapLog 图标键盘）
```

---

## 8. 目录速查

```
/opt/NovaxKit/                     ← 共享 Swift 包（从 Shard 复制提取）
├── Package.swift
├── SHARED_CHANGELOG.md            ← 项目间信息桥
├── GUIDE.md                       ← 本文档
└── Sources/
    ├── NovaxMobileBridge/
    ├── NovaxUI/
    ├── NovaxSecurity/
    └── NovaxUtils/

/opt/novax-common/                 ← 共享 Go 模块
├── go.mod
├── bridge/
└── crypto/

/opt/novax_trader/vault-core/      ← Shard（不动）
├── mobile/vault.go
├── ios/Vault/Vault/Security.swift ← NovaxSecurity 的来源模板
└── ios/Vault/Vault/               ← NovaxUI 的来源模板

/opt/taplog/                       ← TapLog（引用共享库）
├── mobile/taplog.go               ← import novax-common
├── ios/TapLog/TapLog/             ← import NovaxKit
└── app/                           ← FastAPI 服务端
```

---

## 9. 给 Cursor AI 的指令

> **绝对不要修改 Shard 的任何代码来适配共享库。**
>
> 在 TapLog 中工作时，如果要写以下类型的代码，先检查 NovaxKit / novax-common 是否已有：
> - JSON 解析 → `MobileBridge.parseJSON`
> - HTTP 请求 → `bridge.AuthedGet` / `bridge.AuthedPost`
> - 日期格式化 → `NovaxDate`
> - 随机 ID → `ncrypto.GenerateID()`
> - KV 存储 → `bridge.KVStore`
> - Keychain → `KeychainHelper`
> - 按钮样式 → `NovaxTapButtonStyle`
> - TabBar → `FloatingTabBar`
> - 空状态 → `NovaxEmptyStateView`
> - 安全检查 → `JailbreakDetector` / `AntiDebug` / `ScreenProtection`
>
> 如果 NovaxKit 中没有而 Shard 中有，**复制到 NovaxKit**，不要改 Shard。
>
> 做完共享操作后，务必更新 `SHARED_CHANGELOG.md`。
