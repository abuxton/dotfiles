#!/usr/bin/env bash
# do_nothing_template.sh
#
# TEMPLATE — Do-Nothing Script
# Generated from: <source file or procedure description>
#
# A do-nothing script encodes a manual procedure as a sequence of step
# functions. Each function prints instructions and waits for the operator to
# act. Replace a function body with real automation whenever you're ready —
# the rest of the script stays unchanged.
#
# Reference: https://blog.danslimmon.com/2019/07/15/do-nothing-scripting-the-key-to-gradual-automation/
#
# Usage: ./<script_name>.sh
# ------------------------------------------------------------------------------

set -euo pipefail

# ------------------------------------------------------------------------------
# Context — values collected once and used across steps
# ------------------------------------------------------------------------------
CONTEXT_example_var=""

# ------------------------------------------------------------------------------
# Utilities
# ------------------------------------------------------------------------------

wait_for_enter() {
  read -rp "    ↩  Press Enter when done... " _
  echo
}

collect_context() {
  echo "==> Collecting context"
  read -rp "    example_var: " CONTEXT_example_var
  echo
}

# ------------------------------------------------------------------------------
# Steps — replace any function body with real automation when ready
# ------------------------------------------------------------------------------

step_1_example_step() {  # TODO: automate
  echo "==> Step 1: Example step"
  echo "    Run:"
  echo "        example-command --flag value"
  wait_for_enter
}

step_2_another_step() {
  echo "==> Step 2: Another step"
  echo "    Open https://example.com"
  echo "    Find the record for: ${CONTEXT_example_var}"
  echo "    Copy the ID shown and paste it below."
  read -rp "    ID: " CONTEXT_retrieved_id
  echo
}

step_3_final_step() {
  echo "==> Step 3: Final step"
  echo "    Run:"
  printf "        some-command --id %s\n" "${CONTEXT_retrieved_id}"
  wait_for_enter
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

main() {
  echo
  echo "╔══════════════════════════════════════════════════════════╗"
  echo "║  Do-Nothing Procedure: <Procedure Name>                  ║"
  echo "╚══════════════════════════════════════════════════════════╝"
  echo

  collect_context

  step_1_example_step
  step_2_another_step
  step_3_final_step

  echo "✓ Done."
}

main "$@"
