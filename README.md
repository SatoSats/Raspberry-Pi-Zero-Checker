# Raspberry Pi Zero Checker

Guida in italiano per controllare visivamente e tramite software un Raspberry Pi Zero V1.3 con Raspberry Pi OS Trixie a 32 bit (`armhf`).

## Immagine pronta da scaricare

Scarica l’immagine preconfigurata dalla pagina [Releases](https://github.com/SatoSats/Raspberry-Pi-Zero-Checker/releases/latest):

1. Scarica `rpzc-trixie-armhf.img.xz` e `SHA256SUMS`.
2. Verifica l’integrità del download con il comando indicato in [CONTROLLO_COMPLETO.md](docs/CONTROLLO_COMPLETO.md).
3. Apri Raspberry Pi Imager, scegli **Use custom / Usa immagine personalizzata**, seleziona il file `.img.xz` e scrivilo sulla microSD.
4. Avvia il Pi Zero, attendi la creazione del rapporto e poi leggi `RPZC-REPORT.txt` dalla partizione `bootfs` sul computer.

La [procedura completa passo passo](docs/CONTROLLO_COMPLETO.md) spiega anche come scegliere la microSD corretta, avviare il Pi e interpretare il rapporto. Prima dell’installazione, confronta la scheda con le fotografie originali nella [guida visiva](docs/guida-italiana.pdf).

## Che cosa significa il risultato

Il test di riconoscimento è superato quando il rapporto mostra Raspberry Pi Zero Rev 1.3, revisione `900093` oppure `920093`, e Raspberry Pi OS Trixie 32 bit (`armhf`). Il controllo conferma che il software identifica dati compatibili con il modello previsto.

Non certifica l’autenticità fisica della scheda: revisione e device-tree sono dati software falsificabili. Anche il controllo visivo aiuta a individuare anomalie, ma non dimostra da solo l’autenticità.

SSH non è un requisito. USB Gadget e la connessione di rete tra Pi e computer sono verifiche facoltative e separate.

## Esito della prova già effettuata

Il rapporto fornito per la scheda provata ha identificato Raspberry Pi Zero Rev 1.3, revisione `900093` e Trixie 32 bit (`armhf`). Il file `RPZC-REPORT.txt` è stato generato automaticamente sulla partizione di avvio. La versione attuale dell’immagine usa il criterio corretto e non dipende da SSH o USB Gadget.

## Per chi mantiene il progetto

Il workflow in `.github/workflows/publish-image.yml` costruisce e pubblica l’immagine pronta nelle Releases. `image/build-ready-image.sh` prepara il file partendo dalla base ufficiale con checksum verificato. `image/prepare-selftest-card.sh` resta un metodo alternativo per scrivere direttamente una microSD da Linux.

Nella guida PDF, le pagine 1–5 con fotografie e controlli visivi sono rimaste invariate. Le pagine 6–7 sono state aggiornate alla procedura con l’immagine pronta scaricata da GitHub; SSH non è richiesto.