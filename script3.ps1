CREANDO SISTEMA DE LOGUEO

# script3.ps1
function New-FolderCreation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$foldername
    )

    # Create absolute path for the folder relative to current location
    $logpath = Join-Path -Path (Get-Location).Path -ChildPath $foldername
    if (-not (Test-Path -Path $logpath)) {
        New-Item -Path $logpath -ItemType Directory -Force | Out-Null
    }

    return $logpath
}

function Write-Log {
    [CmdletBinding()]
    param(
        # Create parameter set
        [Parameter(Mandatory = $true, ParameterSetName = 'Create')]
        [Alias('Names')]
        [object]$Name,                    # can be single string or array

        [Parameter(Mandatory = $true, ParameterSetName = 'Create')]
        [string]$Ext,

        [Parameter(Mandatory = $true, ParameterSetName = 'Create')]
        [string]$folder,

        [Parameter(ParameterSetName = 'Create', Position = 0)]
        [switch]$Create,

        # Message parameter set
        [Parameter(Mandatory = $true, ParameterSetName = 'Message')]
        [string]$message,

        [Parameter(Mandatory = $true, ParameterSetName = 'Message')]
        [string]$path,

        [Parameter(Mandatory = $false, ParameterSetName = 'Message')]
        [ValidateSet('Information','Warning','Error')]
        [string]$Severity = 'Information',

        [Parameter(ParameterSetName = 'Message', Position = 0)]
        [switch]$MSG
    )

    switch ($PsCmdlet.ParameterSetName) {
        "Create" {
            $created = @()

            # Normalize $Name to an array
            $namesArray = @()
            if ($null -ne $Name) {
                if ($Name -is [System.Array]) { $namesArray = $Name }
                else { $namesArray = @($Name) }
            }

            # Date + time formatting (safe for filenames)
            $date1 = (Get-Date -Format "yyyy-MM-dd")
            $time  = (Get-Date -Format "HH-mm-ss")

            # Ensure folder exists and get absolute folder path
            $folderPath = New-FolderCreation -foldername $folder

            foreach ($n in $namesArray) {
                # sanitize name to string
                $baseName = [string]$n

                # Build filename
                $fileName = "${baseName}_${date1}_${time}.$Ext"

                # Full path for file
                $fullPath = Join-Path -Path $folderPath -ChildPath $fileName

                # Create the file (New-Item -Force will create or overwrite; use -ErrorAction Stop to catch errors)
                try {
                    # If you prefer to NOT overwrite existing file, use: if (-not (Test-Path $fullPath)) { New-Item ... }
                    New-Item -Path $fullPath -ItemType File -Force -ErrorAction Stop | Out-Null

                    # Optionally write a header line (uncomment if desired)
                    # "Log created: $(Get-Date)" | Out-File -FilePath $fullPath -Encoding UTF8 -Append

                    $created += $fullPath
                }
                catch {
                    Write-Warning "Failed to create file '$fullPath' - $_"
                }
            }

            return $created
        }

        "Message" {
            # Ensure directory for message file exists
            $parent = Split-Path -Path $path -Parent
            if ($parent -and -not (Test-Path -Path $parent)) {
                New-Item -Path $parent -ItemType Directory -Force | Out-Null
            }

            $date = Get-Date
            $concatmessage = "|$date| |$message| |$Severity|"

            switch ($Severity) {
                "Information" { Write-Host $concatmessage -ForegroundColor Green }
                "Warning"     { Write-Host $concatmessage -ForegroundColor Yellow }
                "Error"       { Write-Host $concatmessage -ForegroundColor Red }
            }

            # Append message to the specified path (creates file if it does not exist)
            Add-Content -Path $path -Value $concatmessage -Force

            return $path
        }

        default {
            throw "Unknown parameter set: $($PsCmdlet.ParameterSetName)"
        }
    }
}

# ---------- Example usage ----------
# This will create the folder "logs" (if missing) and create a file Name-Log_YYYY-MM-DD_HH-mm-ss.log
$logPaths = Write-Log -Name "Name-Log" -folder "logs" -Ext "log" -Create
$logPaths