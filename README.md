# NovaxKit

Shared Swift Package for [Shard](https://github.com/beckham23zx/vault-core) and [TapLog](https://github.com/beckham23zx/TapLog) iOS clients.

## Modules

| Module | Description |
|--------|-------------|
| **NovaxMobileBridge** | Go Mobile JSON bridge: `parseJSON`, `MobileResult<T>`, `novaxLog` |
| **NovaxUI** | Shared UI components: `FloatingTabBar`, button styles, cards, empty states |
| **NovaxSecurity** | Security utilities: jailbreak detection, anti-debug, keychain, screen protection |
| **NovaxUtils** | Common utilities: date formatting, device info, hex encoding |

## Installation (SPM)

In Xcode: **File → Add Package Dependencies** → enter:

```
https://github.com/beckham23zx/NovaxKit.git
```

Select the modules you need.

## Usage

```swift
import NovaxMobileBridge
import NovaxSecurity
import NovaxUI
import NovaxUtils

// Parse Go Mobile response
let json = MobileBridge.parseJSON(goResult)

// Jailbreak check
if JailbreakDetector.isJailbroken { /* handle */ }

// Floating tab bar
FloatingTabBar(tabs: myTabs, selection: $selected, tintColor: .blue)

// Date helpers
let today = NovaxDate.todayString()  // "2026-04-14"
```
