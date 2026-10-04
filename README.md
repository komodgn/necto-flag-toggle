# NectoFlagToggle

A generic [necto](https://github.com/toss/necto) plugin to **remotely toggle an app's Bool flag** from the necto sidebar.

Useful for anything you want to flip on/off during development — A/B flow switching, feature flags, forcing dark mode, etc. Display strings and value read/write are injected, so it is not tied to any specific app.

<!-- TODO: add screenshot -->
<img width="1001" height="828" alt="스크린샷 2026-10-04 오후 3 43 21" src="https://github.com/user-attachments/assets/a15442a7-5d4e-4102-8251-a669eae2cfa8" />

## What's inside

- **Device plugin** (`NectoFlagTogglePlugin`) — registered in the app SDK. Provides get/toggle/enable/disable/reset bridges.
- **Web panel** (`Panel/`) — the toggle UI shown in the sidebar, rendered from the strings the app injects.

## Installation (Swift Package Manager)

```swift
.package(url: "https://github.com/komodgn/necto-flag-toggle.git", from: "0.1.0")
```

Add the NectoFlagTogglePlugin library to your target.
> Depends on the necto SDK (toss/necto). If your app already uses necto, keep the versions compatible.

## Usage

Register it in your necto setup (typically under `#if DEBUG`).
```Swift
import NectoSDK
import NectoFlagTogglePlugin

NectoSDK.register(NectoFlagTogglePlugin(
    config: .init(
        title: "VIP Status",
        onLabel: "Active",
        offLabel: "Standard",
        note: "Simulates premium user perks and UI."
    ),
    read:  { UserSession.isVip },
    write: { UserSession.vipOverride = $0 }
))
NectoSDK.start()
```

### Recommended: an override hook

To make write(nil) "fall back to the original logic", expose the flag as an overridable value.

```Swift
var vipOverride: Bool?             // debug override
var isVip: Bool {
    if let o = vipOverride { return o }
    return /* your original user state logic */
}
```

## Bridge operations

| Operation | Behavior |
|---|---|
| `flag.get` | Get current value → `{ on: Bool }` |
| `flag.toggle` | Flip the value |
| `flag.enable` | Force `true` |
| `flag.disable` | Force `false` |
| `flag.reset` | Clear the override (back to app logic) |
| `flag.config` | Get the panel display strings |

Also callable from the CLI: necto call `necto.device.flag.toggle`

## Building and Development 

Open `NectoFlagToggle.xcodeproj` and run the ExampleApp scheme. The plugin appears in Necto while the example app is connected. To build the web panel after making changes:

```Bash
cd panel
npm install
npm run build
```

> The necto SDK reads the panel resources at registration time, so rebuild the app after changing the panel.

## License

MIT
