# Git Repository SSH URL Collector

This tool helps collect SSH URLs from all Git repositories located within a common parent directory.

## Features

- Recursively finds all Git repositories in a specified directory
- Automatically converts HTTPS URLs to SSH format for GitHub repositories
- Outputs results both to console and a tab-separated file
- Handles errors gracefully without interrupting the collection process

## Usage

### Basic Usage

1. Open PowerShell
2. Navigate to the directory containing the script
3. Run the script:

```powershell
.\collect_git_urls_20240321.ps1
```

This will scan the current directory and all subdirectories for Git repositories.

### Advanced Usage

You can specify a custom root directory and output file:

```powershell
.\collect_git_urls_20240321.ps1 -RootPath "C:\YourReposDirectory" -OutputFile "custom_output.txt"
```

### Parameters

- `-RootPath`: The directory to start searching from (default: current directory)
- `-OutputFile`: The file to save the results to (default: git_repos_ssh_urls.txt)

## Output Format

The script generates two types of output:

1. Console output: A formatted table showing repository paths and their SSH URLs
2. File output: A tab-separated file containing repository paths and SSH URLs

## Example Output

```
Repository                          SSHUrl
----------                          ------
C:\repos\project1                   git@github.com:username/project1.git
C:\repos\project2                   git@github.com:username/project2.git
```

## Notes

- The script automatically converts GitHub HTTPS URLs to SSH format
- Repositories without remote URLs are skipped
- Error handling ensures the script continues even if individual repositories have issues
