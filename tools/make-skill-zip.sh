#!/bin/sh
# Builds dist/praxiscad-skill.zip with the skill at praxiscad/SKILL.md (layout for Claude apps / ChatGPT skill upload).
set -e
root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$root/dist" "$tmp/praxiscad"
cp -R "$root/skills/praxiscad/." "$tmp/praxiscad/"
rm -f "$root/dist/praxiscad-skill.zip"
(cd "$tmp" && zip -qr "$root/dist/praxiscad-skill.zip" praxiscad -x '*.DS_Store')
echo "$root/dist/praxiscad-skill.zip"
