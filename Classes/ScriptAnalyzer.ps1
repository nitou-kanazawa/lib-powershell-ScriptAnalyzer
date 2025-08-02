# ScriptAnalyzer.ps1
# Main Script Analyzer Class

<#
.SYNOPSIS
    Main script analyzer class for analyzing script files in directories

.DESCRIPTION
    Scans directories for script files, analyzes them, and provides statistics.
    Supports various file types and provides detailed analysis results.

.EXAMPLE
    $analyzer = [ScriptAnalyzer]::new("C:\MyProject")
    $analyzer.Analyze()
    $analyzer.ShowStatistics()
#>

# Load DisplayUtils class
# Note: DisplayUtils is loaded by Start-ScriptAnalysis.ps1

class ScriptAnalyzer {
    # Properties
    [string] $TargetDirectory              # Target directory to analyze
    [ScriptAnalysisConfig] $Config         # Analysis configuration
    [FileInfo[]] $Files                    # Analyzed files
    [hashtable] $Statistics                # Analysis statistics
    [datetime] $AnalysisStartTime          # Analysis start time
    [datetime] $AnalysisEndTime            # Analysis end time
    [Logger] $Logger                       # Logger instance
    [ErrorHandler] $ErrorHandler           # Error handler instance
    [hashtable] $PerformanceMetrics        # Performance monitoring data

    # Constructor
    ScriptAnalyzer([string] $directory) {
        $this.Initialize($directory, $null)
    }

    ScriptAnalyzer([string] $directory, [ScriptAnalysisConfig] $config) {
        $this.Initialize($directory, $config)
    }

    # Initialize the analyzer
    hidden [void] Initialize([string] $directory, [ScriptAnalysisConfig] $config) {
        if ([string]::IsNullOrEmpty($directory)) {
            throw "Directory path cannot be null or empty"
        }

        if (-not (Test-Path $directory)) {
            throw "Directory does not exist: $directory"
        }

        $this.TargetDirectory = (Get-Item $directory).FullName

        # Use default config if none provided
        if ($null -eq $config) {
            $this.Config = [ScriptAnalysisConfig]::new()
        } else {
            $this.Config = $config
        }

        # Validate configuration
        if (-not $this.Config.Validate()) {
            throw "Invalid configuration"
        }

        # Initialize logger and error handler
        $this.Logger = [Logger]::new($this.Config.LogLevel, $this.Config.LogFilePath)
        $this.ErrorHandler = [ErrorHandler]::new($this.Logger, $true)

        # Initialize collections
        $this.Files = @()
        $this.Statistics = @{
            TotalFiles = 0
            TotalSize = 0
            TotalLines = 0
            Languages = @{}
            Categories = @{}
            FileTypes = @{}
            AnalysisTime = [timespan]::Zero
        }
        $this.PerformanceMetrics = @{
            StartMemory = 0
            PeakMemory = 0
            EndMemory = 0
            FileProcessingTimes = @()
            BatchProcessingTimes = @()
        }
    }

