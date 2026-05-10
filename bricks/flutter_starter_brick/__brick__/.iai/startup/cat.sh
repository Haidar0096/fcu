#!/bin/bash
# Project-level startup loader. Cat'd by the home walker on every chat
# inside this project. Loads project rules + project-scoped learnings.
# Mirrors the home cat.sh pattern (~/.iai/startup/cat.sh) — same emit/expander
# helpers, same alphabetical+dedupe rendering for learnings.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HOME/.iai/scripts/emit.sh"

EXPANDER="$HOME/.iai/scripts/expand_kernel_cmds.py"

# Project rules (file always exists; may be empty until the user fills it in).
emit "$SCRIPT_DIR/rules.iai.md"

# Project-scoped learnings (created on `promote_project` at close).
LEARNINGS_DIR="$SCRIPT_DIR/learnings"
LEARNINGS_EMITTER="$HOME/.iai/scripts/emit_learnings.py"
if [ -d "$LEARNINGS_DIR" ]; then
    python3 "$LEARNINGS_EMITTER" "$LEARNINGS_DIR" | python3 "$EXPANDER"
fi
