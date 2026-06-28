#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

XELATEX="${XELATEX:-}"
if [[ -z "$XELATEX" ]]; then
  if command -v xelatex >/dev/null 2>&1; then
    XELATEX="$(command -v xelatex)"
  elif [[ -x "/mnt/d/Miktex/miktex/bin/x64/xelatex.exe" ]]; then
    XELATEX="/mnt/d/Miktex/miktex/bin/x64/xelatex.exe"
  else
    echo "xelatex не найден. Укажите путь: XELATEX=/path/to/xelatex bash scripts/build_review_pdf.sh" >&2
    exit 1
  fi
fi

TEX="review_ls_cp_flcb_theory_latex.tex"
[[ -f "$TEX" ]] || { echo "Не найден $TEX" >&2; exit 1; }
"$XELATEX" -interaction=nonstopmode -halt-on-error "$TEX"
"$XELATEX" -interaction=nonstopmode -halt-on-error "$TEX"
echo "Готово: review_ls_cp_flcb_theory_latex.pdf"
