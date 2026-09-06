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

<p align="center">
  <img src="https://github.com/synthalorian/sc-synthesis/raw/main/.github/SC-Synthesis-banner.png" alt="SC:Synthesis — Offline Star Citizen Companion" width="600">
</p>

<p align="center">
  <a href="https://buymeacoffee.com/synthalorian"><img src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-☕-ff69b4?style=flat-square" alt="Buy Me a Coffee"></a>
  <img src="https://img.shields.io/badge/ships-238-00f0ff?style=flat-square" alt="238 Ships">
  <img src="https://img.shields.io/badge/status-offline-00f0ff?style=flat-square" alt="Offline">
  <img src="https://img.shields.io/badge/Flutter-3.11+-02569B?style=flat-square&logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Rust-💪-DEA584?style=flat-square&logo=rust" alt="Rust">
</p>

> SC:Synthesis brings the full Star Citizen ship database to your pocket (or
> desktop) with a retro-synthwave aesthetic, native Rust performance, and zero
> network requirements. **No server, no API calls, no internet needed.**

---

## Features

  🛸   **238 ships, 100% offline** — The complete FleetYards ship catalog is
       bundled in a local SQLite database via a Rust FFI bridge. No network
       calls. Never. Works on a plane, in a bunker, or in the black.

  ⚡   **Rust-native performance** — Search, filter, and sort 200+ ships
       through a Rust `rusqlite` backend exposed to Flutter via
       `flutter_rust_bridge`. Sub-millisecond queries on-device.

  🔎   **Ship browser** — Full-text search by name or manufacturer, filter
       by size (Small, Medium, Large, Capital), filter by manufacturer, sort
       by name, price, or size. Instant results.

  ✨   **Ship detail screens** — Glassmorphism synthwave design with full
       stats (crew, cargo capacity, speed, weapons, shields), description,
       manufacturer info, and price. One-tap link to FleetYards.net for
       complete specifications.

  📊   **Ship comparison** — Compare 2–3 ships side by side with stat bars.
       Pick ships from the browser or your fleet, see which one has more
       firepower, cargo space, or quantum fuel.

  🛡️   **Local Fleet Manager** — Track ships you own and build a wishlist.
       Everything is stored in SharedPreferences — no account, no login, no
       sync. Just your fleet, locally.

  📝   **Per-ship personal notes** — Add custom notes to any ship on its
       detail screen. Jot down loadout ideas, upgrade plans, or just your
       thoughts. Saved locally.

  🎨   **6 retro themes** — Synthwave '84 (default), OutRun, Vaporwave,
       Cyberpunk, Dark, and Light. Switch on the fly from the Settings tab
       — no restart needed.

  ⚙️   **Settings & About** — App version, local database stats (ships
       loaded, cached entries), theme picker, Buy Me a Coffee link, and
       credits. All in one place.

  🔗   **FleetYards.net integration** — One-tap links from every ship card
       to the FleetYards web page for community reviews, pledge store
       prices, and detailed component specs.

  🌙   **Shimmer loading** — Skeleton shimmer placeholders while the SQLite
       database initialises on first launch.

---

## Screenshots

```
  ┌──────────────────────┐  ┌──────────────────────┐  ┌──────────────────────┐
  │  [screenshot_01.png] │  │  [screenshot_02.png] │  │  [screenshot_03.png] │
  │   Ship List          │  │   Ship Detail         │  │   Ship Comparison    │
  │   (Synthwave '84)    │  │   (Glassmorphism)     │  │   (Cyberpunk theme)  │
  └──────────────────────┘  └──────────────────────┘  └──────────────────────┘
```

*Screenshots will be added after the first public release.*

---

## Architecture

```
  ┌──────────────────────────────────────────────────────────────────┐
  │                      SC:Synthesis App                            │
  │  ┌────────────────────────────────────────────────────────────┐  │
  │  │                  Flutter (Dart) Layer                      │  │
  │  │                                                            │  │
  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌───────────┐ │  │
  │  │  │  Fleet   │  │  Ships   │  │ Compare  │  │ Settings  │ │  │
  │  │  │  Screen  │  │  Screen  │  │  Screen  │  │ & About   │ │  │
  │  │  └────┬─────┘  └────┬─────┘  └────┬─────┘  └─────┬─────┘ │  │
  │  │       │              │             │               │       │  │
  │  │  ┌────▼──────────────▼─────────────▼───────────────▼─────┐ │  │
  │  │  │                  Core / Services                      │ │  │
  │  │  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐  │ │  │
  │  │  │  │  Database    │  │   Fleet      │  │   Theme    │  │ │  │
  │  │  │  │  Service     │  │   Manager    │  │   Manager  │  │ │  │
  │  │  │  │ (Rust SQLite)│  │ (SharedPrefs)│  │            │  │ │  │
  │  │  │  └──────┬───────┘  └──────────────┘  └────────────┘  │ │  │
  │  │  └─────────┼────────────────────────────────────────────┘ │  │
  │  └────────────┼──────────────────────────────────────────────┘  │
  │               │                                                  │
  │  ┌────────────▼──────────────────────────────────────────────┐  │
  │  │  flutter_rust_bridge  •  FFI  •  auto-generated bindings  │  │
  │  └──────────────────────────┬────────────────────────────────┘  │
  │                             │                                    │
  │  ┌──────────────────────────▼────────────────────────────────┐  │
  │  │                  Rust Bridge Crate                         │  │
  │  │  sc_synthesis_bridge — compiled to .so / .dylib / .dll    │  │
  │  │                                                            │  │
  │  │  ┌────────────────┐  ┌────────────────┐                   │  │
  │  │  │  rusqlite      │  │  serde / json  │                   │  │
  │  │  │  (embedded DB) │  │  (ship models) │                   │  │
  │  │  └────────────────┘  └────────────────┘                   │  │
  │  └───────────────────────────────────────────────────────────┘  │
  │                                                                  │
  │  ┌───────────────────────────────────────────────────────────┐  │
  │  │  Assets — ships.json (238 ships, bundled at compile time)  │  │
  │  └───────────────────────────────────────────────────────────┘  │
  └──────────────────────────────────────────────────────────────────┘
```

