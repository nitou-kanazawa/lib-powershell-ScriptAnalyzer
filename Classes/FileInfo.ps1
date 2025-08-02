# FileInfo.ps1
# File Information Management Class

<#
.SYNOPSIS
    File information management class for script analysis

.DESCRIPTION
    Manages file information including type, size, path, and metadata.
    Provides methods for file analysis and categorization.

.EXAMPLE
    $fileInfo = [FileInfo]::new("C:\temp\script.ps1")
    $fileInfo.GetFileType()  # Returns "PowerShell"
    $fileInfo.GetSizeInKB()  # Returns file size in KB
#>

class FileInfo {
    # Properties
    [string] $FullPath                    # Full file path
    [string] $FileName                    # File name only
    [string] $Extension                   # File extension
    [string] $Directory                   # Directory path
    [long] $Size                          # File size in bytes
    [datetime] $LastModified              # Last modified date
    [bool] $IsHidden                      # Hidden file flag
    [bool] $IsReadOnly                    # Read-only file flag
    [string] $Language                    # Programming language
    [hashtable] $Metadata                 # Additional metadata

    # Constructor
    FileInfo([string] $filePath) {
        $this.InitializeFromPath($filePath, $null)
    }

    FileInfo([string] $filePath, [ScriptAnalysisConfig] $config) {
        $this.InitializeFromPath($filePath, $config)
    }

    # Initialize file information from path
    hidden [void] InitializeFromPath([string] $filePath, [ScriptAnalysisConfig] $config) {
        if ([string]::IsNullOrEmpty($filePath)) {
            throw "File path cannot be null or empty"
        }

        if (-not (Test-Path $filePath)) {
            throw "File does not exist: $filePath"
        }

        # Get file system information
        $fileItem = Get-Item $filePath

        # Set basic properties
        $this.FullPath = $fileItem.FullName
        $this.FileName = $fileItem.Name
        $this.Extension = $fileItem.Extension
        $this.Directory = $fileItem.DirectoryName
        $this.Size = $fileItem.Length
        $this.LastModified = $fileItem.LastWriteTime
        $this.IsHidden = ($fileItem.Attributes -band [System.IO.FileAttributes]::Hidden) -ne 0
        $this.IsReadOnly = ($fileItem.Attributes -band [System.IO.FileAttributes]::ReadOnly) -ne 0

        # Determine programming language
        $this.Language = $this.DetermineLanguage($this.Extension)

        # Initialize metadata
        $this.Metadata = @{
            LinesOfCode = $this.CountLinesOfCode($config)
            CharacterCount = $this.GetCharacterCount($config)
            WordCount = $this.GetWordCount($config)
            CommentLines = $this.CountCommentLines($config)
            EmptyLines = $this.CountEmptyLines($config)
        }
    }

    # Determine programming language from extension
    hidden [string] DetermineLanguage([string] $extension) {
        $languageMap = @{
            '.ps1'    = 'PowerShell'
            '.py'     = 'Python'
            '.js'     = 'JavaScript'
            '.ts'     = 'TypeScript'
            '.lua'    = 'Lua'
            '.rb'     = 'Ruby'
            '.pl'     = 'Perl'
            '.php'    = 'PHP'
            '.cs'     = 'C#'
            '.cpp'    = 'C++'
            '.cxx'    = 'C++'
            '.cc'     = 'C++'
            '.c'      = 'C'
            '.h'      = 'C/C++ Header'
            '.hpp'    = 'C++ Header'
            '.java'   = 'Java'
            '.swift'  = 'Swift'
            '.kt'     = 'Kotlin'
            '.rs'     = 'Rust'
            '.go'     = 'Go'
            '.html'   = 'HTML'
            '.htm'    = 'HTML'
            '.css'    = 'CSS'
            '.scss'   = 'SASS'
            '.less'   = 'LESS'
            '.bat'    = 'Batch'
            '.cmd'    = 'Command'
            '.sh'     = 'Shell Script'
            '.bash'   = 'Bash'
            '.zsh'    = 'Zsh'
            '.fish'   = 'Fish'
            '.shader' = 'Unity Shader'
            '.cginc'  = 'CG Include'
            '.hlsl'   = 'HLSL'
            '.glsl'   = 'GLSL'
            '.json'   = 'JSON'
            '.xml'    = 'XML'
            '.yaml'   = 'YAML'
            '.yml'    = 'YAML'
            '.toml'   = 'TOML'
            '.ini'    = 'INI'
            '.sql'    = 'SQL'
            '.vbs'    = 'VBScript'
            '.asm'    = 'Assembly'
        }

        $lowerExt = $extension.ToLower()
        if ($languageMap.ContainsKey($lowerExt)) {
            return $languageMap[$lowerExt]
        }

        return "Unknown"
    }

