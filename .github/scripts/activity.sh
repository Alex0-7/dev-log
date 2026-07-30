#!/bin/bash
set -e

TODAY=$(date -u +%Y-%m-%d)
YESTERDAY=$(date -u -d 'yesterday' +%Y-%m-%d)
LAST_DATE=$(git log -1 --format=%ai 2>/dev/null | cut -d' ' -f1 || echo "none")
RANDOM=$(( $(date +%s) + $$ ))

if [ "$LAST_DATE" = "$TODAY" ]; then
  echo "Already active today. Skipping."
  exit 0
fi

if [ "$LAST_DATE" = "$YESTERDAY" ] || [ "$LAST_DATE" = "$TODAY" ]; then
  ACTIVE_PROB=75
else
  ACTIVE_PROB=35
fi

if [ $(( RANDOM % 100 )) -ge $ACTIVE_PROB ]; then
  echo "Rest day. No activity."
  git config user.name "Alex0-7"
  git config user.email "Alex0-7@users.noreply.github.com"
  exit 0
fi

R=$(( RANDOM % 100 ))
if [ $R -lt 30 ]; then
  COMMITS=$(( RANDOM % 3 + 1 ))
elif [ $R -lt 60 ]; then
  COMMITS=$(( RANDOM % 3 + 3 ))
elif [ $R -lt 85 ]; then
  COMMITS=$(( RANDOM % 4 + 5 ))
else
  COMMITS=$(( RANDOM % 7 + 8 ))
fi

echo "Active day! Making $COMMITS commits."

MSGS_FIX=("fix: typo in login handler" "fix: broken redirect on logout" "fix: null check in parser" "fix: off-by-one in pagination" "fix: missing import" "fix: incorrect error message")
MSGS_REFACTOR=("refactor: clean up imports" "refactor: extract helper function" "refactor: simplify conditional" "refactor: rename variables for clarity" "refactor: remove dead code" "refactor: split large function")
MSGS_UPDATE=("update config values" "bump dependencies" "update README" "update docs" "bump version" "sync config")
MSGS_DOCS=("docs: add inline comments" "docs: update API reference" "docs: fix typos" "docs: add usage examples")
MSGS_CHORE=("chore: format code" "chore: cleanup whitespace" "chore: update timestamps" "chore: sync data")
ALL_MSGS=("${MSGS_FIX[@]}" "${MSGS_REFACTOR[@]}" "${MSGS_UPDATE[@]}" "${MSGS_DOCS[@]}" "${MSGS_CHORE[@]}")

CATEGORIES=("Fixed" "Worked on" "Reviewed" "Debugged" "Refactored" "Added" "Updated" "Investigated" "Cleaned up" "Wrote")
ITEMS=("login redirect bug" "PR #$(( RANDOM % 99 + 1 ))" "API client tests" "memory leak in cache layer" "notification service" "input validation" "deployment scripts" "slow query on users table" "stale TODO comments" "unit tests for auth middleware" "error handling in worker pool" "logging format" "CI pipeline config")
CHANGES=("fixed typo in login handler" "updated dependencies" "added unit tests" "refactored parser module" "cleaned up logging" "improved error messages" "added input validation" "fixed memory leak" "updated README" "refactored auth middleware")

git config user.name "Alex0-7"
git config user.email "Alex0-7@users.noreply.github.com"

for i in $(seq 1 $COMMITS); do
  FILE_TYPE=$(( RANDOM % 4 ))

  case $FILE_TYPE in
    0)
      BUILD=$(( RANDOM % 5000 + 100 ))
      cat > .data/stats.json <<- JSONEOF
{
  "version": "$TODAY.$(( RANDOM % 99 + 1 ))",
  "build": $BUILD,
  "updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "tests": {
    "total": $(( RANDOM % 500 + 1000 )),
    "passed": $(( RANDOM % 500 + 995 )),
    "failed": $(( RANDOM % 3 ))
  }
}
JSONEOF
      git add .data/stats.json
      ;;
    1)
      NOTES_ITEMS=""
      for j in $(seq 1 $(( RANDOM % 4 + 2 ))); do
        CAT=${CATEGORIES[$(( RANDOM % ${#CATEGORIES[@]} ))]}
        ITEM=${ITEMS[$(( RANDOM % ${#ITEMS[@]} ))]}
        NOTES_ITEMS+="* $CAT $ITEM"$'\n'
      done
      cat > "notes/$TODAY.md" <<- NOTESEOF
# Notes - $TODAY

$NOTES_ITEMS
NOTESEOF
      git add "notes/$TODAY.md"
      ;;
    2)
      CHANGELOG_ENTRY="## [$(date -u +%Y.%m.%d).$(( RANDOM % 99 + 1 ))] - $TODAY
### ${CATEGORIES[$(( RANDOM % ${#CATEGORIES[@]} ))]}
* ${CHANGES[$(( RANDOM % ${#CHANGES[@]} ))]}
* ${CHANGES[$(( RANDOM % ${#CHANGES[@]} ))]}

"
      { printf '%s' "$CHANGELOG_ENTRY"; cat changelog.md 2>/dev/null || true; } > /tmp/changelog.md
      mv /tmp/changelog.md changelog.md
      git add changelog.md
      ;;
    3)
      echo "$(date -u +'%Y-%m-%d %H:%M:%S UTC') - session $(( RANDOM % 1000 ))" >> activity.log
      git add activity.log
      ;;
  esac

  MSG=${ALL_MSGS[$(( RANDOM % ${#ALL_MSGS[@]} ))]}
  git commit -m "$MSG"
done

echo "Done. $COMMITS commits made."
