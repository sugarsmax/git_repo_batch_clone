# Script to batch clone Git repositories
param(
    [Parameter(Mandatory=$false)]
    [string]$InputFile = "git_repos_ssh_urls.txt",
    
    [Parameter(Mandatory=$false)]
    [string]$TargetDirectory = (Get-Location).Path,
    
    [Parameter(Mandatory=$false)]
    [switch]$ParallelClone,
    
    [Parameter(Mandatory=$false)]
    [int]$MaxParallelJobs = 3
)

# Create target directory if it doesn't exist
if (-not (Test-Path $TargetDirectory)) {
    New-Item -ItemType Directory -Path $TargetDirectory | Out-Null
}

# Function to clone a single repository
function Clone-Repository {
    param(
        [string]$RepoUrl,
        [string]$TargetDir
    )
    
    # Extract repo name from SSH URL
    $repoName = $RepoUrl -replace '.*[:/]([^/]+)\.git$','$1'
    $targetPath = Join-Path $TargetDir $repoName
    
    # Skip if directory already exists
    if (Test-Path $targetPath) {
        Write-Host "Repository '$repoName' already exists at $targetPath - Skipping" -ForegroundColor Yellow
        return
    }
    
    Write-Host "Cloning $repoName..." -ForegroundColor Cyan
    try {
        git clone $RepoUrl $targetPath 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Successfully cloned $repoName" -ForegroundColor Green
        } else {
            Write-Host "Failed to clone $repoName" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error cloning $repoName: $_" -ForegroundColor Red
    }
}

# Check if input file exists
if (-not (Test-Path $InputFile)) {
    Write-Host "Input file not found: $InputFile" -ForegroundColor Red
    exit 1
}

# Read repository URLs
$repos = Get-Content $InputFile | Where-Object { $_ -match '\S' } | ForEach-Object {
    if ($_ -match '\t') {
        # Handle tab-separated format from collect_git_urls script
        $_.Split("`t")[1]
    } else {
        # Handle plain URL format
        $_
    }
}

Write-Host "Found $($repos.Count) repositories to clone" -ForegroundColor Cyan
Write-Host "Target directory: $TargetDirectory" -ForegroundColor Cyan

if ($ParallelClone) {
    Write-Host "Cloning repositories in parallel (max $MaxParallelJobs jobs)..." -ForegroundColor Cyan
    
    $jobs = @()
    foreach ($repo in $repos) {
        # Wait if we've reached max parallel jobs
        while ($jobs.Count -ge $MaxParallelJobs) {
            $jobs = $jobs | Where-Object { $_.State -eq 'Running' }
            Start-Sleep -Seconds 1
        }
        
        # Start new job
        $jobs += Start-Job -ScriptBlock {
            param($RepoUrl, $TargetDir)
            # Define function inside job
            ${function:Clone-Repository} = ${using:function:Clone-Repository}
            Clone-Repository -RepoUrl $RepoUrl -TargetDir $TargetDir
        } -ArgumentList $repo, $TargetDirectory
    }
    
    # Wait for remaining jobs
    Wait-Job $jobs | Out-Null
    Receive-Job $jobs
    Remove-Job $jobs
} else {
    # Sequential cloning
    foreach ($repo in $repos) {
        Clone-Repository -RepoUrl $repo -TargetDir $TargetDirectory
    }
}

Write-Host "Batch cloning completed!" -ForegroundColor Green
