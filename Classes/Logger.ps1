# Logger.ps1
# Logging utility class for ScriptAnalyzer

<#
.SYNOPSIS
    Logging utility class for tracking analysis progress and errors

.DESCRIPTION
    Provides structured logging functionality with different log levels
    and output formats.

.EXAMPLE
    $logger = [Logger]::new()
    $logger.Info("Analysis started")
    $logger.Error("File not found", $exception)
#>

class Logger {
    # Log levels
    [string] $LogLevel = "Info"  # Debug, Info, Warning, Error
    [bool] $EnableConsoleOutput = $true
    [string] $LogFilePath = $null
    [datetime] $StartTime

    # Constructor
    Logger() {
        $this.StartTime = Get-Date
    }

    Logger([string] $logLevel) {
        $this.LogLevel = $logLevel
        $this.StartTime = Get-Date
    }

    Logger([string] $logLevel, [string] $logFilePath) {
        $this.LogLevel = $logLevel
        $this.LogFilePath = $logFilePath
        $this.StartTime = Get-Date
    }

    # Get log level priority
    hidden [int] GetLogLevelPriority([string] $level) {
        switch ($level.ToLower()) {
            "debug" { return 0 }
            "info" { return 1 }
            "warning" { return 2 }
            "error" { return 3 }
            default { return 1 }
        }
        return 1  # Default fallback
    }

    # Check if should log
    hidden [bool] ShouldLog([string] $level) {
        $currentPriority = $this.GetLogLevelPriority($this.LogLevel)
        $messagePriority = $this.GetLogLevelPriority($level)
        return $messagePriority -ge $currentPriority
    }

    # Format log message
    hidden [string] FormatMessage([string] $level, [string] $message) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $elapsed = (Get-Date) - $this.StartTime
        $elapsedStr = $elapsed.ToString("hh\:mm\:ss\.fff")
        return "[$timestamp] [$elapsedStr] [$($level.ToUpper())] $message"
    }

    # Write log message
    hidden [void] WriteLog([string] $level, [string] $message) {
        if (-not $this.ShouldLog($level)) {
            return
        }

        $formattedMessage = $this.FormatMessage($level, $message)

        # Console output
        if ($this.EnableConsoleOutput) {
            $color = switch ($level.ToLower()) {
                "debug" { "Gray" }
                "info" { "White" }
                "warning" { "Yellow" }
                "error" { "Red" }
                default { "White" }
            }
            Write-Host $formattedMessage -ForegroundColor $color
        }

        # File output
        if ($this.LogFilePath) {
            try {
                $formattedMessage | Out-File -FilePath $this.LogFilePath -Append -Encoding UTF8
            }
            catch {
                Write-Warning "Failed to write to log file: $_"
            }
        }
    }

    # Log methods
    [void] Debug([string] $message) {
        $this.WriteLog("Debug", $message)
    }

    [void] Info([string] $message) {
        $this.WriteLog("Info", $message)
    }

    [void] Warning([string] $message) {
        $this.WriteLog("Warning", $message)
    }

    [void] Error([string] $message) {
        $this.WriteLog("Error", $message)
    }

    [void] Error([string] $message, [System.Exception] $exception) {
        $fullMessage = "$message`nException: $($exception.Message)"
        if ($exception.StackTrace) {
            $fullMessage += "`nStackTrace: $($exception.StackTrace)"
        }
        $this.WriteLog("Error", $fullMessage)
    }

    # Performance logging
    [void] LogPerformance([string] $operation, [timespan] $duration) {
        $this.Info("Performance: $operation completed in $($duration.TotalMilliseconds)ms")
    }

    # Analysis progress logging
    [void] LogProgress([string] $phase, [int] $current, [int] $total) {
        $percentage = if ($total -gt 0) { [math]::Round(($current / $total) * 100, 1) } else { 0 }
        $this.Debug("Progress: $phase - $current/$total ($percentage%)")
    }
}
