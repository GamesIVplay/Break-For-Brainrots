#!/bin/sh

set -e

PROJECT_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

if ! command -v rokit >/dev/null 2>&1; then
    echo "Installing Rokit..."

    case "$(uname -s)" in
        Linux|Darwin)
            curl -sSf https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | sh
            ;;
        *)
            echo "Rokit is not installed."
            echo "Install it from https://github.com/rojo-rbx/rokit, then rerun this script."
            exit 1
            ;;
    esac

    if [ -d "$HOME/.rokit/bin" ]; then
        PATH="$HOME/.rokit/bin:$PATH"
        export PATH
    fi
fi

echo "Installing Rokit tools..."
rokit install --no-trust-check

echo "Generating network..."
sh scripts/generate-network.sh

echo "Installing packages..."
sh scripts/install-packages.sh

echo "Setup complete."
