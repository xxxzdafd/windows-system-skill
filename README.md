# windows-system-skill

PowerShell-native Windows system administration skill for [OpenCode](https://opencode.ai).

## What is it?

An OpenCode skill that lets AI assistants manage, troubleshoot, and inspect Windows systems using native PowerShell commands. Covers processes, services, disk, network, registry, users, event logs, updates, and system configuration.

## Quick Start

1. Install the skill in OpenCode
2. Tell the AI: "电脑卡了" or "网络不通" or "磁盘满了"
3. The AI opens the matching reference file and runs diagnostic commands

## Structure

| Path | Description |
|------|-------------|
| SKILL.md | Entry point, symptom-to-command mapping |
| eferences/process.md | Process inspection and management |
| eferences/disk.md | Disk usage and file operations |
| eferences/network.md | Network diagnostics and firewall |
| eferences/event.md | Event log and crash analysis |
| eferences/manage.md | Software and update management |
| eferences/user.md | User and permission management |
| eferences/registry.md | Registry operations |
| eferences/system.md | System information and hardware |

## License

MIT