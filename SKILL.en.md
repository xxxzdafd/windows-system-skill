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
| "computer is slow/laggy/CPU high" | [process.md](references/process.md) |
| "network down/cant connect/firewall" | [network.md](references/network.md) |
| "disk full/cant delete file" | [disk.md](references/disk.md) |
| "BSOD/error/crash" | [event.md](references/event.md) |
| "whats installed/update/uninstall" | [manage.md](references/manage.md) |
| "no permission/add user" | [user.md](references/user.md) |
| "edit registry/search registry" | [registry.md](references/registry.md) |
| "what system/how much RAM/hardware" | [system.md](references/system.md) |
| "quick settings/HDR/power mode/dark mode/volume" | [quick-settings.ps1](references/quick-settings.ps1) |

## Safety Rules
- check for `⚠️` prefix = destructive. Always confirm with user before running.
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
| "computer is slow" | `gps \| sort cpu -desc \| select -f 10` → `Get-Counter "\Processor(_Total)\% Processor Time"` → `gps \| sort ws -desc \| select -f 5` |
| "no internet" | `Test-Connection 8.8.8.8 -Count 2` → `Resolve-DnsName google.com` → `Get-NetRoute \| Where DestinationPrefix -eq '0.0.0.0/0'` → `Get-NetFirewallProfile \| Select Name,Enabled` |
| "disk full" | `Get-PSDrive -PSProvider FileSystem \| Select Name,@{N='FreeGB';E={[int]($_.Free/1GB)}},@{N='Used%';E={[math]::Round((1-$_.Free/($_.Used+$_.Free))*100,1)}}` |
| "BSOD/crash" | `Get-WinEvent -FilterHashtable @{LogName='System';ID=1001,1074,6008,41} -MaxEvents 10 \| Select TimeCreated,Id,Message` |
| "app wont open" | `Get-WinEvent -FilterHashtable @{LogName='Application';Level=1,2} -MaxEvents 20` → `Get-Process -Name "appname" -ErrorAction 0` |
| "slow boot" | `Get-CimInstance Win32_StartupCommand \| Select Name,Command,Location` → `Get-Service \| Where StartType -eq 'Automatic' -and Status -ne 'Running'` |
| "port in use" | `Get-NetTCPConnection \| Where State -eq 'Listen' \| Select LocalPort,@{N='Proc';E={(gps -Id \$_.OwningProcess -ErrorAction 0).ProcessName}} \| Sort LocalPort` |
| "WiFi wont connect" | `netsh wlan show interfaces` → `netsh wlan show networks` → `ipconfig /flushdns` |
| "file cant be deleted" | `Get-Process \| Where { \$_.Modules.FileName -like "*filename*" }` → `icacls "path"` → `Get-Acl "path" \| Select Owner` |
| "forgot user password" | `net user username *` (run as admin, sets new password) |

## Before Destructive Operations
Run this to create a restore point (admin required):
```
Checkpoint-Computer -Description "Before change at $(Get-Date)" -RestorePointType MODIFY_SETTINGS
```
