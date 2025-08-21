# Git Repository Batch Cloner

This collection of scripts enables batch cloning of multiple Git repositories from a list of SSH URLs. Available for both Windows (PowerShell) and macOS/Linux (bash).

## Features

- Clones multiple repositories in sequence or parallel
- Supports both simple URL list and tab-separated format
- Automatically skips existing repositories
- Shows progress and error information
- Configurable parallel job limit

## Usage

### Windows (PowerShell)

#### Basic Usage

1. Open PowerShell
2. Navigate to the script directory
3. Run the script:

```powershell
.\batch_clone_repos_20240321.ps1
```

#### Advanced Usage

```powershell
# Clone with custom input file and target directory
.\batch_clone_repos_20240321.ps1 -InputFile "my_repos.txt" -TargetDirectory "D:\Projects"

# Enable parallel cloning with max 5 concurrent jobs
.\batch_clone_repos_20240321.ps1 -ParallelClone -MaxParallelJobs 5
```

#### Parameters

- `-InputFile`: Path to file containing repository URLs (default: git_repos_ssh_urls.txt)
- `-TargetDirectory`: Directory where repositories will be cloned (default: current directory)
- `-ParallelClone`: Switch to enable parallel cloning
- `-MaxParallelJobs`: Maximum number of concurrent clone operations (default: 3)

### macOS/Linux (Bash)

#### Basic Usage

1. Open Terminal
2. Navigate to the script directory
3. Make the script executable (first time only):

```bash
chmod +x batch_clone_repos_20250103.sh
```

4. Run the script:

```bash
./batch_clone_repos_20250103.sh
```

#### Advanced Usage

```bash
# Clone with custom input file and target directory
./batch_clone_repos_20250103.sh -f "my_repos.txt" -d "/Users/username/Projects"

# Enable parallel cloning with max 5 concurrent jobs
./batch_clone_repos_20250103.sh --parallel --jobs 5

# Full example with all options
./batch_clone_repos_20250103.sh -f git_list_20250821_01.txt -d ~/repositories --parallel -j 4
```

#### Parameters

- `-f, --file`: Input file containing repository URLs (default: git_repos_ssh_urls.txt)
- `-d, --directory`: Target directory for cloning (default: current directory)
- `-p, --parallel`: Enable parallel cloning
- `-j, --jobs`: Maximum number of parallel jobs (default: 3)
- `-h, --help`: Display help message

## Input File Format

The script supports two formats:

1. Simple URL list:
```
git@github.com:user/repo1.git
git@github.com:user/repo2.git
```

2. Tab-separated format (output from collect_git_urls script):
```
/path/to/repo1    git@github.com:user/repo1.git
/path/to/repo2    git@github.com:user/repo2.git
```

## Notes

- The script automatically creates the target directory if it doesn't exist
- Existing repositories are skipped to prevent conflicts
- Progress is color-coded for better visibility:
  - Green: Success
  - Yellow: Skip (already exists)
  - Red: Error
  - Cyan: Information/Progress

## Tips

### Windows (PowerShell)
- For faster cloning of many repositories, use the `-ParallelClone` switch
- Adjust `-MaxParallelJobs` based on your internet connection and system capabilities

### macOS/Linux (Bash)
- For faster cloning of many repositories, use the `--parallel` flag
- Adjust `--jobs` parameter based on your internet connection and system capabilities
- Use `./batch_clone_repos_20250103.sh --help` to see all available options

### General
- Keep the input file format simple, one URL per line
- Both scripts work with the same input file formats
- SSH keys must be properly configured for Git authentication
