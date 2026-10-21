# Customer App

Base técnica Android para Cliente e Invitado. No contiene flujos de negocio.

```powershell
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

`10.0.2.2` permite que el emulador Android alcance la API del equipo anfitrión.
