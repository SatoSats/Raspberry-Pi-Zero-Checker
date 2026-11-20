#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DOWNLOAD_DIR="$SCRIPT_DIR/downloads"
IMAGE="$DOWNLOAD_DIR/2026-10-06-raspios-trixie-armhf-lite.img.xz"
IMAGER="$DOWNLOAD_DIR/Raspberry_Pi_Imager-v2.0.12-cli-x86_64.AppImage"
IMAGE_SHA256='2c302771f34c67a0b7ae7aa2e0dcdd3eac660504be59193c011ba79d412e1632'
IMAGER_SHA256='8a2fa9c0fe6c61f57d5826a7419131b18f33226c681c740ebc30a713928d05e3'

fail() { printf 'Errore: %s\n' "$1" >&2; exit 1; }

command -v sha256sum >/dev/null || fail 'sha256sum non disponibile.'
command -v openssl >/dev/null || fail 'openssl non disponibile.'
command -v lsblk >/dev/null || fail 'lsblk non disponibile.'
command -v sudo >/dev/null || fail 'sudo non disponibile.'
command -v curl >/dev/null || fail 'curl non disponibile.'

mkdir -p "$DOWNLOAD_DIR"
if [[ ! -f "$IMAGE" ]]; then
  bash "$SCRIPT_DIR/fetch-base-image.sh"
fi
if [[ ! -f "$IMAGER" ]]; then
  curl --fail --location --retry 3 --output "$IMAGER" \
    'https://github.com/raspberrypi/rpi-imager/releases/download/v2.0.12/Raspberry_Pi_Imager-v2.0.12-cli-x86_64.AppImage'
  chmod 755 "$IMAGER"
fi

printf 'Verifico i file scaricati...\n'
printf '%s  %s\n' "$IMAGE_SHA256" "$IMAGE" | sha256sum --check --status || fail 'checksum dell’immagine non valido.'
printf '%s  %s\n' "$IMAGER_SHA256" "$IMAGER" | sha256sum --check --status || fail 'checksum di Raspberry Pi Imager non valido.'
printf 'Checksum verificati.\n\n'

printf 'Dischi rilevati:\n'
lsblk -e7 -o NAME,SIZE,MODEL,TRAN,RM,TYPE,MOUNTPOINTS
printf '\n'
read -r -p 'Dispositivo microSD da usare [/dev/mmcblk0]: ' DEVICE
DEVICE="${DEVICE:-/dev/mmcblk0}"
[[ "$DEVICE" == /dev/* && -b "$DEVICE" ]] || fail "non è un dispositivo disco valido: $DEVICE"
[[ "$(lsblk -dnro TYPE "$DEVICE")" == disk ]] || fail 'seleziona il disco intero, non una partizione.'

ROOT_SOURCE="$(findmnt -nro SOURCE / 2>/dev/null || true)"
if [[ -n "$ROOT_SOURCE" ]] && lsblk -s -nrpo NAME "$ROOT_SOURCE" 2>/dev/null | grep -Fxq "$DEVICE"; then
  fail 'il dispositivo selezionato contiene il sistema Linux in uso.'
fi

printf '\nDispositivo selezionato:\n'
lsblk -o NAME,SIZE,MODEL,TRAN,RM,TYPE,MOUNTPOINTS "$DEVICE"
printf '\nLa scrittura cancellerà tutto il contenuto del dispositivo selezionato.\n'
read -r -p "Per continuare digita SCRIVI $DEVICE: " CONFIRM
[[ "$CONFIRM" == "SCRIVI $DEVICE" ]] || fail 'scrittura annullata.'

read -r -p 'Nome utente sul Raspberry Pi [checker]: ' USERNAME
USERNAME="${USERNAME:-checker}"
[[ "$USERNAME" =~ ^[a-z_][a-z0-9_-]*[$]?$ ]] || fail 'nome utente non valido.'

while true; do
  IFS= read -r -s -p 'Crea una password SSH: ' PASSWORD_1; printf '\n'
  IFS= read -r -s -p 'Ripeti la password: ' PASSWORD_2; printf '\n'
  [[ -n "$PASSWORD_1" ]] || { printf 'La password non può essere vuota.\n'; continue; }
  [[ "$PASSWORD_1" == "$PASSWORD_2" ]] || { printf 'Le password non coincidono.\n'; unset PASSWORD_1 PASSWORD_2; continue; }
  break
done
PASSWORD_HASH="$(printf '%s' "$PASSWORD_1" | openssl passwd -6 -stdin)"
unset PASSWORD_1 PASSWORD_2

TEMP_DIR="$(mktemp -d)"
chmod 700 "$TEMP_DIR"
trap 'rm -rf -- "$TEMP_DIR"; unset PASSWORD_HASH' EXIT
USER_DATA="$TEMP_DIR/user-data"
cat > "$USER_DATA" <<EOF
#cloud-config
hostname: rpizero-checker
manage_etc_hosts: true
user:
  name: $USERNAME
  shell: /bin/bash
  lock_passwd: false
  passwd: '$PASSWORD_HASH'
  sudo: null
ssh_pwauth: true
rpi:
  enable_usb_gadget: true
runcmd:
  - [systemctl, enable, --now, ssh]
EOF
chmod 600 "$USER_DATA"

printf '\nRaspberry Pi Imager scriverà Trixie 32-bit e applicherà SSH + USB Gadget.\n'
printf 'Può chiedere la password amministrativa del computer per accedere alla microSD.\n\n'
sudo "$IMAGER" --appimage-extract-and-run --cloudinit-userdata "$USER_DATA" "$IMAGE" "$DEVICE"

printf '\nScrittura completata. Espelli la microSD in sicurezza e inseriscila nel Pi Zero V1.3.\n'
printf 'Usa la porta USB dati accanto alla mini-HDMI; attendi un minuto prima di collegarti.\n'
