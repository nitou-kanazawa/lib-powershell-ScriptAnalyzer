# ScriptAnalysisConfig.ps1
# Script Analysis Configuration Class

<#
.SYNOPSIS
    Script analysis configuration management class

.DESCRIPTION
    Manages analysis target settings, exclusion patterns, output options, etc.
    Provides default values and allows users to customize as needed.

.EXAMPLE
    $config = [ScriptAnalysisConfig]::new()
    $config.MaxDepth = 3
    $config.ExcludePatterns += "*.tmp"
#>

# Note: ConfigValidator is loaded by Start-ScriptAnalysis.ps1

class ScriptAnalysisConfig {
    # Property definitions
    [int] $MaxDepth = -1                    # Maximum search depth (-1 is unlimited)
    [bool] $IncludeHidden = $false          # Include hidden files
    [bool] $FollowSymlinks = $false         # Follow symbolic links
    [string[]] $ExcludePatterns = @()       # Exclusion patterns (wildcards)
    [string[]] $IncludePatterns = @()       # Include patterns (empty means all)
    [bool] $ShowProgress = $true            # Show progress
    [string] $OutputFormat = "Console"      # Output format (Console, JSON, CSV)
    [string] $DefaultEncoding = "UTF8"
    [string] $LogLevel = "Info"  # Debug, Info, Warning, Error
    [string] $LogFilePath = $null      # Default encoding for file reading
    [hashtable] $SupportedExtensions       # Supported extensions and descriptions

    # Constructor
    ScriptAnalysisConfig() {
        $this.InitializeDefaults()
    }

    ScriptAnalysisConfig([hashtable] $customSettings) {
        $this.InitializeDefaults()
        $this.ApplyCustomSettings($customSettings)
    }

        # Initialize default settings
    hidden [void] InitializeDefaults() {
        # Load configuration from external file
        $configPath = Join-Path $PSScriptRoot "..\Config\FileTypes.json"
        if (Test-Path $configPath) {
            try {
                $configData = Get-Content $configPath -Raw | ConvertFrom-Json

                                # Load supported extensions
                $this.SupportedExtensions = @{}
                foreach ($ext in $configData.supportedExtensions.PSObject.Properties) {
                    $this.SupportedExtensions[$ext.Name] = $ext.Value.language
                }

                # Load default exclusion patterns
                $this.ExcludePatterns = $configData.defaultExcludePatterns
            }
            catch {
                Write-Warning "Failed to load external config, using defaults: $_"
                $this.LoadDefaultExtensions()
                $this.LoadDefaultExcludePatterns()
            }
        } else {
            Write-Warning "Config file not found, using defaults: $configPath"
            $this.LoadDefaultExtensions()
            $this.LoadDefaultExcludePatterns()
        }
    }

    # Load default extensions (fallback)
    hidden [void] LoadDefaultExtensions() {
        $this.SupportedExtensions = @{
            '.ps1' = 'PowerShell'
            '.py'  = 'Python'
            '.js'  = 'JavaScript'
            '.cs'  = 'C#'
            '.cpp' = 'C++'
            '.c'   = 'C'
            '.h'   = 'C/C++ Header'
            '.java' = 'Java'
            '.html' = 'HTML'
            '.css' = 'CSS'
            '.bat' = 'Batch'
            '.sh'  = 'Shell Script'
        }
    }

    # Load default exclusion patterns (fallback)
    hidden [void] LoadDefaultExcludePatterns() {
        $this.ExcludePatterns = @(
            '*.tmp'
            '*.log'
            '*.bak'
            '*~'
            '.git'
            'node_modules'
            'bin'
            'obj'
        )
    }

    # Apply custom settings
    [void] ApplyCustomSettings([hashtable] $settings) {
        if ($null -eq $settings) {
            return
        }

        foreach ($key in $settings.Keys) {
            switch ($key) {
                'MaxDepth' {
                    if ($settings[$key] -is [int] -and $settings[$key] -ge -1) {
                        $this.MaxDepth = $settings[$key]
                    } else {
                        throw "MaxDepth must be an integer greater than or equal to -1"
                    }
                }
                'IncludeHidden' {
                    if ($settings[$key] -is [bool]) {
                        $this.IncludeHidden = $settings[$key]
                    } else {
                        throw "IncludeHidden must be a boolean value"
                    }
                }
                'FollowSymlinks' {
                    if ($settings[$key] -is [bool]) {
                        $this.FollowSymlinks = $settings[$key]
                    } else {
                        throw "FollowSymlinks must be a boolean value"
                    }
                }
                'ExcludePatterns' {
                    if ($null -ne $settings[$key] -and $settings[$key] -is [array]) {
                        $this.ExcludePatterns += $settings[$key]
                    } else {
                        throw "ExcludePatterns must be an array"
                    }
                }
                'IncludePatterns' {
                    if ($null -ne $settings[$key] -and $settings[$key] -is [array]) {
                        $this.IncludePatterns = $settings[$key]
                    } else {
                        throw "IncludePatterns must be an array"
                    }
                }
                'ShowProgress' {
                    if ($settings[$key] -is [bool]) {
                        $this.ShowProgress = $settings[$key]
                    } else {
                        throw "ShowProgress must be a boolean value"
                    }
                }
                'OutputFormat' {
                    $validFormats = @('Console', 'JSON', 'CSV', 'XML')
                    if ($settings[$key] -in $validFormats) {
                        $this.OutputFormat = $settings[$key]
                    } else {
                        throw "OutputFormat must be one of: $($validFormats -join ', ')"
                    }
                }
                default {
                    Write-Warning "Unknown setting: $key"
                }
            }
        }
    }

