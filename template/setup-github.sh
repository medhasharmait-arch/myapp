#!/usr/bin/env bash
# Set up a new GitHub repo the way this workflow expects. Light: a dozen GitHub API calls through `gh`.
# Run it as the repo's owner (admin), from any shell with GitHub CLI signed in (`gh auth status`).
#
# Usage: template/setup-github.sh <owner/name>
#
# Does, and is safe to run again:
#   - labels: ios (Mac run with @claude), walkthrough (iOS simulator video)
#   - repo settings: Actions may only read by default; squash merges; head branches deleted after merge
#   - ruleset "Protect main": no deletion, no force-push, PRs only, required checks
#     android-build, android-e2e, ios-core-test (they always report: see android.yml and ios-core.yml)
#   - asks for the secrets; you paste them into gh's own prompt, so they never land in a file or in chat
set -euo pipefail

REPO=${1:-}
[[ $REPO =~ ^[A-Za-z0-9-]+/[A-Za-z0-9._-]+$ ]] || { sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }
gh repo view "$REPO" --json name >/dev/null || { echo "Can't see $REPO with gh. Run: gh auth login"; exit 1; }

echo "== Labels"
gh label create ios --repo "$REPO" --force --color 000000 \
  --description "Request a macOS run (@claude on a Mac runner)"
gh label create walkthrough --repo "$REPO" --force --color 5319E7 \
  --description "Record the Maestro flows on the iOS simulator as a video"

echo "== Repo settings"
gh api -X PATCH "repos/$REPO" -F delete_branch_on_merge=true -F allow_squash_merge=true >/dev/null
gh api -X PUT "repos/$REPO/actions/permissions/workflow" \
  -f default_workflow_permissions=read -F can_approve_pull_request_reviews=false

echo "== Ruleset: Protect main"
RULESET=$(cat <<'JSON'
{
  "name": "Protect main",
  "target": "branch",
  "enforcement": "active",
  "conditions": { "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] } },
  "rules": [
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    { "type": "pull_request", "parameters": {
        "required_approving_review_count": 0, "dismiss_stale_reviews_on_push": false,
        "require_code_owner_review": false, "require_last_push_approval": false,
        "required_review_thread_resolution": false } },
    { "type": "required_status_checks", "parameters": {
        "strict_required_status_checks_policy": false,
        "required_status_checks": [
          { "context": "android-build", "integration_id": 15368 },
          { "context": "android-e2e", "integration_id": 15368 },
          { "context": "ios-core-test", "integration_id": 15368 } ] } }
  ]
}
JSON
)
# integration_id 15368 is GitHub Actions, so only Actions can satisfy the checks.
ID=$(gh api "repos/$REPO/rulesets" --jq '.[] | select(.name == "Protect main") | .id' | head -n1)
if [ -n "$ID" ]; then
  gh api -X PUT "repos/$REPO/rulesets/$ID" --input - <<< "$RULESET" >/dev/null && echo "updated ruleset $ID"
else
  gh api -X POST "repos/$REPO/rulesets" --input - <<< "$RULESET" --jq '"created ruleset \(.id)"'
fi

echo "== Secrets"
HAVE=$(gh secret list --repo "$REPO" --json name --jq '.[].name')
ask_secret() {
  local name=$1 why=$2
  if grep -qx "$name" <<< "$HAVE"; then echo "$name: already set"; return; fi
  echo "$name: $why"
  if [ -t 0 ]; then
    read -r -p "  Set it now? [y/N] " yes
    if [[ $yes =~ ^[Yy] ]]; then gh secret set "$name" --repo "$REPO"; return; fi
  fi
  echo "  Later: gh secret set $name --repo $REPO"
}
ask_secret CLAUDE_CODE_OAUTH_TOKEN "lets ios-claude.yml run Claude on a Mac runner. Make one with: claude setup-token"
ask_secret APPETIZE_API_TOKEN "optional; the iOS walk-through also uploads to Appetize (appetize.io → Account → API token)"

cat <<EOF

Done. Still to do by hand (template/README.md, step 2):
  - Install the Claude GitHub app on $REPO: https://github.com/apps/claude → Configure
  - After the first Appetize upload: gh variable set APPETIZE_PUBLIC_KEY --repo $REPO --body <key from the run summary>
EOF
