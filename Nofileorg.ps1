# Create a log folder in the same directory as the script
$logFolder = Join-Path -Path $PSScriptRoot -ChildPath "no_organizefiles_logs"
if (-not (Test-Path -Path $logFolder)) {
    New-Item -Path $logFolder -ItemType Directory
}

# Create a transcript log file with a timestamp
$logFile = Join-Path -Path $logFolder -ChildPath ("log_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".txt")

# Start transcript logging
Start-Transcript -Path $logFile -Append
Write-Host "Transcript started. All console output will be logged to $logFile."

# Prompt the user to specify the folder to organize
try {
    $folderPath = Read-Host "Enter the full path of the folder you want to organize"
    Write-Host "User specified folder to organize: $folderPath"
} catch {
    Write-Host "An error occurred while reading the folder path: $_"
    Stop-Transcript
    pause
    exit
}

# Ask the user if they want to organize surface-level files only or all files recursively
try {
    $organizeOption = Read-Host "Do you want to organize surface-level files only? (Y/N)"
    $surfaceOnly = $organizeOption -eq "Y" -or $organizeOption -eq "y"
    Write-Host "User selected surface-level only: $surfaceOnly"
} catch {
    Write-Host "An error occurred while reading the organization option: $_"
    Stop-Transcript
    pause
    exit
}

# Define the main categories and their associated file extensions
$categories = @{
    "Documents" = @(".pdf", ".docx", ".xlsx", ".txt", ".ppt", ".pptx", ".odt", ".rtf")
    "Pictures"    = @(".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff", ".svg", ".webp")
    "Videos"    = @(".mp4", ".mkv", ".avi", ".mov", ".wmv", ".flv", ".mpeg", ".webm")
    "Music"     = @(".mp3", ".wav", ".flac", ".aac", ".ogg", ".m4a", ".wma")
    "Archives"  = @(".zip", ".rar", ".7z", ".tar", ".gz", ".bz2")
    "Applications" = @(".exe", ".msi", ".dmg", ".pkg", ".bat", ".sh")
}

# Get all files in the folder (surface-level or recursively)
try {
    if ($surfaceOnly) {
        $files = Get-ChildItem -Path $folderPath -File
        $folders = Get-ChildItem -Path $folderPath -Directory
        Write-Host "Retrieved surface-level files and folders from $folderPath"
    } else {
        $files = Get-ChildItem -Path $folderPath -File -Recurse
        Write-Host "Retrieved all files recursively from $folderPath"
    }
} catch {
    Write-Host "An error occurred while retrieving files: $_"
    Stop-Transcript
    pause
    exit
}

# Function to generate a unique filename
function Get-UniqueFileName {
    param (
        [string]$destinationFolder,
        [string]$fileName
    )
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
    $extension = [System.IO.Path]::GetExtension($fileName)
    $newFileName = $fileName
    $count = 1

    # Check if the file already exists and increment the number until a unique name is found
    while (Test-Path -Path (Join-Path -Path $destinationFolder -ChildPath $newFileName)) {
        $newFileName = "$baseName ($count)$extension"
        $count++
    }

    return $newFileName
}

# Organize files into categories
foreach ($file in $files) {
    try {
        $fileExtension = $file.Extension.ToLower()
        $categoryFound = $false

        # Check which category the file belongs to
        foreach ($category in $categories.Keys) {
            if ($categories[$category] -contains $fileExtension) {
                $destinationFolder = Join-Path -Path $folderPath -ChildPath $category
                if (-not (Test-Path -Path $destinationFolder)) {
                    New-Item -Path $destinationFolder -ItemType Directory
                    Write-Host "Created directory: $destinationFolder"
                }

                # Check if the file is already in the correct destination folder
                $destinationFile = Join-Path -Path $destinationFolder -ChildPath $file.Name
                if ($file.DirectoryName -eq $destinationFolder) {
                    Write-Host "File is already in the correct folder: $($file.FullName)"
                    $categoryFound = $true
                    break
                }

                # Generate a unique filename if a file with the same name already exists
                if (Test-Path -Path $destinationFile) {
                    $uniqueFileName = Get-UniqueFileName -destinationFolder $destinationFolder -fileName $file.Name
                    $destinationFile = Join-Path -Path $destinationFolder -ChildPath $uniqueFileName
                }

                Move-Item -Path $file.FullName -Destination $destinationFile
                Write-Host "Moved file: $($file.FullName) to $destinationFile"
                $categoryFound = $true
                break
            }
        }

        # If the file doesn't fit into any category, move it to "Others"
        if (-not $categoryFound) {
            $destinationFolder = Join-Path -Path $folderPath -ChildPath "Others"
            if (-not (Test-Path -Path $destinationFolder)) {
                New-Item -Path $destinationFolder -ItemType Directory
                Write-Host "Created directory: $destinationFolder"
            }

            # Check if the file is already in the correct destination folder
            $destinationFile = Join-Path -Path $destinationFolder -ChildPath $file.Name
            if ($file.DirectoryName -eq $destinationFolder) {
                Write-Host "File is already in the correct folder: $($file.FullName)"
                continue
            }

            # Generate a unique filename if a file with the same name already exists
            if (Test-Path -Path $destinationFile) {
                $uniqueFileName = Get-UniqueFileName -destinationFolder $destinationFolder -fileName $file.Name
                $destinationFile = Join-Path -Path $destinationFolder -ChildPath $uniqueFileName
            }

            Move-Item -Path $file.FullName -Destination $destinationFile
            Write-Host "Moved file: $($file.FullName) to $destinationFile"
        }
    } catch {
        Write-Host "An error occurred while processing file $($file.FullName): $_"
    }
}

# If organizing surface-level files only, move subfolders to "Folders"
if ($surfaceOnly -and $folders) {
    try {
        $otherFoldersPath = Join-Path -Path $folderPath -ChildPath "Folders"
        if (-not (Test-Path -Path $otherFoldersPath)) {
            New-Item -Path $otherFoldersPath -ItemType Directory
            Write-Host "Created directory: $otherFoldersPath"
        }
        foreach ($folder in $folders) {
            # Skip moving the "Folders" directory and category folders
            if ($folder.Name -eq "Folders" -or $categories.Keys -contains $folder.Name) {
                Write-Host "Skipping folder: $($folder.FullName)"
                continue
            }
            Move-Item -Path $folder.FullName -Destination $otherFoldersPath
            Write-Host "Moved folder: $($folder.FullName) to $otherFoldersPath"
        }
    } catch {
        Write-Host "An error occurred while moving folders: $_"
    }
}

# Function to delete empty subdirectories
function Remove-EmptySubdirectories {
    param (
        [string]$directory
    )
    # Get all subdirectories
    $subdirectories = Get-ChildItem -Path $directory -Directory -Recurse

    # Iterate through subdirectories in reverse order (deepest first)
    foreach ($subdirectory in $subdirectories | Sort-Object FullName -Descending) {
        # Check if the directory is empty
        if (-not (Get-ChildItem -Path $subdirectory.FullName -Force)) {
            Write-Host "Deleting empty directory: $($subdirectory.FullName)"
            Remove-Item -Path $subdirectory.FullName -Force
        }
    }
}

# If not organizing surface-level files, delete empty subdirectories
if (-not $surfaceOnly) {
    try {
        Write-Host "Checking for and deleting empty subdirectories..."
        Remove-EmptySubdirectories -directory $folderPath
        Write-Host "Empty subdirectories deleted."
    } catch {
        Write-Host "An error occurred while deleting empty subdirectories: $_"
    }
}

Write-Host "Files organized successfully!"

# Stop transcript logging
Stop-Transcript

# Wait for user input before closing the PowerShell window
pause