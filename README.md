# dotfiles

macOS / zsh / iTerm2 前提。**会社の端末でも使う**ことを想定し、
外部送信・平文保存・自動ダウンロードにかかわる設定は既定で無効、
または明示的なコメント付きにしてある。

## セットアップ

```bash
git clone <this-repo> ~/dotfiles
DRY_RUN=1 bash ~/dotfiles/setup.sh   # 何が起きるか確認
bash ~/dotfiles/setup.sh             # 実行（既存ファイルは .bak-<日時> に退避）

brew bundle --file=~/dotfiles/Brewfile
source ~/.zshrc
```

その後:

1. `~/.gitconfig.local` に `user.name` / `user.email` を書く
2. `~/.zshrc.local` に API キー等を書く（**リポジトリには絶対に置かない**）

## ファイル構成
| パス | 内容 |
|---|---|
| `.zshrc` | メイン。秘密情報は含めない |
| `.zshrc.local.example` | API キー等のテンプレート → `~/.zshrc.local` |
| `.gitconfig` | delta / 安全側の既定。**識別情報は含めない** |
| `.gitconfig.local.example` | `user.name` / `user.email` のテンプレート |
| `.gitignore_global` | 全リポジトリ共通の ignore（秘匿ファイル） |
| `.bashrc` / `.bash_profile` / `.vimrc` | Linux 環境・素の vim 用に残してある |
| `Brewfile` | `brew bundle` 用。要注意ツールはコメントアウト |
| `config/vscode/` | VS Code の設定・キーバインド・拡張機能リスト |
| `hooks/pre-commit` | 秘密情報の混入を止める |
| `setup.sh` | シンボリックリンク作成（退避つき） |

---

## 会社利用時のセキュリティ方針

### 0. 大前提

技術対策の前に、社内に**承認済みソフトウェア一覧**や **Homebrew 利用ポリシー**が
あるか確認する。MDM 管理下の Mac では `brew` や未署名バイナリの実行が
制限されている場合がある。

### 1. 秘密情報を dotfiles に置かない

API キー・トークンは `~/.zshrc.local`（`.gitignore` 済み、`chmod 600`）に置く。
可能なら環境変数に直接書かず Keychain から取り出す:

```bash
 security add-generic-password -a "$USER" -s OPENAI_API_KEY -w   # 行頭スペースで履歴に残さない
export OPENAI_API_KEY="$(security find-generic-password -a "$USER" -s OPENAI_API_KEY -w)"
```

`hooks/pre-commit` が `sk-...` / `ghp_...` / `AKIA...` / 秘密鍵 / `*.local` を検出して
コミットを止める（`setup.sh` が `core.hooksPath` を設定する）。

**一度平文で書いてしまったキーは、ファイルから消すだけでは不十分。
必ず発行元でローテーション（失効・再発行）する。** git 履歴・バックアップ・
Time Machine・シェル履歴に残っている可能性がある。

### 2. undo 履歴 / viminfo / スワップ

vim は undo 履歴・レジスタ・検索履歴を平文で残す。`.vimrc` の
`augroup secure_files` で、`.env` / `*.pem` / `*.key` / `*credentials*` /
`*secret*` / `id_rsa*` を開いたときは
`noundofile noswapfile nobackup nowritebackup viminfo=` にして無効化してある。

### 3. シェル履歴

- `HISTSIZE=100000` の分だけ平文が長く残るため、`~/.zsh_history` は `chmod 600`
  （`setup.sh` と `.zshrc` が自動で締める）
- 秘匿コマンドは**行頭にスペース**を入れて実行（`hist_ignore_space`）
- `HISTORY_IGNORE` でトークン・パスワードを含む行を記録しない

### 4. fzf のプレビュー

`FZF_DEFAULT_COMMAND` で `.env` / `.aws` / `.ssh` / `.gnupg` / `.netrc` / `.kube` /
`.docker` を除外している。画面共有中に `Ctrl+T` を押して認証情報を映す事故を防ぐ。

### 5. git の安全側の既定（`.gitconfig`）

