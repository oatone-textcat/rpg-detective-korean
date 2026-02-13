#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
cd "$SCRIPT_DIR"

log() { printf '%s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

# Common Steam roots on Steam Deck / Linux
STEAM_ROOTS=(
  "$HOME/.steam/steam"
  "$HOME/.local/share/Steam"
)

find_proton_candidates() {
  local root
  for root in "${STEAM_ROOTS[@]}"; do
    [[ -d "$root" ]] || continue

    # 1) Official Proton installs
    if [[ -d "$root/steamapps/common" ]]; then
      find "$root/steamapps/common" -maxdepth 2 -type f -name proton 2>/dev/null
    fi

    # 2) Custom compatibility tools (Proton-GE, etc.)
    if [[ -d "$root/compatibilitytools.d" ]]; then
      find "$root/compatibilitytools.d" -maxdepth 3 -type f -name proton 2>/dev/null
    fi
  done
}

choose_proton() {
  local candidates=()
  local p

  while IFS= read -r p; do
    [[ -x "$p" ]] && candidates+=("$p")
  done < <(find_proton_candidates | sort -u)

  ((${#candidates[@]} > 0)) || return 1

  # Prefer Proton Experimental if present
  for p in "${candidates[@]}"; do
    if [[ "$p" == *"Proton Experimental"*"/proton" ]]; then
      echo "$p"
      return 0
    fi
  done

  # Otherwise, pick the "newest-looking" Proton by sorting path strings descending.
  # This is a heuristic but works well for typical Steam layouts.
  printf '%s\n' "${candidates[@]}" | sort -r | head -n 1
}

PROTON_PATH="$(choose_proton || true)"
[[ -n "${PROTON_PATH:-}" ]] || die "Could not find Proton. Install Proton (or Proton Experimental) via Steam, then retry."

log "Using Proton: $PROTON_PATH"

# Use a dedicated prefix inside the patch folder to avoid touching game prefixes.
export STEAM_COMPAT_CLIENT_INSTALL_PATH="${STEAM_ROOTS[0]}"
export STEAM_COMPAT_DATA_PATH="${SCRIPT_DIR}/_proton_prefix"
mkdir -p "$STEAM_COMPAT_DATA_PATH"

# Run the batch file via cmd.exe in Proton.
# We use absolute Windows path mapping through Proton's drive setup automatically.
log ""
log "Launching patch.bat via Proton..."
log ""

"$PROTON_PATH" run cmd /c patch.bat
RC=$?

log ""
if [[ $RC -eq 0 ]]; then
  log "Patch process finished (exit code 0)."
else
  log "Patch process finished with non-zero exit code: $RC"
fi
exit "$RC"
