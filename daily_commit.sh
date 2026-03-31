#!/usr/bin/env bash

set -euo pipefail

# Usage:
#   ./daily_commit.sh /absolute/path/to/your/repo [min_commits] [max_commits]
#
# Example:
#   ./daily_commit.sh /Users/ocean_dev2/stage/front-end-Monpatient 10 20

REPO_PATH="${1:-}"
MIN_COMMITS="${2:-10}"
MAX_COMMITS="${3:-20}"
DAILY_GIT_BRANCH="${DAILY_GIT_BRANCH:-}"
TRACK_FILE=".daily-activity.log"

if [[ -z "$REPO_PATH" ]]; then
  echo "Error: repo path is required."
  echo "Usage: ./daily_commit.sh /absolute/path/to/repo [min_commits] [max_commits]"
  exit 1
fi

if [[ ! -d "$REPO_PATH/.git" ]]; then
  echo "Error: '$REPO_PATH' is not a git repository."
  exit 1
fi

if ! [[ "$MIN_COMMITS" =~ ^[0-9]+$ && "$MAX_COMMITS" =~ ^[0-9]+$ ]]; then
  echo "Error: min/max commits must be numbers."
  exit 1
fi

if (( MIN_COMMITS < 1 || MAX_COMMITS < 1 || MIN_COMMITS > MAX_COMMITS )); then
  echo "Error: invalid range. Use values like 10 20."
  exit 1
fi

cd "$REPO_PATH"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: cannot access git repository at '$REPO_PATH'."
  exit 1
fi

# Pick current branch if not provided.
if [[ -z "$DAILY_GIT_BRANCH" ]]; then
  DAILY_GIT_BRANCH="$(git branch --show-current 2>/dev/null || true)"
fi

if [[ -z "$DAILY_GIT_BRANCH" ]]; then
  if git show-ref --verify --quiet "refs/heads/main"; then
    DAILY_GIT_BRANCH="main"
  elif git show-ref --verify --quiet "refs/heads/master"; then
    DAILY_GIT_BRANCH="master"
  fi
fi

if [[ -z "$DAILY_GIT_BRANCH" ]]; then
  echo "Error: could not detect branch. Set DAILY_GIT_BRANCH env var."
  exit 1
fi

COMMIT_COUNT=$(( RANDOM % (MAX_COMMITS - MIN_COMMITS + 1) + MIN_COMMITS ))
echo "Creating $COMMIT_COUNT commits on branch '$DAILY_GIT_BRANCH' in '$REPO_PATH'"

for (( i=1; i<=COMMIT_COUNT; i++ )); do
  NOW="$(date '+%Y-%m-%d %H:%M:%S')"
  RAND_VALUE=$(( RANDOM % 900000 + 100000 ))
  echo "$NOW | commit-$i | random=$RAND_VALUE" >> "$TRACK_FILE"

  git add "$TRACK_FILE"
  git commit -m "chore(daily): activity update $i/$COMMIT_COUNT (rand:$RAND_VALUE)"
done

git push origin "$DAILY_GIT_BRANCH"
echo "Done: pushed $COMMIT_COUNT commits."
