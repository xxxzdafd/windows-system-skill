---
name: windows-system
description: Use when managing, troubleshooting, or inspecting Windows systems — processes, services, disk, network, registry, users, event logs, updates, or system configuration. Covers PowerShell-native commands for system administration.
---

# Windows System Skill

## Overview
PowerShell-native Windows administration — inspect and control every major subsystem. Commands are production-ready one-liners, usable as-is.

## Quick Symptom → File Map

| If user says... | Open this file |
|----------------|----------------|
| "电脑卡/慢/CPU高" | [process.md](references/process.md) |
| "网络不通/掉线/防火墙" | [network.md](references/network.md) |
| "磁盘满了/文件删不掉" | [disk.md](references/disk.md) |
| "蓝屏/报错/崩溃" | [event.md](references/event.md) |
| "装了什么/更新/卸载" | [manage.md](references/manage.md) |
| "用户权限不够/加人" | [user.md](references/user.md) |
| "改注册表/搜注册表" | [registry.md](references/registry.md) |
| "啥系统/多少内存/硬件" | [system.md](references/system.md) |
| "快速设置/HDR/电源/深色模式/音量" | [quick-settings.ps1](references/quick-settings.ps1) |

## Safety Rules
- `⚠️` prefix = destructive. Always confirm with user before running.
- Add `-WhatIf` to preview before write operations
- Admin operations require elevated PowerShell
- Registry/system changes should have a restore point first
- Before UI automation (SendKeys): always switch IME to English first
- Before killing processes/services: confirm with user AND verify the process name

## Recommended Workflow
1. Identify symptom → open matching reference file
2. Run diagnostic commands to confirm root cause
3. Propose fix to user, confirm, then execute
4. Verify fix and report result

## Quick Diagnosis Chains

| Symptom | Run this first |
|---------|---------------|
| "电脑卡/慢" | `gps \| sort cpu -desc \| select -f 10` → `Get-Counter "\Processor(_Total)\% Processor Time"` → `gps \| sort ws -desc \| select -f 5` |
| "上不了网" | `Test-Connection 8.8.8.8 -Count 2` → `Resolve-DnsName google.com` → `Get-NetRoute \| Where DestinationPrefix -eq '0.0.0.0/0'` → `Get-NetFirewallProfile \| Select Name,Enabled` |
| "磁盘满了" | `Get-PSDrive -PSProvider FileSystem \| Select Name,@{N='FreeGB';E={[int]($_.Free/1GB)}},@{N='Used%';E={[math]::Round((1-$_.Free/($_.Used+$_.Free))*100,1)}}` |
| "蓝屏/崩溃" | `Get-WinEvent -FilterHashtable @{LogName='System';ID=1001,1074,6008,41} -MaxEvents 10 \| Select TimeCreated,Id,Message` |
| "某应用打不开" | `Get-WinEvent -FilterHashtable @{LogName='Application';Level=1,2} -MaxEvents 20` → `Get-Process -Name "appname" -ErrorAction 0` |
| "开机慢" | `Get-CimInstance Win32_StartupCommand \| Select Name,Command,Location` → `Get-Service \| Where StartType -eq 'Automatic' -and Status -ne 'Running'` |
| "端口被占用" | `Get-NetTCPConnection \| Where State -eq 'Listen' \| Select LocalPort,@{N='Proc';E={(gps -Id \$_.OwningProcess -ErrorAction 0).ProcessName}} \| Sort LocalPort` |
| "WiFi连不上" | `netsh wlan show interfaces` → `netsh wlan show networks` → `ipconfig /flushdns` |
| "文件删不掉" | `Get-Process \| Where { \$_.Modules.FileName -like "*filename*" }` → `icacls "path"` → `Get-Acl "path" \| Select Owner` |
| "用户密码忘了" | `net user username *` (管理员运行，可设新密码) |

## Before Destructive Operations
Run this to create a restore point (admin required):
```
Checkpoint-Computer -Description "Before change at $(Get-Date)" -RestorePointType MODIFY_SETTINGS
```
