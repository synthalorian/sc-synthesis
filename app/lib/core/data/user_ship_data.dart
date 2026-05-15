import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the user's locally-tracked fleet — ships they own, want, notes.
/// 100% offline — stored in SharedPreferences as JSON.
class UserShipData extends ChangeNotifier {
  static final UserShipData _instance = UserShipData._();
  factory UserShipData() => _instance;
  UserShipData._();

  static const String _ownedKey = 'user_owned_ships';
  static const String _wishlistKey = 'user_wishlist_ships';
  static const String _notesKey = 'user_ship_notes';

  Set<String> _ownedIds = {};
  Set<String> _wishlistIds = {};
  Map<String, String> _notes = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;
  Set<String> get ownedIds => Set.unmodifiable(_ownedIds);
  Set<String> get wishlistIds => Set.unmodifiable(_wishlistIds);
  int get ownedCount => _ownedIds.length;
  int get wishlistCount => _wishlistIds.length;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();

    final ownedJson = prefs.getString(_ownedKey);
    if (ownedJson != null) {
      _ownedIds = Set.from(json.decode(ownedJson) as List);
    }

    final wishJson = prefs.getString(_wishlistKey);
    if (wishJson != null) {
      _wishlistIds = Set.from(json.decode(wishJson) as List);
    }

    final notesJson = prefs.getString(_notesKey);
    if (notesJson != null) {
      _notes = Map<String, String>.from(json.decode(notesJson) as Map);
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ownedKey, json.encode(_ownedIds.toList()));
    await prefs.setString(_wishlistKey, json.encode(_wishlistIds.toList()));
    await prefs.setString(_notesKey, json.encode(_notes));
  }

  bool isOwned(String shipId) => _ownedIds.contains(shipId);
  bool isWishlisted(String shipId) => _wishlistIds.contains(shipId);
  String? getNote(String shipId) => _notes[shipId];

  Future<void> toggleOwned(String shipId) async {
    if (_ownedIds.contains(shipId)) {
      _ownedIds.remove(shipId);
    } else {
      _ownedIds.add(shipId);
      _wishlistIds.remove(shipId); // remove from wishlist if now owned
    }
    await _save();
    notifyListeners();
  }

  Future<void> toggleWishlist(String shipId) async {
    if (_wishlistIds.contains(shipId)) {
      _wishlistIds.remove(shipId);
    } else {
      _wishlistIds.add(shipId);
      _ownedIds.remove(shipId); // remove from owned if wishlisted instead
    }
    await _save();
    notifyListeners();
  }

  Future<void> setNote(String shipId, String note) async {
    if (note.isEmpty) {
      _notes.remove(shipId);
    } else {
      _notes[shipId] = note;
    }
    await _save();
    notifyListeners();
  }
}
