# GLM CLI

BigModel APIを介してGLM (ChatGLM) 設定でClaude Codeを起動するためのコマンドラインインターフェースです。一時的なセッションベースの構成を使用します。

## 特徴

- 🚀 **セッションベースの起動**: Claudeを一時的にGLM設定で起動します（永続的な設定変更なし）
- 🎯 **モデル選択**: 起動時に異なるGLMモデルを選択可能（glm-4.7, glm-4.6, glm-4.5, glm-4.5-airなど）
- 🔀 **フラグのパススルー**: claude CLIのフラグを直接glm経由で渡せます（例: `--allowedTools`, `--verbose`）
- ⚡ **YOLOモード**: `--yolo`フラグで権限確認をスキップし、ワークフローを高速化
- 📦 **自動インストール**: Claude Codeを組み込みのnpm依存関係チェック機能付きでインストール
- 🔄 **自動アップデート**: インタラクティブなアップデートコマンドで更新をチェックし適用
- ⚙️ **トークン管理**: 認証トークンを安全に管理

## インストール

### クイックインストール（高速ですが、セキュリティ面で注意が必要）

`curl | bash` は便利ですが、最も安全な配布方法ではありません。

**自動インストーラー:**

```bash
curl -fsSL https://raw.githubusercontent.com/okkyok/glm/main/install.sh | bash
```

### 推奨インストール（手動 + チェックサム検証）

```bash
# 1) リリースページからバイナリとチェックサムをダウンロード
curl -fL -o glm-darwin-arm64 "https://github.com/okkyok/glm/releases/download/v1.2.0/glm-darwin-arm64"
curl -fL -o checksums.txt "https://github.com/okkyok/glm/releases/download/v1.2.0/checksums.txt"

# 2) チェックサムの検証 (macOS)
grep " glm-darwin-arm64$" checksums.txt | shasum -a 256 -c

# 3) インストール
chmod +x glm-darwin-arm64
mv glm-darwin-arm64 ~/.local/bin/glm
```

**別の方法 - 手動クイックインストール:**

