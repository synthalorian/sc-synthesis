/// API endpoint constants for the SC:Synthesis Rust server
class ApiEndpoints {
  /// The base URL of the SC:Synthesis Rust API server
  /// Change this to your server's address in production
  static const String baseUrl = 'http://localhost:3001';

  static const String apiPrefix = '/api/v1';

  // Auth
  static const String login = '$apiPrefix/auth/login';
  static const String verify2fa = '$apiPrefix/auth/verify';
  static const String logout = '$apiPrefix/auth/logout';

  // Fleet
  static const String fleet = '$apiPrefix/fleet';
  static const String fleetValue = '$apiPrefix/fleet/value';

  // Ships
  static const String ships = '$apiPrefix/ships';
  static const String syncShips = '$apiPrefix/ships/sync';
  static String ship(String id) => '$apiPrefix/ships/$id';

  // Status
  static const String status = '$apiPrefix/status';
}
