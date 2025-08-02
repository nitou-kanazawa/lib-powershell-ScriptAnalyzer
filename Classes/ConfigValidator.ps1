# ConfigValidator.ps1
# Configuration validation utility for ScriptAnalyzer

<#
.SYNOPSIS
    Configuration validation utility for ScriptAnalyzer

.DESCRIPTION
    Provides validation functionality for configuration files and settings.

.EXAMPLE
    $validator = [ConfigValidator]::new()
    $isValid = $validator.ValidateFileTypesConfig($configData)
#>

class ConfigValidator {
    # Valid log levels
    [string[]] $ValidLogLevels = @('Debug', 'Info', 'Warning', 'Error')

    # Valid encodings
    [string[]] $ValidEncodings = @('UTF8', 'UTF8BOM', 'UTF7', 'UTF32', 'Unicode', 'BigEndianUnicode', 'ASCII', 'Default')

    # Required file type properties
    [string[]] $RequiredFileTypeProperties = @('language', 'category', 'description')

    # Constructor
    ConfigValidator() {
        # Default constructor
    }

    # Validate file types configuration
    [bool] ValidateFileTypesConfig([PSCustomObject] $configData) {
        try {
            # Check if configData is null
            if ($null -eq $configData) {
                Write-Error "Configuration data is null"
                return $false
            }

            # Check for required top-level properties
            if (-not $configData.PSObject.Properties.Name.Contains('supportedExtensions')) {
                Write-Error "Missing required property: supportedExtensions"
                return $false
            }

            if (-not $configData.PSObject.Properties.Name.Contains('defaultExcludePatterns')) {
                Write-Error "Missing required property: defaultExcludePatterns"
                return $false
            }

            # Validate supported extensions
            if (-not $this.ValidateSupportedExtensions($configData.supportedExtensions)) {
                return $false
            }

            # Validate exclude patterns
            if (-not $this.ValidateExcludePatterns($configData.defaultExcludePatterns)) {
                return $false
            }

            return $true
        }
        catch {
            Write-Error "Configuration validation failed: $_"
            return $false
        }
    }

    # Validate supported extensions
    hidden [bool] ValidateSupportedExtensions([PSCustomObject] $extensions) {
        if ($null -eq $extensions) {
            Write-Error "Supported extensions is null"
            return $false
        }

        foreach ($ext in $extensions.PSObject.Properties) {
            $extensionName = $ext.Name
            $extensionData = $ext.Value

            # Validate extension name format
            if (-not $extensionName.StartsWith('.')) {
                Write-Warning "Extension should start with '.': $extensionName"
            }

            # Validate extension data
            if (-not $this.ValidateExtensionData($extensionData, $extensionName)) {
                return $false
            }
        }

        return $true
    }

    # Validate individual extension data
    hidden [bool] ValidateExtensionData([PSCustomObject] $extensionData, [string] $extensionName) {
        if ($null -eq $extensionData) {
            Write-Error "Extension data is null for: $extensionName"
            return $false
        }

        # Check required properties
        foreach ($requiredProp in $this.RequiredFileTypeProperties) {
            if (-not $extensionData.PSObject.Properties.Name.Contains($requiredProp)) {
                Write-Error "Missing required property '$requiredProp' for extension: $extensionName"
                return $false
            }
        }

        # Validate property values
        if ([string]::IsNullOrEmpty($extensionData.language)) {
            Write-Error "Language cannot be empty for extension: $extensionName"
            return $false
        }

        if ([string]::IsNullOrEmpty($extensionData.category)) {
            Write-Error "Category cannot be empty for extension: $extensionName"
            return $false
        }

        return $true
    }

    # Validate exclude patterns
    hidden [bool] ValidateExcludePatterns([array] $patterns) {
        if ($null -eq $patterns) {
            Write-Error "Exclude patterns is null"
            return $false
        }

        if ($patterns.Count -eq 0) {
            Write-Warning "No exclude patterns defined"
        }

        foreach ($pattern in $patterns) {
            if ([string]::IsNullOrEmpty($pattern)) {
                Write-Warning "Empty exclude pattern found"
            }
        }

        return $true
    }

    # Validate analysis configuration
    [bool] ValidateAnalysisConfig([ScriptAnalysisConfig] $config) {
        try {
            # Validate MaxDepth
            if ($config.MaxDepth -lt -1) {
                Write-Error "MaxDepth must be -1 or greater"
                return $false
            }

            # Validate LogLevel
            if ($config.LogLevel -notin $this.ValidLogLevels) {
                Write-Error "Invalid LogLevel: $($config.LogLevel). Valid values: $($this.ValidLogLevels -join ', ')"
                return $false
            }

            # Validate DefaultEncoding
            if ($config.DefaultEncoding -notin $this.ValidEncodings) {
                Write-Error "Invalid DefaultEncoding: $($config.DefaultEncoding). Valid values: $($this.ValidEncodings -join ', ')"
                return $false
            }

            # Validate OutputFormat
            $validOutputFormats = @('Console', 'JSON', 'CSV')
            if ($config.OutputFormat -notin $validOutputFormats) {
                Write-Error "Invalid OutputFormat: $($config.OutputFormat). Valid values: $($validOutputFormats -join ', ')"
                return $false
            }

            return $true
        }
        catch {
            Write-Error "Analysis configuration validation failed: $_"
            return $false
        }
    }

    # Validate file path
    [bool] ValidateFilePath([string] $filePath) {
        if ([string]::IsNullOrEmpty($filePath)) {
            Write-Error "File path cannot be null or empty"
            return $false
        }

        if (-not (Test-Path $filePath)) {
            Write-Error "File does not exist: $filePath"
            return $false
        }

        return $true
    }

    # Validate directory path
    [bool] ValidateDirectoryPath([string] $directoryPath) {
        if ([string]::IsNullOrEmpty($directoryPath)) {
            Write-Error "Directory path cannot be null or empty"
            return $false
        }

        if (-not (Test-Path $directoryPath)) {
            Write-Error "Directory does not exist: $directoryPath"
            return $false
        }

        if (-not (Test-Path $directoryPath -PathType Container)) {
            Write-Error "Path is not a directory: $directoryPath"
            return $false
        }

        return $true
    }
}
