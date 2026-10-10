#!/usr/bin/env bash
# Installs Tamarin 1.10.0 and Maude 3.5 inside WSL (Ubuntu) on Windows 11.
# Run inside the Ubuntu terminal:  bash install_tamarin_wsl.sh
set -euo pipefail

TAMARIN_URL="https://github.com/tamarin-prover/tamarin-prover/releases/download/1.10.0/tamarin-prover-1.10.0-linux64-ubuntu.tar.gz"
MAUDE_URL="https://github.com/maude-lang/Maude/releases/download/Maude3.5/Maude-3.5-linux-x86_64.zip"
DEST="$HOME/tamarin"

sudo apt-get update -y
sudo apt-get install -y curl unzip graphviz

mkdir -p "$DEST/maude"
cd "$DEST"
curl -fsSL -o tamarin.tgz "$TAMARIN_URL"
tar xzf tamarin.tgz && rm tamarin.tgz
curl -fsSL -o maude.zip "$MAUDE_URL"
unzip -o -q maude.zip -d maude && rm maude.zip
chmod +x tamarin-prover maude/maude

# Put both on the PATH and use a UTF-8 locale (Tamarin crashes on output otherwise).
if ! grep -q 'tamarin/maude' "$HOME/.bashrc"; then
  {
    echo 'export PATH="$HOME/tamarin:$HOME/tamarin/maude:$PATH"'
    echo 'export LANG=C.UTF-8 LC_ALL=C.UTF-8'
  } >> "$HOME/.bashrc"
fi
export PATH="$DEST:$DEST/maude:$PATH" LANG=C.UTF-8 LC_ALL=C.UTF-8

maude --version
tamarin-prover test | tail -3
echo "Done. Open a new Ubuntu terminal (or run: source ~/.bashrc)."
