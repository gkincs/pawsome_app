# pawsome_app
- Kisállat-Gondozó Mobilalkalmazás

Egy Flutter-alapú mobilalkalmazás, amely segít a kisállattartóknak abban, hogy nyomon kövessék kedvenceik adatait, időpontjait, táplálkozási naplóját, gyógyszerelését és kiadásait. Az alkalmazás Firebase alapú háttérrel működik, és egyszerű, mégis hatékony módot kínál a kisállatok mindennapi gondozásának kezelésére.

## Fő Funkciók:

- **Felhasználói regisztráció és bejelentkezés**
- **Kisállat profil létrehozása és kezelése**
- **Időpontok kezelése**
- **Táplálkozási napló vezetése**
- **Mozgásnapló rögzítése**
- **Gyógyszeres kezelés nyilvántartása**
- **Kiadások követése**

## Követelmények:

- **Flutter SDK verzió**: 3.24.5
- **Ajánlott fejlesztői környezet**: Android Studio vagy Visual Studio Code
- **Dart verzió**: 3.5.4
- **Minimális Android verzió**: Android 6.0 (API 23)
- **Minimális iOS verzió**: iOS 11.0

## Telepítés:

Az alkalmazás telepítéséhez és beállításához a következő lépéseket kell követni:

1. Klónozni kell a repository-t a következő parancs segítségével:
   ```bash
   git clone https://github.com/gkincs/pawsome_app


2. Belépés a projekt könyvtárába:
    cd  <projekt könyvtárának a neve>

3. Szükséges csomagok telepítése:
    flutter pub get

Futtatás:
    flutter run

Használt fő csomagok:

    firebase_core: A Firebase alapú szolgáltatások inicializálásához.

    firebase_auth: Felhasználói hitelesítés és regisztráció.

    cloud_firestore: Firestore adatbázis kezelésére szolgál.

    provider: Állapotkezelés a felhasználói interface számára.

    flutter_svg: SVG fájlok kezelésére.

    intl: Dátumformátumok és lokalizáció kezelésére.


A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