**No server. No backend. No network.** The entire ship catalog is bundled
at compile time and seeded into an embedded SQLite database on first launch.
The Fleet Manager (owned ships + wishlist + notes) lives in Dart-side
SharedPreferences. The Rust bridge handles all ship queries — search,
filter, sort, and detail lookups — through a single `RustDatabaseService`
abstraction.

---

## Quick Start

### Prerequisites

- **Flutter SDK** 3.11+ (`flutter doctor` should pass)
- **Rust toolchain** (rustup, stable)
- **Cargokit** (included in `rust_builder/` — no manual install needed)

### 1. Clone & enter

```bash
git clone https://github.com/synthalorian/sc-synthesis.git
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

The binary lives in `app/build/linux/x64/release/bundle/`. Package with your
favourite tool (e.g. `makeself`, `dpkg-deb`, or `linuxdeploy`).

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
│   │   │   ├── data/                    # RustDatabaseService, FleetManager
│   │   │   ├── theme/                   # 6 themes + app_theme.dart
│   │   │   │   └── themes/              # synthwave84, outrun, vaporwave, ...
│   │   │   └── widgets/                 # FleetYardsLink, ShimmerLoading, StatBar
│   │   └── features/
│   │       ├── fleet/                   # Fleet dashboard screen
│   │       ├── ships/                   # Ship list + ship detail + comparison
│   │       └── settings/                # Settings & About tab
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
├── README.md
└── .gitignore
```

---

## Tech Stack

| Layer             | Technology                                           |
|-------------------|------------------------------------------------------|
| **UI Framework**  | Flutter 3.11+ • Dart 3.x                             |
| **State**         | Riverpod 2.x (flutter_riverpod, riverpod_annotation) |
| **Navigation**    | go_router 14.x                                       |
| **Native Bridge** | flutter_rust_bridge 2.12  •  FFI  •  Cargokit       |
| **Rust**          | rusqlite 0.32 (bundled SQLite), serde, chrono, uuid  |
| **Database**      | SQLite (bundled per-platform binary via rusqlite)     |
| **Local Storage** | SharedPreferences (fleet, wishlist, notes, settings) |
| **Data Source**   | Bundled `ships.json` (frozen FleetYards snapshot)    |
| **Charts**        | fl_chart 0.70 (comparison stat bars)                 |
| **Animation**     | flutter_animate 4.x                                  |
| **Links**         | url_launcher (FleetYards.net deep links)             |

**Network required:** Never. Zero. The app makes zero HTTP calls at runtime.

---

## Themes

SC:Synthesis ships with **six hand-crafted themes** inspired by the
synthwave / outrun / cyberpunk aesthetic.

| Theme           | Palette Highlights                              | Default? |
|-----------------|--------------------------------------------------|----------|
| **Synthwave84** | Neon pink #ff2d95, cyan #00f0ff, deep purple     | Yes      |
| **OutRun**      | Sunset orange #ff6b35, magenta #e91e63            |          |
| **Vaporwave**   | Pastel teal #00ced1, lavender #b388ff             |          |
| **Cyberpunk**   | Acid green #39ff14, electric yellow #ffe74c       |          |
| **Dark**        | Slate grey, subtle accent                         |          |
| **Light**       | Clean off-white, low-contrast for daylight        |          |

Switch themes at runtime from the Settings tab — no restart required.

---

## Contributing

Contributions are welcome! Here's how to get started:

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

- Additional theme contributions
- iOS/macOS build verification and CI
- WebAssembly (wasm) support for the Rust bridge
- More comparison stat visualisations
- Localisation (i18n)
- Tests — unit, widget, integration

---

## Support

If you find SC:Synthesis useful, consider buying me a coffee:

<p align="center">
  <a href="https://buymeacoffee.com/synthalorian">
    <img src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-☕-ff69b4?style=for-the-badge" alt="Buy Me a Coffee">
  </a>
</p>

---

## Credits

Developed by **synth** with assistance from **synthshark** 🎹🦈 — a digital entity from the neon grid of 1984.

---

*"Every city tells a story. Your repo is no different."* 🌆

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

<p align="center">
  <i>Fly safe, Citizen.  o7</i>
</p>
