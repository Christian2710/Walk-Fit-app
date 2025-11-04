# GitHub Actions - CI/CD Pipeline

## 📋 Panoramica

Walk & Fit include una **pipeline CI/CD completa** con GitHub Actions per test automatici, build e release.

### Pipeline Implementate

| Workflow | File | Trigger | Scopo |
|----------|------|---------|-------|
| **Test** | `flutter_test.yml` | Push, PR | Esegue test su Linux e macOS |
| **Build** | `build.yml` | Push, PR | Build APK e App Bundle |
| **Release** | `release.yml` | Tag `v*.*.*` | Release automatica con asset |
| **Quality** | `code_quality.yml` | Push, PR, Schedule | Verifica qualità e sicurezza |
| **CI** | `ci.yml` | Push, PR | Pipeline principale completa |

---

## 🔄 Workflow 1: Flutter Tests

**File**: `.github/workflows/flutter_test.yml`

### Quando si Attiva

- ✅ Push su `main`, `master`, `develop`
- ✅ Pull request verso `main`, `master`
- ✅ Manualmente (workflow_dispatch)

### Cosa Fa

**Matrix Build**: Test su Linux E macOS

1. **Checkout Codice**: Scarica repository
2. **Setup Java 17**: Solo per Linux (Android)
3. **Setup Flutter**: Installa Flutter stable cache
4. **Installa Dipendenze**: `flutter pub get`
5. **Verifica Formatting**: `flutter format --set-exit-if-changed`
6. **Analisi Statica**: `flutter analyze`
7. **Esegui Test**: Tutti i test con reporter expanded
8. **Coverage Report**: Genera file `coverage/lcov.info`
9. **Upload Codecov**: Carica coverage (solo Linux)
10. **Upload Artifact**: Salva risultati test (7 giorni)

### Output

- ✅ Badge test passati/falliti
- 📊 Report coverage su Codecov
- 📁 Artifact con risultati

### Esempio Output

```
✅ Tests: 20 passed, 0 failed
📊 Coverage: 75.2%
⏱️ Durata: 2m 34s
```

---

## 🏗️ Workflow 2: Build Android

**File**: `.github/workflows/build.yml`

### Quando si Attiva

- ✅ Push su `main`, `master`
- ✅ Pull request
- ✅ Manualmente

### Job 1: Build APK

**Steps:**
1. Checkout codice
2. Setup Java 17 + Flutter
3. **Esegui test** (blocca build se falliscono!)
4. Build APK release
5. Calcola SHA256 hash
6. Upload APK (30 giorni)
7. Upload hash

**Output**: `walk-and-fit-apk.apk` (~20-50 MB)

### Job 2: Build App Bundle

**Trigger Speciale**: Solo su branch `main`/`master`

**Steps:**
1. Setup ambiente
2. Build AAB release
3. Upload AAB (90 giorni)

**Output**: `walk-and-fit-aab.aab` (~15-40 MB)

**Nota**: AAB è per Google Play Store

### Job 3: Build Info

**Dipende da**: build-apk, build-appbundle

**Steps:**
1. Download artifact APK
2. Calcola dimensione file
3. Genera summary con info

**Output**: Summary su GitHub con dimensioni

---

## 🚀 Workflow 3: Release Automatica

**File**: `.github/workflows/release.yml`

### Quando si Attiva

**Automatico**: Quando crei un tag versione
```bash
git tag v1.0.0
git push origin v1.0.0
```

**Manuale**: Da GitHub Actions tab

### Cosa Fa

**Build Multipli**:
1. APK Universale (tutti i dispositivi)
2. APK ARM64 (dispositivi moderni, più piccolo)
3. APK ARM32 (dispositivi vecchi)
4. APK x86_64 (emulatori)
5. App Bundle (Play Store)

**Steps Automatici**:
1. ✅ Esegui tutti i test (blocca se falliscono)
2. ✅ Analizza codice
3. ✅ Build APK split per ABI (ottimizzato)
4. ✅ Build App Bundle
5. ✅ Genera changelog automatico da git log
6. ✅ Calcola SHA256 di tutti i file
7. ✅ Crea GitHub Release
8. ✅ Upload tutti i file

### Release Note Automatiche

La release include:
- 📱 Link download per ogni APK
- ✨ Changelog auto-generato dai commit
- 🔐 File checksums.txt per verifica integrità
- 📊 Info build (Flutter version, commit hash)

### Esempio Release

