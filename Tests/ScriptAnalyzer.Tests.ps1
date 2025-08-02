# ScriptAnalyzer.Tests.ps1
# ScriptAnalyzer Test File

# Load class definition
. "$PSScriptRoot\..\Classes\Config.ps1"

Write-Host "=== ScriptAnalyzer Test Start ===" -ForegroundColor Green

# Create test configuration object
$config = [ScriptAnalysisConfig]::new()

# Test 1: null/empty string test
Write-Host "`nTest 1: null/empty string test" -ForegroundColor Yellow
try {
    $result1 = $config.IsExcluded($null)
    $result2 = $config.IsExcluded("")

    Write-Host "  null result: $result1" -ForegroundColor Cyan
    Write-Host "  empty result: $result2" -ForegroundColor Cyan

    if ($result1 -and $result2) {
        Write-Host "  PASS: null/empty string test" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: null/empty string test" -ForegroundColor Red
    }
} catch {
    Write-Host "  ERROR: null/empty string test - $_" -ForegroundColor Red
}

# Test 2: Extension support test
Write-Host "`nTest 2: Extension support test" -ForegroundColor Yellow
try {
    $supportedExtensions = @('.ps1', '.py', '.js', '.cs', '.json')
    $unsupportedExtensions = @('.xyz', '.unknown', '')

    $allSupported = $true
    foreach ($ext in $supportedExtensions) {
        $isSupported = $config.IsSupportedExtension($ext)
        Write-Host "  $ext : $isSupported" -ForegroundColor Cyan
        if (-not $isSupported) {
            $allSupported = $false
        }
    }

    $allUnsupported = $true
    foreach ($ext in $unsupportedExtensions) {
        $isSupported = $config.IsSupportedExtension($ext)
        Write-Host "  $ext : $isSupported" -ForegroundColor Cyan
        if ($isSupported) {
            $allUnsupported = $false
        }
    }

    if ($allSupported -and $allUnsupported) {
        Write-Host "  PASS: Extension support test" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: Extension support test" -ForegroundColor Red
    }
} catch {
    Write-Host "  ERROR: Extension support test - $_" -ForegroundColor Red
}

# Test 3: Exclusion pattern test
Write-Host "`nTest 3: Exclusion pattern test" -ForegroundColor Yellow
try {
    $testFiles = @(
        @{Path = "C:\temp\test.tmp"; ShouldBeExcluded = $true},
        @{Path = "C:\temp\test.log"; ShouldBeExcluded = $true},
        @{Path = "C:\temp\test.ps1"; ShouldBeExcluded = $false},
        @{Path = "C:\temp\.git\config"; ShouldBeExcluded = $true},
        @{Path = "C:\temp\node_modules\package.json"; ShouldBeExcluded = $true}
    )

    $allCorrect = $true
    foreach ($test in $testFiles) {
        $result = $config.IsExcluded($test.Path)
        Write-Host "  $($test.Path) - Expected: $($test.ShouldBeExcluded), Actual: $result" -ForegroundColor Cyan
        if ($result -ne $test.ShouldBeExcluded) {
            $allCorrect = $false
        }
    }

    if ($allCorrect) {
        Write-Host "  PASS: Exclusion pattern test" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: Exclusion pattern test" -ForegroundColor Red
    }
} catch {
    Write-Host "  ERROR: Exclusion pattern test - $_" -ForegroundColor Red
}

# Test 4: Configuration validation test
Write-Host "`nTest 4: Configuration validation test" -ForegroundColor Yellow
try {
    $validConfig = $config.Validate()
    Write-Host "  Validation result: $validConfig" -ForegroundColor Cyan

    if ($validConfig) {
        Write-Host "  PASS: Configuration validation test" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: Configuration validation test" -ForegroundColor Red
    }
} catch {
    Write-Host "  ERROR: Configuration validation test - $_" -ForegroundColor Red
}

# Test 5: Custom settings test
Write-Host "`nTest 5: Custom settings test" -ForegroundColor Yellow
try {
    $customSettings = @{
        MaxDepth = 3
        IncludeHidden = $true
        ShowProgress = $false
        ExcludePatterns = @("*.test")
    }

    $customConfig = [ScriptAnalysisConfig]::new($customSettings)

    Write-Host "  MaxDepth: $($customConfig.MaxDepth)" -ForegroundColor Cyan
    Write-Host "  IncludeHidden: $($customConfig.IncludeHidden)" -ForegroundColor Cyan
    Write-Host "  ShowProgress: $($customConfig.ShowProgress)" -ForegroundColor Cyan
    Write-Host "  Has *.test pattern: $($customConfig.ExcludePatterns -contains '*.test')" -ForegroundColor Cyan

    if ($customConfig.MaxDepth -eq 3 -and
        $customConfig.IncludeHidden -eq $true -and
        $customConfig.ShowProgress -eq $false -and
        $customConfig.ExcludePatterns -contains "*.test") {
        Write-Host "  PASS: Custom settings test" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: Custom settings test" -ForegroundColor Red
    }
} catch {
    Write-Host "  ERROR: Custom settings test - $_" -ForegroundColor Red
}

Write-Host "`n=== Test Complete ===" -ForegroundColor Green
