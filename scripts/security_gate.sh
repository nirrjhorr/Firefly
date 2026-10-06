#!/bin/bash
# Firefly Security Gate Shell Wrapper (PRD Section 7.4)
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
python3 "$DIR/security_gate.py"
