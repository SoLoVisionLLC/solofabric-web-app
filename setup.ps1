# Check if pyproject.toml exists in the current directory
if (-not (Test-Path "pyproject.toml")) {
    Write-Host "Poetry could not find a pyproject.toml file in the current directory or its parents."
    Write-Host "Please navigate to the project directory where pyproject.toml is located and rerun this script."
    exit
}

# Installs poetry-based python dependencies
Write-Host "Installing python dependencies"
poetry install

# List of commands to check and add or update alias for
$commands = @("fabric", "fabric-api", "fabric-webui")

# Since PowerShell doesn't use .bashrc or .zshrc, we might update the PowerShell profile instead
$configFiles = @("$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1", "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1")

# Initialize an array to hold the paths of the sourced files (not directly applicable in PowerShell, but keeping for reference)
$sourceCommands = @()

foreach ($configFile in $configFiles) {
    # Check if the configuration file exists
    if (Test-Path $configFile) {
        Write-Host "Updating $configFile"
        foreach ($cmd in $commands) {
            # Get the path of the command
            $CMD_PATH = poetry run which $cmd 2>$null
            
            # PowerShell doesn't directly support `which`, but `poetry run which` should output the path if it exists

            # Check if CMD_PATH is empty
            if ([string]::IsNullOrWhiteSpace($CMD_PATH)) {
                Write-Host "Command $cmd not found in the current Poetry environment."
                continue
            }

            # PowerShell doesn't use aliases in the same way as bash/zsh. You might add custom functions to your profile instead.
            # Check if the profile already contains a function for the command
            $pattern = "function $cmd"
            if (Select-String -Path $configFile -Pattern $pattern -Quiet) {
                # Update the function (this requires more nuanced editing not easily done in PowerShell without potentially complex parsing)
                Write-Host "Consider manually updating the alias for $cmd in $configFile."
            }
            else {
                # If not, add the function to the config file
                Add-Content -Path $configFile -Value "`nfunction $cmd { & `"$CMD_PATH`" `@args }"
                Write-Host "Added alias for $cmd to $configFile."
            }
        }
        # PowerShell profiles are updated on new sessions, so no need to source
    }
    else {
        Write-Host "$configFile does not exist."
    }
}

# Inform the user about restarting PowerShell to apply changes
Write-Host "Please restart PowerShell to apply the changes."