    # Check if extension is supported
    [bool] IsSupportedExtension([string] $extension) {
        if ([string]::IsNullOrEmpty($extension)) {
            return $false
        }
        return $this.SupportedExtensions.ContainsKey($extension.ToLower())
    }

    # Get extension description
    [string] GetExtensionDescription([string] $extension) {
        if ([string]::IsNullOrEmpty($extension)) {
            return "Unknown"
        }
        $lowerExt = $extension.ToLower()
        if ($this.SupportedExtensions.ContainsKey($lowerExt)) {
            return $this.SupportedExtensions[$lowerExt]
        }
        return "Unknown"
    }

    # Check if file is excluded
    [bool] IsExcluded([string] $filePath) {
        # Check for null or empty string
        if ([string]::IsNullOrEmpty($filePath)) {
            return $true
        }

        # Get path information at once (performance improvement)
        $pathInfo = @{
            FileName = Split-Path $filePath -Leaf
            DirectoryName = Split-Path $filePath -Parent | Split-Path -Leaf
            FullPath = $filePath
        }

        # Null check (in case Split-Path fails)
        if ([string]::IsNullOrEmpty($pathInfo.FileName)) {
            return $true
        }

        foreach ($pattern in $this.ExcludePatterns) {
            # File name pattern matching
            if ($pathInfo.FileName -like $pattern) {
                return $true
            }
            # Directory name pattern matching
            if (-not [string]::IsNullOrEmpty($pathInfo.DirectoryName) -and $pathInfo.DirectoryName -like $pattern) {
                return $true
            }
            # Full path pattern matching
            if ($pathInfo.FullPath -like "*$pattern*") {
                return $true
            }
        }

        # Check for Include patterns if specified
        if ($this.IncludePatterns.Count -gt 0) {
            $included = $false
            foreach ($pattern in $this.IncludePatterns) {
                # Check both file name and directory name
                if ($pathInfo.FileName -like $pattern -or
                    (-not [string]::IsNullOrEmpty($pathInfo.DirectoryName) -and $pathInfo.DirectoryName -like $pattern)) {
                    $included = $true
                    break
                }
            }
            return -not $included
        }

        return $false
    }

    # Validate settings
    [bool] Validate() {
        try {
            # Validate MaxDepth
            if ($this.MaxDepth -lt -1) {
                Write-Error "MaxDepth must be -1 or greater"
                return $false
            }

            # Validate LogLevel
            $validLogLevels = @('Debug', 'Info', 'Warning', 'Error')
            if ($this.LogLevel -notin $validLogLevels) {
                Write-Error "Invalid LogLevel: $($this.LogLevel)"
                return $false
            }

            # Validate DefaultEncoding
            $validEncodings = @('UTF8', 'UTF8BOM', 'UTF7', 'UTF32', 'Unicode', 'BigEndianUnicode', 'ASCII', 'Default')
            if ($this.DefaultEncoding -notin $validEncodings) {
                Write-Error "Invalid DefaultEncoding: $($this.DefaultEncoding)"
                return $false
            }

            # Validate OutputFormat
            $validOutputFormats = @('Console', 'JSON', 'CSV')
            if ($this.OutputFormat -notin $validOutputFormats) {
                Write-Error "Invalid OutputFormat: $($this.OutputFormat)"
                return $false
            }

            return $true
        } catch {
            Write-Error "Error during configuration validation: $_"
            return $false
        }
    }

    # Display configuration (for debugging)
    [string] ToString() {
        $output = @"
ScriptAnalysisConfig:
    MaxDepth: $($this.MaxDepth)
    IncludeHidden: $($this.IncludeHidden)
    FollowSymlinks: $($this.FollowSymlinks)
    ShowProgress: $($this.ShowProgress)
    OutputFormat: $($this.OutputFormat)
    DefaultEncoding: $($this.DefaultEncoding)
    ExcludePatterns: $($this.ExcludePatterns -join ', ')
    IncludePatterns: $($this.IncludePatterns -join ', ')
    SupportedExtensions: $($this.SupportedExtensions.Count) types
"@
        return $output
    }
}
