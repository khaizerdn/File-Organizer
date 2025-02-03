# Define folder where random files will be created
$testFolder = "C:\Users\Khaizer\Downloads\TestFiles"
if (-not (Test-Path -Path $testFolder)) {
    New-Item -Path $testFolder -ItemType Directory
    Write-Host "Created test folder: $testFolder"
}

# Define file extensions for different categories
$fileExtensions = @(
    ".pdf", ".docx", ".xlsx", ".txt", ".ppt", ".pptx", ".odt", ".rtf",  # Documents
    ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff", ".svg", ".webp",  # Images
    ".mp4", ".mkv", ".avi", ".mov", ".wmv", ".flv", ".mpeg", ".webm",   # Videos
    ".mp3", ".wav", ".flac", ".aac", ".ogg", ".m4a", ".wma",            # Music
    ".zip", ".rar", ".7z", ".tar", ".gz", ".bz2",                       # Archives
    ".exe", ".msi", ".dmg", ".pkg", ".bat", ".sh"                       # Applications
    ".log", ".txt", ".debug",  # Logs and debugging files
    ".ini", ".conf", ".配置",  # Configuration files
    ".xlsm", ".xltdm",        # Excel Spreadsheet Models
    ".mdb",                   # Microsoft Access database
    ".js", ".css", ".xml", ".json", ".gml", ".swf", ".hdf5", ".mat", ".xladd-in", ".xsd", ".yaml", ".yml", ".xhtml"  # Various other types
)

# Number of files to create
$numberOfFiles = 50

# Function to generate a random string for filenames
function Get-RandomString {
    param (
        [int]$length = 10
    )
    $characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    $randomString = -join (1..$length | ForEach-Object { $characters[(Get-Random -Maximum $characters.Length)] })
    return $randomString
}

# Generate random files
for ($i = 1; $i -le $numberOfFiles; $i++) {
    $fileName = Get-RandomString -length 8
    $fileExtension = $fileExtensions | Get-Random
    $filePath = Join-Path -Path $testFolder -ChildPath "$fileName$fileExtension"
    
    # Generate random content for the file
    $fileSize = Get-Random -Minimum 1 -Maximum 1024  # Random size between 1 KB and 1 MB
    $randomContent = -join (1..$fileSize | ForEach-Object { [char](Get-Random -Minimum 32 -Maximum 126) })
    
    # Create the file
    Set-Content -Path $filePath -Value $randomContent
    Write-Host "Created file: $filePath"
}

Write-Host "Random files generated successfully in $testFolder!"