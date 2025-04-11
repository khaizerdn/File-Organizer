# Local File Organizer

Organize your local files within a selected directory by categorizing them based on file type. The script supports both surface-level and recursive organization, helping to declutter folders and files in a structured and automated manner.

## Features

- **Automatic Categorization**  
  Files are sorted into folders like `Documents`, `Pictures`, `Videos`, `Music`, `Archives`, `Applications`, and `Others`.

- **Surface-Level or Recursive**  
  Choose whether to organize only the top-level contents or include all nested subfolders.

- **Duplicate Handling**  
  Automatically detects and renames duplicate files to avoid overwriting.

- **Empty Folder Cleanup**  
  Recursively deletes empty subdirectories after organizing (if selected).

- **User-Prompted Operation**  
  Interactive PowerShell prompts for folder selection and organization preferences.

- **Log Generation**  
  Creates a timestamped transcript log for all operations in a dedicated log folder.
  
## Requirements

- Windows OS  
- PowerShell 5.1 or later  
- Read/Write permissions in the target directory

## Use Case
- Use Local-File-Generator.ps1 when you need sample data for testing file operations, indexing tools, or backup software.
- Use Local-File-Organizer.ps1 when you want to clean up and structure your real folders by automatically moving files into appropriate categories.

## Usage

1. Clone or download this repository.
2. Right-click the script file and select **Run with PowerShell**.
3. Follow the prompts to:
   - Enter the full path of the directory to organize.
   - Choose between surface-level or recursive organization.
4. Review the output and logs (stored in the `no_organizefiles_logs` folder).

## Example Output Structure

```
📁 YourFolder
 ┣ 📁 Documents
 ┣ 📁 Pictures
 ┣ 📁 Videos
 ┣ 📁 Music
 ┣ 📁 Archives
 ┣ 📁 Applications
 ┣ 📁 Others
 ┗ 📁 Folders (if surface-level subfolders are present)
```
