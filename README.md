                                   _      _   _
                                  | |    (_) | |
  ___  ___  ___  ___   ___ ___  __| | ___ _| |_(_)_ __   __ _
 / __|/ __|/ _ \/ __| / __/ _ \/ _` |/ __| | __| | '_ \ / _` |
 \__ \ (__|  __/ (__ | (_|  __/ (_| | (__| | |_| | | | | (_| |
 |___/\___|\___|\___(_)___\___|\__,_|\___|_|\__|_|_| |_|\__, |
              _____       _ _   _              _          __/ |
             / ____|     (_) | | |            (_)        |___/
            | (___  _ __  _| |_| |__  _ __ ___ _ _ __   ___
             \___ \| '_ \| | __| '_ \| '__/ __| | '_ \ / _ \
             ____) | | | | | |_| | | | | | (__| | | | |  __/
            |_____/|_| |_|_|\__|_| |_|_|  \___|_|_| |_|\___|

                     A Star Citizen Companion App
             ~ synthwave ships, offline-first, Rust-fast ~

[!NOTE]
> SC:Synthesis brings the SC ship database to your pocket (or desktop)
> with a retro-synthwave aesthetic, native Rust performance, and full
> offline capability. No server required except for RSI fleet sync.

---

## Screenshots

```
  ┌──────────────────────┐  ┌──────────────────────┐  ┌──────────────────────┐
  │  [screenshot_01.png] │  │  [screenshot_02.png] │  │  [screenshot_03.png] │
  │   Ship List          │  │   Ship Detail         │  │   Fleet Dashboard    │
  │   (Synthwave '84)    │  │   (Glassmorphism)     │  │   (OutRun theme)     │
  └──────────────────────┘  └──────────────────────┘  └──────────────────────┘
```

*Screenshots will be added after the first public release.*

---

## Features

  🚀   **238 ships, offline** — Full FleetYards ship catalog bundled as JSON,
       seeded into a local SQLite database via the Rust FFI bridge.  No network
       needed once the app is installed.

  ⚡   **Rust-native performance** — Search, filter, and sort 200+ ships
       through a Rust rusqlite backend exposed to Flutter via
       flutter_rust_bridge.  Sub-millisecond queries.

  🎨   **6 synthwave / cyberpunk themes** — Synthwave '84 (default), OutRun,
       Vaporwave, Cyberpunk, Dark, and Light.  Toggle on the fly from the
       floating palette button.

  🔎   **Ship browser** — Full-text search, filter by size (Small, Medium,
       Large, Capital), filter by class (Fighter, Explorer, Industrial, etc.),
       sort by name, price, or size.

  ✨   **Ship detail — Frosted glass design** — Each ship gets a glassmorphism
       detail screen with stats (crew, cargo, speed, weapons), a
       high-resolution render, and quick links to FleetYards.net.

  🔗   **FleetYards.net integration** — Every ship card links out to the
       FleetYards web page for full specifications, community reviews, pledge
       store prices, and the ship comparison tool.

  🛡️   **RSI account sync (optional)** — Run the companion server to scrape
       your RSI hangar via headless Chrome (handles Cloudflare Turnstile) and
       map purchased pledges to ships.  Your fleet, shown locally.

  🌙   **Shimmer loading** — Skeleton shimmer placeholders while the SQLite
       database initialises on first launch.

---

## Architecture

```
  ┌─────────────────────────────────────────────────────────────────────┐
  │                        SC:Synthesis App                            │
  │  ┌───────────────────────────────────────────────────────────────┐  │
  │  │                    Flutter (Dart) Layer                       │  │
  │  │                                                               │  │
  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐                    │  │
  │  │  │  Fleet   │  │  Ships   │  │  Auth    │                    │  │
  │  │  │  Screen  │  │  Screen  │  │  Screen  │  ...               │  │
  │  │  └────┬─────┘  └────┬─────┘  └────┬─────┘                    │  │
  │  │       │              │             │                          │  │
  │  │  ┌────▼──────────────▼─────────────▼──────────────────────┐  │  │
  │  │  │              Core / Services                           │  │  │
  │  │  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │  │  │
  │  │  │  │  API Client  │  │   Database   │  │    Theme     │  │  │  │
  │  │  │  │   (Dio)      │  │   Service    │  │   Manager    │  │  │  │
  │  │  │  └──────┬───────┘  └──────┬───────┘  └──────────────┘  │  │  │
  │  │  └─────────┼──────────────────┼────────────────────────────┘  │  │
  │  └────────────┼──────────────────┼───────────────────────────────┘  │
  │               │                  │                                   │
  │  ┌────────────▼──────────────────▼───────────────────────────────┐  │
  │  │  flutter_rust_bridge  •  FFI  •  auto-generated bindings      │  │
  │  └──────────────────────────┬────────────────────────────────────┘  │
  │                             │                                        │
  │  ┌──────────────────────────▼────────────────────────────────────┐  │
  │  │                    Rust Bridge Crate                           │  │
  │  │  sc_synthesis_bridge — compiled to .so / .dylib / .dll        │  │
  │  │                                                               │  │
  │  │  ┌────────────────┐  ┌────────────────┐                      │  │
  │  │  │  rusqlite      │  │  serde / json   │                      │  │
  │  │  │  (embedded DB) │  │  (ship models)  │                      │  │
  │  │  └────────────────┘  └────────────────┘                      │  │
  │  └───────────────────────────────────────────────────────────────┘  │
  │                                                                     │
  │  ┌───────────────────────────────────────────────────────────────┐  │
  │  │  Assets — ships.json (238 ships, bundled at compile time)      │  │
  │  └───────────────────────────────────────────────────────────────┘  │
  └─────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────┐
  │              Optional: SC:Synthesis Server                          │
  │  (axum HTTP server — only needed for RSI fleet sync)                │
  │                                                                    │
  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐   │
  │  │  Auth API  │  │ Fleet API  │  │ Scraper    │  │   SQLite   │   │
  │  │  (axum)    │  │  (axum)    │  │ (chromium  │  │   (sqlx)   │   │
  │  │            │  │            │  │ oxide)     │  │            │   │
  │  └────────────┘  └────────────┘  └────────────┘  └────────────┘   │
  └─────────────────────────────────────────────────────────────────────┘
```

---

## Quick Start

### Prerequisites

- **Flutter SDK** 3.11+ (`flutter doctor` should pass)
- **Rust toolchain** (rustup, stable)
- **Cargokit** (included in `rust_builder/` — no manual install needed)
- For the optional server: Chromium/Chrome (headless), OpenSSL

### 1. Clone & enter

```bash
git clone https://github.com/your-org/sc-synthesis.git
cd sc-synthesis
```

### 2. Generate FFI bindings

```bash
cd app
flutter pub get
flutter_rust_bridge_codegen generate
```

*Note: If you cloned from a published release, the generated Dart bindings in
`lib/src/rust/` are pre-committed and you can skip this step.*

### 3. Run (Linux desktop)

```bash
cd app
flutter run -d linux
```

### 4. Run (Android)

```bash
cd app
flutter run
```

Make sure you have a device connected or an emulator running.

---

## Build for Distribution

### Android APK / App Bundle

```bash
cd app
flutter build apk --release             # universal APK
flutter build appbundle --release        # Play Store AAB
```

APK output: `app/build/app/outputs/flutter-apk/`
AAB output: `app/build/app/outputs/bundle/release/`

### Linux (native .deb / AppImage)

```bash
cd app
flutter build linux --release
```

The binary lives in `app/build/linux/x64/release/bundle/`.  Package with your
favourite tool (e.g. `makeself`, `dpkg-deb`, or `linuxdeploy`).

### Web

```bash
cd app
flutter build web --release
```

*Note: The Rust bridge uses FFI — web builds require wasm support
(experimental).  For a fully offline web experience, a pure-Dart SQLite
fallback is planned.*

### iOS / macOS

```bash
cd app
flutter build ios --release             # requires Xcode
flutter build macos --release           # requires macOS + Xcode
```

---

## Project Structure

```
sc-synthesis/
├── app/                                  # Flutter application
│   ├── lib/
│   │   ├── main.dart                    # Entry point
│   │   ├── app.dart                     # App shell: bottom nav, theme selector
│   │   ├── src/
│   │   │   └── rust/                    # (AUTO-GENERATED) FRB bindings
│   │   ├── core/
│   │   │   ├── api/                     # Dio client, auth manager, endpoints
│   │   │   ├── data/                    # RustDatabaseService, legacy ShipDatabase
│   │   │   ├── theme/                   # 6 themes + app_theme.dart
│   │   │   │   └── themes/              # synthwave84, outrun, vaporwave, ...
│   │   │   └── widgets/                 # FleetYardsLink, ShimmerLoading
│   │   └── features/
│   │       ├── fleet/                   # Fleet dashboard screen
│   │       ├── ships/                   # Ship list + ship detail
│   │       └── auth/                    # RSI login form
│   ├── rust/                            # Rust bridge crate
│   │   ├── src/api/
│   │   │   ├── model.rs                # Ship struct (serde)
│   │   │   └── database.rs             # SQLite open, migrate, search, import
│   │   └── Cargo.toml
│   ├── rust_builder/                    # (AUTO-GENERATED) Cargokit harness
│   ├── assets/
│   │   └── data/ships.json             # 238 ships, bundled offline
│   ├── pubspec.yaml
│   └── flutter_rust_bridge.yaml
│
├── server/                              # Optional Rust backend
│   ├── src/
│   │   ├── main.rs
│   │   ├── api/                        # Auth, fleet, ships endpoints (axum)
│   │   ├── scraping/                   # RSI headless auth, FleetYards scraping
│   │   ├── data/models.rs              # Ship, Pledge, Component, Commodity
│   │   ├── db/                         # SQLx migrations + queries
│   │   └── config.rs
│   └── Cargo.toml
│
├── README.md
└── .gitignore
```

---

## Tech Stack

| Layer             | Technology                                             |
|-------------------|--------------------------------------------------------|
| **UI Framework**  | Flutter 3.11+ • Dart 3.x                               |
| **State**         | Riverpod 2.x (flutter_riverpod, riverpod_annotation)   |
| **Navigation**    | go_router 14.x                                         |
| **Networking**    | dio 5.x  +  url_launcher                              |
| **Native Bridge** | flutter_rust_bridge 2.12  •  FFI  •  Cargokit         |
| **Rust**          | rusqlite 0.32 (bundled SQLite), serde, chrono, uuid    |
| **Database**      | SQLite (bundled per-platform binary via rusqlite)       |
| **Data Source**   | FleetYards.net REST API (frozen snapshot of 238 ships)  |
| **Charts**        | fl_chart 0.70                                          |
| **Animation**     | flutter_animate 4.x                                    |
| **Server**        | axum 0.8  •  tokio  •  sqlx  •  chromiumoxide         |
| **Auth/Sync**     | Headless Chrome scraping (Cloudflare Turnstile bypass) |

---

## Themes

SC:Synthesis ships with **six hand-crafted themes** inspired by the
synthwave / outrun / cyberpunk aesthetic.

| Theme           | Palette Highlights                              | Default? |
|-----------------|--------------------------------------------------|----------|
| **Synthwave84** | Neon pink #ff2d95, cyan #00f0ff, deep purple     | Yes      |
| **OutRun**      | Sunset orange #ff6b35, magenta #e91e63             |          |
| **Vaporwave**   | Pastel teal #00ced1, lavender #b388ff              |          |
| **Cyberpunk**   | Acid green #39ff14, electric yellow #ffe74c        |          |
| **Dark**        | Slate grey, subtle accent                          |          |
| **Light**       | Clean off-white, low-contrast for daylight         |          |

Switch themes at runtime via the floating action palette button
(I.palette_outlined) on the home screen — no restart required.

---

## Server (Optional — RSI Fleet Sync)

The app works entirely offline without the server.  You only need to run the
server if you want to sync your **RSI account fleet** (i.e. pledge-to-ship
mapping from your hangar).

### Why a separate server?

RSI uses Cloudflare Turnstile (browser challenge) on its login page, which
prevents simple HTTP POST scraping.  The server uses **headless Chromium**
(via the `chromiumoxide` crate) to automate the login flow, then scrapes the
protected hangar page.

### Running the server

```bash
cd server

# 1. Configure (create .env or use defaults)
cp .env.example .env
# Edit RSI_USERNAME and RSI_PASSWORD if desired

# 2. Run
cargo run
```

The server starts on `http://localhost:3000`.

### Endpoints

| Method | Path                | Description                        |
|--------|---------------------|------------------------------------|
| POST   | `/api/auth`         | Authenticate with RSI credentials  |
| GET    | `/api/fleet`        | Return scraped fleet (ships list)  |
| GET    | `/api/fleet/sync`   | Force re-scrape from RSI hangar    |
| GET    | `/api/ships`        | FleetYards ship catalog (proxy)    |

### Configuration

All config is in `server/src/config.rs` and overridable via environment
variables or a `.env` file:

| Variable                  | Default               | Description                     |
|---------------------------|-----------------------|---------------------------------|
| `SERVER_HOST`             | `127.0.0.1`           | Bind address                    |
| `SERVER_PORT`             | `3000`                | Listen port                     |
| `DATABASE_URL`            | `sc_synthesis.db`     | SQLite path                     |
| `CHROMIUM_PATH`           | `chromium`            | Path to Chromium/Chrome binary  |
| `RSI_USERNAME`            | —                     | RSI login (or prompt at /auth)  |
| `RSI_PASSWORD`            | —                     | RSI password (or prompt)        |

---

## Contributing

Contributions are welcome!  Here's how to get started:

1. **Fork** the repository on GitHub.
2. **Create a feature branch** (`git checkout -b feat/my-cool-thing`).
3. **Make your changes** — see the architecture diagram above for guidance
   on where code lives.
4. **Run the linter & tests:**
   ```bash
   cd app
   flutter analyze
   flutter test
   ```
5. **Commit with a descriptive message** — conventional commits encouraged.
6. **Open a pull request** against `main`.

### Code style

- Dart: follow `flutter_lints` (included in `pubspec.yaml`).
- Rust: `rustfmt` with default settings.
- Keep the Flutter UI layer free of Rust FFI calls; go through the
  `RustDatabaseService` abstraction in `core/data/`.

### What needs help?

- Additional theme contributions (e.g. Cyberpunk 2077 palette)
- iOS/macOS build verification and CI
- WebAssembly (wasm) support for the Rust bridge
- Ship comparison view with fl_chart radar plots
- Localisation (i18n)
- Tests — unit, widget, integration

---

## License

```
MIT License

Copyright (c) 2025 SC:Synthesis Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

*Fly safe, Citizen.  o7*
