param (
    # The rule uuid to use
    [Parameter(Mandatory)]
    [ValidateScript( {
            try {
                [System.Guid]::Parse($_) | Out-Null
                $true
            }
            catch {
                $false
            }
        })]
    [string]
    $RuleUuid
)

$ErrorActionPreference = "Stop"

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole] "Administrator")
if (!$isAdmin) {
    Write-Error "Please rerun the script as administrator"
}

$scriptFolder = Split-Path -parent $PSCommandPath
$modulePath = Join-Path $scriptFolder "NetLimiter.psm1"
if (!(Test-Path $modulePath)) {
    Write-Error "Could not find NetLimiter module at: $modulePath, please ensure it is there"
}

$moduleFolder = Join-Path "$Home\Documents\WindowsPowerShell\Modules" "NetLimiter"
New-Item -Type Directory -Path $moduleFolder -Force
# Install netlimiter module
Copy-Item $modulePath -Destination $moduleFolder -Force

$enableAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -command `"Enable-NetLimiterRule $RuleUuid`""
$disableAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -command `"Disable-NetLimiterRule $RuleUuid`""

$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$principal = New-ScheduledTaskPrincipal -UserId $currentUser -RunLevel Highest

$enableTask = New-ScheduledTask -Action $enableAction -Principal $principal -Description "Enables the NetLimiter rule {$RuleUuid}"
$disableTask = New-ScheduledTask -Action $disableAction -Principal $principal -Description "Disables the NetLimiter rule {$RuleUuid}"

Register-ScheduledTask EnableDestinyNetLimitRule -InputObject $enableTask -Force
Register-ScheduledTask DisableDestinyNetLimitRule -InputObject $disableTask -Force
