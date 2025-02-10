# Gratuitous ASCII Art
$text = @"
                                                                                          
                                           #####                                          
                                          #######                                         
                                          #######                                         
                        ###                 ###                 ###                       
                      #######                                 #######                     
                      #######              #####              #######                     
                       #####              #######              #####                      
                              ##          #######                                         
                            ######        #######        ######                           
                            ########      #######       ########                          
                            #########     #######     #########                           
                              ########    #######    #########                            
            ###                #########  #######   ########                 ###          
          ######                ######### ####### #########                ######         
         ########   ####          #####             ######         ####   ########        
          ######   ###########     ##                 ##     ###########   ######         
                   ################                     #################                 
                    ##############                       ###############                  
                        ##########                       ##########                       
                              ###                         ####                            
                                                                                          
                           ######                        ######                           
                      ############                       ###########                      
                   ################                     ###############                   
            ###    ##############                      # ###############    ###           
          #######  #########      ####               ####     ##########  #######         
          #######     #          ########         ########         ###    #######         
           #####               #########  #######  #########               #####          
                              #########   #######   #########                             
                             #########    #######     #########                           
                            ########      #######      #########                          
                           ########       #######       ########                          
                             ####         #######         #####                           
                        ###               #######               ####                      
                      #######             #######              ######                     
                      #######               ###               #######                     
                       #####                                    ####                      
                                           #####                                          
                                          #######                                         
                                          #######                                         
                                            ###                                           
                                                                                          
                                                                                          
          #              #     #                ##   ##      #  #                     
          #     ###   ####  ####   ###  ###     # # # #  ### #  #  ###  ###         
          #    #   # #   # #   #  #   # #  #    # # # # # ## #  #  # #  # #            
          ####  ###   ## #  ## #   ###  #  #    #  #  # ## # #  #  #### ####         
                                                                                          
           ### #                        #      ###                ##                       
          #    # ##    ###  ## ###    ####    #    ###  ## #    # #  ###  ###   ###         
           ### ##  #  # ##  #  # #   #   #     ### # #  #   ## ## #  #    # #   ##     
          #### #   #  ## #  #  ####   ## #    #### #### #    ##   #  ###  ####  ###       
"@

# Define Log File
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path
$logFile = Join-Path -Path $scriptDir -ChildPath "CylanceUninstallLog.txt"

# Function to Log Messages
function Write-Log {
    param (
        [string]$Message,
        [string]$Type = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Type] $Message"
    Add-Content -Path $logFile -Value $logEntry
}

# Start Logging
Write-Log "Script execution started."

try {
# Check Cylance Protection Policy
$policyPath = "C:\ProgramData\Cylance\Status\Status.json"
if (Test-Path $policyPath) {
    try {
        $policyName = (Get-Content -Path $policyPath -Raw | ConvertFrom-Json).Policy.name
        Write-Log "Current Cylance Protection Policy: $policyName"

        # List of allowed policy names
        $allowedPolicies = @("0-troubleshoot-NO Security", "0-Troubleshooting-NO SECURITY", "default", "04-AQT MPB SCB ORA [Macro Alert Only] TZ-DH24", "03-AQT MPB SCA ORA [Macro Alert Only] TZ-DH24", "LMSS VDI - Phase 2.5 AQT MPB SCA")

        if ($policyName -notin $allowedPolicies) {
            Write-Log "Policy does not appear to be in a disabled state. Agent is likely orphaned and needs manual intervention." -Type "WARNING"
            Write-Log "Script halted due to incompatible Cylance policy." -Type "INFO"
            exit
        }
    } catch {
        Write-Log "Failed to parse the Cylance policy file. Error: $_" -Type "ERROR"
        Write-Log "Assuming Cylance is uninstalled. Continuing with cleanup." -Type "INFO"
    }
} else {
    Write-Log "Policy file not found. Assuming Cylance is uninstalled. Continuing with cleanup." -Type "INFO"
}


    # Uninstall CylanceOPTICS
    $co = Get-WmiObject Win32_Product | Where-Object {$_.Name -like "Cylance*OPTICS*"}
    if ($co) {
        Write-Log "Uninstalling CylanceOPTICS..."
        Start-Process "msiexec.exe" -ArgumentList "/x $($co.IdentifyingNumber) /qn /norestart" -Wait
        Write-Log "CylanceOPTICS uninstalled successfully."
    } else {
        Write-Log "CylanceOPTICS not found." -Type "WARNING"
    }

    # Uninstall CylancePROTECT
    $cp = Get-WmiObject Win32_Product | Where-Object {$_.Name -like "Cylance*PROTECT*"}
    if ($cp) {
        Write-Log "Uninstalling CylancePROTECT..."
        Start-Process "msiexec.exe" -ArgumentList "/x $($cp.IdentifyingNumber) /qn /norestart" -Wait
        Write-Log "CylancePROTECT uninstalled successfully."
    } else {
        Write-Log "CylancePROTECT not found." -Type "WARNING"
    }

    # Check for remnants and run Cylance Removal Tool if needed
    $ci = Get-WmiObject Win32_Product | Where-Object {$_.Name -like "Cylance*"}
    $programFilesPaths = @(
        "C:\Program Files\Cylance",
        "C:\Program Files (x86)\Cylance",
        "C:\ProgramData\Cylance"
    )

    # Detect remnants
    if ($ci -or ($programFilesPaths | Where-Object { Test-Path $_ })) {
        Write-Log "Cylance remnants detected. Running Cylance Removal Tool..."
        $toolPath = Join-Path -Path $scriptDir -ChildPath "CylanceRemovalTool.0.13.7\CylanceUninstallTool.0.13.7-x64.exe"
        
        if (Test-Path $toolPath) {
            Start-Process $toolPath -ArgumentList "-S -r -l $scriptDir" -Wait
            Write-Log "Cylance Removal Tool executed successfully."
        } else {
            Write-Log "Cylance Removal Tool not found. Manual cleanup may be required." -Type "ERROR"
        }
    } else {
        Write-Log "No Cylance components or folder remnants found."
    }

    # Clean up leftover shortcuts, folders, and traces
    $pathsToRemove = @(
        "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Cylance",
        "C:\Program Files\Cylance",
        "C:\Program Files (x86)\Cylance",
        "C:\ProgramData\Cylance"
    )

    foreach ($path in $pathsToRemove) {
        if (Test-Path $path) {
            Write-Log "Removing leftover Cylance folder or shortcut: $path"
            try {
                Remove-Item -Path $path -Force -Recurse -ErrorAction Stop
                Write-Log "Removed: $path"
            } catch {
                Write-Log "Failed to remove $path. Error: $_" -Type "ERROR"
            }
        } else {
            Write-Log "No trace found at: $path"
        }
    }
} catch {
    Write-Log "An unexpected error occurred: $_" -Type "ERROR"
}

Write-Log "Script execution completed."
