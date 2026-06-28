#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

UV_BIN="${UV_BIN:-}"
if [[ -z "$UV_BIN" ]]; then
  if command -v uv >/dev/null 2>&1; then
    UV_BIN="$(command -v uv)"
  elif [[ -x "$HOME/.local/bin/uv" ]]; then
    UV_BIN="$HOME/.local/bin/uv"
  else
    echo "uv не найден. Установите uv: https://docs.astral.sh/uv/getting-started/installation/" >&2
    echo "Например: curl -LsSf https://astral.sh/uv/install.sh | sh" >&2
    exit 1
  fi
fi

echo "[1/4] repo: $ROOT"
echo "[2/4] uv: $UV_BIN"

mkdir -p .pi/venvs .pi/downloads/papers .pi/bin

echo "[3/4] creating/updating paper-search-mcp git venv"
"$UV_BIN" venv .pi/venvs/paper-search-mcp-git >/dev/null
"$UV_BIN" pip install --python .pi/venvs/paper-search-mcp-git/bin/python \
  'git+https://github.com/openags/paper-search-mcp.git'

echo "[4/4] writing local .mcp.json"
python3 - <<PY
import json, os
root = os.path.abspath('$ROOT')
config = {
  'mcpServers': {
    'wiley-scholar-gateway': {
      'type': 'http',
      'url': 'https://connector.scholargateway.ai/mcp'
    },
    'papersflow': {
      'transport': 'http',
      'url': 'https://doxa.papersflow.ai/mcp'
    },
    'paper-search-scihub': {
      'command': os.path.join(root, '.pi/venvs/paper-search-mcp-git/bin/python'),
      'args': ['-m', 'paper_search_mcp.server'],
      'env': {
        'PAPER_SEARCH_MCP_UNPAYWALL_EMAIL': os.environ.get('PAPER_SEARCH_MCP_UNPAYWALL_EMAIL', ''),
        'PAPER_SEARCH_MCP_CORE_API_KEY': os.environ.get('PAPER_SEARCH_MCP_CORE_API_KEY', ''),
        'PAPER_SEARCH_MCP_SEMANTIC_SCHOLAR_API_KEY': os.environ.get('PAPER_SEARCH_MCP_SEMANTIC_SCHOLAR_API_KEY', ''),
        'PAPER_SEARCH_MCP_ZENODO_ACCESS_TOKEN': os.environ.get('PAPER_SEARCH_MCP_ZENODO_ACCESS_TOKEN', ''),
        'PAPER_SEARCH_MCP_GOOGLE_SCHOLAR_PROXY_URL': os.environ.get('PAPER_SEARCH_MCP_GOOGLE_SCHOLAR_PROXY_URL', '')
      }
    }
  }
}
with open('.mcp.json', 'w', encoding='utf-8') as f:
    json.dump(config, f, indent=2, ensure_ascii=False)
    f.write('\n')
print('.mcp.json written')
PY

echo
echo "Готово. Проверка:"
echo "  bash scripts/test_mcp.sh"
echo
echo "После setup перезапустите Pi/agent, чтобы он перечитал .mcp.json."