```markdown
## 🎉 Walk & Fit v1.0.0

### 📱 Download
- APK Universale: app-release.apk (25 MB)
- APK ARM64: app-arm64-v8a-release.apk (18 MB)
- App Bundle: app-release.aab (15 MB)

### ✨ Novità
- Aggiunto tracking nutrizionale
- Timer workout con passo dinamico
- Obiettivo basato su calorie

### 🔐 Verifica
SHA256: abc123...
```

---

## 🎯 Workflow 4: Code Quality

**File**: `.github/workflows/code_quality.yml`

### Quando si Attiva

- ✅ Push/PR
- ✅ Ogni domenica alle 00:00 (cron)

### Job 1: Quality Check

**Verifica:**
1. ✅ Analisi statica rigorosa (`--fatal-infos`)
2. ✅ Formattazione codice
3. ✅ Dipendenze obsolete
4. ✅ Metriche codice (file, linee)

**Output**: Summary con statistiche

### Job 2: Security Check

**Verifica:**
1. ✅ Nessuna API key hardcoded
2. ✅ Nessun file secrets committato
3. ✅ Nessuna password nel codice

**Output**: Report sicurezza

### Job 3: Dependency Check

**Verifica:**
1. ✅ Vulnerabilità dipendenze
2. ✅ Versioni obsolete
3. ✅ Albero dipendenze

---

## 🔧 Workflow 5: CI Principale

**File**: `.github/workflows/ci.yml`

### Pipeline Completa

Combina tutti i workflow in uno:

**Job 1: Test**
- Analisi + Test + Coverage

**Job 2: Build APK**
- Build e upload APK

**Job 3: Build Bundle**
- Build AAB (solo main)

**Durata Totale**: 5-8 minuti

---

## 📊 Badge per README

Aggiungi al README.md:

```markdown
![Tests](https://github.com/USERNAME/walk-and-fit/workflows/Flutter%20Tests/badge.svg)
![Build](https://github.com/USERNAME/walk-and-fit/workflows/Build%20Android/badge.svg)
![Quality](https://github.com/USERNAME/walk-and-fit/workflows/Code%20Quality/badge.svg)
[![codecov](https://codecov.io/gh/USERNAME/walk-and-fit/branch/main/graph/badge.svg)](https://codecov.io/gh/USERNAME/walk-and-fit)
```

---

## 🎬 Come Usare

### 1. Push Normale

```bash
git add .
git commit -m "feat: nuova funzionalità"
git push
```

**Trigger**: Tests + Build APK

### 2. Pull Request

```bash
git checkout -b feature/nuova-feature
git add .
git commit -m "feat: implementa X"
git push origin feature/nuova-feature
```

Crea PR su GitHub → **Trigger tutti i check**

### 3. Release

```bash
git tag v1.0.0
git push origin v1.0.0
```

**Trigger**: Release workflow → Crea release con APK scaricabili

### 4. Manuale

1. Vai su GitHub → Actions tab
2. Scegli workflow (es. "Build Android")
3. Click "Run workflow"
4. Seleziona branch
5. Click "Run workflow"

---

## 📦 Artifact Generati

| Artifact | Retention | Dimensione | Uso |
|----------|-----------|------------|-----|
| `test-results-ubuntu` | 7 giorni | ~1 MB | Debug test |
| `test-results-macos` | 7 giorni | ~1 MB | Debug test |
| `walk-and-fit-apk` | 30 giorni | ~25 MB | Distribuzione diretta |
| `walk-and-fit-apk-hash` | 30 giorni | ~1 KB | Verifica integrità |
| `walk-and-fit-aab` | 90 giorni | ~15 MB | Play Store |

### Download Artifact

1. Vai su GitHub → Actions
2. Click sul workflow completato
3. Scroll → Sezione "Artifacts"
4. Click download

---

## 🔔 Notifiche

### Email Automatiche

GitHub invia email per:
- ✅ Test falliti
- ✅ Build falliti
- ✅ Release completate

### Status Check PR

Ogni PR mostra:
- ✅ Test: 20 passed
- ✅ Build: Success
- ✅ Quality: No issues

**Merge bloccato** se un check fallisce!

---

## 🐛 Troubleshooting

### Test Falliscono in CI ma Passano Localmente

```bash
# Replica ambiente CI
flutter clean
flutter pub get
flutter test
```

### Build Fallisce

**Causa comune**: Dipendenze non sincronizzate

```bash
flutter pub upgrade
flutter pub get
```

### Coverage Non Caricato

