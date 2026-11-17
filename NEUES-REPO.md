# Checkliste neues Repo

## 0. Vorher
- [ ] Zu welchem Fokus-Thema gehört das? Wenn keins: nicht anlegen, auf den Ideen-Parkplatz.
- [ ] Öffentlich oder privat? Privat, sobald Kunden-, Liedelt-, Stiftungs- oder Personendaten drin sind.

## 1. Repo aus der Vorlage anlegen

```powershell
gh repo create roberteinsle/<name> --private --template roberteinsle/app-template
```

Die Vorlage bringt mit: `CLAUDE.md` (bindet `docs/STANDARDS.md` ein), Build-Workflow mit allen Prüfungen, Dependabot, Devcontainer, Dockerfile, Coolify-Compose, `.gitignore`, `.env.example`.

## 2. Im Codespace
- [ ] Codespace öffnen, dann einmal `bin/init-laravel.sh` (Laravel 13, Filament 5, Pest, Larastan, Tests gegen PostgreSQL)
- [ ] `CLAUDE.md` und `README.md` ausfüllen (Platzhalter `<…>`)
- [ ] `name` in `.devcontainer/devcontainer.json` und `APP_NAME` in `.env.example` anpassen
- [ ] `LICENSE` – nur bei öffentlichen Repos
- [ ] Committen und pushen; in Actions prüfen, dass alles grün ist

## 3. Sicherheit
- [ ] Skript erneut ausführen (kann man beliebig oft laufen lassen), in PowerShell im Ordner dieses Repos:

  ```powershell
  $env:DRY_RUN = "0"
  & "C:\Program Files\Git\bin\bash.exe" scripts/github-security-enable.sh
  ```

- [ ] Repo → Security: keine offenen Secret-Scanning-Meldungen

## 4. Coolify und Betrieb

Ausführlich in `DEPLOYMENT.md` → „Neue App in Coolify“. Kurz:

- [ ] PostgreSQL als eigene Ressource anlegen, Backup aktivieren
- [ ] „Docker Compose Empty“ mit `deploy/docker-compose.coolify.yml`, Env-Variablen setzen, Domain und Port 8080
- [ ] Auto-Deploy: Secrets `COOLIFY_WEBHOOK`, `COOLIFY_TOKEN`, Variable `AUTO_DEPLOY=true`
- [ ] Öffentlich erreichbar? → Admin-Pfad hinter Cloudflare Access
- [ ] `/login-audit` in Claude Code ausführen, sobald der Login steht
- [ ] Release-Tag `v0.1.0`, sobald die App etwas Sinnvolles tut
