# Personal Finance & Budget Tracker

An offline-first Android personal finance application for managing income, expenses, accounts, budgets, recurring bills, and financial reports. Core functionality works entirely on-device without registration, a remote API, or an internet connection.

**Flutter repository:** https://github.com/ShaheenDevs/Personal-Finance-Budget-Tracker  
**Backend:** Not required for core functionality. An optional Node.js + SQL service may be introduced later for encrypted backup and multi-device synchronization.

## Project Overview

### Technology
| Area | Planned technology |
|---|---|
| Application | Flutter / Dart |
| Architecture | Stacked, following the Flutter reference repository |
| State management | BaseViewModel, StackedView, ViewModelWidget where appropriate |
| Dependency injection | Stacked service locator |
| Local database | SQLite with Drift |
| Export | Local CSV and PDF generation |
| Backend | None for core functionality |
| Future service | Node.js, Express.js, JavaScript/CommonJS, Sequelize, SQL (only if approved) |

## Reference Architecture and Conventions

The Flutter reference repository, ShaheenDevs/edge_market_flutter, separates:
- lib/app/ — app setup, locator, routing, dialogs, and bottom sheets.
- lib/models/ — application data models.
- lib/services/ — application services.
- lib/ui/common/ — shared colors, strings, endpoints, and UI helpers.
- lib/ui/views/ — feature views and ViewModels.
- lib/ui/widgets/common/ — reusable UI components.
- test/ — service, ViewModel, helper, and golden tests.

The reference uses Stacked BaseViewModel, StackedView, and the service-locator pattern. This project adapts those conventions to local repositories and database services. API/authentication services are not needed for offline core functionality.

The Node.js reference repository, ShaheenDevs/edge_market_node_js, uses JavaScript/CommonJS, Express, Sequelize, SQL, and separated routes, controllers, models, middleware, and migrations. This is recorded for a possible future sync service only. No backend is part of the current core scope.

## Features and Status

Status definitions:
- ☒ Completed and tested
- [~] Implemented, testing incomplete
- ☐ Pending
- [!] Blocked or requires a decision

The Flutter source foundation, native Android scaffold, and local database foundation are committed. Account repository workflows, a Stacked account screen, and account ViewModel are implemented. Transaction, category, and tag screens/ViewModels remain pending.

### Core Features
- [~] Income transaction creation, editing, deletion, and listing (repository operations implemented; UI pending)
- [~] Expense transaction creation, editing, deletion, and listing (repository operations implemented; UI pending)
- [~] Custom transaction categories (repository creation and type validation implemented; UI pending)
- [~] Tags and transaction tagging (repository creation and atomic transaction links implemented; UI pending)
- ☐ Monthly budgets
- ☐ Custom-period budgets
- ☐ Recurring bill definitions and schedules
- [~] Multiple account types: cash, bank, and digital wallet (repository supports cash, bank, and wallet)
- [~] Account balance tracking and transaction-account consistency (balance calculation and currency validation implemented)
- ☐ Transaction search, filters, and sorting
- ☐ Financial charts and visual reports
- ☐ CSV export
- ☐ PDF report export
- ☐ Application lock
- ☐ Local data management and privacy controls

### Premium / Paid Features
- ☐ Advanced financial analytics
- ☐ Unlimited financial accounts (free-tier account allowance requires product decision)
- ☐ Recurring transaction automation
- ☐ Multi-device synchronization (future backend)
- ☐ Encrypted cloud backup and restore (future backend)
- ☐ Advanced reports and insights

### Screens and UI
- [~] Dashboard / overview (initial offline-first landing screen; financial summaries pending)
- ☐ Transactions list and details
- ☐ Add/edit income and expense
- ☐ Category management
- ☐ Tag management
- [~] Accounts list and details (list, balances, create/edit, and archive UI implemented; full list-state widget coverage pending)
- ☐ Budget list, creation, and details
- ☐ Recurring bills list and editor
- ☐ Reports and charts
- ☐ Export flow
- ☐ Search and filter interface
- ☐ App lock setup and unlock
- ☐ Settings and local data management
- ☐ Premium feature presentation and entitlement checks