```bash
# ユーザーのbinディレクトリを作成し、GLM CLIをダウンロード
mkdir -p ~/.local/bin
curl -L -o ~/.local/bin/glm "https://github.com/okkyok/glm/releases/download/v1.2.0/glm-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m | sed 's/x86_64/amd64/')"
chmod +x ~/.local/bin/glm

# PATHに追加（一度だけのセットアップ）
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

どちらの方法でも以下のことが行われます：

- OSとアーキテクチャの検出
- 最新のバイナリリリースのダウンロード
- ユーザーディレクトリへのインストール
- アクセスを容易にするためのPATH設定

### 手動インストール

#### オプション1: ビルド済みバイナリをダウンロード

1. [リリースページ](https://github.com/okkyok/glm/releases)へ行く
2. お使いのプラットフォーム用のバイナリをダウンロード：
   - macOS Intel: `glm-darwin-amd64`
   - macOS Apple Silicon: `glm-darwin-arm64`
   - Linux x64: `glm-linux-amd64`
   - Linux ARM64: `glm-linux-arm64`
3. 実行権限を与えてPATHに移動：
   ```bash
   chmod +x glm-*
   sudo mv glm-* /usr/local/bin/glm
   ```

#### オプション2: ソースからビルド

**前提条件:**

- Go 1.24 以降
- GLM APIトークン

```bash
git clone https://github.com/okkyok/glm.git
cd glm
go mod tidy
go build -o glm
sudo mv glm /usr/local/bin/
```

## 認証設定

GLM CLIは、Anthropic APIトークンを提供するための複数の方法をサポートしています：

### オプション1: 環境変数（推奨）

トークンをディスクに保存しないように、環境変数を優先して使用してください：

```bash
export ANTHROPIC_AUTH_TOKEN="your_token_here"
glm
```

`GLM_TOKEN` もフォールバック変数としてサポートされています。

### オプション2: インタラクティブな設定（TTYのみ）

初回実行時、CLIはトークンの設定を求めるプロンプトを表示します：

```bash
glm  # トークンが見つからない場合は入力を求められます
```

### オプション3: 手動でのトークン設定

```bash
glm token set  # トークンを安全に入力します
```

### 非インタラクティブ環境（CI/スクリプト）

CIやスクリプトの場合は、プロンプトを無効にして環境変数を使用してください：

```bash
export GLM_NON_INTERACTIVE=1
export ANTHROPIC_AUTH_TOKEN="your_token_here"
glm --non-interactive
```

**トークンの優先順位:**

1. 環境変数 `ANTHROPIC_AUTH_TOKEN`
2. 環境変数 `GLM_TOKEN`
3. 設定ファイル `~/.glm/config.json`
4. インタラクティブなプロンプト（TTYのみ、`GLM_NON_INTERACTIVE=1` または `--non-interactive` で無効化可能）

## 使い方

### ClaudeをGLMで起動（主要な機能）

デフォルトモデル (glm-4.7) でClaudeを起動：

```bash
glm
```

特定のモデルでClaudeを起動：

```bash
glm --model glm-4.5-air
glm -m glm-4.5-air
```

YOLOモードで起動（権限確認をスキップ）：

```bash
glm --yolo
glm --yolo --model glm-4.5-air
```

プロンプトを明示的に無効化（スクリプト/自動化用）：

```bash
glm --non-interactive
```

その他のフラグを直接Claudeに渡す：

```bash
glm --allowedTools "Bash,Read,Write"
glm --verbose
glm --yolo --allowedTools "Bash,Read"
```

**仕組み:**

- Claudeセッション用に一時的な環境変数を設定します
- Claudeの設定ファイルに対する永続的な変更は行いません
- 設定は起動されたClaudeセッションにのみ適用されます
- GLMなしでClaudeを使用する場合は、直接 `claude` を実行してください

### Claude Codeのインストール

npm経由でClaude Codeをインストール（Node.jsを自動検出）：

```bash
glm install claude
```

### 認証トークンの管理

APIトークンを設定：

```bash
glm token set
```

現在のトークンを表示（マスク表示）：

```bash
glm token show
```

保存されたトークンを消去：

```bash
glm token clear
```

### GLMのアップデート

アップデートをチェック：

```bash
glm update --check
```

最新バージョンにアップデート：

```bash
glm update
```

確認なしでアップデート：

```bash
glm update --force
```

`glm update` は、インストール前にリリースの `checksums.txt` からSHA-256チェックサムを検証します。
リリースにチェックサムが公開されていない場合、デフォルトでアップデートは失敗します。
リスクを承知の上でこれをバイパスする場合のみ、以下を実行してください：

```bash
GLM_ALLOW_UNVERIFIED=1 glm update
```

### ヘルプ

各コマンドのヘルプを表示：

```bash
glm --help
glm install --help
glm token --help
glm update --help
```

## コマンドリファレンス

| コマンド             | 説明                               | 例                          |
| -------------------- | ---------------------------------- | --------------------------- |
| `glm`                | GLMでClaudeを起動（一時的な設定）  | `glm --model glm-4.7`       |
| `glm --yolo`         | 権限確認をスキップして起動         | `glm --yolo`                |
| `glm --<flag>`       | claudeにフラグを渡す               | `glm --allowedTools "Bash"` |
| `glm install claude` | Claude Codeをインストール          | `glm install claude`        |
| `glm token set`      | 認証トークンを設定                 | `glm token set`             |
| `glm token show`     | 現在のトークンを表示（マスク表示） | `glm token show`            |
| `glm token clear`    | 保存されたトークンを消去           | `glm token clear`           |
| `glm update`         | GLMを最新バージョンに更新          | `glm update`                |
| `glm update --check` | アップデートのチェックのみ行う     | `glm update --check`        |

### 非推奨のコマンド

これらのコマンドは非推奨であり、現在は動作しません。代わりに `--model` フラグ付きで `glm` を使用してください：

| コマンド      | 状態                  | 代替                   |
| ------------- | --------------------- | ---------------------- |
| `glm enable`  | ⚠️ 非推奨（動作なし） | 代わりに `glm` を使用  |
| `glm disable` | ⚠️ 非推奨（動作なし） | 直接 `claude` を実行   |
| `glm set`     | ❌ 削除済み           | `glm --model X` を使用 |

## 利用可能なモデル

- `glm-4.7` (デフォルト)
- `glm-4.6`
- `glm-4.5`
- `glm-4.5-air`
- その他、BigModel APIでサポートされているすべてのGLMモデル

## 設定ファイル

CLIは以下のファイルを管理します：

- `~/.glm/config.json` - 認証トークンと設定

`~/.glm/config.json` は制限的な権限 (`0600`) で書き込まれます。
より高いセキュリティのために、トークンが永続化されない環境変数の使用を推奨します。

**注意:** GLMは `~/.claude/settings.json` を変更しません。すべての設定は一時的な環境変数を介して渡されます。

## 仕組み

1. **起動 (`glm`)**: 以下のパスを含む一時的な環境変数でClaude Codeを起動します：
   - `ANTHROPIC_BASE_URL=https://open.bigmodel.cn/api/anthropic`
   - `ANTHROPIC_AUTH_TOKEN=<あなたのトークン>`
   - `ANTHROPIC_MODEL=<選択されたモデル>`

2. **セッションベース**: 設定は起動されたClaudeセッションにのみ存在します。永続的なファイル変更は行われません。

3. **トークンの保存**: 利便性のためにトークンを `~/.glm/config.json` (権限 `0600`) に保存できますが、より強固なセキュリティのために環境変数を推奨します。