    # Analyze the target directory
    [void] Analyze() {
        $this.AnalysisStartTime = Get-Date

        # Initialize performance monitoring
        $this.PerformanceMetrics.StartMemory = [System.GC]::GetTotalMemory($false)
        $this.PerformanceMetrics.PeakMemory = $this.PerformanceMetrics.StartMemory

        $this.Logger.Info("Starting analysis of: $($this.TargetDirectory)")

        if ($this.Config.ShowProgress) {
            Write-Host "Starting analysis of: $($this.TargetDirectory)" -ForegroundColor Green
        }

        try {
            # Get all files in the directory
            $allFiles = $this.GetAllFiles($this.TargetDirectory)

            $this.Logger.Info("Found $($allFiles.Count) files to analyze")
            if ($this.Config.ShowProgress) {
                Write-Host "Found $($allFiles.Count) files to analyze..." -ForegroundColor Yellow
            }

            # Process files in batches for better performance
            $processedCount = 0
            $batchSize = 50  # Process 50 files at a time
            $totalFiles = $allFiles.Count

            for ($i = 0; $i -lt $totalFiles; $i += $batchSize) {
                $batch = $allFiles | Select-Object -Skip $i -First $batchSize

                foreach ($filePath in $batch) {
                    $processedCount++

                    if ($this.Config.ShowProgress -and $processedCount % 10 -eq 0) {
                        $percent = [math]::Round(($processedCount / $totalFiles) * 100, 1)
                        Write-Progress -Activity "Analyzing files" -Status "Processing $processedCount of $totalFiles" -PercentComplete $percent
                        $this.Logger.LogProgress("File Analysis", $processedCount, $totalFiles)
                    }

                    if ($this.ShouldAnalyzeFile($filePath)) {
                        $fileStartTime = Get-Date
                        try {
                            $fileInfo = [FileInfo]::new($filePath, $this.Config)
                            $this.Files += $fileInfo
                            $this.UpdateStatistics($fileInfo)

                            # Record file processing time
                            $fileProcessingTime = (Get-Date) - $fileStartTime
                            $this.PerformanceMetrics.FileProcessingTimes += $fileProcessingTime
                        } catch {
                            $this.ErrorHandler.HandleFileError($filePath, $_)
                        }

                        # Update peak memory usage
                        $currentMemory = [System.GC]::GetTotalMemory($false)
                        if ($currentMemory -gt $this.PerformanceMetrics.PeakMemory) {
                            $this.PerformanceMetrics.PeakMemory = $currentMemory
                        }
                    }
                }
            }

            if ($this.Config.ShowProgress) {
                Write-Progress -Activity "Analyzing files" -Completed
                Write-Host "Analysis completed successfully!" -ForegroundColor Green
            }

        } catch {
            throw "Analysis failed: $_"
        } finally {
            $this.AnalysisEndTime = Get-Date
            $this.Statistics.AnalysisTime = $this.AnalysisEndTime - $this.AnalysisStartTime

            # Finalize performance monitoring
            $this.PerformanceMetrics.EndMemory = [System.GC]::GetTotalMemory($false)

            # Log performance metrics
            $this.Logger.LogPerformance("Total Analysis", $this.Statistics.AnalysisTime)
            $this.Logger.Info("Memory Usage - Start: $([math]::Round($this.PerformanceMetrics.StartMemory / 1MB, 2)) MB, Peak: $([math]::Round($this.PerformanceMetrics.PeakMemory / 1MB, 2)) MB, End: $([math]::Round($this.PerformanceMetrics.EndMemory / 1MB, 2)) MB")

            # Log error summary
            $this.ErrorHandler.LogErrorSummary()
        }
    }

    # Get all files in directory recursively
    hidden [string[]] GetAllFiles([string] $directory) {
        $searchOption = if ($this.Config.MaxDepth -eq -1) { "AllDirectories" } else { "TopDirectoryOnly" }

        $fileArray = @()

        try {
            if ($this.Config.MaxDepth -eq -1) {
                # Unlimited depth
                $fileArray = Get-ChildItem -Path $directory -File -Recurse -Force:$this.Config.IncludeHidden
            } else {
                # Limited depth
                $fileArray = $this.GetFilesWithDepthLimit($directory, 0)
            }

            return $fileArray | ForEach-Object { $_.FullName }
        } catch {
            Write-Warning "Error scanning directory $directory : $_"
            return @()
        }
    }

    # Get files with depth limit
    hidden [System.IO.FileInfo[]] GetFilesWithDepthLimit([string] $directory, [int] $currentDepth) {
        if ($currentDepth -gt $this.Config.MaxDepth) {
            return @()
        }

        $fileArray = @()

        try {
            $items = Get-ChildItem -Path $directory -Force:$this.Config.IncludeHidden

            foreach ($item in $items) {
                if ($item.PSIsContainer) {
                    # Directory
                    if ($currentDepth -lt $this.Config.MaxDepth) {
                        $subFiles = $this.GetFilesWithDepthLimit($item.FullName, $currentDepth + 1)
                        $fileArray += $subFiles
                    }
                } else {
                    # File
                    $fileArray += $item
                }
            }
        } catch {
            Write-Warning "Error scanning directory $directory at depth $currentDepth : $_"
        }

        return $fileArray
    }