### Local Database
- [~] Drift schema v1, code generation, and initial database tests pass in CI; migration coverage remains pending
- [~] Accounts table
- [~] Categories table
- [~] Tags table and transaction-tag join table
- [~] Transactions table
- [~] Budgets table
- [~] Recurring transaction definitions
- [~] Transaction query indexes and foreign-key constraints defined
- ☐ Atomic transaction workflows for financial mutations
- ☒ 10 database/repository tests passed in CI
- [~] Stable UUID identifiers and created/updated/deleted metadata included in schema

### Backend APIs
- ☐ Not applicable to core offline release
- ☐ Future encrypted backup API — pending separate scope and approval
- ☐ Future synchronization API — pending separate scope and approval

### Authentication and Authorization
- ☐ No registration or remote authentication for core functionality
- ☐ Local application lock
- ☐ Future backup identity and authorization design — only if cloud features are approved

### Offline Functionality
- ☐ All core create/read/update/delete flows work offline
- ☐ Dashboard and reports use local data
- ☐ CSV/PDF generation works locally
- ☐ No network dependency during normal use
- ☐ Future sync queue and conflict policy — only in optional sync phase

### Notifications
- ☐ Recurring bill reminders and notification behavior to be designed
- ☐ Permission-denied and notification-disabled states

### Settings
- ☐ Currency and number formatting preferences
- ☐ App lock settings
- ☐ Export and local data management
- ☐ Premium entitlement display
- ☐ Backup/sync settings only when those features exist

### Testing
- [~] Unit tests for account balances and repository/domain rules (covered in current suites)
- ☒ 10 repository/database tests passed in CI
- ☒ 4 account ViewModel tests passed in CI
- [~] Account route/form widget test passed; broader screen-state and navigation coverage remains
- ☐ CSV/PDF export tests
- ☐ Offline behavior tests
- ☐ Migration and data-integrity tests
- ☐ Android release build verification
- ☒ GitHub Actions passes dependency resolution, Drift/Stacked code generation, analysis, all 15 tests, and Android debug APK build

### Deployment and Release
- ☐ App identity, icon, and version configuration
- ☐ Android build configuration
- ☐ Release build and installation verification
- ☐ Store listing and privacy documentation

## Architecture Plan

Feature flow: View (StackedView) → ViewModel (BaseViewModel) → Service → Repository → Drift Database.

- Views render state and forward user actions.
- ViewModels coordinate screen behavior and validation.
- Services encapsulate feature-level operations and calculations.
- Repositories provide data access boundaries.
- Drift owns SQLite queries, schema, migrations, and transactional writes.
- The service locator registers long-lived services and repositories.

### Proposed Flutter Structure

This is the planned responsibility map; these files do not exist yet.

    lib/
      app/
        app.dart
        app.locator.dart
        app.router.dart
      database/
        app_database.dart
        tables/
        daos/
      models/
      repositories/
      services/
      ui/
        common/
        views/
          dashboard/
          transactions/
          categories/
          tags/
          accounts/
          budgets/
          recurring/
          reports/
          settings/
          app_lock/
        widgets/
          common/
    test/
      database/
      repositories/
      services/
      viewmodels/
      widgets/

This adapts the reference's app, models, services, and ui/views organization while adding database and repository boundaries required by the offline-first data layer.

## Local Data Model

The initial Drift schema is now defined in `lib/database/tables/`. Schema version is 1. Drift-generated code is intentionally not committed yet; run the code-generation command after dependency resolution. Date/time columns are configured for ISO-8601 text storage in `build.yaml`.

| Table | Main fields / purpose |
|---|---|
| accounts | `id` (UUID text PK), name, account type, ISO currency code, opening balance in minor units, archived flag, created/updated timestamps |
| categories | `id` (UUID text PK), name, transaction type, optional icon/color metadata, built-in flag; unique name + transaction type |
| transactions | `id` (UUID text PK), account/category foreign keys, type, positive amount in minor units, currency code, optional note, transaction date, created/updated/deleted timestamps |
| tags | `id` (UUID text PK), unique name, optional color metadata, created timestamp |
| transaction_tags | Transaction and tag foreign keys; composite primary key prevents duplicate tag assignment |
| budgets | `id` (UUID text PK), optional category FK, amount in minor units, currency, period type, start/end dates, timestamps |
| recurring_transactions | `id` (UUID text PK), account/category references, type, amount in minor units, currency, frequency, next due date, timezone ID, active state, timestamps |
| app_preferences | Preference key (text PK), value, updated timestamp |

