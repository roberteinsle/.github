#!/usr/bin/env bash
# Aktiviert "Security and quality"-Funktionen fuer alle eigenen Repos (keine Forks, keine archivierten).
#
# Aufruf:
#   DRY_RUN=1 ./github-security-enable.sh            # nur anzeigen, was passieren wuerde
#   ./github-security-enable.sh                      # ausfuehren (Standard-Owner: roberteinsle)
#   ./github-security-enable.sh anderer-owner
#
# Voraussetzung: gh CLI, angemeldet mit Scope "repo"  (gh auth status / gh auth refresh -s repo)
#
# Kosten: Secret Scanning und Code Scanning sind nur fuer PUBLIC-Repos kostenlos.
# Bei privaten Repos braucht man dafuer kostenpflichtige Lizenzen (GitHub Secret Protection /
# Code Security) -> das Skript ueberspringt sie dort bewusst.

set -uo pipefail

OWNER="${1:-roberteinsle}"
DRY_RUN="${DRY_RUN:-0}"
ERR=$(mktemp)
trap 'rm -f "$ERR"' EXIT

api() {
  local method=$1 path=$2; shift 2
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "    [dry] $method $path"
    return
  fi
  if gh api -X "$method" "$path" "$@" --silent 2>"$ERR"; then
    echo "    OK      $method $path"
  else
    echo "    FEHLER  $method $path -> $(tr '\n' ' ' < "$ERR" | head -c 200)"
  fi
}

mapfile -t REPOS < <(gh repo list "$OWNER" --source --no-archived --limit 500 \
  --json name,visibility -q '.[] | "\(.name) \(.visibility)"')

echo "Gefunden: ${#REPOS[@]} Repos fuer $OWNER"

for line in "${REPOS[@]}"; do
  repo=${line% *}
  vis=${line#* }
  echo
  echo "== $OWNER/$repo ($vis)"

  # Dependabot (kostenlos, auch privat)
  api PUT "repos/$OWNER/$repo/vulnerability-alerts"        # Dependabot alerts
  api PUT "repos/$OWNER/$repo/automated-security-fixes"    # Dependabot security updates (PRs)

  if [[ "$vis" == "PUBLIC" ]]; then
    # Private vulnerability reporting (nur public)
    api PUT "repos/$OWNER/$repo/private-vulnerability-reporting"

    # Secret scanning + Push protection
    api PATCH "repos/$OWNER/$repo" --input - <<'JSON'
{"security_and_analysis":{
  "secret_scanning":{"status":"enabled"},
  "secret_scanning_push_protection":{"status":"enabled"}
}}
JSON

    # Code scanning (CodeQL Default Setup).
    # Schlaegt fehl, wenn das Repo schon einen eigenen CodeQL-Workflow hat oder keine
    # unterstuetzte Sprache enthaelt - dann ist nichts zu tun.
    api PATCH "repos/$OWNER/$repo/code-scanning/default-setup" -f state=configured
  else
    echo "    --      privat: Secret/Code Scanning und Private Reporting uebersprungen (kostenpflichtig bzw. nicht verfuegbar)"
  fi
done

echo
echo "Fertig. Security policy: SECURITY.md im oeffentlichen Repo $OWNER/.github anlegen,"
echo "dann gilt es fuer alle Repos ohne eigene SECURITY.md."
