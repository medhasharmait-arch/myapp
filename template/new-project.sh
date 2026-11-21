#!/usr/bin/env bash
# Make a new project from this template: copies template/files/ into a folder (usually the fresh clone of the new
# repo) and fills in the names. Light work (copying ~90 small files), so it runs anywhere with bash and perl:
# a Claude Code cloud session, GitHub Codespaces, or Git Bash on Windows.
#
# Usage:
#   template/new-project.sh --name Notes --app-id com.example.notes --repo you/notes [--ios-id com.example.notes.ios] [--force] <folder>
#
#   --name     App name, PascalCase (Swift/Kotlin type names, Xcode scheme, app label). Example: Notes
#   --app-id   Android applicationId and Kotlin package, lowercase dotted. Example: com.example.notes
#   --repo     GitHub owner/name, used in README and LATER links. Example: you/notes
#   --ios-id   iOS bundle id (default: <app-id>.ios)
#   --force    Overwrite files that already exist in <folder> (a README.md from GitHub is always replaced)
set -euo pipefail

usage() { sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }
die() { echo "new-project: $*" >&2; exit 1; }

NAME="" APP_ID="" IOS_ID="" REPO="" FORCE=0 TARGET=""
while [ $# -gt 0 ]; do
  case "$1" in
    --name) NAME=${2:-}; shift 2 ;;
    --app-id) APP_ID=${2:-}; shift 2 ;;
    --ios-id) IOS_ID=${2:-}; shift 2 ;;
    --repo) REPO=${2:-}; shift 2 ;;
    --force) FORCE=1; shift ;;
    -h|--help) usage 0 ;;
    -*) die "unknown option $1 (see --help)" ;;
    *) [ -z "$TARGET" ] || die "only one folder, got '$TARGET' and '$1'"; TARGET=$1; shift ;;
  esac
done
[ -n "$NAME" ] && [ -n "$APP_ID" ] && [ -n "$REPO" ] && [ -n "$TARGET" ] || usage 1
IOS_ID=${IOS_ID:-$APP_ID.ios}

# The values go into Kotlin, Swift, Gradle, XcodeGen and YAML, so keep them to safe characters.
[[ $NAME =~ ^[A-Z][A-Za-z0-9]*$ ]] || die "--name must be PascalCase letters and digits, like Notes"
[[ $APP_ID =~ ^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$ ]] || die "--app-id must look like com.example.notes"
[[ $IOS_ID =~ ^[A-Za-z][A-Za-z0-9-]*(\.[A-Za-z][A-Za-z0-9-]*)+$ ]] || die "--ios-id must look like com.example.notes.ios"
[[ $REPO =~ ^[A-Za-z0-9-]+/[A-Za-z0-9._-]+$ ]] || die "--repo must be owner/name"
for word in ${APP_ID//./ }; do
  case "$word" in
    as|break|class|continue|do|else|false|for|fun|if|in|interface|is|null|object|package|return|super|this|throw|true|try|typealias|typeof|val|var|when|while)
      die "--app-id segment '$word' is a Kotlin keyword" ;;
  esac
done
command -v perl >/dev/null || die "perl is needed"

HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SRC="$HERE/files"
[ -d "$SRC" ] || die "template files not found at $SRC"
mkdir -p "$TARGET"
TARGET=$(cd "$TARGET" && pwd)
[ "$TARGET" != "$(cd "$HERE/.." && pwd)" ] || die "refusing to write into the template's own repo"
APP_PATH=${APP_ID//./\/}

# Every template file, with its final path.
FILES=()
while IFS= read -r f; do FILES+=("$f"); done < <(cd "$SRC" && find . -type f | sed 's|^\./||' | LC_ALL=C sort)
dest_of() { local p=$1; echo "${p//__APP_PATH__/$APP_PATH}"; }

if [ "$FORCE" -eq 0 ]; then
  CONFLICTS=()
  for f in "${FILES[@]}"; do
    d=$(dest_of "$f")
    [ "$d" = "README.md" ] && continue
    [ -e "$TARGET/$d" ] && CONFLICTS+=("$d")
  done
  if [ ${#CONFLICTS[@]} -gt 0 ]; then
    printf '  %s\n' "${CONFLICTS[@]}" >&2
    die "these files already exist in $TARGET; use --force to overwrite them"
  fi
fi

for f in "${FILES[@]}"; do
  d="$TARGET/$(dest_of "$f")"
  mkdir -p "$(dirname "$d")"
  cp "$SRC/$f" "$d"
  # Fill in the tokens in text files only (the PNGs and the Gradle wrapper jar are copied as they are).
  if LC_ALL=C grep -Iq . "$d" 2>/dev/null; then
    NAME="$NAME" APP_ID="$APP_ID" IOS_ID="$IOS_ID" REPO="$REPO" perl -pi -e '
      s/__IOS_BUNDLE_ID__/$ENV{IOS_ID}/g; s/__APP_ID__/$ENV{APP_ID}/g;
      s/__APP_NAME__/$ENV{NAME}/g; s/__REPO__/$ENV{REPO}/g' "$d"
  fi
done
chmod +x "$TARGET/android/gradlew" "$TARGET/scripts/cloud-setup.sh"

LEFT=$(cd "$TARGET" && grep -rIl --exclude-dir=.git -E '__(APP_NAME|APP_ID|APP_PATH|IOS_BUNDLE_ID|REPO)__' . || true)
[ -z "$LEFT" ] || die "tokens left unfilled in: $LEFT"

cat <<EOF
Made $NAME in $TARGET (${#FILES[@]} files)
  Android: $APP_ID    iOS: $IOS_ID    Repo: $REPO

Next (template/README.md has the details):
  1. Commit on a branch and open a PR; CI runs the Android and iOS core checks.
  2. On the PR: add the 'walkthrough' label for the iOS video.
  3. Merge, then start building specs/ features in cloud sessions.
EOF
