# Novax 跨项目共享指引

> 本文档面向开发者和 Cursor AI，是 Shard 和 TapLog 两个项目之间代码共享与协作的完整指南。

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
           │ SPM 依赖                 │ go get
    ┌──────┴──────┐            ┌──────┴──────┐
    │   Shard     │            │   TapLog    │
    │  (Vault)    │            │             │
    ├─────────────┤            ├─────────────┤
    │ Swift UI    │            │ Swift UI    │
    │  (Xcode)    │            │  (Xcode)    │
    ├─────────────┤            ├─────────────┤
    │ Go Mobile   │            │ Go Mobile   │
    │ vault.go    │            │ taplog.go   │
    ├─────────────┤            ├─────────────┤
    │ P2P Seeds   │            │ FastAPI     │
    │ (服务器3-8,10)│           │ (服务器9)    │
    └─────────────┘            └─────────────┘
```

---

## 2. 已共享的组件清单

### 2.1 NovaxKit (Swift)

| 模块 | 组件 | 说明 | Shard 用 | TapLog 用 |
|------|------|------|----------|-----------|
| **NovaxMobileBridge** | `MobileBridge.parseJSON(_:)` | 统一解析 Go Mobile JSON 返回 | ✅ VaultManager | ✅ TapLogManager |
| | `MobileResult<T>` | 泛型结果包装 `{"ok":true/false}` | 可选 | 可选 |
| | `novaxLog(_:_:_:)` | 统一 debug 日志（Release 自动静默） | ✅ vaultLog | 可用 |
| **NovaxUI** | `FloatingTabBar` | 磨砂浮动 TabBar | ✅ MainTabView | ✅ MainTabView |
| | `NovaxTab` | TabBar 数据模型 | ✅ | ✅ |
| | `NovaxTapButtonStyle` | 按压缩放按钮样式 | 可用 | ✅ TodayView |
| | `NovaxCardButtonStyle` | 卡片按压效果 | 可用 | 可用 |
| | `NovaxEmptyStateView` | 空状态占位（图标+标题+副标题） | 可用 | ✅ TodayView |
| | `NovaxCard` | 圆角阴影卡片容器 | 可用 | 可用 |
| **NovaxSecurity** | `JailbreakDetector` | 越狱检测 | ✅ VaultApp | 可用 |
| | `AntiDebug` | 反调试检测 | ✅ VaultApp | 可用 |
| | `ScreenProtection` | 录屏/截屏保护遮罩 | ✅ VaultApp | ✅ TapLogApp |
| | `SecureClipboard` | 自动过期剪贴板 | ✅ | 可用 |
| | `KeychainHelper` | Keychain 通用读写封装 | ✅ Security.swift | 可用 |
| **NovaxUtils** | `NovaxDate` | 日期工具（todayString, ISO8601） | 可用 | ✅ TapLogManager, TodayView |
| | `NovaxDevice` | 设备 ID、平台 | 可用 | 可用 |
| | `NovaxHex` | hex 编解码 | ✅ Security.swift | 可用 |

### 2.2 novax-common (Go)

| 包 | 函数 | 说明 | Shard 用 | TapLog 用 |
|----|------|------|----------|-----------|
| **bridge** | `OkJSON(data)` | 返回 `{"ok":true, ...}` | ✅ vault.go | ✅ taplog.go |
| | `ErrJSON(msg)` | 返回 `{"ok":false, "error":"..."}` | ✅ vault.go | ✅ taplog.go |
| | `ParseJSON(s)` | JSON 字符串 → map | 可用 | 可用 |
| | `AuthedGet(url, path, token)` | 带 Bearer 的 GET | 可用 | ✅ taplog.go |
| | `AuthedPost(url, path, token, body)` | 带 Bearer 的 POST | 可用 | ✅ taplog.go |
| | `KVStore` | SQLite KV 存储 | 可用 | ✅ taplog.go |
| **crypto** | `GenerateID()` | UUID 风格随机 ID | 可用 | ✅ taplog.go |
| | `RandomBytes(n)` | 安全随机字节 | 可用 | 可用 |

---

## 3. 建议复用但尚未提取的代码

以下是两个项目中存在的重复模式，**建议未来提取到共享层**：

### 3.1 Swift 端

| 候选组件 | 当前位置 | 提取目标 | 优先级 |
|----------|----------|----------|--------|
| `AccountManager` 基类 | Shard `VaultApp.swift` | NovaxKit/NovaxAuth | 中 — TapLog 目前用设备登录，后续加社交登录时需要 |
| Apple/Google/Facebook 登录封装 | Shard 已实现 | NovaxKit/NovaxAuth | 中 — 同上 |
| 隐私屏（后台模糊遮罩） | Shard `VaultApp.swift` `.overlay` | NovaxKit/NovaxSecurity 或 NovaxUI | 低 — 逻辑简单但值得统一 |
| PrettyUI 主题预设 | Shard `VaultApp.swift` `.vault` | NovaxKit/NovaxUI | 低 — 各 App 配色不同 |
| 生物识别认证 | Shard `VaultManager.authenticateWithBiometrics` | NovaxKit/NovaxSecurity | 中 — TapLog 未来可能需要 |
| 网络状态监听 | 两项目均无 | NovaxKit/NovaxUtils | 中 — 两项目都需要离线检测 |

### 3.2 Go 端

| 候选组件 | 当前位置 | 提取目标 | 优先级 |
|----------|----------|----------|--------|
| SQLite 迁移管理器 | TapLog `createTables()` | novax-common/bridge | 低 — 各项目表结构不同 |
| 离线队列 + 重试 | TapLog `syncTapToServer()` | novax-common/bridge | 高 — 通用的本地写→异步同步模式 |
| P2P 密钥管理 | Shard `loadOrCreateP2PKey()` | novax-common/crypto | 低 — 仅 Shard 用 P2P |

---

## 4. 新功能共享流程

当你在一个项目中完成了通用功能，按照以下流程让另一个项目也能用上：

### 4.1 判断是否应该共享

```
                     这个功能是否只有一个项目用？
                              │
                     ┌────── YES ──────┐
                     │                  │
                 保留在项目内        不需要共享
                     │
                     NO
                     │
              两个项目都可能用？
                     │
                    YES
                     │
           ┌─ Swift 代码 ──── 提取到 NovaxKit
           │
           └─ Go 代码 ─────── 提取到 novax-common
