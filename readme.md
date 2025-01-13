# Cylance Uninstall Script

## Overview
This PowerShell script is designed to automate the removal of Cylance security products (CylancePROTECT and CylanceOPTICS) from a Windows system. It checks the current Cylance protection policy, uninstalls Cylance components, and performs cleanup tasks to ensure no remnants are left behind. The script logs all actions to a file for auditing and troubleshooting purposes.

---
## Features
- Logs all actions and errors to `CylanceUninstallLog.txt`.
- Reads and verifies the current Cylance protection policy.
- Automatically uninstalls **CylancePROTECT** and **CylanceOPTICS** if detected.
- Executes the Cylance Removal Tool for residual components, if available.
- Cleans up any leftover shortcuts or folders associated with Cylance products.
- **Cylance Script Control Exception**: If the script is run from **C:\lmss\ps_scripts\**, it will bypass Cylance's script control, if it is still enabled, and allow the tool to run.
---
## Disclaimer
This script has not been widely tested and is provided as-is. It is the responsibility of the user to:
- Thoroughly test the script in a controlled, non-production environment before using it in production.
- Verify its functionality and suitability for their specific use case.

The author of this script assumes no responsibility for any damage, data loss, or issues caused by the use of this script or any associated tools. Use it at your own risk.
---
## Required Files
- **CylanceRemovalTool.0.13.7** - Cylance Removal Tool
- **CylanceUninstall.ps1** - LMSS Provided script
- **readme.md** - This document

## Prerequisites
1. **Administrative Privileges**: The script must be executed with administrative rights.
2. **PowerShell Execution Policy**: Ensure the PowerShell execution policy allows the script to run (e.g., `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`).
3. **Cylance Removal Tool**: Place the Cylance Removal Tool (`CylanceUninstallTool.0.13.7-x64.exe`) in the folder `.\CylanceRemovalTool.0.13.7\` relative to the script.
---
## How to Use
1. **Download the Script**  
   Save the script as `CylanceUninstall.ps1` on the target machine.

2. **Prepare Environment**  
   - Ensure the Cylance Removal Tool is in the correct folder as mentioned above.
   - Verify that the `C:\ProgramData\Cylance\Status\Status.json` file exists if you need to check the Cylance protection policy.

3. **Test in a Non-Production Environment**  
   Before deploying the script in a production environment, thoroughly test it in a controlled environment to confirm its behavior.

4. **Run the Script**  
   - Open PowerShell as an administrator and execute the script:
   ```powershell
   .\CylanceUninstall.ps1
   ```
   -Check the Log File
       - Review CylanceUninstallLog.txt in the same directory as the script for detailed logs of the uninstallation process.

## Script Workflow
**Logging**
- All actions, warnings, and errors are logged to CylanceUninstallLog.txt with timestamps.

**Check Protection Policy**
- Reads the policy from C:\ProgramData\Cylance\Status\Status.json and logs the current policy name.

**Uninstall Cylance Components**
- Searches for Cylance products using WMI and uninstalls them via msiexec.
- If remnants remain, runs the Cylance Removal Tool if available.

**Cleanup**
- Removes leftover shortcuts and folders related to Cylance.

### Log File Example

The script creates a log file named CylanceUninstallLog.txt with entries like the following:
```
[2024-12-10 15:11:43] [INFO] Script execution started.
[2024-12-10 15:11:43] [INFO] Current Cylance Protection Policy: 
[2024-12-10 15:11:43] [INFO] Current Cylance Protection Policy: '0-troubleshoot-NO Security'.
[2024-12-10 15:11:58] [WARNING] CylanceOPTICS not found.
[2024-12-10 15:12:13] [INFO] Uninstalling CylancePROTECT...
[2024-12-10 15:13:30] [INFO] CylancePROTECT uninstalled successfully.
[2024-12-10 15:13:44] [INFO] No additional Cylance components found.
[2024-12-10 15:13:44] [INFO] No Start Menu folder found for Cylance.
[2024-12-10 15:13:44] [INFO] Script execution completed.
```

## Error Handling
- If a policy file is missing or cannot be parsed, the script logs a warning or error.
- If a Cylance component cannot be uninstalled, an error is logged, and the script proceeds to the next step.
- Missing Cylance Removal Tool or other unexpected issues are logged as errors.

## Notes
- Policy Verification: If the protection policy is not "0-troubleshoot-NO Security", "0-Troubleshooting-NO SECURITY" or "default" manually verify the endpoint's status before proceeding.
- Cylance Removal Tool: Ensure the tool version matches the environment and is properly configured for silent execution.

## Support
- If you encounter issues with the script or need additional assistance, review the log file for detailed error messages and adjust the environment accordingly.