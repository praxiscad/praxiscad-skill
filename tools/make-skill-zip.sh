#!/bin/sh
# Builds dist/praxiscad-skill.zip (skill at praxiscad/SKILL.md) and dist/praxiscad-local-skill.zip (praxiscad-local/SKILL.md).
set -e
root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$root/dist" "$tmp/praxiscad"
cp -R "$root/skills/praxiscad/." "$tmp/praxiscad/"
cp "$root/LICENSE" "$tmp/praxiscad/LICENSE"
rm -f "$root/dist/praxiscad-skill.zip"
(cd "$tmp" && zip -qr "$root/dist/praxiscad-skill.zip" praxiscad -x '*.DS_Store')
echo "$root/dist/praxiscad-skill.zip"
mkdir -p "$tmp/praxiscad-local"
cp -R "$root/skills/praxiscad-local/." "$tmp/praxiscad-local/"
cp "$root/LICENSE" "$tmp/praxiscad-local/LICENSE"
rm -f "$root/dist/praxiscad-local-skill.zip"
(cd "$tmp" && zip -qr "$root/dist/praxiscad-local-skill.zip" praxiscad-local -x '*.DS_Store')
echo "$root/dist/praxiscad-local-skill.zip"
