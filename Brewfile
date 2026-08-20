# ============================================================
# Brewfile  ―  brew bundle --file=~/dotfiles/Brewfile
#
# 会社利用の前に必ず確認すること:
#   - 社内の承認済みソフトウェア一覧 / Homebrew 利用ポリシー
#   - MDM 管理下の Mac では brew や未署名バイナリが制限される場合がある
# ============================================================

# --- 必須（すべてローカル完結・外部送信なし） ---
brew "bat"          # cat 置き換え
brew "ripgrep"      # grep 置き換え（.gitignore を尊重）
brew "fd"           # find 置き換え
brew "fzf"          # 曖昧検索
brew "zoxide"       # cd 置き換え
brew "git-delta"    # git diff の可読性向上
brew "eza"          # ls 置き換え
brew "dust"         # du 置き換え
brew "duf"          # df 置き換え
brew "procs"        # ps 置き換え
brew "bottom"       # top 置き換え（btm）
brew "sd"           # sed 置き換え
brew "hyperfine"    # ベンチマーク
brew "tealdeer"     # tldr
brew "jq"
brew "yq"

# gh: 認証トークンは Keychain に保存される。
# ただし `gh auth login` で会社の GitHub Enterprise と個人アカウントを
# 取り違えないよう、初回は `gh auth status` で接続先を必ず確認する。
brew "gh"

# --- データ・Python 系 ---
brew "duckdb"       # JSONL/Parquet を SQL で直接クエリ
brew "uv"           # pip/venv/pyenv の置き換え
brew "mise"         # 言語バージョン管理
brew "visidata"     # CSV/TSV の TUI ビューア

# --- zsh プラグイン・プロンプト ---
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "zsh-completions"
brew "starship"
# brew "fzf-tab"    # Tab 補完を fzf UI に置き換え（任意）

# ============================================================
# 以下は会社利用では既定で無効。必要なら判断のうえコメントを外す
# ============================================================

# node: npm/PyPI/GitHub Releases から任意バイナリを取得する経路になるため、
#       社内のパッケージ審査ポリシーを確認してから入れる。
# brew "node"