```

**共享的标准：**
- 与具体业务无关的工具代码（日期、网络、加密、UI 组件）→ **必须共享**
- 两个项目结构相似的模式代码（Manager 状态机、TabBar 配置）→ **建议共享**
- 与具体业务强相关的逻辑（Shard 的 P2P 分片、TapLog 的图标键盘）→ **不共享**

### 4.2 提取到 NovaxKit (Swift)

```bash
# 1. 在 NovaxKit 仓库中添加新文件
cd /opt/NovaxKit
# 决定放入哪个模块（MobileBridge / UI / Security / Utils）
# 如果是全新类别，在 Package.swift 中新增 target

# 2. 写代码，注意：
#    - 所有类型/函数加 public
#    - 不依赖 Mobile framework（那是各项目私有的）
#    - 不硬编码任何项目专属值（颜色、URL、service name 等用参数传入）

# 3. 提交并推送
git add -A && git commit -m "Add XXX to NovaxYYY" && git push

# 4. 在使用方项目的 Xcode 中更新 SPM 版本
#    File → Packages → Update to Latest Package Versions

# 5. 更新 SHARED_CHANGELOG.md
```

### 4.3 提取到 novax-common (Go)

```bash
# 1. 在 novax-common 仓库中添加或修改
cd /opt/novax-common
# 放入 bridge/ 或 crypto/，或新建包目录

# 2. 函数名首字母大写（导出）
# 3. go build ./... 验证通过

# 4. 提交并推送
git add -A && git commit -m "Add XXX to bridge" && git push

# 5. 在使用方项目中更新依赖
cd /opt/taplog          # 或 /opt/novax_trader/vault-core
go get github.com/beckham23zx/novax-common@latest
go mod tidy

# 6. 更新 SHARED_CHANGELOG.md
```

### 4.4 更新 SHARED_CHANGELOG.md

**每次共享操作后必须更新。** 这是两个项目的 Cursor AI 相互感知的唯一桥梁。

格式：
```markdown
## YYYY-MM-DD — 简短描述

### [项目名] 变更
- 具体做了什么

