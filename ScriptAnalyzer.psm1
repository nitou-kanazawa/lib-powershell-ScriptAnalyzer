# ScriptAnalyzer.psm1
# Main module file for ScriptAnalyzer

<#
.SYNOPSIS
    ScriptAnalyzer PowerShell Module

.DESCRIPTION
    A comprehensive script analysis tool for PowerShell that analyzes script files
    in directories and provides detailed statistics and reports.

.NOTES
    Version: 1.0.0
    Author: ScriptAnalyzer Team
    PowerShell Version: 5.1+

.EXAMPLE
    Import-Module .\ScriptAnalyzer.psm1
    Get-ScriptStatistics -Path "C:\MyProject"

.EXAMPLE
    Import-Module .\ScriptAnalyzer.psm1
    $analyzer = [ScriptAnalyzer]::new("C:\MyProject")
    $analyzer.Analyze()
    $analyzer.ShowStatistics()
#>

# Module metadata
$ModuleVersion = "1.0.0"
$ModuleAuthor = "ScriptAnalyzer Team"
$ModuleDescription = "A comprehensive script analysis tool for PowerShell"

# Get the module root directory
$ModuleRoot = $PSScriptRoot
if ([string]::IsNullOrEmpty($ModuleRoot)) {
    $ModuleRoot = Split-Path $MyInvocation.MyCommand.Path
}

# Load all class definitions
$ClassesPath = Join-Path $ModuleRoot "Classes"
if (Test-Path $ClassesPath) {
    Get-ChildItem -Path $ClassesPath -Filter "*.ps1" | ForEach-Object {
        . $_.FullName
    }
}

# Load all function definitions
$FunctionsPath = Join-Path $ModuleRoot "Functions"
if (Test-Path $FunctionsPath) {
    Get-ChildItem -Path $FunctionsPath -Filter "*.ps1" | ForEach-Object {
        . $_.FullName
    }
}

# Export public functions
Export-ModuleMember -Function @(
    'Get-ScriptStatistics',
    'Show-DirectoryTree'
)

# Export classes (PowerShell 5.0+)
if ($PSVersionTable.PSVersion.Major -ge 5) {
    # Note: Classes are automatically available when loaded
    # but we can't explicitly export them in older PowerShell versions
}

# Module initialization
function Initialize-ScriptAnalyzerModule {
    <#
    .SYNOPSIS
        Initialize the ScriptAnalyzer module

    .DESCRIPTION
        Performs module initialization tasks and validates the environment.

    .EXAMPLE
        Initialize-ScriptAnalyzerModule
    #>

    Write-Verbose "Initializing ScriptAnalyzer module v$ModuleVersion"

    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Write-Warning "ScriptAnalyzer requires PowerShell 5.0 or later. Current version: $($PSVersionTable.PSVersion)"
    }

    # Validate module structure
    $requiredPaths = @(
        (Join-Path $ModuleRoot "Classes"),
        (Join-Path $ModuleRoot "Functions"),
        (Join-Path $ModuleRoot "Tests"),
        (Join-Path $ModuleRoot "Examples")
    )

    foreach ($path in $requiredPaths) {
        if (-not (Test-Path $path)) {
            Write-Warning "Required module path not found: $path"
        }
    }

    # Check for required classes
    $requiredClasses = @("ScriptAnalysisConfig", "FileInfo", "ScriptAnalyzer")
    foreach ($className in $requiredClasses) {
        try {
            $null = [System.Management.Automation.PSTypeName]$className
            Write-Verbose "Class loaded: $className"
        } catch {
            Write-Warning "Required class not found: $className"
        }
    }

    Write-Verbose "ScriptAnalyzer module initialization completed"
}

# Module cleanup
function Remove-ScriptAnalyzerModule {
    <#
    .SYNOPSIS
        Clean up ScriptAnalyzer module resources

    .DESCRIPTION
        Performs cleanup tasks when the module is removed.

    .EXAMPLE
        Remove-ScriptAnalyzerModule
    #>

    Write-Verbose "Cleaning up ScriptAnalyzer module"

    # Clear any module-specific variables or resources
    Remove-Variable -Name ModuleRoot -ErrorAction SilentlyContinue
    Remove-Variable -Name ModuleVersion -ErrorAction SilentlyContinue
    Remove-Variable -Name ModuleAuthor -ErrorAction SilentlyContinue
    Remove-Variable -Name ModuleDescription -ErrorAction SilentlyContinue

    Write-Verbose "ScriptAnalyzer module cleanup completed"
}

