import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sc_synthesis/core/api/api_client.dart';

/// Authentication state for the app
enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
  requires2fa,
  error,
}

/// Manages authentication state and session persistence
class AuthManager extends ChangeNotifier {
  static const String _sessionKey = 'auth_session_id';
  static const String _usernameKey = 'auth_username';

  final ApiClient _api = ApiClient();

  AuthStatus _status = AuthStatus.unauthenticated;
  String _errorMessage = '';
  String? _sessionId;
  String? _username;

  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get sessionId => _sessionId;
  String? get username => _username;

  AuthManager() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString(_sessionKey);
    final username = prefs.getString(_usernameKey);

    if (sessionId != null && username != null) {
      _sessionId = sessionId;
      _username = username;
      _status = AuthStatus.authenticated;
      notifyListeners();
    }
  }

  /// Attempt to log in to RSI via the Rust server
  Future<void> login(String username, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = '';
    notifyListeners();

    final response = await _api.login(username, password);

    if (response.success && !response.requires2fa) {
      // Login successful
      _status = AuthStatus.authenticated;
      _sessionId = response.sessionId;
      _username = username;

      // Persist session
      final prefs = await SharedPreferences.getInstance();
      if (response.sessionId != null) {
        await prefs.setString(_sessionKey, response.sessionId!);
      }
      await prefs.setString(_usernameKey, username);
    } else if (response.requires2fa) {
      _status = AuthStatus.requires2fa;
    } else {
      _status = AuthStatus.error;
      _errorMessage = response.message;
    }

    notifyListeners();
  }

  /// Log out and clear session
  Future<void> logout() async {
    _status = AuthStatus.unauthenticated;
    _sessionId = null;
    _username = null;
    _errorMessage = '';

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_usernameKey);

    notifyListeners();
  }
}
