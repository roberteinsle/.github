# Checkliste neues Repo

## 0. Vorher
- [ ] Zu welchem Fokus-Thema gehört das? Wenn keins: nicht anlegen, auf den Ideen-Parkplatz.
- [ ] Öffentlich oder privat? Privat, sobald Kunden-, Liedelt-, Stiftungs- oder Personendaten drin sind.

## 1. Dateien
- [ ] `README.md` – Zweck, Installation, wo es läuft (Server/VM)
- [ ] `.gitignore` – `.env`, `vendor/`, `node_modules/` ausschließen
- [ ] `.env.example` – alle Variablen ohne echte Werte
- [ ] `LICENSE` – nur bei öffentlichen Repos
- [ ] `.github/dependabot.yml` – Vorlage aus `vorlagen/dependabot.yml` kopieren, nicht genutzte Ökosysteme löschen
- [ ] `docs/STANDARDS.md` – aus diesem Repo kopieren
- [ ] `CLAUDE.md` – erste Zeile `@docs/STANDARDS.md`, danach nur Projektspezifisches

## 2. Sicherheit
- [ ] Skript erneut ausführen (kann man beliebig oft laufen lassen), in PowerShell im Ordner dieses Repos:

  ```powershell
  $env:DRY_RUN = "0"
  & "C:\Program Files\Git\bin\bash.exe" scripts/github-security-enable.sh
  ```

- [ ] Danach kurz prüfen: Repo → Settings → Advanced Security

## 3. Nach dem ersten Push
- [ ] Repo → Security: keine offenen Secret-Scanning-Meldungen
