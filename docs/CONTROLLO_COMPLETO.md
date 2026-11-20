# Controllo completo del Raspberry Pi Zero V1.3

Questa procedura combina l’ispezione fotografica della scheda con il rapporto automatico prodotto sulla microSD. È scritta per chi non ha esperienza di elettronica.

## Prima di iniziare

Occorrono il Raspberry Pi Zero da controllare, una microSD, un computer Linux con Raspberry Pi Imager e un cavo micro-USB. La procedura del rapporto non richiede monitor, tastiera, Wi-Fi, SSH o una connessione di rete USB.

La scheda e i dati mostrati dal suo sistema possono essere contraffatti. Il risultato indica ciò che il software rileva; non è una certificazione di autenticità.

## 1. Ispezione visiva con le fotografie

Apri la [guida visiva illustrata](guida-italiana.pdf) e confronta la scheda reale con le fotografie del lato componenti e del lato posteriore. Non modificare o rimuovere componenti durante il controllo.

Segui l’orientamento mostrato nella guida: GPIO in alto, porte sul bordo inferiore, lettore microSD a sinistra e connettore CAMERA sul bordo destro. Controlla la presenza, la posizione e l’integrità dei connettori e dei componenti indicati nelle pagine 2 e 3. Sul retro confronta logo, serigrafie, piazzole di test e area J5 con la fotografia. Verifica la checklist visiva a pagina 5.

Il Raspberry Pi Zero V1.3 senza suffisso H può avere i 40 fori GPIO non popolati con pin metallici: è normale. Non decidere in base al colore del circuito o dei connettori, né a una singola marcatura del package; alcuni componenti e codici variano tra lotti. Non scartare una scheda soltanto perché un particolare colore differisce dalla fotografia.

La foto è un riferimento per notare incongruenze, parti mancanti, fili aggiunti o saldature sospette. Logo, scritte e disposizione possono essere copiati: la somiglianza visiva non prova l’autenticità.

## 2. Preparare la microSD con il rapporto automatico

Dal terminale del computer, entra nella cartella del repository e avvia:

```bash
bash image/prepare-selftest-card.sh
```

Lo script scarica la base ufficiale Raspberry Pi OS Lite Trixie a 32 bit (`armhf`) e ne verifica il checksum. Poi mostra i dischi rilevati. Seleziona il disco intero corrispondente alla microSD, non una sua partizione. Controlla con attenzione nome e dimensione: la scrittura cancella tutti i dati presenti sul disco scelto.

Per proseguire, conferma soltanto dopo aver verificato che il dispositivo selezionato sia davvero la microSD. Se hai dubbi, annulla e chiedi aiuto prima di scrivere.

Il programma inserisce nella configurazione di avvio il controllo e l’unità systemd. L’unità è abilitata per partire automaticamente. SSH non viene abilitato e non è necessario.

## 3. Avviare il Raspberry e leggere il rapporto

Espelli la microSD in sicurezza dal computer e inseriscila nel Raspberry Pi Zero. Alimenta la scheda. Per questa procedura puoi usare la porta `PWR IN`; non occorre collegare il cavo USB dati al computer.

Attendi circa due minuti per il primo avvio e la creazione del rapporto. Poi spegni la scheda e reinserisci la microSD nel computer. Apri la partizione di avvio, chiamata di solito `bootfs`, e leggi il file `RPZC-REPORT.txt`.

Il rapporto viene scritto in `/boot/firmware/RPZC-REPORT.txt` sul Raspberry; quando la microSD viene rimessa nel computer, il file si trova nella partizione FAT di avvio.

## 4. Interpretare il risultato di riconoscimento

Il profilo previsto dal test è:

- modello: Raspberry Pi Zero Rev 1.3;
- revisione: `900093` oppure `920093`;
- sistema: Raspberry Pi OS Trixie;
- architettura: `armhf` (32 bit).

Se il rapporto mostra queste informazioni e scrive **Esito test di riconoscimento: SUPERATO**, il test di riconoscimento software è superato. Il valore `900093` è stato osservato nel collaudo reale del 20 novembre 2026; il codice ammesso `920093` identifica la stessa revisione V1.3.

Il rapporto precedente al cambiamento dello script mostrava anche SSH non attivo e `usb0` assente e terminava con codice 1. Questo codice rifletteva il vecchio criterio che sommava controlli facoltativi al risultato. Il riconoscimento del modello e del sistema era comunque riuscito. Nella versione aggiornata, SSH è escluso e l’assenza di `usb0` è solo informativa: non impediscono l’esito positivo se modello, revisione e sistema coincidono.

Se modello, revisione, codename o architettura non coincidono, il test non risulta superato. Conserva il rapporto completo e ricontrolla le righe prima di trarre conclusioni sulla scheda.

## 5. Limiti e verifiche facoltative

Il rapporto legge informazioni rese disponibili dal sistema, tra cui `/proc/device-tree/model`, la revisione in `/proc/cpuinfo` e `/etc/os-release`. Questi sono dati software falsificabili. Un risultato positivo conferma che il software ha riconosciuto il profilo previsto; non dimostra che la scheda sia originale, che ogni componente sia quello di fabbrica o che l’hardware sia elettricamente integro.

SSH non è requisito del test. USB Gadget e la rete tra computer e Raspberry sono controlli separati. L’eventuale presenza di `usb0` riguarda il Raspberry; per verificare che il computer host riceva una rete USB occorre un controllo distinto dal computer. L’assenza di questi elementi non cambia l’esito del test di riconoscimento.

La guida illustrata descrive anche un percorso facoltativo di collegamento USB e lettura del codice tramite SSH. Seguilo solo se vuoi verificare quel collegamento; non serve per generare o leggere `RPZC-REPORT.txt`.
