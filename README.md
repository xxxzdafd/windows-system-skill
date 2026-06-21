# Windows System Skill

PowerShell-native Windows administration skill for AI agents — token-efficient, full coverage, production-ready commands.

给 AI Agent 的 Windows 系统管理技能包。纯 PowerShell，省 token，全覆盖，拿来即用。

## Modules / 模块

| Module | File | Coverage |
|--------|------|----------|
| System | [system.md](references/system.md) | OS/Hardware/BIOS/Environment/Restore |
| Process | [process.md](references/process.md) | Processes/Services/Scheduler/Startup |
| Network | [network.md](references/network.md) | IP/DNS/Firewall/WiFi/Routing/Shares |
| Disk | [disk.md](references/disk.md) | Volumes/Permissions/Symlinks/BitLocker |
| Registry | [registry.md](references/registry.md) | Read/Write/Search/ACL |
| User | [user.md](references/user.md) | Users/Groups/UAC/Audit/Privileges |
| Event | [event.md](references/event.md) | Event Logs/Performance/BlueScreen/Dumps |
| Manage | [manage.md](references/manage.md) | Updates/Programs/WinRM/Boot/Power/UI Automation/OCR/SendKeys |
| Quick Settings | [quick-settings.ps1](references/quick-settings.ps1) | HDR/Power Mode/Dark Mode/Volume/Display Tray Tool |

## Features / 特色

- **10 个诊断链** — "电脑卡/网络断/磁盘满/蓝屏/端口占用"等场景一键排查
- **截图 + OCR** — 安装 Tesseract 后截图转文字
- **UI 自动化** — 鼠标/键盘/窗口控制，含 IME 输入法切换
- **安全网** — ⚠️ 标记危险操作，内置 `-WhatIf` 预览
- **Quick Settings 面板** — 系统托盘一键切换 HDR、电源模式、深色模式、音量、夜间模式。零依赖，纯 PowerShell，右键即开

## Design Principles / 设计原则

- **Every command is runnable as-is** — no assembly required, copy and execute
  **每条命令即用** — 不拼接，不解释，直接跑
- **Pure PowerShell** — object output, AI can filter with `.Where()` / `.Select()`
  **纯 PowerShell** — 输出结构化对象，AI 可二次过滤
- **Token efficient** — ~350 lines covers all core scenarios
  **省 token** — 约 350 行覆盖所有核心场景
- **Safety marked** — `⚠️` prefix for destructive operations
  **安全标记** — `⚠️` 标记破坏性操作，默认带保护

## Quick Start / 快速开始

```powershell
# Clone to your agent's skills directory
git clone https://github.com/xxxzdafd/windows-system-skill.git ~/.config/opencode/skills/windows-system
```

Then tell your agent: "电脑卡了" / "my computer is slow" — it knows which reference to open.

## License / 许可证

MIT
