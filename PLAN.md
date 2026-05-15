# SC:Synthesis — Star Citizen Companion App

## Vision

A mobile companion for Star Citizen that unifies fleet management, ship loadout planning, trade route optimization, and org management into one polished, offline-capable experience. The app that should exist but doesn't.

## Architecture

```
┌──────────────────────┐       ┌──────────────────────┐
│   Flutter App (Dart) │       │   Rust API Server     │
│                      │       │                      │
│   ┌──────────────┐   │ HTTP  │   ┌──────────────┐   │
│   │ Auth Screen  │◀──┼───────┼──▶│ Auth Proxy   │   │
│   └──────────────┘   │       │   └──────┬───────┘   │
│   ┌──────────────┐   │       │          │           │
│   │ Fleet Viewer │◀──┼───────┼──▶ RSI Website       │
│   └──────────────┘   │       │          │           │
│   ┌──────────────┐   │       │   ┌──────┴───────┐   │
│   │ Loadout Lab  │◀──┼───────┼──▶│ P4K Extractor│   │
│   └──────────────┘   │       │   └──────────────┘   │
│   ┌──────────────┐   │       │   ┌──────────────┐   │
│   │ Trade Routes │◀──┼───────┼──▶│ UEX/Pricing  │   │
│   └──────────────┘   │       │   └──────────────┘   │
│   ┌──────────────┐   │       │   ┌──────────────┐   │
│   │ Org Hub      │◀──┼───────┼──▶│ Spectrum API │   │
│   └──────────────┘   │       │   └──────────────┘   │
│                      │       │   ┌──────────────┐   │
│   ┌──────────────┐   │       │   │  SQLite DB   │   │
│   │ Local Cache  │◀──┼───────┼──▶│ (data store) │   │
│   └──────────────┘   │       │   └──────────────┘   │
└──────────────────────┘       └──────────────────────┘
```

### Stack

| Layer | Technology | Version |
|---|---|---|
| Frontend | Flutter (Dart) | 3.41.9 / Dart 3.11.5 |
| Backend | Rust | 1.95.0 |
| API Framework | Axum | latest |
| Scraping | reqwest + scraper | latest |
| Database | SQLite (sqlx) | 3.53.1 |
| State Mgmt | Riverpod | latest |
| Nav | GoRouter | latest |
| Local DB | drift (SQLite) | latest |

---

## Feature Modules

### Phase 1 — MVP (Foundation)

| Module | Backend | Frontend | Description |
|---|---|---|---|
| **Auth Proxy** | ✅ Rust | ✅ Flutter | RSI login via session cookie proxy. User enters credentials in Flutter → Rust proxies to RSI → returns session. Rust stores sessions server-side, never exposes raw token to client. |
| **Fleet Manager** | ✅ Rust | ✅ Flutter | Import pledges/ships from RSI account. View fleet with value, count, manufacturer breakdown. No manual entry needed. |
| **Ship Database** | ✅ Rust | ✅ Flutter | All ships + stats from Data.p4k extraction. Browse, search, filter by manufacturer/size/role. |
| **Loadout Lab** | ❌ Rust | ✅ Flutter | Local-only for MVP. Ship loadout builder with component browser. Save loadouts locally on device (drift). |

### Phase 2 — Trading & Economy

| Module | Backend | Frontend | Description |
|---|---|---|---|
| **Trade Routes** | ✅ Rust | ✅ Flutter | Commodity prices (crowdsourced path), route optimizer, profit calculators. |
| **Market Alerts** | ✅ Rust | ✅ Flutter | Push notifications when a route hits peak profitability. |

### Phase 3 — Community

| Module | Backend | Frontend | Description |
|---|---|---|---|
| **Org Hub** | ✅ Rust | ✅ Flutter | Org roster, fleet composition, member activity. |
| **Spectrum Bridge** | ✅ Rust | ✅ Flutter | See org announcements in-app. |
| **CCU Planner** | ✅ Rust | ✅ Flutter | Visual upgrade path planner with melt/exchange calculator. |

---

## Data Models (Core)

```rust
// Rust models (server/src/data/models.rs)

struct Ship {
    id: String,              // game ID (e.g. "ANVL_C8")
    name: String,            // "C8 Pisces"
    manufacturer: String,    // "Anvil Aerospace"
    size: ShipSize,          // Vehicle, Small, Medium, Large, Capital
    role: String,            // "Pathfinder", "Cargo", "Fighter"
    crew_min: i32,
    crew_max: i32,
    cargo_capacity: f64,     // SCU
    price: f64,              // aUEC
    pledge_price: f64,       // USD
    max_speed: f64,
    shield_hp: f64,
    hull_hp: f64,
    // ... component hardpoints, weapon mounts, etc.
}

struct Pledge {
    id: String,
    name: String,
    ship_id: String,
    pledge_price: f64,
    insured: bool,
    buyback: bool,
    melt_value: f64,
}

struct Component {
    id: String,
    name: String,
    category: ComponentCategory, // PowerPlant, Cooler, Shield, QuantumDrive, Weapon
    size: i32,
    manufacturer: String,
    // ... size-specific stats
}

struct TradeRoute {
    from: String,
    to: String,
    commodity: String,
    buy_price: f64,
    sell_price: f64,
    profit_per_scu: f64,
    distance: f64,           // Gm (quantum travel)
    risk: RiskLevel,
}
```

