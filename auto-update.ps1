# AutoFish Pro - Auto Update Script
# Automatically commits and pushes changes to GitHub repository

param(
    [string]$CommitMessage = "Auto-update: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    [switch]$DryRun = $false,
    [switch]$Force = $false
)

# Configuration
$GitPath = "C:\Git\cmd\git.exe"
$RepoPath = "D:\ssciprtgame\New folder"
$Branch = "main"

# Colors for output
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Success { Write-ColorOutput Green $args }
function Write-Warning { Write-ColorOutput Yellow $args }
function Write-Error { Write-ColorOutput Red $args }
function Write-Info { Write-ColorOutput Cyan $args }

# Check if Git exists
if (-not (Test-Path $GitPath)) {
    Write-Error "Git not found at: $GitPath"
    Write-Error "Please install Git or update the GitPath variable"
    exit 1
}

# Check if we're in a git repository
Set-Location $RepoPath
$gitStatus = & $GitPath status --porcelain 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Error "Not a git repository or git error occurred"
    exit 1
}

Write-Success "AutoFish Pro - Auto Update Script"
Write-Info "Repository: $RepoPath"
Write-Info "Branch: $Branch"
Write-Info "Commit Message: $CommitMessage"

if ($DryRun) {
    Write-Warning "DRY RUN MODE - No changes will be made"
}

# Check for changes
$changes = & $GitPath status --porcelain
if (-not $changes) {
    Write-Info "No changes detected. Repository is up to date."
    exit 0
}

Write-Info "Changes detected:"
$changes | ForEach-Object {
    $status = $_.Substring(0, 2)
    $file = $_.Substring(3)
    
    switch ($status.Trim()) {
        "M" { Write-Info "  [M] Modified: $file" }
        "A" { Write-Info "  [A] Added: $file" }
        "D" { Write-Info "  [D] Deleted: $file" }
        "R" { Write-Info "  [R] Renamed: $file" }
        "??" { Write-Info "  [?] Untracked: $file" }
        default { Write-Info "  [*] Changed: $file" }
    }
}

if ($DryRun) {
    Write-Warning "DRY RUN: Would commit and push these changes"
    exit 0
}

# Confirm before proceeding (unless Force is used)
if (-not $Force) {
    $confirm = Read-Host "Do you want to commit and push these changes? (y/N)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-Info "Operation cancelled by user"
        exit 0
    }
}

Write-Info "Starting auto-update process..."

try {
    # Stage all changes
    Write-Info "Staging changes..."
    & $GitPath add .
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to stage changes"
    }
    
    # Commit changes
    Write-Info "Committing changes..."
    & $GitPath commit -m $CommitMessage
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to commit changes"
    }
    
    # Push to remote
    Write-Info "Pushing to remote repository..."
    & $GitPath push origin $Branch
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to push to remote repository"
    }
    
    Write-Success "Auto-update completed successfully!"
    Write-Success "Changes have been pushed to GitHub repository"
    
    # Show final status
    Write-Info "Final repository status:"
    & $GitPath status --short
    
} catch {
    Write-Error "Auto-update failed: $_"
    Write-Error "Please check the error and try again"
    exit 1
}

Write-Success "AutoFish Pro repository updated successfully!"