# Module information function
function Get-ScriptAnalyzerInfo {
    <#
    .SYNOPSIS
        Get ScriptAnalyzer module information

    .DESCRIPTION
        Returns detailed information about the ScriptAnalyzer module including
        version, features, and supported file types.

    .EXAMPLE
        Get-ScriptAnalyzerInfo
    #>

    $info = @{
        Name = "ScriptAnalyzer"
        Version = $ModuleVersion
        Author = $ModuleAuthor
        Description = $ModuleDescription
        PowerShellVersion = $PSVersionTable.PSVersion.ToString()
        ModuleRoot = $ModuleRoot
        Features = @{
            "File Analysis" = "Analyze script files and generate statistics"
            "Directory Scanning" = "Recursively scan directories for script files"
            "Multiple Formats" = "Support for JSON, CSV, and XML output"
            "Tree Visualization" = "Display directory structure with ASCII art"
            "Custom Filtering" = "Include/exclude patterns and depth limits"
            "Performance Metrics" = "Analysis time and performance optimization"
            "Code Quality" = "Comment ratio, file size analysis, and recommendations"
        }
        SupportedFileTypes = @{
            "Script Languages" = @(".ps1", ".py", ".js", ".ts", ".lua", ".rb", ".pl", ".php")
            "Compiled Languages" = @(".cs", ".cpp", ".cxx", ".cc", ".c", ".h", ".hpp", ".java", ".swift", ".kt", ".rs", ".go")
            "Web Technologies" = @(".html", ".htm", ".css", ".scss", ".less")
            "Batch/Shell" = @(".bat", ".cmd", ".sh", ".bash", ".zsh", ".fish")
            "Game Development" = @(".shader", ".cginc", ".hlsl", ".glsl")
            "Configuration" = @(".json", ".xml", ".yaml", ".yml", ".toml", ".ini")
            "Other" = @(".sql", ".vbs", ".asm")
        }
        Classes = @("ScriptAnalysisConfig", "FileInfo", "ScriptAnalyzer")
        Functions = @("Get-ScriptStatistics", "Show-DirectoryTree")
    }

    return $info
}

# Export additional functions
Export-ModuleMember -Function @(
    'Initialize-ScriptAnalyzerModule',
    'Remove-ScriptAnalyzerModule',
    'Get-ScriptAnalyzerInfo'
)

# Initialize module on import
Initialize-ScriptAnalyzerModule

# Register cleanup on module removal
$ExecutionContext.SessionState.Module.OnRemove = {
    Remove-ScriptAnalyzerModule
}

# Module manifest information
$Manifest = @{
    ModuleVersion = $ModuleVersion
    Author = $ModuleAuthor
    Description = $ModuleDescription
    PowerShellVersion = "5.0"
    RootModule = "ScriptAnalyzer.psm1"
    FunctionsToExport = @(
        'Get-ScriptStatistics',
        'Show-DirectoryTree',
        'Initialize-ScriptAnalyzerModule',
        'Remove-ScriptAnalyzerModule',
        'Get-ScriptAnalyzerInfo'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    CompatiblePSEditions = @("Desktop", "Core")
    RequiredModules = @()
    RequiredAssemblies = @()
    ScriptsToProcess = @()
    TypesToProcess = @()
    FormatsToProcess = @()
    NestedModules = @()
    DefaultCommandPrefix = ""
    FileList = @(
        "ScriptAnalyzer.psm1",
        "ScriptAnalyzer.psd1",
        "Classes\Config.ps1",
        "Classes\FileInfo.ps1",
        "Classes\ScriptAnalyzer.ps1",
        "Functions\Get-ScriptStatistics.ps1",
        "Functions\Show-DirectoryTree.ps1",
        "Examples\Basic.ps1",
        "Examples\Advanced.ps1",
        "Tests\ScriptAnalyzer.Tests.ps1",
        "Documentation\README.md",
        "Documentation\TestSpecification.md",
        "Documentation\TestExecutionGuide.md",
        ".editorconfig"
    )
    PrivateData = @{
        PSData = @{
            Tags = @("Script", "Analysis", "Statistics", "PowerShell", "Code", "Quality")
            ProjectUri = "https://github.com/username/ScriptAnalyzer"
            LicenseUri = "https://github.com/username/ScriptAnalyzer/blob/main/LICENSE"
            ReleaseNotes = "Initial release with basic script analysis capabilities"
            Prerelease = ""
            RequireLicenseAcceptance = $false
            ExternalModuleDependencies = @()
        }
    }
}

# Display welcome message on first import
if (-not $ScriptAnalyzerInitialized) {
    Write-Host "ScriptAnalyzer v$ModuleVersion loaded successfully!" -ForegroundColor Green
    Write-Host "Use Get-ScriptAnalyzerInfo for detailed information" -ForegroundColor Cyan
    Write-Host "Use Get-ScriptStatistics -Path <directory> to start analyzing" -ForegroundColor Cyan
    $ScriptAnalyzerInitialized = $true
}