    # Check if file should be analyzed
    hidden [bool] ShouldAnalyzeFile([string] $filePath) {
        # Check if file is excluded
        if ($this.Config.IsExcluded($filePath)) {
            return $false
        }

        # Check if file extension is supported
        $extension = [System.IO.Path]::GetExtension($filePath)
        if (-not $this.Config.IsSupportedExtension($extension)) {
            return $false
        }

        return $true
    }

    # Update statistics with file information
    hidden [void] UpdateStatistics([FileInfo] $fileInfo) {
        # Update total counts
        $this.Statistics.TotalFiles++
        $this.Statistics.TotalSize += $fileInfo.Size
        $this.Statistics.TotalLines += $fileInfo.Metadata.LinesOfCode

        # Update language statistics
        $language = $fileInfo.Language
        if (-not $this.Statistics.Languages.ContainsKey($language)) {
            $this.Statistics.Languages[$language] = @{
                Count = 0
                TotalSize = 0
                TotalLines = 0
                Extensions = @{}
            }
        }

        $this.Statistics.Languages[$language].Count++
        $this.Statistics.Languages[$language].TotalSize += $fileInfo.Size
        $this.Statistics.Languages[$language].TotalLines += $fileInfo.Metadata.LinesOfCode

        # Update extension statistics within language
        $extension = $fileInfo.Extension.ToLower()
        if (-not $this.Statistics.Languages[$language].Extensions.ContainsKey($extension)) {
            $this.Statistics.Languages[$language].Extensions[$extension] = 0
        }
        $this.Statistics.Languages[$language].Extensions[$extension]++

        # Update category statistics
        $category = $fileInfo.GetFileCategory()
        if (-not $this.Statistics.Categories.ContainsKey($category)) {
            $this.Statistics.Categories[$category] = @{
                Count = 0
                TotalSize = 0
                TotalLines = 0
            }
        }

        $this.Statistics.Categories[$category].Count++
        $this.Statistics.Categories[$category].TotalSize += $fileInfo.Size
        $this.Statistics.Categories[$category].TotalLines += $fileInfo.Metadata.LinesOfCode

        # Update file type statistics
        $fileType = $fileInfo.Extension.ToLower()
        if (-not $this.Statistics.FileTypes.ContainsKey($fileType)) {
            $this.Statistics.FileTypes[$fileType] = @{
                Count = 0
                TotalSize = 0
                TotalLines = 0
                Language = $language
            }
        }

        $this.Statistics.FileTypes[$fileType].Count++
        $this.Statistics.FileTypes[$fileType].TotalSize += $fileInfo.Size
        $this.Statistics.FileTypes[$fileType].TotalLines += $fileInfo.Metadata.LinesOfCode
    }

    # Show analysis statistics
    [void] ShowStatistics() {
        if ($this.Files.Count -eq 0) {
            Write-Host "No files found to analyze." -ForegroundColor Yellow
            return
        }

        $this.ShowHeader()
        $this.ShowLanguageStatistics()
        $this.ShowSummary()
    }

    # Show analysis statistics with category (optional)
    [void] ShowStatistics([bool] $includeCategory) {
        if ($this.Files.Count -eq 0) {
            Write-Host "No files found to analyze." -ForegroundColor Yellow
            return
        }

        $this.ShowHeader()
        $this.ShowLanguageStatistics()
        if ($includeCategory) {
            $this.ShowCategoryStatistics()
        }
        $this.ShowSummary()
    }

