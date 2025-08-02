# Start-ScriptAnalysis.ps1
# Main commandlet for script analysis

<#
.SYNOPSIS
    Analyze script files in a directory

.DESCRIPTION
    Scans a directory for script files and provides detailed statistics
    including file types, languages, and code metrics.

.PARAMETER Path
    The directory path to analyze. Defaults to current directory.

.PARAMETER MaxDepth
    Maximum directory depth to scan. -1 for unlimited.

.PARAMETER IncludeHidden
    Include hidden files and directories.

.PARAMETER ExcludePatterns
    Array of patterns to exclude (wildcards).

.PARAMETER OutputFormat
    Output format: Console, JSON, CSV

.PARAMETER ExportPath
    Path to export results (for JSON/CSV output).

.PARAMETER ShowProgress
    Show progress during analysis.

.EXAMPLE
    Start-ScriptAnalysis -Path "C:\MyProject"

.EXAMPLE
    Start-ScriptAnalysis -Path "C:\MyProject" -MaxDepth 3 -OutputFormat JSON -ExportPath "results.json"

.EXAMPLE
    Start-ScriptAnalysis -ExcludePatterns "*.tmp", "node_modules" -ShowProgress
#>

function Start-ScriptAnalysis {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string] $Path = ".",

        [Parameter()]
        [int] $MaxDepth = -1,

        [Parameter()]
        [switch] $IncludeHidden,

        [Parameter()]
        [string[]] $ExcludePatterns = @(),

        [Parameter()]
        [ValidateSet("Console", "JSON", "CSV")]
        [string] $OutputFormat = "Console",

        [Parameter()]
        [string] $ExportPath,

        [Parameter()]
        [switch] $ShowProgress,

        [Parameter()]
        [ValidateSet("Debug", "Info", "Warning", "Error")]
        [string] $LogLevel = "Info",

        [Parameter()]
        [string] $LogFilePath,

        [Parameter()]
        [switch] $ShowCategory,

        [Parameter()]
        [switch] $ShowTree,

        [Parameter()]
        [switch] $ShowFileCounts,

        [Parameter()]
        [switch] $ShowFileTypes
    )

    try {
        # Import required classes
        . .\Classes\Config.ps1
        . .\Classes\DisplayUtils.ps1
        . .\Classes\Logger.ps1
        . .\Classes\ConfigValidator.ps1
        . .\Classes\ErrorHandler.ps1
        . .\Classes\FileInfo.ps1
        . .\Classes\ScriptAnalyzer.ps1

        # Create configuration
        $config = [ScriptAnalysisConfig]::new()
        $config.MaxDepth = $MaxDepth
        $config.IncludeHidden = $IncludeHidden
        $config.ShowProgress = $ShowProgress
        $config.OutputFormat = $OutputFormat
        $config.LogLevel = $LogLevel
        $config.LogFilePath = $LogFilePath

        # Add custom exclude patterns
        if ($ExcludePatterns.Count -gt 0) {
            $config.ExcludePatterns += $ExcludePatterns
        }

        # Create analyzer and run analysis
        $analyzer = [ScriptAnalyzer]::new($Path, $config)
        $analyzer.Analyze()

        # Handle output
        switch ($OutputFormat) {
            "Console" {
                if ($ShowTree) {
                    Show-DirectoryTreeInternal $analyzer $ShowFileCounts $ShowFileTypes
                } else {
                    $analyzer.ShowStatistics($ShowCategory)
                }
            }
            "JSON" {
                $jsonOutput = $analyzer.ExportToJSON()
                if ($ExportPath) {
                    $jsonOutput | Out-File -FilePath $ExportPath -Encoding UTF8
                    Write-Host "Results exported to: $ExportPath" -ForegroundColor Green
                } else {
                    return $jsonOutput
                }
            }
            "CSV" {
                $csvOutput = $analyzer.ExportToCSV()
                if ($ExportPath) {
                    $csvOutput | Out-File -FilePath $ExportPath -Encoding UTF8
                    Write-Host "Results exported to: $ExportPath" -ForegroundColor Green
                } else {
                    return $csvOutput
                }
            }
        }

        return $analyzer
    }
    catch {
        Write-Error "Analysis failed: $_"
        throw
    }
}

# Show directory tree structure
function Show-DirectoryTreeInternal([ScriptAnalyzer] $analyzer, [bool] $showFileCounts, [bool] $showFileTypes) {
        $rootName = Split-Path $analyzer.TargetDirectory -Leaf
        if ([string]::IsNullOrEmpty($rootName)) {
            $rootName = $analyzer.TargetDirectory
        }

        Write-Host "`nDirectory Tree: $($analyzer.TargetDirectory)" -ForegroundColor Cyan
        Write-Host ("=" * (20 + $rootName.Length)) -ForegroundColor Cyan
        Write-Host ""

        # Display root
        Write-Host "$rootName" -ForegroundColor Yellow

        # Group files by directory
        $filesByDir = @{}
        foreach ($file in $analyzer.Files) {
            $relativePath = $file.GetRelativePath($analyzer.TargetDirectory)
            $directory = Split-Path $relativePath -Parent
            if ([string]::IsNullOrEmpty($directory)) {
                $directory = "."
            }

            if (-not $filesByDir.ContainsKey($directory)) {
                $filesByDir[$directory] = @()
            }
            $filesByDir[$directory] += $file
        }

        # Display directories and files
        $sortedDirs = $filesByDir.Keys | Sort-Object
        foreach ($dir in $sortedDirs) {
            if ($dir -eq ".") { continue }

            $displayName = Split-Path $dir -Leaf
            $fileCount = $filesByDir[$dir].Count
            $indent = "  " * (($dir -split '\\').Count - 1)

            $dirLine = "$indent├── $displayName"
            if ($showFileCounts -and $fileCount -gt 0) {
                $dirLine += " ($fileCount files)"
            }
            Write-Host $dirLine -ForegroundColor Blue

            # Display files in this directory
            $files = $filesByDir[$dir] | Sort-Object FileName
            $fileIndent = "  " * (($dir -split '\\').Count)

            foreach ($file in $files) {
                $fileLine = "$fileIndent├── $($file.FileName)"

                if ($showFileTypes) {
                    $fileLine += " ($($file.Language))"
                }

                if ($showFileCounts) {
                    $fileLine += " - $($file.GetFormattedSize()), $($file.Metadata.LinesOfCode) lines"
                }

                Write-Host $fileLine -ForegroundColor White
            }
        }

        # Display root files
        if ($filesByDir.ContainsKey(".")) {
            $files = $filesByDir["."] | Sort-Object FileName
            foreach ($file in $files) {
                $fileLine = "  ├── $($file.FileName)"

                if ($showFileTypes) {
                    $fileLine += " ($($file.Language))"
                }

                if ($showFileCounts) {
                    $fileLine += " - $($file.GetFormattedSize()), $($file.Metadata.LinesOfCode) lines"
                }

                Write-Host $fileLine -ForegroundColor White
            }
        }

        Write-Host ""
        Write-Host "Summary:" -ForegroundColor Green
        Write-Host "  Total Files: $($analyzer.Statistics.TotalFiles)" -ForegroundColor White
        Write-Host "  Total Size: $($analyzer.FormatSize($analyzer.Statistics.TotalSize))" -ForegroundColor White
        Write-Host "  Total Lines: $($analyzer.Statistics.TotalLines) lines" -ForegroundColor White
        Write-Host ""
    }
