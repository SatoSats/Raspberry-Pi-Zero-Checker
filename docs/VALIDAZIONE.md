# Stato di validazione

## Risultato della prova fisica già effettuata

Il rapporto fornito dall’utente dopo la prova sulla scheda ha riportato:

- Raspberry Pi Zero Rev 1.3;
- revisione `900093`;
- Raspbian GNU/Linux 13 (Trixie), versione 13, architettura `armhf`;
- riconoscimento di modello/revisione e Trixie 32 bit: `OK`;
- file `RPZC-REPORT.txt` generato automaticamente sulla partizione di avvio.

Il test di riconoscimento è superato per la scheda provata. La revisione `920093` è ammessa come seconda variante V1.3.

Il rapporto precedente riportava anche SSH inattivo, `usb0` assente ed exit code 1. Lo script precedente includeva questi controlli facoltativi nel codice di uscita. L’esito positivo di modello/revisione e sistema era comunque visibile nel rapporto. La versione attuale esclude SSH e tratta USB Gadget come informazione facoltativa.

## Immagine da scaricare

`.github/workflows/publish-image.yml` costruisce l’immagine a partire dalla release ufficiale fissata in `image/SOURCE.md`, installa il checker e abilita l’unità systemd che scrive il rapporto ad ogni avvio. La pubblicazione crea una GitHub Release con il file `rpzc-trixie-armhf.img.xz` e il relativo `SHA256SUMS`.

Il workflow verifica il checksum della base, controlla la sintassi del contenitore XZ e produce l’impronta SHA-256 dell’immagine finale. **La build non equivale a una nuova prova fisica**: un’immagine pubblicata va ancora avviata su un Raspberry Pi Zero V1.3 reale per verificare il rapporto generato da quella specifica release.

## Limiti

Il rapporto descrive dati presentati dal software. Non certifica l’autenticità fisica della scheda: revisione e device-tree sono dati software falsificabili. Anche la guida fotografica aiuta a individuare anomalie ma non prova da sola l’autenticità.

SSH non è richiesto. USB Gadget e rete host sono controlli separati e facoltativi.