**Soluzione**: Aggiungi secret `CODECOV_TOKEN`:
1. Vai su codecov.io
2. Connetti repository
3. Copia token
4. GitHub → Settings → Secrets → New secret
5. Nome: `CODECOV_TOKEN`
6. Valore: token copiato

### Workflow Non Parte

**Verifica**:
- File in `.github/workflows/` sono validi YAML
- Branch match il trigger (main vs master)
- Actions abilitate nel repository

---

## ⚙️ Configurazione Repository

### Secrets Necessari

| Secret | Obbligatorio | Uso |
|--------|--------------|-----|
| `GITHUB_TOKEN` | ✅ Auto | Release, artifacts |
| `CODECOV_TOKEN` | ⚪ Opzionale | Upload coverage |

### Branch Protection

**Consigliato per `main`**:

```yaml
Require status checks:
  ✅ Test
  ✅ Build APK
  ✅ Code Quality

Require review: 1
Require linear history: true
```

---

## 📈 Metriche Pipeline

### Performance

| Stage | Durata Media | Cache Hit |
|-------|--------------|-----------|
| Checkout | 5-10s | N/A |
| Setup Flutter | 20-30s | 95% |
| Install Deps | 10-20s | 90% |
| Tests | 30-45s | N/A |
| Build APK | 2-3m | 80% |
| Build AAB | 2-3m | 80% |
| **Totale** | **5-8m** | **85%** |

### Costi

- ✅ **Gratis** per repository pubblici
- ✅ **2000 min/mese** gratis per privati
- ✅ Uso stimato: ~100-200 min/mese

---

## 🚀 Prossimi Step

### Dopo il Push

1. **Vai su GitHub Actions tab**
2. **Monitora workflow in esecuzione**
3. **Attendi green checkmark** ✅
4. **Download APK** da Artifacts (se necessario)

### Per Release

1. **Assicurati che tutti i test passino**
2. **Crea tag**: `git tag v1.0.0`
3. **Push tag**: `git push origin v1.0.0`
4. **Attendi ~8 minuti**
5. **Release creata automaticamente!**
6. **Download APK dalla sezione Releases**

---

## 📝 Best Practices

### Commit Messages

Usa conventional commits per changelog automatico:

```bash
feat: aggiunge timer workout
fix: corregge calcolo calorie
docs: aggiorna README
test: aggiunge unit test per nutrition
chore: aggiorna dipendenze
```

### Versionamento

**Semantic Versioning** (MAJOR.MINOR.PATCH):

```
v1.0.0 - Release iniziale
v1.0.1 - Bug fix
v1.1.0 - Nuova feature
v2.0.0 - Breaking change
```

### Branch Strategy

```
main/master  → Produzione (protetto)
develop      → Sviluppo (test automatici)
feature/*    → Nuove features
hotfix/*     → Fix urgenti
```

---

## ✅ Checklist Pre-Release

Prima di creare un tag di release:

- [ ] Tutti i test passano localmente
- [ ] `flutter analyze` zero errori
- [ ] Versione aggiornata in `pubspec.yaml`
- [ ] CHANGELOG.md aggiornato
- [ ] Screenshot aggiornati (se necessario)
- [ ] Documentazione aggiornata
- [ ] Build locale funziona: `flutter build apk`

---

## 🎯 Vantaggi Pipeline CI/CD

### Per Sviluppo

- ✅ **Test Automatici**: Ogni commit testato
- ✅ **Qualità Garantita**: Nessun codice rotto in main
- ✅ **Review Facilitata**: Status check visibili in PR
- ✅ **Regression Prevention**: Test bloccano merge

### Per Deploy

- ✅ **Build Automatici**: APK pronti ad ogni release
- ✅ **Riproducibili**: Stesso ambiente sempre
- ✅ **Tracciabili**: Ogni build loggata
- ✅ **Veloci**: 5-8 minuti dal tag all'APK

### Per Team

- ✅ **Collaborazione**: PR con status check
- ✅ **Documentazione**: Pipeline as Code
- ✅ **Standardizzazione**: Processo uguale per tutti
- ✅ **Audit Trail**: History completa

---

## 📖 Esempi Pratici

### Scenario 1: Sviluppo Feature

```bash
# 1. Crea branch
git checkout -b feature/tracking-workout
<function_calls>
# 2. Sviluppa e testa
flutter test

# 3. Commit
git add .
git commit -m "feat: aggiunge workout tracking"

# 4. Push
git push origin feature/tracking-workout

# 5. Crea PR su GitHub
# → CI esegue automaticamente test e build
# → Vedi risultati in PR

# 6. Se tutto green → Merge!
```

