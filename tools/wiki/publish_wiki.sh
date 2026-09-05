#!/usr/bin/env bash
# Publish DIVINER's wiki/ folder to the GitHub wiki.
#
# A GitHub wiki is its own git repository, <repo>.wiki.git, and it only exists
# once somebody has created the first page in the web UI - there is no API for
# that. Until then this script fails at the clone with "Repository not found":
# open https://github.com/ghosts-of-battle/DIVINER/wiki, press "Create the
# first page", save anything, then run this. The push replaces that page.
#
# WHAT IT PUBLISHES: every *.md in wiki/, exactly, and nothing else. A page
# removed from wiki/ is removed from the wiki. Home.md, _Sidebar.md and
# _Footer.md are the wiki's own reserved names and go up as they are.
#
# AUTH: plain git over HTTPS through the credential helper already used for
# origin (Git Credential Manager on this box). Run from Git Bash on Windows.
#
# Usage:  tools/wiki/publish_wiki.sh [--dry-run]

set -euo pipefail

REPO="https://github.com/ghosts-of-battle/DIVINER.wiki.git"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$(cd "$HERE/../../wiki" && pwd)"
WORK="${WIKI_PUBLISH_WORKDIR:-${TMPDIR:-/tmp}/diviner-wiki-publish}"
DRY=0
[ "${1:-}" = "--dry-run" ] && DRY=1

export GIT_TERMINAL_PROMPT=0

echo "source : $SRC ($(ls "$SRC"/*.md | wc -l) pages)"
echo "target : $REPO"

rm -rf "$WORK"
if ! git clone --quiet "$REPO" "$WORK" 2>/tmp/diviner-wiki-clone.err; then
    echo
    echo "clone failed:"; cat /tmp/diviner-wiki-clone.err
    echo
    echo "If it says 'Repository not found', the wiki has never been initialised:"
    echo "open https://github.com/ghosts-of-battle/DIVINER/wiki, press 'Create the"
    echo "first page', save it, and run this again."
    exit 1
fi

cd "$WORK"
# every existing page out, every current page in - so deletions propagate
find . -maxdepth 1 -name '*.md' -type f -delete
cp "$SRC"/*.md .
git add -A

if git diff --cached --quiet; then
    echo "wiki already up to date - nothing to publish"
    exit 0
fi

echo
git diff --cached --stat | tail -n 20

if [ "$DRY" = 1 ]; then
    echo
    echo "dry run - not committed, not pushed"
    exit 0
fi

git commit --quiet -m "Publish wiki from DIVINER wiki/ ($(date +%Y-%m-%d))

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
git push --quiet origin HEAD
echo
echo "published: https://github.com/ghosts-of-battle/DIVINER/wiki"