### Data Integrity Rules
- Store monetary values as integer minor units (cents/paisa), not floating-point values.
- Store an ISO 4217 currency code with monetary records; do not silently combine different currencies in totals.
- Use stable UUID identifiers so future backup/sync does not depend on device-local auto-increment IDs.
- Use database foreign keys and indexes for relationships and common filters.
- Update transaction records and account/budget effects within database transactions.
- Prefer deriving account balances and report totals from source transactions, or maintain cached totals only with tested atomic updates.
- Keep timestamps and soft-delete/sync metadata extensible for future synchronization.
- Define recurring schedules with explicit timezone and due-date rules before automation.
- Never store app-lock secrets as plaintext. Select secure platform-backed storage during the app-lock milestone.

### Implemented Database Files

- `lib/database/app_database.dart` — Drift database, schema version 1, database opening, and foreign-key activation.
- `lib/database/tables/` — eight table definitions: accounts, categories, transactions, tags, transaction_tags, budgets, recurring_transactions, and app_preferences.
- `lib/repositories/local_finance_repository.dart` — account/category/tag CRUD starter operations, transaction create/update/soft-delete, transaction-tag links, and balance calculations.
- `lib/ui/views/accounts/accounts_view.dart` and `accounts_viewmodel.dart` — account list, balances, create/edit/archive flows, loading/empty/error states, and retry action.
- `lib/app/app.locator.dart`, `app.dart`, and `app.router.dart` — repository registration and dashboard/accounts routes.
- `test/database/app_database_test.dart` — 10 in-memory database/repository tests.
- `test/viewmodels/accounts_viewmodel_test.dart` — 4 account ViewModel tests.
- `test/widget_test.dart` — dashboard-to-accounts navigation and account form widget test.
- `build.yaml` — stores Drift date/time values as ISO-8601 text.

Transaction indexes cover account/date and category/date query patterns. Foreign-key enforcement is enabled when the database opens. Financial amounts use integer minor units; no floating-point money fields are used.

### Core Relationships
- One account has many transactions.
- A category can classify many transactions.
- Transactions and tags have a many-to-many relationship through transaction_tags.
- Budgets can apply to an overall spending scope or a category and a defined period.
- Recurring transaction definitions reference the account and category used when a due transaction is generated.

## Free and Premium Separation

### Free
- Manual income and expense transactions
- Basic categories and tags
- Basic budgets
- Standard reports
- Local CSV and PDF export
- Offline data storage and management

### Premium
- Advanced analytics
- Unlimited accounts
- Recurring transaction automation
- Multi-device synchronization
- Encrypted cloud backup and restore
- Advanced reporting and insights

Premium gating will be centralized in an entitlement/service layer rather than scattered UI-only checks. Core records must remain locally accessible; a premium entitlement must not be required to read or preserve existing financial data.

**Product decision to confirm before account-limit implementation:** the exact number of accounts available in the free tier. Requirements specify unlimited accounts as premium but do not state the free-tier limit.

## Development Progress

| Workstream | Flutter | Backend | Testing |
|---|---|---|---|
| Repository setup | ☒ Flutter source foundation and Android scaffold committed | N/A | ☒ CI analysis and Android debug APK build passed |
| Architecture and planning | [~] Documented; initial Stacked app structure committed | N/A | N/A |
| Local database | ☒ Drift schema v1, eight tables, repository workflows, foreign-key rules, and indexes committed | N/A | ☒ Code generation and 10 database/repository tests passed in CI |
| Transactions | [~] Repository create/update/soft-delete and query operations implemented; UI pending | N/A | [~] Lifecycle and validation tests pass |
| Categories and tags | [~] Repository creation and tag association implemented; UI pending | N/A | [~] Type and relationship tests pass |
| Accounts and balances | [~] Create/update/archive, currency protection, balance calculation, Stacked list/form UI, and retry state implemented | N/A | ☒ Repository/ViewModel tests; route/form widget test passed |
| Budgets | ☐ Pending | N/A | ☐ Pending |
| Recurring bills | ☐ Pending | N/A | ☐ Pending |
| Reports and exports | ☐ Pending | N/A | ☐ Pending |
| App lock and settings | ☐ Pending | N/A | ☐ Pending |
| Premium separation | ☐ Pending | N/A | ☐ Pending |
| Cloud backup and sync | ☐ Future | ☐ Future | ☐ Future |

