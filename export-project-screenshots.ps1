# PowerShell script to help export screenshots from Microsoft Project file
# Uses Windows Snipping Tool for easy screenshot capture

param(
    [string]$ProjectPath = "C:\Users\defil\Desktop\Mohawk College\Mohawk Fall 2023\Project Management for IT\Final Project\000823174.mpp",
    [string]$OutputDir = "C:\Repositories\mkdocs\docs\Subjects\images"
)

# Ensure output directory exists
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Microsoft Project Screenshot Helper" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Opening project file..." -ForegroundColor Green
if (Test-Path $ProjectPath) {
    Start-Process -FilePath $ProjectPath
    Start-Sleep -Seconds 3
    Write-Host "Project file opened!" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "ERROR: Project file not found: $ProjectPath" -ForegroundColor Red
    exit 1
}

# List of views and corresponding output filenames
$viewsToExport = @(
    @{View = "Gantt Chart"; FileName = "pm-project-gantt-overview.png"; Description = "Complete project Gantt chart - show all tasks"},
    @{View = "Gantt Chart"; FileName = "pm-dependency-types.png"; Description = "Gantt chart showing dependency types (FS, SS, FF, SF) with arrows visible"},
    @{View = "Resource Sheet or Resource Usage"; FileName = "pm-resource-assignments.png"; Description = "Resource assignments showing Marcello and Pat"},
    @{View = "Gantt Chart"; FileName = "pm-baseline-view.png"; Description = "Gantt chart with baseline bars visible (gray bars behind blue bars)"},
    @{View = "Gantt Chart"; FileName = "pm-critical-path-task8.png"; Description = "Gantt chart zoomed to Task 8 showing critical path and 50% completion"},
    @{View = "Task Sheet or Outline"; FileName = "pm-wbs-structure.png"; Description = "WBS structure showing hierarchical levels (1, 1.1, 1.1.1)"},
    @{View = "Gantt Chart"; FileName = "pm-split-task.png"; Description = "Gantt chart showing a split task with gap in task bar"}
)

Write-Host "========================================" -ForegroundColor Yellow
Write-Host "SCREENSHOT INSTRUCTIONS" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

Write-Host "For each view below:" -ForegroundColor White
Write-Host "1. Switch to the view in Microsoft Project" -ForegroundColor White
Write-Host "2. Press Windows + Shift + S to open Snipping Tool" -ForegroundColor White
Write-Host "3. Select the area you want to capture" -ForegroundColor White
Write-Host "4. The screenshot will be copied to clipboard" -ForegroundColor White
Write-Host "5. Open Paint (or any image editor)" -ForegroundColor White
Write-Host "6. Paste (Ctrl+V) and save as PNG" -ForegroundColor White
Write-Host ""

Write-Host "OR use the built-in Snipping Tool:" -ForegroundColor Cyan
Write-Host "1. Press Windows key, type 'Snipping Tool', press Enter" -ForegroundColor White
Write-Host "2. Click 'New' to capture" -ForegroundColor White
Write-Host "3. Save directly as PNG" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "VIEWS TO CAPTURE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$counter = 1
foreach ($viewInfo in $viewsToExport) {
    Write-Host "$counter. Filename: $($viewInfo.FileName)" -ForegroundColor Green
    Write-Host "   View: $($viewInfo.View)" -ForegroundColor Yellow
    Write-Host "   Description: $($viewInfo.Description)" -ForegroundColor Gray
    Write-Host "   Save to: $OutputDir\$($viewInfo.FileName)" -ForegroundColor Cyan
    Write-Host ""
    $counter++
}

Write-Host "========================================" -ForegroundColor Yellow
Write-Host "IMPORTANT:" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "Save all screenshots with the EXACT filenames shown above" -ForegroundColor White
Write-Host "Save location: $OutputDir" -ForegroundColor White
Write-Host ""

Write-Host "Press any key when you've finished taking all screenshots..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host ""
Write-Host "Checking for saved images..." -ForegroundColor Cyan
$missingImages = @()
foreach ($viewInfo in $viewsToExport) {
    $imagePath = Join-Path $OutputDir $viewInfo.FileName
    if (Test-Path $imagePath) {
        Write-Host "  Found: $($viewInfo.FileName)" -ForegroundColor Green
    } else {
        Write-Host "  Missing: $($viewInfo.FileName)" -ForegroundColor Red
        $missingImages += $viewInfo.FileName
    }
}

if ($missingImages.Count -eq 0) {
    Write-Host ""
    Write-Host "All images found! Your documentation is ready." -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Missing images:" -ForegroundColor Yellow
    foreach ($missing in $missingImages) {
        Write-Host "  - $missing" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "Please capture and save the missing images." -ForegroundColor Yellow
}
