# ScriptAnalyzer テスト実行手順書

## 概要

このドキュメントは、ScriptAnalyzerプロジェクトのテストを実行するための詳細な手順を説明します。初心者から上級者まで、誰でもテストを実行できるように段階的に説明しています。

## 前提条件

### 必要な環境

1. **PowerShell 5.1以上**
   ```powershell
   $PSVersionTable.PSVersion
   ```

2. **実行ポリシーの確認**
   ```powershell
   Get-ExecutionPolicy
   # 必要に応じて変更
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **プロジェクトファイルの確認**
   ```
   ScriptAnalyzer/
   ├── Classes/
   │   └── Config.ps1
   ├── Tests/
   │   └── ScriptAnalyzer.Tests.ps1
   └── Documentation/
       ├── TestSpecification.md
       └── TestExecutionGuide.md
   ```

## 基本的なテスト実行

### ステップ1: プロジェクトディレクトリに移動

```powershell
cd "C:\Users\nitou\Desktop\ScriptAnalyzer"
```

### ステップ2: テストファイルの実行

```powershell
.\Tests\ScriptAnalyzer.Tests.ps1
```

### ステップ3: 結果の確認

正常に実行されると、以下のような出力が表示されます：

```
=== ScriptAnalyzer Test Start ===

Test 1: null/empty string test
  null result: True
  empty result: True
  PASS: null/empty string test

Test 2: Extension support test
  .ps1 : True
  .py : True
  .js : True
  .cs : True
  .json : True
  .xyz : False
  .unknown : False
   : False
  PASS: Extension support test

Test 3: Exclusion pattern test
  C:\temp\test.tmp - Expected: True, Actual: True
  C:\temp\test.log - Expected: True, Actual: True
  C:\temp\test.ps1 - Expected: False, Actual: False
  C:\temp\.git\config - Expected: True, Actual: True
  C:\temp\node_modules\package.json - Expected: True, Actual: True
  PASS: Exclusion pattern test

Test 4: Configuration validation test
  Validation result: True
  PASS: Configuration validation test

Test 5: Custom settings test
  MaxDepth: 3
  IncludeHidden: True
  ShowProgress: False
  Has *.test pattern: True
  PASS: Custom settings test

=== Test Complete ===
```

## 個別テストの実行

### クラス定義の読み込み

```powershell
# クラス定義を読み込み
. ".\Classes\Config.ps1"

# 設定オブジェクトを作成
$config = [ScriptAnalysisConfig]::new()
```

### 個別メソッドのテスト

#### 1. null/空文字列テスト

```powershell
# null値のテスト
$result1 = $config.IsExcluded($null)
Write-Host "null result: $result1"

# 空文字列のテスト
$result2 = $config.IsExcluded("")
Write-Host "empty result: $result2"
```

#### 2. 拡張子サポートテスト

```powershell
# サポートされている拡張子
$supportedExtensions = @('.ps1', '.py', '.js', '.cs', '.json')
foreach ($ext in $supportedExtensions) {
    $isSupported = $config.IsSupportedExtension($ext)
    Write-Host "$ext : $isSupported"
}

# サポートされていない拡張子
$unsupportedExtensions = @('.xyz', '.unknown', '')
foreach ($ext in $unsupportedExtensions) {
    $isSupported = $config.IsSupportedExtension($ext)
    Write-Host "$ext : $isSupported"
}
```

#### 3. 除外パターンテスト

```powershell
# テストファイルの定義
$testFiles = @(
    @{Path = "C:\temp\test.tmp"; ShouldBeExcluded = $true},
    @{Path = "C:\temp\test.log"; ShouldBeExcluded = $true},
    @{Path = "C:\temp\test.ps1"; ShouldBeExcluded = $false},
    @{Path = "C:\temp\.git\config"; ShouldBeExcluded = $true},
    @{Path = "C:\temp\node_modules\package.json"; ShouldBeExcluded = $true}
)

# テスト実行
foreach ($test in $testFiles) {
    $result = $config.IsExcluded($test.Path)
    Write-Host "$($test.Path) - Expected: $($test.ShouldBeExcluded), Actual: $result"
}
```

#### 4. 設定検証テスト

```powershell
# 設定の検証
$validConfig = $config.Validate()
Write-Host "Validation result: $validConfig"
```

#### 5. カスタム設定テスト

```powershell
# カスタム設定の定義
$customSettings = @{
    MaxDepth = 3
    IncludeHidden = $true
    ShowProgress = $false
    ExcludePatterns = @("*.test")
}

# カスタム設定オブジェクトの作成
$customConfig = [ScriptAnalysisConfig]::new($customSettings)

# 設定値の確認
Write-Host "MaxDepth: $($customConfig.MaxDepth)"
Write-Host "IncludeHidden: $($customConfig.IncludeHidden)"
Write-Host "ShowProgress: $($customConfig.ShowProgress)"
Write-Host "Has *.test pattern: $($customConfig.ExcludePatterns -contains '*.test')"
```

## トラブルシューティング

### よくあるエラーと解決方法

#### 1. 実行ポリシーエラー

**エラー**:
```
File C:\Users\nitou\Desktop\ScriptAnalyzer\Tests\ScriptAnalyzer.Tests.ps1 cannot be loaded because running scripts is disabled on this system.
```

**解決方法**:
```powershell
# 現在のポリシーを確認
Get-ExecutionPolicy

