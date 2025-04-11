# Get Downloads path dynamically
$downloadsPath = [System.IO.Path]::Combine([Environment]::GetFolderPath("UserProfile"), "Downloads")

# Define main test folder
$testFolder = Join-Path -Path $downloadsPath -ChildPath "TestFiles"

# Create the main test folder if it doesn't exist
if (-not (Test-Path -Path $testFolder)) {
    New-Item -Path $testFolder -ItemType Directory | Out-Null
    Write-Host "Created test folder: $testFolder"
}

# Define file extensions
$fileExtensions = @(
    ".pdf", ".docx", ".xlsx", ".txt", ".ppt", ".pptx", ".odt", ".rtf",
    ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff", ".svg", ".webp",
    ".mp4", ".mkv", ".avi", ".mov", ".wmv", ".flv", ".mpeg", ".webm",
    ".mp3", ".wav", ".flac", ".aac", ".ogg", ".m4a", ".wma",
    ".zip", ".rar", ".7z", ".tar", ".gz", ".bz2",
    ".exe", ".msi", ".dmg", ".pkg", ".bat", ".sh",
    ".log", ".debug", ".ini", ".conf", ".配置",
    ".xlsm", ".xltdm", ".mdb",
    ".js", ".css", ".xml", ".json", ".gml", ".swf", ".hdf5", ".mat", ".xladd-in", ".xsd", ".yaml", ".yml", ".xhtml"
)

# Parameters for randomization
$numberOfTopLevelFiles = 30
$numberOfSubfolders = 5
$minFilesPerSubfolder = 3
$maxFilesPerSubfolder = 10

# Function to generate a random alphanumeric string
function Get-RandomString {
    param ([int]$length = 10)
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return -join (1..$length | ForEach-Object { $chars[(Get-Random -Minimum 0 -Maximum $chars.Length)] })
}

# Function to generate a random file with binary content
function Create-RandomFile {
    param (
        [string]$folderPath
    )

    $fileName = Get-RandomString -length 8
    $fileExtension = $fileExtensions | Get-Random
    $filePath = Join-Path -Path $folderPath -ChildPath "$fileName$fileExtension"

    $fileSize = Get-Random -Minimum 1024 -Maximum (1024 * 1024)  # 1 KB – 1 MB
    $bytes = New-Object byte[] $fileSize
    (New-Object System.Random).NextBytes($bytes)

    [System.IO.File]::WriteAllBytes($filePath, $bytes)
    Write-Host "Created file: $filePath"
}

# Create top-level random files
Write-Host "`nCreating $numberOfTopLevelFiles files in $testFolder..."
for ($i = 1; $i -le $numberOfTopLevelFiles; $i++) {
    Create-RandomFile -folderPath $testFolder
}

# Create random subfolders with random files
Write-Host "`nCreating $numberOfSubfolders random subfolders with files..."
for ($j = 1; $j -le $numberOfSubfolders; $j++) {
    $subfolderName = Get-RandomString -length 6
    $subfolderPath = Join-Path -Path $testFolder -ChildPath $subfolderName

    New-Item -Path $subfolderPath -ItemType Directory | Out-Null
    Write-Host "Created subfolder: $subfolderPath"

    $filesInThisFolder = Get-Random -Minimum $minFilesPerSubfolder -Maximum $maxFilesPerSubfolder

    for ($k = 1; $k -le $filesInThisFolder; $k++) {
        Create-RandomFile -folderPath $subfolderPath
    }
}

Write-Host "`nAll random files and folders created successfully in:`n$testFolder"
