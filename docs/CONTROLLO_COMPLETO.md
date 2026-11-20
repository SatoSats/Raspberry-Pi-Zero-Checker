# Controllo completo del Raspberry Pi Zero V1.3

Questa procedura usa un’immagine già pronta: la scarichi da GitHub, la scrivi sulla microSD, avvii il Raspberry e leggi il rapporto dal computer. La guida illustrata inclusa nel repository contiene le fotografie originali per confrontare la scheda.

## Occorrente

- Raspberry Pi Zero da controllare e una microSD da almeno 8 GB.
- Computer con Raspberry Pi Imager e lettore microSD.
- Alimentatore micro-USB per la porta `PWR IN`.

Non servono monitor, tastiera, Wi-Fi, SSH o collegamento USB dati al computer.

## 1. Confronta la scheda con le fotografie

Apri la [guida visiva illustrata](guida-italiana.pdf). Segui l’orientamento indicato e confronta sia il lato componenti sia il retro con le fotografie originali. Controlla connettori, scritte, fori GPIO e disposizione dei componenti come descritto nelle pagine 2, 3 e 5.

Sul modello senza suffisso H, i 40 fori GPIO possono essere vuoti: è normale. Colore del circuito, colore dei connettori e singole marcature dei componenti possono cambiare tra lotti. La foto aiuta a notare anomalie, ma scritte e logo possono essere copiati e il confronto visivo non certifica l’autenticità.

## 2. Scarica l’immagine già pronta da GitHub

1. Apri la pagina [Releases di Raspberry Pi Zero Checker](https://github.com/SatoSats/Raspberry-Pi-Zero-Checker/releases/latest).
2. Scarica questi due file della versione più recente:
   - `rpzc-trixie-armhf.img.xz` — immagine da scrivere sulla microSD;
   - `SHA256SUMS` — impronta per controllare che il download sia completo.
3. Metti entrambi i file nella stessa cartella del computer.
4. Su Linux apri il Terminale in quella cartella ed esegui:

   ```bash
   sha256sum -c SHA256SUMS
   ```

   Prosegui solo se compare `OK` per `rpzc-trixie-armhf.img.xz`. Se il controllo fallisce, scarica di nuovo entrambi i file.

L’immagine contiene Raspberry Pi OS Trixie 32 bit e il servizio che crea il rapporto a ogni avvio. Non contiene password personali. SSH non viene abilitato.

## 3. Scrivi la microSD

1. Inserisci la microSD nel computer.
2. Apri Raspberry Pi Imager.
3. Scegli **Use custom / Usa immagine personalizzata** e seleziona `rpzc-trixie-armhf.img.xz`.
4. Scegli la microSD come destinazione. Controlla nome e capacità del supporto: la scrittura cancellerà tutti i dati presenti sulla microSD selezionata.
5. Avvia la scrittura e attendi che Raspberry Pi Imager mostri il completamento.
6. Espelli la microSD in modo sicuro.

## 4. Avvia il Pi e fai creare il rapporto

1. Inserisci la microSD nel Raspberry Pi Zero.
2. Collega un alimentatore alla porta `PWR IN`, quella più vicina alla porta `USB` dati.
3. Attendi circa due minuti per il primo avvio e la creazione del file.
4. Scollega l’alimentazione, poi rimuovi la microSD.

Il servizio di sistema è attivato automaticamente. Scrive il rapporto in `/boot/firmware/RPZC-REPORT.txt`; sul computer il file si trova nella partizione FAT chiamata spesso `bootfs`.

## 5. Leggi e interpreta `RPZC-REPORT.txt`

Rimetti la microSD nel computer, apri `bootfs` e fai doppio clic su `RPZC-REPORT.txt` (oppure aprilo con un editor di testo).

Il profilo atteso è:

- modello: Raspberry Pi Zero Rev 1.3;
- revisione: `900093` oppure `920093`;
- sistema: Raspberry Pi OS Trixie;
- architettura: `armhf` (32 bit).

Se questi dati corrispondono e compare **Esito test di riconoscimento: SUPERATO**, il riconoscimento software è superato. `900093` è la revisione rilevata nella prova già effettuata; `920093` è l’altra revisione V1.3 ammessa.

SSH non fa parte del test. L’assenza dell’interfaccia `usb0` non cambia l’esito. USB Gadget e la rete tra il computer host e il Pi si controllano a parte, solo se ti interessa verificare anche quel collegamento.

## 6. Limiti del controllo

Il programma legge informazioni presentate dal sistema, tra cui modello, revisione, `/proc/device-tree/model` e `/etc/os-release`. La revisione e il device-tree sono dati software falsificabili. Il risultato conferma che il software ha riconosciuto il profilo previsto; non certifica l’autenticità fisica, l’origine o l’integrità elettrica della scheda.

La guida illustrata descrive anche un percorso USB/SSH facoltativo. Non serve per scrivere l’immagine, generare il rapporto o superare il test di riconoscimento.

## Nota per chi mantiene il repository

Il workflow di pubblicazione genera il file `.img.xz` dalle fonti fissate nel repository. `image/prepare-selftest-card.sh` è un percorso alternativo per preparare direttamente una microSD da Linux; l’utente finale può seguire invece i passaggi di questa guida e scaricare l’immagine dalle Releases.
