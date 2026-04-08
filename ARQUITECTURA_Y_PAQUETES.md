# Arquitectura y estructura de paquetes

## Arquitectura usada

La app usa una arquitectura **MVVM** con separación por capas y por features.

Flujo principal:

- **View (UI)**: renderiza la interfaz y captura interacciones del usuario.
- **ViewModel**: maneja estado y lógica de presentación.
- **Repository**: centraliza el acceso a datos para la UI.
- **Service**: realiza llamadas externas (HTTP, conectividad, etc.).

En términos de flujo:

`View → ViewModel → Repository → Service`

Además, en `main.dart` se configura la inyección de dependencias con `Provider` / `ChangeNotifierProvider` para servicios, repositorios y viewmodels.

## Estructura de paquetes

Estructura principal en `lib/`:

- `ui/`: capa de presentación, organizada por feature.
  - Ejemplos: `login`, `signup`, `home`, `create_listing`, `listing-detail`, `map_listing`, `connectivity`, `router`.
- `data/`: capa de datos.
  - `services/`: acceso a APIs y servicios externos.
  - `repositories/`: abstracción y orquestación de datos para la UI.
  - `dtos/`: objetos de transferencia para requests/responses.
  - `domains/`: modelos de dominio usados en flujos de negocio.
  - `storage/`: persistencia local (por ejemplo, token storage).
- `models/`: modelos compartidos por diferentes módulos.

Esta estructura combina:

- **organización por capas** (ui/data/models), y
- **organización por feature** dentro de `ui/`.

## Feature de mapas

Hay dos usos claros de mapas:

### 1) Seleccionar ubicación al crear un listing

En `ui/create_listing/widgets/listing_location_section.dart`:

- Se abre un `Dialog` con `GoogleMap`.
- El usuario toca el mapa para elegir coordenadas.
- Al confirmar, se actualiza el `CreateListingViewModel` con `updateLocationFromCoordinates(latitude, longitude)`.
- La ubicación se guarda como string en formato `"lat,lng"` con 6 decimales.

### 2) Ver ubicación de un listing

En `ui/map_listing/`:

- `MapListingViewModel` carga el listing por id desde `ListingRepository`.
- Parsea `listing.location` separando por coma para obtener latitud y longitud.
- `MapListingView` muestra un `GoogleMap` centrado en ese punto y agrega un `Marker`.
- Se presenta una tarjeta (`MapListingPreviewCard`) con resumen del listing y navegación al detalle.

## Feature de cámara en Create Listing

En `ui/create_listing/widgets/listing_image_picker_section.dart` y `create_listing_viewmodel.dart`:

- El usuario abre un bottom sheet con dos opciones:
  - **Take Photo** (cámara)
  - **Choose from Gallery** (galería)
- Para cámara, el ViewModel usa `image_picker` con `ImageSource.camera` en `pickImageFromCamera()`.
- Las imágenes seleccionadas se guardan en `selectedImages`.
- Hay límite de `maxImages = 5`.
- Se permite eliminar imágenes antes de enviar el formulario.

Con esto, la creación de un listing integra captura de evidencia visual (cámara/galería) y ubicación geográfica (mapa), ambas gestionadas desde el ViewModel de la feature.
