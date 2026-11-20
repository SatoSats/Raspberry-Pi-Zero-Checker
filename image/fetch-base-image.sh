#!/usr/bin/env bash
set -euo pipefail

URL='https://downloads.raspberrypi.com/raspios_lite_armhf/images/raspios_lite_armhf-2026-10-06/2026-10-06-raspios-trixie-armhf-lite.img.xz'
SHA256='2c302771f34c67a0b7ae7aa2e0dcdd3eac660504be59193c011ba79d412e1632'
OUT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/downloads"
OUT_FILE="$OUT_DIR/2026-10-06-raspios-trixie-armhf-lite.img.xz"
mkdir -p "$OUT_DIR"

if [[ -e "$OUT_FILE" ]]; then
  echo "File già presente: $OUT_FILE" >&2
  echo 'Spostalo o rimuovilo manualmente per ripetere il download.' >&2
  exit 2
fi

trap 'rm -f "$OUT_FILE.part"' EXIT
curl --fail --location --retry 3 --output "$OUT_FILE.part" "$URL"
printf '%s  %s\n' "$SHA256" "$OUT_FILE.part" | sha256sum --check --status || {
  echo 'Checksum non valido: download rifiutato.' >&2
  exit 1
}
mv "$OUT_FILE.part" "$OUT_FILE"
trap - EXIT
printf '%s  %s\n' "$SHA256" "$(basename "$OUT_FILE")" > "$OUT_DIR/SHA256SUMS"
echo "Immagine ufficiale verificata: $OUT_FILE"
echo 'Lo script non scrive su schede SD.'
