# DirMap Script 📁
![GitHub last commit](https://img.shields.io/github/last-commit/WiseDodge/DirMap-Script)

**A PowerShell script to generate a visual directory tree of any folder.**

> This tool creates a text file that **shows a map of all your folders**. I made it as a folder-only successor to `tree /f > directoryinROOT.txt`, which is one of my most-used Windows commands. It has two versions: one you run from a Powershell window, and one you just double-click. Both files will save the output in the same directory as the provided path.

-----

## 🚀 Features

  * 🗂️ **Folder-Only Output** — Unlike the standard `tree` command, this script only maps folders, making the output cleaner and easier to read.
  * 📄 **Text File Export** — Creates a `directoryinROOT.txt` file in the specified directory, which is easy to share via email, chat, and other platforms.
  * 💻 **Dual Usage Methods** — Supports two methods of operation: a PowerShell file for command-line use, and a batch file for simple double-click execution.

-----

## 📂 How It Works

The script simply prompts the user for a directory path, and then proceeds to recursively scan that directory to generate a visual tree structure of all the folders within. It then saves this map into a text file named `directoryinROOT.txt` in that same root folder.

-----

## 📸 Sample Output

The output will look similar to this:

```
C:\Users\Username\Documents\
├───Project Alpha
│   ├───Documents
│   └───Source
├───Project Beta
│   ├───Assets
│   │   ├───Images
│   │   └───Models
│   └───Scripts
└───Vacation Photos
    ├───2023
    └───2024
```

-----

## 🧰 Usage

### Method 1: The PowerShell File (`.ps1`)

*Use this if you prefer running scripts from the PowerShell window.*

1.  Navigate to the `src/` directory in PowerShell.

2.  Run the script with the following command:

    ```powershell
    .\Get-FolderTree.ps1
    ```

3.  The script will prompt you to enter the path of the directory you want to map. 
    > *Tip: You can get a directory's path by clicking on a folder and pressing `Ctrl + Shift + C`.*


```ps1
# Get-FolderTree.ps1
# This script prompts the user to select a root directory and generates a text file
# containing a visual tree structure of all folders within that directory.

# Make sure the console output uses the correct character encoding for tree characters
chcp 65001 >$null

# Define a recursive function to build the directory tree structure
function Get-DirectoryTree {
    param (
        [string]$Path,
        [int]$Level = 0,
        [string[]]$IndentationPrefixes = @()
    )

    # Get the items in the current directory, including hidden ones, but only folders
    $items = Get-ChildItem -Path $Path -Directory -Force | Sort-Object Name

    # Get the number of items to correctly determine last child
    $count = $items.Count
    $i = 0

    # Loop through each folder
    foreach ($item in $items) {
        $i++
        $isLastItem = ($i -eq $count)

        # Build the current line's prefix for the tree
        if ($isLastItem) {
            $prefix = "└───"
        } else {
            $prefix = "├───"
        }

        # Build the full indentation string based on the parent levels
        $indentation = ($IndentationPrefixes -join "") + $prefix

        # Print the current folder path with indentation to the pipeline
        Write-Output "$indentation$($item.Name)"

        # Prepare indentation for the next level
        $newPrefixes = @($IndentationPrefixes)
        if ($isLastItem) {
            $newPrefixes += "    "
        } else {
            $newPrefixes += "│   "
        }

        # Recursively call the function for subdirectories
        Get-DirectoryTree -Path $item.FullName -Level ($Level + 1) -IndentationPrefixes $newPrefixes
    }
}

# Prompt the user for a root directory and validate the input
do {
    $rootPath = Read-Host -Prompt "Please enter the full path of the directory you want to scan (e.g., C:\Users\Username\Documents)"
    if (-not (Test-Path -Path $rootPath -PathType Container)) {
        Write-Host "Error: The path '$rootPath' is not a valid directory. Please try again." -ForegroundColor Red
    }
} while (-not (Test-Path -Path $rootPath -PathType Container))

# Set the file encoding for all outputs in this session
$PSDefaultParameterValues['Out-File:Encoding'] = 'UTF8'

# Clear the output file before writing to it
Set-Content -Path "directoryinROOT.txt" -Value "" -Encoding UTF8

# Write the root path and then the directory tree to the output file
Write-Output "$rootPath\" | Out-File -FilePath "directoryinROOT.txt" -Encoding UTF8
Get-DirectoryTree -Path $rootPath | Out-File -FilePath "directoryinROOT.txt" -Append -Encoding UTF8

Write-Host "Scan complete. The directory tree has been saved to directoryinROOT.txt" -ForegroundColor Green
```

### Method 2: The Batch File (`.bat`)

*This version is the easiest to use. It's a single file that runs everything for you with a double-click.*

1.  Navigate to the `src/` directory in Windows Explorer.
2.  Double-click the batch file (`.bat`) to run it.
3.  A command window will open, prompting you to enter the directory path.


```powershell
@echo off
chcp 65001 >nul
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {$PSDefaultParameterValues['Out-File:Encoding'] = 'UTF8'; function Get-DirectoryTree {param ([string]$Path, [int]$Level = 0, [string[]]$IndentationPrefixes = @()) $items = Get-ChildItem -Path $Path -Directory -Force | Sort-Object Name; $count = $items.Count; $i = 0; foreach ($item in $items) {$i++; $isLastItem = ($i -eq $count); if ($isLastItem) {$prefix = '└───'} else {$prefix = '├───'}; $indentation = ($IndentationPrefixes -join '') + $prefix; Write-Output ($indentation + $item.Name); $newPrefixes = @($IndentationPrefixes); if ($isLastItem) {$newPrefixes += '    '} else {$newPrefixes += '│   '}; Get-DirectoryTree -Path $item.FullName -Level ($Level + 1) -IndentationPrefixes $newPrefixes}}; do {$rootPath = Read-Host -Prompt 'Please enter the full path of the directory you want to scan (e.g., C:\Users\Username\Documents)'; if (-not (Test-Path -Path $rootPath -PathType Container)) {Write-Host ('Error: The path ' + $rootPath + ' is not a valid directory. Please try again.') -ForegroundColor Red}} while (-not (Test-Path -Path $rootPath -PathType Container)); Set-Content -Path 'directoryinROOT.txt' -Value '' -Encoding UTF8; Write-Output ($rootPath + '\') | Out-File -FilePath 'directoryinROOT.txt' -Encoding UTF8; Get-DirectoryTree -Path $rootPath | Out-File -FilePath 'directoryinROOT.txt' -Append -Encoding UTF8}"
pause
```

-----

## ⚠️ Troubleshooting

**Error:** "Running scripts is disabled on this system."

**Solution:** This is a common security feature. To allow the script to run, open PowerShell as an administrator and enter this command:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

-----

## 📜 License

This project is licensed under the MIT License.

-----