## Milestones

1. **M1 — Repository analysis and project planning:** inspect references and target repository; document architecture, scope, data model, and roadmap.
2. **M2 — Flutter project foundation:** ☒ project manifest, analyzer rules, Stacked app setup, routing, locator, theme, dashboard, and Android scaffold committed; analyzer, widget test, and Android debug APK build passed in CI.
3. **M3 — Local database foundation:** ☒ Drift dependencies, schema v1, eight table definitions, foreign keys, indexes, repository starter methods, and in-memory tests implemented; code generation and all 6 database tests passed in CI. Upgrade-migration tests will be added with the next schema version, when a real migration path exists.
4. **M4 — Accounts and transaction management:** [~] account repository, balances, account Stacked screen/ViewModel, create/edit/archive UI, and account tests implemented. Transaction repository operations are implemented; transaction ViewModels/screens and category/tag management UI remain pending.
5. **M5 — Budgets and recurring bills:** implement budget calculations and recurring schedule management.
6. **M6 — Dashboard, reports, and exports:** implement summaries, charts, search/filtering, CSV, and PDF exports.
7. **M7 — Security, settings, and premium separation:** implement app lock, preferences, and centralized premium entitlements.
8. **M8 — QA and Android release preparation:** test offline behavior, data integrity, migrations, and release build.
9. **M9 — Optional cloud phase:** only after separate approval, design and implement encrypted backup and multi-device sync.

## Completed Work

### 2026-11-27 — M4 account management UI
- Added `AccountsView` and `AccountsViewModel` using the existing Stacked architecture and the local finance repository.
- Added account listing with calculated balances, cash/bank/wallet icons, and archived-state display.
- Added create-account form with name, account type, three-letter currency code, and opening balance.
- Added account editing and archive confirmation; archived accounts and their historical balances remain visible, while archived accounts cannot accept new transactions.
- Added loading, empty, error, and retry states. Added the Accounts route to Stacked configuration/router and a dashboard entry point.
- Added four ViewModel tests for loading balances, create/update, archive/history preservation, and validation errors; expanded widget test to verify navigation and account form fields.
- CI run `45888645681` on source commit `0d5a4f9e1f79a5c5383e1c2aaaf7562743cbc96a` passed code generation, `flutter analyze`, all 15 tests, and Android debug APK build. Full account list-state behavior still needs broader widget coverage.

### 2026-11-27 — M4 repository foundation
- Expanded `LocalFinanceRepository` with account create/update/archive operations, sorted account queries, and account balance calculation from opening balance plus income/expense transactions.
- Added category and tag list/watch/create operations.
- Added transaction list/watch, atomic create/update with tag-link replacement, and soft deletion.
- Added validation for positive transaction amounts, income/expense types, account types, three-letter currency codes, account/category currency/type consistency, missing tags, archived accounts, and preventing currency changes after transactions exist.
- Added tests for tagged transactions, account balances, transaction update/soft-delete, category/currency mismatch rejection, and account currency/archive protections.
- GitHub Actions run `45884874572` on commit `d0c057df038d56b482759052d5a2e7c8b0d45603` passed Drift/Stacked code generation, `flutter analyze`, all 11 tests, and Android debug APK build.

### 2026-11-27 — CI verification and Android project identity
- Latest GitHub Actions run `45880105913` on commit `975b7715ec29533a2b512f7fe038ea377f780596` completed successfully.
- Dependency resolution and Drift/Stacked code generation completed successfully.
- `flutter analyze` reported `No issues found!`.
- The expanded suite passed all 7 tests: 6 Drift database tests and 1 dashboard widget test.
- Database tests cover account persistence, transaction/account relationships, positive transaction amounts, foreign-key rejection, cascading account deletion, and schema version 1.
- Confirmed the Android platform scaffold already exists under `android/`; README had incorrectly described it as missing.
- Updated the Android application ID to `com.shaheendevs.personalfinancebudgettracker` and launcher label to `Personal Finance & Budget Tracker`.
- Added a CI debug APK build. Fixed the Android Gradle Plugin (9.1.0 to 9.1.1), Gradle wrapper (9.3.1 to 9.5.0), and escaped the ampersand in the manifest label as `&amp;`.
- Latest CI run `45882661936` on commit `73175434a04e7b7483af8938c3f7864bc2e19859` passed dependency resolution, code generation, `flutter analyze`, all 7 tests, and `flutter build apk --debug`.