    # Get file type (alias for Language)
    [string] GetFileType() {
        return $this.Language
    }

    # Get file size in KB
    [double] GetSizeInKB() {
        return [math]::Round($this.Size / 1KB, 2)
    }

    # Get file size in MB
    [double] GetSizeInMB() {
        return [math]::Round($this.Size / 1MB, 2)
    }

    # Get formatted file size
    [string] GetFormattedSize() {
        if ($this.Size -lt 1KB) {
            return "$($this.Size) B"
        } elseif ($this.Size -lt 1MB) {
            return "$($this.GetSizeInKB()) KB"
        } else {
            return "$($this.GetSizeInMB()) MB"
        }
    }

    # Count lines of code
    hidden [int] CountLinesOfCode([ScriptAnalysisConfig] $config) {
        $encoding = if ($null -eq $config) { "UTF8" } else { $config.DefaultEncoding }

        try {
            $content = Get-Content $this.FullPath -Encoding $encoding -ErrorAction Stop
            return $content.Count
        } catch {
            # Fallback to system default encoding if specified encoding fails
            try {
                $content = Get-Content $this.FullPath -ErrorAction Stop
                return $content.Count
            } catch {
                return 0
            }
        }
    }

        # Get character count (properly handles multibyte characters)
    hidden [int] GetCharacterCount([ScriptAnalysisConfig] $config) {
        $encoding = if ($null -eq $config) { "UTF8" } else { $config.DefaultEncoding }

        try {
            $content = Get-Content $this.FullPath -Raw -Encoding $encoding -ErrorAction Stop
            # Use StringInfo to correctly count multibyte characters
            $stringInfo = [System.Globalization.StringInfo]::new($content)
            return $stringInfo.LengthInTextElements
        } catch {
            # Fallback to system default encoding if specified encoding fails
            try {
                $content = Get-Content $this.FullPath -Raw -ErrorAction Stop
                $stringInfo = [System.Globalization.StringInfo]::new($content)
                return $stringInfo.LengthInTextElements
            } catch {
                return 0
            }
        }
    }

        # Get word count (handles multibyte characters)
    hidden [int] GetWordCount([ScriptAnalysisConfig] $config) {
        $encoding = if ($null -eq $config) { "UTF8" } else { $config.DefaultEncoding }

        try {
            $content = Get-Content $this.FullPath -Raw -Encoding $encoding -ErrorAction Stop
            # Regular expression for word splitting including multibyte characters
            $words = $content -split '[\s\p{P}]+' | Where-Object { $_.Length -gt 0 }
            return $words.Count
        } catch {
            # Fallback to system default encoding if specified encoding fails
            try {
                $content = Get-Content $this.FullPath -Raw -ErrorAction Stop
                $words = $content -split '[\s\p{P}]+' | Where-Object { $_.Length -gt 0 }
                return $words.Count
            } catch {
                return 0
            }
        }
    }

        # Count comment lines (basic implementation with multibyte support)
    hidden [int] CountCommentLines([ScriptAnalysisConfig] $config) {
        $encoding = if ($null -eq $config) { "UTF8" } else { $config.DefaultEncoding }

        try {
            $content = Get-Content $this.FullPath -Encoding $encoding -ErrorAction Stop
            $commentCount = 0

            foreach ($line in $content) {
                $trimmedLine = $line.Trim()
                if ($trimmedLine.StartsWith('#') -or
                    $trimmedLine.StartsWith('//') -or
                    $trimmedLine.StartsWith('/*') -or
                    $trimmedLine.StartsWith('<!--') -or
                    $trimmedLine.StartsWith('--') -or
                    $trimmedLine.StartsWith(';') -or
                    $trimmedLine.StartsWith('REM ')) {
                    $commentCount++
                }
            }

            return $commentCount
        } catch {
            # Fallback to system default encoding if specified encoding fails
            try {
                $content = Get-Content $this.FullPath -ErrorAction Stop
                $commentCount = 0

                foreach ($line in $content) {
                    $trimmedLine = $line.Trim()
                    if ($trimmedLine.StartsWith('#') -or
                        $trimmedLine.StartsWith('//') -or
                        $trimmedLine.StartsWith('/*') -or
                        $trimmedLine.StartsWith('<!--') -or
                        $trimmedLine.StartsWith('--') -or
                        $trimmedLine.StartsWith(';') -or
                        $trimmedLine.StartsWith('REM ')) {
                        $commentCount++
                    }
                }

                return $commentCount
            } catch {
                return 0
            }
        }
    }

