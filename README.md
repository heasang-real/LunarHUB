<<<<<<< HEAD
# 🌙 LunarHUB

Universal Roblox Script Framework

---

## Description

LunarHUB is a universal Roblox script hub designed to support multiple Roblox experiences through a single codebase.

The goal of this project is to provide game-specific functionality while maintaining a shared framework for UI, configuration, execution, and utility systems.

This repository contains the source code, modules, and assets used by LunarHUB.

---

## Project Goals

* Support multiple Roblox games.
* Maintain a modular architecture.
* Allow rapid feature deployment.
* Minimize duplicated code.
* Keep performance impact low.
* Provide a consistent user experience across supported games.

---

## Architecture

LunarHUB follows a module-based architecture.

```text
LunarHUB
├── Main.lua (메인 파일이다. 실행 시, 이걸 기준으로 시작한다)
├── README.md (너가 읽고 있는 설명서)
├── example.lua (공식 예시)
├── module (Folder) # 여기에는 모듈들의 스크립트가 들어간다. ESP, AimAssist 등 상세 이름으로 들어간다. 각 파일에는 들어가는 모듈의 기능 + UI를 구성하는 코드가 들어가있다. LinoriaLib 기반으로 커스텀 함수를 제작해서 사용하면 더욱 좋다.
│   ├── ESP.lua
│   ├── ESP_Settings.lua
│   ├── AimAssist.lua
│   ├── (...).lua
│
├── games (Folder) # 여기에는 각 게임마다 module 폴더에서 불러올 모듈을 지정하는 파일들이 있다. 즉, 아스널에 들어가고, 아스널 게임 ID인 lua 파일이 있다면 거기서 지정한 모듈들을 불러온다. 만약 여기에 등록되어 있지않다면 게임에서 추방한다. (추방 메시지는 아래 참고)
│   ├── (게임 ID).lua
│   ├── (...).lua
```

### Core

Shared functionality used by every supported game.

Examples:

* Window system
* Tabs
* Buttons
* Toggles
* Keybinds
* Configuration handling
* Notification system

### Kick message
```
[ 🌙 LunarHUB - You are been kicked! ]

- Reason: (코드) / (사유)
ㄴ (해결법)
```

Code: LH-01
└ Reason: This game is not supported.
└ How to fix: Please check the Discord server and join the supported experience.

Code: LH-02
└ Reason: Failed to load required resources.
└ How to fix: Rejoin the game and try again.

Code: LH-03
└ Reason: Script initialization failed.
└ How to fix: Restart Roblox and execute LunarHUB again.

Code: LH-04
└ Reason: Unsupported game version detected.
└ How to fix: Wait for a LunarHUB update or use a supported version.

Code: LH-05
└ Reason: Required game assets are missing.
└ How to fix: Rejoin the experience and allow it to load completely.

Code: LH-06
└ Reason: An unexpected internal error occurred.
└ How to fix: Contact support and provide the error code.

Code: LH-07
└ Reason: Detected an incompatible executor.
└ How to fix: Use a supported executor.

Code: LH-08
└ Reason: Configuration file is invalid.
└ How to fix: Reset LunarHUB settings and try again.

### Games

Game-specific modules.

Each module should only contain functionality required for a specific Roblox experience.

---

## Coding Standards

### Naming

Use descriptive names.

Good:

```lua
local PlayerData
local AutoFarmEnabled
local CharacterController
```

Bad:

```lua
local a
local x
local thing
```

### Functions

Functions should have a single responsibility.

Good:

```lua
local function GetNearestEnemy()
end
```

Avoid large functions that handle multiple unrelated tasks.

### Variables

Avoid global variables whenever possible.

Prefer:

```lua
local Settings = {}
```

Over:

```lua
_G.Settings = {}
```

---

## Module Requirements

Every game module should expose:

```lua
return {
    Name = "Game Name",
    GameId = 0000000000,

    Init = function()
    end
}
```

You need to use this: (Example: https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/refs/heads/main/Example.lua)

```lua
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
```

### Example

```lua
return {
    Name = "Example Game",
    GameId = 123456789,

    Init = function()
        print("Loaded")
    end
}
```

---

## Supported Features

Possible feature categories:

* Auto Farm
* Auto Quest
* ESP
* Teleports
* Player Utilities
* Combat Enhancements
* Farming Utilities
* Quality of Life Tools

Not every game module implements every feature.

---

## Performance Guidelines

* Cache services whenever possible.
* Avoid unnecessary loops.
* Disconnect unused connections.
* Use task.wait() responsibly.
* Prevent memory leaks.

Example:

```lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
```

---

## Error Handling

Use protected calls when interacting with uncertain game data.

Example:

```lua
local Success, Result = pcall(function()
    return SomeFunction()
end)
```

Handle failures gracefully.

---

## AI Instructions

This section is intended for AI assistants analyzing this repository.

### Repository Type

Roblox Universal Script Hub

### Primary Language

Lua (Luau)

### Environment

Roblox Client

### Design Philosophy

* Modular
* Lightweight
* Readable
* Reusable

### When Modifying Code

Prefer:

* Existing utility functions.
* Existing UI components.
* Existing framework patterns.

Avoid:

* Rewriting working systems.
* Introducing unnecessary dependencies.
* Breaking compatibility with existing game modules.

### Code Generation Rules

When generating new code:

1. Follow existing naming conventions.
2. Use local variables whenever possible.
3. Keep modules self-contained.
4. Minimize performance overhead.
5. Maintain readability.
6. Avoid duplicate implementations.

### Output Expectations

Generated code should:

* Be production-ready.
* Be properly indented.
* Be easy to maintain.
* Include comments only when necessary.

---

## Disclaimer

LunarHUB is a framework intended for educational, experimental, and development purposes.

Repository maintainers are responsible for determining how the software is used.
=======
<h1 align="center">🌙 LunarHUB</h1>

<p align="center">
Advanced universal Roblox script powered by LinoriaLib.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/status-public_alpha-8A5CF6?style=for-the-badge" />
  <img src="https://img.shields.io/badge/platform-Roblox-111827?style=for-the-badge&logo=roblox&logoColor=white" />
  <img src="https://img.shields.io/badge/built_with-LinoriaLib-111827?style=for-the-badge" />
</p>

---

## 🌌 About

LunarHUB is a modern multi-game Roblox utility hub focused on performance, clean UI, and universal support.

Built using LinoriaLib, LunarHUB aims to provide a lightweight and polished experience while remaining flexible and constantly expandable.

---

## ✨ Features

- 🌙 Modern LinoriaLib UI
- 🎮 Multi-game support
- ⚡ Fast & lightweight
- 🛠 Universal systems
- 🚀 Frequent updates
- 🔧 Easy to expand
>>>>>>> 8752ab1954966c3cc57b5c1f98f5f912c30f77c4
