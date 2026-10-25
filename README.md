# orbisV Hub
> A lightweight, universal script hub for Roblox. Works on almost any executor.

![Version](https://img.shields.io/badge/version-0.1-blue)
![Status](https://img.shields.io/badge/status-working-green)
![Key](https://img.shields.io/badge/key-not_required-brightgreen)

## About
**orbisV Hub** is a universal script hub designed to be lightweight and stable. It doesn't rely on dangerous `hookmetamethod` exploits, making it less likely to crash your game. It uses safe, surgical hooks (`hookfunction` and `getconnections`) to provide features across almost any Roblox game.

Built with [WindUI](https://github.com/Footagesus/WindUI) for a clean and modern interface.

## Features (TODO!)

### Player Mods
- **God Mode** (Infinity Health)
- **WalkSpeed** & **JumpPower** sliders
- **Fly** (with adjustable speed)
- **Noclip**
- **Infinite Jump**
- **Anti-Ragdoll** & **Anti-Fling**

### Visuals
- **Player ESP** (Highlight)
- **Fullbright** (Better visibility in dark maps)

### Teleportation
- **Ctrl + Click Teleport** (Click anywhere to teleport)
- **Teleport to Player** (Enter username to teleport directly to them)

### Utility
- **Server Hop** (Find a new server)
- **Rejoin Server**
- **Reset Character**

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ТВОЙ_НИК/orbisV-Hub/main/orbisV.lua"))()
