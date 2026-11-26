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

All application features below are pending implementation.

### Core Features
- ☐ Income transaction creation, editing, deletion, and listing
- ☐ Expense transaction creation, editing, deletion, and listing
- ☐ Custom transaction categories
- ☐ Tags and transaction tagging
- ☐ Monthly budgets
- ☐ Custom-period budgets
- ☐ Recurring bill definitions and schedules
- ☐ Multiple account types: cash, bank, and digital wallet
- ☐ Account balance tracking and transaction-account consistency
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
- ☐ Dashboard / overview
- ☐ Transactions list and details
- ☐ Add/edit income and expense
- ☐ Category management
- ☐ Tag management
- ☐ Accounts list and details
- ☐ Budget list, creation, and details
- ☐ Recurring bills list and editor
- ☐ Reports and charts
- ☐ Export flow
- ☐ Search and filter interface
- ☐ App lock setup and unlock
- ☐ Settings and local data management
- ☐ Premium feature presentation and entitlement checks

### Local Database
- ☐ Drift database setup and schema versioning
- ☐ Accounts table
- ☐ Categories table
- ☐ Tags table and transaction-tag join table
- ☐ Transactions table
- ☐ Budgets table
- ☐ Recurring transaction definitions
- ☐ Database indexes and foreign-key constraints
- ☐ Atomic transaction workflows for financial mutations
- ☐ Database migration tests
- ☐ Backup/sync-ready stable identifiers and metadata

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
- ☐ Unit tests for calculations and domain rules
- ☐ Repository/database tests
- ☐ ViewModel tests
- ☐ Widget and navigation tests
- ☐ CSV/PDF export tests
- ☐ Offline behavior tests
- ☐ Migration and data-integrity tests
- ☐ Android release build verification

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

The following is the initial logical schema. Exact Drift column types, nullability, indexes, and migrations will be finalized during implementation.

| Table | Main fields / purpose |
|---|---|
| accounts | Stable ID, name, type, opening balance, currency code, archived state, timestamps |
| categories | Stable ID, name, transaction type, icon/color metadata, built-in/custom flag |
| transactions | Stable ID, account ID, category ID, type, amount, currency code, note, transaction date, timestamps |
| tags | Stable ID, name, color metadata |
| transaction_tags | Transaction ID and tag ID; unique pair |
| budgets | Stable ID, category or overall scope, amount, period type, start/end dates, timestamps |
| recurring_transactions | Stable ID, account/category references, amount, frequency, next due date, active state |
| app_preferences | Non-financial local preferences where appropriate |

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
| Repository setup | ☐ Pending | N/A | ☐ Pending |
| Architecture and planning | [~] Documented | N/A | N/A |
| Local database | ☐ Pending | N/A | ☐ Pending |
| Transactions | ☐ Pending | N/A | ☐ Pending |
| Categories and tags | ☐ Pending | N/A | ☐ Pending |
| Accounts and balances | ☐ Pending | N/A | ☐ Pending |
| Budgets | ☐ Pending | N/A | ☐ Pending |
| Recurring bills | ☐ Pending | N/A | ☐ Pending |
| Reports and exports | ☐ Pending | N/A | ☐ Pending |
| App lock and settings | ☐ Pending | N/A | ☐ Pending |
| Premium separation | ☐ Pending | N/A | ☐ Pending |
| Cloud backup and sync | ☐ Future | ☐ Future | ☐ Future |

## Milestones

1. **M1 — Repository analysis and project planning:** inspect references and target repository; document architecture, scope, data model, and roadmap.
2. **M2 — Flutter project foundation:** initialize Flutter project, dependencies, Stacked app setup, routing, locator, and shared UI foundation.
3. **M3 — Local database foundation:** configure Drift, initial schema, migrations, repositories, and database tests.
4. **M4 — Accounts and transaction management:** implement account, income, expense, category, tag, and transaction flows.
5. **M5 — Budgets and recurring bills:** implement budget calculations and recurring schedule management.
6. **M6 — Dashboard, reports, and exports:** implement summaries, charts, search/filtering, CSV, and PDF exports.
7. **M7 — Security, settings, and premium separation:** implement app lock, preferences, and centralized premium entitlements.
8. **M8 — QA and Android release preparation:** test offline behavior, data integrity, migrations, and release build.
9. **M9 — Optional cloud phase:** only after separate approval, design and implement encrypted backup and multi-device sync.

## Completed Work

### 2026-11-26 — Initial repository analysis and planning
- Confirmed the Flutter reference repository and inspected its project tree, dependencies, app bootstrap, Stacked locator, ViewModel, View, and API service patterns.
- Confirmed the Node.js reference repository and inspected its project tree, CommonJS/Express/Sequelize dependencies, model registry, server entry point, and migration conventions.
- Confirmed the new Personal Finance repository exists and is empty.
- Created this project roadmap and technical record.

**Tests:** No application code exists yet; no Flutter or backend tests were run.

**Git:** Initial planning commit will be recorded here after the README is committed.

## Pending Work
- Create the Flutter application foundation in this repository.
- Add Drift database and migration tests.
- Implement all planned local-first features.
- Confirm free-tier account allowance before enforcing an account cap.
- Design and execute QA on an Android device/emulator.
- Keep optional cloud features out of the core release until separately approved.

## API Documentation

No APIs are required for the core offline application. Future backup/sync endpoints will be documented here only after that phase is approved and implemented.

## Installation and Setup

The repository is currently in its planning stage. Flutter setup and run instructions will be added after the Flutter project scaffold and dependency versions are committed.

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
| 2026-11-26 | M1 — Planning | Initial README, architecture plan, feature checklist, logical data model | Not applicable; no app code | To be recorded after commit |
