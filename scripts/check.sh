#!/bin/sh

set -e

PROJECT_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

find scripts -type f -name "*.sh" -exec sh -n {} \;
sh scripts/generate-network.sh
sh scripts/install-packages.sh
stylua --check src
selene src
rojo build default.project.json --output "/tmp/$(basename "$PROJECT_ROOT").rbxlx"
