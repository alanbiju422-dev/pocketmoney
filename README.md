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
- **Transaction Storage:** The app uses `SupabaseTransactionRepository` to persist transactions in `public.transactions`. Each request uses the signed-in Supabase Auth user; Row Level Security policies restrict reads, inserts, and deletes to that owner. `MemoryTransactionRepository` remains available for unit and widget tests.

## Supabase Database Setup

Before running the app against Supabase, apply both migrations in timestamp order to the `pocket-money` project in the Supabase SQL Editor: [`20261118000100_create_user_transactions.sql`](supabase/migrations/20261118000100_create_user_transactions.sql), then [`20261118000200_fix_transactions_other_description_constraint.sql`](supabase/migrations/20261118000200_fix_transactions_other_description_constraint.sql). The first migration creates the transaction table, enables and forces RLS, grants only the required authenticated operations, and adds the table to the Realtime publication. The follow-up migration corrects the null-safe check for descriptions on `other` expenses without changing transaction rows. These migrations do not create or require a service-role key in the app.

The migration intentionally stores amounts as integer paise. It keeps the current transaction ID format and category values (`travel`, `food`, `college`, `other`). Existing in-memory transactions cannot be recovered after an app restart and are not part of the migration.

## Author

- **Alan Biju**
- GitHub: [alanbiju422-dev](https://github.com/alanbiju422-dev)
