# Script to collect SSH URLs from Git repositories
param(
    [Parameter(Mandatory=$false)]
    [string]$RootPath = (Get-Location).Path,
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "$(Split-Path -Parent $MyInvocation.MyCommand.Path)\git_repo_list_$($env:COMPUTERNAME)_$(Get-Date -Format 'yyyyMMdd_HHmm').txt"
)

# Function to get Git remote URL
function Get-GitRemoteUrl {
    param([string]$RepoPath)
    
    Push-Location $RepoPath
    try {
        $remoteUrl = git config --get remote.origin.url
        if ($remoteUrl) {
            # Convert HTTPS URLs to SSH format if needed
            if ($remoteUrl -match "^https://github\.com/(.+)/(.+)\.git$") {
                $remoteUrl = "git@github.com:$($matches[1])/$($matches[2]).git"
            }
            return $remoteUrl
        }
    }
    catch {
        Write-Warning "Could not get remote URL for $RepoPath"
    }
    finally {
        Pop-Location
    }
    return $null
}

Write-Host "Searching for Git repositories in: $RootPath"
$results = @()

# Find all .git directories
Get-ChildItem -Path $RootPath -Directory -Recurse -Force -ErrorAction SilentlyContinue | 
    Where-Object { $_.Name -eq ".git" } | 
    ForEach-Object {
        $repoPath = $_.Parent.FullName
        $remoteUrl = Get-GitRemoteUrl $repoPath
        if ($remoteUrl) {
            $results += [PSCustomObject]@{
                Repository = $repoPath
                SSHUrl = $remoteUrl
            }
        }
    }

# Output results
if ($results.Count -eq 0) {
    Write-Host "No Git repositories found."
} else {
    Write-Host "Found $($results.Count) repositories:"
    $results | Format-Table -AutoSize
    
    # Save to file
    $results | ForEach-Object { 
        "Repository: $($_.Repository)"
        "SSH URL: $($_.SSHUrl)"
        "" # Empty line between entries
    } | Out-File -FilePath $OutputFile
    Write-Host "Results saved to: $OutputFile"
}
