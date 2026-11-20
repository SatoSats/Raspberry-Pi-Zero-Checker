#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo 'Avvia con sudo: sudo bash install.sh' >&2
  exit 1
fi
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CHECKER="$SCRIPT_DIR/pi-zero-checker"
if [[ ! -r "$CHECKER" ]]; then
  echo 'File pi-zero-checker non trovato accanto a install.sh.' >&2
  exit 1
fi
install -o root -g root -m 0755 "$CHECKER" /usr/local/bin/pi-zero-checker
if command -v rpi-usb-gadget >/dev/null 2>&1; then
  rpi-usb-gadget on
else
  echo 'Pacchetto rpi-usb-gadget assente. Installalo con sudo apt install rpi-usb-gadget.' >&2
  exit 2
fi
echo 'Installazione completata. Riavvia il Pi, poi esegui pi-zero-checker.'
