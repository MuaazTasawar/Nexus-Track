# 💹 Nexus Track – Professional Expense & Financial Management

**Nexus Track** is a scalable, production-ready financial management application built using **Flutter (Dart 3.x)**.  
It enables users to track expenses, manage budgets, monitor subscriptions, and split shared expenses—all within a modern **cyber-dark fintech UI**.

The project follows a **layered architecture** that cleanly separates UI, business logic, and data models, making it easy to maintain, test, and extend.

---

## 🎯 Project Vision

Nexus Track is designed to:

- 📊 Provide **complete financial visibility**
- ⚡ Deliver a **fast, intuitive user experience**
- 🔐 Enforce **secure authentication & session handling**
- 🧩 Maintain a **modular, scalable architecture**
- 🎨 Offer a **modern fintech-grade UI**

---

## 📱 Application Overview

The app consists of two primary modules:

1. **Authentication Module**
2. **Dashboard Module (Main Application Hub)**

---

## 🔐 Authentication Module

**Location:** `lib/pages/auth/`

Handles user identity and access control.

### 🔑 Login (`login_page.dart`)
- Email & password authentication
- Password visibility toggle
- Forgot password flow hook
- Navigation to sign-up
- Validation-ready form structure

### 📝 Sign Up (`signup_page.dart`)
- Email, password, confirm password fields
- Real-time validation support
- Password masking by default
- Consistent UX with login screen

> 🔒 Authentication logic is abstracted into the service layer for security and maintainability.

---

## 🧭 Dashboard Module

**Location:** `lib/pages/dashboard/`

This is the core of the application after login.

### 🧱 Dashboard Scaffold (`dashboard_page.dart`)
- Persistent **TabBar navigation**
- Central **Floating Action Button (FAB)**
- Global logout action
- Smooth tab switching (no page reloads)

---

## 📑 Dashboard Tabs

Each tab represents a dedicated financial domain.

### 📑 Transactions (`transaction_tab.dart`)
- Core income & expense ledger
- Chronological transaction history
- Empty state for first-time users
- Designed for future filtering & analytics

---

### 📊 Budgeting (`budget_tab.dart`)
- Monthly or category-based budgets
- Tracks spending vs limits
- Ready for progress indicators & alerts
- Encourages proactive spending control

---

### 🎬 Subscriptions (`subscription_tab.dart`)
- Tracks recurring services (Netflix, Spotify, etc.)
- Billing cycle awareness
- Prevents forgotten recurring charges

---

### 👥 Shared Expenses (`shared_expense_tab.dart`)
- Split expenses among multiple users
- Ideal for roommates or group trips
- Tracks balances and settlements

---

### 💳 Payment Methods (`payment_method_tab.dart`)
- Manage cash, cards, banks, and wallets
- Enables spending insights by account
- Decoupled from transaction logic

---

## 🧠 Data Models

**Location:** `lib/models/`

| Model | Description |
|------|------------|
| `transaction.dart` | Income & expense records |
| `budget.dart` | Spending limits & tracking |
| `subscription.dart` | Recurring billing logic |
| `shared_expense.dart` | Split calculations |
| `payment_method.dart` | Account & wallet definitions |

> Models are UI-agnostic and optimized for API serialization.

---

## ⚙️ Service Layer

**Location:** `lib/services/`

### 🔌 API Service (`api_service.dart`)
- Centralized REST client
- Backend communication abstraction
- Environment-ready (local/staging/prod)

### 👤 User Service (`user_service.dart`)
- Manages authentication state
- Handles user session lifecycle
- Supports global logout & access guards

---

## 🎨 UI & UX Philosophy

- 🌌 Cyber-dark theme (deep charcoal)
- 💚 Neon mint accents
- 📐 Clean layouts & strong hierarchy
- 🧭 Helpful empty states & CTAs
- ⚡ Optimized for performance

Designed to feel **modern, premium, and fintech-grade**.

---

## 🏗 Project Structure

```text
lib/
├── models/
│   ├── budget.dart
│   ├── payment_method.dart
│   ├── shared_expense.dart
│   ├── subscription.dart
│   └── transaction.dart
│
├── pages/
│   ├── auth/
│   │   ├── login_page.dart
│   │   └── signup_page.dart
│   └── dashboard/
│       ├── dashboard_page.dart
│       ├── transaction_tab.dart
│       ├── budget_tab.dart
│       ├── subscription_tab.dart
│       ├── shared_expense_tab.dart
│       └── payment_method_tab.dart
│
├── services/
│   ├── api_service.dart
│   └── user_service.dart
│
└── main.dart
```
---
## 🚀 Getting Started

### 1️⃣ Clone the Repository
```bash
git clone https://github.com/YourRepo/NexusTrack.git
cd NexusTrack
flutter pub get
```
### 2️⃣ Configure Backend
Update **api_service.dart** with your backend endpoint (local, staging, or production).
### 3️⃣ Run the App
```bash
flutter run --release
```
---
## 🔮 Planned Enhancements
- 📈 Charts & analytics dashboards 
- ☁️ Cloud sync & offline-first storage 
- 🔔 Subscription renewal notifications 
- 🌍 Multi-currency support 
- 📊 Advanced spending insights
---
## 📄 License
**Licensed under the MIT License.**