4. **インストール**: npmの有無をチェックし、Claude Codeをグローバルにインストールします。

5. **アップデート**: GitHubから最新バージョンのGLMバイナリをダウンロードして置き換えます。

## ワークフローの例

```bash
# GLM CLIをインストール
curl -fsSL https://raw.githubusercontent.com/okkyok/glm/main/install.sh | bash

# 初回セットアップ
glm install claude        # Claude Codeをインストール
glm token set            # トークンを安全に入力

# GLMでClaudeを起動 (デフォルトモデル: glm-4.7)
glm

# 特定のモデルで起動
glm --model glm-4.5-air

# YOLOモードで起動（権限確認をスキップ）
glm --yolo

# Claudeに追加のフラグを渡す
glm --allowedTools "Bash,Read,Write"

# GLMなしでClaudeを使用
claude

# アップデートをチェック
glm update --check

# 最新バージョンにアップデート
glm update
```

## トラブルシューティング

### インストールの問題

#### curlが見つからない

"curl not found" エラーが出る場合：

- **macOS**: Xcode Command Line Toolsをインストール: `xcode-select --install`
- **Linux**: curlをインストール: `sudo apt install curl` (Ubuntu/Debian) または `sudo yum install curl` (CentOS/RHEL)

#### インストール中に権限拒否 (Permission denied)

インストーラーが権限エラーで失敗する場合：

```bash
# ダウンロードして手動でsudoを指定して実行
curl -fsSL https://raw.githubusercontent.com/okkyok/glm/main/install.sh -o install.sh
chmod +x install.sh
sudo ./install.sh
```

#### お使いのプラットフォーム用のバイナリが見つからない

プラットフォーム用のバイナリが利用可能でない場合：

1. [リリースページ](https://github.com/okkyok/glm/releases)で利用可能なバイナリを確認してください
2. 手動インストールの手順に従ってソースからビルドしてください

### 実行時の問題

#### npmが見つからない

`glm install claude` 実行時にnpmエラーが出る場合：

1. https://nodejs.org/ からNode.jsをインストールしてください
2. ターミナルを再起動してください
3. 再度 `glm install claude` を実行してください

#### 認証トークンが見つからない

以下のいずれかの方法でトークンを設定してください：

- 環境変数を設定（推奨）: `export ANTHROPIC_AUTH_TOKEN="your_token"`
- またはフォールバック変数を設定: `export GLM_TOKEN="your_token"`
- `glm token set` (TTY only)

CIや非インタラクティブなシェルでは、プロンプトは無効化されます：

```bash
export GLM_NON_INTERACTIVE=1
export ANTHROPIC_AUTH_TOKEN="your_token"
glm --non-interactive
```

#### Claudeがデフォルト設定のままになる

セッションベースの構成は以下を意味します：

- 設定は `glm` 経由で起動されたClaudeセッションにのみ適用されます
- 直接 `claude` を実行すると、デフォルト設定が使用されます
- これは意図的な動作です。GLM設定で起動するには `glm` を使用してください

#### インストール後にコマンドが見つからない

インストール後に `glm` コマンドが見つからない場合：

1. `/usr/local/bin` または `~/.local/bin` がPATHに含まれているか確認してください: `echo $PATH`
2. 含まれていない場合はPATHに追加してください（`.bashrc` や `.zshrc` などに追加）:
   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   ```
3. ターミナルを再起動するか、以下を実行してください: `source ~/.bashrc` (または `.zshrc`)

#### アップデートが権限エラーで失敗する

`glm update` が権限拒否で失敗する場合：

```bash
sudo glm update
```

## 以前のバージョンからの移行

バージョン 1.0.x からアップグレードする場合：

### ⚠️ 重要: 古い設定ファイルの確認

バージョン 1.0.x は `~/.claude/settings.json` を永続的に作成していた可能性があります。
セッションベースのバージョンはこのファイルを使用しません。もしこのファイルにGLMの上書き設定が残っていると、`claude` が予期せずGLMを使い続ける可能性があります。

```bash
cat ~/.claude/settings.json
```

このファイルにGLMの環境変数値がハードコードされており、その動作を望まない場合は、手動で削除してください。

### その他の変更点:

1. **非推奨のコマンド**: `glm enable` と `glm disable` は警告を表示し、何もしません。
2. **削除されたコマンド**: `glm set` は削除されました。代わりに `glm --model X` を使用してください。
3. **新しい使い方**: GLMでClaudeを起動するには `glm` を実行し、モデルを指定するには `glm --model X` を実行するだけです。

## ライセンス

MIT License - 詳細は [LICENSE](LICENSE) ファイルを参照してください。

## 貢献

1. リポジトリをフォークする
2. フィーチャーブランチを作成する
3. 変更を加える
4. 該当する場合はテストを追加する
5. プルリクエストを送信する

## サポート

問題や機能のリクエストについては、リポジトリでIssueを作成してください。
