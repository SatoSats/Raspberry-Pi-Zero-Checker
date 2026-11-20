# Stato di validazione

## Risultato della prova fisica

Il rapporto fornito dall’utente dopo la prova sul Raspberry Pi Zero ha riportato:

- modello: Raspberry Pi Zero Rev 1.3;
- revisione: `900093`;
- sistema: Raspbian GNU/Linux 13 (Trixie), versione 13, architettura `armhf`;
- test del modello e della revisione: `OK`;
- test di Raspberry Pi OS Trixie 32 bit: `OK`;
- file `RPZC-REPORT.txt` generato automaticamente sulla partizione di avvio.

Il test di riconoscimento è quindi **superato** per la scheda provata. La revisione `920093` è ammessa dallo script come seconda variante di Raspberry Pi Zero V1.3.

Nel rapporto originario SSH non risultava attivo, `usb0` era assente e il vecchio programma terminava con codice 1. Il vecchio codice sommava questi controlli facoltativi al risultato. Non cambia i due esiti positivi del riconoscimento e del sistema. La versione aggiornata esclude SSH e tratta USB Gadget come informazione facoltativa.

## Limiti del risultato

Il controllo descrive le informazioni presentate dal software. Non certifica l’autenticità fisica della scheda: revisione e device-tree sono dati software falsificabili. L’ispezione visiva aiuta a rilevare differenze o anomalie, ma non fornisce una prova definitiva di autenticità.

## Modifiche di questa versione

- Criterio di riconoscimento: modello Raspberry Pi Zero Rev 1.3, revisione `900093` o `920093`, Raspberry Pi OS Trixie 32 bit (`armhf`).
- SSH non è richiesto e non viene abilitato dal preparatore della scheda per il rapporto automatico.
- USB Gadget e rete host sono controlli separati; la loro assenza non rende negativo il test di riconoscimento.
- Il rapporto automatico viene scritto in `/boot/firmware/RPZC-REPORT.txt`, sulla partizione di avvio leggibile dal computer.
- La guida PDF illustrata fornita dall’utente è inclusa senza modifiche al contenuto; `CONTROLLO_COMPLETO.md` fornisce le istruzioni complementari passo passo.

## Controlli dei file

La preparazione della microSD usa l’immagine ufficiale Raspberry Pi OS Lite Trixie 32 bit fissata in `image/SOURCE.md` e ne controlla SHA-256 prima della scrittura. La procedura mostra i dischi disponibili e richiede una conferma esplicita perché la scrittura cancella il dispositivo scelto.

La procedura SSH/USB della guida illustrata resta un percorso facoltativo. Il test di riconoscimento e la generazione del rapporto non dipendono dalla rete.
