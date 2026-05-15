import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sc_synthesis/src/rust/api/database.dart';
import 'package:sc_synthesis/src/rust/api/model.dart';
import 'package:sc_synthesis/src/rust/frb_generated.dart';

/// Service wrapping the Rust backend — database operations via SQLite/FFI.
/// 100% offline — runs inside the app process, no server needed.
class RustDatabaseService {
  static final RustDatabaseService _instance = RustDatabaseService._();
  factory RustDatabaseService() => _instance;
  RustDatabaseService._();

  Database? _db;
  bool _initialized = false;
  int _totalShips = 0;

  bool get isInitialized => _initialized;
  int get totalShips => _totalShips;

  /// Initialize flutter_rust_bridge, open the SQLite DB, and seed from bundled JSON.
  Future<void> init() async {
    if (_initialized) return;

    // Initialize flutter_rust_bridge (loads native .so)
    await RustLib.init();

    // Determine DB path in app's document directory
    final docDir = await getApplicationDocumentsDirectory();
    final dbPath = '${docDir.path}/sc_synthesis.db';

    // Open the database (creates if not exists, runs migrations)
    _db = await Database.open(path: dbPath);

    // Seed with bundled data if DB is empty
    final hasShips = await _db!.hasShips();
    if (!hasShips) {
      final jsonString = await rootBundle.loadString('assets/data/ships.json');
      final imported = await _db!.importShips(json: jsonString);
      _totalShips = imported.toInt();
    } else {
      final count = await _db!.shipCount();
      _totalShips = count.toInt();
    }

    _initialized = true;
  }

  Database get db {
    if (!_initialized || _db == null) {
      throw StateError('RustDatabaseService not initialized. Call init() first.');
    }
    return _db!;
  }

  /// Get all ships
  Future<List<Ship>> getAllShips() => db.getAllShips();

  /// Search/filter ships
  Future<List<Ship>> searchShips({
    String query = '',
    String sizeFilter = '',
    String manufacturerFilter = '',
  }) => db.searchShips(
    query: query,
    sizeFilter: sizeFilter,
    manufacturerFilter: manufacturerFilter,
  );

  /// Get a single ship by ID
  Future<Ship?> getShipById(String id) => db.getShipById(id: id);

  /// Get available sizes
  Future<List<String>> getAvailableSizes() => db.getAvailableSizes();

  /// Get available manufacturers
  Future<List<String>> getAvailableManufacturers() => db.getAvailableManufacturers();

  /// Ship count
  Future<int> getShipCount() => db.shipCount().then((v) => v.toInt());
}
