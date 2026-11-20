# Raspberry Pi Zero Checker

Procedura in italiano per controllare visivamente e tramite software un Raspberry Pi Zero V1.3 con Raspberry Pi OS Trixie a 32 bit (`armhf`).

## Che cosa significa il risultato

Il test di riconoscimento è superato quando il sistema riporta Raspberry Pi Zero Rev 1.3, revisione `900093` oppure `920093`, e Raspberry Pi OS Trixie 32 bit (`armhf`). Il controllo conferma che il software identifica questi dati compatibili con il modello previsto.

Non certifica l’autenticità fisica della scheda: revisione e device-tree sono dati software falsificabili. La verifica visiva aiuta a individuare differenze e anomalie, ma da sola non dimostra l’autenticità.

SSH non è un requisito. USB Gadget e la connessione di rete tra Pi e computer sono controlli facoltativi separati.

## Procedura consigliata: ispezione e rapporto automatico

1. Segui la [guida visiva illustrata](docs/guida-italiana.pdf) e confronta entrambi i lati della scheda con le fotografie originali incluse.
2. Prepara una microSD con Raspberry Pi OS Trixie Lite 32 bit e il rapporto automatico:

   ```bash
   bash image/prepare-selftest-card.sh
   ```

3. Seleziona con attenzione il disco della microSD. La scrittura cancella tutto il suo contenuto; lo script mostra i dischi e chiede una conferma esplicita.
4. Inserisci la microSD nel Pi, alimentalo e attendi circa due minuti. Il servizio abilitato all’avvio salva `RPZC-REPORT.txt` nella partizione di avvio (`bootfs`).
5. Spegni il Pi, rimetti la microSD nel computer e apri `RPZC-REPORT.txt` nella partizione `bootfs`.
6. Leggi la voce **Esito test di riconoscimento**. SSH e `usb0` non cambiano questo esito.

La procedura dettagliata, inclusi l’orientamento delle porte e l’interpretazione del rapporto, è in [CONTROLLO_COMPLETO.md](docs/CONTROLLO_COMPLETO.md).

## Controlli USB facoltativi

USB Gadget può essere controllato separatamente collegando un cavo dati alla porta `USB` accanto alla mini-HDMI. Per verificare anche il collegamento dal computer host, consulta il percorso USB/SSH descritto nella guida illustrata. SSH serve solo a quel percorso facoltativo e non è necessario per generare o leggere il rapporto.

Il programma segnala se `usb0` è presente sul Raspberry, ma non verifica DHCP o la rete del computer host.

## Immagine e file

- `image/prepare-selftest-card.sh` prepara la microSD e abilita il rapporto automatico al boot.
- `scripts/pi-zero-checker` esegue il controllo di riconoscimento.
- `docs/guida-italiana.pdf` è la guida illustrata fornita dall’utente, conservata invariata.
- `image/SOURCE.md` e `image/SHA256SUMS` documentano l’immagine di base fissata.

Lo script scarica e verifica l’immagine originale con SHA-256 prima di scrivere la microSD. Non condividere immagini di sistema che contengano password personali.

## Riferimenti

- [Download Raspberry Pi OS](https://www.raspberrypi.com/software/operating-systems/)
- [Codici di revisione Raspberry Pi](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#raspberry-pi-revision-codes)
- [USB Gadget e SSH over USB](https://www.raspberrypi.com/news/usb-gadget-mode-in-raspberry-pi-os-ssh-over-usb/)
- [Pacchetto ufficiale rpi-usb-gadget](https://github.com/raspberrypi/rpi-usb-gadget/tree/pios/trixie)
