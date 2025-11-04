# Guida Configurazione API

## ✅ API GIÀ CONFIGURATA!

L'app è **già pronta all'uso** con:
- ✅ **API-Ninjas configurata** - Accesso a migliaia di alimenti internazionali
- ✅ **Database locale** - 40+ cibi italiani comuni sempre disponibili offline

**Puoi usare l'app immediatamente!** Cerca cibi come "pasta", "pollo", "apple", "chicken", "rice" e funzionerà!

---

## API 1: API-Ninjas Nutrition (CONSIGLIATA)

### Cosa fa
Cerca informazioni nutrizionali per migliaia di alimenti internazionali.

### Come ottenerla (GRATIS)

1. **Vai su:** https://api-ninjas.com/register

2. **Registrati** con email (conferma l'email)

3. **Vai su:** https://api-ninjas.com/profile
   
4. **Copia la tua API Key** (es: `abc123def456ghi789jkl012mno345pqr678stu901vwx234`)

5. **Apri il file:** `lib/services/nutrition_api_service.dart`

6. **Trova la riga 5:**
   ```dart
   static const String _apiNinjasKey = 'YOUR_API_NINJAS_KEY_HERE';
   ```

7. **Sostituisci con la tua chiave:**
   ```dart
   static const String _apiNinjasKey = 'abc123def456ghi789jkl012mno345pqr678stu901vwx234';
   ```

8. **Salva il file** ✅

### Limiti piano gratuito
- 10.000 richieste al mese
- Più che sufficienti per uso personale

---

## Come Funziona il Calcolo delle Calorie Bruciate

L'app calcola automaticamente le calorie bruciate in base a:

1. **Passi Giornalieri**:
   - Formula: `calorie = passi × 0.04`
   - Esempio: 10.000 passi = 400 kcal

2. **Allenamenti Cronometrati**:
   - Calcolate in base a durata e passi durante la sessione
   - Traccia anche velocità media e distanza

3. **Bilancio Intelligente**:
   - Calorie Consumate (cibi inseriti)
   - Calorie Bruciate (passi + allenamenti)
   - **Suggerimenti**: Ti dice quanti passi/minuti servono per smaltire l'eccesso!

---

## Funzionalità Complete

### Tracking Nutrizionale
- ✅ Ricerca automatica cibi con API-Ninjas
- ✅ Database locale per cibi italiani comuni
- ✅ Inserimento manuale se cibo non trovato
- ✅ Salvataggio cibi consumati nel database
- ✅ Calcolo calorie, proteine, carboidrati, grassi

### Calcolo Bilancio Calorico
- ✅ Totale calorie consumate (cibi inseriti)
- ✅ Totale calorie bruciate (passi + workout)
- ✅ Bilancio giornaliero in tempo reale
- ✅ Indicatore visivo (verde = deficit, arancione = surplus)

### Suggerimenti Intelligenti
- ✅ "Hai 300 kcal da smaltire"
- ✅ "Cammina ancora 7500 passi (circa 75 minuti)"
- ✅ Aggiornamenti dinamici durante la giornata

---

## Riepilogo File da Modificare

**File:** `lib/services/nutrition_api_service.dart`

```dart
class NutritionApiService {
  // Riga 5 - API-Ninjas (Consigliata)
  static const String _apiNinjasKey = 'INSERISCI_QUI';
  
  // Riga 8 - Burned Calories (Opzionale)
  static const String _burnedCaloriesKey = 'INSERISCI_QUI';
  
  // Righe 11-12 - FatSecret (Opzionale)  
  static const String _fatSecretKey = 'INSERISCI_QUI';
  static const String _fatSecretSecret = 'INSERISCI_QUI';
```

---

## Test

Dopo aver inserito le chiavi:

1. **Riavvia l'app** completamente
2. **Vai nella sezione Nutrizione** (icona 🍴)
3. **Prova a cercare:** "chicken breast" o "apple"
4. Se funziona, vedrai i dati nutrizionali dettagliati!

---

## Cibi Disponibili Offline (Senza API)

L'app ha già un database locale con questi cibi:
- Mela, Banana, Arance, Fragole, Pesche
- Pasta, Riso, Pane, Cereali
- Pollo, Manzo, Pesce, Tonno, Salmone, Prosciutto
- Uova, Latte, Formaggio, Yogurt
- Patate, Carote, Pomodoro, Insalata, Verdure, Legumi
- Pizza, Gelato, Cioccolato, Biscotti, Nutella
- Olio, Burro, Zucchero
- Caffè, Tè, Acqua, Vino, Birra

Cerca uno di questi cibi e funzionerà sempre, anche senza connessione!

---

## Problemi Comuni

### "Dati non trovati"
- Verifica di aver inserito correttamente la chiave API
- Controlla di aver salvato il file
- Riavvia completamente l'app
- Controlla la connessione internet
- Prova con un cibo del database locale (es: "pasta")

### Errore API
- Controlla di non aver superato i limiti gratuiti
- Verifica che la chiave sia valida sul sito dell'API
- L'app userà automaticamente il database locale come fallback

---

## Note Importanti

⚠️ **Non condividere mai le tue chiavi API pubblicamente**

✅ **L'app funziona già senza API** grazie al database locale

💡 **Consiglio:** Configura solo API-Ninjas per iniziare, le altre sono opzionali

🔒 **Privacy:** Tutte le chiamate API vengono cachate nel database locale dopo la prima ricerca
