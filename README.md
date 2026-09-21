# CrispyDesk

Point-of-sale (POS) system for managing sales, inventory and cash for a business.

## Repository structure

```
.
├── backend/    Express + TypeScript + Prisma + PostgreSQL (REST API)
└── frontend/   Flutter (Web + Android), Riverpod, Clean Architecture
```

## Features

- **Users**: Administrador/Cajera roles, self-service password change, admin password reset.
- **Products**: full CRUD, categories (Pollo/Bebida/Acompañamiento), stock tracking, per-product photo (camera or gallery).
- **Sales**: shopping cart, chicken cut selection (Pecho/Ala or Pierna/Entrepierna), multi-select side dishes, payment method (Efectivo/QR/Mixto) with correct cash-drawer math.
- **Cierre de Caja**: end-of-shift cash/QR reconciliation.
- **Gastos**: expense tracking feeding into real-profit calculation.
- **Estadísticas & Reportes**: daily summary and date-range reports.
- **Offline read cache**: Products and sales history stay viewable without a connection (read from a local Drift database; writes always go to the backend).

## Backend (`backend/`)

Node.js + Express + TypeScript, with Prisma as the ORM over PostgreSQL. JWT authentication and bcrypt password hashing.

**Main models**: `User`, `Producto`, `Venta`, `DetalleVenta`, `Cierre`, `Gasto`.

### Local setup

1. Copy `backend/.env.example` to `backend/.env` and fill in:
   ```
   DATABASE_URL="postgresql://user:password@localhost:5432/crispydesk?schema=public"
   JWT_SECRET="a long random string"
   PORT=3000
   SEED_ADMIN_EMAIL="admin@crispydesk.local"
   SEED_ADMIN_PASSWORD="************"
   ```
2. Install dependencies and apply migrations:
   ```bash
   cd backend
   npm install
   npx prisma migrate dev
   npx tsx prisma/seed.ts   # creates the first admin user
   ```
3. Start the dev server:
   ```bash
   npm run dev
   ```

### Deployment

Includes a `Dockerfile` ready for platforms like Railway. On container startup, pending migrations are applied (`prisma migrate deploy`) and the admin seed runs before the server starts, so it's safe to redeploy without losing data.

## Frontend (`frontend/`)

Flutter application using Riverpod for state management and Clean Architecture (`domain` / `data` / `presentation`) per feature. Runs on both Web and Android.

### Local setup

```bash
cd frontend
flutter pub get
flutter run -d web-server --web-port 8081 --dart-define=BACKEND_BASE_URL=http://localhost:3000
```

The backend URL is configurable at build time (defaults to `http://localhost:3000`):

```bash
flutter build web --dart-define=BACKEND_BASE_URL=https://your-backend.up.railway.app
flutter build apk --release --dart-define=BACKEND_BASE_URL=https://your-backend.up.railway.app
```

### Local persistence

The app keeps a local Drift database (`CachedProductos`, `CachedVentas`, `CachedDetalleVentas`) as a read-only cache: it always tries the backend first, and falls back to the last saved data when offline. There is no offline write queue.

## Tech stack

Flutter · Riverpod · Drift · Express · TypeScript · Prisma · PostgreSQL · Docker · Railway
