# ============================================================
# .zshrc  (macOS / zsh)
#
# !! 秘密情報（API キー・トークン・社内ホスト名）は絶対にここへ書かない !!
#    それらは ~/.zshrc.local に書く（.gitignore 済み、末尾で読み込む）。
#    テンプレート: .zshrc.local.example
# ============================================================

# ------------------------------------------------------------
# PATH
#   注意: PATH に "~" をクォート付きで書くとチルダが展開されず、
#   カレントディレクトリからの相対パス "./~/..." として解釈される。
#   悪意あるディレクトリを掴まされる PATH ハイジャックの原因になるので
#   必ず $HOME を使う。
# ------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"

# ------------------------------------------------------------
# oh-my-zsh
# ------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
# ZSH_THEME="candy"

# 自動更新は明示的に実行する（起動時に勝手に git pull させない）
zstyle ':omz:update' mode disabled

plugins=(git python aws poetry-env)

[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# ------------------------------------------------------------
# 補完・入力支援（syntax-highlighting は必ず最後に読み込む）
# ------------------------------------------------------------
BREW_PREFIX="$(brew --prefix 2>/dev/null)"
if [ -n "$BREW_PREFIX" ]; then
  # fzf-tab を使う場合は autosuggestions より前に読み込む
  # source "$BREW_PREFIX/share/fzf-tab/fzf-tab.plugin.zsh"
  source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'   # 大文字小文字を無視
zstyle ':completion:*' menu select                        # 候補をカーソル選択

# ------------------------------------------------------------
# 履歴
#   HISTSIZE を大きくした分、平文の履歴が長く残る。
#   秘匿コマンドは「行頭にスペース」を入れて実行する（hist_ignore_space）。
# ------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt share_history          # 複数ペイン間で履歴を共有
setopt hist_ignore_all_dups   # 重複を除去
setopt hist_reduce_blanks     # 余分な空白を削除
setopt hist_ignore_space      # 行頭スペースのコマンドは記録しない（秘匿用）

# 履歴ファイルは本人のみ読み書き可にする（初回だけでよいが冪等なので毎回実行）
[ -f "$HISTFILE" ] && [ "$(stat -f '%Lp' "$HISTFILE" 2>/dev/null)" != "600" ] && chmod 600 "$HISTFILE"

# 秘密情報を含みやすいコマンドは履歴に残さない
export HISTORY_IGNORE='(*(TOKEN|KEY|SECRET|PASSWORD|PASSWD|CREDENTIAL)*=*|curl *Authorization*|aws * --secret*|* --password *|export *_KEY=*)'

# ------------------------------------------------------------
# ディレクトリ移動
# ------------------------------------------------------------
setopt auto_cd auto_pushd pushd_ignore_dups
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"   # z <部分文字列> でジャンプ

# ------------------------------------------------------------
# fzf
# ------------------------------------------------------------
command -v fzf >/dev/null && source <(fzf --zsh)   # Ctrl+R 履歴 / Ctrl+T ファイル / Alt+C ディレクトリ

# 秘匿ファイルが候補・プレビューに出ないよう除外（画面共有時の事故防止）
export FZF_DEFAULT_COMMAND='fd --type f --hidden \
  --exclude .git --exclude .env --exclude .aws --exclude .ssh --exclude .gnupg \
  --exclude .netrc --exclude .kube --exclude .docker \
  --exclude node_modules --exclude .venv'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers {}'"
# Alt+C のディレクトリ候補も同じ方針で除外
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git --exclude .aws --exclude .ssh --exclude node_modules --exclude .venv'

# ------------------------------------------------------------
# alias
# ------------------------------------------------------------
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --git --time-style=long-iso --group-directories-first'
alias la='ll -a'
alias lt='eza --tree --level=2 --icons'
alias cat='bat --paging=never'
alias so='source'
alias vz='vim ~/.zshrc'

# 事故防止（上書き・削除の確認）
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -p'
alias diff='diff -U1'

# git
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'

# grep → ripgrep
#   grep 自体は潰さない。オプション体系も既定挙動（再帰・.gitignore 尊重・
#   バイナリスキップ）も異なり、grep のつもりで打つと取りこぼすため。
#   rg はそのまま rg と打つ。
# alias grep='rg'
alias rgh='rg --hidden --no-ignore'    # .gitignore とドットファイルも対象

# find → fd
alias find='fd'
alias fda='fd --hidden --no-ignore'    # .gitignore とドットファイルも対象

# du / df
alias du='dust'
alias df='duf'

# ps / top
alias ps='procs'
alias top='btop'
alias htop='btop'

# sed → sd
#   sed 自体は潰さない（sd は置換専用で、-n や範囲指定などの体系が違う）
alias sedre='sd'

# man → tldr
alias help='tldr'

# json
alias jl='jless'

# 元のコマンドに戻したいとき
alias ols='command ls'
alias ocat='command cat'
alias ogrep='command grep'
alias ofind='command find'

# ------------------------------------------------------------
# 言語ランタイム
# ------------------------------------------------------------
if command -v pyenv >/dev/null; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# npm のグローバル領域（$HOME を使う。"~" のクォートは PATH ハイジャックの元）
[ -d "$HOME/.npm-global/bin" ] && export PATH="$HOME/.npm-global/bin:$PATH"
[ -d "$HOME/.tiup/bin" ]       && export PATH="$HOME/.tiup/bin:$PATH"

# ------------------------------------------------------------
# プロンプト
#   starship を使う場合は oh-my-zsh のテーマより後に置く（テーマは上書きされる）
# ------------------------------------------------------------
command -v starship >/dev/null && eval "$(starship init zsh)"

# ------------------------------------------------------------
# エディタ統合
# ------------------------------------------------------------
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# ------------------------------------------------------------
# マシン固有設定・秘密情報（このリポジトリでは管理しない）
#   API キーなどはすべてここ。ファイルは chmod 600 にしておく。
# ------------------------------------------------------------
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
