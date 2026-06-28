# VPS setup: перенос Pi academic search проекта на чистый сервер

Инструкция рассчитана на чистый Ubuntu/Debian VPS. Для других Linux-дистрибутивов команды установки системных пакетов нужно адаптировать.

## 1. Системные зависимости

```bash
sudo apt update
sudo apt install -y git curl ca-certificates python3 python3-venv python3-pip build-essential nodejs npm openssh-client
```

Проверка:

```bash
git --version
node --version
npm --version
python3 --version
```

## 2. Установить Pi CLI

```bash
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
```

Проверка:

```bash
pi --version
```

## 3. Авторизация Pi

Запустить Pi один раз и выполнить `/login`:

```bash
pi
```

Внутри Pi:

```text
/login
```

Выбрать нужного провайдера: Codex/OpenAI, Claude, GitHub Copilot или API-key provider.

Альтернатива через env-переменные, если используете API:

```bash
export ANTHROPIC_API_KEY="..."
# или другой ключ согласно вашему провайдеру
```

## 4. Клонировать проект

```bash
cd ~
git clone https://github.com/IliaFF/Pi_paper_search.git
cd Pi_paper_search
```

## 5. Установить Pi-пакеты/расширения

В репозитории есть `.pi/settings.json`. После доверия к проекту Pi должен подтянуть пакеты автоматически. Чтобы поставить явно:

```bash
pi install -l npm:pi-subagents
pi install -l npm:pi-mcp-adapter
pi install -l npm:context-mode
pi install -l npm:@ff-labs/pi-fff
pi install -l npm:@hypabolic/pi-hypa
pi install -l npm:pi-web-access
pi install -l npm:@narumitw/pi-codex-usage
```

Что это дает:

- `pi-mcp-adapter` — MCP-инструменты внутри Pi;
- `pi-web-access` — web search/fetch для исследований;
- `context-mode` — обработка больших выводов/логов без засорения контекста;
- `pi-subagents` — делегирование задач субагентам;
- `@ff-labs/pi-fff` — быстрый поиск по файлам/контенту;
- `@hypabolic/pi-hypa` — сжатое чтение больших файлов/выводов;
- `@narumitw/pi-codex-usage` — учет использования Codex.

## 6. Установить локальный academic MCP

```bash
bash scripts/setup.sh
```

Скрипт создаст:

- `.pi/venvs/paper-search-mcp-git/` — виртуальное окружение Python;
- `.mcp.json` — локальную MCP-конфигурацию с абсолютными путями текущего VPS;
- `.pi/downloads/papers/` — папку для скачанных PDF.

## 7. Проверить MCP

```bash
bash scripts/test_mcp.sh
```

Ожидаемый результат:

```text
OK: paper-search-mcp запущен, tools=57
Key tools: download_scihub, download_with_fallback, search_arxiv, search_papers, search_unpaywall
```

Число tools может немного измениться, если upstream `paper-search-mcp` обновится.

## 8. Опциональные ключи для академических источников

Перед `bash scripts/setup.sh` можно задать:

```bash
export PAPER_SEARCH_MCP_UNPAYWALL_EMAIL="you@example.com"
export PAPER_SEARCH_MCP_CORE_API_KEY="..."
export PAPER_SEARCH_MCP_SEMANTIC_SCHOLAR_API_KEY="..."
export PAPER_SEARCH_MCP_ZENODO_ACCESS_TOKEN="..."
export PAPER_SEARCH_MCP_GOOGLE_SCHOLAR_PROXY_URL="http://user:pass@host:port"
```

Минимально желательно задать `PAPER_SEARCH_MCP_UNPAYWALL_EMAIL`, чтобы Unpaywall работал корректно.

Секреты не коммитить. `.mcp.json` уже в `.gitignore`.

## 9. Запуск Pi в проекте

```bash
cd ~/Pi_paper_search
pi
```

Pi автоматически прочитает `AGENTS.md`, а там указано использовать `agent.md` как основную инструкцию академического агента.

После первого запуска можно проверить MCP внутри Pi:

```text
Покажи доступные MCP серверы
```

Ожидаемо должны быть:

- `paper-search-scihub` — локальный академический поиск;
- `wiley-scholar-gateway` — потребует OAuth;
- `papersflow` — потребует OAuth.

## 10. Wiley и PapersFlow OAuth

При первом подключении эти серверы могут ответить `Unauthorized` или `Re-authentication required`. Тогда нужно запустить OAuth через MCP auth flow, открыть ссылку в браузере, скопировать redirect URL/code и завершить авторизацию.

Если VPS без браузера: откройте ссылку авторизации на локальной машине, а в Pi вставьте полный redirect URL или `code`.

## 11. Сборка PDF-рецензии на VPS

Если нужен PDF с LaTeX-формулами:

```bash
sudo apt install -y texlive-xetex texlive-lang-cyrillic texlive-latex-extra
bash scripts/build_review_pdf.sh
```

На Windows/WSL с MiKTeX:

```bash
XELATEX="/mnt/d/Miktex/miktex/bin/x64/xelatex.exe" bash scripts/build_review_pdf.sh
```

## 12. Быстрый smoke test после переноса

```bash
cd ~/Pi_paper_search
git pull
bash scripts/setup.sh
bash scripts/test_mcp.sh
pi -p "Прочитай AGENTS.md и README.md, затем скажи, какие MCP-инструменты должны быть доступны"
```

Если `scripts/test_mcp.sh` проходит, локальная часть academic search MCP установлена правильно.

## 13. Частые проблемы

### `uv не найден`

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc
bash scripts/setup.sh
```

### Pi не видит новый MCP

Перезапустите Pi после `setup.sh`. MCP-конфиг читается при старте сессии.

### `paper-search-scihub` не подключается

Проверьте:

```bash
bash scripts/test_mcp.sh
cat .mcp.json
```

В `.mcp.json` путь `command` должен быть абсолютным и указывать на существующий Python внутри `.pi/venvs/paper-search-mcp-git/bin/python`.

### Нет OAuth для Wiley/PapersFlow

Это нормально. Эти серверы требуют авторизации отдельно от локального MCP.
