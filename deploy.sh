#!/bin/bash
# Deploy themodellab.pl z repozytorium GitHub.
# Uruchamiane przez zadanie CRON (program: BASH, katalog roboczy: ~/themodellab.pl)
set -u

SRC="https://raw.githubusercontent.com/damian-dealme/themodellab-site/main/index.html"
DIR="$HOME/themodellab.pl/public_html"
TMP="$DIR/.index.new"

mkdir -p "$DIR"

# 1. Sciagnij aktualna wersje strony z GitHuba
if wget -q -O "$TMP" "$SRC" && [ -s "$TMP" ]; then
  # podmieniaj tylko gdy plik faktycznie sie zmienil
  if ! cmp -s "$TMP" "$DIR/index.html"; then
    mv -f "$TMP" "$DIR/index.html"
    echo "$(date '+%Y-%m-%d %H:%M') zaktualizowano index.html" >> "$HOME/themodellab.pl/deploy.log"
  else
    rm -f "$TMP"
  fi
else
  rm -f "$TMP"
  echo "$(date '+%Y-%m-%d %H:%M') BLAD pobierania z GitHuba" >> "$HOME/themodellab.pl/deploy.log"
fi

# 2. Posprzataj duplikaty (index.html.1, index.html.2, ...) z poprzednich pobran
rm -f "$DIR"/index.html.[0-9]* "$DIR"/.htaccess.[0-9]* 2>/dev/null

# 3. Trzymaj log w rozsadnym rozmiarze
LOG="$HOME/themodellab.pl/deploy.log"
if [ -f "$LOG" ]; then tail -n 200 "$LOG" > "$LOG.tmp" && mv -f "$LOG.tmp" "$LOG"; fi