### 2026-11-26 — Flutter CI validation and analysis fixes
- Added `.github/workflows/flutter-validation.yml` to run on pushes to `main` and pull requests targeting `main`.
- The workflow sets up the stable Flutter toolchain, resolves packages, generates Drift and Stacked code, runs `flutter analyze`, and executes `flutter test`.
- CI confirmed dependency resolution and Drift/Stacked code generation succeed.
- Fixed the Stacked repository registration by making the repository constructor accept an optional database and using the standard `LazySingleton(classType: LocalFinanceRepository)` declaration.
- The next analyzer run reported only lint/deprecation infos: generated locator/router formatting, Flutter Material API deprecation notices, and `withOpacity`.
- Excluded generated locator/router files from analysis, configured the SDK deprecation notice as ignored for compatibility, and replaced `withOpacity` with `withValues(alpha: 0.08)`.
- CI for commit `8ace7c4b2fce6fab024facfc45181a1a98e57592` passed dependency resolution, code generation, and `flutter analyze` (no issues found). Three database tests passed; the existing dashboard widget test failed because the app did not provide the generated Stacked route handler and the test did not initialize the locator.
- Connected `StackedRouter().onGenerateRoute` to `MaterialApp` and initialized the locator in the widget test. The new validation run is pending; the full suite is not yet confirmed passing.

### 2026-11-26 — M3 initial local database implementation
- Added Drift and drift_flutter runtime dependencies, drift_dev code-generation dependency, and UUID generation.
- Added eight Drift tables for accounts, categories, transactions, tags, transaction-tag links, budgets, recurring transaction definitions, and app preferences.
- Added schema version 1 and enabled SQLite foreign-key enforcement on database open.
- Added indexes for transaction lookups by account/date and category/date.
- Configured Drift to store date/time values as ISO-8601 text.
- Added a local repository with account creation/list/watch, category creation, and transaction creation; transaction amounts must be positive integer minor units.
- Registered the database and repository in the Stacked service locator.
- Added in-memory database tests for account persistence, transaction persistence with its account relationship, and transaction amount validation.

**Tests:** Not run. Flutter and Dart SDK executables are unavailable in the execution environment. Drift/Stacked code generation, dependency resolution, analyzer, database tests, and migration behavior remain unverified.

**Git:** Initial M3 implementation committed file-by-file; latest M3 source/test commit: `48735836df77be5ac70caf814e5887d4da5f8f44`.

### 2026-11-26 — M2 initial Flutter source foundation
- Added `pubspec.yaml` with Flutter, Stacked, Stacked Services, build_runner, and Stacked generator dependencies, following the reference repository's package conventions.
- Added `.gitignore` and `analysis_options.yaml`.
- Added the application entry point, Stacked locator configuration, route configuration, and `@StackedApp` configuration source.
- Added a shared Material 3 theme and the initial Dashboard View/ViewModel using `StackedView` and `BaseViewModel`.
- Added an initial widget test for the dashboard.
- Kept dashboard color opacity compatible with older supported Flutter APIs.
- Native Android/iOS platform folders and generated build artifacts have not been created in this environment.

**Tests:** Not run. Flutter and Dart SDK executables are not installed in the available execution environment; dependency resolution, code generation, analyzer, widget tests, and Android build remain unverified.

**Git:** Foundation files were pushed directly to `main` in individual file commits; latest foundation commit: `9dfa071a7f662cb20c896cc6db0ab9b0e20e8bf0`.

