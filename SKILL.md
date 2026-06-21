---
name: windows-system
description: Use when managing, troubleshooting, or inspecting Windows systems 鈥?processes, services, disk, network, registry, users, event logs, updates, or system configuration. Covers PowerShell-native commands for system administration.
---

# Windows System Skill

## Overview
PowerShell-native Windows administration 鈥?inspect and control every major subsystem. Commands are production-ready one-liners, usable as-is.

## Quick Symptom 鈫?File Map

| If user says... | Open this file |
|----------------|----------------|
| "鐢佃剳鍗?鎱?CPU楂? | [process.md](references/process.md) |
| "缃戠粶涓嶉€?鎺夌嚎/闃茬伀澧? | [network.md](references/network.md) |
| "纾佺洏婊′簡/鏂囦欢鍒犱笉鎺? | [disk.md](references/disk.md) |
| "钃濆睆/鎶ラ敊/宕╂簝" | [event.md](references/event.md) |
| "瑁呬簡浠€涔?鏇存柊/鍗歌浇" | [manage.md](references/manage.md) |
| "鐢ㄦ埛鏉冮檺涓嶅/鍔犱汉" | [user.md](references/user.md) |
| "鏀规敞鍐岃〃/鎼滄敞鍐岃〃" | [registry.md](references/registry.md) |
| "鍟ョ郴缁?澶氬皯鍐呭瓨/纭欢" | [system.md](references/system.md) |

## Safety Rules
- `鈿狅笍` prefix = destructive. Always confirm with user before running.
- Add `-WhatIf` to preview before write operations
- Admin operations require elevated PowerShell
- Registry/system changes should have a restore point first
- Before UI automation (SendKeys): always switch IME to English first
- Before killing processes/services: confirm with user AND verify the process name

## Recommended Workflow
1. Identify symptom 鈫?open matching reference file
2. Run diagnostic commands to confirm root cause
3. Propose fix to user, confirm, then execute
4. Verify fix and report result

## Quick Diagnosis Chains

| Symptom | Run this first |
|---------|---------------|
| "鐢佃剳鍗?鎱? | `gps \| sort cpu -desc \| select -f 10` 鈫?`Get-Counter "\Processor(_Total)\% Processor Time"` 鈫?`gps \| sort ws -desc \| select -f 5` |
| "涓婁笉浜嗙綉" | `Test-Connection 8.8.8.8 -Count 2` 鈫?`Resolve-DnsName google.com` 鈫?`Get-NetRoute \| Where DestinationPrefix -eq '0.0.0.0/0'` 鈫?`Get-NetFirewallProfile \| Select Name,Enabled` |
| "纾佺洏婊′簡" | `Get-PSDrive -PSProvider FileSystem \| Select Name,@{N='FreeGB';E={[int]($_.Free/1GB)}},@{N='Used%';E={[math]::Round((1-$_.Free/($_.Used+$_.Free))*100,1)}}` |
| "钃濆睆/宕╂簝" | `Get-WinEvent -FilterHashtable @{LogName='System';ID=1001,1074,6008,41} -MaxEvents 10 \| Select TimeCreated,Id,Message` |
| "鏌愬簲鐢ㄦ墦涓嶅紑" | `Get-WinEvent -FilterHashtable @{LogName='Application';Level=1,2} -MaxEvents 20` 鈫?`Get-Process -Name "appname" -ErrorAction 0` |
| "寮€鏈烘參" | `Get-CimInstance Win32_StartupCommand \| Select Name,Command,Location` 鈫?`Get-Service \| Where StartType -eq 'Automatic' -and Status -ne 'Running'` |
| "绔彛琚崰鐢? | `Get-NetTCPConnection \| Where State -eq 'Listen' \| Select LocalPort,@{N='Proc';E={(gps -Id \$_.OwningProcess -ErrorAction 0).ProcessName}} \| Sort LocalPort` |
| "WiFi杩炰笉涓? | `netsh wlan show interfaces` 鈫?`netsh wlan show networks` 鈫?`ipconfig /flushdns` |
| "鏂囦欢鍒犱笉鎺? | `Get-Process \| Where { \$_.Modules.FileName -like "*filename*" }` 鈫?`icacls "path"` 鈫?`Get-Acl "path" \| Select Owner` |
| "鐢ㄦ埛瀵嗙爜蹇樹簡" | `net user username *` (绠＄悊鍛樿繍琛岋紝鍙鏂板瘑鐮? |

## Before Destructive Operations
Run this to create a restore point (admin required):
```
Checkpoint-Computer -Description "Before change at $(Get-Date)" -RestorePointType MODIFY_SETTINGS
```
