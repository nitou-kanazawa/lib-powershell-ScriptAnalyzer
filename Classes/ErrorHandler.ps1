# ErrorHandler.ps1
# Error handling utility for ScriptAnalyzer

<#
.SYNOPSIS
    Error handling utility for ScriptAnalyzer

.DESCRIPTION
    Provides centralized error handling and reporting functionality.

.EXAMPLE
    $errorHandler = [ErrorHandler]::new()
    $errorHandler.HandleFileError($filePath, $exception)
#>

class ErrorHandler {
    [Logger] $Logger
    [bool] $ContinueOnError = $true
    [hashtable] $ErrorCounts = @{}

    # Constructor
    ErrorHandler([Logger] $logger) {
        $this.Logger = $logger
    }

    ErrorHandler([Logger] $logger, [bool] $continueOnError) {
        $this.Logger = $logger
        $this.ContinueOnError = $continueOnError
    }

    # Handle file processing errors
    [void] HandleFileError([string] $filePath, [System.Exception] $exception) {
        $errorType = $this.GetErrorType($exception)
        $this.ErrorCounts[$errorType]++

        $errorMessage = "Failed to process file: $filePath - $($exception.Message)"
        $this.Logger.Error($errorMessage, $exception)

        if (-not $this.ContinueOnError) {
            throw $exception
        }
    }

    # Handle configuration errors
    [void] HandleConfigError([string] $configPath, [System.Exception] $exception) {
        $errorMessage = "Configuration error in $configPath - $($exception.Message)"
        $this.Logger.Error($errorMessage, $exception)

        if (-not $this.ContinueOnError) {
            throw $exception
        }
    }

    # Handle directory access errors
    [void] HandleDirectoryError([string] $directoryPath, [System.Exception] $exception) {
        $errorMessage = "Directory access error: $directoryPath - $($exception.Message)"
        $this.Logger.Error($errorMessage, $exception)

        if (-not $this.ContinueOnError) {
            throw $exception
        }
    }

    # Get error type from exception
    hidden [string] GetErrorType([System.Exception] $exception) {
        if ($exception -is [System.IO.FileNotFoundException]) {
            return "FileNotFound"
        } elseif ($exception -is [System.IO.DirectoryNotFoundException]) {
            return "DirectoryNotFound"
        } elseif ($exception -is [System.UnauthorizedAccessException]) {
            return "UnauthorizedAccess"
        } elseif ($exception -is [System.IO.IOException]) {
            return "IOError"
        } else {
            return "GeneralError"
        }
    }

    # Get error summary
    [hashtable] GetErrorSummary() {
        return $this.ErrorCounts.Clone()
    }

    # Log error summary
    [void] LogErrorSummary() {
        if ($this.ErrorCounts.Count -eq 0) {
            $this.Logger.Info("No errors occurred during analysis")
            return
        }

        $this.Logger.Warning("Error Summary:")
        foreach ($errorType in $this.ErrorCounts.Keys) {
            $count = $this.ErrorCounts[$errorType]
            $this.Logger.Warning("  $errorType`: $count errors")
        }
    }

    # Clear error counts
    [void] ClearErrors() {
        $this.ErrorCounts.Clear()
    }
}
