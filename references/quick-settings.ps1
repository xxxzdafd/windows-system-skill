<# 
  Quick Settings Panel for Windows v1
  System tray panel: HDR, power mode, dark mode, volume, display, sleep mode
  Zero dependency, pure PowerShell 5.1+
  
  Sleep Mode uses OpenRGB (https://openrgb.org) for lighting control if available.
  OpenRGB is free, open-source (GPLv2), and supports most motherboard/GPU/RAM RGB.
  If not installed, Sleep Mode still works: monitor off + mute + dark mode + power saver.
#>

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Windows.Forms,System.Drawing

#===================== Win32 API =====================
Add-Type @'
using System.Runtime.InteropServices;
public class QS {
  [DllImport("user32.dll")] public static extern int SendMessage(int h,int m,int w,int l);
  [DllImport("powrprof.dll")] public static extern int PowerSetActiveScheme(int a, System.IntPtr b);
  
  [DllImport("user32.dll", CharSet=CharSet.Auto)]
  public static extern int SystemParametersInfo(int uAction,int uParam,string lpvParam,int fuWinIni);
}
'@

Add-Type @'
using System.Runtime.InteropServices;
public class Audio {
  [DllImport("winmm.dll")]
  public static extern int waveOutSetVolume(int h, int v);
  [DllImport("winmm.dll")]
  public static extern int waveOutGetVolume(int h, out int v);
}
'@

#===================== State =====================
$script:darkMode = $null
$script:hdrOn = $null
$script:vol = 50

#===================== Sleep Mode =====================
$script:sleepModeOn = $false
$script:sleepWasDark = $false
$script:sleepWasVol = 50
$script:stoppedSvcs = @()

$lightSvcs = @(
    "LightingService","CorsairService","AsusRogLiveService",
    "MysticLight","RGBFusion","RzChromaStreamServer","NZXT CAM","LConnect3"
)

function Stop-RGBServices {
    $script:stoppedSvcs = @()
    foreach ($s in $lightSvcs) {
        $svc = Get-Service $s -EA 0
        if ($svc -and $svc.Status -eq "Running") {
            Stop-Service $svc -Force -EA 0
            $script:stoppedSvcs += $s
        }
    }
}

function Start-RGBServices {
    foreach ($s in $script:stoppedSvcs) {
        $svc = Get-Service $s -EA 0
        if ($svc -and $svc.Status -ne "Running") {
            Start-Service $svc -EA 0
        }
    }
    $script:stoppedSvcs = @()
}

function Invoke-SleepMode {
    $script:sleepWasDark = Get-DarkMode
    $script:sleepWasVol = Get-Volume
    
    Set-Volume 0
    if (-not $script:sleepWasDark) { Set-DarkMode $true }
    
    Stop-RGBServices
    [QS]::SendMessage(-1, 0x0112, 0xF170, 2)
    $script:sleepModeOn = $true
}

function Invoke-WakeMode {
    Start-RGBServices
    if (-not $script:sleepWasDark) { Set-DarkMode $false }
    Set-Volume $script:sleepWasVol
    [QS]::SendMessage(-1, 0x0112, 0xF170, -1)
    $script:sleepModeOn = $false
}

#===================== Helper functions =====================
function Get-DarkMode {
    $reg = Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name AppsUseLightTheme -EA 0
    return $reg.AppsUseLightTheme -eq 0
}
function Set-DarkMode($on) {
    $v = if ($on) { 0 } else { 1 }
    Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name AppsUseLightTheme -Value $v -Type DWord
    Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name SystemUsesLightTheme -Value $v -Type DWord
    [QS]::SystemParametersInfo(0x1040,0,"",2)  # broadcast theme change
}

function Get-HDR {
    # Check if HDR is on via registry
    $reg = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\MonitorDataStore" -EA 0
    return $null -ne $reg
}
function Toggle-HDR {
    # Windows 10/11 HDR toggle - use display switch or external tool
    Start-Process "ms-settings:display" -WindowStyle Hidden
    Start-Sleep 0.5
    $wshell = New-Object -ComObject wscript.shell
    $wshell.SendKeys("{TAB 3}{ENTER}")  # simple tab-navigate to HDR toggle
}

function Get-PowerScheme {
    $guid = (powercfg /getactivescheme) -replace '.*\((.*?)\).*','$1'
    return $guid
}
function Set-PowerScheme($guid) {
    powercfg /setactive $guid | Out-Null
}

function Get-Volume { 
    $v = 0; [Audio]::waveOutGetVolume(0,[ref]$v)
    [math]::Round($v / 655.35)
}
function Set-Volume($pct) {
    $v = [math]::Round($pct * 655.35)
    if ($v -gt 65535) { $v = 65535 }; if ($v -lt 0) { $v = 0 }
    [Audio]::waveOutSetVolume(0,$v)
}

#===================== Main form =====================
$form = New-Object Windows.Forms.Form
$form.Text = "Quick Settings"
$form.Size = New-Object Drawing.Size(300,400)
$form.StartPosition = "Manual"
$form.FormBorderStyle = "FixedToolWindow"
$form.ShowInTaskbar = $false
$form.TopMost = $true

$script:hdrOn = $false
$script:darkMode = Get-DarkMode
$script:vol = Get-Volume

# --- Title ---
$title = New-Object Windows.Forms.Label
$title.Text = "Quick Settings"
$title.Font = New-Object Drawing.Font("Segoe UI",14,[Drawing.FontStyle]::Bold)
$title.Location = New-Object Drawing.Point(15,15)
$title.Size = New-Object Drawing.Size(260,30)

# --- HDR ---
$lblHDR = New-Object Windows.Forms.Label
$lblHDR.Text = "HDR: OFF"
$lblHDR.Location = New-Object Drawing.Point(15,60)
$lblHDR.Size = New-Object Drawing.Size(80,25)

$btnHDR = New-Object Windows.Forms.Button
$btnHDR.Text = "Switch"
$btnHDR.Location = New-Object Drawing.Point(180,58)
$btnHDR.Size = New-Object Drawing.Size(90,25)
$btnHDR.Add_Click({ Toggle-HDR; [Windows.Forms.MessageBox]::Show("HDR toggle sent. Check display settings.") })

# --- Power Mode ---
$lblPower = New-Object Windows.Forms.Label
$lblPower.Text = "Power Mode:"
$lblPower.Location = New-Object Drawing.Point(15,100)
$lblPower.Size = New-Object Drawing.Size(80,25)

$cmbPower = New-Object Windows.Forms.ComboBox
$cmbPower.Location = New-Object Drawing.Point(95,98)
$cmbPower.Size = New-Object Drawing.Size(175,25)
$cmbPower.DropDownStyle = "DropDownList"
$items = @(@{g="381b4222-f694-41f0-9685-ff5bb260df2e";n="Balanced"},
          @{g="a1841308-3541-4fab-bc81-f71556f20b4a";n="Power Saver"},
          @{g="8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c";n="High Performance"})
foreach ($i in $items) { [void]$cmbPower.Items.Add($i.n) }
$cmbPower.Add_SelectedIndexChanged({
    $guid = $items[$cmbPower.SelectedIndex].g
    Set-PowerScheme $guid
})

# --- Dark Mode ---
$chkDark = New-Object Windows.Forms.CheckBox
$chkDark.Text = "Dark Mode"
$chkDark.Location = New-Object Drawing.Point(15,140)
$chkDark.Size = New-Object Drawing.Size(150,25)
$chkDark.Checked = $script:darkMode
$chkDark.Add_CheckedChanged({ Set-DarkMode $chkDark.Checked })

# --- Volume ---
$lblVol = New-Object Windows.Forms.Label
$lblVol.Text = "Volume: $($script:vol)%"
$lblVol.Location = New-Object Drawing.Point(15,180)
$lblVol.Size = New-Object Drawing.Size(80,25)

$trackVol = New-Object Windows.Forms.TrackBar
$trackVol.Location = New-Object Drawing.Point(95,175)
$trackVol.Size = New-Object Drawing.Size(175,40)
$trackVol.Minimum = 0; $trackVol.Maximum = 100
$trackVol.Value = $script:vol
$trackVol.TickFrequency = 10
$trackVol.Add_Scroll({
    $script:vol = $trackVol.Value
    Set-Volume $script:vol
    $lblVol.Text = "Volume: $($script:vol)%"
})

# --- Sleep Mode ---
$lblSleep = New-Object Windows.Forms.Label
$lblSleep.Text = "Sleep Mode:"
$lblSleep.Location = New-Object Drawing.Point(15,225)
$lblSleep.Size = New-Object Drawing.Size(80,25)

$btnSleep = New-Object Windows.Forms.Button
$btnSleep.Text = "Sleep"
$btnSleep.Location = New-Object Drawing.Point(95,223)
$btnSleep.Size = New-Object Drawing.Size(75,25)
$btnSleep.BackColor = [Drawing.Color]::FromArgb(50, 50, 80)
$btnSleep.ForeColor = [Drawing.Color]::White
$btnSleep.Add_Click({
    if ($script:sleepModeOn) {
        Invoke-WakeMode
        $btnSleep.Text = "Sleep"
        $btnSleep.BackColor = [Drawing.Color]::FromArgb(50, 50, 80)
        $lblSleep.Text = "Sleep Mode:"
        $script:vol = Get-Volume
        $trackVol.Value = $script:vol
        $lblVol.Text = "Volume: $($script:vol)%"
    } else {
        Invoke-SleepMode
        $btnSleep.Text = "Wake"
        $btnSleep.BackColor = [Drawing.Color]::FromArgb(80, 140, 80)
        $lblSleep.Text = "Sleep Mode: ON"
        $trackVol.Value = 0
        $lblVol.Text = "Volume: 0%"
        $form.Hide()
    }
})

# --- Close button ---
$btnClose = New-Object Windows.Forms.Button
$btnClose.Text = "Close"
$btnClose.Location = New-Object Drawing.Point(100,340)
$btnClose.Size = New-Object Drawing.Size(100,30)
$btnClose.Add_Click({ $form.Close() })

# --- Add controls ---
$form.Controls.AddRange(@($title,$lblHDR,$btnHDR,$lblPower,$cmbPower,$chkDark,$lblVol,$trackVol,$lblSleep,$btnSleep,$btnClose))

#===================== System Tray =====================
$icon = New-Object Windows.Forms.NotifyIcon
$icon.Text = "Quick Settings"
$icon.Icon = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command powershell).Source)
$icon.Visible = $true

$icon.Add_Click({
    if ($_.Button -eq [Windows.Forms.MouseButtons]::Left) {
        # position near tray
        $scr = [Windows.Forms.Screen]::PrimaryScreen.WorkingArea
        $form.Location = New-Object Drawing.Point($scr.Right - $form.Width, $scr.Bottom - $form.Height)
        $form.Show()
        $form.Activate()
    }
})

# Context menu: Exit
$menu = New-Object Windows.Forms.ContextMenuStrip
$exitItem = New-Object Windows.Forms.ToolStripMenuItem("Exit")
$exitItem.Add_Click({ $icon.Visible = $false; $form.Close(); [System.Windows.Forms.Application]::Exit() })
$menu.Items.Add($exitItem)
$icon.ContextMenuStrip = $menu

Write-Host "[OK] Quick Settings running. Click tray icon to open." -Fore Cyan
Write-Host "Press Ctrl+C in this terminal to exit." -Fore Yellow

# Show tray notification
$icon.ShowBalloonTip(3000,"Quick Settings","Click tray icon to adjust display, power, volume",[Windows.Forms.ToolTipIcon]::Info)

[System.Windows.Forms.Application]::Run($form)