    # Show analysis header
    hidden [void] ShowHeader() {
        $title = "Script Analysis Results: $($this.TargetDirectory)"
        $separator = "=" * $title.Length

        Write-Host "`n$title" -ForegroundColor Cyan
        Write-Host $separator -ForegroundColor Cyan
        Write-Host ""
    }

    # Show file type statistics
    hidden [void] ShowFileTypeStatistics() {
        Write-Host "File Type Statistics:" -ForegroundColor Green

        # Sort by count descending
        $sortedTypes = $this.Statistics.FileTypes.GetEnumerator() |
            Sort-Object { $_.Value.Count } -Descending

        foreach ($type in $sortedTypes) {
            $count = $type.Value.Count
            $percentage = [math]::Round(($count / $this.Statistics.TotalFiles) * 100, 1)
            $language = $type.Value.Language
            $extension = $type.Key

            # Format with fixed width columns for proper alignment
            $languageColumn = $language.PadRight(15)  # 15 characters for language name
            $extensionColumn = "($extension)".PadRight(10)  # 10 characters for extension
            $countColumn = $count.ToString().PadLeft(3)  # 3 characters for count
            $percentageColumn = $percentage.ToString("F1").PadLeft(5)  # 5 characters for percentage
            $barLength = [math]::Round(($percentage / 100) * 20)
            $bar = "#" * $barLength

            # Build aligned output using string concatenation
            $output = $languageColumn + $extensionColumn + $countColumn + " files (" + $percentageColumn + "%) " + $bar

            Write-Host $output -ForegroundColor White
        }

        Write-Host ""
    }

    # Show category statistics
    hidden [void] ShowCategoryStatistics() {
        Write-Host "Category Statistics:" -ForegroundColor Green

        # Sort by count descending
        $sortedCategories = $this.Statistics.Categories.GetEnumerator() |
            Sort-Object { $_.Value.Count } -Descending

        foreach ($category in $sortedCategories) {
            $count = $category.Value.Count
            $percentage = [math]::Round(($count / $this.Statistics.TotalFiles) * 100, 1)
            $totalSize = $this.FormatSize($category.Value.TotalSize)
            $totalLines = $category.Value.TotalLines

            # Format with fixed width columns for proper alignment
            $categoryColumn = $category.Key.PadRight(15)  # 15 characters for category name
            $countColumn = $count.ToString().PadLeft(3)  # 3 characters for count
            $percentageColumn = $percentage.ToString("F1").PadLeft(5)  # 5 characters for percentage
            $barLength = [math]::Round(($percentage / 100) * 20)
            $bar = "#" * $barLength

            # Build aligned output using string concatenation
            $output = $categoryColumn + $countColumn + " files (" + $percentageColumn + "%) - " + $totalSize + ", " + $totalLines + " lines " + $bar

            Write-Host $output -ForegroundColor White
        }

        Write-Host ""
    }

    # Show language statistics
    hidden [void] ShowLanguageStatistics() {
        Write-Host "Language Statistics:" -ForegroundColor Green

        # Sort by count descending
        $sortedLanguages = $this.Statistics.Languages.GetEnumerator() |
            Sort-Object { $_.Value.Count } -Descending

        foreach ($language in $sortedLanguages) {
            $count = $language.Value.Count
            $percentage = [math]::Round(($count / $this.Statistics.TotalFiles) * 100, 1)
            $totalSize = $this.FormatSize($language.Value.TotalSize)
            $totalLines = $language.Value.TotalLines

            # Format with fixed width columns for proper alignment
            $languageColumn = $language.Key.PadRight(15)  # 15 characters for language name
            $countColumn = $count.ToString().PadLeft(3)  # 3 characters for count
            $percentageColumn = $percentage.ToString("F1").PadLeft(5)  # 5 characters for percentage
            $barLength = [math]::Round(($percentage / 100) * 20)
            $bar = "#" * $barLength

            # Build aligned output using string concatenation
            $output = $languageColumn + $countColumn + " files (" + $percentageColumn + "%) - " + $totalSize + ", " + $totalLines + " lines " + $bar

            Write-Host $output -ForegroundColor White
        }

        Write-Host ""
    }

