# Análisis detallado de patrones y estilos de arquitectura

Repositorio analizado: `Moviles-ISIS3510-S4-G44/Flutter-app`  
Fecha: 2026-04-09

---

## 1) Resumen ejecutivo (qué sí está y qué no)

| Patrón / Estilo | Estado en este código | Observación breve |
|---|---|---|
| Strategy | **Parcial / implícito** | Hay decisiones por condición (no una jerarquía formal de estrategias). |
| Facade | **Sí (parcial)** | Repositories simplifican y unifican acceso a Services para la UI. |
| MVVM | **Sí, principal** | Es la arquitectura central declarada y aplicada. |
| MVP | **No** | No hay Presenter como capa separada. |
| Web Service Broker / Service Adapter | **Sí** | Services encapsulan HTTP y adaptan endpoints externos. |
| MVC | **No** | No hay Controller clásico; se usa ViewModel. |
| Observer | **Sí** | `ChangeNotifier`, `notifyListeners`, `context.watch`, `Stream`. |
| DAO | **Parcial / cercano** | `Repository` y `TokenStorage` cumplen parte del rol de acceso a datos, pero no DAO formal con DB relacional. |
| Bridge | **No evidente** | No hay abstracción/implementación desacoplada en jerarquías separadas tipo Bridge clásico. |
| Singleton | **Parcial** | Instancias únicas compartidas por Provider y miembros `static` globales (no singleton clásico con constructor privado). |
| Builder | **No como patrón GoF** | Hay uso de *builders* de Flutter (`AnimatedBuilder`) pero no objeto Builder de dominio. |
| Factory / Abstract Factory | **Factory simple (sí, parcial)** | Constructors `factory ...fromJson` en DTOs. No Abstract Factory formal. |
| MVC-WEB | **No aplica directamente** | Es app Flutter cliente; no hay capa web MVC de servidor en este repo. |
| Application Service | **Sí (parcial)** | Services coordinan casos de uso técnicos de integración externa. |
| Repository (Android) | **Sí** | Repositories como fuente intermedia de datos para ViewModels. |
| VO / DTO / TO | **Sí (DTO muy claro; VO parcial)** | DTOs para transporte externo y modelos inmutables de valor en dominio/UI. |
| Interpreter | **No** | No hay parser de lenguaje/reglas con AST o gramática interna. |
| Decorator | **No formal** | Hay composición de widgets, pero no decoradores con misma interfaz envolviendo comportamiento de objetos de dominio. |

---

## 2) Arquitectura base real del proyecto

La arquitectura dominante es **MVVM con capa de datos Repository + Service**, documentada explícitamente y visible en implementación.

### Evidencia directa en documentación
- MVVM declarado: `README.md:5`
- Data layer = repositories + services: `README.md:10`, `README.md:153`, `README.md:181`
- Flujo declarado: `View → ViewModel → Repository → Service` en `README.md:112`

### Evidencia directa en composición de dependencias
- Registro de servicios/repositorios/viewmodels con Provider en `lib/main.dart:37-95`
- Inyección de `AuthRepository`, `ListingRepository`, `InteractionRepository` y ViewModels en `lib/main.dart:52-94`

### Flujo real observado (ejemplo)
1. Vista (`LoginView`) invoca acción de ViewModel (`login`) → `lib/ui/login/login_view.dart:299-305`
2. ViewModel delega en Repository → `lib/ui/login/login_viewmodel.dart:32-35`
3. Repository delega en Service HTTP → `lib/data/repositories/auth_repository.dart:34-37`
4. Service consume API externa → `lib/data/services/auth_service.dart:64-75`

---

## 3) Análisis patrón por patrón

## 3.1 Strategy

### Evaluación
**Parcial / implícito**, no implementado como Strategy formal de GoF.

### Qué hay en el código
- Lógica de variación por condicionales, por ejemplo:
  - Navegación por índice en `HomeView._onNavTap` (`lib/ui/home/home_view.dart:16-24`)
  - Selección de condición del producto como estado (`lib/ui/create_listing/create_listing_viewmodel.dart:29-31`, `75-78`)

### Qué faltaría para Strategy formal
- Interfaz de estrategia (ej. `SearchStrategy`, `PricingStrategy`, `NavigationStrategy`)
- Implementaciones intercambiables concretas
- Contexto que reciba una estrategia por composición

---

## 3.2 Facade

### Evaluación
**Sí, parcialmente aplicado** a través de repositorios.

### Dónde se ve
Los repositorios exponen una API más simple para la UI/ViewModel, ocultando detalles de transporte, DTOs y múltiples llamadas:
- `AuthRepository` simplifica login/signup/sesión: `lib/data/repositories/auth_repository.dart:13-93`
- `ListingRepository` simplifica lectura/creación/listing by id: `lib/data/repositories/listing_repository.dart:13-52`
- `InteractionRepository` combina perfil actual + llamadas de interacción: `lib/data/repositories/interaction_repository.dart:14-33`

Esto funciona como una **fachada de la capa de datos** para la capa de presentación.

---

## 3.3 MVVM

