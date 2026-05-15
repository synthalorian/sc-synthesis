import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:sc_synthesis/core/api/api_endpoints.dart';

/// Singleton HTTP client for the SC:Synthesis Rust server
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('[API] $obj'),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout) {
            // Server might be down
            handler.next(error);
          } else if (error.response?.statusCode == 401) {
            // Auth expired
            handler.next(error);
          } else {
            handler.next(error);
          }
        },
      ),
    );
  }

  Dio get dio => _dio;

  /// Check if the Rust server is reachable
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get(ApiEndpoints.status);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Login to RSI via the Rust proxy
  Future<LoginApiResponse> login(String username, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'username': username, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;
      return LoginApiResponse(
        success: data['success'] as bool? ?? false,
        requires2fa: data['requires_2fa'] as bool? ?? false,
        sessionId: data['session_id'] as String?,
        message: data['message'] as String? ?? '',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final data = e.response?.data as Map<String, dynamic>?;
        return LoginApiResponse(
          success: false,
          requires2fa: false,
          message: data?['message'] as String? ?? 'Login failed',
        );
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return LoginApiResponse(
          success: false,
          requires2fa: false,
          message: 'Cannot connect to SC:Synthesis server. Is it running?',
        );
      }
      return LoginApiResponse(
        success: false,
        requires2fa: false,
        message: 'Network error: ${e.message}',
      );
    } catch (e) {
      return LoginApiResponse(
        success: false,
        requires2fa: false,
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Fetch the user's fleet from the server
  Future<List<FleetShip>> getFleet() async {
    try {
      final response = await _dio.get(ApiEndpoints.fleet);
      final data = response.data as List<dynamic>;
      return data
          .map((e) => FleetShip.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Fetch all ships from the server database (populated via FleetYards sync)
  Future<List<Ship>> getShips() async {
    try {
      final response = await _dio.get(ApiEndpoints.ships);
      final data = response.data as List<dynamic>;
      return data.map((e) => Ship.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Trigger a sync of ship data from FleetYards.net
  Future<SyncResult> syncShips() async {
    try {
      final response = await _dio.post(ApiEndpoints.syncShips);
      final data = response.data as Map<String, dynamic>;
      return SyncResult(
        success: data['success'] as bool? ?? false,
        imported: data['imported'] as int? ?? 0,
        message: data['message'] as String? ?? 'Unknown result',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        return SyncResult(
          success: false,
          imported: 0,
          message: 'Cannot connect to server. Is it running?',
        );
      }
      return SyncResult(
        success: false,
        imported: 0,
        message: 'Sync error: ${e.message}',
      );
    } catch (e) {
      return SyncResult(
        success: false,
        imported: 0,
        message: 'Unexpected error: $e',
      );
    }
  }
}

/// Response from login endpoint
class LoginApiResponse {
  final bool success;
  final bool requires2fa;
  final String? sessionId;
  final String message;

  const LoginApiResponse({
    required this.success,
    required this.requires2fa,
    this.sessionId,
    required this.message,
  });
}

/// A ship in the user's fleet (from server)
class FleetShip {
  final String id;
  final String name;
  final String manufacturer;
  final String size;
  final String role;

  const FleetShip({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.size,
    required this.role,
  });

  factory FleetShip.fromJson(Map<String, dynamic> json) {
    return FleetShip(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      manufacturer: json['manufacturer'] as String? ?? '',
      size: json['size'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }
}

/// A ship from the master database (populated from FleetYards)
class Ship {
  final String id;
  final String name;
  final String manufacturer;
  final String size;
  final String role;
  final int crewMin;
  final int crewMax;
  final double cargoCapacity;
  final double pledgePrice;
  final double maxSpeed;
  final double shieldHp;
  final double hullHp;
  final String description;

  const Ship({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.size,
    required this.role,
    required this.crewMin,
    required this.crewMax,
    required this.cargoCapacity,
    required this.pledgePrice,
    required this.maxSpeed,
    required this.shieldHp,
    required this.hullHp,
    required this.description,
  });

  factory Ship.fromJson(Map<String, dynamic> json) {
    return Ship(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      manufacturer: json['manufacturer'] as String? ?? '',
      size: json['size'] as String? ?? '',
      role: json['role'] as String? ?? '',
      crewMin: (json['crew_min'] as num?)?.toInt() ?? 1,
      crewMax: (json['crew_max'] as num?)?.toInt() ?? 1,
      cargoCapacity: (json['cargo_capacity'] as num?)?.toDouble() ?? 0.0,
      pledgePrice: (json['pledge_price'] as num?)?.toDouble() ?? 0.0,
      maxSpeed: (json['max_speed'] as num?)?.toDouble() ?? 0.0,
      shieldHp: (json['shield_hp'] as num?)?.toDouble() ?? 0.0,
      hullHp: (json['hull_hp'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
    );
  }
}

/// Result of a FleetYards sync operation
class SyncResult {
  final bool success;
  final int imported;
  final String message;

  const SyncResult({
    required this.success,
    required this.imported,
    required this.message,
  });
}
