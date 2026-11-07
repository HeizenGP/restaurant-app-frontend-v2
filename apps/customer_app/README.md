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

## Google OAuth 2.0

La app obtiene un ID token con el plugin oficial `google_sign_in` y lo envía al
backend para validación. No contiene client secrets ni crea una sesión paralela:
la respuesta se persiste con el mismo almacenamiento seguro de KAIRO.

Configuración externa pendiente:

1. En Google Cloud Console crea/configura la pantalla de consentimiento.
2. Crea un cliente OAuth **Android** para el package
   `pe.chifaasia.customer_app` y registra los SHA-1/SHA-256 de debug y release.
3. Crea un cliente OAuth **Web application** para el backend. Usa ese mismo
   identificador en Render como `RESTAURANT_GOOGLE_OAUTH_CLIENT_ID` y al compilar
   Flutter como `GOOGLE_WEB_CLIENT_ID`.
4. No incorpores un client secret, keystore ni credenciales SMTP al repositorio.

Ejemplo local:

```powershell
flutter run `
  --dart-define=USE_RENDER=false `
  --dart-define=USE_LOCAL=true `
  --dart-define=GOOGLE_WEB_CLIENT_ID=000000000000-example.apps.googleusercontent.com
```

El valor del ejemplo es deliberadamente ficticio. Sin `GOOGLE_WEB_CLIENT_ID` el
botón permanece visible pero deshabilitado y explica la configuración faltante.

## Recuperación de contraseña

El backend debe tener SMTP configurado para entregar el token. El enlace móvil
predeterminado `kairo://app/recuperar-acceso` abre la ruta protegida por token;
la pantalla también permite pegarlo manualmente. La app nunca guarda ni envía el
campo de confirmación de contraseña.

Para depuración en dispositivo físico con backend local:
```powershell
adb -s <device-id> reverse tcp:8000 tcp:8000
flutter run -d <device-id> --dart-define=USE_RENDER=false --dart-define=USE_LOCAL=true
```

## Ubicación GPS y Selección de Direcciones (KAIRO Delivery)

El sistema de ubicación y selección de direcciones (`features/location_delivery`) ofrece una experiencia interactiva tipo Rappi/PedidosYa:

1. **Permisos de Android:**
   - Requiere `ACCESS_FINE_LOCATION` y `ACCESS_COARSE_LOCATION` declarados en `AndroidManifest.xml`.
   - Maneja los estados de permisos (`denied`, `deniedForever`, `unableToDetermine`) y disponibilidad del servicio GPS con fallback transparente a la sede KAIRO en Tarapoto.
2. **Mapa Interactivo con Mapbox Standard:**
   - Basado en `mapbox_maps_flutter`, con perfiles vectoriales claro/oscuro y
     Standard Satellite. Configura el token público en compilación con
     `--dart-define=MAPBOX_ACCESS_TOKEN=pk...`; no guardes tokens secretos en el
     repositorio.
   - La cuenta de Mapbox debe disponer de cuota de teselas. Ante una respuesta
     `429 Too Many Requests`, la app conserva la cámara y vuelve al mapa
     vectorial con un aviso contextual hasta que se restablezca la cuota.
   - Marcador central animado (efecto rebote/elevación al arrastrar el mapa) que sincroniza en tiempo real la latitud/longitud del centro.
   - Botón de auto-ubicación ("Mi Ubicación Actual") con animación suave de centrado.
   - Búsqueda en vivo de direcciones y geocodificación inversa con debounce para no saturar peticiones.
3. **Múltiples Direcciones Guardadas:**
   - Etiquetas rápidas: `Casa`, `Trabajo` y `Otro`.
   - Campos de calle/número, departamento/interior, referencias y selector de dirección predeterminada.
   - Persistencia local inmediata y sincronización REST con el backend para usuarios autenticados.
4. **Flujo de Usuario Integrado:**
   - **Inicio (`HomePage`):** Barra superior de entrega (`HomeDeliveryBar`) que muestra la dirección activa y el costo de delivery evaluado, permitiendo cambiarla con un toque mediante un modal `AddressSelectorModal`.
   - **Checkout (`DeliveryDetailsPage`):** Al elegir "Envío a Domicilio", la dirección predeterminada se precarga automáticamente y permite cambiar o registrar una nueva antes de enviar la orden.
   - **Perfil (`AddressesPage`):** Gestión de direcciones guardadas con acceso directo al mapa interactivo.
