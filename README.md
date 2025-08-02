# ScriptAnalyzer
PowerShellで作成したスクリプトファイル分析ツール．指定したディレクトリ内のスクリプトファイルを種類別に集計し，詳細な統計情報を提供します．

> [!caution]
> 学習用リポジトリです．実用性はありません．


## 主な機能

- 指定ディレクトリのスキャンとファイル統計
- 言語別・カテゴリ別の集計
- ディレクトリツリー表示
- JSON/CSV形式での出力
- 外部設定ファイルによるカスタマイズ


## 使用方法

#### 基本的な使用例

```powershell
# 基本分析
Start-ScriptAnalysis -Path "C:\MyProject"

# ディレクトリツリー表示
Start-ScriptAnalysis -Path "C:\MyProject" -ShowTree -ShowFileCounts -ShowFileTypes

# カテゴリ統計の表示
Start-ScriptAnalysis -Path "C:\MyProject" -ShowCategory

# 結果をJSONファイルに出力
Start-ScriptAnalysis -Path "C:\MyProject" -OutputFormat JSON -ExportPath "results.json"
```

#### 詳細設定

```powershell
# 除外パターンを指定
Start-ScriptAnalysis -Path "C:\MyProject" -ExcludePatterns "*.tmp", "node_modules"

# 階層制限を設定
Start-ScriptAnalysis -Path "C:\MyProject" -MaxDepth 3

# ログ機能付きで分析
Start-ScriptAnalysis -Path "C:\MyProject" -LogLevel Debug -LogFilePath "analysis.log"
```


## 出力例

### 基本分析
```
Script Analysis Results: C:\Users\user\Desktop\ScriptAnalyzer
==============================================================

Language Statistics:
PowerShell      10 files ( 90.9%) - 75.4 KB, 2249 lines ##################
JSON             1 files (  9.1%) - 6.8 KB, 243 lines ##

Summary:
Total: 11 files
Total Size: 82.2 KB
Total Lines: 2492 lines
Analysis Time: 0.41 seconds
```

### ディレクトリツリー表示
```
Directory Tree: C:\Users\user\Desktop\ScriptAnalyzer
==================================

ScriptAnalyzer
 Classes (7 files)
   Config.ps1 (PowerShell) - 10.13 KB, 294 lines
   ConfigValidator.ps1 (PowerShell) - 6.68 KB, 213 lines
   DisplayUtils.ps1 (PowerShell) - 4.13 KB, 123 lines
   ErrorHandler.ps1 (PowerShell) - 2.97 KB, 102 lines
   FileInfo.ps1 (PowerShell) - 13 KB, 375 lines
   Logger.ps1 (PowerShell) - 3.86 KB, 134 lines
   ScriptAnalyzer.ps1 (PowerShell) - 19.76 KB, 533 lines
 Config (1 files)
   FileTypes.json (JSON) - 6.8 KB, 243 lines
 Examples (1 files)
   Basic-Usage.ps1 (PowerShell) - 2.96 KB, 99 lines
 Functions (1 files)
   Start-ScriptAnalysis.ps1 (PowerShell) - 7.21 KB, 240 lines
 Tests (1 files)
   ScriptAnalyzer.Tests.ps1 (PowerShell) - 4.66 KB, 136 lines

Summary:
  Total Files: 11
  Total Size: 82.2 KB
  Total Lines: 2492 lines
```

## 🔧 サポートするファイル形式

ScriptAnalyzerは、`Config/FileTypes.json`で定義されたファイル形式をサポートしています。

### 主なサポート形式

| カテゴリ | 主な拡張子 | 説明 |
|----------|------------|------|
| **Script** | `.ps1`, `.py`, `.js`, `.lua`, `.rb`, `.pl`, `.php` | 各種スクリプト言語 |
| **Source Code** | `.cs`, `.cpp`, `.c`, `.java`, `.swift`, `.kt`, `.rs`, `.go` | コンパイル言語 |
| **Web** | `.html`, `.css`, `.scss`, `.less` | Web技術 |
| **Shader** | `.shader`, `.cginc`, `.hlsl`, `.glsl` | シェーダー言語 |
| **Configuration** | `.json`, `.xml`, `.yaml`, `.toml`, `.ini` | 設定ファイル |
| **Database** | `.sql` | データベーススクリプト |

### 設定ファイルのカスタマイズ

サポートするファイル形式は、`Config/FileTypes.json`を編集することで簡単にカスタマイズできます：

```json
{
  "supportedExtensions": {
    ".your_ext": {
      "language": "Your Language",
      "category": "Your Category",
      "description": "Description of your file type"
    }
  }
}
```

詳細な設定方法については、[Config/FileTypes.json](Config/FileTypes.json)を参照してください。


## プロジェクト構造

```
ScriptAnalyzer/
├── README.md                    # このファイル
├── ScriptAnalyzer.psm1         # メインモジュール
├── ScriptAnalyzer.psd1         # モジュールマニフェスト
├── Classes/                    # 分析クラス群
├── Config/
│   └── FileTypes.json          # 外部設定ファイル
├── Functions/
│   └── Start-ScriptAnalysis.ps1 # 統合コマンドレット
├── Tests/
│   └── ScriptAnalyzer.Tests.ps1 # テスト
└── Examples/
    └── Basic-Usage.ps1         # 使用例
```

## セットアップ

### 前提条件
- PowerShell 5.1 以上

### セットアップ手順

1. リポジトリをクローン
```bash
git clone https://github.com/[username]/ScriptAnalyzer.git
cd ScriptAnalyzer
```

2. 実行ポリシーの設定（必要に応じて）
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

3. コマンドレットの読み込み
```powershell
. .\Functions\Start-ScriptAnalysis.ps1
```

## 参考資料

- [PowerShell Best Practices](https://docs.microsoft.com/en-us/powershell/scripting/dev-cross-plat/writing-portable-cmdlets)
- [PowerShell Classes](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_classes)
