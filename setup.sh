#!/usr/bin/env bash
# ============================================================
# dotfiles セットアップ
#
#   bash ~/dotfiles/setup.sh          # 実際にリンクを張る
#   DRY_RUN=1 bash ~/dotfiles/setup.sh # 何をするかだけ表示
#
# 安全側の設計:
#   - 既存の実ファイルは ln -sf で握り潰さず、必ず .bak-<日時> に退避する
#   - 秘密情報を含むファイル（*.local）はリポジトリで管理せず、
#     テンプレートから生成して chmod 600 する
# ============================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
DRY_RUN="${DRY_RUN:-0}"

run() {
    if [ "$DRY_RUN" = "1" ]; then
        echo "  [dry-run] $*"
    else
        "$@"
    fi
}

# link <リポジトリ内の相対パス> <リンク先の絶対パス>
link() {
    local src="$DOTFILES_DIR/$1"
    local dst="$2"

    if [ ! -e "$src" ]; then
        echo "  skip   : $1 (リポジトリに存在しない)"
        return
    fi

    run mkdir -p "$(dirname "$dst")"

    # 既に同じ場所を指すシンボリックリンクなら何もしない
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        echo "  ok     : $dst"
        return
    fi

    # 実ファイル / 別リンクがある場合は退避してから張り替える
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        echo "  backup : $dst -> $dst.bak-$STAMP"
        run mv "$dst" "$dst.bak-$STAMP"
    fi

    echo "  link   : $dst -> $src"
    run ln -s "$src" "$dst"
}

# copy_template <テンプレート> <生成先> : 生成先が無いときだけ 600 で作る
copy_template() {
    local src="$DOTFILES_DIR/$1"
    local dst="$2"
    if [ -e "$dst" ]; then
        echo "  keep   : $dst (既存のものを使う)"
        return
    fi
    echo "  create : $dst (600)"
    run cp "$src" "$dst"
    run chmod 600 "$dst"
}

echo "==> shell / editor"
link .zshrc          "$HOME/.zshrc"
link .bashrc         "$HOME/.bashrc"
link .bash_profile   "$HOME/.bash_profile"
link .vimrc          "$HOME/.vimrc"

echo "==> git"
link .gitconfig      "$HOME/.gitconfig"
link .gitignore_global "$HOME/.gitignore_global"

echo "==> VS Code"
# 注意: VS Code は設定 UI から保存するときにファイルを置き換えることがあり、
# その際シンボリックリンクが実ファイルに戻ることがある。挙動が変だと感じたら
# `ls -l` でリンクを確認し、必要なら setup.sh を再実行する。
VSCODE_USER="$HOME/Library/Application Support/Code/User"
if [ -d "$VSCODE_USER" ]; then
    link config/vscode/settings.json    "$VSCODE_USER/settings.json"
    link config/vscode/keybindings.json "$VSCODE_USER/keybindings.json"
    echo "  note   : 拡張機能は bash $DOTFILES_DIR/config/vscode/install-extensions.sh"
else
    echo "  skip   : VS Code が未インストール"
fi

echo "==> 秘密情報・マシン固有設定（リポジトリでは管理しない）"
copy_template .zshrc.local.example     "$HOME/.zshrc.local"
copy_template .gitconfig.local.example "$HOME/.gitconfig.local"

echo "==> 秘密情報の混入を防ぐ pre-commit フック（このリポジトリに対して有効化）"
if [ -d "$DOTFILES_DIR/.git" ]; then
    echo "  hooks  : core.hooksPath = hooks"
    run git -C "$DOTFILES_DIR" config core.hooksPath hooks
fi

echo "==> パーミッションの締め直し"
for f in "$HOME/.zsh_history" "$HOME/.bash_history" "$HOME/.zshrc.local" "$HOME/.gitconfig.local" "$HOME/.gitconfig.work"; do
    if [ -f "$f" ]; then
        echo "  chmod 600 : $f"
        run chmod 600 "$f"
    fi
done

cat <<'MSG'

------------------------------------------------------------
完了。次にやること:

 1. ~/.gitconfig.local に user.name / user.email を書く
    （会社リポジトリを ~/work/ 配下に置き、~/.gitconfig.work を別に作る）
 2. ~/.zshrc.local に API キー等を書く（リポジトリには絶対に置かない）
 3. brew bundle --file=~/dotfiles/Brewfile
 4. source ~/.zshrc

退避したファイルは *.bak-<日時> という名前で残っている。
------------------------------------------------------------
MSG
