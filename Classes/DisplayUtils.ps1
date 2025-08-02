# DisplayUtils.ps1
# Display Utility Class for ScriptAnalyzer

<#
.SYNOPSIS
    Display utility class for formatting and outputting analysis results

.DESCRIPTION
    Provides common display functionality including progress bars,
    formatted output, and consistent styling.

.EXAMPLE
    $display = [DisplayUtils]::new()
    $display.ShowProgressBar(75, 100)
#>

class DisplayUtils {
    # Default colors
    [string] $DefaultColor = "White"
    [string] $HeaderColor = "Green"
    [string] $ProgressBarColor = "Cyan"
    [string] $WarningColor = "Yellow"
    [string] $ErrorColor = "Red"

    # Progress bar settings
    [int] $DefaultBarLength = 20
    [string] $ProgressBarChar = "#"

    # Constructor
    DisplayUtils() {
        # Default constructor
    }

    # Show a progress bar
    [void] ShowProgressBar([double] $current, [double] $total, [int] $barLength = 0) {
        if ($barLength -eq 0) {
            $barLength = $this.DefaultBarLength
        }

        $percentage = if ($total -gt 0) { ($current / $total) * 100 } else { 0 }
        $filledLength = [math]::Round(($percentage / 100) * $barLength)
        $bar = $this.ProgressBarChar * $filledLength

        Write-Host $bar -NoNewline -ForegroundColor $this.ProgressBarColor
        Write-Host " $([math]::Round($percentage, 1))%" -ForegroundColor $this.DefaultColor
    }

    # Show formatted statistics line
    [void] ShowStatisticsLine([string] $label, [int] $count, [double] $percentage, [string] $additionalInfo = "") {
        $barLength = [math]::Round(($percentage / 100) * $this.DefaultBarLength)
        $bar = $this.ProgressBarChar * $barLength

        # Build output line
        $output = $label + "`t" + $count + " files (" + $percentage + "%)"
        if ($additionalInfo -ne "") {
            $output += " - " + $additionalInfo
        }
        $output += " " + $bar

        Write-Host $output -ForegroundColor $this.DefaultColor
    }

    # Show formatted file type statistics line with proper alignment
    [void] ShowFileTypeStatisticsLine([string] $language, [string] $extension, [int] $count, [double] $percentage) {
        $barLength = [math]::Round(($percentage / 100) * $this.DefaultBarLength)
        $bar = $this.ProgressBarChar * $barLength

        # Format with fixed width columns
        $languageColumn = $language.PadRight(15)  # 15 characters for language name
        $extensionColumn = "($extension)".PadRight(10)  # 10 characters for extension
        $countColumn = $count.ToString().PadLeft(3)  # 3 characters for count
        $percentageColumn = $percentage.ToString("F1").PadLeft(5)  # 5 characters for percentage

        # Build aligned output using string concatenation
        $output = $languageColumn + $extensionColumn + $countColumn + " files (" + $percentageColumn + "%) " + $bar

        Write-Host $output -ForegroundColor $this.DefaultColor
    }

    # Show header
    [void] ShowHeader([string] $title) {
        $separator = "=" * $title.Length
        Write-Host "`n$title" -ForegroundColor $this.HeaderColor
        Write-Host $separator -ForegroundColor $this.HeaderColor
        Write-Host ""
    }

    # Show section header
    [void] ShowSectionHeader([string] $sectionName) {
        Write-Host ($sectionName + ":") -ForegroundColor $this.HeaderColor
    }

    # Show summary line
    [void] ShowSummaryLine([string] $label, [string] $value) {
        Write-Host ($label + ": " + $value) -ForegroundColor $this.DefaultColor
    }

    # Format file size
    [string] FormatFileSize([long] $size) {
        if ($size -lt 1KB) {
            return "$size B"
        } elseif ($size -lt 1MB) {
            return "$([math]::Round($size / 1KB, 1)) KB"
        } else {
            return "$([math]::Round($size / 1MB, 1)) MB"
        }
    }

    # Show warning message
    [void] ShowWarning([string] $message) {
        Write-Host "Warning: $message" -ForegroundColor $this.WarningColor
    }

    # Show error message
    [void] ShowError([string] $message) {
        Write-Host "Error: $message" -ForegroundColor $this.ErrorColor
    }

    # Show success message
    [void] ShowSuccess([string] $message) {
        Write-Host $message -ForegroundColor $this.HeaderColor
    }
}
