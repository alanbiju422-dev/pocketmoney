# Pocket Money Tracker

A personal finance ledger application built with Flutter, designed with a Classic Editorial aesthetic. Pocket Money Tracker provides a manual expense and income tracking experience with real Google Sign-In via Supabase Authentication, customizable display profiles, interactive financial reports, and a 5-second undo transaction deletion mechanism.

---

## Overview

Pocket Money Tracker is developed for individuals who value privacy, simplicity, and deliberate financial tracking.

- **Manual Entry:** The application does not link to bank accounts, UPI platforms, or credit card APIs. Every transaction is entered intentionally by the user.
- **Privacy Conscious:** Transaction records reside locally in device memory and are never transmitted to third parties or advertising networks.
- **Decoupled Architecture:** User authentication and profile metadata are handled via Supabase Auth, while transaction records utilize an independent repository pattern.

---

## Features

- **Google Authentication:** Real Google OAuth sign-in powered by Supabase with PKCE (Proof Key for Code Exchange) authorization.
- **Personalized Onboarding:** First-time user onboarding with display name personalization and a clear privacy notice.
- **Profile Management:** View Google profile name, customize in-app display name (persisted in Supabase user metadata), and secure sign-out.
- **Income Tracking (Add Money):** Quick entry of incoming funds without unnecessary categorizations or friction.
- **Expense Tracking (Spend Money):** Log expenses with predefined categories:
  - *Travel*
  - *Food*
  - *College*
  - *Other* (with mandatory custom reason)
- **Searchable Transaction History:** Instant search across categories, notes, and transaction amounts.
- **Filterable Records:** Filter transactions by type (*Income* or *Expense*) and category.
- **Safe Transaction Deletion:** Two-step confirmation with a 5-second floating countdown banner and instant **Undo** capability before permanent removal.
- **Financial Analytics & Reports:** Dynamic summary reports across multiple timeframes:
  - *Daily* (Today)
  - *Weekly* (This Week)
  - *Monthly* (This Month)
  - *Yearly* (This Year)
  - *Custom Date Range* (Interactive calendar picker)
- **Visual Spending Distribution:** Category breakdown percentages and visual charts powered by `fl_chart`.
- **Editorial Design System:**
  - *Light Theme:* Warm ivory, soft cream, sage green, and muted terracotta.
  - *Dark Theme:* Charcoal forest, muted sage, and warm cream typography.
  - *System Theme:* Automatically matches device appearance.

---

## Architecture & Data Storage

To ensure architectural clarity, data handling in Pocket Money Tracker is divided into two distinct layers:

### 1. Authentication & Profile Layer (Cloud)
- Managed by **Supabase Auth**.
- Handles authentication state, active sessions, and OAuth tokens.
- Persists user profile metadata, including customized display names (`display_name`) and onboarding acknowledgment status (`has_completed_welcome`).
- Authentication session tokens are managed on the client device by the Supabase Flutter SDK according to standard OAuth session lifecycles.

### 2. Transaction Ledger Layer (In-Memory)
- Managed via `MemoryTransactionRepository` implementing the abstract `TransactionRepository` interface.
- **Current Development Stage:** All income, expense, and balance entries reside exclusively in volatile application memory (RAM) and **reset when the application is restarted or when the user signs out**.
- Transactions are **not** synchronized across devices or stored in cloud database tables in the current build.
- The repository layer is fully decoupled; persistent backends (such as SQLite, PostgreSQL, or Supabase Database) can be plugged in without modifying UI or business logic.

---

## Technology Stack