### Evaluación
**Sí, claramente implementado y dominante.**

### Evidencia por capas
- **View**: `login_view.dart`, `home_view.dart`, `create_listing_view.dart`, `listing_detail_view.dart`, etc.
- **ViewModel**: clases `...ViewModel extends ChangeNotifier`:
  - `lib/ui/login/login_viewmodel.dart:6`
  - `lib/ui/home/home_viewmodel.dart:8`
  - `lib/ui/signup/signup_viewmodel.dart:4`
  - `lib/ui/create_listing/create_listing_viewmodel.dart:11`
  - `lib/ui/listing-detail/listing_detail_viewmodel.dart:7`
  - `lib/ui/map_listing/map_listing_viewmodel.dart:5`
- **Model/Data**: Repositories + Services + DTOs (`lib/data/**`)

### Evidencia de interacción View ↔ ViewModel
- Observación reactiva: `context.watch<ViewModel>()`:
  - `lib/ui/login/login_view.dart:130`
  - `lib/ui/home/home_view.dart:136`
- Mutación de estado + notificación:
  - `notifyListeners()` en múltiples ViewModels, por ejemplo `lib/ui/home/home_viewmodel.dart:41`, `72`, `98`

---

## 3.4 MVP

### Evaluación
**No presente.**

### Motivo
No existe capa `Presenter`; la lógica de presentación está en `ViewModel` con `ChangeNotifier`, que es MVVM, no MVP.

---

## 3.5 Web Service Broker / Service Adapter

### Evaluación
**Sí, presente.**

### Dónde se ve
Servicios que encapsulan HTTP, endpoints, serialización y errores:
- `AuthService` (`/auth/signup`, `/auth/login`, `/auth/me`): `lib/data/services/auth_service.dart:16-122`
- `ListingApiService` (`/listings`, `/listings/{id}`): `lib/data/services/listing_api_service.dart:13-68`
- `CategoryApiService` (`/categories`): `lib/data/services/category_api_service.dart:12-30`
- `InteractionService` (`/interactions`, `/interactions/users/{id}/top`): `lib/data/services/interaction_service.dart:12-59`

Estos servicios adaptan la API externa al contrato interno consumible por repositorios.

---

## 3.6 MVC

### Evaluación
**No presente como estilo principal.**

### Motivo
No hay controladores tipo MVC. La lógica de interacción está en ViewModels y Repositories.

---

## 3.7 Observer

### Evaluación
**Sí, fuertemente presente.**

### Evidencia (UI reactiva)
- `ChangeNotifier` en modelos de estado y viewmodels:
  - `lib/ui/connectivity/connectivity_model.dart:5`
  - `lib/ui/home/home_viewmodel.dart:8`
  - `lib/ui/login/login_viewmodel.dart:6`
- Emisión de cambios con `notifyListeners()` en toda la capa UI/ViewModel
- Suscripción desde vistas con `context.watch<...>()`:
  - `lib/ui/home/home_view.dart:29`, `136`
  - `lib/ui/login/login_view.dart:129-130`
- Uso de `AnimatedBuilder` con ViewModels como `Listenable`:
  - `lib/ui/listing-detail/listing_detail_view.dart:50-53`
  - `lib/ui/map_listing/map_listing_view.dart:42-45`

### Evidencia (streams)
- `ConnectivityService` usa `StreamController.broadcast` + listeners:
  - `lib/data/services/connectivity_service.dart:8-15`, `20-24`

---

## 3.8 DAO

### Evaluación
**Parcial / aproximación.**

### Qué hay
- `TokenStorage` encapsula acceso a almacenamiento seguro local:
  - `lib/data/storage/auth_token_storage.dart:3-20`
- Repositories encapsulan acceso a datos remotos:
  - `lib/data/repositories/*.dart`

### Qué falta para DAO clásico
- DAO típicamente orientado a persistencia estructurada (SQL/ORM) con interfaces dedicadas por entidad.
- Aquí predomina acceso HTTP + secure storage puntual, no capa DAO formal separada.

---

## 3.9 Bridge

### Evaluación
**No evidente.**

### Motivo
No se observan dos jerarquías desacopladas (abstracción e implementación) unidas por composición al estilo Bridge GoF.

---

## 3.10 Singleton

### Evaluación
**Parcial.**

### Evidencia de comportamiento “single instance” sin patrón clásico completo
- Router global estático:
  - `AppRouter.router` en `lib/ui/router/app_router.dart:11`
- Config global por acceso estático:
  - `AppConfig.apiBaseUrl` en `lib/config/app_config.dart:4`
- Instancias compartidas mediante árbol de Providers en `lib/main.dart:37-95`

### Nota
No hay constructor privado + instancia estática interna típica de Singleton GoF.

---

## 3.11 Builder

### Evaluación
**No como patrón de construcción de objetos de dominio.**

### Lo que sí existe
- `AnimatedBuilder` (widget de Flutter), por ejemplo:
  - `lib/ui/listing-detail/listing_detail_view.dart:50`
  - `lib/ui/map_listing/map_listing_view.dart:42`

