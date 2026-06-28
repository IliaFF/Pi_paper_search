# Academic Search Agent / Literature Review MCP Setup

Готовая сборка проекта для академического поиска, литобзора и критического анализа литературы в Pi/agent harness.

## Что входит

- `agent.md` — инструкции агента для академического поиска, литобзора и рецензирования.
- `.mcp.json.example` — шаблон MCP-конфигурации.
- `scripts/setup.sh` — автоматическая установка локального MCP `paper-search-scihub`.
- `scripts/test_mcp.sh` — проверка, что MCP-сервер запускается и отдает нужные tools.
- `scripts/build_review_pdf.sh` — сборка PDF-рецензии через XeLaTeX.
- `review_ls_cp_flcb_theory_latex.tex` / `.pdf` — пример жесткой рецензии с нормальными LaTeX-формулами.

## MCP-серверы

После установки будут настроены:

1. `paper-search-scihub` — локальный `paper-search-mcp` из git-версии.  
   Основные инструменты:
   - `search_papers`
   - `download_with_fallback`
   - `download_scihub`
   - `search_arxiv`
   - `search_pubmed`
   - `search_crossref`
   - `search_openalex`
   - `search_pmc`
   - `search_europepmc`
   - `search_unpaywall`
   - `search_zenodo`
   - `search_hal`

2. `wiley-scholar-gateway` — HTTP MCP, требует OAuth при первом подключении.
3. `papersflow` — HTTP MCP, требует OAuth/авторизацию при первом подключении.

Anna's Archive намеренно не включен.

## Требования

- Linux/WSL/macOS shell.
- Python 3.
- [`uv`](https://docs.astral.sh/uv/getting-started/installation/).
- Для PDF: XeLaTeX. На Windows можно использовать MiKTeX.

Установка `uv`, если его нет:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

## Быстрый старт

```bash
git clone <REPO_URL>
cd search_agent
bash scripts/setup.sh
bash scripts/test_mcp.sh
```

После `setup.sh` в корне будет создан локальный `.mcp.json` с абсолютным путем к виртуальному окружению текущего пользователя.

Затем перезапустите Pi/agent, чтобы он перечитал `.mcp.json`.

## Опциональные ключи

Секреты не хранятся в репозитории. Их можно передать через переменные окружения перед `setup.sh`:

```bash
export PAPER_SEARCH_MCP_UNPAYWALL_EMAIL="you@example.com"
export PAPER_SEARCH_MCP_CORE_API_KEY="..."
export PAPER_SEARCH_MCP_SEMANTIC_SCHOLAR_API_KEY="..."
bash scripts/setup.sh
```

Без ключей большая часть поиска все равно работает; Unpaywall лучше настроить через email.

## Проверка MCP вручную

```bash
bash scripts/test_mcp.sh
```

Ожидаемый результат: сообщение вида

```text
OK: paper-search-mcp запущен, tools=57
```

Число tools может измениться, если upstream `paper-search-mcp` обновится.

## Сборка PDF-рецензии

Если `xelatex` есть в PATH:

```bash
bash scripts/build_review_pdf.sh
```

Если MiKTeX установлен в нестандартном месте:

```bash
XELATEX="/mnt/d/Miktex/miktex/bin/x64/xelatex.exe" bash scripts/build_review_pdf.sh
```

## Безопасность и воспроизводимость

- `.mcp.json` игнорируется git, потому что содержит локальные абсолютные пути и может содержать ключи.
- `.pi/venvs`, `.pi/agent-profile`, `.pi/portia`, логи и кэши не коммитятся.
- В репозитории хранится только воспроизводимая конфигурация: шаблон, инструкции и setup-скрипты.

## Что делать новому пользователю

1. Клонировать репозиторий.
2. Запустить `bash scripts/setup.sh`.
3. Запустить `bash scripts/test_mcp.sh`.
4. Перезапустить Pi/agent.
5. При первом использовании Wiley/PapersFlow пройти OAuth.

## Перенос на VPS / чистый Pi

Подробная инструкция для чистого VPS: [`VPS_SETUP.md`](VPS_SETUP.md).
