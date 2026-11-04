# Architecture Decision Record (ADR-001)

## Subject: Hybrid State Management Strategy in LearnHub

### Status: Accepted & Implemented

---

### Context
LearnHub is an educational application combining enterprise-grade Clean Architecture business rules with high-performance, pragmatic UI reactivity. During architectural planning, two state management methodologies were evaluated:
1. **BLoC (Business Logic Component)** via `flutter_bloc`
2. **Provider** via `provider` (`ChangeNotifier`)

### Decision: Clear Feature-Level Separation

Rather than forcing a single paradigm across disparate problem spaces, LearnHub explicitly designates state-management responsibilities by architectural layer:

| Domain / Layer | Technology | Primary Classes | Justification |
| :--- | :--- | :--- | :--- |
| **Authentication & Security** | **BLoC** (`flutter_bloc`) | `AuthBloc`, `AuthEvent`, `AuthState`, `UseCases` | Follows strict Clean Architecture. Emits predictable, immutable states (`AuthLoading`, `Authenticated`, `Unauthenticated`, `AuthError`). Easily tested with `bloc_test`. |
| **Books Catalog & API** | **Provider** (`provider`) | `BooksProvider`, `BookModel` | Fast, reactive updates for search queries, topic filtering, and asynchronous REST Open Library responses. |
| **Favorites & Persistence** | **Provider** (`provider`) | `FavoritesProvider`, `StorageService` | Seamless cross-widget synchronization between local on-device `SharedPreferences` and Cloud Firestore collections. |
| **Application Theming & Settings** | **Provider** (`provider`) | `SettingsProvider` | Directly drives `MaterialApp.router`'s `themeMode` and settings drawer switches without ceremony. |
| **Notifications & Scheduling** | **Provider** (`provider`) | `NotificationProvider`, `NotificationService` | Reactive state for Android notification channels, time-picker models, and instant alert logs. |

---

### Communication & Data Flow

```
+--------------------------------------------------------------+
|                     PRESENTATION LAYER                       |
|                                                              |
|   [ Login / Register / Splash ]   [ Home / Details / Favs ]  |
|                 |                             |              |
|          BlocBuilder / Consumer        Consumer / Provider   |
+-----------------|-----------------------------|--------------+
                  v                             v
+-----------------------------+   +----------------------------+
|         AuthBloc            |   |       Feature Providers    |
| (Clean Architecture Domain) |   | (Books, Favs, Settings)    |
|  - SignInUseCase            |   |  - SharedPreferences      |
|  - SignUpUseCase            |   |  - Open Library REST API   |
|  - SignOutUseCase           |   |  - Firestore Collections   |
+-----------------------------+   +----------------------------+
```

### Consequences & Benefits
- **Separation of Concerns**: Critical authentication flows cannot inadvertently mutate UI states.
- **Testability**: `AuthBloc` is tested with isolated event-state streams, while providers are tested with targeted unit assertions.
- **Maintainability**: Developers immediately know where to place logic based on whether it is enterprise authentication (BLoC) or feature/view state (Provider).