    # Show summary
    hidden [void] ShowSummary() {
        $totalSize = $this.FormatSize($this.Statistics.TotalSize)
        $analysisTime = $this.Statistics.AnalysisTime.TotalSeconds

        Write-Host "Summary:" -ForegroundColor Green
        Write-Host "Total: $($this.Statistics.TotalFiles) files" -ForegroundColor White
        Write-Host "Total Size: $totalSize" -ForegroundColor White
        Write-Host "Total Lines: $($this.Statistics.TotalLines) lines" -ForegroundColor White
        Write-Host "Analysis Time: $([math]::Round($analysisTime, 2)) seconds" -ForegroundColor White
        Write-Host ""
    }

    # Format size for display
    hidden [string] FormatSize([long] $size) {
        if ($size -lt 1KB) {
            return "$size B"
        } elseif ($size -lt 1MB) {
            return "$([math]::Round($size / 1KB, 1)) KB"
        } else {
            return "$([math]::Round($size / 1MB, 1)) MB"
        }
    }

    # Get files by language
    [FileInfo[]] GetFilesByLanguage([string] $language) {
        return $this.Files | Where-Object { $_.Language -eq $language }
    }

    # Get files by category
    [FileInfo[]] GetFilesByCategory([string] $category) {
        return $this.Files | Where-Object { $_.GetFileCategory() -eq $category }
    }

    # Get files by extension
    [FileInfo[]] GetFilesByExtension([string] $extension) {
        $lowerExt = $extension.ToLower()
        return $this.Files | Where-Object { $_.Extension.ToLower() -eq $lowerExt }
    }

    # Export statistics to JSON
    [string] ExportToJSON() {
        $exportData = @{
            AnalysisInfo = @{
                TargetDirectory = $this.TargetDirectory
                AnalysisStartTime = $this.AnalysisStartTime
                AnalysisEndTime = $this.AnalysisEndTime
                AnalysisDuration = $this.Statistics.AnalysisTime.TotalSeconds
                Configuration = @{
                    MaxDepth = $this.Config.MaxDepth
                    IncludeHidden = $this.Config.IncludeHidden
                    FollowSymlinks = $this.Config.FollowSymlinks
                    ExcludePatterns = $this.Config.ExcludePatterns
                    IncludePatterns = $this.Config.IncludePatterns
                }
            }
            Statistics = $this.Statistics
            Files = $this.Files | ForEach-Object { $_.GetSummary() }
        }

        return $exportData | ConvertTo-Json -Depth 10
    }

    # Export statistics to CSV
    [string] ExportToCSV() {
        $csvData = $this.Files | ForEach-Object {
            $summary = $_.GetSummary()
            [PSCustomObject]@{
                Name = $summary.Name
                Path = $summary.Path
                Language = $summary.Language
                Category = $summary.Category
                Size = $summary.Size
                LinesOfCode = $summary.LinesOfCode
                CharacterCount = $summary.CharacterCount
                WordCount = $summary.WordCount
                CommentLines = $summary.CommentLines
                EmptyLines = $summary.EmptyLines
                LastModified = $summary.LastModified
                IsHidden = $summary.IsHidden
                IsReadOnly = $summary.IsReadOnly
            }
        }

        return $csvData | ConvertTo-Csv -NoTypeInformation
    }

    # Get analysis report
    [hashtable] GetReport() {
        return @{
            TargetDirectory = $this.TargetDirectory
            AnalysisTime = $this.AnalysisStartTime
            Statistics = $this.Statistics
            Files = $this.Files
            Configuration = $this.Config
        }
    }

    # Override ToString method
    [string] ToString() {
        return "ScriptAnalyzer: $($this.TargetDirectory) - $($this.Statistics.TotalFiles) files"
    }
}