### 2026-11-26 — Initial repository analysis and planning
- Confirmed the Flutter reference repository and inspected its project tree, dependencies, app bootstrap, Stacked locator, ViewModel, View, and API service patterns.
- Confirmed the Node.js reference repository and inspected its project tree, CommonJS/Express/Sequelize dependencies, model registry, server entry point, and migration conventions.
- Confirmed the new Personal Finance repository exists and is empty.
- Created this project roadmap and technical record.

**Tests:** No application code exists yet; no Flutter or backend tests were run.

**Git:** Initial README commit: afac94f5d0a3a386d5f0f4dfc834a25c955b0c8d.

## Pending Work
- Expand account screen widget coverage for populated, archived, and database-error states.
- Add transaction ViewModels/screens and their widget/navigation tests.
- Add category and tag management UI.
- Add schema-upgrade migration tests when a future schema version introduces an actual migration path.
- Implement all planned local-first features.
- Confirm free-tier account allowance before enforcing an account cap.
- Design and execute QA on an Android device/emulator.
- Keep optional cloud features out of the core release until separately approved.

## API Documentation

No APIs are required for the core offline application. Future backup/sync endpoints will be documented here only after that phase is approved and implemented.

## Installation and Setup

### Flutter application

1. Install Flutter and Android toolchain compatible with Dart SDK `>=3.4.0 <4.0.0`.
2. From the repository root, run `flutter pub get`.
3. Generate Stacked and Drift code with `dart run build_runner build --delete-conflicting-outputs`.
4. Run static analysis with `flutter analyze`.
5. Run tests with `flutter test`.
6. Generate the native Android platform scaffold if it is not present: `flutter create . --platforms=android`.
7. Launch on an Android device/emulator with `flutter run`.

The Drift database is stored in the app's application documents directory as `personal_finance.sqlite`. Core data access does not require network connectivity. No backend environment variables or API credentials are required.

## Database Documentation

The logical entities and relationships are documented in Local Data Model above. The implemented Drift schema, generated files, indexes, and migration history will be documented here as they are added.

## Known Issues and Decisions
- Free-tier account allowance is unspecified and must be confirmed before implementing a cap.
- Premium entitlement verification and purchase integration are not yet specified; no payment provider will be assumed.
- Recurring reminder timing, timezone behavior, and notification permissions require implementation-level definition.
- Cloud backup and synchronization are explicitly future/optional and are not part of the initial offline release.

## Development History

| Date | Milestone | Changes | Tests | Commit |
|---|---|---|---|---|
| 2026-11-27 | M4 — Account UI and ViewModel | Added Stacked accounts screen, create/edit/archive form, dashboard route, loading/error/empty/retry states, and four ViewModel tests | `flutter analyze` passed; 15 tests passed; Android debug APK built | `0d5a4f9e1f79a5c5383e1c2aaaf7562743cbc96a` (validated run `45888645681`) |
| 2026-11-27 | M4 — Account and transaction repository | Added account/category/tag/transaction operations, balance calculations, validation, tag links, and soft deletion | `flutter analyze` passed; 11 tests passed; Android debug APK built | `d0c057df038d56b482759052d5a2e7c8b0d45603` (validated run `45884874572`) |
| 2026-11-27 | M2/M3 — Android and database validation | Set application ID/display name; upgraded Android Gradle Plugin and Gradle wrapper; fixed manifest XML; added foreign-key and cascade tests; CI debug APK build | `flutter analyze` passed; 7 tests passed; `flutter build apk --debug` passed | `73175434a04e7b7483af8938c3f7864bc2e19859` (validated run `45882661936`) |
| 2026-11-26 | CI — Flutter validation | Added GitHub Actions workflow; fixed repository construction, analyzer issues, MaterialApp route handler, and widget-test locator setup | `flutter analyze` passed; all 4 tests passed on corrected run `45880105913` | `975b7715ec29533a2b512f7fe038ea377f780596` |
| 2026-11-26 | M1 — Planning | Initial README, architecture plan, feature checklist, logical data model | Not applicable; no app code | `826ab3e01eadb647bbe1313093edd9527b40e913` |
| 2026-11-26 | M2 — Initial Flutter source foundation | Flutter manifest, lint config, app bootstrap, Stacked locator/router config, theme, dashboard, widget test, ignore rules | Not run: Flutter/Dart SDK unavailable | `4dcc485834a091ccd960cdc308a19146cabe2d03` (latest source fix)
