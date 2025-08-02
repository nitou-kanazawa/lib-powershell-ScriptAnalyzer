# ScriptAnalyzer テスト仕様書

## 概要

このドキュメントは、ScriptAnalyzerプロジェクトのテストに関する仕様を定義します。テストの目的、範囲、実行方法、期待結果を詳細に記述しています。

## テスト対象

### ScriptAnalysisConfig クラス

- **ファイル**: `Classes/Config.ps1`
- **クラス名**: `ScriptAnalysisConfig`
- **目的**: スクリプト分析の設定を管理するクラス

## テストファイル

- **テストファイル**: `Tests/ScriptAnalyzer.Tests.ps1`
- **実行方法**: `.\Tests\ScriptAnalyzer.Tests.ps1`

## テストケース詳細

### 1. null/空文字列テスト

**目的**: null値や空文字列が正しく処理されることを確認

**テスト内容**:
- `$config.IsExcluded($null)` → `$true` を返すべき
- `$config.IsExcluded("")` → `$true` を返すべき

**期待結果**:
```
null result: True
empty result: True
PASS: null/empty string test
```

**技術的根拠**:
- null参照例外を防ぐため
- 無効なパスを適切に除外するため

### 2. 拡張子サポートテスト

**目的**: サポートされている拡張子が正しく認識されることを確認

**テスト内容**:
- **サポートされている拡張子**: `.ps1`, `.py`, `.js`, `.cs`, `.json`
- **サポートされていない拡張子**: `.xyz`, `.unknown`, `""`

**期待結果**:
```
.ps1 : True
.py : True
.js : True
.cs : True
.json : True
.xyz : False
.unknown : False
 : False
PASS: Extension support test
```

**技術的根拠**:
- 大文字小文字を無視した拡張子マッチング
- 空文字列の適切な処理

### 3. 除外パターンテスト

**目的**: 除外パターンが正しく適用されることを確認

**テスト内容**:
| ファイルパス | 期待される除外 | 理由 |
|---|---|---|
| `C:\temp\test.tmp` | `True` | 一時ファイルパターン |
| `C:\temp\test.log` | `True` | ログファイルパターン |
| `C:\temp\test.ps1` | `False` | 通常のPowerShellファイル |
| `C:\temp\.git\config` | `True` | Gitディレクトリパターン |
| `C:\temp\node_modules\package.json` | `True` | node_modulesディレクトリパターン |

**期待結果**:
```
C:\temp\test.tmp - Expected: True, Actual: True
C:\temp\test.log - Expected: True, Actual: True
C:\temp\test.ps1 - Expected: False, Actual: False
C:\temp\.git\config - Expected: True, Actual: True
C:\temp\node_modules\package.json - Expected: True, Actual: True
PASS: Exclusion pattern test
```

**技術的根拠**:
- ファイル名、ディレクトリ名、フルパスの3つのレベルでのパターンマッチング
- ワイルドカードパターンの正しい処理

### 4. 設定検証テスト

**目的**: 設定オブジェクトが有効な状態であることを確認

**テスト内容**:
- `MaxDepth`が-1以上であること
- `OutputFormat`が有効な値であること
- `SupportedExtensions`が初期化されていること

**期待結果**:
```
Validation result: True
PASS: Configuration validation test
```

**技術的根拠**:
- 設定の整合性を保つため
- 実行時エラーを防ぐため

### 5. カスタム設定テスト

**目的**: カスタム設定が正しく適用されることを確認

**テスト内容**:
```powershell
$customSettings = @{
    MaxDepth = 3
    IncludeHidden = $true
    ShowProgress = $false
    ExcludePatterns = @("*.test")
}
```

**期待結果**:
```
MaxDepth: 3
IncludeHidden: True
ShowProgress: False
Has *.test pattern: True
PASS: Custom settings test
```

**技術的根拠**:
- 型安全性の確保
- 設定の上書きが正しく動作すること

## テスト実行方法

### 基本的な実行

```powershell
# プロジェクトルートディレクトリで実行
.\Tests\ScriptAnalyzer.Tests.ps1
```

### 個別テストの実行

```powershell
# クラス定義を読み込み
. ".\Classes\Config.ps1"

# 設定オブジェクトを作成
$config = [ScriptAnalysisConfig]::new()

# 個別テスト
$config.IsExcluded($null)  # True
$config.IsSupportedExtension('.ps1')  # True
$config.Validate()  # True
```

## テスト環境要件

### PowerShell要件
- PowerShell 5.1以上
- クラスサポート（PowerShell 5.0以降）

### ファイル構造
```
ScriptAnalyzer/
├── Classes/
│   └── Config.ps1
├── Tests/
│   └── ScriptAnalyzer.Tests.ps1
└── Documentation/
    └── TestSpecification.md
```

## エラーハンドリング

### 想定されるエラー

1. **型エラー**
   - 無効な型の設定値が渡された場合
   - 期待される例外が発生することを確認

2. **null参照エラー**
   - null値が適切に処理されることを確認
   - 例外が発生しないことを確認

3. **パス処理エラー**
   - 無効なパスが適切に処理されることを確認
   - `Split-Path`の失敗が適切にハンドリングされることを確認

### エラー時の期待動作

- 適切なエラーメッセージが表示される
- アプリケーションがクラッシュしない
- デフォルト値が適用される（該当する場合）

## パフォーマンス考慮事項

### 最適化された処理

1. **パス情報の一括取得**
   ```powershell
   $pathInfo = @{
       FileName = Split-Path $filePath -Leaf
       DirectoryName = Split-Path $filePath -Parent | Split-Path -Leaf
       FullPath = $filePath
   }
   ```

2. **早期リターン**
   - null/空文字列チェックで早期リターン
   - パターンマッチングで一致時に即座にリターン

3. **効率的なループ**
   - `foreach`ループの適切な使用
   - 不要な処理の回避

## 拡張性

### 新しいテストケースの追加

1. **テストケースの追加方法**
   ```powershell
   # Test X: New test case
   Write-Host "`nTest X: New test case" -ForegroundColor Yellow
   try {
       # テストロジック
       Write-Host "  PASS: New test case" -ForegroundColor Green
   } catch {
       Write-Host "  ERROR: New test case - $_" -ForegroundColor Red
   }
   ```

2. **新しいプロパティのテスト**
   - プロパティの初期化確認
   - 値の設定・取得確認
   - バリデーション確認

### テストカバレッジ

現在のテストカバレッジ:
- ✅ コンストラクタ
- ✅ プロパティ初期化
- ✅ メソッド呼び出し
- ✅ エラーハンドリング
- ✅ 型安全性
- ✅ パフォーマンス

## メンテナンス

### テストの更新タイミング

1. **新機能追加時**
   - 新しいプロパティやメソッドのテスト追加
   - 既存テストの更新（必要に応じて）

2. **バグ修正時**
   - 修正内容を反映したテストケースの追加
   - 回帰テストの実行

3. **リファクタリング時**
   - テストの動作確認
   - 必要に応じてテストの更新

### テスト結果の記録

- テスト実行日時
- 実行環境（PowerShellバージョン、OS等）
- 成功/失敗の記録
- エラー内容の詳細記録

## 参考資料

- [PowerShell Classes Documentation](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/strongly-encouraged-development-guidelines)
- [PowerShell Testing Best Practices](https://docs.microsoft.com/en-us/powershell/scripting/developer/testing-overview)
- [EditorConfig Specification](https://editorconfig.org/) 