Esto es un componente del framework, no una implementación propia de Builder GoF.

---

## 3.12 Factory / Abstract Factory

### Evaluación
**Factory simple sí (en DTOs); Abstract Factory no.**

### Evidencia de Factory (constructores fábrica)
- `factory ListingDto.fromJson(...)` en `lib/data/dtos/listings/listing_dto.dart:26`
- `factory CategoryDto.fromJson(...)` en `lib/data/dtos/categories/category_dto.dart:10`
- `factory InteractionDto.fromJson(...)` en `lib/data/dtos/interactions/interaction_dto.dart:16`
- `factory TokenDto.fromJson(...)` en `lib/data/dtos/auth/token_dto.dart:10`
- `factory UserDto.fromJson(...)` en `lib/data/dtos/auth/user_dto.dart:14`

### Abstract Factory
No hay familias de fábricas abstractas para crear objetos relacionados por variante.

---

## 3.13 MVC-WEB

### Evaluación
**No presente en este repositorio cliente Flutter.**

### Motivo
No se observa un backend web MVC (controllers/server-side views/models) dentro de este repo.

---

## 3.14 Application Service

### Evaluación
**Sí, parcialmente** en la capa `services/`.

### Dónde se ve
Servicios que concentran operaciones técnicas de aplicación para integraciones externas:
- `AuthService`: login/signup/me + manejo de códigos HTTP y timeouts (`lib/data/services/auth_service.dart:16-122`)
- `InteractionService`: registrar interacción y top interacciones (`lib/data/services/interaction_service.dart:12-59`)

### Nota
En DDD estricto, “Application Service” suele orquestar casos de uso de negocio. Aquí la capa se usa sobre todo como integración técnica HTTP.

---

## 3.15 Repository (Android)

### Evaluación
**Sí, claramente presente.**

### Evidencia
- Repositories en `lib/data/repositories/`:
  - `auth_repository.dart`
  - `listing_repository.dart`
  - `category_repository.dart`
  - `interaction_repository.dart`
- Consumidos por ViewModels inyectados desde `main.dart` (`lib/main.dart:52-94`)
- Transforman DTOs a modelos usados por UI:
  - `ListingRepository._toListingSummary` y `_toListingDetail` en `lib/data/repositories/listing_repository.dart:24-48`

---

## 3.16 VO / DTO / TO

### Evaluación
**DTO: sí muy claro. VO: parcial.**

### DTO/TO (muy claro)
- `ListingDto`, `CategoryDto`, `InteractionDto`, `UserDto`, `TokenDto` bajo `lib/data/dtos/**`
- Request DTO: `CreateListingRequest` (`lib/data/dtos/listings/create_listing_request.dart:1-37`)

### VO (parcial)
Modelos inmutables usados como valores de dominio/UI:
- `ListingDetail` (`lib/models/listings/listing_detail.dart:1-24`)
- `AppUser` (dominio auth, archivo `lib/data/domains/auth/app_user.dart`)

No se observan validaciones de invariantes ricas típicas de VO “fuerte” (ej. clases dedicadas Email, Money, Location).

---

## 3.17 Interpreter

### Evaluación
**No presente.**

### Motivo
No hay motor de interpretación de expresiones/lenguaje propio con gramática/AST.

---

## 3.18 Decorator

### Evaluación
**No formalmente presente.**

### Motivo
Aunque Flutter usa composición de widgets, no se observan decoradores de objetos de dominio/servicios con misma interfaz para añadir comportamiento de forma transparente (patrón Decorator clásico).

---

## 4) Hallazgos transversales de estilo arquitectónico

## 4.1 Inyección de dependencias
- Se implementa con `Provider`/`ChangeNotifierProvider` en un punto central (`lib/main.dart:37-95`).
- Esto mejora testabilidad y separación de responsabilidades.

## 4.2 Separación por capas y por feature
- UI organizada por feature (`lib/ui/home`, `lib/ui/login`, `lib/ui/create_listing`, etc.).
- Data separada en `services`, `repositories`, `dtos`, `storage`.

## 4.3 Transformación explícita de datos
- Conversión DTO → modelo interno en repositorios (`ListingRepository`), reduciendo acoplamiento de UI al formato API.

## 4.4 Reactividad y estado
- Estado observable basado en `ChangeNotifier` y escucha en la vista mediante Provider.
- Patrón consistente en casi todos los módulos de UI.

---

## 5) Conclusión global

La app implementa de forma sólida una arquitectura **MVVM + Repository + Service**, con uso fuerte de **Observer** y **DTO Factory constructors**.  
De los patrones de clase listados, los más claramente presentes son:

1. **MVVM**
2. **Observer**
3. **Repository**
4. **Web Service Adapter/Broker**
5. **Factory (simple, en DTOs)**
6. **VO/DTO (principalmente DTO)**
7. **Facade (parcial, vía repositorios)**

Los demás (MVP, MVC, Bridge, Interpreter, Decorator formal, Abstract Factory, MVC-WEB) **no aparecen de forma explícita** en este código actual.