### Scenario 2: Rilascio Versione

```bash
# 1. Assicurati di essere su main aggiornato
git checkout main
git pull

# 2. Aggiorna versione in pubspec.yaml
# version: 1.0.1+2

# 3. Commit
git add pubspec.yaml
git commit -m "chore: bump version to 1.0.1"

# 4. Crea tag
git tag v1.0.1

# 5. Push commit e tag
git push
git push origin v1.0.1

# 6. Attendi ~8 minuti
# → Release automatica creata
# → APK disponibili per download
# → Changelog auto-generato
```

### Scenario 3: Hotfix Urgente

```bash
# 1. Branch da main
git checkout -b hotfix/fix-crash main

# 2. Fix bug
# ...

# 3. Test locale
flutter test

# 4. Commit e push
git add .
git commit -m "fix: risolve crash al login"
git push origin hotfix/fix-crash

# 5. PR veloce
# → CI verifica fix
# → Merge se green

# 6. Tag immediato
git checkout main
git pull
git tag v1.0.2
git push origin v1.0.2

# → Release automatica in 8 minuti!
```

---

## 🔍 Monitoraggio e Debug

### Visualizzare Log

1. GitHub → Actions tab
2. Click sul workflow run
3. Click su job (es. "test")
4. Espandi step per vedere log

### Ri-eseguire Workflow Fallito

1. Vai al workflow fallito
2. Click "Re-run all jobs" (in alto a destra)
3. Attendi nuova esecuzione

### Download Artifact

1. Workflow completato → Scroll down
2. Sezione "Artifacts"
3. Click nome artifact
4. Download ZIP

---

## 🌟 Funzionalità Avanzate

### Matrix Build

Test su **2 sistemi operativi** contemporaneamente:
- Linux (veloce, economico)
- macOS (iOS compatibility check)

### Caching Intelligente

- ✅ Flutter SDK cachato
- ✅ Dipendenze Pub cachate
- ✅ Gradle cache (Android)
- ✅ Riduce tempo build 50%

### Conditional Jobs

- `build-appbundle`: Solo su main
- `upload-codecov`: Solo su Linux
- `release`: Solo su tag v*

### Artifact Retention

- Test: 7 giorni (debug)
- APK: 30 giorni (testing)
- AAB: 90 giorni (Play Store)

---

## 📚 Risorse

### Documentazione Ufficiale

- [GitHub Actions](https://docs.github.com/en/actions)
- [Flutter CI/CD](https://docs.flutter.dev/deployment/cd)
- [Codecov Integration](https://docs.codecov.com/docs)

### Action Usate

- `actions/checkout@v4` - Checkout repository
- `actions/setup-java@v3` - Setup Java
- `subosito/flutter-action@v2` - Setup Flutter
- `actions/upload-artifact@v4` - Upload files
- `softprops/action-gh-release@v1` - Create release
- `codecov/codecov-action@v4` - Upload coverage

---

## 🎓 Per la Presentazione

### Punti da Evidenziare

1. **Pipeline Completa**: Test + Build + Release automatizzati
2. **Multi-Platform**: Linux + macOS
3. **Quality Gates**: Merge bloccato se test falliscono
4. **Release Automatiche**: Tag → APK in 8 minuti
5. **Best Practices**: Semantic versioning, changelog automatico
6. **Professional**: Stesso workflow di progetti enterprise

### Demo Live

1. Mostra file `.github/workflows/`
2. Spiega trigger e job
3. Mostra Actions tab su GitHub
4. Mostra release automatica
5. Scarica APK da artifact

### Domande Previste

**Q: Perché CI/CD?**
A: Automatizza test, previene regressioni, accelera deploy

**Q: Quanto costa?**
A: Gratis per pubblici, 2000 min/mese gratis per privati

**Q: Quanto tempo risparmia?**
A: Test manuali + build manuale = 15-20 min → Automatico in 5-8 min

**Q: Cosa succede se test falliscono?**
A: Workflow si ferma, nessun build creato, merge PR bloccato

---

## ✨ Conclusione

La pipeline CI/CD di Walk & Fit è:
- 🏗️ **Completa**: Test, build, release automatici
- 🔒 **Sicura**: Quality gates, security scan
- ⚡ **Veloce**: 5-8 minuti total pipeline
- 💰 **Economica**: Gratis su GitHub
- 📊 **Professionale**: Industry standard practices

**Production-ready e enterprise-grade!** 🚀
