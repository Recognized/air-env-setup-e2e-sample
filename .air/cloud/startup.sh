#!/usr/bin/env bash
# Fixture for jcp-air-project-setup-mcp's live integration test
# `companion checks out the pushed setup branch and runs the default startup script`.
#
# The marker below exists only on this branch, never on the base ref, so finding it in the
# companion's startup log proves the bootstrap's best-effort checkout of the run's setup branch
# actually took effect. Keep the script trivial and exit 0: the test's completion gate reads the
# exit code the launch wrapper records.
set -euo pipefail

echo "setup-branch-checkout-ok-7c3f0a1c"
