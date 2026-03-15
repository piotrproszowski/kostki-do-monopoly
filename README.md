# Kostki Monopoly 3D (Flutter)

Projekt "re-write" aplikacji webowej na natywny Flutter, aby wspierać prawdziwą fizykę 3D.

## Wymagania
- Flutter SDK (zainstalowany i dodany do PATH)
- Przeglądarka Chrome do uruchamiania wersji web
- Android Studio / Xcode (opcjonalnie, do uruchomienia symulatora)

## Uruchomienie lokalne
1. Otwórz terminal w tym folderze.
2. Pobierz zależności:
   ```bash
   flutter pub get
   ```
3. Uruchom aplikację:
   ```bash
   flutter run
   ```

## Uruchomienie w przeglądarce
1. Włącz obsługę Flutter Web:
   ```bash
   flutter config --enable-web
   ```
2. Uruchom aplikację w Chrome:
   ```bash
   flutter run -d chrome
   ```

## Deploy na GitHub Pages
Najprostsza wersja polega na zbudowaniu aplikacji web i opublikowaniu zawartości katalogu `build/web`.

### 1. Zbuduj wersję produkcyjną
Jeśli repozytorium będzie publikowane pod adresem w stylu:
`https://twoj-login.github.io/nazwa-repo/`

to użyj:
```bash
flutter build web --base-href /nazwa-repo/
```

Jeśli publikujesz pod własną domeną w katalogu głównym, użyj:
```bash
flutter build web
```

### 2. Opublikuj `build/web` na branchu `gh-pages`
Przykład:
```bash
git add .
git commit -m "Prepare web build"
git subtree push --prefix build/web origin gh-pages
```

### 3. Włącz GitHub Pages w repozytorium
W ustawieniach repozytorium:
- wejdź w `Settings`
- otwórz `Pages`
- ustaw źródło publikacji na branch `gh-pages`

Po chwili aplikacja będzie dostępna pod adresem:
`https://twoj-login.github.io/nazwa-repo/`

## Szybki test na tablecie w tej samej sieci Wi‑Fi
Po zbudowaniu aplikacji możesz wystawić katalog `build/web` lokalnie:
```bash
python3 -m http.server 8000 --directory build/web
```

Następnie otwórz na tablecie:
`http://ADRES_IP_TWOJEGO_MACA:8000`

## Funkcje
- Prawdziwy render 3D (kostki to sześciany, nie obrazki).
- Fizyka rzutu: kostki obracają się z wytracaniem prędkości.
- Wybór liczby kostek (1-5).
