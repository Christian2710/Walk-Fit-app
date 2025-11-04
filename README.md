# Walk & Fit - Documentazione Tecnica Completa

## Indice
1. [Panoramica del Progetto](#panoramica-del-progetto)
2. [Architettura dell'Applicazione](#architettura-dellapplicazione)
3. [Tecnologie e Sensori Utilizzati](#tecnologie-e-sensori-utilizzati)
4. [Struttura del Progetto](#struttura-del-progetto)
5. [Spiegazione Dettagliata dei File](#spiegazione-dettagliata-dei-file)
6. [Flusso di Funzionamento](#flusso-di-funzionamento)
7. [Database e Persistenza Dati](#database-e-persistenza-dati)
8. [API Esterne](#api-esterne)

---

## Panoramica del Progetto

**Walk & Fit** è un'applicazione mobile per il monitoraggio dell'attività fisica sviluppata in Flutter. L'app traccia i passi dell'utente utilizzando il sensore accelerometro del dispositivo, calcola calorie bruciate e distanza percorsa, e offre funzionalità di allenamento cronometrato con calcolo della velocità media.

### Funzionalità Principali:
- Conteggio passi in tempo reale tramite sensore accelerometro
- Calcolo automatico di calorie bruciate e distanza percorsa
- **Tracciamento nutrizionale completo con database alimenti**
- **Calcolo bilancio calorico (calorie consumate vs bruciate)**
- **Suggerimenti intelligenti su quanti passi servono per smaltire**
- Obiettivo passi giornaliero personalizzabile
- Timer manuale per sessioni di allenamento
- Calcolo velocità media per chilometro durante gli allenamenti
- Resoconto dettagliato post-allenamento
- Statistiche giornaliere e settimanali con grafici
- Cronologia completa degli allenamenti effettuati
- Messaggi motivazionali basati sul progresso
- Persistenza dati locale tramite database SQLite
- **Integrazione con API nutrizionali per informazioni precise**

---

## Architettura dell'Applicazione

L'applicazione segue il pattern architetturale **MVC (Model-View-Controller)** adattato per Flutter, con una chiara separazione delle responsabilità:

### 1. **Model Layer (Modelli di Dati)**
Rappresenta la struttura dei dati dell'applicazione.

**File coinvolti:**
- `lib/models/step_record.dart` - Modello per i record giornalieri di passi
- `lib/models/workout_session.dart` - Modello per le sessioni di allenamento
- `lib/models/food_item.dart` - Modello per cibi consumati
- `lib/models/daily_nutrition.dart` - Modello per bilancio calorico giornaliero

**Responsabilità:**
- Definire la struttura dei dati
- Serializzazione/deserializzazione da/verso database
- Logica di calcolo sui dati (es. velocità media, durata formattata)

### 2. **View Layer (Interfaccia Utente)**
Gestisce la presentazione dei dati all'utente.

**File coinvolti:**
- `lib/screens/home_screen.dart` - Schermata principale
- `lib/screens/workout_screen.dart` - Schermata allenamento con timer
- `lib/screens/nutrition_screen.dart` - Schermata tracking nutrizionale
- `lib/screens/statistics_screen.dart` - Schermata statistiche e grafici

**Responsabilità:**
- Rendering dell'interfaccia grafica
- Gestione input utente
- Presentazione dati in forma visuale (grafici, card, liste)

### 3. **Service Layer (Logica di Business)**
Gestisce la logica applicativa e la comunicazione con risorse esterne.

**File coinvolti:**
- `lib/services/pedometer_service.dart` - Gestione sensore accelerometro
- `lib/services/database_service.dart` - Gestione database SQLite
- `lib/services/nutrition_api_service.dart` - Calcoli nutrizionali e messaggi

**Responsabilità:**
- Interfaccia con sensori hardware
- Gestione database e persistenza
- Calcoli e algoritmi di business logic
- Gestione messaggi motivazionali

### 4. **Entry Point**
- `lib/main.dart` - Punto di ingresso dell'applicazione

---

## Tecnologie e Sensori Utilizzati

### Sensore Accelerometro (Pedometro)

**Come Funziona:**
Il sensore accelerometro è un componente hardware presente in tutti gli smartphone moderni che misura l'accelerazione del dispositivo sui tre assi (X, Y, Z). L'applicazione utilizza questo sensore per rilevare i movimenti caratteristici della camminata.

**Principio di Funzionamento del Contapassi:**
1. **Rilevamento Movimento**: L'accelerometro rileva le variazioni di accelerazione causate dal movimento del corpo durante la camminata
2. **Analisi Pattern**: Il sistema operativo (Android/iOS) analizza questi pattern di movimento
3. **Conteggio Passi**: Quando viene riconosciuto un pattern compatibile con un passo, il contatore viene incrementato
4. **Stream di Dati**: Il sensore invia continuamente aggiornamenti all'app tramite uno stream

**Implementazione nell'App:**
- Package utilizzato: `pedometer` v4.0.2
- Il servizio `PedometerService` si sottoscrive allo stream del sensore
- Ogni evento contiene il numero totale di passi dal riavvio del dispositivo
- L'app calcola i passi giornalieri sottraendo il valore iniziale dal valore corrente

**Permessi Richiesti:**
- Android: `ACTIVITY_RECOGNITION` (necessario da Android 10+)
- iOS: Accesso ai dati "Motion & Fitness"

### Database SQLite

**Cos'è:**
SQLite è un database relazionale embedded, cioè un database che viene eseguito direttamente all'interno dell'applicazione senza bisogno di un server separato.

**Utilizzo nell'App:**
- Package utilizzato: `sqflite` v2.3.0
- Il database viene creato localmente sul dispositivo
- Due tabelle principali: `step_records` e `workout_sessions`
- Tutti i dati rimangono sul dispositivo (privacy totale)

### API Nutrizionali Integrate

L'app integra tre API principali per fornire un tracking nutrizionale completo e accurato:

#### 1. **API-Ninjas Nutrition API**

**Cos'è:**
API REST che fornisce informazioni nutrizionali dettagliate per migliaia di alimenti.

**URL Base:** `https://api.api-ninjas.com/v1`

**Endpoint utilizzato:** `/nutrition?query={food_name}`

**Funzionamento:**
- Ricerca alimenti per nome
- Ritorna calorie, proteine, carboidrati, grassi
- Porzioni standardizzate in grammi
- Gratuita con limite di richieste giornaliere

**Utilizzo nell'app:**
- Quando l'utente aggiunge un cibo, l'app interroga l'API
- I dati nutrizionali vengono mostrati all'utente
- L'utente può confermare e salvare nel database locale

#### 2. **Burned Calories Calculator API**

**Cos'è:**
API che calcola le calorie bruciate in base all'attività, durata e peso dell'utente.

**URL Base:** `https://zylalabs.com/api`

**Endpoint:** `/burned-calories-calculator`

**Parametri:**
- `activity`: tipo di attività (walking, running, cycling, ecc.)
- `duration`: durata in minuti
- `weight`: peso dell'utente in kg

**Funzionamento:**
- Utilizza valori MET (Metabolic Equivalent of Task)
- Calcola: `calorie = MET × peso_kg × (minuti / 60)`
- Fornisce risultati scientificamente accurati

**Fallback locale:**
Se l'API non è disponibile, l'app usa valori MET predefiniti:
- Camminata: 3.5 MET
- Corsa: 8.0 MET
- Ciclismo: 6.0 MET
- Nuoto: 7.0 MET
- Yoga: 2.5 MET
- Pesi: 3.0 MET

#### 3. **FatSecret Platform API**

**Cos'è:**
Una delle più grandi banche dati di alimenti al mondo con informazioni nutrizionali complete.

**URL Base:** `https://platform.fatsecret.com/rest/server.api`

**Metodo utilizzato:** `foods.search`

**Funzionamento:**
- Ricerca avanzata con oltre 1 milione di alimenti
- Database internazionale con cibi di diverse cucine
- Include alimenti di marca e preparazioni casalinghe
- Informazioni nutrizionali complete per porzione

**Utilizzo nell'app:**
- Ricerca alternativa se API-Ninjas non trova risultati
- Maggiore copertura di alimenti specifici
- Autenticazione OAuth 2.0

**Note implementative:**
- Le chiavi API devono essere inserite nelle costanti del servizio
- Tutte le API hanno un sistema di fallback locale
- I dati vengono cachati nel database SQLite per evitare chiamate ripetute

---

## Struttura del Progetto

```
Walk&Fit/
├── lib/
│   ├── main.dart                          # Entry point dell'applicazione
│   ├── models/                            # Modelli di dati
│   │   ├── step_record.dart              # Modello record passi giornalieri
│   │   ├── workout_session.dart          # Modello sessione allenamento
│   │   ├── food_item.dart                # Modello cibo consumato
│   │   └── daily_nutrition.dart          # Modello bilancio calorico
│   ├── screens/                           # Schermate UI
│   │   ├── home_screen.dart              # Schermata principale
│   │   ├── workout_screen.dart           # Schermata allenamento con timer
│   │   ├── nutrition_screen.dart         # Schermata tracking nutrizionale
│   │   └── statistics_screen.dart        # Schermata statistiche e grafici
│   └── services/                          # Servizi e logica business
│       ├── pedometer_service.dart        # Gestione sensore pedometro
│       ├── database_service.dart         # Gestione database SQLite
│       └── nutrition_api_service.dart    # Integrazione API nutrizionali
├── android/                               # Configurazione Android
├── assets/                                # Risorse (icone, immagini)
├── pubspec.yaml                          # Dipendenze e configurazione progetto
└── README.md                             # Documentazione (questo file)
```

---

## Spiegazione Dettagliata dei File

### 1. lib/main.dart

**Scopo:** Entry point dell'applicazione Flutter. Inizializza l'app e configura il tema.

**Analisi Riga per Riga:**

```dart
import 'package:flutter/material.dart';
```
Importa il framework Material Design di Flutter per la costruzione dell'interfaccia utente.

```dart
import 'package:walk_and_fit/screens/home_screen.dart';
```
Importa la schermata principale dell'app.

```dart
import 'package:walk_and_fit/services/database_service.dart';
```
Importa il servizio database per l'inizializzazione.

```dart
void main() async {
```
Funzione principale asincrona che avvia l'applicazione. `async` permette l'uso di operazioni asincrone.

```dart
  WidgetsFlutterBinding.ensureInitialized();
```
Assicura che il binding dei widget Flutter sia inizializzato prima di eseguire codice asincrono. Necessario quando si eseguono operazioni prima di `runApp()`.

```dart
  await DatabaseService.instance.database;
```
Inizializza il database in modo asincrono all'avvio dell'app. Questo assicura che il database sia pronto prima che l'utente inizi ad usare l'app.

```dart
  runApp(const MyApp());
```
Avvia l'applicazione Flutter con il widget principale `MyApp`.

```dart
class MyApp extends StatelessWidget {
```
Widget principale dell'app. `StatelessWidget` significa che non ha stato mutabile.

```dart
  const MyApp({super.key});
```
Costruttore con parametro `key` per l'identificazione del widget nell'albero.

```dart
  @override
  Widget build(BuildContext context) {
```
Metodo che costruisce l'interfaccia del widget.

```dart
    return MaterialApp(
```
Widget radice che configura l'applicazione Material Design.

```dart
      title: 'Walk & Fit',
```
Titolo dell'applicazione (visibile nel task manager).

```dart
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
```
Definisce il tema chiaro dell'app con colore principale verde e Material Design 3.

```dart
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
```
Definisce il tema scuro dell'app (si attiva automaticamente in base alle impostazioni di sistema).

```dart
      home: const HomeScreen(),
```
Imposta `HomeScreen` come schermata iniziale dell'app.

```dart
      debugShowCheckedModeBanner: false,
```
Rimuove il banner "DEBUG" visibile in modalità sviluppo.

---

### 2. lib/models/step_record.dart

**Scopo:** Modello di dati per rappresentare un record giornaliero di passi, calorie e distanza.

**Analisi Riga per Riga:**

```dart
class StepRecord {
```
Definizione della classe per il record giornaliero.

```dart
  final int? id;
```
ID univoco del record nel database. `int?` significa che può essere null (quando il record non è ancora stato salvato).

```dart
  final String date;
```
Data del record in formato 'yyyy-MM-dd' (es. '2025-11-03').

```dart
  final int steps;
```
Numero di passi effettuati in quel giorno.

```dart
  final double calories;
```
Calorie bruciate calcolate dai passi.

```dart
  final double distance;
```
Distanza percorsa in chilometri.

```dart
  StepRecord({
    this.id,
    required this.date,
    required this.steps,
    required this.calories,
    required this.distance,
  });
```
Costruttore della classe. `required` indica parametri obbligatori, `this.id` è opzionale.

```dart
  Map<String, dynamic> toMap() {
```
Metodo che converte l'oggetto in una mappa per il salvataggio nel database.

```dart
    return {
      'id': id,
      'date': date,
      'steps': steps,
      'calories': calories,
      'distance': distance,
    };
```
Crea una mappa chiave-valore con tutti i campi dell'oggetto.

```dart
  factory StepRecord.fromMap(Map<String, dynamic> map) {
```
Factory constructor che crea un oggetto `StepRecord` da una mappa (usato per leggere dal database).

```dart
    return StepRecord(
      id: map['id'],
      date: map['date'],
      steps: map['steps'],
      calories: map['calories'],
      distance: map['distance'],
    );
```
Costruisce l'oggetto estraendo i valori dalla mappa.

---

### 3. lib/models/workout_session.dart

**Scopo:** Modello per rappresentare una sessione di allenamento con timer, contenente tempo, passi, distanza e velocità.

**Analisi Riga per Riga:**

```dart
class WorkoutSession {
```
Classe che rappresenta una sessione di allenamento.

```dart
  final int? id;
  final String date;
  final int startTime;
  final int? endTime;
  final int steps;
  final double distance;
  final double? averageSpeed;
```
Campi della sessione:
- `id`: identificativo nel database
- `date`: data della sessione
- `startTime`: timestamp di inizio in millisecondi
- `endTime`: timestamp di fine (null se la sessione è ancora attiva)
- `steps`: passi durante la sessione
- `distance`: distanza in km
- `averageSpeed`: velocità media in km/h

```dart
  WorkoutSession({
    this.id,
    required this.date,
    required this.startTime,
    this.endTime,
    required this.steps,
    required this.distance,
    this.averageSpeed,
  });
```
Costruttore con parametri obbligatori e opzionali.

```dart
  int get duration => endTime != null ? endTime! - startTime : 0;
```
Getter che calcola la durata dell'allenamento in millisecondi. Se `endTime` è null (sessione ancora attiva), ritorna 0. L'operatore `!` forza l'unwrapping del valore nullable.

```dart
  String get formattedDuration {
    final totalSeconds = duration ~/ 1000;
```
Converte la durata da millisecondi a secondi. `~/` è la divisione intera.

```dart
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
```
Calcola ore, minuti e secondi dalla durata totale:
- `totalSeconds ~/ 3600`: ore (3600 secondi = 1 ora)
- `(totalSeconds % 3600) ~/ 60`: minuti rimanenti
- `totalSeconds % 60`: secondi rimanenti

```dart
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
```
Formatta la durata in modo intelligente mostrando solo le unità rilevanti.

```dart
  double calculateAverageSpeed() {
    if (distance == 0 || duration == 0) return 0;
```
Evita divisione per zero.

```dart
    final hours = duration / (1000 * 60 * 60);
```
Converte la durata in ore (divisione floating point).

```dart
    return distance / hours;
```
Calcola velocità media: km / ore = km/h.

```dart
  String getAverageSpeedPerKm() {
    if (distance == 0) return '--:--';
    final avgSpeed = calculateAverageSpeed();
    if (avgSpeed == 0) return '--:--';
```
Gestisce casi limite restituendo placeholder.

```dart
    final minutesPerKm = 60 / avgSpeed;
```
Converte km/h in minuti per km. Se vai a 6 km/h, fai 10 minuti per km (60/6=10).

```dart
    final minutes = minutesPerKm.floor();
    final seconds = ((minutesPerKm - minutes) * 60).round();
```
Estrae minuti e secondi:
- `floor()`: parte intera
- `(minutesPerKm - minutes) * 60`: converte la parte decimale in secondi

```dart
    return '${minutes}:${seconds.toString().padLeft(2, '0')} min/km';
```
Formatta come "5:30 min/km". `padLeft(2, '0')` aggiunge zero davanti se necessario.

```dart
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'steps': steps,
      'distance': distance,
      'averageSpeed': averageSpeed,
    };
  }
```
Serializza l'oggetto per il database.

```dart
  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'],
      date: map['date'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      steps: map['steps'],
      distance: map['distance'],
      averageSpeed: map['averageSpeed'],
    );
  }
```
Deserializza l'oggetto dal database.

---

### 4. lib/services/pedometer_service.dart

**Scopo:** Servizio Singleton per gestire la comunicazione con il sensore accelerometro e fornire lo stream dei passi.

**Analisi Riga per Riga:**

```dart
import 'dart:async';
```
Importa le API asincrone di Dart (Stream, Future, ecc.).

```dart
import 'package:pedometer/pedometer.dart';
```
Importa il package che interfaccia con il sensore accelerometro.

```dart
import 'package:permission_handler/permission_handler.dart';
```
Importa il package per gestire i permessi runtime.

```dart
class PedometerService {
  static final PedometerService _instance = PedometerService._internal();
  factory PedometerService() => _instance;
  PedometerService._internal();
```
Implementazione del pattern Singleton:
- `_instance`: istanza unica statica
- `factory PedometerService()`: ritorna sempre la stessa istanza
- `_internal()`: costruttore privato per impedire creazione di nuove istanze

**Perché Singleton?** Assicura che ci sia un solo servizio pedometro nell'app, evitando duplicazioni di stream e conflitti.

```dart
  StreamSubscription<StepCount>? _stepCountSubscription;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;
```
Sottoscrizioni agli stream del sensore. `StreamSubscription` permette di cancellarle quando non servono più.

```dart
  final _stepCountController = StreamController<int>.broadcast();
  final _statusController = StreamController<String>.broadcast();
```
`StreamController` crea stream personalizzati:
- `broadcast()`: permette a più ascoltatori di sottoscriversi allo stesso stream
- Trasformano i dati grezzi del sensore in formato utilizzabile dall'app

```dart
  Stream<int> get stepCountStream => _stepCountController.stream;
  Stream<String> get statusStream => _statusController.stream;
```
Getter che espongono gli stream pubblicamente (solo lettura).

```dart
  int _initialSteps = 0;
  int _currentSteps = 0;
```
Variabili per tracciare:
- `_initialSteps`: passi totali all'avvio dell'app
- `_currentSteps`: passi della sessione corrente

```dart
  Future<bool> requestPermissions() async {
```
Metodo asincrono per richiedere il permesso ACTIVITY_RECOGNITION.

```dart
    if (await Permission.activityRecognition.request().isGranted) {
      return true;
    }
    return false;
```
Richiede il permesso e ritorna `true` se concesso, `false` altrimenti.

```dart
  Future<void> startListening() async {
    if (!await requestPermissions()) {
      _statusController.add('Permessi negati');
      return;
    }
```
Se i permessi non sono concessi, invia un messaggio di errore nello stream e termina.

```dart
    _stepCountSubscription = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: _onStepCountError,
    );
```
Si sottoscrive allo stream del conteggio passi:
- `listen()`: inizia ad ascoltare gli eventi
- `_onStepCount`: callback chiamato ad ogni nuovo valore
- `onError`: callback chiamato in caso di errore

```dart
    _pedestrianStatusSubscription = Pedometer.pedestrianStatusStream.listen(
      _onPedestrianStatusChanged,
      onError: _onPedestrianStatusError,
    );
```
Si sottoscrive allo stream dello stato pedonale (walking, stopped, unknown).

```dart
  void _onStepCount(StepCount event) {
    if (_initialSteps == 0) {
      _initialSteps = event.steps;
    }
```
Al primo evento, salva il conteggio iniziale dei passi (dal riavvio del dispositivo).

```dart
    _currentSteps = event.steps - _initialSteps;
```
Calcola i passi della sessione corrente sottraendo il valore iniziale.

```dart
    _stepCountController.add(_currentSteps);
```
Invia il nuovo valore attraverso lo stream personalizzato.

```dart
  void _onPedestrianStatusChanged(PedestrianStatus event) {
    _statusController.add(event.status);
  }
```
Inoltra lo stato pedonale ("walking", "stopped", ecc.) attraverso lo stream.

```dart
  void _onStepCountError(error) {
    _statusController.add('Errore nel conteggio passi');
  }

  void _onPedestrianStatusError(error) {
    _statusController.add('Errore stato pedone');
  }
```
Gestiscono errori dal sensore inviando messaggi di errore.

```dart
  void resetDailySteps() {
    _initialSteps = _currentSteps + _initialSteps;
    _currentSteps = 0;
    _stepCountController.add(0);
  }
```
Resetta il conteggio giornaliero:
- Aggiorna `_initialSteps` al valore corrente totale
- Azzera `_currentSteps`
- Notifica l'azzeramento tramite stream

```dart
  void dispose() {
    _stepCountSubscription?.cancel();
    _pedestrianStatusSubscription?.cancel();
    _stepCountController.close();
    _statusController.close();
  }
```
Pulisce le risorse:
- Cancella le sottoscrizioni ai sensori
- Chiude i controller degli stream
Importante per evitare memory leak.

---

### 5. lib/services/database_service.dart

**Scopo:** Servizio Singleton per gestire tutte le operazioni sul database SQLite locale.

**Analisi Riga per Riga:**

```dart
import 'package:sqflite/sqflite.dart';
```
Importa il package SQLite per Flutter.

```dart
import 'package:path/path.dart';
```
Importa utility per la gestione dei percorsi file.

```dart
import 'package:walk_and_fit/models/step_record.dart';
import 'package:walk_and_fit/models/workout_session.dart';
```
Importa i modelli di dati.

```dart
import 'package:shared_preferences/shared_preferences.dart';
```
Importa il package per salvare preferenze semplici (chiave-valore).

```dart
class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();
```
Pattern Singleton per avere una sola istanza del database.

```dart
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
```
Getter asincrono per il database:
- Se già inizializzato, lo ritorna
- Altrimenti lo inizializza prima di ritornarlo
- Pattern "lazy initialization"

```dart
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
```
Ottiene il percorso standard per i database dell'app.

```dart
    final path = join(dbPath, 'walk_fit.db');
```
Costruisce il percorso completo del file database.

```dart
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
```
Apre/crea il database:
- `version: 2`: versione dello schema (per migrazioni)
- `onCreate`: chiamato alla prima creazione
- `onUpgrade`: chiamato quando la versione aumenta

```dart
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE step_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        steps INTEGER NOT NULL,
        calories REAL NOT NULL,
        distance REAL NOT NULL,
        UNIQUE(date)
      )
    ''');
```
Crea la tabella `step_records`:
- `id`: chiave primaria auto-incrementale
- `date`: data in formato testo
- `steps`, `calories`, `distance`: dati numerici
- `UNIQUE(date)`: impedisce duplicati sulla stessa data

```dart
    await db.execute('''
      CREATE TABLE workout_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        startTime INTEGER NOT NULL,
        endTime INTEGER,
        steps INTEGER NOT NULL,
        distance REAL NOT NULL,
        averageSpeed REAL
      )
    ''');
```
Crea la tabella `workout_sessions` per le sessioni di allenamento.

```dart
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE workout_sessions (
          ...
        )
      ''');
    }
  }
```
Migrazione database: quando un utente aggiorna l'app dalla versione 1 alla 2, viene creata la tabella `workout_sessions`.

```dart
  Future<int> insertStepRecord(StepRecord record) async {
    final db = await database;
    return await db.insert(
      'step_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
```
Inserisce un record di passi:
- `conflictAlgorithm.replace`: se esiste già un record per quella data, lo sostituisce
- Ritorna l'ID del record inserito

```dart
  Future<List<StepRecord>> getStepRecords({int? limit}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'step_records',
      orderBy: 'date DESC',
      limit: limit,
    );
```
Recupera i record di passi:
- `orderBy: 'date DESC'`: ordina dal più recente al più vecchio
- `limit`: numero massimo di risultati (opzionale)

```dart
    return List.generate(maps.length, (i) => StepRecord.fromMap(maps[i]));
```
Trasforma la lista di mappe in lista di oggetti `StepRecord`.

```dart
  Future<StepRecord?> getStepRecordByDate(String date) async {
    final db = await database;
    final maps = await db.query(
      'step_records',
      where: 'date = ?',
      whereArgs: [date],
    );
```
Cerca un record per data specifica:
- `where: 'date = ?'`: clausola WHERE con placeholder
- `whereArgs: [date]`: valori che sostituiscono i `?` (previene SQL injection)

```dart
    if (maps.isEmpty) return null;
    return StepRecord.fromMap(maps.first);
```
Se non trova nulla ritorna `null`, altrimenti il primo risultato.

```dart
  Future<int> updateStepRecord(StepRecord record) async {
    final db = await database;
    return await db.update(
      'step_records',
      record.toMap(),
      where: 'date = ?',
      whereArgs: [record.date],
    );
  }
```
Aggiorna un record esistente. Ritorna il numero di righe modificate.

```dart
  Future<int> deleteStepRecord(String date) async {
    final db = await database;
    return await db.delete(
      'step_records',
      where: 'date = ?',
      whereArgs: [date],
    );
  }
```
Elimina un record per data.

```dart
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        SUM(steps) as totalSteps,
        AVG(steps) as avgSteps,
        SUM(calories) as totalCalories,
        SUM(distance) as totalDistance
      FROM step_records
    ''');
    return result.first;
  }
```
Esegue una query SQL aggregata per ottenere statistiche totali:
- `SUM(steps)`: somma di tutti i passi
- `AVG(steps)`: media passi giornalieri
- `SUM(calories)` e `SUM(distance)`: totali

```dart
  Future<int> insertWorkoutSession(WorkoutSession session) async {
    final db = await database;
    return await db.insert('workout_sessions', session.toMap());
  }
```
Inserisce una nuova sessione di allenamento.

```dart
  Future<int> updateWorkoutSession(WorkoutSession session) async {
    final db = await database;
    return await db.update(
      'workout_sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }
```
Aggiorna una sessione esistente (usato per salvare `endTime` quando si ferma il timer).

```dart
  Future<List<WorkoutSession>> getWorkoutSessions({int? limit}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_sessions',
      orderBy: 'startTime DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => WorkoutSession.fromMap(maps[i]));
  }
```
Recupera la lista delle sessioni di allenamento, ordinate dalla più recente.

```dart
  Future<WorkoutSession?> getActiveWorkoutSession() async {
    final db = await database;
    final maps = await db.query(
      'workout_sessions',
      where: 'endTime IS NULL',
      orderBy: 'startTime DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return WorkoutSession.fromMap(maps.first);
  }
```
Cerca una sessione attiva (senza `endTime`):
- Utile per riprendere un allenamento in corso dopo la chiusura dell'app

```dart
  Future<int> setDailyStepGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_step_goal', goal);
    return goal;
  }
```
Salva l'obiettivo passi giornaliero nelle SharedPreferences:
- SharedPreferences è un sistema chiave-valore più semplice di SQLite
- Ideale per piccole preferenze come questa

```dart
  Future<int> getDailyStepGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('daily_step_goal') ?? 10000;
  }
```
Recupera l'obiettivo, con valore di default 10000 se non impostato (`??` è l'operatore null-coalescing).

---

### 6. lib/services/nutrition_api_service.dart

**Scopo:** Servizio per calcoli nutrizionali, messaggi motivazionali e integrazione (futura) con API esterne.

**Analisi Riga per Riga:**

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
```
Importa librerie per fare richieste HTTP e decodificare JSON.

```dart
class NutritionApiService {
  static const String _baseUrl = 'https://api.calorieninjas.com/v1';
  static const String _apiKey = 'YOUR_API_KEY_HERE';
```
URL base e chiave API per CalorieNinjas. Attualmente non utilizzati attivamente.

```dart
  Future<Map<String, dynamic>?> getCaloriesForActivity(
    String activity,
    int durationMinutes,
  ) async {
```
Metodo per interrogare l'API sul consumo calorico di un'attività.

```dart
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/caloriesburned?activity=$activity&duration=$durationMinutes'),
        headers: {'X-Api-Key': _apiKey},
      );
```
Effettua una richiesta GET all'API:
- `Uri.parse()`: costruisce l'URL con parametri query
- `headers`: aggiunge l'API key nell'header HTTP

```dart
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
```
Se la richiesta ha successo (status 200), decodifica il JSON. Altrimenti ritorna `null`.

```dart
    } catch (e) {
      return null;
    }
```
Gestisce eventuali eccezioni (es. mancanza di connessione).

```dart
  Future<Map<String, dynamic>?> getNutritionInfo(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/nutrition?query=$query'),
        headers: {'X-Api-Key': _apiKey},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
```
Metodo per ottenere informazioni nutrizionali di alimenti. Struttura identica al precedente.

```dart
  double calculateCaloriesFromSteps(int steps) {
    return steps * 0.04;
  }
```
Formula empirica per calcolare le calorie:
- 1 passo ≈ 0.04 kcal
- 10000 passi ≈ 400 kcal
Basato su medie per persona di peso medio (~70kg).

```dart
  String getMotivationalMessage(int steps) {
    if (steps < 2000) {
      return "Inizia a muoverti! Ogni passo conta! 🚶";
```
Se meno di 2000 passi, mostra messaggio di incoraggiamento iniziale.

```dart
    } else if (steps < 5000) {
      return "Ottimo inizio! Continua così! 💪";
```
Tra 2000 e 5000: messaggio di incoraggiamento.

```dart
    } else if (steps < 8000) {
      return "Stai andando benissimo! Quasi al goal! 🎯";
```
Tra 5000 e 8000: messaggio di progressione.

```dart
    } else if (steps < 10000) {
      return "Fantastico! Sei vicino all'obiettivo! 🌟";
```
Tra 8000 e 10000: quasi raggiunto l'obiettivo.

```dart
    } else {
      return "Incredibile! Hai raggiunto il goal! 🏆";
    }
```
Oltre 10000: obiettivo raggiunto!

```dart
  List<String> getHealthTips(int steps) {
    final tips = <String>[];
```
Crea una lista vuota di consigli.

```dart
    final calories = calculateCaloriesFromSteps(steps);
    
    tips.add('Hai bruciato circa ${calories.toStringAsFixed(1)} kcal');
```
Aggiunge sempre il primo consiglio con le calorie bruciate. `toStringAsFixed(1)` formatta con 1 decimale.

```dart
    if (steps >= 10000) {
      tips.add('Ottima attività! Idratati bene 💧');
      tips.add('Considera uno stretching post-camminata');
```
Se obiettivo raggiunto, aggiunge consigli per chi ha fatto molta attività.

```dart
    } else if (steps >= 5000) {
      tips.add('Ancora qualche passo per raggiungere 10.000!');
      tips.add('Prova a fare le scale invece dell\'ascensore');
```
Se a metà strada, consigli per raggiungere l'obiettivo. `\'` è l'escape dell'apostrofo.

```dart
    } else {
      tips.add('Una camminata di 30 minuti può fare la differenza');
      tips.add('Prova a fare una passeggiata dopo i pasti');
    }
    
    return tips;
  }
```
Se pochi passi, consigli per iniziare a muoversi.

---

### 7. lib/screens/home_screen.dart

**Scopo:** Schermata principale che mostra il conteggio passi in tempo reale, progresso verso l'obiettivo, calorie, distanza e consigli.

**Analisi Sezioni Principali:**

```dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
```
`StatefulWidget` perché deve aggiornare l'interfaccia quando i passi cambiano.

```dart
class _HomeScreenState extends State<HomeScreen> {
  final _pedometerService = PedometerService();
  final _nutritionService = NutritionApiService();
  final _dbService = DatabaseService.instance;
```
Istanze dei servizi utilizzati dalla schermata.

```dart
  int _steps = 0;
  String _status = 'Inizializzazione...';
  double _calories = 0;
  double _distance = 0;
  int _goalSteps = 10000;
```
Variabili di stato che definiscono i dati mostrati nell'interfaccia.

```dart
  @override
  void initState() {
    super.initState();
    _loadGoal();
    _initPedometer();
    _loadTodayData();
  }
```
Metodo chiamato quando la schermata viene creata:
1. Carica l'obiettivo salvato
2. Inizializza il pedometro
3. Carica i dati del giorno corrente dal database

```dart
  Future<void> _loadGoal() async {
    final goal = await _dbService.getDailyStepGoal();
    setState(() {
      _goalSteps = goal;
    });
  }
```
Carica l'obiettivo personalizzato. `setState()` notifica Flutter di ridisegnare l'interfaccia.

```dart
  Future<void> _initPedometer() async {
    await _pedometerService.startListening();

    _pedometerService.stepCountStream.listen((steps) {
      setState(() {
        _steps = steps;
        _calories = _nutritionService.calculateCaloriesFromSteps(steps);
        _distance = steps * 0.0008;
      });
      _saveTodayData();
    });
```
Si sottoscrive allo stream dei passi. Ad ogni nuovo valore:
1. Aggiorna `_steps`
2. Ricalcola `_calories` (passi × 0.04)
3. Ricalcola `_distance` (passi × 0.0008 km, circa 80 cm per passo)
4. Salva i dati

```dart
    _pedometerService.statusStream.listen((status) {
      setState(() {
        _status = status;
      });
    });
```
Ascolta anche lo stream dello stato ("walking", "stopped").

```dart
  Future<void> _loadTodayData() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final record = await _dbService.getStepRecordByDate(today);
    if (record != null) {
      setState(() {
        _steps = record.steps;
        _calories = record.calories;
        _distance = record.distance;
      });
    }
  }
```
Carica i dati salvati per oggi:
- Formatta la data corrente
- Cerca nel database
- Se trova dati, li carica (utile se si riapre l'app)

```dart
  Future<void> _saveTodayData() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final record = StepRecord(
      date: today,
      steps: _steps,
      calories: _calories,
      distance: _distance,
    );
    await _dbService.insertStepRecord(record);
  }
```
Salva i dati correnti nel database. Grazie a `ConflictAlgorithm.replace`, aggiorna sempre lo stesso record giornaliero.

```dart
  @override
  Widget build(BuildContext context) {
    final progress = _steps / _goalSteps;
```
Calcola la percentuale di completamento (0.0 - 1.0).

```dart
    final motivationMessage = _nutritionService.getMotivationalMessage(_steps);
    final healthTips = _nutritionService.getHealthTips(_steps);
```
Ottiene messaggio motivazionale e consigli in base ai passi.

```dart
    return Scaffold(
      appBar: AppBar(
        title: const Text('Walk & Fit'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WorkoutScreen()),
              );
            },
          ),
```
Pulsante che apre la schermata allenamento. `Navigator.push()` aggiunge una nuova schermata allo stack.

```dart
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatisticsScreen()),
              );
            },
          ),
        ],
      ),
```
Pulsante che apre le statistiche.

```dart
      body: SingleChildScrollView(
```
Permette lo scroll se il contenuto supera lo schermo.

```dart
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 4,
```
`Card` con ombra (elevation = 4).

```dart
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
```
`Stack` sovrappone widget. `alignment.center` li centra.

```dart
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                            value: progress > 1 ? 1 : progress,
```
Indicatore circolare di progresso. Limita a 1.0 se i passi superano l'obiettivo.

```dart
                            strokeWidth: 12,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress >= 1 ? Colors.green : Colors.blue,
                            ),
```
Cambia colore da blu a verde quando si raggiunge l'obiettivo.

```dart
                        Column(
                          children: [
                            Text(
                              '$_steps',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'passi',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
```
Testo al centro del cerchio che mostra il numero di passi.

```dart
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Obiettivo: $_goalSteps passi',
                          style: const TextStyle(fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: _showGoalDialog,
                        ),
                      ],
                    ),
```
Mostra l'obiettivo con un pulsante per modificarlo.

```dart
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          Icons.local_fire_department,
                          '${_calories.toStringAsFixed(1)} kcal',
                          'Calorie',
                        ),
                        _buildStatItem(
                          Icons.route,
                          '${_distance.toStringAsFixed(2)} km',
                          'Distanza',
                        ),
                      ],
                    ),
```
Mostra calorie e distanza in due colonne affiancate.

```dart
  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.orange),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
```
Widget riutilizzabile per mostrare una statistica con icona, valore e label.

```dart
  void _showGoalDialog() {
    final controller = TextEditingController(text: _goalSteps.toString());
```
Crea un controller per il campo di testo, pre-compilato con l'obiettivo attuale.

```dart
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifica Obiettivo'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
```
Dialog con campo numerico per modificare l'obiettivo.

```dart
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              final newGoal = int.tryParse(controller.text);
              if (newGoal != null && newGoal > 0) {
                await _dbService.setDailyStepGoal(newGoal);
                setState(() {
                  _goalSteps = newGoal;
                });
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Salva'),
          ),
        ],
```
Pulsanti "Annulla" e "Salva":
- `tryParse()`: converte stringa a int, ritorna `null` se non valido
- Salva nel database e aggiorna l'interfaccia
- `context.mounted`: verifica che il widget sia ancora attivo prima di chiudere il dialog

```dart
  @override
  void dispose() {
    _pedometerService.dispose();
    super.dispose();
  }
```
Pulizia risorse quando la schermata viene distrutta.

---

### 8. lib/screens/workout_screen.dart

**Scopo:** Schermata per allenamenti cronometrati con timer manuale, conteggio passi e calcolo velocità media.

**Analisi Sezioni Principali:**

```dart
class _WorkoutScreenState extends State<WorkoutScreen> {
  final _dbService = DatabaseService.instance;
  final _pedometerService = PedometerService();
  
  WorkoutSession? _activeSession;
  Timer? _timer;
  int _elapsedTime = 0;
  int _steps = 0;
  int _startSteps = 0;
  double _distance = 0;
  bool _isRunning = false;
```
Stato della schermata:
- `_activeSession`: sessione in corso (null se non attiva)
- `_timer`: timer per aggiornare il cronometro ogni secondo
- `_elapsedTime`: tempo trascorso in millisecondi
- `_steps`: passi durante la sessione
- `_startSteps`: passi totali all'inizio della sessione
- `_distance`: distanza in km
- `_isRunning`: flag per sapere se il timer è attivo

```dart
  @override
  void initState() {
    super.initState();
    _checkActiveSession();
    _initPedometer();
  }
```
All'avvio verifica se c'è una sessione attiva e inizializza il pedometro.

```dart
  Future<void> _checkActiveSession() async {
    final session = await _dbService.getActiveWorkoutSession();
    if (session != null) {
      setState(() {
        _activeSession = session;
        _isRunning = true;
        _elapsedTime = DateTime.now().millisecondsSinceEpoch - session.startTime;
        _steps = session.steps;
        _distance = session.distance;
      });
      _startTimer();
    }
  }
```
Controlla se esiste una sessione in corso (utile se l'app è stata chiusa durante un allenamento):
- Recupera la sessione dal database
- Calcola il tempo trascorso dall'inizio
- Riprende il timer

```dart
  void _initPedometer() {
    _pedometerService.stepCountStream.listen((steps) {
      if (_isRunning) {
        setState(() {
          if (_startSteps == 0) {
            _startSteps = steps;
          }
          _steps = steps - _startSteps;
          _distance = _steps * 0.0008;
        });
        _updateActiveSession();
      }
    });
  }
```
Ascolta lo stream dei passi, ma aggiorna solo se il timer è attivo:
- Al primo evento, salva `_startSteps`
- Calcola passi della sessione: `steps - _startSteps`
- Aggiorna il database in tempo reale

```dart
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime += 1000;
      });
    });
  }
```
Crea un timer che ogni secondo:
- Incrementa `_elapsedTime` di 1000ms
- Chiama `setState()` per aggiornare il display

```dart
  Future<void> _startWorkout() async {
    final now = DateTime.now();
    final session = WorkoutSession(
      date: DateFormat('yyyy-MM-dd').format(now),
      startTime: now.millisecondsSinceEpoch,
      steps: 0,
      distance: 0,
    );

    final id = await _dbService.insertWorkoutSession(session);
```
Avvia un nuovo allenamento:
- Crea una sessione con timestamp corrente
- Salva nel database
- Ottiene l'ID generato

```dart
    setState(() {
      _activeSession = WorkoutSession(
        id: id,
        date: session.date,
        startTime: session.startTime,
        steps: 0,
        distance: 0,
      );
      _isRunning = true;
      _elapsedTime = 0;
      _steps = 0;
      _startSteps = 0;
      _distance = 0;
    });

    _startTimer();
```
Inizializza lo stato e avvia il timer.

```dart
  Future<void> _stopWorkout() async {
    if (_activeSession == null) return;

    _timer?.cancel();
```
Ferma il timer. `?.` è l'operatore di chiamata sicura (chiama solo se non null).

```dart
    final endTime = DateTime.now().millisecondsSinceEpoch;
    final finalSession = WorkoutSession(
      id: _activeSession!.id,
      date: _activeSession!.date,
      startTime: _activeSession!.startTime,
      endTime: endTime,
      steps: _steps,
      distance: _distance,
      averageSpeed: _distance > 0 && _elapsedTime > 0 
          ? _distance / (_elapsedTime / (1000 * 60 * 60)) 
          : 0,
    );
```
Crea la sessione finale con:
- `endTime`: timestamp corrente
- Dati finali di passi e distanza
- Calcolo velocità media: `km / ore`

```dart
    await _dbService.updateWorkoutSession(finalSession);

    _showWorkoutSummary(finalSession);

    setState(() {
      _isRunning = false;
      _activeSession = null;
    });
```
Salva nel database, mostra il riepilogo e resetta lo stato.

```dart
  Future<void> _updateActiveSession() async {
    if (_activeSession == null) return;

    final updatedSession = WorkoutSession(
      id: _activeSession!.id,
      date: _activeSession!.date,
      startTime: _activeSession!.startTime,
      steps: _steps,
      distance: _distance,
    );

    await _dbService.updateWorkoutSession(updatedSession);
  }
```
Aggiorna continuamente la sessione nel database mentre è in corso (per non perdere dati in caso di crash).

```dart
  void _showWorkoutSummary(WorkoutSession session) {
    showDialog(
      context: context,
      barrierDismissible: false,
```
`barrierDismissible: false` impedisce di chiudere il dialog toccando fuori.

```dart
      builder: (context) => AlertDialog(
        title: const Text('Allenamento Completato! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow('Durata:', session.formattedDuration),
            _buildSummaryRow('Passi:', '${session.steps}'),
            _buildSummaryRow('Distanza:', '${session.distance.toStringAsFixed(2)} km'),
            _buildSummaryRow('Velocità media:', session.getAverageSpeedPerKm()),
          ],
        ),
```
Mostra il riepilogo con tutti i dati della sessione.

```dart
  String _formatElapsedTime() {
    final totalSeconds = _elapsedTime ~/ 1000;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
```
Formatta il tempo come "HH:MM:SS". `padLeft(2, '0')` aggiunge zeri iniziali (es. 5 diventa "05").

```dart
  String _getCurrentSpeed() {
    if (_distance == 0 || _elapsedTime == 0) return '--:-- min/km';
    
    final hours = _elapsedTime / (1000 * 60 * 60);
    final avgSpeed = _distance / hours;
    final minutesPerKm = 60 / avgSpeed;
    final minutes = minutesPerKm.floor();
    final seconds = ((minutesPerKm - minutes) * 60).round();
    
    return '${minutes}:${seconds.toString().padLeft(2, '0')} min/km';
  }
```
Calcola e formatta la velocità media in tempo reale durante l'allenamento.

```dart
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRunning ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  border: Border.all(
                    color: _isRunning ? Colors.green : Colors.grey,
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Text(
                    _formatElapsedTime(),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _isRunning ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ),
```
Cerchio grande che mostra il timer:
- Verde se in corso, grigio se fermo
- `withOpacity(0.1)`: sfondo semi-trasparente

```dart
              SizedBox(
                width: 200,
                height: 200,
                child: FloatingActionButton(
                  onPressed: _isRunning ? _stopWorkout : _startWorkout,
                  backgroundColor: _isRunning ? Colors.red : Colors.green,
                  child: Icon(
                    _isRunning ? Icons.stop : Icons.play_arrow,
                    size: 64,
                  ),
                ),
              ),
```
Pulsante grande:
- Verde con icona play per iniziare
- Rosso con icona stop per fermare

---

### 9. lib/screens/statistics_screen.dart

**Scopo:** Mostra statistiche totali, grafico degli ultimi 7 giorni e cronologia allenamenti.

**Analisi Sezioni Principali:**

```dart
class _StatisticsScreenState extends State<StatisticsScreen> {
  final _dbService = DatabaseService.instance;
  List<StepRecord> _records = [];
  List<WorkoutSession> _workouts = [];
  Map<String, dynamic> _stats = {};
```
Stato:
- `_records`: record degli ultimi 7 giorni
- `_workouts`: lista allenamenti
- `_stats`: statistiche aggregate

```dart
  Future<void> _loadData() async {
    final records = await _dbService.getStepRecords(limit: 7);
    final stats = await _dbService.getStatistics();
    final workouts = await _dbService.getWorkoutSessions(limit: 10);
    setState(() {
      _records = records.reversed.toList();
      _stats = stats;
      _workouts = workouts.where((w) => w.endTime != null).toList();
    });
  }
```
Carica tutti i dati dal database:
- Ultimi 7 record giornalieri (reversed per avere ordine cronologico)
- Statistiche totali
- Ultimi 10 allenamenti completati (filtra quelli con `endTime != null`)

```dart
                          _buildStatRow('Passi totali', '${_stats['totalSteps'] ?? 0}'),
                          _buildStatRow('Media giornaliera', '${(_stats['avgSteps'] ?? 0).toStringAsFixed(0)}'),
                          _buildStatRow('Calorie totali', '${(_stats['totalCalories'] ?? 0).toStringAsFixed(1)} kcal'),
                          _buildStatRow('Distanza totale', '${(_stats['totalDistance'] ?? 0).toStringAsFixed(2)} km'),
```
Mostra le statistiche aggregate dal database. `?? 0` fornisce un valore di default se null.

```dart
                    SizedBox(
                      height: 300,
                      child: BarChart(
```
Widget `BarChart` dal package `fl_chart` per creare grafici a barre.

```dart
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 15000,
```
Configura il grafico:
- `spaceAround`: distribuisce le barre uniformemente
- `maxY: 15000`: valore massimo asse Y

```dart
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= _records.length) {
                                  return const Text('');
                                }
                                final record = _records[value.toInt()];
                                final date = DateFormat('dd/MM').format(
                                  DateTime.parse(record.date),
                                );
                                return Text(
                                  date,
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
```
Configura le etichette dell'asse X:
- `getTitlesWidget`: funzione che genera il widget per ogni etichetta
- Mostra la data in formato "dd/MM" (es. "03/11")

```dart
                        barGroups: List.generate(
                          _records.length,
                          (index) => BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: _records[index].steps.toDouble(),
                                color: _records[index].steps >= 10000
                                    ? Colors.green
                                    : Colors.blue,
                                width: 20,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
```
Crea le barre del grafico:
- Una barra per ogni record
- Altezza = numero di passi
- Colore verde se >= 10000, altrimenti blu
- Bordi arrotondati in alto

```dart
                  if (_workouts.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Nessun allenamento registrato',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
```
Se non ci sono allenamenti, mostra un messaggio.

```dart
                  else
                    ..._workouts.map((workout) => Card(
```
Operatore spread `...` espande la lista di Card nell'albero dei widget.

```dart
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Icon(Icons.directions_run, color: Colors.white),
                            ),
```
Icona circolare a sinistra della tile.

```dart
                            title: Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(
                                DateTime.fromMillisecondsSinceEpoch(workout.startTime),
                              ),
                            ),
```
Titolo: data e ora di inizio dell'allenamento.

```dart
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Durata: ${workout.formattedDuration}'),
                                Text('${workout.steps} passi - ${workout.distance.toStringAsFixed(2)} km'),
                              ],
                            ),
```
Sottotitolo con durata, passi e distanza.

```dart
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Icon(Icons.speed, size: 16),
                                Text(
                                  workout.getAverageSpeedPerKm(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
```
A destra mostra la velocità media per km.

---

## Flusso di Funzionamento

### Avvio dell'Applicazione

1. **main.dart**: `main()` viene eseguito
   - Inizializza i binding Flutter
   - Apre il database SQLite (crea le tabelle se non esistono)
   - Avvia l'app con `MyApp` come root widget

2. **MyApp**: Configura l'applicazione
   - Imposta i temi (chiaro e scuro)
   - Definisce `HomeScreen` come schermata iniziale

3. **HomeScreen**: Si inizializza
   - Carica l'obiettivo passi dalle SharedPreferences (default 10000)
   - Richiede il permesso ACTIVITY_RECOGNITION
   - Avvia il servizio pedometro
   - Carica i dati del giorno corrente dal database
   - Si sottoscrive allo stream del sensore accelerometro

### Conteggio Passi in Tempo Reale

1. **Sensore Accelerometro**:
   - Il sistema operativo monitora continuamente l'accelerometro
   - Riconosce pattern di movimento compatibili con i passi
   - Incrementa il contatore interno

2. **PedometerService**:
   - Riceve eventi dal sensore tramite il package `pedometer`
   - Ogni evento contiene il conteggio totale dal riavvio del dispositivo
   - Calcola i passi della sessione: `passi_attuali - passi_iniziali`
   - Emette il valore nello stream personalizzato

3. **HomeScreen**:
   - Ascolta lo stream del PedometerService
   - Ad ogni nuovo valore:
     - Aggiorna `_steps`
     - Calcola calorie: `passi × 0.04`
     - Calcola distanza: `passi × 0.0008` km
     - Chiama `setState()` per aggiornare l'UI
     - Salva i dati nel database (upsert automatico per la data corrente)

### Sessione di Allenamento

1. **Avvio**:
   - L'utente apre WorkoutScreen
   - Preme il pulsante play
   - Viene creato un record `WorkoutSession` con `startTime` corrente
   - Il record viene salvato nel database
   - Parte il timer (aggiorna `_elapsedTime` ogni secondo)
   - Il servizio pedometro salva `_startSteps`

2. **Durante l'Allenamento**:
   - Il timer incrementa `_elapsedTime` ogni secondo
   - Il pedometro aggiorna `_steps` (passi dall'inizio della sessione)
   - La distanza viene ricalcolata: `_steps × 0.0008`
   - La velocità viene calcolata in tempo reale: `distanza / ore`
   - La sessione viene aggiornata nel database continuamente

3. **Fine**:
   - L'utente preme stop
   - Il timer viene fermato
   - Viene calcolata la velocità media finale
   - La sessione viene aggiornata con `endTime`
   - Appare un dialog con il riepilogo completo
   - La sessione completata viene salvata definitivamente

### Visualizzazione Statistiche

1. **Caricamento Dati**:
   - La schermata statistiche si apre
   - Vengono eseguite 3 query al database:
     - Ultimi 7 record giornalieri
     - Statistiche aggregate (totali e medie)
     - Ultimi 10 allenamenti completati

2. **Grafico**:
   - I 7 record vengono trasformati in barre
   - Ogni barra ha altezza = passi del giorno
   - Colore verde se >= 10000, altrimenti blu
   - L'asse X mostra le date in formato "dd/MM"

3. **Cronologia**:
   - Gli allenamenti vengono mostrati in una lista
   - Ogni elemento mostra: data, ora, durata, passi, distanza, velocità media

---

## Database e Persistenza Dati

### Tecnologia: SQLite

SQLite è un database relazionale **embedded**, cioè un database che viene eseguito direttamente all'interno dell'applicazione senza bisogno di un server separato. È perfetto per applicazioni mobile perché:
- Leggero e veloce
- Non richiede configurazione
- Tutto memorizzato in un singolo file
- Supporta query SQL complete
- ACID compliant (transazioni sicure)

### Schema Database

**Tabella: step_records**
```sql
CREATE TABLE step_records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,
  steps INTEGER NOT NULL,
  calories REAL NOT NULL,
  distance REAL NOT NULL,
  UNIQUE(date)
)
```
- `id`: chiave primaria auto-incrementale
- `date`: data in formato 'yyyy-MM-dd'
- `steps`, `calories`, `distance`: dati numerici del giorno
- `UNIQUE(date)`: garantisce un solo record per data (permette upsert automatico)

**Tabella: workout_sessions**
```sql
CREATE TABLE workout_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,
  startTime INTEGER NOT NULL,
  endTime INTEGER,
  steps INTEGER NOT NULL,
  distance REAL NOT NULL,
  averageSpeed REAL
)
```
- `startTime`, `endTime`: timestamp in millisecondi
- `endTime` è NULL per sessioni in corso
- `averageSpeed`: velocità media in km/h

### Migrazione Database

L'app usa un sistema di versioning:
- Versione 1: solo tabella `step_records`
- Versione 2: aggiunta tabella `workout_sessions`

Quando un utente aggiorna l'app, il metodo `_onUpgrade` viene eseguito automaticamente per aggiornare lo schema senza perdere dati.

### SharedPreferences

Per dati semplici (chiave-valore) come l'obiettivo passi, viene usato SharedPreferences invece di SQLite:
- Più veloce per letture/scritture singole
- API più semplice
- Ideale per preferenze utente

---

## API Esterne

### CalorieNinjas API

**Base URL**: `https://api.calorieninjas.com/v1`

**Endpoints Disponibili** (non utilizzati attivamente nell'app attuale):

1. **/caloriesburned**
   - Parametri: `activity` (tipo di attività), `duration` (minuti)
   - Ritorna: calorie bruciate per quella attività

2. **/nutrition**
   - Parametri: `query` (nome alimento)
   - Ritorna: informazioni nutrizionali dettagliate

**Autenticazione**: API Key nell'header `X-Api-Key`

**Nota Implementazione**: Nell'app attuale, il calcolo delle calorie è fatto localmente con la formula `passi × 0.04`. La struttura del servizio API è presente per eventuali integrazioni future più precise.

---

## Note Tecniche Aggiuntive

### Pattern di Programmazione Utilizzati

1. **Singleton**: PedometerService e DatabaseService garantiscono un'unica istanza globale
2. **Stream Pattern**: Comunicazione reattiva tra sensore e UI
3. **Factory Constructor**: Creazione oggetti da Map (database)
4. **Async/Await**: Gestione operazioni asincrone (database, sensori, API)

### Gestione dello Stato

- `StatefulWidget` per schermate con dati dinamici
- `setState()` per notificare cambiamenti dell'UI
- Stream per comunicazione continua sensore-app

### Calcoli Chiave

- **Calorie**: `passi × 0.04` kcal (basato su persona media ~70kg)
- **Distanza**: `passi × 0.0008` km (circa 80cm per passo)
- **Velocità Media**: `distanza_km / durata_ore` = km/h
- **Passo per km**: `60 / velocità_kmh` = min/km

### Permessi Android

Richiesto nel file `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION"/>
```

Per Android 10+, deve essere richiesto a runtime tramite `permission_handler`.

---

## Tracking Nutrizionale - Funzionalità Avanzate

### Bilancio Calorico Intelligente

L'app implementa un sistema completo di tracking nutrizionale che calcola automaticamente:

1. **Calorie Consumate**: Somma di tutti i cibi registrati nella giornata
2. **Calorie Bruciate**: Calorie da passi + calorie da allenamenti cronometrati
3. **Bilancio**: Differenza tra consumate e bruciate

### Suggerimenti Dinamici

In base al bilancio calorico, l'app fornisce suggerimenti specifici:

- **Deficit calorico** (bruciate > consumate): Messaggio congratulatorio
- **Surplus calorico** (consumate > bruciate): 
  - Calcola quanti passi servono per smaltire l'eccesso
  - Stima i minuti di camminata necessari
  - Formula: `passi_necessari = calorie_eccesso / 0.04`

### Workflow Utente

1. **Aggiunta Cibo**:
   - L'utente inserisce il nome del cibo
   - L'app interroga API-Ninjas per i dati nutrizionali
   - Se trovati, mostra un riepilogo con calorie, proteine, carboidrati, grassi
   - L'utente può confermare o inserire manualmente se i dati non sono trovati
   - Il cibo viene salvato nel database locale

2. **Visualizzazione Bilancio**:
   - Card principale mostra calorie consumate vs bruciate
   - Indicatore visivo (verde per deficit, arancione per surplus)
   - Messaggio personalizzato basato sul bilancio
   - Suggerimenti sui passi/minuti necessari

3. **Lista Cibi**:
   - Visualizza tutti i cibi consumati oggi
   - Possibilità di eliminare voci errate
   - Aggiornamento in tempo reale del bilancio

### Modelli di Dati Nutrizionali

**FoodItem**: Rappresenta un singolo cibo consumato
- Nome, calorie, proteine, carboidrati, grassi
- Porzione in grammi
- Timestamp per ordinamento cronologico

**DailyNutrition**: Calcola e fornisce il bilancio giornaliero
- Metodi helper per calcoli automatici
- Proprietà calcolate (balance, stepsNeededToBalance, minutesWalkingNeeded)
- Messaggi dinamici basati sullo stato

### Database Nutrizionale

Tabella `food_items`:
```sql
CREATE TABLE food_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,
  name TEXT NOT NULL,
  calories REAL NOT NULL,
  protein REAL NOT NULL,
  carbs REAL NOT NULL,
  fat REAL NOT NULL,
  servingSize REAL NOT NULL,
  timestamp INTEGER NOT NULL
)
```

Permette di:
- Salvare cibi consumati per data
- Calcolare totali giornalieri con query aggregate
- Mantenere storico completo
- Eliminare voci errate

### Configurazione API

Per utilizzare le API nutrizionali, inserisci le chiavi in `lib/services/nutrition_api_service.dart`:

```dart
static const String _apiNinjasKey = 'TUA_CHIAVE_API_NINJAS';
static const String _burnedCaloriesKey = 'TUA_CHIAVE_BURNED_CALORIES';
static const String _fatSecretKey = 'TUA_CHIAVE_FATSECRET';
```

**Come ottenere le chiavi:**
1. **API-Ninjas**: Registrati su https://api-ninjas.com
2. **Burned Calories**: Registrati su https://zylalabs.com
3. **FatSecret**: Registrati su https://platform.fatsecret.com

Tutte offrono piani gratuiti con limiti giornalieri sufficienti per uso personale.

---

## Conclusione

Walk & Fit è un'applicazione completa per il fitness e nutrition tracking che combina:
- Monitoraggio continuo tramite sensori hardware
- **Tracking nutrizionale completo con API internazionali**
- **Calcolo bilancio calorico intelligente**
- Database locale per privacy e prestazioni
- Calcoli in tempo reale per feedback immediato
- **Suggerimenti personalizzati per raggiungere obiettivi**
- Interfaccia intuitiva Material Design
- Architettura modulare e scalabile

L'app dimostra l'uso efficace di:
- Pattern architetturali (MVC, Singleton)
- Programmazione asincrona e reattiva (Stream, Future)
- **Integrazione multiple API REST**
- Integrazione sensori hardware
- Persistenza dati locale (SQLite + SharedPreferences)
- UI responsive e animata con Flutter
- **Algoritmi nutrizionali e di fitness**

