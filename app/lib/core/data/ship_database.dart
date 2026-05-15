import 'dart:convert';
import 'package:flutter/services.dart';

/// A ship record from the bundled FleetYards data
class ShipData {
  final String id;
  final String name;
  final String slug;
  final String manufacturer;
  final String classification;
  final String focus;
  final int crewMin;
  final int crewMax;
  final double cargo;
  final double pledgePrice;
  final double maxSpeed;
  final String size;
  final String description;

  const ShipData({
    required this.id,
    required this.name,
    required this.slug,
    required this.manufacturer,
    required this.classification,
    required this.focus,
    required this.crewMin,
    required this.crewMax,
    required this.cargo,
    required this.pledgePrice,
    required this.maxSpeed,
    required this.size,
    required this.description,
  });

  factory ShipData.fromJson(Map<String, dynamic> json) {
    return ShipData(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      manufacturer: json['manufacturer'] as String? ?? '',
      classification: json['classification'] as String? ?? '',
      focus: json['focus'] as String? ?? '',
      crewMin: (json['crew_min'] as num?)?.toInt() ?? 1,
      crewMax: (json['crew_max'] as num?)?.toInt() ?? 1,
      cargo: (json['cargo'] as num?)?.toDouble() ?? 0.0,
      pledgePrice: (json['pledge_price'] as num?)?.toDouble() ?? 0.0,
      maxSpeed: (json['max_speed'] as num?)?.toDouble() ?? 0.0,
      size: json['size'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? '',
    );
  }

  String get fleetyardsUrl => 'https://fleetyards.net/ships/$slug';

  String get pledgePriceLabel =>
      pledgePrice > 0 ? '\$${pledgePrice.toStringAsFixed(0)}' : '';

  String get cargoLabel => cargo > 0 ? '${cargo.toStringAsFixed(0)} SCU' : '';

  String get crewLabel => crewMax > 1 ? '$crewMin-$crewMax crew' : '1 pilot';
}

/// Local ship database — loads from the bundled JSON asset.
/// 100% offline — no server needed.
class ShipDatabase {
  static final ShipDatabase _instance = ShipDatabase._();
  factory ShipDatabase() => _instance;
  ShipDatabase._();

  List<ShipData>? _allShips;
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// Load ships from the asset bundle. Call once at app startup or lazily.
  Future<void> load() async {
    if (_loaded) return;
    final jsonString = await rootBundle.loadString('assets/data/ships.json');
    final List<dynamic> list = json.decode(jsonString) as List<dynamic>;
    _allShips = list
        .map((e) => ShipData.fromJson(e as Map<String, dynamic>))
        .toList();
    _loaded = true;
  }

  /// Get all ships (call [load] first or use [ensureLoaded])
  List<ShipData> get all {
    assert(_loaded, 'ShipDatabase not loaded — call load() first');
    return _allShips!;
  }

  /// Get available size filters
  List<String> get availableSizes {
    final sizes = all.map((s) => s.size).toSet().toList();
    sizes.sort((a, b) => _sizeOrder(a).compareTo(_sizeOrder(b)));
    return sizes;
  }

  /// Get available manufacturers
  List<String> get availableManufacturers {
    final mfrs = all.map((s) => s.manufacturer).toSet().toList();
    mfrs.sort();
    return mfrs;
  }

  /// Search ships by query across name, manufacturer, and classification
  List<ShipData> search({
    String query = '',
    String? sizeFilter,
    String? manufacturerFilter,
  }) {
    var results = all;

    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      results = results
          .where(
            (s) =>
                s.name.toLowerCase().contains(q) ||
                s.manufacturer.toLowerCase().contains(q) ||
                s.classification.toLowerCase().contains(q) ||
                s.focus.toLowerCase().contains(q),
          )
          .toList();
    }

    if (sizeFilter != null && sizeFilter.isNotEmpty) {
      results = results
          .where((s) => s.size.toLowerCase() == sizeFilter.toLowerCase())
          .toList();
    }

    if (manufacturerFilter != null && manufacturerFilter.isNotEmpty) {
      results = results
          .where((s) => s.manufacturer == manufacturerFilter)
          .toList();
    }

    return results;
  }

  /// Find a single ship by ID
  ShipData? byId(String id) {
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Total ship count
  int get totalCount => all.length;

  static int _sizeOrder(String size) {
    switch (size.toLowerCase()) {
      case 'snub':
        return 0;
      case 'small':
        return 1;
      case 'medium':
        return 2;
      case 'large':
        return 3;
      case 'capital':
        return 4;
      default:
        return 5;
    }
  }
}
