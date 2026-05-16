import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sc_synthesis/core/data/reference_database.dart';

/// A single component slot in a loadout.
class LoadoutSlot {
  final String category; // weapon, shieldgenerator, powerplant, cooler, quantumdrive, radar
  String? componentId;
  Map<String, dynamic>? componentData;

  LoadoutSlot({required this.category, this.componentId, this.componentData});

  Map<String, dynamic> toJson() => {
        'category': category,
        'componentId': componentId,
      };

  factory LoadoutSlot.fromJson(Map<String, dynamic> json) => LoadoutSlot(
        category: json['category'] as String,
        componentId: json['componentId'] as String?,
      );

  String get label {
    switch (category) {
      case 'weapons':
        return 'Weapons';
      case 'shieldgenerator':
        return 'Shield';
      case 'powerplant':
        return 'Power Plant';
      case 'cooler':
        return 'Cooler';
      case 'quantumdrive':
        return 'Quantum Drive';
      case 'radar':
        return 'Radar';
      default:
        return category;
    }
  }
}

/// A complete loadout for one ship.
class Loadout {
  final String id;
  String shipId;
  String shipName;
  String shipSlug;
  List<LoadoutSlot> slots;
  String name; // user-given name
  DateTime createdAt;
  DateTime updatedAt;

  Loadout({
    required this.id,
    required this.shipId,
    required this.shipName,
    required this.shipSlug,
    required this.name,
    List<LoadoutSlot>? slots,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : slots = slots ?? _defaultSlots(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  static List<LoadoutSlot> _defaultSlots() => [
        LoadoutSlot(category: 'weapons'),
        LoadoutSlot(category: 'shieldgenerator'),
        LoadoutSlot(category: 'powerplant'),
        LoadoutSlot(category: 'cooler'),
        LoadoutSlot(category: 'quantumdrive'),
        LoadoutSlot(category: 'radar'),
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'shipId': shipId,
        'shipName': shipName,
        'shipSlug': shipSlug,
        'name': name,
        'slots': slots.map((s) => s.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Loadout.fromJson(Map<String, dynamic> json) => Loadout(
        id: json['id'] as String,
        shipId: json['shipId'] as String,
        shipName: json['shipName'] as String,
        shipSlug: json['shipSlug'] as String,
        name: json['name'] as String,
        slots: (json['slots'] as List<dynamic>)
            .map((s) => LoadoutSlot.fromJson(s as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  /// Resolve component data from ReferenceDatabase for all filled slots.
  void resolveComponents(ReferenceDatabase db) {
    for (final slot in slots) {
      if (slot.componentId != null) {
        slot.componentData = db.components.cast<Map<String, dynamic>?>().firstWhere(
              (c) => c?['id'] == slot.componentId,
              orElse: () => null,
            );
      }
    }
  }

  double get totalCost {
    double cost = 0;
    for (final slot in slots) {
      if (slot.componentData != null) {
        cost += (slot.componentData!['price'] as num?)?.toDouble() ?? 0;
      }
    }
    return cost;
  }
}

/// Persistence layer for saved loadouts.
class LoadoutService extends ChangeNotifier {
  static final LoadoutService _instance = LoadoutService._();
  factory LoadoutService() => _instance;
  LoadoutService._();

  List<Loadout> _loadouts = [];
  bool _loaded = false;

  List<Loadout> get loadouts => List.unmodifiable(_loadouts);

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('loadouts');
    if (raw != null) {
      final list = json.decode(raw) as List<dynamic>;
      _loadouts = list
          .map((e) => Loadout.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode(_loadouts.map((l) => l.toJson()).toList());
    await prefs.setString('loadouts', raw);
    notifyListeners();
  }

  Future<void> addLoadout(Loadout loadout) async {
    _loadouts.add(loadout);
    await _save();
  }

  Future<void> updateLoadout(Loadout loadout) async {
    final idx = _loadouts.indexWhere((l) => l.id == loadout.id);
    if (idx >= 0) {
      loadout.updatedAt = DateTime.now();
      _loadouts[idx] = loadout;
      await _save();
    }
  }

  Future<void> deleteLoadout(String id) async {
    _loadouts.removeWhere((l) => l.id == id);
    await _save();
  }

  Future<void> duplicateLoadout(String id) async {
    final idx = _loadouts.indexWhere((l) => l.id == id);
    if (idx >= 0) {
      final original = _loadouts[idx];
      final copy = Loadout(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        shipId: original.shipId,
        shipName: original.shipName,
        shipSlug: original.shipSlug,
        name: '${original.name} (copy)',
        slots: original.slots
            .map((s) => LoadoutSlot(
                  category: s.category,
                  componentId: s.componentId,
                ))
            .toList(),
      );
      _loadouts.add(copy);
      await _save();
    }
  }
}