| Layer | Component | Details |
| :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev/) | Cross-platform UI toolkit |
| **Dart SDK** | [Dart](https://dart.dev/) | Version `^3.13.7` (as defined in `pubspec.yaml`) |
| **State Management** | [Provider](https://pub.dev/packages/provider) | `ChangeNotifierProvider` for Auth, Theme, and Transactions |
| **Authentication** | [supabase_flutter](https://pub.dev/packages/supabase_flutter) | Google OAuth 2.0 with PKCE authorization flow |
| **Data Repository** | In-Memory Repository | Decoupled abstract contract architecture |
| **Charts & Graphs** | [fl_chart](https://pub.dev/packages/fl_chart) | Category distribution and financial visualizations |
| **Typography** | [google_fonts](https://pub.dev/packages/google_fonts) | *Lora* (Editorial headings) and *Source Sans 3* (Body text) |
| **Date & Currency** | [intl](https://pub.dev/packages/intl) | Locale-aware date calculations and currency formatting |

---

## Project Structure

```
pocketmoney/
├── android/                        # Android native platform files
│   ├── app/
│   │   ├── build.gradle.kts        # Android build configuration & release signing
│   │   └── src/main/
│   │       └── AndroidManifest.xml # Permissions & OAuth deep-link callback
│   └── gradle.properties          # Gradle environment & Kotlin compiler flags
├── assets/
│   └── fonts/                      # Lora and Source Sans 3 typography assets
├── docs/                           # Documentation resources
├── lib/
│   ├── config/
│   │   └── supabase_config.dart    # Supabase URL and Publishable Key configuration
│   ├── models/
│   │   ├── transaction_model.dart  # Transaction entity & ExpenseCategory enum
│   │   └── user_model.dart         # User entity supporting Google & display names
│   ├── providers/
│   │   ├── auth_provider.dart      # Auth state, login, and user profile management
│   │   ├── theme_provider.dart     # Light, dark, and system theme state
│   │   └── transaction_provider.dart # Financial calculations, filters & 5s undo logic
│   ├── repositories/
│   │   ├── auth_repository.dart    # Abstract auth repository contract
│   │   ├── local_auth_repository.dart # Local/test auth implementation
│   │   ├── memory_transaction_repository.dart # In-memory transaction storage
│   │   ├── supabase_auth_repository.dart # Supabase OAuth auth implementation
│   │   └── transaction_repository.dart # Abstract transaction storage contract
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── auth_gate.dart      # Central reactive authentication router
│   │   │   ├── display_name_screen.dart # Initial display name setup
│   │   │   ├── google_sign_in_screen.dart # Sign-in screen
│   │   │   └── welcome_privacy_notice_screen.dart # Privacy notice acknowledgment
│   │   ├── add_money_screen.dart   # Income entry screen
│   │   ├── history_screen.dart     # Searchable & filterable transaction history
│   │   ├── home_screen.dart        # Dashboard, balance card & quick actions
│   │   ├── main_navigation_screen.dart # Navigation bar coordinator
│   │   ├── reports_screen.dart     # Analytics, charts & date range filters
│   │   ├── settings_screen.dart    # Account info, edit name, currency, theme
│   │   └── spend_screen.dart       # Expense entry screen with category picker
│   ├── services/
│   │   └── transaction_service.dart # Financial business logic, validation & reports
│   ├── utils/
│   │   ├── app_constants.dart      # Constant labels, versioning & category definitions
│   │   ├── app_theme.dart          # Light and dark color schemes & styles
│   │   ├── currency_formatter.dart # Paise/Rupee currency calculations
│   │   └── date_helpers.dart       # Editorial date formatting & range calculations
│   ├── widgets/
│   │   ├── balance_card.dart       # Top balance summary card widget
│   │   ├── category_selector.dart  # Expense category selector chips
│   │   ├── deletion_undo_snackbar.dart # 5-second countdown banner with Undo button
│   │   ├── empty_state.dart        # Clean editorial empty-state placeholders
│   │   ├── quick_action_button.dart# Add/Spend home action buttons
│   │   ├── transaction_detail_sheet.dart # Transaction bottom detail modal
│   │   └── transaction_tile.dart   # Transaction list item with category icon
│   └── main.dart                   # Application bootstrap & dependency injection
├── test/                           # Unit and widget test suites
├── .gitignore                      # Git exclusion rules for secrets, builds & IDEs
├── analysis_options.yaml           # Flutter lint rules
└── pubspec.yaml                    # Package dependencies and asset declarations
```

---

## Prerequisites

Before building or running the project, ensure you have the following installed:

- [Dart SDK](https://dart.dev/get-dart) version `^3.13.7` (as specified in `pubspec.yaml`)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (supported Flutter 3 release compatible with Dart `^3.13.7`)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter and Dart extensions
- Android SDK with platform tools installed (for Android device testing)
- A [Supabase](https://supabase.com/) account (free tier is sufficient)
- A [Google Cloud Console](https://console.cloud.google.com/) account (for Google OAuth credentials)

---

## Setup & Installation

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/pocketmoney.git
cd pocketmoney
```

### 2. Install Dependencies

Fetch all required packages declared in `pubspec.yaml`:

```bash
flutter pub get
```

---

## Configuration

### 1. Supabase Configuration

Open `lib/config/supabase_config.dart`. Configure your Supabase project URL and Publishable Key:

```dart
class SupabaseConfig {
  SupabaseConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://<YOUR_PROJECT_ID>.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_<YOUR_PUBLISHABLE_KEY>',
  );
}
```

> **Understanding Supabase Keys:**
> - The **Publishable Key** (`sb_publishable_...`) is public client configuration, similar to a public project identifier. It identifies your project to Supabase and is safe to bundle in mobile and web client builds.
> - **Never** place a Supabase **Service Role Key** or **Secret Key** (`sb_secret_...`) in Flutter source code. Secret keys bypass security policies and must remain server-side.

### 2. Google OAuth via Supabase

Google Sign-In is orchestrated through Supabase Auth, keeping OAuth secrets off the mobile client.

#### A. Google Cloud Console Setup
1. Open the [Google Cloud Console](https://console.cloud.google.com/).
2. Create or select a project.
3. Navigate to **APIs & Services → Credentials**.
4. Create an **OAuth 2.0 Client ID** of type **Web application**:
   - Add your Supabase project callback URL to **Authorized redirect URIs**:
     ```
     https://<YOUR_PROJECT_ID>.supabase.co/auth/v1/callback
     ```
   - Note the generated **Client ID** and **Client Secret**.
5. Create an **OAuth 2.0 Client ID** of type **Android**:
   - Package name: `com.alanbiju.pocketmoney`
   - Enter your development or release SHA-1 signing certificate fingerprint.

#### B. Supabase Dashboard Setup
1. Log in to your [Supabase Dashboard](https://supabase.com/dashboard).
2. Select your project and navigate to **Authentication → Providers → Google**.
3. Toggle the Google provider **ON**.
4. Enter the **Client ID** and **Client Secret** obtained from your Google Cloud Console Web Application credentials.
5. In **Authentication → URL Configuration**, add the application deep-link redirect URI to **Redirect URLs**:
   ```
   io.supabase.pocketmoney://login-callback/
   ```

---

## Running the Application

### Debug Run

Launch the application on an attached physical device or emulator:

```bash
flutter run
```

### Run with Environment Overrides

You can pass configuration dynamically at build time without modifying code:

```bash
flutter run --dart-define=SUPABASE_URL=https://<YOUR_PROJECT_ID>.supabase.co \
            --dart-define=SUPABASE_ANON_KEY=sb_publishable_<YOUR_KEY>
```

---

## Generating the Android Release APK

The project is configured to require production release signing. In [`android/app/build.gradle.kts`](./android/app/build.gradle.kts), release builds will fail with an explicit error message if signing credentials are missing, preventing accidental distribution of debug-signed APKs.

### Step 1: Generate an Upload Keystore (One-Time Setup)

Generate a private keystore using Java's `keytool`:

```bash
keytool -genkey -v \
  -keystore android/app/upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

> **Security Note:** Store your keystore file and passwords securely offline. If lost, you will not be able to update an existing application on user devices.

### Step 2: Configure `android/key.properties`

Create a file named `android/key.properties` (this file is excluded from Git by `.gitignore`):

```properties
storePassword=<YOUR_KEYSTORE_PASSWORD>
keyPassword=<YOUR_KEY_PASSWORD>
keyAlias=upload
storeFile=upload-keystore.jks
```

### Step 3: Build the Release APK

Execute the Flutter release build:

```bash
# Standard release APK
flutter build apk --release

# Recommended: Release APK with Dart code obfuscation
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols

# Release App Bundle for Google Play Store
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols
```

The compiled release APK will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## Security Notes

- **Client-Side Configuration:** The Supabase Publishable Key included in `lib/config/supabase_config.dart` is public client configuration. It identifies the client application to Supabase and restricts access according to backend authorization rules.
- **No Private Secrets in Client:** No Supabase Service Role Key, Secret Key, or Google OAuth Client Secret exists in the source code or APK build configuration.
- **PKCE OAuth Authorization:** Google Sign-In uses the Proof Key for Code Exchange (PKCE) flow. Even if another application registers the redirect custom URI scheme, authorization codes cannot be exchanged without the locally generated code verifier.
- **Android Backup Exclusion:** `android:allowBackup="false"` is configured in `android/app/src/main/AndroidManifest.xml` to prevent application data and cached authentication state from being included in Android system backups (such as cloud backups to Google Drive or device-to-device migration transfers).
- **Session & Memory Clearing:** Signing out invalidates active authentication session tokens with Supabase and clears all in-memory transaction records from RAM, preventing cross-user data exposure on shared devices.
- **Keystore Isolation:** Keystore files (`*.jks`, `*.keystore`), `key.properties`, `local.properties`, and `.env` files are strictly excluded from version control by `.gitignore`.

> **Note on Database Row Level Security (RLS):**  
> If you add cloud database tables in Supabase in future updates, ensure that Row Level Security (RLS) policies are configured according to Supabase best practices so that authenticated requests are restricted to the user's own records (e.g., `auth.uid() = user_id`). For details, consult the [Supabase Row Level Security documentation](https://supabase.com/docs/guides/database/postgres/row-level-security).

---

## Privacy Notes

- **No Banking Connectivity:** Pocket Money Tracker has no integrations with banks, credit cards, or UPI payment apps.
- **No Automated Scraping:** The application cannot read SMS notifications, bank balances, or device payment histories.
- **Session-Only Local Transactions:** In the current build, all transaction records (amounts, categories, descriptions) reside strictly in volatile local memory (RAM) during the active session. They are not transmitted to any remote servers, cloud databases, or third-party networks, and they are cleared upon sign-out or app termination.
- **No Third-Party Analytics:** The application does not bundle tracking SDKs or ad measurement platforms.

---

## Publishing to GitHub

To publish this project to a clean public GitHub repository:

### 1. Initialize and Stage Files

```bash
git init
git add .
```

### 2. Verify Exclusions

Confirm that sensitive files are ignored before committing:

```bash
git status
```

*Ensure that `android/local.properties`, `android/key.properties`, and `*.jks` files are **not** listed.*

### 3. Commit and Push

```bash
git commit -m "feat: Initial public release - Pocket Money Tracker v1.0.0"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/pocketmoney.git
git push -u origin main
```

---

## License

This project is made available for personal, reference, and educational purposes.  
**A software license must be selected before copying, modifying, or redistributing this application.**  
For guidance on selecting an open-source license, refer to [choosealicense.com](https://choosealicense.com/).

---

*Pocket Money Tracker — Classic Editorial Edition. Designed for timeless clarity, personal privacy, and peace of mind.*