# ポリシーを変更（管理者権限が必要な場合があります）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# または、一時的に実行
PowerShell -ExecutionPolicy Bypass -File ".\Tests\ScriptAnalyzer.Tests.ps1"
```

#### 2. クラスが見つからないエラー

**エラー**:
```
型 [ScriptAnalysisConfig] が見つかりません。
```

**解決方法**:
```powershell
# クラス定義を明示的に読み込み
. ".\Classes\Config.ps1"

# クラスが読み込まれたか確認
[ScriptAnalysisConfig]::new()
```

#### 3. パスエラー

**エラー**:
```
Cannot find path 'C:\Users\nitou\Desktop\ScriptAnalyzer\Classes\Config.ps1' because it does not exist.
```

**解決方法**:
```powershell
# 現在のディレクトリを確認
Get-Location

# 正しいディレクトリに移動
cd "C:\Users\nitou\Desktop\ScriptAnalyzer"

# ファイルの存在確認
Test-Path ".\Classes\Config.ps1"
```

#### 4. 構文エラー

**エラー**:
```
文字列に終端記号 " がありません。
```

**解決方法**:
- ファイルの文字エンコーディングを確認
- UTF-8（BOMなし）で保存されているか確認
- 特殊文字が含まれていないか確認

```powershell
# ファイルの内容を確認
Get-Content ".\Tests\ScriptAnalyzer.Tests.ps1" -Encoding UTF8
```

#### 5. メモリ不足エラー

**エラー**:
```
メモリが不足しています。
```

**解決方法**:
```powershell
# PowerShellのメモリ制限を確認
$PSDefaultParameterValues['*:Verbose'] = $true

# ガベージコレクションを実行
[System.GC]::Collect()
```

## 高度なテスト実行

### デバッグモードでの実行

```powershell
# デバッグ情報を有効化
$DebugPreference = "Continue"

# テスト実行
.\Tests\ScriptAnalyzer.Tests.ps1
```

### 詳細ログの出力

```powershell
# ログファイルに出力
.\Tests\ScriptAnalyzer.Tests.ps1 | Tee-Object -FilePath "test-results.log"
```

### パフォーマンス測定

```powershell
# 実行時間の測定
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
.\Tests\ScriptAnalyzer.Tests.ps1
$stopwatch.Stop()
Write-Host "Execution time: $($stopwatch.ElapsedMilliseconds) ms"
```

## 継続的インテグレーション（CI）

### GitHub Actions用のテストスクリプト

```yaml
name: Test ScriptAnalyzer

on: [push, pull_request]

jobs:
  test:
    runs-on: windows-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Run Tests
      shell: pwsh
      run: |
        .\Tests\ScriptAnalyzer.Tests.ps1
```

### Azure DevOps用のテストスクリプト

```yaml
trigger:
- main

pool:
  vmImage: 'windows-latest'

steps:
- task: PowerShell@2
  inputs:
    targetType: 'filePath'
    filePath: 'Tests/ScriptAnalyzer.Tests.ps1'
    workingDirectory: '$(System.DefaultWorkingDirectory)'
```

## テスト結果の分析

### 成功パターン

すべてのテストが成功した場合：
- ✅ すべてのテストケースがPASS
- ✅ エラーメッセージなし
- ✅ 期待される出力値と一致

### 失敗パターン

テストが失敗した場合の分析：

1. **個別テストの失敗**
   - どのテストが失敗したか特定
   - 期待値と実際の値の比較
   - エラーメッセージの詳細確認

2. **環境の問題**
   - PowerShellバージョンの確認
   - 実行ポリシーの確認
   - ファイルパスの確認

3. **コードの問題**
   - クラス定義の構文エラー
   - メソッドの実装エラー
   - 型の不一致

## ベストプラクティス

### テスト実行前のチェックリスト

- [ ] PowerShell 5.1以上がインストールされている
- [ ] 実行ポリシーが適切に設定されている
- [ ] プロジェクトファイルが正しい場所にある
- [ ] ファイルの文字エンコーディングがUTF-8である
- [ ] 管理者権限が必要な場合は取得済み

### テスト実行後のチェックリスト

- [ ] すべてのテストがPASSしている
- [ ] エラーメッセージがない
- [ ] 期待される出力が得られている
- [ ] パフォーマンスが許容範囲内である
- [ ] ログファイルが適切に生成されている（該当する場合）

## サポート

### 問題が解決しない場合

1. **詳細なエラーログの取得**
   ```powershell
   try {
       .\Tests\ScriptAnalyzer.Tests.ps1
   } catch {
       $_.Exception | Format-List -Force
       $_.Exception.StackTrace
   }
   ```

2. **環境情報の収集**
   ```powershell
   $PSVersionTable
   Get-ExecutionPolicy
   Get-Location
   Test-Path ".\Classes\Config.ps1"
   ```

3. **サポートチームへの連絡**
   - エラーメッセージの全文
   - 実行環境の詳細
   - 実行したコマンドの履歴
   - 期待される動作と実際の動作の違い

## 更新履歴

| 日付 | バージョン | 変更内容 |
|---|---|---|
| 2024-01-XX | 1.0.0 | 初版作成 |
| 2024-01-XX | 1.1.0 | トラブルシューティング追加 |
| 2024-01-XX | 1.2.0 | CI/CD情報追加 | 