---

## API Endpoints (Version 1)

```
POST   /api/v1/auth/login        # RSI login proxy
POST   /api/v1/auth/verify       # Verify 2FA
DELETE /api/v1/auth/logout       # Destroy session

GET    /api/v1/fleet              # Your pledges/ships
GET    /api/v1/fleet/value        # Fleet valuation

GET    /api/v1/ships              # All ships (from game data)
GET    /api/v1/ships/:id          # Single ship with stats
GET    /api/v1/ships/:id/loadouts # Community loadouts (future)

GET    /api/v1/components         # All components
GET    /api/v1/components/:id     # Single component

GET    /api/v1/commodities        # All commodities
GET    /api/v1/routes             # Trading routes

GET    /api/v1/orgs/:sid          # Org info
GET    /api/v1/orgs/:sid/members  # Org roster
GET    /api/v1/orgs/:sid/fleet    # Org fleet composition

GET    /api/v1/status             # Server health
GET    /api/v1/version            # Data version info
```

---

## Directory Structure

```
sc-synthesis/
├── server/                    # Rust backend
│   ├── Cargo.toml
│   └── src/
│       ├── main.rs            # Entry point + server bootstrap
│       ├── config.rs          # App configuration
│       ├── api/               # REST handlers
│       │   ├── mod.rs
│       │   ├── auth.rs
│       │   ├── fleet.rs
│       │   ├── ships.rs
│       │   ├── components.rs
│       │   ├── trading.rs
│       │   └── orgs.rs
│       ├── scraping/          # RSI web scraping layer
│       │   ├── mod.rs
│       │   ├── auth.rs        # Login, session, Turnstile
│       │   ├── pledges.rs     # Ship/pledge data
│       │   └── orgs.rs        # Org data
│       ├── data/              # Game data models + P4K
│       │   ├── mod.rs
│       │   ├── models.rs      # All data structures
│       │   └── p4k.rs         # Data.p4k extraction
│       └── db/                # Database layer
│           ├── mod.rs
│           └── queries.rs     # SQL queries
├── app/                       # Flutter mobile app
│   ├── pubspec.yaml
│   └── lib/
│       ├── main.dart
│       ├── app.dart           # MaterialApp + router setup
│       ├── core/              # Shared infrastructure
│       │   ├── api/           # HTTP client, API service
│       │   ├── theme/         # SC:Synthesis design system
│       │   ├── storage/       # Local DB (drift)
│       │   └── widgets/       # Shared UI components
│       ├── features/          # Feature modules
│       │   ├── auth/
│       │   ├── fleet/
│       │   ├── ships/
│       │   ├── components/
│       │   ├── trading/
│       │   └── org/
│       └── data/              # Data layer
│           ├── models/        # Dart data classes
│           └── repositories/  # Data source abstraction
├── docs/                      # Documentation
├── scripts/                   # Dev scripts
└── PLAN.md                    # This file
```

---

## Build Order (What We Ship First)

### Week 1 — Foundation
1. Rust server scaffold (Axum, config, DB)
2. Auth proxy proof-of-concept (RSI login + Turnstile handling)
3. Flask test: can we pull pledge data from RSI?

### Week 2 — Fleet Manager MVP
4. Fleet scraping (pledge list from session-authenticated user)
5. Fleet API endpoint
6. Flutter scaffold (navigation, theming, API client)
7. Auth screen in Flutter
8. Fleet screen — ship list with basic stats

### Week 3 — Ship Data Pipeline
9. P4K extraction pipeline (ship stats, components)
10. Ship database population
11. Ship browser screen in Flutter
12. Ship detail screen

### Week 4 — Loadout Lab
13. Component database + search
14. Loadout builder UI
15. Local save/load for loadouts

### Phase 2+ — Trading, Orgs, CCU

---

## Design Principles

- **Offline-first:** Game data (ships, components, commodities) should work without internet. Only RSI-synced data (your fleet) needs a connection.
- **Privacy-first:** User credentials never touch the Flutter app directly — they flow through the Rust proxy. Session tokens are server-side only. No analytics, no tracking.
- **Neon aesthetic:** Dark theme, synthwave accents (cyan/magenta/amber), data visualizations with glow effects. This is a spaceship dashboard, not a spreadsheet.
- **Fast over feature-rich:** Ship a polished, narrow experience before a bloated, buggy wide one.
