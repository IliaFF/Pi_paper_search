#!/usr/bin/env bash
set -euo pipefail

BIN="$HOME/.pi/agent/npm/node_modules/.bin/hypa"
TARGET_DIR="$HOME/.local/bin"
TARGET="$TARGET_DIR/hypa"

if [[ ! -x "$BIN" ]]; then
  echo "hypa не найден в $BIN" >&2
  echo "Сначала установите Pi package:" >&2
  echo "  pi install npm:@hypabolic/pi-hypa" >&2
  echo "или запустите pi в проекте, чтобы он подтянул .pi/settings.json" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"
ln -sf "$BIN" "$TARGET"
echo "OK: hypa -> $TARGET"
"$TARGET" --version || true

case ":$PATH:" in
  *":$TARGET_DIR:"*) ;;
  *)
    echo
    echo "Внимание: $TARGET_DIR не в PATH текущего shell. Добавьте в ~/.bashrc:"
    echo "  export PATH=\"$TARGET_DIR:\$PATH\""
    ;;
esac
