# 🛒 Uniandes Marketplace App

## 📌 Project Architecture

This project follows the **official Flutter app architecture guidelines**, based on the **MVVM (Model–View–ViewModel)** pattern and layered separation.

According to Flutter documentation, an application should be divided into:

* **UI Layer (Views + ViewModels)**
* **Data Layer (Repositories + Services)** ([Flutter Documentation][1])

The main goal of this architecture is to enforce:

> **Separation of concerns** and maintainability ([Flutter Documentation][2])

---

## 🧠 Project Structure

```text
lib/
  main.dart

  ui/
    home/
      home_view.dart
      home_viewmodel.dart

    search/
      search_view.dart
      search_viewmodel.dart

    product/
      product_detail_view.dart
      product_viewmodel.dart

    chat/
      chat_view.dart
      chat_viewmodel.dart

    profile/
      profile_view.dart
      profile_viewmodel.dart

  data/
    repositories/
      product_repository.dart
      user_repository.dart
      chat_repository.dart

    services/
      api_service.dart
      firebase_service.dart

  models/
    product.dart
    user.dart
    message.dart
```

---

## 🔄 Data Flow

The application follows this architecture flow:

```text
View → ViewModel → Repository → Service
```

* **Views** never access data directly
* **ViewModels** handle UI state and logic
* **Repositories** act as the single source of truth
* **Services** communicate with external APIs

---

## 🧩 Layers and Responsibilities

### 🎨 Views (UI Layer)

* Represent the UI using Flutter widgets
* Display data provided by the ViewModel
* Forward user interactions to the ViewModel
* Contain minimal logic (only UI-related)

Each View is typically a screen or feature.

---

### 🧠 ViewModels

* Manage UI state
* Contain business and presentation logic
* Fetch data from repositories
* Expose actions (commands) to the UI
* Notify the UI using `ChangeNotifier`

Flutter recommends a **one-to-one relationship between View and ViewModel** ([Flutter Documentation][1])

---

### 📦 Repositories (Data Layer)

* Provide access to application data
* Act as the **single source of truth**
* Abstract data sources (API, local storage, etc.)
* Can be reused across multiple ViewModels

---

### 🌐 Services

* Handle external communication
* Call APIs or Firebase
* Do not manage state
* Are used by repositories

---

### 🧱 Models

* Represent data structures
* Are independent from UI
* Used across all layers

---

## 🔥 Key Principles

### 1. UI = Function of State

The UI reacts automatically to state changes.

---

### 2. Separation of Concerns

Each layer has a clearly defined role:

```text
View → UI
ViewModel → Logic & State
Repository → Data
Service → External APIs
```

---

### 3. Single Source of Truth

Repositories centralize application data, ensuring consistency.

---

### 4. One View per ViewModel

Each feature or screen is composed of:

```text
1 View + 1 ViewModel
```

---

### 5. Dependency Flow

Each layer only depends on the layer below:

```text
View → ViewModel → Repository → Service
```

This ensures loose coupling and scalability ([Flutter Documentation][3])

---

## ⚙️ State Management

This project uses:

👉 **Provider + ChangeNotifier**

Because:

* It integrates naturally with Flutter's MVVM approach
* It allows reactive UI updates
* It is recommended for medium-scale applications

---

## 🚫 Anti-Patterns (Avoid)

* Calling APIs directly from Views
* Placing business logic inside Widgets
* Overusing `setState` for global state
* Skipping repositories and accessing services directly

---

## 🎯 Goals of This Architecture

* Scalability
* Maintainability
* Testability
* Clear separation of responsibilities

---

## 🧠 Final Insight

> The UI should only reflect state — never manage it.

---

## 🚀 Future Improvements

* Backend integration (Firebase / REST API)
* Repository caching strategies
* Error handling and loading states
* Unit testing for ViewModels

---

## 📚 References

* Flutter App Architecture Guide ([Flutter Documentation][1])
* Flutter Architecture Recommendations ([Flutter Documentation][4])
* Flutter Case Study (Compass App) ([Flutter Documentation][5])

---

[1]: https://docs.flutter.dev/app-architecture/guide?utm_source=chatgpt.com "Guide to app architecture"
[2]: https://docs.flutter.dev/app-architecture?utm_source=chatgpt.com "Architecting Flutter apps"
[3]: https://docs.flutter.dev/app-architecture/case-study/dependency-injection?utm_source=chatgpt.com "Communicating between layers"
[4]: https://docs.flutter.dev/app-architecture/recommendations?utm_source=chatgpt.com "Architecture recommendations and resources"
[5]: https://docs.flutter.dev/app-architecture/case-study?utm_source=chatgpt.com "Architecture case study"
