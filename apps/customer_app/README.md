# Customer App

Base Android para Cliente e Invitado. Conserva configuración, temas y capas no
visuales de M01/M02; las rutas renderizan placeholders neutros mientras
10.01–10.03 permanecen reabiertos y sin pantallas vigentes.

`API_BASE_URL` se lee en compilación, acepta únicamente una URL absoluta HTTP(S)
y usa `http://10.0.2.2:8000/api/v1` por defecto. Para verificar la app y
reemplazar el valor durante el arranque:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

`10.0.2.2` permite que el emulador Android alcance la API del equipo anfitrión.
La excepción de tráfico HTTP para `10.0.2.2` y `localhost` existe solo en debug;
release debe usar HTTPS.
