 1. Auf neuem Rechner: Recovery-Key aus Bitwarden holen
 2. Speichern als ~/.secrets/sops-recovery.key
 3. Secrets editieren:
`SOPS_AGE_KEY_FILE=~/.secrets/sops-recovery.key sops secrets/secrets.yaml`

 4. Neuen SSH-Key generieren und in .sops.yaml eintragen
 5. updatekeys ausführen
