#!/usr/bin/env bash
set -Eeuo pipefail

# VS Code environment bootstrapper
# Usage:
#   ./setup.sh [--workspace /path/to/project]
#   MCP_TARGET_WORKSPACE=/path/to/project ./setup.sh

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
EXTENSIONS_FILE="$SCRIPT_DIR/vscode-extensions.txt"
SETTINGS_FILE="$SCRIPT_DIR/settings.json"
MCP_FILE="$SCRIPT_DIR/mcp.json"
WORKSPACE="${MCP_TARGET_WORKSPACE:-}"

usage() {
  cat <<'USAGE'
Usage: ./setup.sh [--workspace /path/to/project]

Options:
  --workspace PATH   Copy mcp.json to PATH/.vscode/mcp.json
  -h, --help         Show this help message

Environment:
  MCP_TARGET_WORKSPACE  Alternative to --workspace
USAGE
}

while (($#)); do
  case "$1" in
    --workspace)
      if [[ $# -lt 2 || -z "$2" ]]; then
        echo "Error: --workspace requires a path." >&2
        exit 2
      fi
      WORKSPACE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

for file in "$EXTENSIONS_FILE" "$SETTINGS_FILE"; do
  if [[ ! -f "$file" ]]; then
    echo "Error: required file not found: $file" >&2
    exit 1
  fi
done

if ! command -v code >/dev/null 2>&1; then
  echo "Error: VS Code command 'code' was not found in PATH." >&2
  echo "Open VS Code, run 'Shell Command: Install 'code' command in PATH' from the Command Palette, then rerun this script." >&2
  exit 1
fi

case "$(uname -s)" in
  Darwin)
    USER_SETTINGS_DIR="$HOME/Library/Application Support/Code/User"
    ;;
  Linux)
    USER_SETTINGS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/Code/User"
    ;;
  *)
    echo "Error: this script supports macOS and Linux. For Windows, use the VS Code Command Palette to import settings." >&2
    exit 1
    ;;
esac

mkdir -p "$USER_SETTINGS_DIR"

# Back up existing settings before replacing them.
if [[ -f "$USER_SETTINGS_DIR/settings.json" ]]; then
  BACKUP="$USER_SETTINGS_DIR/settings.json.backup.$(date +%Y%m%d-%H%M%S)"
  cp "$USER_SETTINGS_DIR/settings.json" "$BACKUP"
  echo "Backed up existing settings to: $BACKUP"
fi
cp "$SETTINGS_FILE" "$USER_SETTINGS_DIR/settings.json"
echo "Imported VS Code settings."

# Install extensions, ignoring blank lines and comments.
echo "Installing VS Code extensions..."
while IFS= read -r extension || [[ -n "$extension" ]]; do
  extension="${extension%%#*}"
  extension="$(printf '%s' "$extension" | xargs)"
  [[ -z "$extension" ]] && continue

  echo "  -> $extension"
  if ! code --install-extension "$extension"; then
    echo "Warning: failed to install extension: $extension" >&2
  fi
done < "$EXTENSIONS_FILE"

# MCP configuration is workspace-scoped in this setup.
if [[ -n "$WORKSPACE" ]]; then
  if [[ ! -d "$WORKSPACE" ]]; then
    echo "Error: workspace directory does not exist: $WORKSPACE" >&2
    exit 1
  fi
  if [[ ! -f "$MCP_FILE" ]]; then
    echo "Warning: mcp.json not found; skipping MCP configuration." >&2
  else
    MCP_DIR="$WORKSPACE/.vscode"
    mkdir -p "$MCP_DIR"
    if [[ -f "$MCP_DIR/mcp.json" ]]; then
      MCP_BACKUP="$MCP_DIR/mcp.json.backup.$(date +%Y%m%d-%H%M%S)"
      cp "$MCP_DIR/mcp.json" "$MCP_BACKUP"
      echo "Backed up existing MCP config to: $MCP_BACKUP"
    fi
    cp "$MCP_FILE" "$MCP_DIR/mcp.json"
    echo "Imported MCP configuration to: $MCP_DIR/mcp.json"
  fi
else
  echo "Skipped MCP configuration. To import it, rerun with:"
  echo "  ./setup.sh --workspace /path/to/your/project"
fi

echo
echo "VS Code setup completed. Restart or reload VS Code if needed."
