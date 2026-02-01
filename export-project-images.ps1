# PowerShell script to export images from Microsoft Project file
# This script uses COM automation to open Project and export views as images

param(
    [string]$ProjectPath = "C:\Users\defil\Desktop\Mohawk College\Mohawk Fall 2023\Project Management for IT\Final Project\000823174.mpp",
    [string]$OutputDir = "C:\Repositories\mkdocs\docs\Subjects\images"
)

# Ensure output directory exists
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

Write-Host "Attempting to export images from Microsoft Project..." -ForegroundColor Cyan
Write-Host "Project File: $ProjectPath" -ForegroundColor Yellow
Write-Host "Output Directory: $OutputDir" -ForegroundColor Yellow

try {
    # Open the file with Microsoft Project
    Write-Host "Opening project file in Microsoft Project..." -ForegroundColor Green
    
    if (Test-Path $ProjectPath) {
        Start-Process -FilePath $ProjectPath
        Start-Sleep -Seconds 3
        Write-Host "Project file opened!" -ForegroundColor Green
    } else {
        throw "Project file not found: $ProjectPath"
    }
    
    # List of views and corresponding output filenames
    $viewsToExport = @(
        @{View = "Gantt Chart"; FileName = "pm-project-gantt-overview.png"; Description = "Complete project Gantt chart"},
        @{View = "Gantt Chart"; FileName = "pm-dependency-types.png"; Description = "Gantt chart showing dependency types"},
        @{View = "Resource Sheet"; FileName = "pm-resource-assignments.png"; Description = "Resource assignments view"},
        @{View = "Gantt Chart"; FileName = "pm-baseline-view.png"; Description = "Baseline comparison view"},
        @{View = "Gantt Chart"; FileName = "pm-critical-path-task8.png"; Description = "Critical path Task 8 detail"},
        @{View = "Task Sheet"; FileName = "pm-wbs-structure.png"; Description = "WBS structure view"},
        @{View = "Gantt Chart"; FileName = "pm-split-task.png"; Description = "Split task example"}
    )
    
    Write-Host "`nNote: This script will open Microsoft Project." -ForegroundColor Yellow
    Write-Host "You may need to manually:" -ForegroundColor Yellow
    Write-Host "  1. Switch to the appropriate view" -ForegroundColor Yellow
    Write-Host "  2. Adjust zoom/formatting as needed" -ForegroundColor Yellow
    Write-Host "  3. Use File > Export > Save Project as Picture or take screenshots" -ForegroundColor Yellow
    Write-Host "`nAlternatively, you can manually take screenshots of these views:" -ForegroundColor Cyan
    
    foreach ($viewInfo in $viewsToExport) {
        Write-Host "  - $($viewInfo.FileName): $($viewInfo.Description) ($($viewInfo.View))" -ForegroundColor White
    }
    
    Write-Host "`nProject is now open. Please:" -ForegroundColor Green
    Write-Host "  1. Navigate to each view listed above" -ForegroundColor Green
    Write-Host "  2. Use File > Export > Save Project as Picture" -ForegroundColor Green
    Write-Host "  3. Save to: $OutputDir" -ForegroundColor Green
    Write-Host "  4. Use the filenames listed above" -ForegroundColor Green
    
    # Keep Project open for user to export images
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Microsoft Project should now be open." -ForegroundColor Green
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    Write-Host "Please export the following views as PDF:" -ForegroundColor Yellow
    Write-Host "`n1. Switch to each view listed below" -ForegroundColor White
    Write-Host "2. Go to: File > Export > Save Project as PDF" -ForegroundColor White
    Write-Host "3. Save each PDF temporarily (we'll convert them to PNG)" -ForegroundColor White
    Write-Host "4. The script will convert PDFs to PNG images automatically`n" -ForegroundColor White
    
    $counter = 1
    foreach ($viewInfo in $viewsToExport) {
        Write-Host "$counter. $($viewInfo.FileName)" -ForegroundColor Cyan
        Write-Host "   View: $($viewInfo.View)" -ForegroundColor Gray
        Write-Host "   Description: $($viewInfo.Description)`n" -ForegroundColor Gray
        $counter++
    }
    
    Write-Host "`nAfter exporting PDFs, press any key to convert them to PNG images..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    # Try to convert PDFs to PNG using ImageMagick or PowerShell
    Write-Host "`nAttempting to convert PDFs to PNG..." -ForegroundColor Cyan
    
    $tempPdfDir = Join-Path $env:TEMP "ProjectExports"
    if (-not (Test-Path $tempPdfDir)) {
        New-Item -ItemType Directory -Path $tempPdfDir -Force | Out-Null
    }
    
    # Check for ImageMagick
    $magickPath = Get-Command magick -ErrorAction SilentlyContinue
    if ($magickPath) {
        Write-Host "Found ImageMagick, converting PDFs..." -ForegroundColor Green
        Get-ChildItem -Path $tempPdfDir -Filter "*.pdf" | ForEach-Object {
            $pdfName = $_.BaseName
            $pngName = "$pdfName.png"
            $outputPath = Join-Path $OutputDir $pngName
            & magick -density 300 "$($_.FullName)" -quality 100 "$outputPath"
            Write-Host "  Converted: $pngName" -ForegroundColor Gray
        }
    } else {
        Write-Host "ImageMagick not found. Alternative options:" -ForegroundColor Yellow
        Write-Host "1. Install ImageMagick from: https://imagemagick.org/script/download.php" -ForegroundColor White
        Write-Host "2. Use online converter: https://www.ilovepdf.com/pdf_to_jpg" -ForegroundColor White
        Write-Host "3. Take screenshots directly (Windows + Shift + S)" -ForegroundColor White
        Write-Host "`nFor now, please manually convert PDFs or take screenshots." -ForegroundColor Yellow
        Write-Host "Save images to: $OutputDir" -ForegroundColor Yellow
        Write-Host "Use these exact filenames:" -ForegroundColor Yellow
        foreach ($viewInfo in $viewsToExport) {
            Write-Host "  - $($viewInfo.FileName)" -ForegroundColor Cyan
        }
    }
    
    Write-Host "`nDone! Images should be in: $OutputDir" -ForegroundColor Green
    
} catch {
    Write-Host "`nError: Could not automate Microsoft Project." -ForegroundColor Red
    Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nManual Instructions:" -ForegroundColor Yellow
    Write-Host "  1. Open Microsoft Project" -ForegroundColor White
    Write-Host "  2. Open the file: $ProjectPath" -ForegroundColor White
    Write-Host "  3. For each view below, switch to it and export:" -ForegroundColor White
    
    foreach ($viewInfo in $viewsToExport) {
        Write-Host "     - $($viewInfo.FileName): Switch to '$($viewInfo.View)' view" -ForegroundColor Cyan
    }
    
    Write-Host "`n  4. Use File > Export > Save Project as Picture" -ForegroundColor White
    Write-Host "  5. Save all images to: $OutputDir" -ForegroundColor White
}
