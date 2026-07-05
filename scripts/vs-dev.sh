#!/bin/sh

set -e

PROJECT_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

if [ ! -d "network" ]; then
    echo "Network folder missing. Exiting."
    exit 1
fi

if [ ! -d "Packages" ]; then
    echo "Packages folder missing. Exiting."
    exit 1
fi

rojo serve default.project.json \
    & rojo sourcemap default.project.json -o sourcemap.json --watch \
