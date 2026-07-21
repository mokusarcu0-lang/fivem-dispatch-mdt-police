# FiveM Dispatch, MDT, Police & Jail System

**Professzionális rendőrségi rendszer ESX Legacy 1.14.0-hoz**

## 🎯 Funkciók

### 📋 Dispatch Rendszer
- ✅ Valós idejű híváskezelés
- ✅ Automatikus blip generálás
- ✅ GPS navigáció
- ✅ Hívás elfogadás/lezárás
- ✅ Hívások előzmény

### 📱 Mobil Adatopó (MDT)
- ✅ Jármű adatbázis keresés
- ✅ Játékos keresés és adatok
- ✅ Körözöttek listája
- ✅ Személyes megjegyzések
- ✅ Szép modern UI

### 👮 Rendőrségi Rendszer
- ✅ Körözési szintek (0-5 csillag)
- ✅ Arcmaszk rendszer
- ✅ Szolgálat be/ki
- ✅ Rendőrségi parancsok
- ✅ Jogosítványok kezelése

### 🔒 Börtön Rendszer
- ✅ Börtön időzítő
- ✅ Szökés megakadályozás
- ✅ Börtön ajtó zárolás
- ✅ Automatikus felszabadítás
- ✅ Adatbázis tárolt börtönidő

## 📥 Telepítés

1. **Másold** a mappát a `resources` mappádba
2. **Frissítsd** az `fxmanifest.lua` fájlt ha szükséges
3. **Add hozzá** az `ensure fivem-dispatch-mdt-police` sort a `server.cfg`-be
4. **Importáld** az SQL táblák a `config.lua`-ban felsoroltak szerint
5. **Restart** a szervert

## 🎮 Parancsok

```
/dispatch     - Új hívás létrehozása
/mdt          - Mobil Adatopó megnyitása
/wanted       - Körözés beállítása
/jail         - Játékos börtönzése
/unjail       - Játékos felszabadítása
/duty         - Munkába állás/felszabadulás
/frisk        - Játékos megmotozása
/checklic     - Jogosítványa ellenőrzése
```

## ⚙️ Konfigurálás

Az `shared/config.lua` fájlban módosíthatod:
- Rendőrség job neve
- Börtön helyszínei
- Körözési szintek
- Parancsok nevei
- Nyelvesítés

## 📝 Nyelvek

- 🇭🇺 Magyar (Default)
- 🇬🇧 English

## 🛠️ Támogatott Keretrendszerek

- ✅ ESX Legacy 1.14.0
- ✅ ox_lib
- ✅ MySQL-async / MySQL Slow

## 💾 Adatbázis Táblák

```sql
- dispatch_calls     (Hívások)
- player_wanted      (Körözöttek)
- player_jail        (Börtön)
- player_notes       (Megjegyzések)
- police_logs        (Naplók)
```

## 👨‍💻 Fejlesztő

**FiveM Developer** - 2026

## 📄 Licenc

Szabad felhasználás az adott szerverre

## 🐛 Hibák Bejelentése

Ha hibát találsz, jelezd az issue-k között!

---

**Sok sikert a használatban!** 🚔✨
