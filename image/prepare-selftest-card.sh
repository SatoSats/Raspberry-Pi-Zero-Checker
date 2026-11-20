#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
DOWNLOAD_DIR="$SCRIPT_DIR/downloads"
IMAGE="$DOWNLOAD_DIR/2026-10-06-raspios-trixie-armhf-lite.img.xz"
IMAGER="$DOWNLOAD_DIR/Raspberry_Pi_Imager-v2.0.12-cli-x86_64.AppImage"
IMAGE_SHA256='2c302771f34c67a0b7ae7aa2e0dcdd3eac660504be59193c011ba79d412e1632'
IMAGER_SHA256='8a2fa9c0fe6c61f57d5826a7419131b18f33226c681c740ebc30a713928d05e3'

fail() { printf 'Errore: %s\n' "$1" >&2; exit 1; }

command -v sha256sum >/dev/null || fail 'sha256sum non disponibile.'
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
[[ -r "$ROOT_DIR/scripts/pi-zero-checker" ]] || fail 'script di controllo mancante.'
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

TEMP_DIR="$(mktemp -d)"
chmod 700 "$TEMP_DIR"
trap 'rm -rf -- "$TEMP_DIR"' EXIT
USER_DATA="$TEMP_DIR/user-data"
{
  cat <<'EOF'
#cloud-config
hostname: rpizero-checker
rpi:
  enable_usb_gadget: true
write_files:
  - path: /usr/local/sbin/pi-zero-checker
    owner: root:root
    permissions: '0755'
    content: |
EOF
  sed 's/^/      /' "$ROOT_DIR/scripts/pi-zero-checker"
  cat <<'EOF'
  - path: /usr/local/sbin/pi-zero-checker-report
    owner: root:root
    permissions: '0755'
    content: |
      #!/usr/bin/env bash
      set -u
      REPORT=/boot/firmware/RPZC-REPORT.txt
      {
        printf 'Rapporto automatico Raspberry Pi Zero Checker\n'
        printf 'Creato: %s\n\n' "$(date -Is)"
        printf 'Il rapporto verifica il software locale; non certifica l’autenticità della scheda.\n\n'
        printf 'Il controllo SSH verifica solo il servizio locale, non il login remoto.\n'
        printf 'La rete USB va verificata separatamente dal computer host.\n\n'
        /usr/local/sbin/pi-zero-checker
        result=$?
        printf '\nExit code: %s\n' "$result"
      } > "$REPORT" 2>&1
      sync
      exit 0
  - path: /etc/systemd/system/pi-zero-checker-report.service
    owner: root:root
    permissions: '0644'
    content: |
      [Unit]
      Description=Run Pi Zero Checker and save report to the boot partition
      After=local-fs.target NetworkManager.service
      Wants=NetworkManager.service
      RequiresMountsFor=/boot/firmware

      [Service]
      Type=oneshot
      ExecStart=/usr/local/sbin/pi-zero-checker-report

      [Install]
      WantedBy=multi-user.target
runcmd:
  - [systemctl, daemon-reload]
  - [systemctl, enable, --now, ssh]
  - [systemctl, enable, --now, pi-zero-checker-report.service]
EOF
} > "$USER_DATA"
chmod 600 "$USER_DATA"

printf '\nLa scheda eseguirà il controllo da sola al primo avvio e salverà RPZC-REPORT.txt nella partizione bootfs.\n'
printf 'Può chiedere la password amministrativa del computer per scrivere sulla microSD.\n\n'
sudo "$IMAGER" --appimage-extract-and-run --cloudinit-userdata "$USER_DATA" "$IMAGE" "$DEVICE"

printf '\nScrittura completata. Espelli la microSD e inseriscila nel Pi Zero V1.3.\n'
printf 'Alimenta il Pi, attendi due minuti, poi spegnilo e leggi RPZC-REPORT.txt dalla partizione bootfs.\n'
