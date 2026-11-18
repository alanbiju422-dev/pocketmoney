# Pocket Money Tracker

A simple, personal pocket money and daily expense tracking app built with Flutter. Designed with a clean editorial interface to help manage daily allowances, track spending by category, and visualize finances with interactive reports.

## Features

- **Google Sign-In:** Authentication powered by Supabase with Google OAuth.
- **Add & Spend Money:** Easily record income and log expenses across categories (Travel, Food, College, and Other).
- **Transaction History:** Searchable and filterable list of past transactions.
- **Safe Deletion with Undo:** Two-step confirmation with a 5-second countdown to quickly undo accidental deletions.
- **Reports & Visual Charts:** Daily, weekly, monthly, yearly, and custom date range breakdowns powered by `fl_chart`.
- **Themes & Profile:** Light, dark, and system themes, with editable display name stored in Supabase user metadata.

## Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **Authentication:** Supabase Auth (Google OAuth with PKCE flow)
- **Charts:** fl_chart
- **Fonts & Styling:** google_fonts (Lora & Source Sans 3)
- **Formatting & Helpers:** intl (currency and date helpers), path_provider

## Project Architecture

```
lib/
├── config/         # App and Supabase configuration
├── models/         # User and Transaction data models
├── providers/      # State management (Auth, Theme, Transactions)
├── repositories/   # Abstract repository contracts and data sources
├── screens/        # UI screens (Home, History, Spend, Reports, Settings, Auth)
├── services/       # Financial calculations, validation, and analytics
├── utils/          # Constants, themes, date helpers, and currency formatting
└── widgets/        # Reusable UI widgets (cards, tiles, bottom sheets, snackbars)
```

- **Authentication:** Managed by Supabase Auth (`SupabaseAuthRepository`), persisting user sessions and profile preferences.
- **Transaction Storage:** Transactions currently use an in-memory repository (`MemoryTransactionRepository`) for local development and testing, resetting on app restart. The decoupled repository pattern allows switching to persistent storage (like SQLite or Supabase Database) without altering the UI or business logic.

## Author

- **Alan Biju**
- GitHub: [alanbiju422-dev](https://github.com/alanbiju422-dev)