| 設定 | 理由 |
|---|---|
| `user.*` を書かない → `includeIf` で分離 | 会社/個人アカウントの取り違え防止（`~/work/` 配下は `~/.gitconfig.work`） |
| `credential.helper = osxkeychain` | 認証情報を平文で保存しない |
| `protocol.git.allow = never` + `url.insteadOf` | `git://` は暗号化も認証もされない |
| `transfer/fetch/receive.fsckObjects` | 細工されたオブジェクトを受け取らない |
| `protocol.file.allow = user` | サブモジュール経由の既知の攻撃を防ぐ |
| `submodule.recurse = false` | 任意コードの暗黙取得を避ける |
| `help.autocorrect = 0` | タイプミスしたコマンドを勝手に実行しない |
| `core.excludesfile` | 秘匿ファイルを `git add -A` で巻き込まない |

### 6. VS Code

`config/vscode/` に実ファイルベースで格納。`setup.sh` がシンボリックリンクを張る。

```bash
bash config/vscode/install-extensions.sh          # 拡張機能を一括インストール
DRY_RUN=1 bash config/vscode/install-extensions.sh # 確認のみ
```

追加したセキュリティ設定:

| 設定 | 理由 |
|---|---|
| `telemetry.telemetryLevel: "off"` | 本体のテレメトリを止める（拡張機能の送信は別） |
| `security.workspace.trust.*` を明示 | 素性不明の repo を開いた際にタスク・拡張の自動実行を止める最後の防御線 |
| `search.exclude` に秘匿ファイル | 画面共有中に検索結果へ認証情報が出る事故を防ぐ |
| `liveServer.settings.host: "127.0.0.1"` | 作業中のソースを社内 LAN に公開しない |
| `settingsSync.ignoredSettings` | プロキシ認証情報などを外部同期の対象外にする |

安全側に倒すためコメントアウトしたもの:

| 元の設定 | 戻した理由 |
|---|---|
| `terminal.integrated.enableMultiLinePasteWarning: "never"` | Web からコピーした複数行コマンドが確認なしで実行される |
| `git.confirmSync: false` | 確認なしで push され、誤ったリモートへ送る事故を防げない |
| `github.branchProtection: false` | 保護ブランチへの直接コミット警告が出なくなる |

`terminal.integrated.copyOnSelection: true` は利便性のため有効のままにしてあるが、
Handoff が有効だと選択した社内コードが個人の iPhone / iPad に転送されうる。
気になる場合は システム設定 → 一般 → AirDrop と Handoff で Handoff をオフにする。

**VS Code は設定 UI からの保存時にファイルを置き換えることがあり、
シンボリックリンクが実ファイルに戻る場合がある。** 挙動が変なときは
`ls -l "$HOME/Library/Application Support/Code/User/settings.json"` で確認し、
`setup.sh` を再実行する。

### 7. PATH ハイジャック

`export PATH="~/local/bin:$PATH"` のように**クォート内に `~`** を書くとチルダが
展開されず、カレントディレクトリ基準の相対パスとして解釈される。移動先に
細工されたコマンドを置かれると実行してしまう。`$HOME` を使い、存在確認してから
追加すること（`.bashrc` / `.zshrc` は修正済み）。

### 8. `setup.sh` の破壊防止

旧 `dotfilesLink.sh` は `ln -sf` で既存の実ファイルを無警告で上書きしていた。
現在は必ず `.bak-<日時>` に退避してからリンクを張る。`DRY_RUN=1` で事前確認できる。

---

## 導入の優先順位

一度に全部入れると慣れないため、効果の大きい順に:

1. **delta** — git diff の可読性
2. **fzf** — Ctrl+R / Ctrl+T
3. **zoxide** — ディレクトリ移動
4. **bat / fd / ripgrep** — 基本の置き換え
5. **starship** — プロンプト（`.zshrc` でコメントアウト中）

> `alias grep='rg'` は設定していない。オプション体系も既定挙動
> （再帰・gitignore 尊重・バイナリスキップ）も異なり、grep のつもりで打つと
> 取りこぼすため。`rg` はそのまま `rg` と打つ。
