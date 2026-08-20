#!/bin/sh
# 旧スクリプト。`ln -sf` で既存の実ファイルを無警告で上書きしていたため、
# バックアップを取る setup.sh に統合した。互換のため呼び出しだけ残す。
exec bash "$(cd "$(dirname "$0")" && pwd)/setup.sh" "$@"
