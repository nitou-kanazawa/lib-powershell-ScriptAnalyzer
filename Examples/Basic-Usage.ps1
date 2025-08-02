# Basic-Usage.ps1
# Basic usage examples for ScriptAnalyzer

<#
.SYNOPSIS
    Basic usage examples for ScriptAnalyzer

.DESCRIPTION
    Demonstrates basic functionality of ScriptAnalyzer using the new Start-ScriptAnalysis commandlet.

.EXAMPLE
    .\Examples\Basic-Usage.ps1
#>

Write-Host "=== ScriptAnalyzer Basic Usage Examples ===" -ForegroundColor Green
Write-Host ""

# Load the main commandlet
. .\Functions\Start-ScriptAnalysis.ps1

# Example 1: Basic analysis of current directory
Write-Host "Example 1: Basic Analysis" -ForegroundColor Yellow
Write-Host "Analyzing current directory..." -ForegroundColor Cyan

try {
    Start-ScriptAnalysis -Path "." -ShowProgress
    Write-Host "Basic analysis completed!" -ForegroundColor Green
} catch {
    Write-Host "Error in basic analysis: $_" -ForegroundColor Red
}

Write-Host ""

# Example 2: Analysis with custom settings
Write-Host "Example 2: Custom Settings" -ForegroundColor Yellow
Write-Host "Analyzing with custom settings..." -ForegroundColor Cyan

try {
    Start-ScriptAnalysis -Path "." -MaxDepth 2 -ExcludePatterns "*.tmp", "*.log" -ShowProgress
    Write-Host "Custom analysis completed!" -ForegroundColor Green
} catch {
    Write-Host "Error in custom analysis: $_" -ForegroundColor Red
}

Write-Host ""

# Example 3: Analysis with category display
Write-Host "Example 3: Category Display" -ForegroundColor Yellow
Write-Host "Showing category statistics..." -ForegroundColor Cyan

try {
    Start-ScriptAnalysis -Path "." -ShowCategory -ShowProgress
    Write-Host "Category analysis completed!" -ForegroundColor Green
} catch {
    Write-Host "Error in category analysis: $_" -ForegroundColor Red
}

Write-Host ""

# Example 4: Directory tree display
Write-Host "Example 4: Directory Tree" -ForegroundColor Yellow
Write-Host "Showing directory tree structure..." -ForegroundColor Cyan

try {
    Start-ScriptAnalysis -Path "." -ShowTree -ShowFileCounts -ShowFileTypes
    Write-Host "Tree display completed!" -ForegroundColor Green
} catch {
    Write-Host "Error in tree display: $_" -ForegroundColor Red
}

Write-Host ""

# Example 5: Export to JSON
Write-Host "Example 5: Export to JSON" -ForegroundColor Yellow
Write-Host "Exporting results to JSON..." -ForegroundColor Cyan

try {
    $jsonPath = ".\analysis_results.json"
    Start-ScriptAnalysis -Path "." -OutputFormat JSON -ExportPath $jsonPath
    Write-Host "Results exported to: $jsonPath" -ForegroundColor Green
} catch {
    Write-Host "Error exporting to JSON: $_" -ForegroundColor Red
}

Write-Host ""

# Example 6: Debug logging
Write-Host "Example 6: Debug Logging" -ForegroundColor Yellow
Write-Host "Running with debug logging..." -ForegroundColor Cyan

try {
    Start-ScriptAnalysis -Path "." -LogLevel Debug -LogFilePath ".\debug.log"
    Write-Host "Debug analysis completed! Check debug.log for details." -ForegroundColor Green
} catch {
    Write-Host "Error in debug analysis: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== All Examples Completed ===" -ForegroundColor Green