### 新增共享组件
- 组件名：一句话说明 + import 方式 + 示例用法
```

---

## 5. 各项目独有的部分（不共享）

### Shard 独有

| 组件 | 原因 |
|------|------|
| P2P 网络层 (libp2p) | Shard 专用的分布式存储架构 |
| Shamir 分片加密 | Shard 专用的秘密分割算法 |
| VaultEngine | Shard 核心加密引擎 |
| 种子节点管理 | Shard 专用网络拓扑 |
| EntryCategory / FieldDef | Shard 专用的数据分类体系 |
| 恢复密钥 / 账号关联 | Shard 专用的身份系统 |

### TapLog 独有

| 组件 | 原因 |
|------|------|
| 图标系统 (31 icons) | TapLog 专用的生活记录图标 |
| 时间段逻辑 (breakfast/morning/...) | TapLog 专用的一天分段 |
| 星星奖励系统 | TapLog 专用的游戏化激励 |
| 商店 (icon packs / themes) | TapLog 专用的变现系统 |
| 体重/睡眠记录 | TapLog 专用的健康模块 |
| FastAPI 服务端 | TapLog 专用的后端 (服务器 9) |

---

## 6. 开发工作流速查

### 日常开发：我在 Shard 写了个好用的工具

1. 自问：TapLog 也可能用吗？
2. 如果是 → 提取到 NovaxKit 或 novax-common（见 §4.2 / §4.3）
3. 更新 `SHARED_CHANGELOG.md`
4. 在 TapLog 项目中 `import` 并使用

### 日常开发：我在 TapLog 写了个好用的工具

同上，方向反过来。

### 共享库升级：我改了 NovaxKit 的一个 bug

1. 在 NovaxKit 中修复并 push
2. **两个项目都需要更新 SPM**：Xcode → File → Packages → Update
3. 在 `SHARED_CHANGELOG.md` 记录 bugfix

### Go 共享库升级

1. 在 novax-common 中修复并 push
2. **两个项目都需要 `go get ... @latest`**
3. 记录 changelog

---

## 7. 目录速查

```
/opt/NovaxKit/                     ← 共享 Swift 包
├── Package.swift
├── SHARED_CHANGELOG.md            ← 项目间信息桥
├── GUIDE.md                       ← 本文档
└── Sources/
    ├── NovaxMobileBridge/          ← Go Mobile 桥接
    ├── NovaxUI/                   ← 共享 UI
    ├── NovaxSecurity/             ← 安全工具
    └── NovaxUtils/                ← 通用工具

/opt/novax-common/                 ← 共享 Go 模块
├── go.mod
├── bridge/                        ← JSON / HTTP / KV
└── crypto/                        ← 随机 ID

/opt/novax_trader/vault-core/      ← Shard 项目
├── mobile/vault.go                ← Go Mobile 层 (import novax-common)
└── ios/Vault/Vault/               ← Swift 客户端 (import NovaxKit)

/opt/taplog/                       ← TapLog 项目
├── mobile/taplog.go               ← Go Mobile 层 (import novax-common)
├── ios/TapLog/TapLog/             ← Swift 客户端 (import NovaxKit)
└── app/                           ← FastAPI 服务端
```

---

## 8. 给 Cursor AI 的指令

> 在任一项目中工作时，如果你要写以下类型的代码，**先检查共享库是否已有**：
>
> - JSON 解析 → `MobileBridge.parseJSON` / `bridge.OkJSON`
> - HTTP 请求 → `bridge.AuthedGet` / `bridge.AuthedPost`
> - 日期格式化 → `NovaxDate`
> - 随机 ID → `ncrypto.GenerateID()`
> - KV 存储 → `bridge.KVStore`
> - Keychain → `KeychainHelper`
> - 按钮样式 → `NovaxTapButtonStyle`
> - TabBar → `FloatingTabBar`
> - 空状态视图 → `NovaxEmptyStateView`
> - 安全检查 → `JailbreakDetector` / `AntiDebug` / `ScreenProtection`
>
> 如果你做了一个通用功能，请主动提议：「这个功能可以提取到 NovaxKit/novax-common 供另一个项目复用。」
>
> 做完共享操作后，务必更新 `SHARED_CHANGELOG.md`。
