# 🛒 Uniandes Marketplace App

## 📌 Architecture Overview

This project follows Flutter’s recommended architecture based on the **MVVM (Model–View–ViewModel)** pattern.

According to Flutter:

* **UI Layer → Views + ViewModels**
* **Data Layer → Repositories + Services** ([Flutter Documentation][1])

Each feature in the app is structured as:

```text
1 Feature = 1 View + 1 ViewModel
```

Flutter explicitly states that:

> “Each feature… contains one view and one view model” ([Flutter Documentation][1])

---

## 🧠 Project Structure

```text
lib/
  ui/
    router/
      app_router.dart

    auth/
      login_view.dart
      login_viewmodel.dart
      signup_view.dart
      signup_viewmodel.dart

    home/
      home_view.dart
      home_viewmodel.dart

    search/
      search_view.dart
      search_viewmodel.dart

    product/
      product_detail_view.dart
      product_viewmodel.dart

    create_listing/
      create_listing_view.dart
      create_listing_viewmodel.dart

    profile/
      profile_view.dart
      profile_viewmodel.dart

    map/
      map_view.dart
      map_viewmodel.dart

  data/
    repositories/
    services/

  models/
```

---

## 🧩 Feature-Based Organization (CORE IDEA)

The UI layer is organized **by feature**, not by file type.

A **feature** represents a complete user functionality, such as:

* Authentication
* Search
* Product detail
* Create listing
* Map

Each feature contains:

```text
View (UI) + ViewModel (state + logic)
```

This follows Flutter’s recommendation that:

* A view interacts with exactly one view model
* A view model belongs to exactly one feature ([Flutter Documentation][2])

---

## 🔄 Data Flow

```text
View → ViewModel → Repository → Service
```

* **View** → displays UI and sends user actions
* **ViewModel** → manages state and logic
* **Repository** → source of truth for data
* **Service** → external APIs (Firebase, HTTP, etc.)

---

## 🧭 Navigation

Navigation is centralized in:

```text
ui/router/app_router.dart
```

Responsibilities:

* Define all app routes
* Control navigation flow
* Keep navigation logic separate from UI

---

## 🧱 Layers Explained

### 🎨 UI Layer (`ui/`)

* Organized by **feature**
* Contains:

  * Views (UI)
  * ViewModels (logic + state)
  * Router (navigation)

---

### 📦 Data Layer (`data/`)

Flutter defines repositories and services as the **data layer (Model in MVVM)** ([Flutter Documentation][1])

#### Repositories

* Single source of truth
* Transform data for the app
* Used by ViewModels

#### Services

* External communication (API, Firebase, sensors)
* Stateless
* Used by repositories

---

### 🧱 Models (`models/`)

* Data structures (Product, User, Message)
* Can include DTOs
* Used across layers

⚠️ Important:

```text
models/ ≠ Model layer
```

The **Model layer in MVVM = data layer (repositories + services)**

---

## 🔥 Key Principles

* Separation of concerns
* UI = function of state
* One View ↔ One ViewModel
* Feature-based organization
* Unidirectional data flow

---

## 🧠 Final Insight

> Architecture is defined by how components interact, not by folder names.

---

## 📚 References

* Flutter App Architecture Guide ([Flutter Documentation][1])
* Flutter Case Study ([Flutter Documentation][3])

[1]: https://docs.flutter.dev/app-architecture/guide?utm_source=chatgpt.com "Guide to app architecture"
[2]: https://docs.flutter.dev/app-architecture/case-study/dependency-injection?utm_source=chatgpt.com "Communicating between layers"
[3]: https://docs.flutter.dev/app-architecture/case-study?utm_source=chatgpt.com "Architecture case study"
