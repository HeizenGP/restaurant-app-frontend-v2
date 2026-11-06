# Customer App

App Android para Cliente e Invitado de KAIRO. Incluye M01 (acceso y perfil), M02 (catálogo), M03 (mesas), M04 (pedidos y seguimiento), M06 (anticipos y estado de pagos) y M07 (despacho/entrega).

## Configuración de Entornos

La URL de la API se selecciona en tiempo de compilación mediante flags booleanas:

- **Para Render (Backend en la nube):**
  ```powershell
  flutter run --dart-define=USE_RENDER=true --dart-define=USE_LOCAL=false
  ```
- **Para Backend Local (localhost:8000 / emulador Android):**
  ```powershell
  flutter run --dart-define=USE_RENDER=false --dart-define=USE_LOCAL=true
  ```

## Verificación

```powershell
flutter analyze
flutter test test/features test/navigation
```

Para depuración en dispositivo físico con backend local:
```powershell
adb -s <device-id> reverse tcp:8000 tcp:8000
flutter run -d <device-id> --dart-define=USE_RENDER=false --dart-define=USE_LOCAL=true
```
