import 'dart:convert';
import 'package:flutter/services.dart';

/// Offline reference data service — loads factions, missions, locations,
/// and commodities from bundled JSON assets. Singleton pattern matching
/// the existing [ShipDatabase].
class ReferenceDatabase {
  static final ReferenceDatabase _instance = ReferenceDatabase._();
  factory ReferenceDatabase() => _instance;
  ReferenceDatabase._();

  List<Map<String, dynamic>> _factions = [];
  List<Map<String, dynamic>> _missions = [];
  List<Map<String, dynamic>> _locations = [];
  List<Map<String, dynamic>> _commodities = [];
  List<Map<String, dynamic>> _components = [];
  List<Map<String, dynamic>> _stores = [];
  List<Map<String, dynamic>> _tools = [];
  List<Map<String, dynamic>> _miningGadgets = [];
  List<Map<String, dynamic>> _salvageData = [];
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// Load all reference data from bundled assets. Idempotent — safe to call
  /// multiple times.
  Future<void> load() async {
    if (_loaded) return;

    final futures = await Future.wait([
      rootBundle.loadString('assets/data/factions.json'),
      rootBundle.loadString('assets/data/missions.json'),
      rootBundle.loadString('assets/data/locations.json'),
      rootBundle.loadString('assets/data/commodities.json'),
      rootBundle.loadString('assets/data/components.json'),
      rootBundle.loadString('assets/data/stores.json'),
      rootBundle.loadString('assets/data/tools.json'),
      rootBundle.loadString('assets/data/mining_gadgets.json'),
      rootBundle.loadString('assets/data/salvage_data.json'),
    ]);

    _factions = List<Map<String, dynamic>>.from(
      (json.decode(futures[0]) as List<dynamic>)
          .map((e) => e as Map<String, dynamic>),
    );
    _missions = List<Map<String, dynamic>>.from(
      (json.decode(futures[1]) as List<dynamic>)
          .map((e) => e as Map<String, dynamic>),
    );
    _locations = List<Map<String, dynamic>>.from(
      (json.decode(futures[2]) as List<dynamic>)
          .map((e) => e as Map<String, dynamic>),
    );
    _commodities = List<Map<String, dynamic>>.from(
      (json.decode(futures[3]) as List<dynamic>)
          .map((e) => e as Map<String, dynamic>),
    );
    _components = List<Map<String, dynamic>>.from(
      (json.decode(futures[4]) as List<dynamic>)
          .map((e) => e as Map<String, dynamic>),
    );
    _stores = List<Map<String, dynamic>>.from(
      (json.decode(futures[5]) as List<dynamic>)
          .map((e) => e as Map<String, dynamic>),
    );
    _tools = List<Map<String, dynamic>>.from(
      (json.decode(futures[6]) as List<dynamic>)
          .map((e) => e as Map<String, dynamic>),
    );
    _miningGadgets = List<Map<String, dynamic>>.from(
      (json.decode(futures[7]) as List<dynamic>)
          .map((e) => e as Map<String, dynamic>),
    );
    _salvageData = List<Map<String, dynamic>>.from(
      (json.decode(futures[8]) as List<dynamic>)
          .map((e) => e as Map<String, dynamic>),
    );

    _loaded = true;
  }

  /// Unmodifiable views of each category.
  List<Map<String, dynamic>> get factions =>
      List.unmodifiable(_factions);
  List<Map<String, dynamic>> get missions =>
      List.unmodifiable(_missions);
  List<Map<String, dynamic>> get locations =>
      List.unmodifiable(_locations);
  List<Map<String, dynamic>> get commodities =>
      List.unmodifiable(_commodities);
  List<Map<String, dynamic>> get components =>
      List.unmodifiable(_components);
  List<Map<String, dynamic>> get stores =>
      List.unmodifiable(_stores);
  List<Map<String, dynamic>> get tools =>
      List.unmodifiable(_tools);
  List<Map<String, dynamic>> get miningGadgets =>
      List.unmodifiable(_miningGadgets);
  List<Map<String, dynamic>> get salvageData =>
      List.unmodifiable(_salvageData);

  /// Search across all categories by name, type, or location planet.
  /// Returns a flat list of maps with the category name stored under `_category`.
  List<Map<String, dynamic>> search(String query) {
    final q = query.toLowerCase();
    final results = <Map<String, dynamic>>[];

    for (final f in _factions) {
      if ((f['name'] as String).toLowerCase().contains(q) ||
          (f['type'] as String).toLowerCase().contains(q)) {
        results.add({...f, '_category': 'factions'});
      }
    }
    for (final m in _missions) {
      if ((m['name'] as String).toLowerCase().contains(q) ||
          (m['type'] as String).toLowerCase().contains(q)) {
        results.add({...m, '_category': 'missions'});
      }
    }
    for (final l in _locations) {
      if ((l['name'] as String).toLowerCase().contains(q) ||
          (l['planet'] as String?)?.toLowerCase().contains(q) == true) {
        results.add({...l, '_category': 'locations'});
      }
    }
    for (final c in _commodities) {
      if ((c['name'] as String).toLowerCase().contains(q) ||
          (c['type'] as String).toLowerCase().contains(q)) {
        results.add({...c, '_category': 'commodities'});
      }
    }
    for (final c in _components) {
      if ((c['name'] as String).toLowerCase().contains(q) ||
          (c['category'] as String).toLowerCase().contains(q) ||
          (c['manufacturer'] as String).toLowerCase().contains(q)) {
        results.add({...c, '_category': 'components'});
      }
    }
    for (final s in _stores) {
      if ((s['name'] as String).toLowerCase().contains(q) ||
          (s['location'] as String).toLowerCase().contains(q) ||
          (s['planet'] as String).toLowerCase().contains(q)) {
        results.add({...s, '_category': 'stores'});
      }
    }

    return results;
  }
}
