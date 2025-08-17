# Get-FolderTree-CMD.ps1
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
