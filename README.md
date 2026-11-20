# Raspberry Pi Zero Checker

> Stato: il test SSH su Raspberry Pi Zero V1.3 del 20 novembre 2026 non ha completato DHCP. È stata preparata una modalità di autodiagnosi che salva un rapporto sulla microSD; attende il test fisico.

Procedura italiana per controllare modello, sistema operativo e collegamento USB di un Raspberry Pi Zero V1.3 usando Linux, senza monitor, tastiera o Wi-Fi.

## Occorrente

- Raspberry Pi Zero V1.3, microSD da almeno 8 GB e cavo micro-USB dati.
- Computer Linux con [Raspberry Pi Imager](https://www.raspberrypi.com/software/).
- Sul Pi usa la porta dati vicino alla mini-HDMI, marcata USB. PWR IN è solo alimentazione.

## Autodiagnosi automatica

La modalità di autodiagnosi avvia il controllo sul Pi e salva il risultato come `RPZC-REPORT.txt` nella partizione FAT `bootfs`, leggibile dal computer Linux. Non richiede account, monitor, tastiera, Wi-Fi o accesso SSH.

1. Dalla cartella del progetto esegui `bash image/prepare-selftest-card.sh`.
2. Seleziona la microSD corretta e conferma la scrittura. Il contenuto della scheda verrà cancellato.
3. Inserisci la microSD nel Pi Zero V1.3, alimentalo e attendi due minuti.
4. Spegni il Pi, reinserisci la microSD nel computer e apri `bootfs/RPZC-REPORT.txt`.

Il rapporto verifica modello/revisione, sistema operativo, servizio SSH e interfaccia USB sul Pi. Non prova l'autenticazione SSH né conferma che il computer host riceva un indirizzo via DHCP. Questa modalità è preparata ma attende il test su hardware reale.

## Connessione USB e SSH

Il primo test fisico ha rilevato il dispositivo USB Gadget sul computer, ma non ha ottenuto DHCP e SSH non ha risposto. L'indirizzo `10.12.194.1` è quello predefinito del pacchetto ufficiale in modalità condivisa. La procedura SSH resta non convalidata sul Pi Zero V1.3.

### Nota sul primo avvio

Nel test fisico con Trixie, il computer ha rilevato il dispositivo USB Gadget e creato un'interfaccia Ethernet, ma non ha ricevuto un indirizzo IPv4 dal Pi. SSH non è stato raggiunto e il programma di controllo non è stato eseguito. Il risultato è compatibile con la segnalazione [rpi-imager #1797](https://github.com/raspberrypi/rpi-imager/issues/1797), che riporta problemi analoghi sul Pi Zero V1.3. La segnalazione descrive prove soprattutto con Bookworm e non dimostra la causa sulla release Trixie usata qui.

## Controlli e limiti

Lo script legge modello, revisione, versione OS, architettura, servizio SSH e interfaccia USB. I codici ufficiali per Zero V1.3 sono `900093` e `920093`. La stringa BCM2835 da sola non identifica il modello.

Il risultato controlla dati esposti dal software. Non certifica autenticità, integrità elettrica o ogni componente. Il collaudo software non sostituisce una prova su hardware reale.

## Immagine e stato

`image/SOURCE.md` fissa la release ufficiale Lite Trixie 32-bit del 6 ottobre 2026 e il suo SHA-256 (anche in `image/SHA256SUMS`). Lo script image scarica e verifica l'archivio originale; non scrive su SD. Utente, password, SSH e USB Gadget sono impostazioni personali dell'Imager per evitare credenziali predefinite in un'immagine pubblica.

La modalità di autodiagnosi prepara la base ufficiale Trixie 32-bit con Cloud-Init e avvio automatico dello script. La prova SSH è **non superata**; la prova del rapporto automatico è **pendente**. Non presentare il progetto come pronto all'uso finché il rapporto non viene verificato su un Pi Zero V1.3 reale. Documentazione controllata il 20 novembre 2026.

## Riferimenti

- [Download Raspberry Pi OS](https://www.raspberrypi.com/software/operating-systems/)
- [USB Gadget e SSH over USB](https://www.raspberrypi.com/news/usb-gadget-mode-in-raspberry-pi-os-ssh-over-usb/)
- [Codici revisione](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#raspberry-pi-revision-codes)
- [Pacchetto ufficiale rpi-usb-gadget](https://github.com/raspberrypi/rpi-usb-gadget/tree/pios/trixie)
- [Guida illustrata](docs/guida-italiana.pdf)
