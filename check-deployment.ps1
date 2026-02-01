# Script to check GitHub Pages deployment status

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GitHub Pages Deployment Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Checking local repository status..." -ForegroundColor Yellow
$status = git status --short
if ($status) {
    Write-Host "   WARNING: You have uncommitted changes:" -ForegroundColor Yellow
    Write-Host $status -ForegroundColor Gray
    Write-Host "   Commit and push these changes first" -ForegroundColor White
} else {
    Write-Host "   OK: Working tree is clean" -ForegroundColor Green
}

Write-Host ""
Write-Host "2. Checking recent commits..." -ForegroundColor Yellow
$lastCommit = git log --oneline -1
Write-Host "   Latest commit: $lastCommit" -ForegroundColor Gray

Write-Host ""
Write-Host "3. Checking if changes are pushed..." -ForegroundColor Yellow
$unpushed = git log origin/main..HEAD --oneline
if ($unpushed) {
    Write-Host "   WARNING: You have unpushed commits:" -ForegroundColor Yellow
    Write-Host $unpushed -ForegroundColor Gray
    Write-Host "   Run: git push origin main" -ForegroundColor White
} else {
    Write-Host "   OK: All commits are pushed" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "If your commits are pushed, check GitHub:" -ForegroundColor White
Write-Host "1. Go to repository Settings -> Pages" -ForegroundColor Cyan
Write-Host "2. Verify Source is set to GitHub Actions" -ForegroundColor White
Write-Host "3. Check Actions tab for workflow runs" -ForegroundColor Cyan
Write-Host "4. Look for any workflow errors" -ForegroundColor White
Write-Host ""
Write-Host "To trigger a new deployment:" -ForegroundColor Yellow
Write-Host "  git commit --allow-empty -m Trigger deployment" -ForegroundColor Gray
Write-Host "  git push origin main" -ForegroundColor Gray
Write-Host ""
