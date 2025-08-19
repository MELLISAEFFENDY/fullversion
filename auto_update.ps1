# AutoFish Pro - Auto Update Script
# Automatically commits and pushes changes to GitHub repository

param(
    [string]$commitMessage = "",
    [switch]$force = $false,
    [switch]$help = $false
)

# Display help
if ($help) {
    Write-Host "AutoFish Pro Auto Update Script" -ForegroundColor Cyan
    Write-Host "Usage: .\auto_update.ps1 [-commitMessage 'message'] [-force] [-help]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor Green
    Write-Host "  -commitMessage  Custom commit message (optional)" -ForegroundColor White
    Write-Host "  -force          Force push even if there are conflicts" -ForegroundColor White
    Write-Host "  -help           Show this help message" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Green
    Write-Host "  .\auto_update.ps1" -ForegroundColor Gray
    Write-Host "  .\auto_update.ps1 -commitMessage 'Added new features'" -ForegroundColor Gray
    Write-Host "  .\auto_update.ps1 -force" -ForegroundColor Gray
    exit 0
}

# Color functions
function Write-Success {
    param([string]$message)
    Write-Host "✅ $message" -ForegroundColor Green
}

function Write-Info {
    param([string]$message)
    Write-Host "ℹ️  $message" -ForegroundColor Cyan
}

function Write-Warning {
    param([string]$message)
    Write-Host "⚠️  $message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$message)
    Write-Host "❌ $message" -ForegroundColor Red
}

# Header
Clear-Host
Write-Host "🚀 AutoFish Pro - Auto Update Script" -ForegroundColor Magenta
Write-Host "═══════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""

# Check if we're in a git repository
if (-not (Test-Path ".git")) {
    Write-Error "This directory is not a Git repository!"
    Write-Info "Please run 'git init' first or navigate to the correct directory."
    exit 1
}

# Check git status
Write-Info "Checking git status..."
$gitStatus = git status --porcelain

if ($gitStatus.Length -eq 0) {
    Write-Warning "No changes detected in the repository."
    Write-Info "Repository is already up to date."
    exit 0
}

# Show changed files
Write-Info "Changed files detected:"
git status --short
Write-Host ""

# Generate automatic commit message if not provided
if ([string]::IsNullOrEmpty($commitMessage)) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    # Analyze changes to create smart commit message
    $addedFiles = (git diff --cached --name-only --diff-filter=A) -split "`n" | Where-Object { $_ }
    $modifiedFiles = (git diff --cached --name-only --diff-filter=M) -split "`n" | Where-Object { $_ }
    $deletedFiles = (git diff --cached --name-only --diff-filter=D) -split "`n" | Where-Object { $_ }
    
    # Check unstaged changes
    $unstagedFiles = (git diff --name-only) -split "`n" | Where-Object { $_ }
    
    # Create smart commit message
    $changes = @()
    if ($addedFiles.Count -gt 0) { $changes += "Added $($addedFiles.Count) files" }
    if ($modifiedFiles.Count -gt 0) { $changes += "Modified $($modifiedFiles.Count) files" }
    if ($deletedFiles.Count -gt 0) { $changes += "Deleted $($deletedFiles.Count) files" }
    if ($unstagedFiles.Count -gt 0) { $changes += "Updated $($unstagedFiles.Count) files" }
    
    if ($changes.Count -gt 0) {
        $commitMessage = "🔄 Auto-update: " + ($changes -join ", ") + " - $timestamp"
    } else {
        $commitMessage = "🔄 Auto-update: General improvements - $timestamp"
    }
}

Write-Info "Commit message: $commitMessage"
Write-Host ""

try {
    # Stage all changes
    Write-Info "Staging all changes..."
    git add .
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to stage changes!"
        exit 1
    }
    
    Write-Success "Changes staged successfully"
    
    # Commit changes
    Write-Info "Committing changes..."
    git commit -m $commitMessage
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to commit changes!"
        exit 1
    }
    
    Write-Success "Changes committed successfully"
    
    # Check remote repository
    $remoteUrl = git remote get-url origin 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "No remote repository configured."
        Write-Info "Add remote with: git remote add origin [repository-url]"
        exit 1
    }
    
    Write-Info "Remote repository: $remoteUrl"
    
    # Push to remote
    Write-Info "Pushing to remote repository..."
    
    if ($force) {
        Write-Warning "Force pushing to remote..."
        git push origin main --force
    } else {
        git push origin main
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to push to remote repository!"
        Write-Warning "Possible solutions:"
        Write-Host "  1. Pull latest changes: git pull origin main" -ForegroundColor Gray
        Write-Host "  2. Force push: .\auto_update.ps1 -force" -ForegroundColor Gray
        Write-Host "  3. Check repository permissions" -ForegroundColor Gray
        exit 1
    }
    
    Write-Success "Successfully pushed to remote repository!"
    
    # Show final status
    Write-Host ""
    Write-Host "📊 Update Summary:" -ForegroundColor Green
    Write-Host "  Commit: $commitMessage" -ForegroundColor White
    Write-Host "  Remote: $remoteUrl" -ForegroundColor White
    Write-Host "  Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
    
} catch {
    Write-Error "An unexpected error occurred: $($_.Exception.Message)"
    exit 1
}

Write-Host ""
Write-Success "🎉 Repository updated successfully!"
Write-Info "Your changes are now live on GitHub!"
