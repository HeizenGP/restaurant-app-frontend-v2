# Staff App

Base técnica Android para el personal y Flutter Web para administración. No
contiene flujos de negocio ni navegación por roles.

```powershell
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
flutter run -d chrome --web-port=5173 --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```
