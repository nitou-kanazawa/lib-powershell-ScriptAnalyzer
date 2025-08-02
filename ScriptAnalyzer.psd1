@{
    # Version number of this module.
    ModuleVersion = '1.0.0'

    # ID used to uniquely identify this module
    GUID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'

    # Author of this module
    Author = 'ScriptAnalyzer Team'

    # Company or vendor of this module
    CompanyName = 'ScriptAnalyzer'

    # Copyright statement for this module
    Copyright = '(c) 2025 ScriptAnalyzer Team. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'A comprehensive script analysis tool for PowerShell that analyzes script files in directories and provides detailed statistics and reports.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.0'

    # Name of the PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the callers environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Get-ScriptStatistics',
        'Show-DirectoryTree',
        'Initialize-ScriptAnalyzerModule',
        'Remove-ScriptAnalyzerModule',
        'Get-ScriptAnalyzerInfo'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module/package
    # ModuleList = @()

    # List of all files packaged with this module/package
    FileList = @(
        'ScriptAnalyzer.psm1',
        'ScriptAnalyzer.psd1',
        'Classes\Config.ps1',
        'Classes\FileInfo.ps1',
        'Classes\ScriptAnalyzer.ps1',
        'Functions\Get-ScriptStatistics.ps1',
        'Functions\Show-DirectoryTree.ps1',
        'Examples\Basic.ps1',
        'Examples\Advanced.ps1',
        'Tests\ScriptAnalyzer.Tests.ps1',
        'Documentation\README.md',
        'Documentation\TestSpecification.md',
        'Documentation\TestExecutionGuide.md',
        '.editorconfig'
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Script', 'Analysis', 'Statistics', 'PowerShell', 'Code', 'Quality', 'Development', 'Tools')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/username/ScriptAnalyzer/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/username/ScriptAnalyzer'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = @'
Initial release of ScriptAnalyzer with the following features:

Phase 1 (MVP):
- Directory scanning and file analysis
- Script file type detection and categorization
- Statistical analysis and reporting
- Multiple output formats (Console, JSON, CSV, XML)

Phase 2 (Extended Features):
- Directory tree visualization with ASCII art
- Advanced filtering and exclusion patterns
- Performance optimization and metrics
- Code quality analysis and recommendations
- Custom reporting and batch processing
- External tool integration support

Supported file types include:
- Script languages: PowerShell, Python, JavaScript, TypeScript, Lua, Ruby, Perl, PHP
- Compiled languages: C#, C++, Java, Swift, Kotlin, Rust, Go
- Web technologies: HTML, CSS, SASS, LESS
- Game development: Unity shaders, HLSL, GLSL
- Configuration files: JSON, XML, YAML, TOML, INI
- And many more...

For detailed usage examples, see the Examples folder.
'@

            # Prerelease string of this module
            # Prerelease = ''

            # Flag to indicate whether the module requires explicit user acceptance for install, update, or save.
            RequireLicenseAcceptance = $false

            # External dependent modules of this module
            # ExternalModuleDependencies = @()

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}