        # Count empty lines
    hidden [int] CountEmptyLines([ScriptAnalysisConfig] $config) {
        $encoding = if ($null -eq $config) { "UTF8" } else { $config.DefaultEncoding }

        try {
            $content = Get-Content $this.FullPath -Encoding $encoding -ErrorAction Stop
            $emptyCount = 0

            foreach ($line in $content) {
                if ([string]::IsNullOrWhiteSpace($line)) {
                    $emptyCount++
                }
            }

            return $emptyCount
        } catch {
            # Fallback to system default encoding if specified encoding fails
            try {
                $content = Get-Content $this.FullPath -ErrorAction Stop
                $emptyCount = 0

                foreach ($line in $content) {
                    if ([string]::IsNullOrWhiteSpace($line)) {
                        $emptyCount++
                    }
                }

                return $emptyCount
            } catch {
                return 0
            }
        }
    }

    # Get relative path from base directory
    [string] GetRelativePath([string] $baseDirectory) {
        if ([string]::IsNullOrEmpty($baseDirectory)) {
            return $this.FullPath
        }

        try {
            $baseUri = [System.Uri]::new($baseDirectory)
            $fileUri = [System.Uri]::new($this.FullPath)
            $relativeUri = $baseUri.MakeRelativeUri($fileUri)
            return $relativeUri.ToString()
        } catch {
            return $this.FullPath
        }
    }

    # Check if file is a script file
    [bool] IsScriptFile() {
        $scriptExtensions = @('.ps1', '.py', '.js', '.ts', '.lua', '.rb', '.pl', '.php', '.bat', '.cmd', '.sh', '.bash', '.zsh', '.fish', '.vbs')
        return $scriptExtensions -contains $this.Extension.ToLower()
    }

    # Check if file is a source code file
    [bool] IsSourceCodeFile() {
        $sourceExtensions = @('.cs', '.cpp', '.cxx', '.cc', '.c', '.h', '.hpp', '.java', '.swift', '.kt', '.rs', '.go')
        return $sourceExtensions -contains $this.Extension.ToLower()
    }

    # Check if file is a web file
    [bool] IsWebFile() {
        $webExtensions = @('.html', '.htm', '.css', '.scss', '.less', '.js', '.ts')
        return $webExtensions -contains $this.Extension.ToLower()
    }

    # Get file category
    [string] GetFileCategory() {
        if ($this.IsScriptFile()) {
            return "Script"
        } elseif ($this.IsSourceCodeFile()) {
            return "Source Code"
        } elseif ($this.IsWebFile()) {
            return "Web"
        } elseif ($this.Extension -eq '.shader' -or $this.Extension -eq '.cginc' -or $this.Extension -eq '.hlsl' -or $this.Extension -eq '.glsl') {
            return "Shader"
        } elseif ($this.Extension -eq '.json' -or $this.Extension -eq '.xml' -or $this.Extension -eq '.yaml' -or $this.Extension -eq '.yml' -or $this.Extension -eq '.toml' -or $this.Extension -eq '.ini') {
            return "Configuration"
        } else {
            return "Other"
        }
    }

    # Get summary information
    [hashtable] GetSummary() {
        return @{
            Name = $this.FileName
            Path = $this.FullPath
            Language = $this.Language
            Category = $this.GetFileCategory()
            Size = $this.GetFormattedSize()
            LinesOfCode = $this.Metadata.LinesOfCode
            CharacterCount = $this.Metadata.CharacterCount
            WordCount = $this.Metadata.WordCount
            CommentLines = $this.Metadata.CommentLines
            EmptyLines = $this.Metadata.EmptyLines
            LastModified = $this.LastModified
            IsHidden = $this.IsHidden
            IsReadOnly = $this.IsReadOnly
        }
    }

    # Override ToString method
    [string] ToString() {
        return "$($this.FileName) ($($this.Language)) - $($this.GetFormattedSize())"
    }
}
