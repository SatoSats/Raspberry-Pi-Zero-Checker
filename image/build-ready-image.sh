#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
DOWNLOAD_DIR="${RUNNER_TEMP:-/tmp}/rpzc-image-build"
DIST_DIR="$ROOT_DIR/dist"
IMAGE_XZ="$DOWNLOAD_DIR/2026-10-06-raspios-trixie-armhf-lite.img.xz"
IMAGE_SHA256='2c302771f34c67a0b7ae7aa2e0dcdd3eac660504be59193c011ba79d412e1632'
IMAGE_URL='https://downloads.raspberrypi.com/raspios_lite_armhf/images/raspios_lite_armhf-2026-10-06/2026-10-06-raspios-trixie-armhf-lite.img.xz'
RAW_IMAGE="$DOWNLOAD_DIR/raspios-trixie-armhf.img"
OUTPUT="$DIST_DIR/rpzc-trixie-armhf.img.xz"
LOOP_DEVICE=''
ROOT_MOUNT="$DOWNLOAD_DIR/root"

fail() { printf 'Errore: %s\n' "$1" >&2; exit 1; }
cleanup() {
  set +e
  mountpoint -q "$ROOT_MOUNT/boot/firmware" && sudo umount "$ROOT_MOUNT/boot/firmware"
  mountpoint -q "$ROOT_MOUNT" && sudo umount "$ROOT_MOUNT"
  [[ -z "$LOOP_DEVICE" ]] || sudo losetup -d "$LOOP_DEVICE"
}
trap cleanup EXIT

for command_name in curl sha256sum xz losetup mount mountpoint systemctl; do
  command -v "$command_name" >/dev/null || fail "comando mancante: $command_name"
done

mkdir -p "$DOWNLOAD_DIR" "$DIST_DIR" "$ROOT_MOUNT"
if [[ ! -f "$IMAGE_XZ" ]]; then
  curl --fail --location --retry 3 --output "$IMAGE_XZ" "$IMAGE_URL"
fi
printf '%s  %s\n' "$IMAGE_SHA256" "$IMAGE_XZ" | sha256sum --check --status || fail 'checksum dell’immagine ufficiale non valido.'

xz --decompress --stdout "$IMAGE_XZ" > "$RAW_IMAGE"
LOOP_DEVICE="$(sudo losetup --find --show --partscan "$RAW_IMAGE")"
sudo partprobe "$LOOP_DEVICE"
sudo udevadm settle
BOOT_PART="${LOOP_DEVICE}p1"
ROOT_PART="${LOOP_DEVICE}p2"
[[ -b "$BOOT_PART" && -b "$ROOT_PART" ]] || fail 'partizioni boot/root non trovate nell’immagine ufficiale.'

sudo mount "$ROOT_PART" "$ROOT_MOUNT"
sudo mkdir -p "$ROOT_MOUNT/boot/firmware"
sudo mount "$BOOT_PART" "$ROOT_MOUNT/boot/firmware"
sudo install -o root -g root -m 0755 "$ROOT_DIR/scripts/pi-zero-checker" "$ROOT_MOUNT/usr/local/sbin/pi-zero-checker"

sudo tee "$ROOT_MOUNT/usr/local/sbin/pi-zero-checker-report" >/dev/null <<'REPORT_SCRIPT'
#!/usr/bin/env bash
set -u
REPORT=/boot/firmware/RPZC-REPORT.txt
{
  printf 'Rapporto automatico Raspberry Pi Zero Checker\n'
  printf 'Creato: %s\n\n' "$(date -Is)"
  printf 'Il rapporto verifica dati software; non certifica l’autenticità fisica della scheda.\n'
  printf 'Revisione e device-tree sono dati software falsificabili.\n'
  printf 'SSH non è un requisito; USB Gadget e rete host sono controlli facoltativi separati.\n\n'
  /usr/local/sbin/pi-zero-checker
  result=$?
  printf '\nExit code: %s\n' "$result"
} > "$REPORT" 2>&1
sync
exit 0
REPORT_SCRIPT
sudo chown root:root "$ROOT_MOUNT/usr/local/sbin/pi-zero-checker-report"
sudo chmod 0755 "$ROOT_MOUNT/usr/local/sbin/pi-zero-checker-report"

sudo tee "$ROOT_MOUNT/etc/systemd/system/pi-zero-checker-report.service" >/dev/null <<'SERVICE_UNIT'
[Unit]
Description=Create Raspberry Pi Zero Checker report on the boot partition
After=local-fs.target
RequiresMountsFor=/boot/firmware

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/pi-zero-checker-report

[Install]
WantedBy=multi-user.target
SERVICE_UNIT
sudo chown root:root "$ROOT_MOUNT/etc/systemd/system/pi-zero-checker-report.service"
sudo chmod 0644 "$ROOT_MOUNT/etc/systemd/system/pi-zero-checker-report.service"
sudo systemctl --root="$ROOT_MOUNT" enable pi-zero-checker-report.service

sync
sudo umount "$ROOT_MOUNT/boot/firmware"
sudo umount "$ROOT_MOUNT"
sudo losetup -d "$LOOP_DEVICE"
LOOP_DEVICE=''

xz --threads=0 --compress --keep --force "$RAW_IMAGE"
mv "$RAW_IMAGE.xz" "$OUTPUT"
SIZE="$(stat -c '%s' "$OUTPUT")"
(( SIZE < 2147483648 )) || fail 'immagine compressa troppo grande per un singolo asset GitHub Release (limite: meno di 2 GiB).'
(cd "$DIST_DIR" && sha256sum "$(basename "$OUTPUT")" > SHA256SUMS)
xz --test "$OUTPUT"
(cd "$DIST_DIR" && sha256sum --check SHA256SUMS)
printf 'Immagine pronta: %s (%s byte)\n' "$OUTPUT" "$SIZE"
