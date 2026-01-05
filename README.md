# Dak Louk

Dak Louk is a Flutter-based marketplace application that supports both **users** and **merchants** on a single platform.  
Merchants can list products, create promotional posts, and host live streams, while users can browse content, place orders, and communicate directly with merchants.

The project is structured with a clear separation between UI, business logic, and data access to keep the codebase scalable and maintainable as features grow.

For an overview of the system architecture and design decisions, see:

- `docs/ARCHITECTURE.md`

---

## What this project includes

### User features

- Browse merchant posts and products
- View merchant profiles
- Shopping cart and checkout
- Order history and order status tracking
- Private chat with merchants
- Live stream browsing with featured products

### Merchant features

- Product management (create, edit, delete)
- Post management for promotions
- Order management and status updates
- Live stream creation and management
- Private chat with users

### Local data

- SQLite database with defined schema
- Seed data for local development and testing

---

## Quick start

### Prerequisites

- Flutter SDK installed
- Simulator/emulator or a physical device

### Run the app

```bash
flutter pub get
flutter run
```

### Useful commands

```bash
flutter analyze
flutter test
```

---

## Project structure (high level)

Common areas you’ll work in:

- **UI layer**: `lib/ui/`

  - Screens: `lib/ui/screens/`
  - Reusable widgets: `lib/ui/widgets/`

- **Service layer (business logic)**: `lib/domain/services/`

  - User-related services
  - Merchant-related services

- **Model layer**: `lib/domain/models/`

  - Raw models
  - DTOs
  - View models

- **Data layer**: `lib/data/`

  - Repositories: `lib/data/repositories/`
  - Table definitions: `lib/data/tables/`
  - Database setup and seed data: `lib/data/database/`

---

## Data & architecture overview

The app follows a straightforward, layered data flow:

**UI → Services → Repositories → Database**

- **UI** renders screens and handles user input.
- **Services** coordinate app logic, enforce rules, and prepare data for the UI.
- **Repositories** handle database reads and writes.
- **Database & tables** define the SQLite schema and persistence rules.

A lightweight caching layer is also used to reduce repeated database reads where appropriate.
More detailed explanations (model types, caching strategy, repository base patterns) are documented in:

- `docs/ARCHITECTURE.md`

---

## Development notes

### Local database

The app uses a local SQLite database. Schema initialization and seed logic live under:

- `lib/data/database/`

If you modify tables or seed data, you may need to delete the app from the simulator or device to reset the database.

### Media handling

Some flows reference local or picked media (images/videos). Ensure new assets are correctly registered in `pubspec.yaml` when added.

---

## Troubleshooting

### Database changes not reflected

If schema or seed data was updated:

- Delete the app from the simulator/emulator and rerun, or
- Clear the app’s storage on the device.

### Flutter tool issues

```bash
flutter doctor
```
