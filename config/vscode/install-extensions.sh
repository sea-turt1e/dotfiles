#!/usr/bin/env bash
# extensions.txt に列挙された拡張機能をインストールする。
#
#   bash config/vscode/install-extensions.sh          # インストール
#   DRY_RUN=1 bash config/vscode/install-extensions.sh # 一覧表示のみ
#
# `code` コマンドが無い場合は VS Code で
# Cmd+Shift+P → "Shell Command: Install 'code' command in PATH" を実行する。
set -euo pipefail

LIST="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/extensions.txt"
DRY_RUN="${DRY_RUN:-0}"

if ! command -v code >/dev/null 2>&1; then
    echo "code コマンドが見つからない。" >&2
    echo "VS Code で Cmd+Shift+P → \"Shell Command: Install 'code' command in PATH\"" >&2
    exit 1
fi

# コメント・空行・行末コメントを除去して拡張機能 ID だけ取り出す
ids="$(sed -e 's/#.*//' -e 's/[[:space:]]*$//' "$LIST" | grep -v '^$' || true)"

installed="$(code --list-extensions | tr '[:upper:]' '[:lower:]')"

while IFS= read -r id; do
    [ -z "$id" ] && continue
    if grep -qx "$(echo "$id" | tr '[:upper:]' '[:lower:]')" <<< "$installed"; then
        echo "  済み   : $id"
        continue
    fi
    if [ "$DRY_RUN" = "1" ]; then
        echo "  [dry-run] code --install-extension $id"
    else
        echo "  install: $id"
        code --install-extension "$id"
    fi
done <<< "$ids"

echo
echo "完了。リストに無いのに入っている拡張機能は次で確認できる:"
echo "  comm -13 <(sed -e 's/#.*//' -e 's/[[:space:]]*\$//' '$LIST' | grep -v '^\$' | sort) <(code --list-extensions | sort)"
