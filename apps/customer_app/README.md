# Customer App

App Android para Cliente e Invitado. M01, catálogo M02 y carrito local están
implementados y listos para revisión; no incluye checkout ni funcionalidades de
10.05.

`API_BASE_URL` se lee en compilación, acepta únicamente una URL absoluta HTTP(S)
y usa `http://10.0.2.2:8000/api/v1` por defecto. Para verificar la app y
reemplazar el valor durante el arranque:

```powershell
flutter analyze --no-pub
flutter test --no-pub
flutter run --no-pub --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

`10.0.2.2` permite que el emulador Android alcance la API del equipo anfitrión.
Para un dispositivo físico conectado por ADB, crea el túnel y recompila con
`localhost`:

```powershell
adb -s <device-id> reverse tcp:8000 tcp:8000
flutter run --no-pub -d <device-id> --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

El túnel debe volver a crearse si el dispositivo se desconecta o reinicia.
La excepción de tráfico HTTP para `10.0.2.2` y `localhost` existe solo en debug;
release debe usar HTTPS.
