# Raspberry Pi Zero Checker

> Stato: il collaudo fisico su Raspberry Pi Zero V1.3 del 20 novembre 2026 non ha completato SSH. Il progetto non è pronto per l'uso da parte di principianti.

Procedura italiana per controllare modello, sistema operativo e collegamento USB di un Raspberry Pi Zero V1.3 usando Linux, senza monitor, tastiera o Wi-Fi.

## Occorrente

- Raspberry Pi Zero V1.3, microSD da almeno 8 GB e cavo micro-USB dati.
- Computer Linux con [Raspberry Pi Imager](https://www.raspberrypi.com/software/).
- Sul Pi usa la porta dati vicino alla mini-HDMI, marcata USB. PWR IN è solo alimentazione.

## Procedura rapida

1. In Imager scegli Raspberry Pi OS Lite (32-bit), Trixie. Personalizza nome host, utente e password; attiva SSH e USB Gadget. Non configurare Wi-Fi.
2. Scrivi la microSD. La scrittura cancella i dati presenti sulla scheda.
3. Inserisci la scheda nel Pi e collega la porta USB dati al computer con il cavo dati. Attendi fino a un minuto.
4. Dal terminale Linux esegui `ssh NOMEUTENTE@10.12.194.1`, sostituendo l'utente configurato in Imager.
5. Copia ed esegui gli script:

   ```sh
   scp -r scripts NOMEUTENTE@10.12.194.1:~
   ssh NOMEUTENTE@10.12.194.1 'sudo bash ~/scripts/install.sh'
   ```

6. Riavvia il Pi, ricollegati via SSH e lancia `pi-zero-checker`.

L'indirizzo 10.12.194.1 è quello predefinito del pacchetto ufficiale quando il Pi opera in modalità USB Gadget condivisa. Se la connessione non compare, consulta la guida PDF.

### Nota sul primo avvio

Nel test fisico con Trixie, il computer ha rilevato il dispositivo USB Gadget e creato un'interfaccia Ethernet, ma non ha ricevuto un indirizzo IPv4 dal Pi. SSH non è stato raggiunto e il programma di controllo non è stato eseguito. Il risultato è compatibile con la segnalazione [rpi-imager #1797](https://github.com/raspberrypi/rpi-imager/issues/1797), che riporta problemi analoghi sul Pi Zero V1.3. La segnalazione descrive prove soprattutto con Bookworm e non dimostra la causa sulla release Trixie usata qui.

## Controlli e limiti

Lo script legge modello, revisione, versione OS, architettura, servizio SSH e interfaccia USB. I codici ufficiali per Zero V1.3 sono `900093` e `920093`. La stringa BCM2835 da sola non identifica il modello.

Il risultato controlla dati esposti dal software. Non certifica autenticità, integrità elettrica o ogni componente. Il collaudo software non sostituisce una prova su hardware reale.

## Immagine e stato

`image/SOURCE.md` fissa la release ufficiale Lite Trixie 32-bit del 6 ottobre 2026 e il suo SHA-256 (anche in `image/SHA256SUMS`). Lo script image scarica e verifica l'archivio originale; non scrive su SD. Utente, password, SSH e USB Gadget sono impostazioni personali dell'Imager per evitare credenziali predefinite in un'immagine pubblica.

L'immagine personalizzata del progetto non è inclusa. La base ufficiale è stata scritta su microSD e verificata, ma il collaudo funzionale è **non superato**: manca la connessione IPv4/SSH. Una variante con riavvio automatico del modulo USB resta sperimentale e non è convalidata su Trixie. Non distribuire un'immagine del progetto come pronta all'uso finché il percorso semplice non supera il test su hardware reale. Documentazione controllata il 20 novembre 2026.

## Riferimenti

- [Download Raspberry Pi OS](https://www.raspberrypi.com/software/operating-systems/)
- [USB Gadget e SSH over USB](https://www.raspberrypi.com/news/usb-gadget-mode-in-raspberry-pi-os-ssh-over-usb/)
- [Codici revisione](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#raspberry-pi-revision-codes)
- [Pacchetto ufficiale rpi-usb-gadget](https://github.com/raspberrypi/rpi-usb-gadget/tree/pios/trixie)
- [Guida illustrata](docs/guida-italiana.pdf)
