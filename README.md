# True Liability Tracker (Mobile)

A premium, high-performance Flutter application for tracking automated credit card liabilities and manual spending. Built with an **Obsidian Sanctuary** dark-mode design system.

## 🚀 Key Features

- **Obsidian Sanctuary UI**: A custom, high-contrast dark theme using emerald green accents and glassmorphism.
- **Supabase Native Auth**: Securely authenticates users via Supabase GoTrue.
- **Live Sync**: Real-time transaction fetching from the Golang backend using Riverpod state management.
- **True Liability Logic**: Automatically calculates actual debt by filtering for `PENDING` transactions across all linked accounts.

## 🛠 Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: `flutter_riverpod`
- **Backend Communication**: REST API via `http` (targeting `localhost:8080`)
- **Authentication**: `supabase_flutter`

## 🏗 Architecture (Clean Architecture)

- **`lib/core/`**: Shared themes, colors, and network clients (`ApiClient`).
- **`lib/data/`**: JSON models and API repositories.
- **`lib/domain/`**: Business logic and Riverpod providers.
- **`lib/presentation/`**: Pixel-perfect UI layers (Dashboard, Auth).

## 🚦 Getting Started

### 1. Backend Setup
Ensure the **Keuangan Backend** (Golang) is running on port `8080`.
```bash
go run ./cmd/server/main.go
```

### 2. Emulator Connectivity
If running on an **Android Emulator**, the API client is configured to use `10.0.2.2:8080` to reach your host machine's localhost.

### 3. Run the App
```bash
flutter pub get
flutter run
```

---

*Note: This application requires a valid Supabase project with transactional liability tables initialized.*
