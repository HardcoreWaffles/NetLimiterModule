function Enable-NetLimiterRule {
    [CmdletBinding()]
    param (
        # The rule uuid to enable
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

    begin {
        $netLimiterConfigPath = "$($env:ProgramData)\\Locktime\\NetLimiter\\4\\nl_settings.xml"
        [xml] $netLimiterConfigXml = $null;
        $rulesNodeList = $null;
        $netLimiterService = $null
        $shouldRestartService = $false

        # Open the xml config
        if (Test-Path $netLimiterConfigPath) {
            $netLimiterConfigXml = Get-Content $netLimiterConfigPath
        }
        else {
            Write-Error "Could not find NetLimiter config at: $netLimiterConfigPath"
        }
        $rulesNodeList = $netLimiterConfigXml.NLSvcSettings.Rules.ChildNodes

        # Stop the NetLimiter service if it's started
        $netLimiterService = Get-Service | Where-Object { $_.Name -eq "nlsvc" }
        if ($null -eq $netLimiterService) {
            Write-Error "Could not find NetLimiter service, ensure that it is installed"
        }
        
        if ($netLimiterService.Status -ne "running") {
            Write-Warning "NetLimiter service not running, will not restart"
        }
        else {
            $netLimiterService | Stop-Service
            $shouldRestartService = $true;
        }
    }

    process {
        $ruleNode = $rulesNodeList | Where-Object { $_.Id -ieq $RuleUuid }
        $ruleNode.IsEnabled = "true"
        $ruleNode.IsActive = "true"
    }

    end {
        # Save the changes made to the xml config 
        $netLimiterConfigXml.Save($netLimiterConfigPath)

        # Restart the service if needed
        if ($shouldRestartService) {
            $netLimiterService | Start-Service
        }
    }
}

function Disable-NetLimiterRule {
    [CmdletBinding()]
    param (
        # The rule uuid to enable
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

    begin {
        $netLimiterConfigPath = "$($env:ProgramData)\\Locktime\\NetLimiter\\4\\nl_settings.xml"
        [xml] $netLimiterConfigXml = $null;
        $rulesNodeList = $null;
        $netLimiterService = $null
        $shouldRestartService = $false

        # Open the xml config
        if (Test-Path $netLimiterConfigPath) {
            $netLimiterConfigXml = Get-Content $netLimiterConfigPath
        }
        else {
            Write-Error "Could not find NetLimiter config at: $netLimiterConfigPath"
        }
        $rulesNodeList = $netLimiterConfigXml.NLSvcSettings.Rules.ChildNodes

        # Stop the NetLimiter service if it's started
        $netLimiterService = Get-Service | Where-Object { $_.Name -eq "nlsvc" }
        if ($null -eq $netLimiterService) {
            Write-Error "Could not find NetLimiter service, ensure that it is installed"
        }
        
        if ($netLimiterService.Status -ne "running") {
            Write-Warning "NetLimiter service not running, will not restart"
        }
        else {
            $netLimiterService | Stop-Service
            $shouldRestartService = $true;
        }
    }

    process {
        $ruleNode = $rulesNodeList | Where-Object { $_.Id -ieq $RuleUuid }
        $ruleNode.IsEnabled = "false"
        $ruleNode.IsActive = "false"
    }

    end {
        # Save the changes made to the xml config 
        $netLimiterConfigXml.Save($netLimiterConfigPath)

        # Restart the service if needed
        if ($shouldRestartService) {
            $netLimiterService | Start-Service
        }
    }
}

Export-ModuleMember -Function Enable-NetLimiterRule, Disable-NetLimiterRule