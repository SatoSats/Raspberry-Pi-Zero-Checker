# Stato di validazione

## Confermato da fonti ufficiali

- Raspberry Pi OS Lite 32-bit release 2026-10-06 è Trixie, kernel 6.18, compatibile con tutti i modelli; la pagina ufficiale pubblica SHA-256 2c302771f34c67a0b7ae7aa2e0dcdd3eac660504be59193c011ba79d412e1632.
- Il pacchetto Raspberry Pi rpi-usb-gadget espone rete USB; sul Pi Zero si usa la porta micro-USB dati vicina a mini-HDMI, non PWR IN.
- La documentazione Raspberry Pi indica i codici 900093 e 920093 per Zero V1.3.
- Raspberry Pi OS Trixie supporta la configurazione di USB Gadget e SSH al primo avvio tramite Imager o Cloud-Init.

## Da verificare su hardware

Il 13 novembre 2026 è stata aperta la segnalazione [rpi-imager #1797](https://github.com/raspberrypi/rpi-imager/issues/1797), relativa a Zero V1.3 che non raggiunge SSH dopo avvio a freddo collegato alla porta dati. L'autore descrive principalmente Bookworm; un collaboratore segnala di avere riprodotto difficoltà sul proprio Zero 1.3. La segnalazione non prova il comportamento della release Trixie fissata in questo progetto e non identifica una soluzione definitiva.

Prima di dichiarare collaudata o pubblicare un'immagine personalizzata occorre verificare su una scheda Raspberry Pi Zero V1.3 reale:

1. Primo avvio alimentato dal solo cavo dati collegato alla porta USB.
2. Enumerazione di rete USB su Linux e raggiungibilità di SSH.
3. Riavvio a freddo e ripetizione del collegamento.
4. Codice revisione mostrato dallo script e completezza dell'output.

Il workaround riportato nella segnalazione (avvio da PWR IN, collegamento del cavo dati, poi rimozione di PWR IN) è solo un tentativo diagnostico e non è validato da questo progetto.

## Stato

- Verifica delle pagine ufficiali aggiornata: 2026-11-20.
- Revisione di PDF e contenuti: completata localmente.
- Esecuzione degli script su Raspberry Pi Zero V1.3: pendente.
- Immagine personalizzata pubblica: non preparata e non pubblicata.
