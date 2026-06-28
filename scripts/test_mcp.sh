#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
PY=".pi/venvs/paper-search-mcp-git/bin/python"
if [[ ! -x "$PY" ]]; then
  echo "Виртуальное окружение не найдено. Сначала выполните: bash scripts/setup.sh" >&2
  exit 1
fi
"$PY" - <<'PY'
import anyio
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

async def main():
    params = StdioServerParameters(
        command='.pi/venvs/paper-search-mcp-git/bin/python',
        args=['-m', 'paper_search_mcp.server'],
        cwd='.'
    )
    async with stdio_client(params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()
            tools = await session.list_tools()
            names = [t.name for t in tools.tools]
            print(f'OK: paper-search-mcp запущен, tools={len(names)}')
            required = {'search_papers', 'download_with_fallback', 'download_scihub', 'search_arxiv', 'search_unpaywall'}
            missing = sorted(required - set(names))
            if missing:
                raise SystemExit('Missing required tools: ' + ', '.join(missing))
            print('Key tools:', ', '.join(sorted(required)))

anyio.run(main)
PY
