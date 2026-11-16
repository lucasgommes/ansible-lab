$ErrorActionPreference = 'Stop'

$capabilityName = 'OpenSSH.Server~~~~0.0.1.0'

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $hostExecutable = (Get-Process -Id $PID).Path
    $arguments = '-NoProfile -File "{0}"' -f $PSCommandPath
    try {
        $elevatedProcess = Start-Process -FilePath $hostExecutable -Verb RunAs -ArgumentList $arguments -Wait -PassThru
    }
    catch {
        throw "Administrator elevation was canceled or failed. $($_.Exception.Message)"
    }
    exit $elevatedProcess.ExitCode
}

$service = Get-Service -Name 'sshd' -ErrorAction SilentlyContinue
if (-not $service) {
    if (-not (Get-Command Get-WindowsCapability -ErrorAction SilentlyContinue)) {
        throw 'OpenSSH Server is missing, and this Windows installation does not provide Get-WindowsCapability.'
    }

    $capability = Get-WindowsCapability -Online -Name $capabilityName
    if ($capability.State -ne 'Installed') {
        Write-Host 'Installing Windows OpenSSH Server capability...'
        Add-WindowsCapability -Online -Name $capabilityName | Out-Null
    }

    $service = Get-Service -Name 'sshd' -ErrorAction SilentlyContinue
    if (-not $service) {
        throw 'OpenSSH Server installation completed, but the sshd service was not found.'
    }
}

Set-Service -Name 'sshd' -StartupType Automatic
if ($service.Status -ne 'Running') {
    Start-Service -Name 'sshd'
}

$service = Get-Service -Name 'sshd'
if ($service.Status -ne 'Running') {
    throw "The sshd service did not start. Current status: $($service.Status)."
}

Write-Host 'The sshd service is running and configured to start automatically.'
